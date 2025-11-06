---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Система групп. Party creation, invites, roles, loot settings, shared quests, party chat integration.
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-133: api/v1/party/party-system.yaml (2025-11-07 10:26)
- Last Updated: 2025-11-07 00:18
---



# Party System Backend - Система групп (backend архитектура)

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** высокий  
**Автор:** AI Brain Manager

---

## Краткое описание

**Party System** - система для создания и управления группами игроков (до 5 человек) для совместного прохождения контента.

**Ключевые возможности:**
- ✅ Party creation/dissolution
- ✅ Party invites/join/leave/kick
- ✅ Party leader (смена лидера)
- ✅ Party composition (роли: tank, healer, dps)
- ✅ Loot settings (need/greed, personal, master looter)
- ✅ Shared quest progress
- ✅ Party chat integration

---

## Database Schema

```sql
CREATE TABLE parties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leader_id UUID NOT NULL,
    
    -- Members
    members UUID[] DEFAULT '{}',
    max_members INTEGER DEFAULT 5,
    
    -- Loot settings
    loot_mode VARCHAR(20) DEFAULT 'NEED_GREED',
    -- NEED_GREED, PERSONAL, MASTER_LOOTER, FREE_FOR_ALL
    
    master_looter_id UUID, -- Если MASTER_LOOTER mode
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE',
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_party_leader FOREIGN KEY (leader_id) 
        REFERENCES characters(id) ON DELETE CASCADE
);

CREATE INDEX idx_parties_leader ON parties(leader_id);
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/matchmaking-system.md`
- `.BRAIN/05-technical/backend/loot-system.md`

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Party System Backend

