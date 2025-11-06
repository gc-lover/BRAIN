---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Система друзей. Friend list, requests, online status, ignore list, recent players.
---

# Friend System - Система друзей

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
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

