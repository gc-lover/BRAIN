---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Система уведомлений. In-game notifications, WebSocket push, email notifications, types, preferences, history, batch notifications.
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-132: api/v1/notifications/notifications.yaml (2025-11-07 10:24)
- Last Updated: 2025-11-07 00:18
---



# Notification System - Система уведомлений

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** высокий  
**Автор:** AI Brain Manager

---

## Краткое описание

**Notification System** - система для отправки уведомлений игрокам о различных событиях в игре.

**Типы уведомлений:**
- ✅ In-game (popup, toast)
- ✅ WebSocket push (real-time)
- ✅ Email (важные события)
- ✅ Quest updates, achievements, friend requests, guild invites, trade offers, mail
- ✅ Preferences (что показывать)
- ✅ History (архив уведомлений)

---

## Микросервисная архитектура

**Ответственный микросервис:** social-service  
**Порт:** 8084  
**API Gateway маршрут:** `/api/v1/social/notifications/*`  
**Статус:** 📋 В планах (Фаза 3)

**Взаимодействие с другими сервисами:**
- Подписывается на события от ВСЕХ сервисов (event-driven)
- Отправляет уведомления через WebSocket (world-service)

**Event Bus события (подписывается на ВСЕ):**
- `friend:request-sent` → уведомление получателю
- `guild:invited` → уведомление о приглашении
- `trade:offer-received` → уведомление о предложении
- `mail:received` → уведомление о письме
- `achievement:unlocked` → уведомление о достижении
- `quest:completed` → уведомление о награде
- `combat:player-died` → уведомление о смерти

**Паттерн:** Notification service - это event consumer для всех других сервисов

---

## Database Schema

```sql
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    account_id UUID NOT NULL,
    
    -- Type
    notification_type VARCHAR(50) NOT NULL,
    -- QUEST_UPDATE, ACHIEVEMENT, FRIEND_REQUEST, GUILD_INVITE, TRADE_OFFER, etc
    
    -- Priority
    priority VARCHAR(20) DEFAULT 'NORMAL',
    -- LOW, NORMAL, HIGH, URGENT
    
    -- Content
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500), -- Optional link
    
    -- Data (для client-side processing)
    data JSONB,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    
    -- Delivery channels
    sent_in_game BOOLEAN DEFAULT TRUE,
    sent_email BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    expires_at TIMESTAMP, -- Auto-delete after 30 days
    
    CONSTRAINT fk_notification_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE INDEX idx_notifications_account ON notifications(account_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_expires ON notifications(expires_at) WHERE is_read = FALSE;
```

---

## Send Notification

```java
@Service
public class NotificationService {
    
    public void send(UUID accountId, Notification notification) {
        // 1. Проверить preferences
        NotificationPreferences prefs = getPreferences(accountId);
        
        if (!prefs.isEnabled(notification.getType())) {
            return; // User disabled this type
        }
        
        // 2. Сохранить в БД
        notificationRepository.save(notification);
        
        // 3. Отправить через WebSocket (если онлайн)
        if (sessionService.isOnline(accountId)) {
            webSocketService.sendToAccount(accountId, 
                new NotificationMessage(notification));
        }
        
        // 4. Email (если высокий приоритет)
        if (notification.getPriority() == Priority.HIGH || 
            notification.getPriority() == Priority.URGENT) {
            if (prefs.isEmailEnabled()) {
                emailService.sendNotificationEmail(accountId, notification);
            }
        }
    }
}
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/session-management-system.md`

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Notification System

