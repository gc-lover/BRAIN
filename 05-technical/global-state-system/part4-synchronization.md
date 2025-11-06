# Global State System - Part 4: Synchronization

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:14  
**Часть:** 4 из 7

[← Part 3](./part3-state-management.md) | [Навигация](./README.md) | [Part 5 →](./part5-realtime-query.md)

---

## MMORPG Synchronization

**Challenges:**
- 1M+ concurrent players
- Low latency (<100ms)
- Consistency
- Conflict resolution

**Solution:**
- Regional sharding
- Event-driven updates
- Optimistic concurrency
- CRDT for conflicts

---

## Persistence Strategy

**Event Store (PostgreSQL):**
```sql
CREATE TABLE events (
  event_id UUID PRIMARY KEY,
  event_type VARCHAR(50),
  aggregate_id VARCHAR(100),
  timestamp TIMESTAMP,
  data JSONB,
  version INTEGER
);
```

**State Store (PostgreSQL + Redis):**
- Hot data in Redis (TTL: 5min)
- Full data in PostgreSQL
- Snapshots every 100 events

---

## Event Replay

**Use cases:**
- Rebuild state after crash
- Test new projections
- Data migration

**Process:**
```
1. Load snapshot (if exists)
2. Load events after snapshot
3. Apply events sequentially
4. Rebuild state
```

---

## State Versioning

**Schema evolution:**
- Version in event metadata
- Backward compatible reads
- Upcasters for old versions

---

[Part 5: Real-Time & Query →](./part5-realtime-query.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:14) - Создан из global-state-system.md

