# Global State System - Part 5: Real-Time & Query

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:15  
**Часть:** 5 из 7

[← Part 4](./part4-synchronization.md) | [Навигация](./README.md) | [Part 6 →](./part6-operations.md)

---

## Real-Time Synchronization

**WebSocket broadcast:**
```
Event occurs
  ↓
Event Bus
  ↓
Real-Time Sync Service
  ↓
WebSocket → Clients
```

**Topics:**
- `/topic/world/{serverId}`
- `/topic/player/{playerId}`
- `/topic/clan/{clanId}`

---

## Consistency Models

**Eventual consistency:**
- Events processed async
- Small delay acceptable
- Optimistic UI updates

**Strong consistency:**
- Transactions (trades, combat)
- Pessimistic locking
- Higher latency

---

## State Query Service

**API:**
```
GET /api/v1/state/player/{playerId}
GET /api/v1/state/world/{serverId}
GET /api/v1/state/quest/{questId}/progress
```

**Caching:**
- Redis for hot queries
- PostgreSQL for full data
- CDN for static content

---

## Projections

**Multiple views:**
- Player view (my data)
- World view (global state)
- Analytics view (aggregates)

**Materialized:**
- Pre-computed for performance
- Updated async via events
- Stored separately

---

[Part 6: Operations →](./part6-operations.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:15) - Создан из global-state-system.md

