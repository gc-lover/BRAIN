---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:35  
**api-readiness-notes:** Session Management микрофича. Session state, location tracking, party/raid sessions. ~280 строк.
---

# Session Management - Управление состоянием сессий

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:35  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Session state management  
**Размер:** ~280 строк ✅

---

## Краткое описание

**Session Management** - управление состоянием сессий (location, party, activities).

**Ключевые возможности:**
- ✅ Session state tracking
- ✅ Location updates
- ✅ Party/Raid session tracking
- ✅ Activity tracking (in combat, trading)

---

## Session State

```java
public class SessionState {
    private UUID sessionId;
    private UUID playerId;
    private UUID characterId;
    
    // Location
    private String zoneId;
    private Vector3 position;
    private float rotation;
    
    // Activity
    private ActivityType currentActivity; // IDLE, COMBAT, TRADING, IN_DUNGEON
    private UUID activityId; // Combat ID, Trade ID, etc
    
    // Party
    private UUID partyId;
    private UUID raidId;
    
    // Status
    private boolean isInCombat;
    private boolean isTrading;
    private boolean isAFK;
}
```

---

## Location Tracking

```java
@PutMapping("/sessions/location")
public void updateLocation(
    @RequestHeader("Authorization") String token,
    @RequestBody LocationUpdate update
) {
    UUID playerId = extractPlayerId(token);
    GameSession session = getActiveSession(playerId);
    
    // Update location
    session.setLocation(update.getPosition());
    session.setZoneId(update.getZoneId());
    sessionRepository.save(session);
    
    // Broadcast to nearby players
    List<UUID> nearbyPlayers = locationService
        .getPlayersNearby(update.getPosition(), 100);
    
    wsService.broadcastToPlayers(nearbyPlayers,
        new PlayerMovedMessage(playerId, update.getPosition()));
}
```

---

## Activity Tracking

```java
public void enterCombat(UUID sessionId, UUID combatId) {
    GameSession session = sessionRepository.findById(sessionId).orElseThrow();
    session.setCurrentActivity(ActivityType.COMBAT);
    session.setActivityId(combatId);
    sessionRepository.save(session);
}

public void leaveCombat(UUID sessionId) {
    GameSession session = sessionRepository.findById(sessionId).orElseThrow();
    session.setCurrentActivity(ActivityType.IDLE);
    session.setActivityId(null);
    sessionRepository.save(session);
}
```

---

## API Endpoints

**PUT `/api/v1/sessions/location`** - обновить позицию
**GET `/api/v1/sessions/nearby`** - ближайшие игроки
**GET `/api/v1/sessions/status`** - статус сессии

---

## Связанные документы

- `.BRAIN/05-technical/backend/session/session-lifecycle.md` - Lifecycle (микрофича 1/3)
- `.BRAIN/05-technical/backend/session/session-concurrency.md` - Concurrency (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:35)** - Микрофича 2/3: Session Management (split from session-management-system.md)

