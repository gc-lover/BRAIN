---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:35  
**api-readiness-notes:** Session Concurrency микрофича. Concurrent sessions prevention, multi-device handling. ~250 строк.
---

# Session Concurrency - Контроль одновременных сессий

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:35  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Concurrent sessions control  
**Размер:** ~250 строк ✅

---

## Краткое описание

**Session Concurrency** - предотвращение одновременных сессий (1 аккаунт = 1 сессия).

**Ключевые возможности:**
- ✅ Concurrent session prevention
- ✅ Multi-device detection
- ✅ Kick old session
- ✅ Session validation

---

## Concurrent Session Check

```java
public void ensureSingleSession(UUID playerId) {
    List<GameSession> activeSessions = sessionRepository
        .findAllActiveByPlayer(playerId);
    
    if (activeSessions.isEmpty()) {
        return; // OK
    }
    
    if (activeSessions.size() == 1) {
        // Kick старую сессию
        GameSession oldSession = activeSessions.get(0);
        wsService.sendToPlayer(playerId, 
            new KickMessage("New login from another location"));
        
        disconnectSession(oldSession.getId(), "Concurrent login");
    } else {
        // Multiple sessions (data issue) - kick all
        for (GameSession session : activeSessions) {
            disconnectSession(session.getId(), "Data cleanup");
        }
    }
}
```

---

## Multi-Device Detection

```java
@Component
public class SessionValidator {
    
    public void validateSession(UUID sessionId, String ipAddress, String userAgent) {
        GameSession session = sessionRepository.findById(sessionId).orElseThrow();
        
        // Проверить IP change
        if (!session.getIpAddress().equals(ipAddress)) {
            log.warn("Session {} IP changed: {} -> {}", 
                sessionId, session.getIpAddress(), ipAddress);
            
            // TODO: Challenge (2FA, email verification)
        }
        
        // Проверить User-Agent change
        if (!session.getUserAgent().equals(userAgent)) {
            log.warn("Session {} User-Agent changed", sessionId);
        }
    }
}
```

---

## API Endpoints

**GET `/api/v1/sessions/active`** - список активных сессий
**DELETE `/api/v1/sessions/{id}/kick`** - kick сессию (admin)

---

## Связанные документы

- `.BRAIN/05-technical/backend/session/session-lifecycle.md` - Lifecycle (микрофича 1/3)
- `.BRAIN/05-technical/backend/session/session-management.md` - Management (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:35)** - Микрофича 3/3: Session Concurrency (split from session-management-system.md)

