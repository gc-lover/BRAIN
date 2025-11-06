---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:35  
**api-readiness-notes:** Session Lifecycle микрофича. Create, heartbeat, disconnect, reconnect, timeout. ~360 строк.
---

# Session Lifecycle - Жизненный цикл сессий

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:35  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Session create/disconnect/reconnect  
**Размер:** ~360 строк ✅

---

## Краткое описание

**Session Lifecycle** - управление жизненным циклом игровых сессий.

**Ключевые возможности:**
- ✅ Create session (при входе)
- ✅ Heartbeat (keep-alive)
- ✅ Disconnect (timeout/manual)
- ✅ Reconnect (восстановление)
- ✅ Session timeout (5 min AFK → disconnect)

---

## Database Schema

```sql
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Player
    player_id UUID NOT NULL,
    character_id UUID,
    
    -- Connection
    server_id VARCHAR(100) NOT NULL,
    instance_id VARCHAR(100),
    ws_connection_id VARCHAR(255),
    
    -- State
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    -- ACTIVE, AFK, DISCONNECTED, RECONNECTING
    
    -- Position
    location JSONB,
    zone_id VARCHAR(100),
    
    -- Heartbeat
    last_heartbeat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    afk_since TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    disconnected_at TIMESTAMP,
    
    CONSTRAINT fk_session_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_session_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE SET NULL
);

CREATE INDEX idx_sessions_player ON game_sessions(player_id, status);
CREATE INDEX idx_sessions_heartbeat ON game_sessions(last_heartbeat) 
    WHERE status = 'ACTIVE';
```

---

## Create Session

```java
@Transactional
public SessionResponse createSession(UUID playerId, UUID characterId) {
    // 1. Проверить активные сессии
    Optional<GameSession> existingSession = sessionRepository
        .findActiveByPlayer(playerId);
    
    if (existingSession.isPresent()) {
        // Disconnect старую сессию
        disconnectSession(existingSession.get().getId(), "New login");
    }
    
    // 2. Загрузить character
    Character character = characterRepository.findById(characterId).orElseThrow();
    
    // 3. Создать сессию
    GameSession session = new GameSession();
    session.setPlayerId(playerId);
    session.setCharacterId(characterId);
    session.setServerId(getCurrentServerId());
    session.setZoneId(character.getCurrentZoneId());
    session.setLocation(character.getLocation());
    session.setWsConnectionId(generateConnectionId());
    
    session = sessionRepository.save(session);
    
    // 4. Redis cache (fast lookup)
    redis.opsForValue().set(
        "session:" + playerId,
        session.getId().toString(),
        30, TimeUnit.MINUTES
    );
    
    // 5. Notify other systems
    eventPublisher.publishEvent(new SessionCreatedEvent(session));
    
    return new SessionResponse(session);
}
```

---

## Heartbeat

```java
@Scheduled(fixedDelay = 30000) // Каждые 30 секунд
public void processHeartbeats() {
    List<GameSession> activeSessions = sessionRepository.findAllActive();
    
    for (GameSession session : activeSessions) {
        Duration sinceLastHeartbeat = Duration.between(
            session.getLastHeartbeat(),
            Instant.now()
        );
        
        // AFK detection (>2 min no heartbeat)
        if (sinceLastHeartbeat.toMinutes() > 2 && session.getStatus() == SessionStatus.ACTIVE) {
            session.setStatus(SessionStatus.AFK);
            session.setAfkSince(Instant.now());
            sessionRepository.save(session);
            
            wsService.sendToPlayer(session.getPlayerId(), 
                new AFKWarningMessage("You are now AFK"));
        }
        
        // Timeout (>5 min no heartbeat)
        if (sinceLastHeartbeat.toMinutes() > 5) {
            disconnectSession(session.getId(), "Connection timeout");
        }
    }
}

@PostMapping("/sessions/heartbeat")
public void heartbeat(@RequestHeader("Authorization") String token) {
    UUID playerId = extractPlayerId(token);
    
    GameSession session = sessionRepository.findActiveByPlayer(playerId)
        .orElseThrow(() -> new SessionNotFoundException());
    
    session.setLastHeartbeat(Instant.now());
    
    // Вернуть из AFK
    if (session.getStatus() == SessionStatus.AFK) {
        session.setStatus(SessionStatus.ACTIVE);
        session.setAfkSince(null);
    }
    
    sessionRepository.save(session);
}
```

---

## Disconnect

```java
@Transactional
public void disconnectSession(UUID sessionId, String reason) {
    GameSession session = sessionRepository.findById(sessionId).orElseThrow();
    
    // 1. Обновить статус
    session.setStatus(SessionStatus.DISCONNECTED);
    session.setDisconnectedAt(Instant.now());
    sessionRepository.save(session);
    
    // 2. Save character state
    characterService.saveCharacterState(session.getCharacterId());
    
    // 3. Leave party/raid
    if (session.getPartyId() != null) {
        partyService.removeMember(session.getPartyId(), session.getPlayerId());
    }
    
    // 4. Redis cleanup
    redis.delete("session:" + session.getPlayerId());
    
    // 5. Close WebSocket
    wsService.disconnect(session.getWsConnectionId(), reason);
    
    // 6. Event
    eventPublisher.publishEvent(new SessionDisconnectedEvent(session, reason));
}
```

---

## Reconnect

```java
@PostMapping("/sessions/reconnect")
public ReconnectResponse reconnect(
    @RequestHeader("Authorization") String token,
    @RequestBody ReconnectRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Найти disconnected сессию (<10 min ago)
    GameSession session = sessionRepository
        .findRecentDisconnectedByPlayer(playerId, Duration.ofMinutes(10))
        .orElse(null);
    
    if (session == null) {
        // Создать новую сессию
        return createSession(playerId, request.getCharacterId());
    }
    
    // 2. Восстановить сессию
    session.setStatus(SessionStatus.ACTIVE);
    session.setLastHeartbeat(Instant.now());
    session.setWsConnectionId(generateConnectionId());
    session.setDisconnectedAt(null);
    sessionRepository.save(session);
    
    // 3. Redis cache
    redis.opsForValue().set(
        "session:" + playerId,
        session.getId().toString(),
        30, TimeUnit.MINUTES
    );
    
    return new ReconnectResponse(session, "Session restored");
}
```

---

## API Endpoints

**POST `/api/v1/sessions/create`** - создать сессию
**POST `/api/v1/sessions/heartbeat`** - heartbeat
**POST `/api/v1/sessions/disconnect`** - disconnect
**POST `/api/v1/sessions/reconnect`** - reconnect

---

## Связанные документы

- `.BRAIN/05-technical/backend/session/session-management.md` - Management (микрофича 2/3)
- `.BRAIN/05-technical/backend/session/session-concurrency.md` - Concurrency (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:35)** - Микрофича 1/3: Session Lifecycle (split from session-management-system.md)

