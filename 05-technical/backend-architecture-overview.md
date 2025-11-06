---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Полный overview backend архитектуры NECPGAME. Все системы, их взаимосвязи, слои, data flow, integration points.
---

# Backend Architecture Overview - Обзор backend архитектуры NECPGAME

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ  
**Автор:** AI Brain Manager

---

## Краткое описание

**Backend Architecture Overview** - централизованный документ, описывающий всю архитектуру backend систем MMORPG NECPGAME, их взаимосвязи и интеграционные точки. Этот документ является "картой" для понимания, как все системы работают вместе.

---

## Архитектура слоев

### Layered Architecture

```
┌───────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                            │
│  - Web Client (React/Next.js)                              │
│  - UE5 Client (C++ прослойка GAME-CPP-FOR-UE5)            │
│  - Mobile Client (будущее)                                 │
└─────────────────────┬─────────────────────────────────────┘
                      │
                      │ HTTP/REST + WebSocket
                      ▼
┌───────────────────────────────────────────────────────────┐
│                   API GATEWAY LAYER                        │
│  - API Gateway (Kong/Spring Cloud Gateway)                 │
│  - Load Balancer                                           │
│  - Rate Limiting                                           │
│  - Authentication Check (JWT validation)                   │
│  - Request Routing                                         │
└─────────────────────┬─────────────────────────────────────┘
                      │
                      │
                      ▼
┌───────────────────────────────────────────────────────────┐
│                APPLICATION LAYER (Services)                │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │   Auth Service   │  │  Session Service │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │ Character Service│  │ Inventory Service│              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │  Quest Service   │  │  Combat Service  │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │  Loot Service    │  │  Trade Service   │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │ Matchmaking Svc  │  │   Chat Service   │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │   Guild Service  │  │   Party Service  │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │  Friend Service  │  │Notification Svc  │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
└─────────────────────┬─────────────────────────────────────┘
                      │
                      │ Event Bus (inter-service communication)
                      ▼
┌───────────────────────────────────────────────────────────┐
│                    EVENT BUS LAYER                         │
│  - Event Publishing/Subscription                           │
│  - Asynchronous processing                                 │
│  - Event handlers для интеграций                           │
└─────────────────────┬─────────────────────────────────────┘
                      │
                      │
                      ▼
┌───────────────────────────────────────────────────────────┐
│                  DATA LAYER                                │
│                                                            │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │   PostgreSQL     │  │      Redis       │              │
│  │  (Persistent)    │  │     (Cache)      │              │
│  └──────────────────┘  └──────────────────┘              │
│                                                            │
└───────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│             GAME SERVER LAYER (Real-Time)                  │
│  - Game Server Instances                                   │
│  - Zone Management                                         │
│  - Player Position Sync                                    │
│  - Combat Processing                                       │
│  - AI/NPC Behavior                                         │
└───────────────────────────────────────────────────────────┘
```

---

## Все Backend системы (15 систем)

### ⭐⭐⭐ MVP БЛОКЕРЫ (без них игра НЕ запустится)

1. **Authentication & Authorization** → регистрация, login, roles
2. **Player & Character Management** → профили, персонажи, slots
3. **Inventory System** → хранение items, equipment, bank
4. **Loot System** → генерация и распределение лута

### ⭐⭐ КРИТИЧЕСКИЕ системы (без них нет онлайн геймплея)

5. **Session Management** → heartbeat, AFK, reconnection
6. **Matchmaking System** → подбор для PvP/PvE/raids
7. **Chat System** → коммуникация между игроками
8. **Real-Time Server Architecture** → синхронизация позиций, lag compensation

### ⭐ ВАЖНЫЕ системы (нужны для полноценной игры)

9. **Trade System** → P2P обмен предметами
10. **Mail System** → отправка items/gold по почте
11. **Notification System** → уведомления игроков
12. **Party System** → группы до 5 игроков
13. **Friend System** → социальный граф
14. **Guild System Backend** → кланы/гильдии
15. **Global State System** → состояние мира, events

---

## Взаимосвязи систем (Integration Map)

### Player Journey Flow

```
1. РЕГИСТРАЦИЯ
   AuthService.register()
     ↓
   EmailService: verification
     ↓
   AnalyticsService: track registration

2. LOGIN
   AuthService.login()
     ↓
   SessionService: create session
     ↓
   NotificationService: "Welcome back!"

3. CHARACTER SELECTION
   CharacterService.selectCharacter()
     ↓
   SessionService: update session with character_id
     ↓
   RealTimeServer: add player to zone

4. GAMEPLAY
   Player moves → RealTimeServer: sync position
   Player attacks → CombatService: process combat
   NPC dies → LootService: generate loot
   Pickup loot → InventoryService: add items
   Complete quest → QuestService: give rewards
   
5. SOCIAL
   Send friend request → FriendService
   Create party → PartyService
   Join guild → GuildService
   Send chat → ChatService

6. LOGOUT
   SessionService.close()
     ↓
   CharacterService: save state
     ↓
   RealTimeServer: remove from zone
```

### System Integration Matrix

```
┌─────────────┬────┬─────┬──────┬──────┬──────┬──────┬────────┐
│             │Auth│Char │Inven │Loot  │Trade │Mail  │Session │
├─────────────┼────┼─────┼──────┼──────┼──────┼──────┼────────┤
│Auth         │ -  │ ✓   │ ✓    │      │      │      │ ✓      │
│Character    │ ✓  │ -   │ ✓    │ ✓    │ ✓    │ ✓    │ ✓      │
│Inventory    │    │ ✓   │ -    │ ✓    │ ✓    │ ✓    │        │
│Loot         │    │ ✓   │ ✓    │ -    │      │      │        │
│Trade        │    │ ✓   │ ✓    │      │ -    │      │ ✓      │
│Mail         │    │ ✓   │ ✓    │      │      │ -    │        │
│Session      │ ✓  │ ✓   │      │      │ ✓    │      │ -      │
│Chat         │    │ ✓   │      │      │      │      │ ✓      │
│Matchmaking  │    │ ✓   │      │      │      │      │ ✓      │
│Party        │    │ ✓   │      │ ✓    │      │      │ ✓      │
│Guild        │    │ ✓   │ ✓    │      │ ✓    │      │        │
│Friend       │    │ ✓   │      │      │      │      │ ✓      │
│Notification │ ✓  │ ✓   │ ✓    │ ✓    │ ✓    │ ✓    │ ✓      │
│Global State │    │ ✓   │      │      │      │      │ ✓      │
│RealTime Srv │    │ ✓   │      │      │      │      │ ✓      │
└─────────────┴────┴─────┴──────┴──────┴──────┴──────┴────────┘
```

---

## Data Flow Examples

### Example 1: Player kills NPC (solo)

```
1. Player attacks NPC
   CombatService.attack()
     ↓
2. NPC health → 0
   CombatService.npcDeath()
     ↓ (publish NPC_DIED event)
     
3. LootService handles event
   LootService.generateLoot(npcLootTable)
     ↓
   WorldDropService.createDrop(position, items)
     ↓ (notify player via WebSocket)
     
4. Player picks up loot
   LootService.pickupItem()
     ↓
   InventoryService.addItem()
     ↓
   QuestService.checkObjective("collect_10_weapons")
     ↓
   AchievementService.checkAchievement("first_legendary")
     ↓
   NotificationService.send("Legendary weapon acquired!")
```

### Example 2: Player joins party and enters dungeon

```
1. Player A creates party
   PartyService.createParty()
     ↓
   ChatService.createPartyChannel()
   
2. Player A invites Player B
   PartyService.invite(playerB)
     ↓
   NotificationService.send(playerB, "Party invite from PlayerA")
   
3. Player B accepts
   PartyService.accept()
     ↓
   ChatService.addToPartyChannel(playerB)
     ↓
   RealTimeServer: update party members positions
   
4. Party queues for dungeon
   MatchmakingService.queueParty(partyId, DUNGEON_HARD)
     ↓ (wait for more players or start if full)
     
5. Match found
   InstanceService.createDungeonInstance(partyId)
     ↓
   RealTimeServer.teleportPartyToInstance()
     ↓
   SessionService.updateAllSessions(instanceId)
   
6. Party kills boss
   CombatService.bossDeath()
     ↓
   LootService.createBossLoot(partyId)
     ↓
   LootRollService.startRolls()
     ↓
   PartyService.distributeLoot()
```

---

## Technology Stack (рекомендации)

### Backend Framework
- **Java Spring Boot** (основной фреймворк)
- **Spring Data JPA** (для PostgreSQL)
- **Spring Security** (authentication/authorization)
- **Spring WebSocket** (для real-time)

### Database
- **PostgreSQL** (основная БД)
  - Persistent storage
  - ACID transactions
  - Partitioning для больших таблиц
- **Redis** (caching + session store)
  - Session cache
  - Player positions
  - Loot tables cache
  - Leaderboards (sorted sets)

### Message Queue
- **Kafka** или **RabbitMQ** (Event Bus)
  - Асинхронная обработка событий
  - Inter-service communication

### Real-Time
- **WebSocket** (на базе Spring WebSocket)
- **STOMP** protocol

---

## Deployment Architecture

```
┌──────────────┐
│  CloudFlare  │ (CDN для статики)
│  (Web Assets)│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Load Balancer│ (Nginx/HAProxy)
└──────┬───────┘
       │
       ├─→ ┌──────────────┐
       │   │ API Gateway  │ (Spring Cloud Gateway)
       │   └──────┬───────┘
       │          │
       ├─→ ┌──────┴──────────────────────────────┐
       │   │      Application Servers             │
       │   │  (Spring Boot Instances)             │
       │   │  - Auth, Character, Inventory, ...   │
       │   └──────┬───────────────────────────────┘
       │          │
       ├─→ ┌──────┴──────────────────────────────┐
       │   │    Game Server Instances             │
       │   │  (Real-Time servers)                 │
       │   │  - Zone management                   │
       │   │  - Position sync                     │
       │   └──────────────────────────────────────┘
       │
       └─→ ┌─────────────────────────────────────┐
           │        Data Layer                    │
           │  ┌──────────┐    ┌──────────┐       │
           │  │PostgreSQL│    │  Redis   │       │
           │  │(Primary) │    │ (Cache)  │       │
           │  └──────────┘    └──────────┘       │
           │                                      │
           │  ┌──────────┐                        │
           │  │  Kafka   │ (Event Bus)            │
           │  └──────────┘                        │
           └─────────────────────────────────────┘
```

---

## Service Dependencies (зависимости сервисов)

### Core Services (всегда нужны)

```
AuthService
  └─→ SessionService
        ├─→ CharacterService
        │     ├─→ InventoryService
        │     │     └─→ LootService
        │     ├─→ QuestService
        │     └─→ CombatService
        │
        ├─→ ChatService
        ├─→ PartyService
        ├─→ GuildService
        └─→ FriendService
```

### Event-Driven Dependencies

```
Any Service can publish events
  ↓
Event Bus (Kafka/RabbitMQ)
  ↓
Event Handlers (subscribers)
  ↓
- AnalyticsService (track all events)
- NotificationService (send notifications)
- AchievementService (check achievements)
- QuestService (check quest objectives)
- GlobalStateService (update world state)
```

---

## API Structure

### REST API Endpoints (по доменам)

**Authentication & Account:**
- `/api/v1/auth/*` - регистрация, login, logout, password recovery
- `/api/v1/account/*` - управление аккаунтом

**Characters & Inventory:**
- `/api/v1/characters/*` - создание персонажей, управление
- `/api/v1/inventory/*` - инвентарь, equipment
- `/api/v1/loot/*` - loot подбор, rolls

**Game Systems:**
- `/api/v1/quests/*` - квесты, progress
- `/api/v1/combat/*` - combat sessions, actions
- `/api/v1/progression/*` - level up, skills, attributes

**Social:**
- `/api/v1/chat/*` - чат, history
- `/api/v1/friends/*` - друзья, requests
- `/api/v1/party/*` - группы, invites
- `/api/v1/guild/*` - гильдии, management
- `/api/v1/mail/*` - почта, attachments

**Matchmaking:**
- `/api/v1/matchmaking/*` - queue, matches, ratings

**Economy:**
- `/api/v1/trade/*` - P2P торговля
- `/api/v1/auction/*` - аукцион
- `/api/v1/market/*` - player market
- `/api/v1/crafting/*` - крафт

**World:**
- `/api/v1/world/state/*` - мировое состояние
- `/api/v1/world/events/*` - мировые события
- `/api/v1/zones/*` - зоны, teleports

**Admin:**
- `/api/v1/admin/*` - админ панель, moderation

### WebSocket Channels (по темам)

**Player-specific:**
- `/topic/player/{accountId}/notifications` - уведомления
- `/topic/player/{accountId}/mail` - новые письма
- `/topic/player/{accountId}/friends` - friend requests

**Character-specific:**
- `/topic/character/{characterId}/position` - позиция других игроков
- `/topic/character/{characterId}/combat` - combat events

**Group-specific:**
- `/topic/party/{partyId}/chat` - party chat
- `/topic/party/{partyId}/loot` - loot rolls
- `/topic/guild/{guildId}/chat` - guild chat
- `/topic/guild/{guildId}/events` - guild events

**Zone-specific:**
- `/topic/zone/{zoneId}/chat` - zone chat
- `/topic/zone/{zoneId}/events` - zone events

**Global:**
- `/topic/server/announcements` - server announcements
- `/topic/world/events` - world events

---

## Data Storage Strategy

### PostgreSQL (долгосрочное хранение)

**Tables по системам:**
- **Auth:** accounts, account_roles, login_history
- **Characters:** players, characters, character_slots
- **Inventory:** character_inventory, character_items, item_templates
- **Loot:** loot_tables, world_drops, loot_rolls
- **Quests:** quests, quest_progress, dialogue_nodes
- **Combat:** combat_sessions, damage_logs
- **Social:** friendships, parties, guilds, guild_members
- **Communication:** chat_messages, mail_messages
- **Matchmaking:** matchmaking_queues, matches, player_ratings
- **World:** zones, game_instances, player_positions
- **Global:** game_events, global_state

### Redis (кэширование)

**Cache keys:**
```
session:{sessionToken}              - Session data
player_position:{characterId}       - Player position
character:{characterId}             - Character data (hot cache)
loot_table:{tableId}                - Loot tables
zone_players:{zoneId}               - Players in zone (Geo Set)
active_players:{serverId}           - Online players (Set)
matchmaking_queue:{activityType}    - Queue (List)
leaderboard:{type}                  - Rankings (Sorted Set)
chat_history:{channel}:{id}         - Chat history (List)
```

---

## Event Types (Event Bus)

### Player Events
- `ACCOUNT_CREATED`, `LOGIN_SUCCESS`, `LOGOUT`
- `CHARACTER_CREATED`, `CHARACTER_DELETED`, `CHARACTER_SWITCHED`
- `LEVEL_UP`, `ATTRIBUTE_INCREASED`, `SKILL_INCREASED`

### Combat Events
- `COMBAT_STARTED`, `COMBAT_ENDED`
- `PLAYER_ATTACKED`, `NPC_DIED`, `PLAYER_DIED`
- `DAMAGE_DEALT`, `HEAL_CAST`

### Loot Events
- `LOOT_GENERATED`, `ITEM_PICKED_UP`, `ITEM_DROPPED`
- `LOOT_ROLL_STARTED`, `LOOT_ROLL_COMPLETED`

### Quest Events
- `QUEST_STARTED`, `QUEST_COMPLETED`, `QUEST_FAILED`
- `DIALOGUE_NODE_REACHED`, `SKILL_CHECK_PASSED`

### Social Events
- `FRIEND_REQUEST_SENT`, `FRIEND_REQUEST_ACCEPTED`
- `PARTY_CREATED`, `PARTY_DISBANDED`, `PLAYER_JOINED_PARTY`
- `GUILD_CREATED`, `PLAYER_JOINED_GUILD`, `GUILD_LEVELED_UP`

### Economy Events
- `TRADE_COMPLETED`, `AUCTION_WON`, `ITEM_SOLD`
- `CURRENCY_GAINED`, `CURRENCY_SPENT`

### World Events
- `ZONE_CHANGED`, `INSTANCE_CREATED`, `BOSS_SPAWNED`
- `TERRITORY_CAPTURED`, `FACTION_WAR_STARTED`

---

## Связанные документы (все backend системы)

### MVP Блокеры
- `.BRAIN/05-technical/backend/authentication-authorization-system.md`
- `.BRAIN/05-technical/backend/player-character-management.md`
- `.BRAIN/05-technical/backend/inventory-system.md`
- `.BRAIN/05-technical/backend/loot-system.md`

### Критические системы
- `.BRAIN/05-technical/backend/session-management-system.md`
- `.BRAIN/05-technical/backend/matchmaking-system.md`
- `.BRAIN/05-technical/backend/chat-system.md`
- `.BRAIN/05-technical/backend/realtime-server-architecture.md`

### Важные системы
- `.BRAIN/05-technical/backend/trade-system.md`
- `.BRAIN/05-technical/backend/mail-system.md`
- `.BRAIN/05-technical/backend/notification-system.md`
- `.BRAIN/05-technical/backend/party-system.md`
- `.BRAIN/05-technical/backend/friend-system.md`
- `.BRAIN/05-technical/backend/guild-system-backend.md`

### Архитектура
- `.BRAIN/05-technical/global-state-system.md`

---

## TODO (следующие системы для проработки)

### Production-Ready Features
- [ ] **API Gateway Architecture** - routing, rate limiting, versioning
- [ ] **Database Architecture** - sharding, replication, partitioning
- [ ] **Caching Strategy** - multi-level caching, invalidation
- [ ] **Anti-Cheat System** - validation, pattern detection
- [ ] **Admin/Moderation Tools** - dashboard, player management
- [ ] **Error Handling & Logging** - structured logging, ELK stack
- [ ] **CDN & Asset Delivery** - для веб-клиента

### Engagement Features
- [ ] **Achievement System** - definitions, progress tracking
- [ ] **Leaderboard System** - global/class/seasonal rankings
- [ ] **Daily/Weekly Quest Reset** - scheduled jobs

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан Backend Architecture Overview

