---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:55  
**api-readiness-notes:** Полная система управления игровыми сессиями. Создание/закрытие, heartbeat, AFK detection, reconnection, concurrent sessions, session state.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-106: api/v1/technical/session-management.yaml (2025-11-07)
- Last Updated: 2025-11-07 05:20
---

# Session Management System - Управление игровыми сессиями

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:55  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---

## Краткое описание

**Session Management System** - критически важная система для управления игровыми сессиями игроков в MMORPG NECPGAME. Обеспечивает создание, поддержание, мониторинг и закрытие сессий, обработку переподключений и защиту от множественных входов.

**Ключевые возможности:**
- ✅ Создание/закрытие сессий при login/logout
- ✅ Heartbeat механизм (keepalive)
- ✅ AFK detection (автоматический logout)
- ✅ Reconnection handling (быстрое переподключение)
- ✅ Concurrent sessions control (защита от дублирования)
- ✅ Session state management (что хранить)
- ✅ Session timeout (автоматическое закрытие)

---

## Архитектура системы

### High-Level Overview

```
┌─────────────┐
│   CLIENT    │
└──────┬──────┘
       │ 1. Login
       ▼
┌─────────────┐
│ API Gateway │
└──────┬──────┘
       │ 2. Authenticate
       ▼
┌─────────────────────┐
│  Session Manager    │
│  - Create session   │
│  - Generate token   │
│  - Store in cache   │
└──────┬──────────────┘
       │
       ├─→ Redis (Session Store)
       └─→ PostgreSQL (Audit Log)
       
       │ 3. Heartbeat every 30s
       ▼
┌─────────────────────┐
│  Session Manager    │
│  - Update last_seen │
│  - Check expiration │
└─────────────────────┘

       │ 4. Logout or Timeout
       ▼
┌─────────────────────┐
│  Session Manager    │
│  - Close session    │
│  - Cleanup state    │
│  - Log event        │
└─────────────────────┘
```

---

## Session Lifecycle (Жизненный цикл сессии)

### Этапы сессии

```
1. CREATED     - Сессия создана при login
   ↓
2. ACTIVE      - Игрок активен, отправляет heartbeat
   ↓
3. IDLE        - Игрок неактивен (нет действий 5 минут)
   ↓
4. AFK         - Игрок AFK (нет heartbeat 10 минут)
   ↓
5. DISCONNECTED - Соединение потеряно (reconnect возможен 5 минут)
   ↓
6. EXPIRED     - Сессия истекла (timeout)
   ↓
7. CLOSED      - Сессия закрыта (logout или cleanup)
```

### State Transitions

```
CREATED → ACTIVE (первый heartbeat)
ACTIVE → IDLE (no actions 5 min)
IDLE → ACTIVE (action performed)
IDLE → AFK (no heartbeat 10 min)
AFK → DISCONNECTED (connection lost)
DISCONNECTED → ACTIVE (reconnect successful)
DISCONNECTED → EXPIRED (reconnect timeout)
AFK → EXPIRED (AFK timeout 30 min)
ACTIVE/IDLE/AFK → CLOSED (logout)
EXPIRED → CLOSED (cleanup)
```

---

## Database Schema

### Таблица `player_sessions`

```sql
CREATE TABLE player_sessions (
    -- Идентификация
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_token VARCHAR(512) UNIQUE NOT NULL, -- JWT token
    
    -- Игрок
    player_id UUID NOT NULL,
    character_id UUID, -- Активный персонаж (может быть NULL при login)
    account_id UUID NOT NULL,
    
    -- Сервер и регион
    server_id VARCHAR(100) NOT NULL,
    zone_id VARCHAR(100), -- Текущая зона игрока
    instance_id VARCHAR(100), -- Instance (для dungeons, raids)
    
    -- Состояние сессии
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED', 
    -- CREATED, ACTIVE, IDLE, AFK, DISCONNECTED, EXPIRED, CLOSED
    
    -- Временные метки
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_heartbeat_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_action_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL, -- Когда сессия истечет
    closed_at TIMESTAMP, -- Когда закрыта
    
    -- Network информация
    ip_address VARCHAR(45) NOT NULL, -- IPv4 или IPv6
    user_agent TEXT,
    client_version VARCHAR(20),
    
    -- Session data (временные данные)
    session_data JSONB, -- Любые временные данные сессии
    
    -- Reconnection
    can_reconnect BOOLEAN DEFAULT TRUE,
    reconnect_token VARCHAR(512), -- Токен для быстрого переподключения
    reconnect_expires_at TIMESTAMP,
    
    -- Статистика
    total_heartbeats INTEGER DEFAULT 0,
    total_actions INTEGER DEFAULT 0,
    afk_count INTEGER DEFAULT 0,
    disconnections_count INTEGER DEFAULT 0,
    
    -- Закрытие сессии
    close_reason VARCHAR(100), -- LOGOUT, TIMEOUT, AFK, KICKED, ERROR
    
    -- Служебное
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT fk_session_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_session_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE SET NULL,
    CONSTRAINT fk_session_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

-- Индексы
CREATE INDEX idx_sessions_player ON player_sessions(player_id);
CREATE INDEX idx_sessions_token ON player_sessions(session_token) 
    WHERE status IN ('ACTIVE', 'IDLE', 'AFK');
CREATE INDEX idx_sessions_status ON player_sessions(status);
CREATE INDEX idx_sessions_server ON player_sessions(server_id);
CREATE INDEX idx_sessions_expires ON player_sessions(expires_at) 
    WHERE status NOT IN ('CLOSED', 'EXPIRED');
CREATE INDEX idx_sessions_last_heartbeat ON player_sessions(last_heartbeat_at DESC);

-- Unique constraint: один активный session на игрока (опционально)
CREATE UNIQUE INDEX idx_sessions_one_per_player 
    ON player_sessions(player_id) 
    WHERE status IN ('ACTIVE', 'IDLE', 'AFK', 'DISCONNECTED');
```

### Таблица `session_audit_log`

```sql
CREATE TABLE session_audit_log (
    id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL,
    player_id UUID NOT NULL,
    
    -- Событие
    event_type VARCHAR(50) NOT NULL, 
    -- SESSION_CREATED, SESSION_CLOSED, HEARTBEAT, RECONNECT, AFK, KICKED
    
    -- Детали
    details JSONB,
    
    -- Временная метка
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_audit_session FOREIGN KEY (session_id) 
        REFERENCES player_sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_audit_session ON session_audit_log(session_id);
CREATE INDEX idx_audit_player ON session_audit_log(player_id);
CREATE INDEX idx_audit_created ON session_audit_log(created_at DESC);
```

---

## Redis Cache Structure

### Session Cache (для быстрого доступа)

**Key format:** `session:{sessionToken}`

**Value:**
```json
{
  "sessionId": "uuid",
  "playerId": "uuid",
  "characterId": "uuid",
  "accountId": "uuid",
  "serverId": "server-01",
  "zoneId": "nightCity.watson",
  "status": "ACTIVE",
  "createdAt": "2025-11-06T21:00:00Z",
  "lastHeartbeat": "2025-11-06T21:30:00Z",
  "expiresAt": "2025-11-07T21:00:00Z",
  "ipAddress": "192.168.1.1",
  "clientVersion": "1.0.0"
}
```

**TTL:** 24 hours (автоматическое удаление при истечении)

### Active Players Set

**Key:** `active_players:{serverId}`  
**Type:** Redis Set  
**Values:** Player IDs

**Operations:**
```
SADD active_players:server-01 {playerId}  (при login)
SREM active_players:server-01 {playerId}  (при logout)
SMEMBERS active_players:server-01          (получить всех онлайн)
SCARD active_players:server-01             (количество онлайн)
```

### Player → Session Mapping

**Key:** `player_session:{playerId}`  
**Value:** session_token  
**TTL:** 24 hours

**Usage:** Быстро найти сессию игрока

---

## Session Creation (Создание сессии)

### При Login

```java
@Service
public class SessionManager {
    
    @Autowired
    private SessionRepository sessionRepository;
    
    @Autowired
    private RedisTemplate<String, Object> redis;
    
    @Autowired
    private EventBus eventBus;
    
    @Transactional
    public SessionResponse createSession(
        UUID accountId,
        UUID playerId,
        String ipAddress,
        String userAgent,
        String clientVersion
    ) {
        // 1. Проверить существующие сессии игрока
        List<PlayerSession> existingSessions = sessionRepository
            .findActiveByPlayer(playerId);
        
        if (!existingSessions.isEmpty()) {
            // Обработка concurrent sessions (см. ниже)
            handleConcurrentSessions(playerId, existingSessions);
        }
        
        // 2. Создать новую сессию
        PlayerSession session = new PlayerSession();
        session.setSessionToken(generateSessionToken(accountId, playerId));
        session.setPlayerId(playerId);
        session.setAccountId(accountId);
        session.setServerId(getOptimalServer()); // Load balancing
        session.setStatus(SessionStatus.CREATED);
        session.setIpAddress(ipAddress);
        session.setUserAgent(userAgent);
        session.setClientVersion(clientVersion);
        session.setExpiresAt(Instant.now().plus(Duration.ofHours(24)));
        session.setCanReconnect(true);
        session.setReconnectToken(generateReconnectToken());
        session.setReconnectExpiresAt(Instant.now().plus(Duration.ofMinutes(5)));
        
        // 3. Сохранить в БД
        session = sessionRepository.save(session);
        
        // 4. Кэшировать в Redis
        String cacheKey = "session:" + session.getSessionToken();
        redis.opsForValue().set(cacheKey, session, 24, TimeUnit.HOURS);
        
        // Маппинг player → session
        redis.opsForValue().set(
            "player_session:" + playerId,
            session.getSessionToken(),
            24,
            TimeUnit.HOURS
        );
        
        // Добавить в active players
        redis.opsForSet().add("active_players:" + session.getServerId(), playerId);
        
        // 5. Логировать аудит
        logSessionEvent(session.getId(), playerId, "SESSION_CREATED", Map.of(
            "ipAddress", ipAddress,
            "clientVersion", clientVersion
        ));
        
        // 6. Опубликовать событие
        eventBus.publish(new SessionCreatedEvent(
            session.getId(),
            playerId,
            session.getServerId()
        ));
        
        // 7. Вернуть ответ
        return new SessionResponse(
            session.getSessionToken(),
            session.getReconnectToken(),
            session.getExpiresAt(),
            session.getServerId()
        );
    }
    
    private String generateSessionToken(UUID accountId, UUID playerId) {
        return jwtService.generateToken(Map.of(
            "sub", accountId.toString(),
            "player_id", playerId.toString(),
            "type", "session",
            "iat", Instant.now().getEpochSecond(),
            "exp", Instant.now().plus(Duration.ofHours(24)).getEpochSecond()
        ));
    }
}
```

---

## Heartbeat Mechanism (Механизм жизни)

### Концепция

**Проблема:** Как определить, что игрок онлайн?

**Решение:** Heartbeat каждые 30 секунд

```
Client → Server: POST /api/v1/session/heartbeat
Server → Client: 200 OK

Если heartbeat не пришел 3 минуты → AFK
Если heartbeat не пришел 10 минут → DISCONNECTED
```

### Heartbeat Endpoint

```java
@RestController
@RequestMapping("/api/v1/session")
public class SessionController {
    
    @PostMapping("/heartbeat")
    public ResponseEntity<HeartbeatResponse> heartbeat(
        @RequestHeader("Authorization") String token
    ) {
        String sessionToken = extractToken(token);
        
        // 1. Получить сессию из кэша
        String cacheKey = "session:" + sessionToken;
        PlayerSession session = (PlayerSession) redis.opsForValue().get(cacheKey);
        
        if (session == null) {
            // Сессия истекла или не существует
            return ResponseEntity.status(401).build();
        }
        
        // 2. Обновить last_heartbeat
        Instant now = Instant.now();
        session.setLastHeartbeatAt(now);
        session.setTotalHeartbeats(session.getTotalHeartbeats() + 1);
        
        // 3. Проверить и обновить статус
        if (session.getStatus() == SessionStatus.IDLE || 
            session.getStatus() == SessionStatus.AFK) {
            session.setStatus(SessionStatus.ACTIVE);
        }
        
        // 4. Обновить в кэше (быстро)
        redis.opsForValue().set(cacheKey, session, 24, TimeUnit.HOURS);
        
        // 5. Асинхронно обновить в БД (раз в минуту или batch)
        sessionUpdateQueue.add(session.getId(), now);
        
        // 6. Вернуть ответ
        return ResponseEntity.ok(new HeartbeatResponse(
            true,
            session.getStatus(),
            session.getExpiresAt()
        ));
    }
}
```

### Batch Update для производительности

```java
@Service
public class SessionBatchUpdater {
    
    private Map<UUID, Instant> updateQueue = new ConcurrentHashMap<>();
    
    public void queueUpdate(UUID sessionId, Instant lastHeartbeat) {
        updateQueue.put(sessionId, lastHeartbeat);
    }
    
    @Scheduled(fixedDelay = 60000) // Каждую минуту
    public void flushUpdates() {
        if (updateQueue.isEmpty()) {
            return;
        }
        
        // Batch update в БД
        List<UUID> sessionIds = new ArrayList<>(updateQueue.keySet());
        
        sessionRepository.batchUpdateHeartbeat(sessionIds, updateQueue);
        
        updateQueue.clear();
        
        log.info("Flushed {} session heartbeats to DB", sessionIds.size());
    }
}
```

---

## AFK Detection (Определение AFK)

### Auto-AFK Механизм

```java
@Service
public class AfkDetector {
    
    @Scheduled(fixedDelay = 60000) // Каждую минуту
    public void detectAfkPlayers() {
        Instant now = Instant.now();
        Instant idleThreshold = now.minus(Duration.ofMinutes(5));
        Instant afkThreshold = now.minus(Duration.ofMinutes(10));
        
        // 1. Найти IDLE игроков (нет действий 5 минут)
        List<PlayerSession> activeSessions = sessionRepository
            .findByStatus(SessionStatus.ACTIVE);
        
        for (PlayerSession session : activeSessions) {
            if (session.getLastActionAt().isBefore(idleThreshold)) {
                // Перевести в IDLE
                updateSessionStatus(session, SessionStatus.IDLE);
            }
        }
        
        // 2. Найти AFK игроков (нет heartbeat 10 минут)
        List<PlayerSession> idleSessions = sessionRepository
            .findByStatus(SessionStatus.IDLE);
        
        for (PlayerSession session : idleSessions) {
            if (session.getLastHeartbeatAt().isBefore(afkThreshold)) {
                // Перевести в AFK
                updateSessionStatus(session, SessionStatus.AFK);
                session.setAfkCount(session.getAfkCount() + 1);
                
                // Опубликовать событие
                eventBus.publish(new PlayerAfkEvent(
                    session.getPlayerId(),
                    session.getZoneId()
                ));
            }
        }
        
        // 3. Найти EXPIRED сессии (AFK > 30 минут)
        Instant expireThreshold = now.minus(Duration.ofMinutes(30));
        
        List<PlayerSession> afkSessions = sessionRepository
            .findByStatus(SessionStatus.AFK);
        
        for (PlayerSession session : afkSessions) {
            if (session.getLastHeartbeatAt().isBefore(expireThreshold)) {
                // Закрыть сессию
                closeSession(session.getId(), "AFK_TIMEOUT");
            }
        }
    }
}
```

### AFK Consequences

**В игре:**
- AFK игрок не может участвовать в боевых сессиях
- AFK игрок не получает loot в группе
- AFK игрок автоматически выходит из группы после 15 минут
- AFK в PvP зоне → уязвим для атак

**Notifications:**
```
IDLE (5 min): "You are now idle"
AFK (10 min): "You are AFK. Activity will be paused."
AFK Warning (25 min): "You will be disconnected in 5 minutes due to inactivity"
EXPIRED (30 min): "You have been disconnected due to inactivity"
```

---

## Reconnection Handling (Переподключение)

### Fast Reconnect

**Сценарий:** Игрок потерял соединение (сеть упала)

**Механизм:**
```
1. Client detects disconnect
2. Client tries to reconnect (auto or manual)
3. Client sends reconnect_token
4. Server validates token (5 min window)
5. Server restores session (same state)
6. Client continues from where left off
```

**Endpoint:**
```java
@PostMapping("/reconnect")
public ResponseEntity<SessionResponse> reconnect(
    @RequestBody ReconnectRequest request
) {
    String reconnectToken = request.getReconnectToken();
    
    // 1. Найти сессию по reconnect token
    PlayerSession session = sessionRepository
        .findByReconnectToken(reconnectToken);
    
    if (session == null) {
        return ResponseEntity.status(404).body(
            new ErrorResponse("Session not found")
        );
    }
    
    // 2. Проверить expiration
    if (Instant.now().isAfter(session.getReconnectExpiresAt())) {
        return ResponseEntity.status(410).body(
            new ErrorResponse("Reconnect window expired")
        );
    }
    
    // 3. Проверить статус
    if (session.getStatus() != SessionStatus.DISCONNECTED) {
        return ResponseEntity.status(409).body(
            new ErrorResponse("Session is not disconnected")
        );
    }
    
    // 4. Восстановить сессию
    session.setStatus(SessionStatus.ACTIVE);
    session.setLastHeartbeatAt(Instant.now());
    session.setDisconnectionsCount(session.getDisconnectionsCount() + 1);
    
    // 5. Сохранить
    sessionRepository.save(session);
    
    // Обновить кэш
    String cacheKey = "session:" + session.getSessionToken();
    redis.opsForValue().set(cacheKey, session, 24, TimeUnit.HOURS);
    
    // 6. Логировать
    logSessionEvent(session.getId(), session.getPlayerId(), "RECONNECTED", Map.of(
        "disconnectionDuration", Duration.between(
            session.getClosedAt(), Instant.now()
        ).getSeconds() + "s"
    ));
    
    // 7. Опубликовать событие
    eventBus.publish(new PlayerReconnectedEvent(
        session.getPlayerId(),
        session.getServerId(),
        session.getZoneId()
    ));
    
    // 8. Вернуть state для восстановления
    return ResponseEntity.ok(new SessionResponse(
        session.getSessionToken(),
        session.getReconnectToken(),
        session.getExpiresAt(),
        session.getServerId(),
        getSessionState(session) // Восстановление состояния
    ));
}
```

### Reconnect Window

```
Connection Lost
    ↓
5 minutes window (can reconnect)
    ↓
Session EXPIRED (cannot reconnect, must login again)
```

---

## Concurrent Sessions (Множественные сессии)

### Стратегии

**Стратегия 1: One Session Per Player (рекомендуется для MMORPG)**
```
Player tries to login
→ Check for existing active session
→ If found: Close old session, create new one
→ Result: Only one session allowed
```

**Стратегия 2: Multiple Sessions Allowed**
```
Player can login from multiple devices
→ Each device has own session
→ State synchronized between sessions
→ Actions from any session update global state
```

**Стратегия 3: Kick Old Session**
```
Player tries to login
→ Check for existing session
→ If found: Send disconnect to old session, create new
→ Old device receives "You have been logged in elsewhere"
```

### Реализация (Strategy 1)

```java
private void handleConcurrentSessions(
    UUID playerId,
    List<PlayerSession> existingSessions
) {
    log.warn("Player {} has {} existing sessions, closing them", 
        playerId, existingSessions.size());
    
    for (PlayerSession oldSession : existingSessions) {
        // 1. Уведомить старую сессию
        webSocketService.sendToSession(
            oldSession.getSessionToken(),
            new SessionKickedMessage(
                "You have been logged in from another location"
            )
        );
        
        // 2. Закрыть старую сессию
        closeSession(oldSession.getId(), "CONCURRENT_LOGIN");
        
        // 3. Подождать 2 секунды (чтобы уведомление дошло)
        Thread.sleep(2000);
    }
}
```

---

## Session Timeout (Таймауты сессии)

### Типы timeout

**1. Inactivity Timeout (неактивность):**
```
No heartbeat for 10 minutes → AFK
AFK for 30 minutes → Session EXPIRED
```

**2. Absolute Timeout (абсолютный):**
```
Session created 24 hours ago → Session EXPIRED
(даже если heartbeat есть)
```

**3. Idle Timeout (нет действий):**
```
No actions for 5 minutes → IDLE status
IDLE for 60 minutes → Session EXPIRED
```

### Cleanup Job

```java
@Service
public class SessionCleanupService {
    
    @Scheduled(cron = "0 */5 * * * *") // Каждые 5 минут
    public void cleanupExpiredSessions() {
        Instant now = Instant.now();
        
        // 1. Найти истекшие сессии
        List<PlayerSession> expiredSessions = sessionRepository
            .findByExpiresAtBefore(now);
        
        log.info("Found {} expired sessions to cleanup", expiredSessions.size());
        
        // 2. Закрыть каждую
        for (PlayerSession session : expiredSessions) {
            closeSession(session.getId(), "TIMEOUT");
        }
        
        // 3. Удалить старые closed сессии (>7 дней)
        Instant oldThreshold = now.minus(Duration.ofDays(7));
        int deleted = sessionRepository.deleteClosedBefore(oldThreshold);
        
        log.info("Deleted {} old closed sessions", deleted);
    }
}
```

---

## Session State Management (Управление состоянием сессии)

### Что хранить в session

**Минимальное (всегда):**
```json
{
  "playerId": "uuid",
  "characterId": "uuid",
  "serverId": "server-01",
  "zoneId": "nightCity.watson",
  "position": {"x": 1234, "y": 5678}
}
```

**Расширенное (опционально):**
```json
{
  "sessionData": {
    "currentQuest": "quest-uuid",
    "currentDialogueNode": 15,
    "combatSessionId": "combat-uuid",
    "partyId": "party-uuid",
    "instanceId": "instance-uuid",
    
    "temporaryBuffs": [
      {"buffId": "speed_boost", "expiresAt": "..."}
    ],
    
    "pendingActions": [
      {"type": "QUEST_CHOICE", "data": {...}}
    ],
    
    "uiState": {
      "lastOpenedMenu": "inventory",
      "tutorialStep": 5
    }
  }
}
```

### Update Session State

```java
@PostMapping("/state")
public ResponseEntity<Void> updateSessionState(
    @RequestHeader("Authorization") String token,
    @RequestBody Map<String, Object> stateUpdate
) {
    PlayerSession session = getSession(token);
    
    // Merge state (объединить новые данные с существующими)
    Map<String, Object> currentData = session.getSessionData();
    currentData.putAll(stateUpdate);
    session.setSessionData(currentData);
    
    // Обновить в Redis
    updateSessionCache(session);
    
    // Асинхронно в БД
    sessionUpdateQueue.add(session);
    
    return ResponseEntity.ok().build();
}
```

---

## Session Monitoring (Мониторинг сессий)

### Метрики

**Real-time metrics:**
```
sessions.active.total         - всего активных сессий
sessions.created.rate          - скорость создания сессий/мин
sessions.closed.rate           - скорость закрытия сессий/мин
sessions.afk.count             - количество AFK игроков
sessions.heartbeat.rate        - heartbeat/сек
sessions.reconnections.count   - количество reconnect
sessions.average.duration      - средняя длительность сессии
```

**Per-server metrics:**
```
sessions.active.server-01      - активные на сервере 1
sessions.active.server-02      - активные на сервере 2
```

### Dashboard

```java
@GetMapping("/admin/sessions/stats")
public SessionStats getSessionStats() {
    return new SessionStats(
        sessionRepository.countByStatus(SessionStatus.ACTIVE),
        sessionRepository.countByStatus(SessionStatus.IDLE),
        sessionRepository.countByStatus(SessionStatus.AFK),
        sessionRepository.countByStatus(SessionStatus.DISCONNECTED),
        redis.opsForSet().size("active_players:*"),
        getAverageSessionDuration(),
        getSessionsPerServer()
    );
}
```

---

## Session Closing (Закрытие сессии)

### Logout

```java
@PostMapping("/logout")
public ResponseEntity<Void> logout(
    @RequestHeader("Authorization") String token
) {
    String sessionToken = extractToken(token);
    PlayerSession session = getSession(sessionToken);
    
    closeSession(session.getId(), "LOGOUT");
    
    return ResponseEntity.ok().build();
}

@Transactional
private void closeSession(UUID sessionId, String reason) {
    // 1. Получить сессию
    PlayerSession session = sessionRepository.findById(sessionId);
    
    // 2. Сохранить состояние игрока перед закрытием
    if (session.getCharacterId() != null) {
        characterService.saveCurrentState(session.getCharacterId());
    }
    
    // 3. Обновить статус
    session.setStatus(SessionStatus.CLOSED);
    session.setClosedAt(Instant.now());
    session.setCloseReason(reason);
    session.setCanReconnect(false);
    
    sessionRepository.save(session);
    
    // 4. Удалить из кэша
    redis.delete("session:" + session.getSessionToken());
    redis.delete("player_session:" + session.getPlayerId());
    
    // Удалить из active players
    redis.opsForSet().remove(
        "active_players:" + session.getServerId(),
        session.getPlayerId()
    );
    
    // 5. Логировать
    logSessionEvent(session.getId(), session.getPlayerId(), "SESSION_CLOSED", Map.of(
        "reason", reason,
        "duration", Duration.between(
            session.getCreatedAt(), session.getClosedAt()
        ).getSeconds() + "s"
    ));
    
    // 6. Cleanup
    cleanupSessionResources(session);
    
    // 7. Опубликовать событие
    eventBus.publish(new SessionClosedEvent(
        session.getId(),
        session.getPlayerId(),
        reason
    ));
}

private void cleanupSessionResources(PlayerSession session) {
    // Покинуть party (если в группе)
    if (session.getSessionData().get("partyId") != null) {
        partyService.leave(session.getPlayerId());
    }
    
    // Закрыть combat session (если в бою)
    if (session.getSessionData().get("combatSessionId") != null) {
        combatService.exitCombat(session.getPlayerId());
    }
    
    // Закрыть trade (если в торговле)
    if (session.getSessionData().get("tradeSessionId") != null) {
        tradeService.cancelTrade(session.getPlayerId());
    }
}
```

---

## API Endpoints

### Session Management

**POST `/api/v1/session/create`** - создать сессию (при login)
**POST `/api/v1/session/heartbeat`** - heartbeat (каждые 30s)
**POST `/api/v1/session/reconnect`** - переподключение
**POST `/api/v1/session/logout`** - выход
**GET `/api/v1/session/info`** - информация о сессии
**PUT `/api/v1/session/state`** - обновить состояние сессии

**GET `/api/v1/session/active-players`** - список онлайн игроков
```json
{
  "serverId": "server-01",
  "activePlayers": 1523,
  "players": [
    {
      "playerId": "uuid",
      "characterName": "V",
      "zoneId": "nightCity.watson",
      "status": "ACTIVE",
      "onlineSince": "2025-11-06T20:00:00Z"
    }
  ],
  "page": 1,
  "total": 1523
}
```

### Admin Endpoints

**GET `/api/v1/admin/sessions`** - все сессии
**POST `/api/v1/admin/sessions/{id}/kick`** - kick игрока
**GET `/api/v1/admin/sessions/stats`** - статистика сессий

---

## Интеграция с другими системами

### При создании сессии

```
SessionManager.createSession()
  ↓
→ GlobalStateManager: set player.{id}.session = sessionId
→ EventBus: publish SESSION_CREATED
→ AnalyticsService: record login
→ NotificationService: send "Welcome back!"
```

### При heartbeat

```
SessionManager.heartbeat()
  ↓
→ GlobalStateManager: update player.{id}.lastSeen
→ ZoneManager: update player position (если изменилась)
```

### При logout

```
SessionManager.closeSession()
  ↓
→ GlobalStateManager: remove player.{id}.session
→ PartyService: leave party
→ CombatService: exit combat
→ EventBus: publish SESSION_CLOSED
→ AnalyticsService: record session duration
```

---

## Security

### Session Hijacking Protection

**Защиты:**
1. **IP Address Binding:**
```java
// Проверить IP при каждом heartbeat
if (!session.getIpAddress().equals(request.getRemoteAddr())) {
    log.warn("IP mismatch for session {}", sessionId);
    // Опционально: закрыть сессию или требовать re-auth
}
```

2. **User Agent Validation:**
```java
// Проверить User Agent
if (!session.getUserAgent().equals(request.getHeader("User-Agent"))) {
    log.warn("User-Agent mismatch for session {}", sessionId);
}
```

3. **Token Rotation:**
```java
// Обновить session token каждые 4 часа
if (Duration.between(session.getCreatedAt(), Instant.now()).toHours() > 4) {
    String newToken = generateSessionToken();
    session.setSessionToken(newToken);
    // Клиенту вернуть новый токен
}
```

### Brute Force Protection

```
Failed login attempts from IP:
3 attempts → 1 min cooldown
5 attempts → 5 min cooldown
10 attempts → 30 min cooldown
20 attempts → IP block (24 hours)
```

---

## Связанные документы

- `.BRAIN/05-technical/global-state-system.md` - Global State для хранения
- `.BRAIN/05-technical/api-specs/api-endpoints-complete.md` - Auth endpoints
- `.BRAIN/05-technical/api-specs/api-integration-map.md` - Интеграции

---

## TODO для реализации

- [ ] Определить точные timeout значения (балансировка)
- [ ] Настроить Redis persistence для sessions
- [ ] Реализовать graceful shutdown (сохранение сессий при рестарте)
- [ ] Load testing (сколько concurrent sessions выдержит)

---

## История изменений

- **v1.0.0 (2025-11-06 21:55)** - Создан документ Session Management System

