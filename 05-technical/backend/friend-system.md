---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Система друзей. Friend list, requests, online status, ignore list, recent players.
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-228: api/v1/social/friends/friend-system.yaml (2025-11-08 04:40)
- Last Updated: 2025-11-08 04:40
---



# Friend System - Система друзей

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** высокий  
**Автор:** AI Brain Manager

---

## Краткое описание

**Friend System** - социальная система для управления списком друзей.

**Ключевые возможности:**
- ✅ Friend list (add/remove)
- ✅ Friend requests (send/accept/decline)
- ✅ Online status
- ✅ Ignore/block list
- ✅ Recent players

---

## Микросервисная архитектура

**Ответственный микросервис:** social-service  
**Порт:** 8084  
**API Gateway маршрут:** `/api/v1/social/friends/*`  
**Статус:** 📋 В планах (Фаза 3)

**Взаимодействие с другими сервисами:**
- character-service: получение данных друзей (имя, уровень, класс)
- auth-service: online status через session-service
- notification-service (social): уведомления о friend requests

**Event Bus события:**
- Публикует: `friend:request-sent`, `friend:request-accepted`, `friend:online`, `friend:offline`
- Подписывается: `session:created` (friend online), `session:ended` (friend offline)

---

## Database Schema

```sql
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_a_id UUID NOT NULL,
    character_b_id UUID NOT NULL,
    
    status VARCHAR(20) DEFAULT 'PENDING',
    -- PENDING, ACCEPTED, BLOCKED
    
    initiated_by UUID NOT NULL, -- Who sent request
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    
    CONSTRAINT fk_friend_a FOREIGN KEY (character_a_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_friend_b FOREIGN KEY (character_b_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    CHECK (character_a_id < character_b_id) -- Prevent duplicates
);

CREATE INDEX idx_friendships_a ON friendships(character_a_id, status);
CREATE INDEX idx_friendships_b ON friendships(character_b_id, status);
```

---

## Связанные документы

- `.BRAIN/02-gameplay/social/relationships-system.md`

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Friend System

