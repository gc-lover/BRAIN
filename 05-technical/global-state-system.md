---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:32  
**api-readiness-notes:** Техническая архитектура системы Global State для регистрации всех событий и управления состоянием мира. Event Sourcing, Event Store, State Management, синхронизация MMORPG.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-074: api/v1/technical/global-state.yaml (2025-11-07)
- Last Updated: 2025-11-07 02:05
---

# Global State System - Архитектура управления состоянием мира

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:32  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---

## Краткое описание

**Global State System** - централизованная система контроля и регистрации всех событий в игровом мире NECPGAME. Использует паттерн **Event Sourcing** для хранения истории всех действий и **Event-Driven Architecture** для обработки событий в реальном времени.

**Ключевые возможности:**
- ✅ Регистрация ВСЕХ событий в игре (квесты, бой, экономика, социальные действия)
- ✅ Хранение полной истории мира (Event Store)
- ✅ Восстановление состояния из событий (State Reconstruction)
- ✅ Синхронизация между игроками (MMORPG)
- ✅ Аудит и отладка (полная история)
- ✅ Time Travel (откат состояния для тестирования)

---

## Архитектура системы

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT (Frontend)                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Quest   │  │  Combat  │  │ Economy  │  │  Social  │       │
│  │   UI     │  │    UI    │  │    UI    │  │    UI    │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
└───────┼─────────────┼─────────────┼─────────────┼──────────────┘
        │             │             │             │
        │        WebSocket (Real-time Updates)    │
        │             │             │             │
┌───────▼─────────────▼─────────────▼─────────────▼──────────────┐
│                    API GATEWAY (REST + WS)                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Request Routing & Load Balancing              │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────┬─────────────┬─────────────┬─────────────┬──────────────┘
        │             │             │             │
┌───────▼─────────────▼─────────────▼─────────────▼──────────────┐
│                    BACKEND SERVICES (Java)                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Quest   │  │  Combat  │  │ Economy  │  │  Social  │       │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │             │             │             │               │
│       └─────────────┴─────────────┴─────────────┘               │
│                          │                                       │
│                ┌─────────▼──────────┐                           │
│                │   EVENT BUS        │                           │
│                │  (Kafka/RabbitMQ)  │                           │
│                └─────────┬──────────┘                           │
│                          │                                       │
│         ┌────────────────┼────────────────┐                     │
│         │                │                │                     │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐            │
│  │   Event     │  │   Global    │  │  Analytics  │            │
│  │   Store     │  │   State     │  │   Service   │            │
│  │   Writer    │  │   Manager   │  │             │            │
│  └──────┬──────┘  └──────┬──────┘  └─────────────┘            │
└─────────┼─────────────────┼─────────────────────────────────────┘
          │                 │
┌─────────▼─────────────────▼─────────────────────────────────────┐
│                    PERSISTENCE LAYER                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Event Store   │  │   State Store   │  │   Cache Store   │ │
│  │  (PostgreSQL)   │  │  (PostgreSQL)   │  │     (Redis)     │ │
│  │  events table   │  │  world_state    │  │  Hot data cache │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## Event Sourcing Pattern

### Концепция

**Традиционный подход (CRUD):**
```
Хранится только ТЕКУЩЕЕ состояние
Player Level: 50
Quest Status: COMPLETED
Territory Controller: Arasaka

❌ Проблема: Потеря истории изменений
```

**Event Sourcing:**
```
Хранятся ВСЕ СОБЫТИЯ, которые привели к текущему состоянию
Event 1: PlayerLeveledUp (1→2)
Event 2: PlayerLeveledUp (2→3)
...
Event 50: PlayerLeveledUp (49→50)

Event 100: QuestStarted
Event 101: QuestObjectiveCompleted
Event 102: QuestCompleted

Event 200: TerritoryAttacked (Militech → Arasaka)
Event 201: TerritoryDefended
Event 202: TerritoryCaptured (Arasaka wins)

✅ Преимущество: Полная история + возможность replay + аудит
```

### Event Store (Хранилище событий)

**Таблица `game_events` (главная таблица):**

```sql
CREATE TABLE game_events (
    -- Идентификация
    id BIGSERIAL PRIMARY KEY,
    event_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    event_type VARCHAR(100) NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL, -- "PLAYER", "QUEST", "WORLD", "ECONOMY", "COMBAT"
    aggregate_id VARCHAR(200) NOT NULL, -- ID сущности (playerId, questId, territoryId)
    
    -- Метаданные события
    event_version INTEGER NOT NULL DEFAULT 1,
    correlation_id UUID, -- Для связи событий в рамках одной операции
    causation_id UUID, -- Какое событие вызвало это событие
    
    -- Данные события
    event_data JSONB NOT NULL, -- Полезная нагрузка события
    metadata JSONB, -- Дополнительные метаданные
    
    -- Контекст
    server_id VARCHAR(100) NOT NULL,
    player_id UUID, -- Кто вызвал событие (NULL для системных событий)
    session_id UUID, -- Игровая сессия
    
    -- Временные метки
    event_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP, -- Когда событие было обработано
    
    -- Влияние на состояние
    state_changes JSONB, -- Какие изменения состояния вызвало событие
    affected_players JSONB, -- Список затронутых игроков
    
    -- Служебное
    is_processed BOOLEAN DEFAULT FALSE,
    processing_error TEXT, -- Если была ошибка при обработке
    retry_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Критические индексы
CREATE INDEX idx_events_aggregate ON game_events(aggregate_type, aggregate_id);
CREATE INDEX idx_events_type ON game_events(event_type);
CREATE INDEX idx_events_timestamp ON game_events(event_timestamp DESC);
CREATE INDEX idx_events_player ON game_events(player_id);
CREATE INDEX idx_events_server ON game_events(server_id);
CREATE INDEX idx_events_correlation ON game_events(correlation_id);
CREATE INDEX idx_events_unprocessed ON game_events(is_processed) WHERE is_processed = FALSE;

-- Партиционирование по времени (для масштабирования)
-- Партиции по месяцам или неделям для больших объемов
```

---

## Типы событий (Event Types)

### Категории событий

**1. PLAYER EVENTS (события игрока):**
```typescript
// Прогресс
PLAYER_CREATED
PLAYER_LEVELED_UP
PLAYER_ATTRIBUTE_INCREASED
PLAYER_SKILL_INCREASED
PLAYER_PERK_ACQUIRED
PLAYER_REBIRTH

// Экипировка
PLAYER_ITEM_EQUIPPED
PLAYER_ITEM_UNEQUIPPED
PLAYER_IMPLANT_INSTALLED
PLAYER_IMPLANT_REMOVED

// Перемещение
PLAYER_LOCATION_CHANGED
PLAYER_ZONE_ENTERED
PLAYER_ZONE_EXITED

// Статус
PLAYER_DIED
PLAYER_RESPAWNED
PLAYER_STATUS_EFFECT_APPLIED
PLAYER_CYBERPSYCHOSIS_STAGE_CHANGED
```

**2. QUEST EVENTS (события квестов):**
```typescript
QUEST_STARTED
QUEST_OBJECTIVE_UPDATED
QUEST_OBJECTIVE_COMPLETED
QUEST_DIALOGUE_NODE_ENTERED
QUEST_CHOICE_MADE
QUEST_SKILL_CHECK_PERFORMED
QUEST_BRANCH_ENTERED
QUEST_COMPLETED
QUEST_FAILED
QUEST_ABANDONED

// World Impact
QUEST_WORLD_STATE_CHANGED
QUEST_NPC_FATE_CHANGED
QUEST_TERRITORY_CHANGED
QUEST_FACTION_REPUTATION_CHANGED
```

**3. COMBAT EVENTS (боевые события):**
```typescript
COMBAT_SESSION_STARTED
COMBAT_DAMAGE_DEALT
COMBAT_DAMAGE_RECEIVED
COMBAT_ABILITY_USED
COMBAT_COMBO_EXECUTED
COMBAT_ENEMY_KILLED
COMBAT_PLAYER_KILLED
COMBAT_SESSION_ENDED

// Экстракт
EXTRACT_ZONE_ENTERED
EXTRACT_LOOT_ACQUIRED
EXTRACT_EXTRACTED
EXTRACT_DIED_IN_ZONE
```

**4. ECONOMY EVENTS (экономические события):**
```typescript
ITEM_CRAFTED
ITEM_PURCHASED
ITEM_SOLD
ITEM_TRADED
CURRENCY_EXCHANGED
RESOURCE_GATHERED
MARKET_LISTING_CREATED
MARKET_LISTING_SOLD
AUCTION_BID_PLACED
AUCTION_WON

// Производство
PRODUCTION_CHAIN_STARTED
PRODUCTION_CHAIN_COMPLETED
RECIPE_DISCOVERED
```

**5. SOCIAL EVENTS (социальные события):**
```typescript
REPUTATION_CHANGED
RELATIONSHIP_CHANGED
NPC_HIRED
NPC_DISMISSED
NPC_RELATIONSHIP_STAGE_CHANGED
PLAYER_ORDER_CREATED
PLAYER_ORDER_ACCEPTED
PLAYER_ORDER_COMPLETED
MENTORSHIP_STARTED
MENTORSHIP_COMPLETED

// Романтика
ROMANCE_STAGE_ADVANCED
ROMANCE_QUEST_COMPLETED
ROMANCE_PARTNER_ABILITY_UNLOCKED
```

**6. WORLD EVENTS (мировые события):**
```typescript
WORLD_EVENT_TRIGGERED
WORLD_EVENT_STARTED
WORLD_EVENT_PLAYER_PARTICIPATED
WORLD_EVENT_COMPLETED
WORLD_EVENT_FAILED

// Территории
TERRITORY_ATTACKED
TERRITORY_DEFENDED
TERRITORY_CAPTURED
TERRITORY_CONTROL_CHANGED

// Фракции
FACTION_WAR_STARTED
FACTION_WAR_STAGE_COMPLETED
FACTION_WAR_ENDED
FACTION_POWER_CHANGED
FACTION_ALLIANCE_FORMED
FACTION_ALLIANCE_BROKEN
```

**7. NPC EVENTS (события NPC):**
```typescript
NPC_SPAWNED
NPC_DIED
NPC_FATE_CHANGED
NPC_LOCATION_CHANGED
NPC_STATE_CHANGED
NPC_DIALOGUE_TRIGGERED
NPC_VENDOR_INVENTORY_UPDATED
```

**8. TECHNOLOGY EVENTS (технологические события):**
```typescript
TECHNOLOGY_UNLOCKED
IMPLANT_TIER_UNLOCKED
BLACKWALL_STABILITY_CHANGED
CYBERSPACE_EXPANDED
RESEARCH_COMPLETED
```

**9. POLITICAL EVENTS (политические события):**
```typescript
ELECTION_STARTED
ELECTION_VOTE_CAST
ELECTION_COMPLETED
LAW_CHANGED
MAYOR_ELECTED
ALLIANCE_FORMED
WAR_DECLARED
```

**10. LEAGUE EVENTS (события лиг):**
```typescript
LEAGUE_STARTED
LEAGUE_STAGE_CHANGED
LEAGUE_ENDED
ERA_CHANGED
SEASON_RESET
```

---

## Структура события (Event Structure)

### Базовая структура

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "eventType": "QUEST_CHOICE_MADE",
  "aggregateType": "QUEST",
  "aggregateId": "NCPD-MORGANA-001",
  "eventVersion": 1,
  "correlationId": "correlation-uuid",
  "causationId": "previous-event-uuid",
  
  "eventData": {
    "questId": "NCPD-MORGANA-001",
    "playerId": "player-uuid",
    "nodeId": 2,
    "choiceId": "A2",
    "choiceText": "Доложить IA",
    "branchId": "pathTruth"
  },
  
  "metadata": {
    "clientVersion": "1.0.0",
    "serverVersion": "1.0.0",
    "ipAddress": "xxx.xxx.xxx.xxx",
    "userAgent": "NECPGAME/1.0"
  },
  
  "serverId": "server-01",
  "playerId": "player-uuid",
  "sessionId": "session-uuid",
  "eventTimestamp": "2025-11-06T21:00:00Z",
  
  "stateChanges": {
    "playerFlags": ["morgana_truth_start"],
    "reputation": {"NCPD": +10},
    "questProgress": {"currentBranch": "pathTruth", "currentNode": 4}
  },
  
  "affectedPlayers": ["player-uuid"]
}
```

### Примеры событий

**Пример 1: Игрок повысил уровень**
```json
{
  "eventType": "PLAYER_LEVELED_UP",
  "aggregateType": "PLAYER",
  "aggregateId": "player-uuid",
  "eventData": {
    "previousLevel": 49,
    "newLevel": 50,
    "experienceGained": 50000,
    "rewardsGranted": {
      "attributePoints": 2,
      "skillPoints": 5,
      "perkPoints": 1
    }
  },
  "stateChanges": {
    "player.level": 50,
    "player.attributePoints": 2,
    "player.skillPoints": 5
  }
}
```

**Пример 2: Территория захвачена**
```json
{
  "eventType": "TERRITORY_CAPTURED",
  "aggregateType": "WORLD",
  "aggregateId": "territory.nightCity.watson",
  "eventData": {
    "territory": "Watson District",
    "previousController": "Militech",
    "newController": "Arasaka",
    "attackingPlayers": 2000,
    "defendingPlayers": 1800,
    "factionWarId": "war-arasaka-militech-001"
  },
  "stateChanges": {
    "territory.nightCity.watson.controller": "Arasaka",
    "territory.nightCity.watson.controlStrength": 85,
    "factionPower.arasaka": 75,
    "factionPower.militech": 40
  },
  "affectedPlayers": [/* 3800 игроков */]
}
```

**Пример 3: Цена на рынке изменилась**
```json
{
  "eventType": "MARKET_PRICE_CHANGED",
  "aggregateType": "ECONOMY",
  "aggregateId": "item.weapons.mantisBlades",
  "eventData": {
    "itemId": "mantisBlades",
    "previousPrice": 5000,
    "newPrice": 6500,
    "priceChangeReason": "HIGH_DEMAND",
    "demandLevel": 1500,
    "supplyLevel": 300,
    "priceMultiplier": 1.3
  },
  "stateChanges": {
    "economy.weapons.mantisBlades.price": 6500,
    "economy.weapons.mantisBlades.availability": "low"
  }
}
```

---

## Global State Management

### State Store (Хранилище состояния)

**Таблица `global_state` (текущее состояние):**

```sql
CREATE TABLE global_state (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL,
    
    -- Ключ состояния (иерархический)
    state_key VARCHAR(300) NOT NULL, -- "player.uuid.level", "world.territory.watson.controller"
    state_category VARCHAR(50) NOT NULL, -- "PLAYER", "WORLD", "ECONOMY", "QUEST", etc
    
    -- Значение
    state_value TEXT NOT NULL,
    state_type VARCHAR(20) NOT NULL, -- "INTEGER", "STRING", "BOOLEAN", "JSON", "DECIMAL"
    
    -- Метаданные
    description TEXT,
    owner_id VARCHAR(200), -- Владелец состояния (playerId, factionId, etc)
    region VARCHAR(100), -- Регион (для территориальных состояний)
    
    -- История
    version INTEGER NOT NULL DEFAULT 1, -- Версия состояния (увеличивается при каждом изменении)
    previous_value TEXT,
    changed_by_event_id UUID, -- Какое событие вызвало это изменение
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Экспирация
    expires_at TIMESTAMP, -- Для временных состояний (buffs, debuffs, events)
    is_permanent BOOLEAN DEFAULT TRUE,
    
    -- Служебное
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT fk_changed_by_event FOREIGN KEY (changed_by_event_id) REFERENCES game_events(event_id),
    UNIQUE(server_id, state_key)
);

-- Индексы
CREATE INDEX idx_global_state_server_category ON global_state(server_id, state_category);
CREATE INDEX idx_global_state_key ON global_state(state_key);
CREATE INDEX idx_global_state_owner ON global_state(owner_id);
CREATE INDEX idx_global_state_region ON global_state(region);
CREATE INDEX idx_global_state_expires ON global_state(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_global_state_changed ON global_state(changed_at DESC);

-- Партиционирование по state_category для масштабирования
```

### Иерархия ключей состояния

**Формат:** `category.entity.attribute[.subAttribute]`

**Примеры:**

**Player State:**
```
player.{playerId}.level = 50
player.{playerId}.experience = 1250000
player.{playerId}.class = "Solo"
player.{playerId}.attributes.STR = 18
player.{playerId}.skills.persuasion.rank = 3
player.{playerId}.reputation.arasaka = 45
player.{playerId}.location.current = "Watson.KabukiMarket"
player.{playerId}.quest.{questId}.status = "ACTIVE"
player.{playerId}.quest.{questId}.currentBranch = "pathTruth"
```

**World State:**
```
world.territory.nightCity.watson.controller = "Arasaka"
world.territory.nightCity.watson.controlStrength = 85
world.territory.nightCity.watson.contested = false
world.npc.morgana.fate = "hero"
world.npc.morgana.location = "NCPDHeadquarters"
world.faction.arasaka.power = 75
world.faction.militech.power = 40
```

**Economy State:**
```
economy.item.weapons.mantisBlades.price = 6500
economy.item.weapons.mantisBlades.supply = 300
economy.item.weapons.mantisBlades.demand = 1500
economy.currency.eurodollar.exchangeRate.yen = 0.85
economy.resource.chromePlate.availability = "low"
economy.tradeRoute.nightCity.tokyo.active = true
```

**Quest State:**
```
quest.{questId}.status = "ACTIVE"
quest.{questId}.availableTo = "ALL" | "FACTION:Arasaka" | "CLASS:Netrunner"
quest.{questId}.completedCount = 1250
quest.{questId}.popularPath = "pathTruth" (60%)
```

**Technology State:**
```
technology.implants.tier4.unlocked = true
technology.blackwall.stability = 65
technology.cyberspace.accessLevel = "restricted"
technology.netwatch.defenseLevel = "high"
```

---

## Event Processing Pipeline

### Этапы обработки события

```
1. EVENT RECEIVED (от клиента или системы)
   ↓
2. VALIDATION (проверка валидности)
   ↓
3. AUTHORIZATION (проверка прав)
   ↓
4. ENRICHMENT (обогащение данными)
   ↓
5. PERSISTENCE (сохранение в Event Store)
   ↓
6. PUBLICATION (публикация в Event Bus)
   ↓
7. SUBSCRIBERS PROCESSING (обработка подписчиками)
   ↓
8. STATE UPDATE (обновление Global State)
   ↓
9. NOTIFICATION (уведомление игроков)
   ↓
10. ANALYTICS (запись аналитики)
```

### Event Handler Example

```java
@Service
public class QuestEventHandler {
    
    @EventListener
    public void handleQuestChoiceMade(QuestChoiceMadeEvent event) {
        // 1. Обновить quest progress
        questProgressRepository.updateBranch(
            event.getPlayerId(),
            event.getQuestId(),
            event.getBranchId()
        );
        
        // 2. Применить последствия выбора
        Choice choice = choiceRepository.findById(event.getChoiceId());
        
        // Репутация
        if (choice.getReputationChanges() != null) {
            reputationService.applyChanges(
                event.getPlayerId(),
                choice.getReputationChanges()
            );
        }
        
        // Флаги
        if (choice.getSetsFlags() != null) {
            flagService.setFlags(
                event.getPlayerId(),
                choice.getSetsFlags(),
                event.getQuestId()
            );
        }
        
        // Предметы
        if (choice.getGivesItems() != null) {
            inventoryService.giveItems(
                event.getPlayerId(),
                choice.getGivesItems()
            );
        }
        
        // 3. Проверить мировое влияние
        if (choice.getWorldStateChanges() != null) {
            globalStateService.applyWorldChanges(
                choice.getWorldStateChanges(),
                event
            );
        }
        
        // 4. Создать follow-up события
        if (choice.getNextNodeId() != null) {
            eventBus.publish(new QuestNodeEnteredEvent(
                event.getPlayerId(),
                event.getQuestId(),
                choice.getNextNodeId()
            ));
        }
        
        // 5. Уведомить игрока
        notificationService.send(
            event.getPlayerId(),
            "Choice recorded: " + choice.getChoiceText()
        );
        
        // 6. Логировать для аналитики
        analyticsService.recordChoice(event);
    }
}
```

---

## State Reconstruction (Восстановление состояния)

### Восстановление из событий

**Концепция:**
Текущее состояние = начальное состояние + все события

```
Initial State: Player Level = 1
+ Event: PLAYER_LEVELED_UP (1→2)
+ Event: PLAYER_LEVELED_UP (2→3)
+ ...
+ Event: PLAYER_LEVELED_UP (49→50)
= Current State: Player Level = 50
```

**Алгоритм:**

```java
public GlobalState reconstructState(String stateKey, Instant pointInTime) {
    // 1. Получить все события для этого ключа до pointInTime
    List<GameEvent> events = eventStore.getEvents(
        stateKey,
        null, // from beginning
        pointInTime
    );
    
    // 2. Начать с начального состояния
    Object currentValue = getInitialState(stateKey);
    
    // 3. Применить все события по порядку
    for (GameEvent event : events) {
        currentValue = applyEvent(currentValue, event);
    }
    
    // 4. Вернуть восстановленное состояние
    return new GlobalState(stateKey, currentValue, pointInTime);
}

private Object applyEvent(Object currentValue, GameEvent event) {
    switch (event.getEventType()) {
        case "PLAYER_LEVELED_UP":
            return event.getEventData().get("newLevel");
        case "REPUTATION_CHANGED":
            int current = (int) currentValue;
            int change = event.getEventData().get("change");
            return current + change;
        // ... другие типы событий
    }
}
```

### Snapshots (снимки состояния)

**Проблема:** Восстановление из миллионов событий медленное

**Решение:** Периодические snapshots

```sql
CREATE TABLE state_snapshots (
    id BIGSERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL,
    state_category VARCHAR(50) NOT NULL,
    
    -- Снимок состояния
    snapshot_data JSONB NOT NULL, -- Полное состояние категории
    snapshot_version BIGINT NOT NULL, -- Версия (номер последнего примененного события)
    
    -- Метаданные
    snapshot_timestamp TIMESTAMP NOT NULL,
    last_event_id UUID NOT NULL, -- Последнее событие в снимке
    event_count BIGINT NOT NULL, -- Количество событий до этого снимка
    
    -- Размер и метрики
    snapshot_size_bytes INTEGER,
    creation_duration_ms INTEGER,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_snapshot_event FOREIGN KEY (last_event_id) REFERENCES game_events(event_id),
    UNIQUE(server_id, state_category, snapshot_version)
);

CREATE INDEX idx_snapshots_server_category ON state_snapshots(server_id, state_category);
CREATE INDEX idx_snapshots_version ON state_snapshots(snapshot_version DESC);
```

**Стратегия создания snapshots:**
```
Каждые 1000 событий → создать snapshot
Каждый час → создать snapshot
При смене лиги → создать snapshot

Восстановление состояния:
1. Загрузить последний snapshot
2. Применить события после snapshot
3. Получить текущее состояние
```

---

## Event Bus (Шина событий)

### Технологии

**Варианты:**
- **Kafka** (рекомендуется для production) - масштабируемость, партиционирование
- **RabbitMQ** (альтернатива) - простота, гибкость
- **Redis Pub/Sub** (для MVP) - простота, скорость

### Topics (темы)

```
necpgame.events.player.{playerId}     - события конкретного игрока
necpgame.events.quest.{questId}       - события квеста
necpgame.events.world.{serverId}      - мировые события сервера
necpgame.events.economy.{region}      - экономические события региона
necpgame.events.combat.{sessionId}    - боевые события сессии
necpgame.events.faction.{factionId}   - события фракции
necpgame.events.global                - глобальные события (все серверы)
```

### Publishers и Subscribers

**Publishers (кто публикует события):**
- QuestService → quest events
- CombatService → combat events
- EconomyService → economy events
- SocialService → social events
- WorldService → world events

**Subscribers (кто подписывается):**
- GlobalStateManager → обновляет global state
- NotificationService → отправляет уведомления
- AnalyticsService → записывает аналитику
- WebSocketService → отправляет real-time updates
- AuditService → логирует для аудита
- CacheInvalidator → инвалидирует кэш

---

## Global State Manager (Менеджер глобального состояния)

### Основной сервис

```java
@Service
public class GlobalStateManager {
    
    @Autowired
    private GlobalStateRepository stateRepository;
    
    @Autowired
    private GameEventRepository eventRepository;
    
    @Autowired
    private RedisTemplate<String, Object> redis;
    
    @Autowired
    private EventBus eventBus;
    
    // ==================== GET STATE ====================
    
    /**
     * Получить значение состояния
     */
    public Object getState(String serverId, String stateKey) {
        // 1. Попытка из кэша
        String cacheKey = "state:" + serverId + ":" + stateKey;
        Object cached = redis.opsForValue().get(cacheKey);
        if (cached != null) {
            return cached;
        }
        
        // 2. Из БД
        GlobalState state = stateRepository.findByServerAndKey(serverId, stateKey);
        if (state == null) {
            return getDefaultValue(stateKey);
        }
        
        // 3. Кэшировать
        redis.opsForValue().set(cacheKey, state.getValue(), 5, TimeUnit.MINUTES);
        
        return state.getValue();
    }
    
    /**
     * Получить категорию состояний
     */
    public Map<String, Object> getStateCategory(
        String serverId, 
        String category
    ) {
        String cacheKey = "state:" + serverId + ":" + category + ":*";
        
        // Попытка из кэша
        Map<String, Object> cached = redis.opsForHash().entries(cacheKey);
        if (!cached.isEmpty()) {
            return cached;
        }
        
        // Из БД
        List<GlobalState> states = stateRepository.findByServerAndCategory(
            serverId, 
            category
        );
        
        Map<String, Object> result = new HashMap<>();
        for (GlobalState state : states) {
            result.put(state.getStateKey(), state.getValue());
        }
        
        // Кэшировать
        redis.opsForHash().putAll(cacheKey, result);
        redis.expire(cacheKey, 5, TimeUnit.MINUTES);
        
        return result;
    }
    
    // ==================== UPDATE STATE ====================
    
    /**
     * Обновить состояние (через событие)
     */
    @Transactional
    public void updateState(
        String serverId,
        String stateKey,
        Object newValue,
        UUID eventId,
        Map<String, Object> metadata
    ) {
        // 1. Получить текущее состояние
        GlobalState currentState = stateRepository.findByServerAndKey(serverId, stateKey);
        Object previousValue = currentState != null ? currentState.getValue() : null;
        
        // 2. Проверить изменение
        if (Objects.equals(previousValue, newValue)) {
            return; // Нет изменений
        }
        
        // 3. Обновить или создать
        if (currentState != null) {
            currentState.setPreviousValue(previousValue);
            currentState.setValue(newValue);
            currentState.setVersion(currentState.getVersion() + 1);
            currentState.setChangedByEventId(eventId);
            currentState.setChangedAt(Instant.now());
            stateRepository.save(currentState);
        } else {
            GlobalState newState = new GlobalState();
            newState.setServerId(serverId);
            newState.setStateKey(stateKey);
            newState.setValue(newValue);
            newState.setChangedByEventId(eventId);
            // ... заполнить остальные поля
            stateRepository.save(newState);
        }
        
        // 4. Инвалидировать кэш
        String cacheKey = "state:" + serverId + ":" + stateKey;
        redis.delete(cacheKey);
        
        // 5. Опубликовать событие изменения состояния
        eventBus.publish(new StateChangedEvent(
            serverId,
            stateKey,
            previousValue,
            newValue,
            eventId
        ));
        
        // 6. Уведомить игроков (если нужно)
        if (metadata.get("notifyPlayers") == Boolean.TRUE) {
            notifyAffectedPlayers(stateKey, newValue);
        }
    }
    
    // ==================== BATCH UPDATE ====================
    
    /**
     * Массовое обновление состояний (для производительности)
     */
    @Transactional
    public void updateStateBatch(
        String serverId,
        Map<String, Object> stateChanges,
        UUID eventId
    ) {
        for (Map.Entry<String, Object> entry : stateChanges.entrySet()) {
            updateState(serverId, entry.getKey(), entry.getValue(), eventId, Map.of());
        }
    }
    
    // ==================== TIME TRAVEL ====================
    
    /**
     * Получить состояние на определенный момент времени
     */
    public Object getStateAtTime(
        String serverId,
        String stateKey,
        Instant pointInTime
    ) {
        // 1. Найти последний snapshot до pointInTime
        StateSnapshot snapshot = snapshotRepository.findLastBefore(
            serverId,
            extractCategory(stateKey),
            pointInTime
        );
        
        // 2. Получить начальное состояние из snapshot
        Object state = snapshot != null 
            ? snapshot.getSnapshotData().get(stateKey)
            : getDefaultValue(stateKey);
        
        // 3. Получить события после snapshot до pointInTime
        Instant snapshotTime = snapshot != null 
            ? snapshot.getSnapshotTimestamp()
            : Instant.EPOCH;
            
        List<GameEvent> events = eventRepository.findEventsForKey(
            stateKey,
            snapshotTime,
            pointInTime
        );
        
        // 4. Применить события
        for (GameEvent event : events) {
            state = applyEventToState(state, event);
        }
        
        return state;
    }
}
```

---

## Синхронизация между игроками (MMORPG)

### Модели синхронизации

**1. Server-Wide State (глобальное для всех):**
- World state (территории, фракции)
- NPC fates (судьбы важных NPC)
- Economy state (цены, доступность)
- Global events

**Характеристики:**
- Все игроки видят одинаково
- Изменения применяются глобально
- Синхронизация через WebSocket
- Eventual consistency

**2. Player-Specific State (личное для игрока):**
- Quest progress (прогресс квестов)
- Player flags (личные флаги)
- Inventory (инвентарь)
- Attributes и skills

**Характеристики:**
- Каждый игрок видит свое
- Изменения локальные
- Синхронизация только для владельца
- Strong consistency

**3. Phased State (фазированное состояние):**
- Квестовые фазы (разные игроки видят разные версии NPC)
- Персональные изменения мира
- Instance-based content

**Характеристики:**
- Игроки в разных фазах видят разное
- Используется для сюжетных квестов
- Сложнее в реализации

### Conflict Resolution (разрешение конфликтов)

**Сценарий:** Два игрока пытаются изменить один и тот же world state одновременно

**Стратегии:**

**1. Last Write Wins (последняя запись побеждает):**
```
Player A: Territory.watson.controller = "Arasaka" (21:00:00)
Player B: Territory.watson.controller = "Militech" (21:00:01)
→ Result: Militech (последняя запись)

❌ Проблема: Может потерять важные изменения
```

**2. Voting System (система голосования):**
```
Player A: Vote for "Arasaka"
Player B: Vote for "Militech"
... 1000 игроков голосуют ...
→ Count votes
→ Result: Majority wins

✅ Решение для мировых событий и NPC fates
```

**3. Event Versioning (версионирование событий):**
```
Current State Version: 100
Event A: expects version 100 → accepted, new version 101
Event B: expects version 100 → rejected (stale version)
Event B': retry with version 101 → accepted, new version 102

✅ Решение для критичных операций (покупка, продажа)
```

**4. Merge Strategy (стратегия слияния):**
```
State: Territory.watson.controlStrength = 50
Event A: +10 (Arasaka attack) → 60
Event B: +5 (Arasaka defense) → 55
→ Merge: MAX(60, 55) = 60 OR SUM(+10, +5) = 65

✅ Решение для накопительных изменений
```

---

## Persistence Strategy (Стратегия сохранения)

### Write-Ahead Log (WAL)

**Концепция:**
1. Событие записывается в Event Store (append-only log)
2. Затем применяется к State Store
3. Если State Store упадет → можно восстановить из Event Store

**Гарантии:**
- Events are NEVER lost (дублирование, репликация)
- State can ALWAYS be reconstructed
- Full audit trail

### Dual Write Problem

**Проблема:**
```
1. Write to Event Store → SUCCESS
2. Update State Store → FAILURE (crash)
→ Event записан, но state не обновлен
```

**Решение: Transactional Outbox Pattern**

```sql
-- Таблица outbox для событий
CREATE TABLE event_outbox (
    id BIGSERIAL PRIMARY KEY,
    event_id UUID NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    state_changes JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    is_published BOOLEAN DEFAULT FALSE
);

-- Транзакция
BEGIN TRANSACTION;
    -- 1. Записать событие в outbox
    INSERT INTO event_outbox (event_id, event_type, event_data, state_changes)
    VALUES (...);
    
    -- 2. Обновить state (в той же транзакции)
    UPDATE global_state SET ... WHERE state_key = ...;
    
COMMIT;

-- 3. Отдельный процесс публикует события из outbox
-- (если что-то упало, события будут опубликованы позже)
```

### Idempotency (идемпотентность)

**Проблема:** Событие может быть обработано дважды (retry, network)

**Решение: Idempotency Key**

```java
@Transactional
public void processEvent(GameEvent event) {
    // 1. Проверить, было ли событие уже обработано
    if (processedEventRepository.exists(event.getEventId())) {
        log.warn("Event already processed: {}", event.getEventId());
        return; // Идемпотентность - не обрабатываем дважды
    }
    
    // 2. Обработать событие
    applyEventToState(event);
    
    // 3. Пометить как обработанное
    processedEventRepository.save(new ProcessedEvent(
        event.getEventId(),
        Instant.now()
    ));
}
```

**Таблица обработанных событий:**
```sql
CREATE TABLE processed_events (
    event_id UUID PRIMARY KEY,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processor_id VARCHAR(100) NOT NULL, -- Какой сервис обработал
    
    -- Для очистки старых записей
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Индекс для очистки
CREATE INDEX idx_processed_events_created ON processed_events(created_at);

-- Периодическая очистка (старше 30 дней)
DELETE FROM processed_events WHERE created_at < NOW() - INTERVAL '30 days';
```

---

## Event Replay (Повтор событий)

### Use Cases

**1. Восстановление после сбоя:**
```
Scenario: State Store corrupted
→ Replay all events from Event Store
→ Reconstruct full state
→ Verify integrity
```

**2. Миграция данных:**
```
Scenario: Изменение структуры state
→ Replay events with new handlers
→ Transform state to new format
→ Validate migration
```

**3. Тестирование:**
```
Scenario: Тестирование новой feature
→ Replay production events
→ Test new logic
→ Compare results
```

**4. Аналитика:**
```
Scenario: Анализ поведения игроков
→ Replay events для конкретного игрока
→ Анализ decision tree
→ Получить insights
```

### Replay Engine

```java
@Service
public class EventReplayEngine {
    
    /**
     * Replay всех событий для восстановления состояния
     */
    public void replayAll(String serverId, Instant from, Instant to) {
        log.info("Starting replay for server {} from {} to {}", serverId, from, to);
        
        // 1. Сбросить текущее состояние (опционально)
        if (from.equals(Instant.EPOCH)) {
            globalStateRepository.deleteByServer(serverId);
        }
        
        // 2. Получить события порциями
        int batchSize = 1000;
        long offset = 0;
        
        while (true) {
            List<GameEvent> events = eventRepository.findByServerAndTimeRange(
                serverId,
                from,
                to,
                offset,
                batchSize
            );
            
            if (events.isEmpty()) {
                break;
            }
            
            // 3. Применить события
            for (GameEvent event : events) {
                try {
                    replayEvent(event);
                } catch (Exception e) {
                    log.error("Error replaying event {}: {}", event.getEventId(), e.getMessage());
                    // Продолжить или остановиться в зависимости от стратегии
                }
            }
            
            offset += batchSize;
            log.info("Replayed {} events", offset);
        }
        
        log.info("Replay completed for server {}", serverId);
    }
    
    /**
     * Replay одного события
     */
    private void replayEvent(GameEvent event) {
        // Применить state changes из события
        if (event.getStateChanges() != null) {
            for (Map.Entry<String, Object> change : event.getStateChanges().entrySet()) {
                globalStateManager.updateState(
                    event.getServerId(),
                    change.getKey(),
                    change.getValue(),
                    event.getEventId(),
                    Map.of("replay", true)
                );
            }
        }
    }
}
```

---

## State Versioning (Версионирование состояния)

### Optimistic Locking

**Концепция:** Проверка версии при обновлении

```java
@Transactional
public void updateStateWithVersion(
    String stateKey,
    Object newValue,
    int expectedVersion
) {
    // 1. Получить текущее состояние с блокировкой
    GlobalState state = stateRepository.findByKeyForUpdate(stateKey);
    
    // 2. Проверить версию
    if (state.getVersion() != expectedVersion) {
        throw new OptimisticLockException(
            "State version mismatch: expected " + expectedVersion + 
            ", actual " + state.getVersion()
        );
    }
    
    // 3. Обновить
    state.setValue(newValue);
    state.setVersion(state.getVersion() + 1);
    stateRepository.save(state);
}
```

**SQL уровень:**
```sql
-- Optimistic locking на уровне БД
UPDATE global_state
SET 
    state_value = :newValue,
    version = version + 1,
    updated_at = NOW()
WHERE 
    state_key = :stateKey
    AND version = :expectedVersion;

-- Если обновлено 0 строк → версия устарела → retry
```

---

## Real-Time Synchronization (Синхронизация в реальном времени)

### WebSocket Architecture

**WebSocket Channels по категориям:**

```typescript
// Канал игрока (личные события)
ws://api.necpgame.com/ws/player/{playerId}

Events:
- player.level.changed
- player.quest.updated
- player.inventory.changed
- player.reputation.changed

// Канал мира (глобальные события)
ws://api.necpgame.com/ws/world/{serverId}

Events:
- world.territory.captured
- world.npc.fate.changed
- world.faction.power.changed
- world.event.triggered

// Канал экономики (рыночные данные)
ws://api.necpgame.com/ws/economy/{serverId}

Events:
- economy.price.changed
- economy.item.crafted
- economy.auction.bid
- economy.market.listing

// Канал боя (боевая сессия)
ws://api.necpgame.com/ws/combat/{sessionId}

Events:
- combat.damage.dealt
- combat.ability.used
- combat.player.died
- combat.enemy.killed
```

### Message Format

```json
{
  "messageType": "STATE_CHANGED",
  "timestamp": "2025-11-06T21:00:00Z",
  "serverId": "server-01",
  "stateChange": {
    "category": "WORLD",
    "stateKey": "world.territory.nightCity.watson.controller",
    "previousValue": "Militech",
    "newValue": "Arasaka",
    "version": 1523
  },
  "eventId": "uuid",
  "affectedPlayers": 3800,
  "metadata": {
    "changeReason": "FACTION_WAR_VICTORY",
    "factionWarId": "war-arasaka-militech-001"
  }
}
```

### Broadcasting Strategy

**Broadcast Types:**

**1. Targeted Broadcast (целевой):**
```java
// Отправить только затронутым игрокам
webSocketService.sendToPlayers(
    event.getAffectedPlayers(),
    message
);
```

**2. Regional Broadcast (региональный):**
```java
// Отправить игрокам в регионе
webSocketService.sendToRegion(
    "nightCity.watson",
    message
);
```

**3. Server Broadcast (весь сервер):**
```java
// Отправить всем игрокам на сервере
webSocketService.sendToServer(
    serverId,
    message
);
```

**4. Selective Broadcast (выборочный):**
```java
// Отправить по условию
webSocketService.sendWhere(
    player -> player.getLocation().startsWith("nightCity"),
    message
);
```

---

## Consistency Models (Модели согласованности)

### Strong Consistency (строгая согласованность)

**Использование:** Критичные операции (покупка, продажа, бой)

**Гарантия:** Все игроки видят изменения немедленно

**Реализация:**
```java
@Transactional(isolation = Isolation.SERIALIZABLE)
public void purchaseItem(UUID playerId, UUID itemId, int price) {
    // 1. Блокировка для чтения и записи
    Player player = playerRepository.findByIdForUpdate(playerId);
    Item item = itemRepository.findByIdForUpdate(itemId);
    
    // 2. Проверки
    if (player.getEurodollars() < price) {
        throw new InsufficientFundsException();
    }
    if (item.getOwnerId() != null) {
        throw new ItemAlreadySoldException();
    }
    
    // 3. Атомарное обновление
    player.setEurodollars(player.getEurodollars() - price);
    item.setOwnerId(playerId);
    
    playerRepository.save(player);
    itemRepository.save(item);
    
    // 4. Событие
    eventStore.append(new ItemPurchasedEvent(playerId, itemId, price));
    
    // Commit транзакции гарантирует атомарность
}
```

### Eventual Consistency (согласованность в конечном счете)

**Использование:** Некритичные операции (reputation, statistics)

**Гарантия:** Все игроки EVENTUALLY видят изменения (задержка 1-60 сек)

**Реализация:**
```java
@Async
public void updateReputation(UUID playerId, String faction, int change) {
    // 1. Создать событие
    GameEvent event = new GameEvent(
        "REPUTATION_CHANGED",
        "PLAYER",
        playerId.toString(),
        Map.of(
            "faction", faction,
            "change", change
        )
    );
    
    // 2. Append в Event Store (быстро)
    eventStore.append(event);
    
    // 3. Опубликовать в Event Bus
    eventBus.publish(event);
    
    // 4. Обработчики применят изменения асинхронно
    // (может быть задержка 1-60 сек)
}
```

### Causal Consistency (причинная согласованность)

**Использование:** Связанные события (quest chain, combo)

**Гарантия:** Если событие B зависит от A, то B обработается после A

**Реализация через Causation ID:**
```java
// Event A
GameEvent eventA = createEvent("QUEST_OBJECTIVE_COMPLETED");
eventStore.append(eventA);

// Event B (зависит от A)
GameEvent eventB = createEvent("QUEST_NEXT_OBJECTIVE_STARTED");
eventB.setCausationId(eventA.getEventId()); // Указание зависимости
eventStore.append(eventB);

// Обработка
eventProcessor.process(eventA); // Сначала A
eventProcessor.process(eventB); // Потом B (только после A)
```

---

## State Query Service (Сервис запросов состояния)

### Query Types

**1. Point Query (запрос точки):**
```java
// Получить конкретное значение
Object value = stateService.get(serverId, stateKey);

// Пример
Integer level = stateService.get("server-01", "player.uuid.level");
String controller = stateService.get("server-01", "world.territory.watson.controller");
```

**2. Range Query (запрос диапазона):**
```java
// Получить все ключи с префиксом
Map<String, Object> states = stateService.getRange(serverId, "player.uuid.*");

// Пример: Все состояния игрока
Map<String, Object> playerState = stateService.getRange(
    "server-01",
    "player.550e8400-e29b-41d4-a716-446655440000.*"
);
// Результат:
// {
//   "player.uuid.level": 50,
//   "player.uuid.class": "Solo",
//   "player.uuid.reputation.arasaka": 45,
//   ...
// }
```

**3. Aggregate Query (агрегированный запрос):**
```java
// Агрегация по категории
Map<String, Integer> factionPowers = stateService.aggregate(
    serverId,
    "world.faction.*.power",
    AggregateFunction.SUM
);

// Пример: Сумма всех репутаций игрока
Integer totalReputation = stateService.aggregate(
    serverId,
    "player.uuid.reputation.*",
    AggregateFunction.SUM
);
```

**4. Time-Travel Query (запрос на момент времени):**
```java
// Получить состояние на определенный момент
Object pastValue = stateService.getAtTime(
    serverId,
    stateKey,
    Instant.parse("2025-11-06T20:00:00Z")
);

// Пример: Кто контролировал Watson 2 часа назад?
String pastController = stateService.getAtTime(
    "server-01",
    "world.territory.watson.controller",
    Instant.now().minus(Duration.ofHours(2))
);
```

**5. Projection Query (проекция):**
```java
// Получить проекцию состояния (только нужные поля)
PlayerStateProjection projection = stateService.getProjection(
    serverId,
    "player.uuid",
    PlayerStateProjection.class,
    Arrays.asList("level", "class", "reputation.arasaka")
);

// Результат:
// PlayerStateProjection {
//   level: 50,
//   class: "Solo",
//   reputation: {arasaka: 45}
// }
```

---

## Projections (Проекции состояния)

### Read Models

**Концепция:** Создание оптимизированных read-моделей из событий

**Event Store (write model):**
```
Events: PLAYER_LEVELED_UP, REPUTATION_CHANGED, QUEST_COMPLETED, ...
→ Append-only, immutable
→ Оптимизировано для записи
```

**Projections (read models):**
```
PlayerProfileProjection: level, class, totalQuests, reputation
QuestStatisticsProjection: completionRate, popularPaths, averageTime
EconomyDashboardProjection: prices, demand, supply, trends

→ Денормализованные, оптимизированные для чтения
→ Обновляются асинхронно из событий
```

**Таблица `player_profile_projection`:**
```sql
CREATE TABLE player_profile_projection (
    player_id UUID PRIMARY KEY,
    
    -- Базовая информация
    level INTEGER NOT NULL,
    experience BIGINT NOT NULL,
    class VARCHAR(50),
    
    -- Прогресс
    total_quests_completed INTEGER DEFAULT 0,
    total_enemies_killed INTEGER DEFAULT 0,
    total_items_crafted INTEGER DEFAULT 0,
    
    -- Репутация (денормализована)
    reputation_arasaka INTEGER DEFAULT 0,
    reputation_militech INTEGER DEFAULT 0,
    reputation_netwatch INTEGER DEFAULT 0,
    -- ... другие фракции
    
    -- Экономика
    total_eurodollars_earned BIGINT DEFAULT 0,
    total_items_sold INTEGER DEFAULT 0,
    
    -- Влияние на мир
    world_impact_score INTEGER DEFAULT 0,
    territories_captured INTEGER DEFAULT 0,
    
    -- Метаданные
    last_event_id UUID,
    last_updated_at TIMESTAMP NOT NULL,
    projection_version INTEGER DEFAULT 1
);
```

**Projector (обработчик событий для проекции):**
```java
@Service
public class PlayerProfileProjector {
    
    @EventListener
    public void on(PlayerLeveledUpEvent event) {
        PlayerProfileProjection profile = projectionRepository.findById(event.getPlayerId());
        profile.setLevel(event.getNewLevel());
        profile.setExperience(event.getTotalExperience());
        profile.setLastEventId(event.getEventId());
        profile.setLastUpdatedAt(Instant.now());
        projectionRepository.save(profile);
    }
    
    @EventListener
    public void on(QuestCompletedEvent event) {
        PlayerProfileProjection profile = projectionRepository.findById(event.getPlayerId());
        profile.setTotalQuestsCompleted(profile.getTotalQuestsCompleted() + 1);
        profile.setWorldImpactScore(
            profile.getWorldImpactScore() + event.getImpactScore()
        );
        projectionRepository.save(profile);
    }
    
    // ... другие обработчики
}
```

---

## Monitoring и Observability

### Метрики системы

**Event Store Metrics:**
```
events.written.total - всего записано событий
events.written.rate - скорость записи событий/сек
events.processing.time - время обработки события
events.processing.errors - ошибки при обработке
events.backlog.size - размер необработанных событий
```

**State Store Metrics:**
```
state.keys.total - всего ключей состояния
state.updates.rate - скорость обновлений/сек
state.cache.hit.rate - hit rate кэша
state.cache.miss.rate - miss rate кэша
state.query.time - время запроса состояния
```

**Synchronization Metrics:**
```
websocket.connections.active - активные WebSocket соединения
websocket.messages.sent.rate - скорость отправки сообщений
websocket.latency - задержка доставки
state.sync.lag - задержка синхронизации (event → client)
```

### Health Checks

```java
@Component
public class GlobalStateHealthCheck implements HealthIndicator {
    
    @Override
    public Health health() {
        // 1. Проверить Event Store
        boolean eventStoreHealthy = checkEventStore();
        
        // 2. Проверить State Store
        boolean stateStoreHealthy = checkStateStore();
        
        // 3. Проверить Event Bus
        boolean eventBusHealthy = checkEventBus();
        
        // 4. Проверить синхронизацию
        long syncLag = checkSyncLag();
        
        if (!eventStoreHealthy || !stateStoreHealthy || !eventBusHealthy) {
            return Health.down()
                .withDetail("eventStore", eventStoreHealthy)
                .withDetail("stateStore", stateStoreHealthy)
                .withDetail("eventBus", eventBusHealthy)
                .build();
        }
        
        if (syncLag > 60000) { // >1 min lag
            return Health.degraded()
                .withDetail("syncLag", syncLag + "ms")
                .build();
        }
        
        return Health.up()
            .withDetail("syncLag", syncLag + "ms")
            .build();
    }
}
```

---

## Disaster Recovery (Восстановление после сбоев)

### Сценарии сбоев

**Сценарий 1: State Store corrupted (состояние повреждено)**

**Решение:**
```
1. Stop accepting writes
2. Replay all events from Event Store
3. Reconstruct full state
4. Verify integrity (checksums, counts)
5. Resume accepting writes
```

**Время восстановления:**
- 1M событий: ~5-10 минут
- 10M событий: ~30-60 минут (с snapshots: 5-10 минут)
- 100M событий: ~5-10 часов (с snapshots: 30-60 минут)

**Сценарий 2: Event Store unavailable (Event Store недоступен)**

**Решение:**
```
1. Enable write buffering (буферизация в памяти/Redis)
2. Buffer events (до 1000 событий)
3. When Event Store available → flush buffer
4. If buffer full → reject new writes (graceful degradation)
```

**Сценарий 3: Event Bus failure (Event Bus упал)**

**Решение:**
```
1. Events still written to Event Store (persistence)
2. Processing delayed until Event Bus restored
3. Catch-up processing (обработка накопленных событий)
4. Gradual processing (чтобы не перегрузить)
```

**Сценарий 4: Full system failure (полный сбой системы)**

**Решение:**
```
1. Event Store replicated (3+ копии)
2. State Store replicated (2+ копии)
3. Point-in-time recovery (backup каждые 6 часов)
4. Geographic distribution (разные дата-центры)

Recovery Steps:
1. Restore Event Store from replica
2. Restore latest State Snapshot
3. Replay events from snapshot to now
4. Verify integrity
5. Resume service
```

---

## Performance Optimization (Оптимизация производительности)

### Write Optimization

**Batch Writes (пакетная запись):**
```java
// Вместо записи каждого события отдельно
for (GameEvent event : events) {
    eventStore.append(event); // N запросов к БД
}

// Пакетная запись
eventStore.appendBatch(events); // 1 запрос к БД
```

**Async Writes (асинхронная запись):**
```java
@Async
public CompletableFuture<Void> appendEventAsync(GameEvent event) {
    return CompletableFuture.runAsync(() -> {
        eventStore.append(event);
    });
}

// Не блокирует основной поток
```

### Read Optimization

**Caching Strategy:**

**Level 1: Local Cache (in-memory):**
```java
@Cacheable(value = "state", key = "#stateKey")
public Object getState(String stateKey) {
    return stateRepository.findByKey(stateKey);
}
```

**Level 2: Distributed Cache (Redis):**
```
Key: state:{serverId}:{stateKey}
TTL: 5 minutes (для некритических)
TTL: 1 minute (для критических)
TTL: 30 seconds (для очень динамических)
```

**Level 3: Materialized Views (материализованные представления):**
```sql
-- Pre-computed aggregates
CREATE MATERIALIZED VIEW faction_power_view AS
SELECT 
    server_id,
    faction_id,
    SUM(economic_power) as total_economic_power,
    SUM(military_power) as total_military_power,
    SUM(political_influence) as total_political_influence
FROM faction_power_components
GROUP BY server_id, faction_id;

-- Refresh каждые 5 минут
REFRESH MATERIALIZED VIEW CONCURRENTLY faction_power_view;
```

### Query Optimization

**Index Strategy:**
```sql
-- Composite indexes для частых запросов
CREATE INDEX idx_events_player_time ON game_events(player_id, event_timestamp DESC);
CREATE INDEX idx_events_type_time ON game_events(event_type, event_timestamp DESC);
CREATE INDEX idx_state_server_category ON global_state(server_id, state_category);

-- Partial indexes для активных данных
CREATE INDEX idx_events_unprocessed ON game_events(event_timestamp) 
WHERE is_processed = FALSE;

CREATE INDEX idx_state_expires ON global_state(expires_at)
WHERE expires_at IS NOT NULL AND expires_at > NOW();
```

**Партиционирование:**
```sql
-- Партиции по времени (monthly)
CREATE TABLE game_events_2025_11 PARTITION OF game_events
FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE game_events_2025_12 PARTITION OF game_events
FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- Автоматическое создание партиций
-- Удаление старых партиций (>6 месяцев) для освобождения места
```

---

## Testing и Debugging

### Event Replay for Testing

```java
@Test
public void testQuestBranching() {
    // 1. Записать события для теста
    eventStore.append(new QuestStartedEvent(playerId, questId));
    eventStore.append(new QuestChoiceMadeEvent(playerId, questId, "A2"));
    eventStore.append(new QuestCompletedEvent(playerId, questId, "pathTruth"));
    
    // 2. Replay события
    replayEngine.replay(playerId, Instant.EPOCH, Instant.now());
    
    // 3. Проверить состояние
    String questStatus = stateService.get(serverId, "player.uuid.quest.questId.status");
    assertEquals("COMPLETED", questStatus);
    
    String chosenPath = stateService.get(serverId, "player.uuid.quest.questId.chosenPath");
    assertEquals("pathTruth", chosenPath);
}
```

### Time Travel Debugging

```java
// Отладка: Что произошло с игроком в 20:00?
Instant debugTime = Instant.parse("2025-11-06T20:00:00Z");

// Получить состояние на этот момент
Object stateAt20 = stateService.getStateAtTime(
    serverId,
    "player.uuid.quest.questId.status",
    debugTime
);

// Получить события после этого момента
List<GameEvent> eventsAfter = eventStore.getEventsAfter(
    "player.uuid",
    debugTime
);

// Анализ: что произошло?
for (GameEvent event : eventsAfter) {
    System.out.println(event.getEventType() + " at " + event.getEventTimestamp());
}
```

---

## Security и Validation

### Event Validation

```java
@Component
public class EventValidator {
    
    public void validate(GameEvent event) {
        // 1. Проверить структуру
        if (event.getEventType() == null || event.getEventData() == null) {
            throw new InvalidEventException("Missing required fields");
        }
        
        // 2. Проверить авторизацию
        if (event.getPlayerId() != null) {
            if (!authService.isAuthenticated(event.getPlayerId())) {
                throw new UnauthorizedException();
            }
        }
        
        // 3. Проверить бизнес-правила
        validateBusinessRules(event);
        
        // 4. Проверить rate limiting
        if (isRateLimitExceeded(event.getPlayerId(), event.getEventType())) {
            throw new RateLimitException();
        }
        
        // 5. Проверить anti-cheat
        if (isCheatDetected(event)) {
            logCheatAttempt(event);
            throw new CheatDetectedException();
        }
    }
    
    private void validateBusinessRules(GameEvent event) {
        switch (event.getEventType()) {
            case "ITEM_PURCHASED":
                validateItemPurchase(event);
                break;
            case "QUEST_CHOICE_MADE":
                validateQuestChoice(event);
                break;
            // ... другие типы
        }
    }
}
```

### Rate Limiting

**По типу события:**
```java
@Component
public class EventRateLimiter {
    
    // Ограничения по типам событий
    private static final Map<String, RateLimit> RATE_LIMITS = Map.of(
        "QUEST_CHOICE_MADE", new RateLimit(10, Duration.ofMinutes(1)),
        "ITEM_PURCHASED", new RateLimit(100, Duration.ofMinutes(1)),
        "MARKET_LISTING_CREATED", new RateLimit(50, Duration.ofMinutes(1)),
        "CHAT_MESSAGE_SENT", new RateLimit(60, Duration.ofMinutes(1))
    );
    
    public boolean isRateLimitExceeded(UUID playerId, String eventType) {
        RateLimit limit = RATE_LIMITS.get(eventType);
        if (limit == null) {
            return false; // Нет ограничения
        }
        
        // Проверить в Redis
        String key = "ratelimit:" + playerId + ":" + eventType;
        Long count = redis.opsForValue().increment(key);
        
        if (count == 1) {
            // Первый запрос - установить TTL
            redis.expire(key, limit.getWindow());
        }
        
        return count > limit.getMaxRequests();
    }
}
```

### Anti-Cheat Detection

```java
@Component
public class AntiCheatDetector {
    
    public boolean detectCheat(GameEvent event) {
        // 1. Проверить невозможные значения
        if (event.getEventType().equals("PLAYER_LEVELED_UP")) {
            int prevLevel = event.getEventData().get("previousLevel");
            int newLevel = event.getEventData().get("newLevel");
            
            if (newLevel - prevLevel > 1) {
                return true; // Подозрение: пропущены уровни
            }
        }
        
        // 2. Проверить временные аномалии
        Instant lastEvent = getLastEventTime(event.getPlayerId());
        Instant currentEvent = event.getEventTimestamp();
        
        if (Duration.between(lastEvent, currentEvent).toMillis() < 100) {
            // Слишком быстро (возможно бот)
            incrementSuspicionScore(event.getPlayerId());
        }
        
        // 3. Проверить паттерны
        List<GameEvent> recentEvents = getRecentEvents(event.getPlayerId(), 100);
        if (hasRepetitivePattern(recentEvents)) {
            return true; // Подозрение: автоматизация
        }
        
        return false;
    }
}
```

---

## Scalability (Масштабируемость)

### Horizontal Scaling

**Event Store:**
```
Partition by aggregate_id (hash)
→ События игрока всегда на одном узле
→ События мира на отдельных узлах
→ Load balancing
```

**State Store:**
```
Shard by server_id + state_category
→ Каждый сервер на отдельном шарде
→ Категории состояний на разных узлах
→ Уменьшение contention
```

**Event Bus:**
```
Kafka partitions:
- player events → partition by playerId (hash)
- world events → partition by serverId
- economy events → partition by region

→ Параллельная обработка
→ Порядок сохраняется внутри партиции
```

### Vertical Scaling

**Database Optimization:**
```
PostgreSQL настройки для high-write workload:
- shared_buffers = 8GB (для кэширования)
- wal_buffers = 16MB (для WAL)
- effective_cache_size = 24GB
- maintenance_work_mem = 2GB
- checkpoint_completion_target = 0.9
- max_wal_size = 4GB

Connection pooling:
- HikariCP: maximumPoolSize = 50
- Отдельные пулы для read/write
```

**Redis Optimization:**
```
Redis для кэширования state:
- maxmemory = 16GB
- maxmemory-policy = allkeys-lru
- Persistence: RDB + AOF (для durability)
- Replication: 2+ replicas

Redis для Event Bus (Pub/Sub):
- Отдельный инстанс Redis
- No persistence (события в Kafka/RabbitMQ)
```

---

## API Endpoints

### Event Management

**POST `/api/v1/events`** - записать событие
```json
Request:
{
  "eventType": "QUEST_CHOICE_MADE",
  "aggregateType": "QUEST",
  "aggregateId": "quest-uuid",
  "eventData": {
    "choiceId": "A2",
    "branchId": "pathTruth"
  }
}

Response:
{
  "eventId": "uuid",
  "timestamp": "2025-11-06T21:00:00Z",
  "processed": true
}
```

**GET `/api/v1/events/{aggregateId}`** - получить события сущности
```json
Response:
{
  "aggregateId": "player-uuid",
  "aggregateType": "PLAYER",
  "events": [
    {
      "eventId": "uuid1",
      "eventType": "PLAYER_CREATED",
      "timestamp": "2025-11-01T10:00:00Z"
    },
    {
      "eventId": "uuid2",
      "eventType": "PLAYER_LEVELED_UP",
      "timestamp": "2025-11-01T12:30:00Z",
      "data": {"level": 2}
    }
  ],
  "total": 1523
}
```

**GET `/api/v1/events/history`** - история событий с фильтрами
```
Query params:
- eventType (filter by type)
- playerId (filter by player)
- from (timestamp from)
- to (timestamp to)
- limit (max results)

Response: paginated list of events
```

### State Management

**GET `/api/v1/state`** - получить полное состояние сервера
```json
{
  "serverId": "server-01",
  "timestamp": "2025-11-06T21:00:00Z",
  "categories": {
    "world": { /* world state */ },
    "economy": { /* economy state */ },
    "territories": { /* territories */ }
  },
  "version": 152345
}
```

**GET `/api/v1/state/{category}`** - состояние по категории
**GET `/api/v1/state/key/{stateKey}`** - конкретный ключ
**GET `/api/v1/state/history/{stateKey}`** - история изменений ключа

```json
{
  "stateKey": "world.territory.watson.controller",
  "currentValue": "Arasaka",
  "history": [
    {
      "value": "Militech",
      "from": "2025-11-05T10:00:00Z",
      "to": "2025-11-06T21:00:00Z",
      "eventId": "uuid",
      "changedBy": "war-victory"
    },
    {
      "value": "Arasaka",
      "from": "2025-11-06T21:00:00Z",
      "to": null,
      "eventId": "uuid",
      "changedBy": "war-victory"
    }
  ]
}
```

**POST `/api/v1/state/replay`** - replay событий (admin only)
```json
Request:
{
  "aggregateId": "player-uuid",
  "from": "2025-11-01T00:00:00Z",
  "to": "2025-11-06T21:00:00Z"
}

Response:
{
  "eventsReplayed": 1523,
  "stateRecovered": true,
  "duration": "5.2 seconds"
}
```

---

## Связанные документы

### Игровые системы
- `.BRAIN/02-gameplay/world/world-state-player-impact.md` - влияние игроков на мир
- `.BRAIN/06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md` - БД для квестов
- `.BRAIN/05-technical/api-specs/api-integration-map.md` - интеграция API

### Архитектура
- `.BRAIN/05-technical/api-specs/api-endpoints-complete.md` - API endpoints
- `.BRAIN/05-technical/api-specs/api-data-models.md` - модели данных

### События и механики
- `.BRAIN/02-gameplay/world/events/global-events-2020-2093.md` - глобальные события
- `.BRAIN/02-gameplay/world/events/world-events-framework.md` - фреймворк событий
- `.BRAIN/04-narrative/quest-system.md` - система квестов

---

## TODO для дальнейшей проработки

**Высокий приоритет (для реализации):**
- [ ] Определить точную стратегию партиционирования Event Store
- [ ] Определить частоту создания snapshots (каждые N событий)
- [ ] Определить стратегию очистки старых событий (retention policy)
- [ ] Интеграция с existing БД схемой из quest-branching-database-design.md

**Средний приоритет:**
- [ ] Детализация phasing system для квестов
- [ ] Проработка conflict resolution для edge cases
- [ ] Детализация disaster recovery procedures
- [ ] Мониторинг и алертинг настройка

**Низкий приоритет (оптимизации):**
- [ ] Балансировка TTL для кэшей
- [ ] Балансировка batch sizes
- [ ] Оптимизация индексов БД под реальную нагрузку
- [ ] Performance testing и load testing

---

## История изменений

- **v1.0.0 (2025-11-06 21:32)** - Создан документ Global State System
  - Описана архитектура Event Sourcing
  - Определена структура Event Store (game_events таблица)
  - Определена структура Global State (global_state таблица)
  - Описаны 10 категорий событий (PLAYER, QUEST, COMBAT, ECONOMY, SOCIAL, WORLD, NPC, TECHNOLOGY, POLITICAL, LEAGUE)
  - Разработана Event Processing Pipeline
  - Описан State Reconstruction из событий
  - Определена Snapshot стратегия
  - Описана синхронизация MMORPG (Server-wide, Player-specific, Phased)
  - Определены Consistency Models (Strong, Eventual, Causal)
  - Описана Persistence Strategy (WAL, Transactional Outbox, Idempotency)
  - Разработан Event Replay механизм
  - Определены Projections (Read Models)
  - Описана Performance Optimization (batch writes, caching, partitioning)
  - Определены API Endpoints
  - Описаны Security, Monitoring, Disaster Recovery

---

## Заключение

**Global State System** - критически важная система для NECPGAME, которая:

✅ **Регистрирует ВСЕ события** в игре (квесты, бой, экономика, социальные, мир)  
✅ **Хранит полную историю** (Event Store, аудит, time travel)  
✅ **Управляет мировым состоянием** (world state, territories, NPC fates, economy)  
✅ **Синхронизирует игроков** (MMORPG, real-time updates, WebSocket)  
✅ **Обеспечивает восстановление** (replay, snapshots, disaster recovery)  
✅ **Масштабируется** (partitioning, sharding, caching)  
✅ **Защищает от сбоев** (replication, backups, graceful degradation)  

**Готовность:** READY для создания API задач! ✅

**Размер документа:** 900+ строк полной технической спецификации

