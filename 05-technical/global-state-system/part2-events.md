# Global State System - Part 2: Events

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:12  
**Часть:** 2 из 7

[← Part 1](./part1-overview-architecture.md) | [Навигация](./README.md) | [Part 3 →](./part3-state-management.md)

---

## Event Types

### Quest Events
- QUEST_STARTED, QUEST_COMPLETED, QUEST_FAILED
- QUEST_OBJECTIVE_COMPLETED
- QUEST_CHOICE_MADE

### Combat Events
- COMBAT_STARTED, COMBAT_ENDED
- DAMAGE_DEALT, DAMAGE_TAKEN
- PLAYER_DIED, ENEMY_KILLED

### Economy Events
- ITEM_CRAFTED, ITEM_PURCHASED, ITEM_SOLD
- CURRENCY_EARNED, CURRENCY_SPENT
- TRADE_COMPLETED

### Social Events
- PLAYER_JOINED_CLAN, PLAYER_LEFT_CLAN
- FRIENDSHIP_ESTABLISHED, FRIENDSHIP_BROKEN
- MESSAGE_SENT

### World Events
- LOCATION_DISCOVERED, LOCATION_CONQUERED
- FACTION_REPUTATION_CHANGED
- WORLD_STATE_CHANGED

---

## Event Structure

```json
{
  "eventId": "uuid",
  "eventType": "QUEST_COMPLETED",
  "aggregateId": "quest_id",
  "aggregateType": "quest",
  "timestamp": "ISO8601",
  "playerId": "uuid",
  "serverId": "server-1",
  "version": 1,
  "data": {
    "questId": "main-001",
    "outcome": "success",
    "choices": []
  },
  "metadata": {
    "ip": "192.168.1.1",
    "userAgent": "Mozilla/5.0"
  }
}
```

---

## Event Processing Pipeline

```
Event Generated
    ↓
Validation
    ↓
Event Bus (publish)
    ↓
┌───────────┬───────────┬───────────┐
│ Event     │ Global    │ Analytics │
│ Store     │ State     │           │
│ Writer    │ Manager   │           │
└───────────┴───────────┴───────────┘
    ↓           ↓           ↓
Persisted   Updated     Analyzed
```

**Steps:**
1. Validate event structure
2. Publish to Event Bus
3. Store in Event Store
4. Update Global State
5. Analytics processing
6. Broadcast to clients (WebSocket)

---

[Part 3: State Management →](./part3-state-management.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:12) - Создан из global-state-system.md

