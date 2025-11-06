---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-161: docs/database-arch.md (2025-11-07 11:26)
- Last Updated: 2025-11-07 00:18
---


# Database Architecture - Архитектура баз данных

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** критический (Production)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07  
**api-readiness-notes:** Database architecture. PostgreSQL sharding (по player_id), replication (read replicas), partitioning (time-based для logs), backup/restore, connection pooling. Production critical!

---

## Краткое описание

Общая архитектура баз данных для NECPGAME с учетом микросервисной архитектуры.

**Микрофича:** Database architecture (PostgreSQL, sharding, replication, backup)

---

## Микросервисная архитектура БД

### Текущая реализация (Фаза 1-3): Shared Database

**Статус:** ✅ В использовании

**Конфигурация:**
```
PostgreSQL (localhost:5433)
  ├─ auth_schema        → auth-service
  ├─ character_schema   → character-service
  ├─ gameplay_schema    → gameplay-service
  ├─ social_schema      → social-service
  ├─ economy_schema     → economy-service
  └─ world_schema       → world-service
```

**Преимущества:**
- Проще в начале разработки
- Один connection pool
- ACID transactions работают

**Недостатки:**
- Не полная изоляция
- Shared resource contention
- Сложно масштабировать отдельные сервисы

---

### Планируемая реализация (Фаза 4): Database per Service

**Статус:** 📋 Планируется

**Конфигурация:**
```
auth_db (PostgreSQL)
  ├─ Port: 5433
  └─ Service: auth-service

character_db (PostgreSQL)
  ├─ Port: 5434
  └─ Service: character-service

gameplay_db (PostgreSQL)
  ├─ Port: 5435
  └─ Service: gameplay-service

social_db (PostgreSQL)
  ├─ Port: 5436
  └─ Service: social-service

economy_db (PostgreSQL)
  ├─ Port: 5437
  └─ Service: economy-service

world_db (PostgreSQL)
  ├─ Port: 5438
  └─ Service: world-service

cache_db (Redis)
  ├─ Port: 6379
  └─ Services: все сервисы (shared cache)
```

**Преимущества:**
- Полная изоляция
- Независимое масштабирование
- Failure isolation
- Database technology diversity (можем использовать разные БД)

**Недостатки:**
- Нет distributed transactions
- Нужен Saga pattern
- Eventual consistency

---

## 🗄️ Основная БД

**Выбор:** PostgreSQL 15+

**Почему:**
- ✅ ACID transactions
- ✅ JSONB support (flexible schema)
- ✅ Materialized views
- ✅ Partitioning
- ✅ Replication
- ✅ Full-text search

---

## 📊 Database Sharding

**По player_id:**
```
Shard 1: player_id hash % 4 = 0
Shard 2: player_id hash % 4 = 1
Shard 3: player_id hash % 4 = 2
Shard 4: player_id hash % 4 = 3

Horizontal scaling!
```

**По region:**
```
Shard NC: Night City players
Shard TK: Tokyo players
Shard EU: Europe players

Regional isolation!
```

---

## 🔁 Replication

**Master-Replica:**
```
Master: Writes
Replicas (3): Reads

Read queries → Replicas (распределение нагрузки)
Write queries → Master (consistency)
```

---

## 💾 Backup Strategy

**Automated backups:**
```
Full backup: Daily at 03:00 UTC
Incremental: Every 6 hours
WAL archiving: Continuous

Retention:
- Daily backups: 7 days
- Weekly backups: 4 weeks
- Monthly backups: 12 months
```

---

## 📁 Partitioning

**Time-based:**
```sql
-- Monthly partitions for large tables
CREATE TABLE player_quest_choices (
    ...
) PARTITION BY RANGE (created_at);

CREATE TABLE player_quest_choices_2025_11 
    PARTITION OF player_quest_choices
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
```

---

## 🔗 Связанные документы

- `caching-strategy.md`

---

## История изменений

- v1.0.0 (2025-11-06 23:00) - Создание database архитектуры

