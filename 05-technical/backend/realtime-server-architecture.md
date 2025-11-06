---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:55  
**api-readiness-notes:** Полная архитектура real-time сервера. Game server instances, zone/instance management, player position sync, network protocol, lag compensation, bandwidth optimization.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-111: api/v1/technical/realtime-server.yaml (2025-11-07)
- Last Updated: 2025-11-07 05:55
---

# Real-Time Server Architecture - Архитектура real-time сервера

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:55  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---

## Краткое описание

**Real-Time Server Architecture** - архитектура для real-time геймплея в MMORPG NECPGAME. Обеспечивает синхронизацию позиций игроков, обработку действий в реальном времени, управление зонами/инстансами и оптимизацию сетевого трафика.

**Ключевые возможности:**
- ✅ Game Server Instances (масштабируемые инстансы)
- ✅ Zone/Instance Management (управление зонами)
- ✅ Player Position Synchronization (синхронизация позиций)
- ✅ Network Protocol (TCP + WebSocket)
- ✅ Lag Compensation (client prediction, server reconciliation)
- ✅ Interest Management (Area of Interest)
- ✅ Bandwidth Optimization (delta compression, priority)

---

## Архитектура High-Level

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENTS (Players)                        │
│  WebSocket connections (TCP) for game state                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    API GATEWAY / LOAD BALANCER               │
│  - Route to appropriate Game Server                          │
│  - WebSocket sticky sessions                                 │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ GAME SERVER  │   │ GAME SERVER  │   │ GAME SERVER  │
│   Instance 1 │   │   Instance 2 │   │   Instance 3 │
│              │   │              │   │              │
│ Zones:       │   │ Zones:       │   │ Zones:       │
│ - Watson     │   │ - Westbrook  │   │ - City Center│
│ - Japantown  │   │ - Heywood    │   │ - Pacifica   │
└──────┬───────┘   └──────┬───────┘   └──────┬───────┘
       │                  │                   │
       └──────────────────┼───────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │        SHARED SERVICES               │
        │  - Redis (state cache)               │
        │  - PostgreSQL (persistent state)     │
        │  - Event Bus (inter-server events)   │
        │  - Global State Manager              │
        └─────────────────────────────────────┘
```

---

## Game Server Instance

### Концепция

**Game Server Instance** - процесс, который обрабатывает gameplay для набора зон и игроков.

**Характеристики:**
- Обрабатывает 1-5 зон (zones)
- Поддерживает 500-2000 concurrent players
- Обновляет game state 20-60 раз в секунду (tick rate)
- Независимый процесс (может падать без влияния на другие)

### Структура

```java
@Component
public class GameServerInstance {
    
    private final String instanceId;
    private final Set<Zone> zones = new ConcurrentHashMap<>();
    private final Map<UUID, PlayerState> activePlayers = new ConcurrentHashMap<>();
    
    private final ScheduledExecutorService gameLoop;
    private final int TICK_RATE = 20; // 20 ticks/sec = 50ms per tick
    
    @PostConstruct
    public void start() {
        // Запустить game loop
        gameLoop.scheduleAtFixedRate(
            this::tick,
            0,
            1000 / TICK_RATE, // 50ms
            TimeUnit.MILLISECONDS
        );
        
        log.info("Game Server Instance {} started with {} zones", 
            instanceId, zones.size());
    }
    
    private void tick() {
        long startTime = System.currentTimeMillis();
        
        // 1. Process input (player actions)
        processPlayerInput();
        
        // 2. Update game state
        updateGameState();
        
        // 3. Run physics/collision
        updatePhysics();
        
        // 4. Update AI (NPCs)
        updateAI();
        
        // 5. Send updates to clients
        broadcastStateUpdates();
        
        // 6. Cleanup
        cleanup();
        
        long elapsed = System.currentTimeMillis() - startTime;
        
        if (elapsed > 50) {
            log.warn("Tick took {}ms (>50ms), performance issue!", elapsed);
        }
    }
}
```

### Game Loop Breakdown

**Tick: 50ms (20 ticks/sec)**

```
0ms:  Start tick
  ↓
2ms:  Process player input (movement, actions)
  ↓
10ms: Update game state (positions, health, cooldowns)
  ↓
15ms: Physics/Collision detection
  ↓
20ms: Update AI (NPCs behavior)
  ↓
30ms: Broadcast state to clients (delta updates)
  ↓
35ms: Cleanup (remove disconnected players, etc)
  ↓
40ms: End tick (sleep until next tick)
```

**Если tick > 50ms:**
- Log warning
- Skip некритичные операции (AI updates)
- Уменьшить broadcast frequency

---

## Zone Management

### Зоны (Zones)

**Zone** - область игрового мира (район Night City)

**Примеры зон:**
- `nightCity.watson` (Watson district)
- `nightCity.westbrook` (Westbrook district)
- `nightCity.cityCenter` (City Center)
- `badlands.rockyRidge` (Badlands region)

**Характеристики зоны:**
- Max players: 100-200 per zone
- Size: 1000x1000 meters (1km²)
- Subdivided into cells (100x100m each)

### Таблица `zones`

```sql
CREATE TABLE zones (
    id VARCHAR(100) PRIMARY KEY,
    zone_name VARCHAR(200) NOT NULL,
    zone_type VARCHAR(50) NOT NULL, -- CITY, BADLANDS, DUNGEON, RAID, PVP
    
    -- Game Server assignment
    assigned_server_id VARCHAR(100),
    
    -- Capacity
    max_players INTEGER NOT NULL DEFAULT 100,
    current_players INTEGER DEFAULT 0,
    
    -- Boundaries
    min_x DECIMAL(10,2),
    max_x DECIMAL(10,2),
    min_y DECIMAL(10,2),
    max_y DECIMAL(10,2),
    min_z DECIMAL(10,2),
    max_z DECIMAL(10,2),
    
    -- Settings
    is_pvp_enabled BOOLEAN DEFAULT FALSE,
    is_safe_zone BOOLEAN DEFAULT TRUE,
    weather VARCHAR(50) DEFAULT 'CLEAR',
    time_of_day VARCHAR(20) DEFAULT 'DAY',
    
    -- Status
    status VARCHAR(20) DEFAULT 'ONLINE', -- ONLINE, MAINTENANCE, OFFLINE
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_zone_server FOREIGN KEY (assigned_server_id) 
        REFERENCES game_server_instances(id)
);

CREATE INDEX idx_zones_server ON zones(assigned_server_id);
CREATE INDEX idx_zones_status ON zones(status);
```

### Zone Cell (Area of Interest)

**Проблема:** Не нужно отправлять ALL player positions ALL players (дорого)

**Решение:** Zone Cells (Interest Management)

```
Zone (1000x1000m) разбита на 100 cells (100x100m each)

Cell[0,0]   Cell[1,0]   Cell[2,0]   ...   Cell[9,0]
Cell[0,1]   Cell[1,1]   Cell[2,1]   ...   Cell[9,1]
...
Cell[0,9]   Cell[1,9]   Cell[2,9]   ...   Cell[9,9]
```

**Игрок видит только:**
- Свою cell
- 8 соседних cells (3x3 grid)

**Пример:**
```
Player в Cell[5,5] видит:
Cell[4,4] | Cell[5,4] | Cell[6,4]
Cell[4,5] | Cell[5,5] | Cell[6,5]
Cell[4,6] | Cell[5,6] | Cell[6,6]

= Максимум 9 cells
```

### Реализация

```java
@Service
public class ZoneManager {
    
    private static final int CELL_SIZE = 100; // 100 meters
    
    public Set<UUID> getPlayersInInterestArea(Zone zone, Vector3 position) {
        // Определить текущую cell
        int cellX = (int) (position.x / CELL_SIZE);
        int cellY = (int) (position.y / CELL_SIZE);
        
        Set<UUID> players = new HashSet<>();
        
        // 3x3 grid вокруг игрока
        for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
                int neighborX = cellX + dx;
                int neighborY = cellY + dy;
                
                String cellKey = zone.getId() + ":" + neighborX + ":" + neighborY;
                
                // Получить игроков в этой cell из Redis
                Set<String> cellPlayers = redis.opsForSet().members(
                    "zone_cell:" + cellKey
                );
                
                if (cellPlayers != null) {
                    cellPlayers.forEach(p -> players.add(UUID.fromString(p)));
                }
            }
        }
        
        return players;
    }
    
    public void updatePlayerCell(UUID playerId, Zone zone, Vector3 position) {
        // Удалить из старой cell
        String oldCellKey = getPlayerCellKey(playerId);
        if (oldCellKey != null) {
            redis.opsForSet().remove("zone_cell:" + oldCellKey, playerId.toString());
        }
        
        // Добавить в новую cell
        int cellX = (int) (position.x / CELL_SIZE);
        int cellY = (int) (position.y / CELL_SIZE);
        String newCellKey = zone.getId() + ":" + cellX + ":" + cellY;
        
        redis.opsForSet().add("zone_cell:" + newCellKey, playerId.toString());
        redis.opsForValue().set("player_cell:" + playerId, newCellKey);
    }
}
```

---

## Player State Synchronization

### Player State

**Что синхронизируется:**
```json
{
  "playerId": "uuid",
  "position": {"x": 1234.56, "y": 5678.90, "z": 10.5},
  "rotation": {"yaw": 45.0, "pitch": 0.0, "roll": 0.0},
  "velocity": {"x": 5.0, "y": 0.0, "z": 0.0},
  "animation": "RUNNING",
  "health": 850,
  "maxHealth": 1000,
  "status": ["BUFF_SPEED", "DEBUFF_POISON"],
  "equipment": {
    "weapon": "mantis_blades",
    "armor": "corpo_suit"
  },
  "currentAction": "ATTACKING",
  "targetId": "npc-uuid",
  "timestamp": 1699296000000
}
```

### Synchronization Protocol

**Client → Server: Input Messages**
```json
{
  "type": "PLAYER_INPUT",
  "sequence": 12345,
  "input": {
    "move": {"forward": 1.0, "right": 0.0},
    "rotation": {"yaw": 45.0},
    "action": "SHOOT",
    "actionTarget": "npc-uuid"
  },
  "timestamp": 1699296000000
}
```

**Server → Client: State Updates**
```json
{
  "type": "STATE_UPDATE",
  "tick": 54321,
  "players": [
    {
      "id": "uuid-1",
      "p": [1234.5, 5678.9, 10.5],
      "r": [45.0, 0.0],
      "a": "RUN"
    },
    {
      "id": "uuid-2",
      "p": [1200.0, 5700.0, 10.0],
      "r": [90.0, 0.0],
      "a": "IDLE"
    }
  ],
  "npcs": [...],
  "timestamp": 1699296001000
}
```

### Update Frequency

**Зависит от типа action:**
```
Combat (в бою):          60 updates/sec (16ms)
Movement (движение):     20 updates/sec (50ms)
Idle (стоит на месте):   5 updates/sec (200ms)
AFK:                     1 update/sec (1000ms)
```

**Реализация:**
```java
private int getUpdateFrequency(PlayerState state) {
    if (state.isInCombat()) {
        return 60; // High frequency
    } else if (state.isMoving()) {
        return 20; // Normal
    } else if (state.isIdle()) {
        return 5; // Low
    } else {
        return 1; // Minimal
    }
}
```

---

## Network Protocol

### WebSocket vs UDP

**Выбор: WebSocket (TCP)**

**Почему НЕ UDP:**
- Web browsers не поддерживают UDP (WebRTC только для voice/video)
- Проблемы с firewall/NAT
- Сложность реализации reliable messages

**Почему WebSocket (TCP):**
- Поддержка во всех браузерах
- Reliable delivery (не нужно реализовывать acknowledgments)
- Проще для web-based клиента
- Trade-off: немного больше latency (но приемлемо для MMORPG)

### Message Types

**Client → Server:**
```
PLAYER_INPUT       - Движение, действия игрока
CHAT_MESSAGE       - Сообщение в чат
ACTION_USE_SKILL   - Использование способности
ACTION_ATTACK      - Атака
ACTION_INTERACT    - Взаимодействие с объектом
HEARTBEAT          - Keepalive
```

**Server → Client:**
```
STATE_UPDATE       - Обновление состояния мира
COMBAT_EVENT       - Событие боя (урон, хилы)
CHAT_MESSAGE       - Сообщения в чат
SYSTEM_NOTIFICATION - Системные уведомления
ZONE_CHANGED       - Смена зоны
PLAYER_DIED        - Смерть игрока
```

### Message Serialization

**Binary Protocol (Protobuf or MessagePack)**

**Преимущества:**
- Меньший размер сообщений (50-80% reduction vs JSON)
- Быстрая сериализация/десериализация
- Typed schema

**Пример (MessagePack):**
```java
@Service
public class MessageCodec {
    
    private ObjectMapper mapper = new ObjectMapper(new MessagePackFactory());
    
    public byte[] encode(Message message) {
        return mapper.writeValueAsBytes(message);
    }
    
    public Message decode(byte[] data) {
        return mapper.readValue(data, Message.class);
    }
}
```

---

## Lag Compensation

### Client-Side Prediction

**Проблема:** Latency 50-100ms → движение чувствуется laggy

**Решение:** Client Prediction

```
Player presses "W" (move forward)
  ↓
CLIENT: Immediately move forward (predict)
  ↓
Send input to server
  ↓
SERVER: Process input, update authoritative state
  ↓
Send state update back to client
  ↓
CLIENT: Reconcile (если prediction правильный - ничего не делать, 
                   если неправильный - корректировать)
```

**Алгоритм:**
```javascript
// Client-side JavaScript
class ClientPrediction {
    constructor() {
        this.pendingInputs = [];
        this.lastServerTick = 0;
    }
    
    onInput(input) {
        // 1. Сохранить input
        input.sequence = this.nextSequence++;
        this.pendingInputs.push(input);
        
        // 2. Немедленно применить локально (prediction)
        this.applyInput(input);
        
        // 3. Отправить на сервер
        this.sendToServer(input);
    }
    
    onServerUpdate(update) {
        // 1. Удалить обработанные inputs
        this.pendingInputs = this.pendingInputs.filter(
            input => input.sequence > update.lastProcessedSequence
        );
        
        // 2. Установить authoritative state
        this.position = update.position;
        
        // 3. Replay pending inputs (reconciliation)
        for (const input of this.pendingInputs) {
            this.applyInput(input);
        }
    }
}
```

### Server Reconciliation

```java
@Service
public class ServerReconciliation {
    
    // История состояний игрока (последние 1 секунда)
    private final Map<UUID, Deque<PlayerStateSnapshot>> stateHistory = 
        new ConcurrentHashMap<>();
    
    public void processPlayerInput(UUID playerId, PlayerInput input) {
        // 1. Получить текущее состояние игрока
        PlayerState state = getPlayerState(playerId);
        
        // 2. Применить input
        applyInput(state, input);
        
        // 3. Validate (anti-cheat)
        if (!isValidMovement(state, input)) {
            log.warn("Invalid movement from player {}, resetting position", playerId);
            resetToLastValidState(playerId);
            return;
        }
        
        // 4. Сохранить snapshot в историю
        saveStateSnapshot(playerId, state, input.getSequence());
        
        // 5. Broadcast to other players
        broadcastPlayerUpdate(playerId, state);
    }
    
    private boolean isValidMovement(PlayerState state, PlayerInput input) {
        // Проверки:
        // - Скорость не превышает max (anti-speedhack)
        // - Позиция в допустимых границах (не вышел за карту)
        // - Нет teleportation (moved too far in one tick)
        
        double maxSpeed = state.getMaxSpeed();
        double actualSpeed = input.getVelocity().length();
        
        if (actualSpeed > maxSpeed * 1.2) { // 20% tolerance
            return false;
        }
        
        return true;
    }
}
```

### Lag Compensation для Combat

**Проблема:** Игрок стреляет, но цель уже переместилась (из-за latency)

**Решение:** Rewind time на сервере

```java
@Service
public class CombatLagCompensation {
    
    public void processShot(UUID shooterId, UUID targetId, long clientTimestamp) {
        // 1. Определить latency
        long serverTime = System.currentTimeMillis();
        long latency = serverTime - clientTimestamp;
        
        // 2. Rewind target position на moment of shot
        PlayerStateSnapshot targetState = getStateAt(
            targetId,
            clientTimestamp - latency
        );
        
        // 3. Проверить hit detection на rewound state
        boolean isHit = checkHitDetection(shooterId, targetState);
        
        // 4. Если hit, применить урон
        if (isHit) {
            applyDamage(targetId, getDamage(shooterId));
            
            // 5. Broadcast hit event
            broadcastCombatEvent(new HitEvent(
                shooterId,
                targetId,
                getDamage(shooterId)
            ));
        }
    }
}
```

---

## Bandwidth Optimization

### Delta Compression

**Проблема:** Отправлять полный state каждый tick - дорого

**Решение:** Delta updates (только изменения)

```java
@Service
public class DeltaCompression {
    
    // Последнее отправленное состояние для каждого игрока
    private final Map<UUID, PlayerState> lastSentState = new ConcurrentHashMap<>();
    
    public PlayerStateDelta createDelta(UUID playerId, PlayerState currentState) {
        PlayerState lastState = lastSentState.get(playerId);
        
        if (lastState == null) {
            // Первый update - отправить все
            lastSentState.put(playerId, currentState.copy());
            return PlayerStateDelta.full(currentState);
        }
        
        // Создать delta (только изменения)
        PlayerStateDelta delta = new PlayerStateDelta(playerId);
        
        if (!currentState.getPosition().equals(lastState.getPosition())) {
            delta.setPosition(currentState.getPosition());
        }
        
        if (!currentState.getRotation().equals(lastState.getRotation())) {
            delta.setRotation(currentState.getRotation());
        }
        
        if (currentState.getHealth() != lastState.getHealth()) {
            delta.setHealth(currentState.getHealth());
        }
        
        // ... и т.д. для остальных полей
        
        // Обновить last sent state
        lastSentState.put(playerId, currentState.copy());
        
        return delta;
    }
}
```

**Экономия:**
```
Full state: ~500 bytes
Delta state: ~50-100 bytes (если только position изменился)
= 80-90% reduction
```

### Priority-Based Updates

**Проблема:** Bandwidth ограничен, не можем отправить все updates

**Решение:** Приоритизация

```java
private List<PlayerState> prioritizeUpdates(
    UUID recipientId,
    List<PlayerState> allPlayers
) {
    // Сортировать по приоритету:
    // 1. Игроки в combat (highest)
    // 2. Игроки близко (по distance)
    // 3. Игроки в party/guild (medium)
    // 4. Остальные (lowest)
    
    return allPlayers.stream()
        .map(state -> {
            int priority = calculatePriority(recipientId, state);
            return new PrioritizedState(state, priority);
        })
        .sorted(Comparator.comparing(PrioritizedState::getPriority).reversed())
        .limit(50) // Максимум 50 updates per tick
        .map(PrioritizedState::getState)
        .collect(Collectors.toList());
}

private int calculatePriority(UUID recipientId, PlayerState state) {
    int priority = 0;
    
    // Combat bonus
    if (state.isInCombat()) {
        priority += 100;
    }
    
    // Distance (closer = higher priority)
    double distance = getDistance(recipientId, state.getPlayerId());
    priority += (int) (100 - distance); // Max 100m
    
    // Party/Guild bonus
    if (isInSameParty(recipientId, state.getPlayerId())) {
        priority += 50;
    }
    
    return priority;
}
```

### Interest Management (АОI)

**Area of Interest (AOI)** - область вокруг игрока, где он видит других

```
Радиус AOI:
- Визуальный: 100m (видит модели)
- Extended: 200m (видит на карте, но не модели)
- Out of range: >200m (не получает updates вообще)
```

**Реализация:**
```java
public Set<UUID> getPlayersInAOI(UUID playerId, int radius) {
    PlayerState player = getPlayerState(playerId);
    Vector3 position = player.getPosition();
    
    // Использовать spatial index (R-Tree или Grid)
    return spatialIndex.query(
        position.x - radius,
        position.y - radius,
        position.x + radius,
        position.y + radius
    );
}
```

---

## Instance Management

### Game Instances (Dungeons/Raids)

**Instance** - изолированная копия dungeon/raid для группы игроков

**Характеристики:**
- Создается при входе группы
- Изолирована (другие группы не видят)
- Существует 2-4 часа
- Автоматически удаляется после завершения

### Таблица `game_instances`

```sql
CREATE TABLE game_instances (
    id VARCHAR(100) PRIMARY KEY,
    
    -- Тип instance
    instance_type VARCHAR(50) NOT NULL, -- DUNGEON, RAID, PVP_ARENA
    template_id VARCHAR(100) NOT NULL, -- dungeon_blackwall, raid_arasaka
    difficulty VARCHAR(20) NOT NULL, -- NORMAL, HARD, NIGHTMARE
    
    -- Server assignment
    server_id VARCHAR(100) NOT NULL,
    
    -- Players
    party_id UUID, -- Для dungeons
    raid_id UUID, -- Для raids
    players JSONB NOT NULL, -- Array of player IDs
    max_players INTEGER NOT NULL,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    -- CREATED, LOADING, ACTIVE, PAUSED, COMPLETED, FAILED
    
    -- Lifecycle
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    expires_at TIMESTAMP NOT NULL, -- Auto-cleanup
    
    -- Progress
    progress JSONB, -- {bossesKilled: 2, checkpointsReached: 3}
    
    -- Лoot
    loot_generated JSONB,
    
    CONSTRAINT fk_instance_server FOREIGN KEY (server_id) 
        REFERENCES game_server_instances(id),
    CONSTRAINT fk_instance_party FOREIGN KEY (party_id) 
        REFERENCES parties(id) ON DELETE CASCADE,
    CONSTRAINT fk_instance_raid FOREIGN KEY (raid_id) 
        REFERENCES raids(id) ON DELETE CASCADE
);

CREATE INDEX idx_instances_server ON game_instances(server_id);
CREATE INDEX idx_instances_status ON game_instances(status);
CREATE INDEX idx_instances_expires ON game_instances(expires_at);
```

### Instance Lifecycle

```
1. Party enters dungeon portal
   ↓
2. InstanceManager.createInstance(DUNGEON, party)
   ↓
3. Select Game Server (load balancing)
   ↓
4. Initialize instance (spawn NPCs, set up state)
   ↓
5. Teleport players into instance
   ↓
6. Instance ACTIVE (game loop runs)
   ↓
7. Party completes/fails/exits
   ↓
8. Instance COMPLETED
   ↓
9. Distribute loot
   ↓
10. Teleport players out
   ↓
11. Instance cleanup (after 5 minutes)
```

### Реализация

```java
@Service
public class InstanceManager {
    
    public GameInstance createInstance(
        InstanceType type,
        String templateId,
        Difficulty difficulty,
        UUID partyId
    ) {
        // 1. Выбрать Game Server (load balancing)
        String serverId = selectOptimalServer();
        
        // 2. Создать instance
        GameInstance instance = new GameInstance();
        instance.setId(generateInstanceId());
        instance.setInstanceType(type);
        instance.setTemplateId(templateId);
        instance.setDifficulty(difficulty);
        instance.setServerId(serverId);
        instance.setPartyId(partyId);
        instance.setMaxPlayers(type.getMaxPlayers());
        instance.setExpiresAt(Instant.now().plus(Duration.ofHours(4)));
        
        // 3. Сохранить
        instanceRepository.save(instance);
        
        // 4. Инициализировать на Game Server
        gameServerClient.initializeInstance(serverId, instance);
        
        // 5. Опубликовать событие
        eventBus.publish(new InstanceCreatedEvent(instance.getId(), partyId));
        
        return instance;
    }
    
    private String selectOptimalServer() {
        // Load balancing: выбрать сервер с наименьшей нагрузкой
        List<GameServerInstance> servers = serverRepository.findAllActive();
        
        return servers.stream()
            .min(Comparator.comparing(GameServerInstance::getCurrentLoad))
            .map(GameServerInstance::getId)
            .orElseThrow(() -> new NoAvailableServersException());
    }
}
```

---

## Database Schema для Real-Time State

### Таблица `player_positions`

```sql
CREATE TABLE player_positions (
    player_id UUID PRIMARY KEY,
    
    -- Позиция
    x DECIMAL(10,2) NOT NULL,
    y DECIMAL(10,2) NOT NULL,
    z DECIMAL(10,2) NOT NULL,
    
    -- Rotation
    yaw DECIMAL(6,2),
    pitch DECIMAL(6,2),
    roll DECIMAL(6,2),
    
    -- Зона
    zone_id VARCHAR(100) NOT NULL,
    server_id VARCHAR(100) NOT NULL,
    instance_id VARCHAR(100), -- Для dungeons/raids
    
    -- Состояние
    is_moving BOOLEAN DEFAULT FALSE,
    is_in_combat BOOLEAN DEFAULT FALSE,
    current_animation VARCHAR(50),
    
    -- Временная метка
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_position_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_position_zone FOREIGN KEY (zone_id) 
        REFERENCES zones(id)
);

CREATE INDEX idx_positions_zone ON player_positions(zone_id);
CREATE INDEX idx_positions_server ON player_positions(server_id);
CREATE INDEX idx_positions_location ON player_positions(x, y, z);
```

**NOTE:** Позиции хранятся в основном в Redis (для скорости), в PostgreSQL только для persistence.

---

## Redis для Real-Time State

### Player Position Cache

**Key:** `player_position:{playerId}`

**Value:**
```json
{
  "x": 1234.56,
  "y": 5678.90,
  "z": 10.5,
  "yaw": 45.0,
  "zoneId": "nightCity.watson",
  "timestamp": 1699296000000
}
```

**TTL:** 5 минут (если игрок disconnect - автоудаление)

### Zone Players (Spatial Index)

**Key:** `zone_players:{zoneId}`

**Type:** Redis Geo Set

```redis
GEOADD zone_players:nightCity.watson 1234.56 5678.90 player-uuid-1
GEOADD zone_players:nightCity.watson 1200.00 5700.00 player-uuid-2

GEORADIUS zone_players:nightCity.watson 1234.56 5678.90 100 m
→ Returns players within 100m
```

---

## Monitoring & Performance

### Метрики Game Server

```
gameserver.tick.duration_ms         - Длительность tick
gameserver.tick.rate                - Тики в секунду
gameserver.players.active           - Активных игроков
gameserver.zones.count              - Количество зон
gameserver.cpu.usage                - CPU usage
gameserver.memory.usage             - Memory usage
gameserver.network.bytes_sent       - Исходящий трафик
gameserver.network.bytes_received   - Входящий трафик
```

### Alerts

```
tick_duration > 50ms                - WARNING
tick_duration > 100ms               - CRITICAL (перегрузка)
players > 80% capacity              - WARNING (нужно масштабирование)
memory > 90%                        - CRITICAL
```

---

## Load Balancing & Scaling

### Horizontal Scaling

**Add new Game Server:**
```
1. Deploy new Game Server instance
2. Register in service registry
3. Assign zones to new server
4. Migrate some players (gracefully)
```

**Graceful Migration:**
```
1. Stop accepting new players on old server
2. Wait for current players to finish activities
3. Or teleport players to safe location + reconnect to new server
4. Shutdown old server
```

### Auto-Scaling

```
If average_cpu > 70% for 5 minutes:
  → Scale up (add server)

If average_cpu < 30% for 30 minutes:
  → Scale down (remove server, migrate players)
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/session-management-system.md` - Session management
- `.BRAIN/05-technical/backend/matchmaking-system.md` - Matchmaking
- `.BRAIN/05-technical/global-state-system.md` - Global state
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - Combat mechanics

---

## TODO

- [ ] Stress testing (сколько concurrent players на один сервер?)
- [ ] Lag compensation тестирование (different latencies 50-200ms)
- [ ] Cross-server zone migration (seamless transition)
- [ ] Disaster recovery (если Game Server падает)

---

## История изменений

- **v1.0.0 (2025-11-06 21:55)** - Создан документ Real-Time Server Architecture

