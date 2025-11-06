# Global State System - Event Sourcing архитектура

**Статус:** completed  
**Приоритет:** критический  
**Дата создания:** 2025-11-06  
**Дата завершения:** 2025-11-06 21:32  
**Связанные документы:** 
- `05-technical/global-state-system.md` (НОВЫЙ ТЕХНИЧЕСКИЙ ДОКУМЕНТ!)
- `02-gameplay/world/world-state-player-impact.md` (связанный)
- `06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md` (связанный)

---

## Цель

Проработать техническую архитектуру системы **Global State**, которая контролирует и регистрирует ВСЕ события в игровом мире для хранения состояния мира, квестов, прогресса и всех игровых данных.

---

## Контекст

**Задача от пользователя:**
> "Проработай описание системы, которая будет контролировать и регистрировать все события в мире для хранения состояния мира, квестов, прогресса и т.д. То есть нужно проработать некий GLOBAL STATE."

**Проблема:**
- Нужна централизованная система для регистрации ВСЕХ событий
- Нужна система для хранения мирового состояния (world state)
- Нужна система для синхронизации между игроками (MMORPG)
- Нужна возможность восстановления состояния
- Нужна полная история для аудита и отладки

---

## Решение: Event Sourcing Architecture

### Ключевые концепции

**1. Event Sourcing Pattern:**
- Все изменения в системе записываются как события (Events)
- События append-only, immutable (никогда не удаляются/изменяются)
- Текущее состояние = начальное состояние + все события
- Возможность replay и time travel

**2. Event Store:**
- Централизованное хранилище всех событий
- Таблица `game_events` (BIGSERIAL id, event_type, event_data JSONB)
- Партиционирование по времени (monthly/weekly)
- Индексы для быстрого поиска

**3. Global State Store:**
- Хранилище текущего состояния мира
- Таблица `global_state` (hierarchical keys)
- Иерархия: category.entity.attribute.subAttribute
- Версионирование для Optimistic Locking

**4. Event Bus:**
- Асинхронная обработка событий
- Kafka/RabbitMQ для масштабируемости
- Pub/Sub pattern для подписчиков
- Real-time notifications через WebSocket

---

## Что включено в документ

### 1. Архитектура системы (900+ строк)

**High-Level Overview:**
- CLIENT → API Gateway → Backend Services → Event Bus
- Event Bus → Event Store + Global State Manager + Analytics
- Persistence Layer: Event Store (PostgreSQL) + State Store (PostgreSQL) + Cache (Redis)

### 2. Event Sourcing Pattern

**Описание:**
- Концепция Event Sourcing
- Сравнение с традиционным CRUD
- Преимущества (полная история, аудит, replay)

**Event Store таблица:**
```sql
game_events (
    id BIGSERIAL PRIMARY KEY,
    event_id UUID,
    event_type VARCHAR(100),
    aggregate_type VARCHAR(50),
    aggregate_id VARCHAR(200),
    event_data JSONB,
    state_changes JSONB,
    player_id UUID,
    server_id VARCHAR(100),
    event_timestamp TIMESTAMP,
    ...
)
```

### 3. Типы событий (10 категорий)

**PLAYER, QUEST, COMBAT, ECONOMY, SOCIAL, WORLD, NPC, TECHNOLOGY, POLITICAL, LEAGUE**

Каждая категория содержит 10-20 типов событий:
- PLAYER: 16 типов (PLAYER_CREATED, PLAYER_LEVELED_UP, PLAYER_SKILL_INCREASED, ...)
- QUEST: 12 типов (QUEST_STARTED, QUEST_CHOICE_MADE, QUEST_COMPLETED, ...)
- COMBAT: 10 типов (COMBAT_DAMAGE_DEALT, COMBAT_ABILITY_USED, ...)
- И так далее

**ИТОГО: 100+ типов событий**

### 4. Global State Management

**Global State таблица:**
```sql
global_state (
    state_key VARCHAR(300),
    state_value TEXT,
    state_type VARCHAR(20),
    version INTEGER,
    previous_value TEXT,
    changed_by_event_id UUID,
    ...
)
```

**Иерархия ключей:**
```
player.{playerId}.level = 50
world.territory.watson.controller = "Arasaka"
economy.item.weapons.price = 6500
quest.{questId}.status = "ACTIVE"
```

### 5. Event Processing Pipeline

**10 этапов обработки:**
1. EVENT RECEIVED
2. VALIDATION
3. AUTHORIZATION
4. ENRICHMENT
5. PERSISTENCE (Event Store)
6. PUBLICATION (Event Bus)
7. SUBSCRIBERS PROCESSING
8. STATE UPDATE
9. NOTIFICATION
10. ANALYTICS

**Java handlers с примерами кода**

### 6. State Reconstruction

**Алгоритм восстановления состояния:**
```java
reconstructState(stateKey, pointInTime) {
    1. Получить snapshot (если есть)
    2. Получить события после snapshot
    3. Применить события по порядку
    4. Вернуть восстановленное состояние
}
```

**Snapshots:**
- Таблица `state_snapshots`
- Создание каждые 1000 событий или каждый час
- Ускорение восстановления (вместо replay миллионов событий)

### 7. Синхронизация MMORPG

**3 модели состояния:**
- **Server-Wide State:** Все игроки видят одинаково (территории, NPC fates, экономика)
- **Player-Specific State:** Каждый игрок видит свое (quest progress, inventory, flags)
- **Phased State:** Разные игроки видят разное (квестовые фазы)

**Conflict Resolution:**
- Last Write Wins
- Voting System
- Event Versioning
- Merge Strategy

**WebSocket Channels:**
- `/ws/player/{playerId}` - личные события
- `/ws/world/{serverId}` - мировые события
- `/ws/economy/{serverId}` - экономика
- `/ws/combat/{sessionId}` - бой

### 8. Consistency Models

**Strong Consistency:**
- Для критичных операций (покупка, продажа, бой)
- Transactional isolation SERIALIZABLE
- Блокировки FOR UPDATE

**Eventual Consistency:**
- Для некритичных (reputation, statistics)
- Async processing
- Задержка 1-60 секунд

**Causal Consistency:**
- Для связанных событий (quest chain, combo)
- Causation ID для зависимостей
- Гарантия порядка обработки

### 9. Persistence Strategy

**Write-Ahead Log (WAL):**
- События записываются первыми
- Затем state обновляется
- Восстановление из WAL при сбое

**Transactional Outbox Pattern:**
- Таблица `event_outbox`
- Атомарность записи события + обновления state
- Отдельный процесс публикации

**Idempotency:**
- Таблица `processed_events`
- Проверка дубликатов
- Защита от повторной обработки

### 10. Event Replay

**Use Cases:**
- Восстановление после сбоя
- Миграция данных
- Тестирование
- Аналитика

**Replay Engine с Java кодом**

### 11. Projections (Read Models)

**Концепция:**
- Event Store (write model) → оптимизирован для записи
- Projections (read models) → оптимизированы для чтения
- Асинхронное обновление из событий

**Примеры:**
- `player_profile_projection` - профиль игрока
- `quest_statistics_projection` - статистика квестов
- `economy_dashboard_projection` - экономика

### 12. Performance Optimization

**Write Optimization:**
- Batch writes (пакетная запись)
- Async writes (асинхронная запись)
- Партиционирование таблиц

**Read Optimization:**
- Multi-level caching (Local → Redis → DB)
- Materialized Views
- Composite indexes
- Partial indexes

**Scalability:**
- Horizontal scaling (partitioning, sharding)
- Vertical scaling (DB tuning, connection pooling)

### 13. Monitoring и Observability

**Метрики:**
- Event Store metrics (write rate, processing time, errors, backlog)
- State Store metrics (updates rate, cache hit rate, query time)
- Synchronization metrics (WebSocket connections, message rate, latency)

**Health Checks:**
- Event Store health
- State Store health
- Event Bus health
- Sync lag monitoring

### 14. Disaster Recovery

**Сценарии сбоев:**
- State Store corrupted → Replay из Event Store
- Event Store unavailable → Buffering
- Event Bus failure → Delayed processing
- Full system failure → Restore from replicas + backups

**Время восстановления:**
- 1M событий: 5-10 минут
- 10M событий: 30-60 минут (с snapshots: 5-10 мин)
- 100M событий: 5-10 часов (с snapshots: 30-60 мин)

### 15. Security и Validation

**Event Validation:**
- Структура события
- Авторизация игрока
- Бизнес-правила
- Rate limiting
- Anti-cheat detection

**Rate Limiting:**
- По типу события (quest: 10/min, items: 100/min, chat: 60/min)
- Redis для tracking
- Graceful rejection

**Anti-Cheat:**
- Проверка невозможных значений
- Временные аномалии
- Паттерны автоматизации

### 16. API Endpoints

**Event Management:**
- POST `/api/v1/events` - записать событие
- GET `/api/v1/events/{aggregateId}` - получить события
- GET `/api/v1/events/history` - история с фильтрами

**State Management:**
- GET `/api/v1/state` - полное состояние сервера
- GET `/api/v1/state/{category}` - по категории
- GET `/api/v1/state/key/{stateKey}` - конкретный ключ
- GET `/api/v1/state/history/{stateKey}` - история изменений
- POST `/api/v1/state/replay` - replay событий (admin)

---

## Результат

✅ **Создан полный технический документ на 900+ строк:**
- **api-readiness:** ready
- **Версия:** 1.0.0
- **Статус:** approved

✅ **Документ содержит:**
- Полную архитектуру Event Sourcing
- Все таблицы БД (game_events, global_state, state_snapshots, processed_events, event_outbox)
- 100+ типов событий (10 категорий)
- Event Processing Pipeline с Java примерами
- State Reconstruction алгоритмы
- Синхронизацию MMORPG (WebSocket, real-time)
- Consistency Models (Strong, Eventual, Causal)
- Performance Optimization (caching, partitioning, indexing)
- Security (validation, rate limiting, anti-cheat)
- Monitoring и Health Checks
- Disaster Recovery procedures
- API Endpoints спецификацию

✅ **Добавлен в readiness-tracker.yaml** со статусом `ready`

✅ **Готов к созданию API задач и реализации!**

---

## Ключевые достижения

**1. Event Sourcing Architecture:**
- Полная история всех действий в игре
- Возможность replay и time travel
- Аудит и отладка
- Восстановление после сбоев

**2. Global State Management:**
- Иерархическая система ключей
- Версионирование для concurrency
- Multi-level caching
- Real-time updates

**3. MMORPG Synchronization:**
- WebSocket для real-time
- Разрешение конфликтов
- Phasing для квестов
- Server-wide состояние

**4. Scalability:**
- Партиционирование Event Store
- Sharding State Store
- Kafka партиции для Event Bus
- Horizontal и Vertical scaling

**5. Reliability:**
- Snapshots для быстрого восстановления
- Replication для durability
- Disaster Recovery процедуры
- Graceful degradation

---

## Интеграция с другими системами

**Связь с quest-branching-database-design.md:**
- Global State System хранит события
- Quest Branching DB хранит структуру квестов
- События обновляют quest progress через Global State
- World State влияет на доступность квестов

**Связь с world-state-player-impact.md:**
- World State Player Impact описывает ВЛИЯНИЕ игроков
- Global State System описывает ТЕХНОЛОГИЮ хранения и обработки
- Оба документа дополняют друг друга

**Связь с api-integration-map.md:**
- Global State System предоставляет event bus
- API Integration Map описывает интеграции между сервисами
- События связывают все сервисы

---

## История изменений

- **2025-11-06 21:32** - Документ создан и завершен
- **2025-11-06 21:32** - Добавлен в readiness-tracker.yaml
- **2025-11-06 21:32** - Закоммичен в репозиторий

---

## Связанные вопросы

**Решенные вопросы:**
- ✅ Как регистрировать все события в игре?
- ✅ Как хранить состояние мира?
- ✅ Как синхронизировать игроков (MMORPG)?
- ✅ Как восстановить состояние после сбоя?
- ✅ Как обеспечить производительность?
- ✅ Как масштабировать систему?
- ✅ Какие API endpoints нужны?
- ✅ Как обрабатывать события?
- ✅ Как разрешать конфликты?
- ✅ Как мониторить систему?

**Для дальнейшей проработки (низкий приоритет):**
- Точная настройка партиционирования
- Частота создания snapshots
- Retention policy для старых событий
- Load testing и performance tuning

---

## Технические детали

**Размер документа:** 900+ строк

**Разделы:**
1. Архитектура системы (диаграмма)
2. Event Sourcing Pattern (концепция + Event Store)
3. Типы событий (10 категорий, 100+ типов)
4. Event Structure (JSON примеры)
5. Global State Management (таблица + API)
6. Event Processing Pipeline (10 этапов + Java код)
7. State Reconstruction (алгоритмы + snapshots)
8. Event Bus (Kafka/RabbitMQ, topics, publishers, subscribers)
9. Global State Manager (Java service с методами)
10. Синхронизация MMORPG (модели, conflict resolution)
11. Consistency Models (Strong, Eventual, Causal)
12. Persistence Strategy (WAL, Outbox, Idempotency)
13. Event Replay (восстановление, миграция, тестирование)
14. Projections (Read Models)
15. Performance Optimization (caching, partitioning, indexing)
16. Security (validation, rate limiting, anti-cheat)
17. Monitoring (метрики, health checks)
18. Disaster Recovery (сценарии + восстановление)
19. API Endpoints (полная спецификация)
20. Testing и Debugging (примеры)

**Таблицы БД:**
- `game_events` - Event Store
- `global_state` - текущее состояние
- `state_snapshots` - снимки состояния
- `processed_events` - идемпотентность
- `event_outbox` - transactional outbox

**Примеры кода:**
- Java Event Handlers
- State Reconstruction algorithm
- Global State Manager service
- Event Replay Engine
- Projectors
- Health Checks
- Anti-Cheat Detector

---

## Итоговая статистика

**До создания:** 103 документа ready  
**После создания:** 104 документа ready  
**Новый документ:** global-state-system.md (КРИТИЧЕСКИ ВАЖНЫЙ!)

**Покрытие архитектуры:**
- ✅ Event Sourcing ✅
- ✅ Event Store ✅
- ✅ Global State ✅
- ✅ Event Bus ✅
- ✅ Synchronization ✅
- ✅ Consistency ✅
- ✅ Performance ✅
- ✅ Security ✅
- ✅ Monitoring ✅
- ✅ Disaster Recovery ✅

**Задача выполнена полностью!** 🎉

---

## Следующие шаги

**Для реализации (после создания API задач):**
1. Создать API спецификацию из этого документа
2. Реализовать Event Store (PostgreSQL схема)
3. Реализовать Global State Manager (Java service)
4. Настроить Event Bus (Kafka/RabbitMQ)
5. Реализовать Event Handlers
6. Настроить WebSocket для real-time
7. Implement Projections
8. Performance tuning
9. Security implementation
10. Monitoring setup

**Документ готов передавать в API-SWAGGER для создания задач!**

