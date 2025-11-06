---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:55  
**api-readiness-notes:** ╨Я╨╛╨╗╨╜╨░╤П ╨░╤А╤Е╨╕╤В╨╡╨║╤В╤Г╤А╨░ real-time ╤Б╨╡╤А╨▓╨╡╤А╨░. Game server instances, zone/instance management, player position sync, network protocol, lag compensation, bandwidth optimization.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-111: api/v1/technical/realtime-server.yaml (2025-11-07)
- Last Updated: 2025-11-07 05:55
---

# Real-Time Server Architecture - ╨Р╤А╤Е╨╕╤В╨╡╨║╤В╤Г╤А╨░ real-time ╤Б╨╡╤А╨▓╨╡╤А╨░

**╨б╤В╨░╤В╤Г╤Б:** approved  
**╨Т╨╡╤А╤Б╨╕╤П:** 1.0.0  
**╨Ф╨░╤В╨░ ╤Б╨╛╨╖╨┤╨░╨╜╨╕╤П:** 2025-11-06  
**╨Я╨╛╤Б╨╗╨╡╨┤╨╜╨╡╨╡ ╨╛╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╕╨╡:** 2025-11-06 21:55  
**╨Я╤А╨╕╨╛╤А╨╕╤В╨╡╤В:** ╨║╤А╨╕╤В╨╕╤З╨╡╤Б╨║╨╕╨╣  
**╨Р╨▓╤В╨╛╤А:** AI Brain Manager

---

## ╨Ъ╤А╨░╤В╨║╨╛╨╡ ╨╛╨┐╨╕╤Б╨░╨╜╨╕╨╡

**Real-Time Server Architecture** - ╨░╤А╤Е╨╕╤В╨╡╨║╤В╤Г╤А╨░ ╨┤╨╗╤П real-time ╨│╨╡╨╣╨╝╨┐╨╗╨╡╤П ╨▓ MMORPG NECPGAME. ╨Ю╨▒╨╡╤Б╨┐╨╡╤З╨╕╨▓╨░╨╡╤В ╤Б╨╕╨╜╤Е╤А╨╛╨╜╨╕╨╖╨░╤Ж╨╕╤О ╨┐╨╛╨╖╨╕╤Ж╨╕╨╣ ╨╕╨│╤А╨╛╨║╨╛╨▓, ╨╛╨▒╤А╨░╨▒╨╛╤В╨║╤Г ╨┤╨╡╨╣╤Б╤В╨▓╨╕╨╣ ╨▓ ╤А╨╡╨░╨╗╤М╨╜╨╛╨╝ ╨▓╤А╨╡╨╝╨╡╨╜╨╕, ╤Г╨┐╤А╨░╨▓╨╗╨╡╨╜╨╕╨╡ ╨╖╨╛╨╜╨░╨╝╨╕/╨╕╨╜╤Б╤В╨░╨╜╤Б╨░╨╝╨╕ ╨╕ ╨╛╨┐╤В╨╕╨╝╨╕╨╖╨░╤Ж╨╕╤О ╤Б╨╡╤В╨╡╨▓╨╛╨│╨╛ ╤В╤А╨░╤Д╨╕╨║╨░.

**╨Ъ╨╗╤О╤З╨╡╨▓╤Л╨╡ ╨▓╨╛╨╖╨╝╨╛╨╢╨╜╨╛╤Б╤В╨╕:**
- тЬЕ Game Server Instances (╨╝╨░╤Б╤И╤В╨░╨▒╨╕╤А╤Г╨╡╨╝╤Л╨╡ ╨╕╨╜╤Б╤В╨░╨╜╤Б╤Л)
- тЬЕ Zone/Instance Management (╤Г╨┐╤А╨░╨▓╨╗╨╡╨╜╨╕╨╡ ╨╖╨╛╨╜╨░╨╝╨╕)
- тЬЕ Player Position Synchronization (╤Б╨╕╨╜╤Е╤А╨╛╨╜╨╕╨╖╨░╤Ж╨╕╤П ╨┐╨╛╨╖╨╕╤Ж╨╕╨╣)
- тЬЕ Network Protocol (TCP + WebSocket)
- тЬЕ Lag Compensation (client prediction, server reconciliation)
- тЬЕ Interest Management (Area of Interest)
- тЬЕ Bandwidth Optimization (delta compression, priority)

---

## ╨Р╤А╤Е╨╕╤В╨╡╨║╤В╤Г╤А╨░ High-Level

```
тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР
тФВ                     CLIENTS (Players)                        тФВ
тФВ  WebSocket connections (TCP) for game state                  тФВ
тФФтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФмтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФШ
                            тФВ
                            тЦ╝
тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР
тФВ                    API GATEWAY / LOAD BALANCER               тФВ
тФВ  - Route to appropriate Game Server                          тФВ
тФВ  - WebSocket sticky sessions                                 тФВ
тФФтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФмтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФШ
                            тФВ
        тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФ╝тФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР
        тФВ                   тФВ                   тФВ
        тЦ╝                   тЦ╝                   тЦ╝
тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР   тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР   тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР
тФВ GAME SERVER  тФВ   тФВ GAME SERVER  тФВ   тФВ GAME SERVER  тФВ
тФВ   Instance 1 тФВ   тФВ   Instance 2 тФВ   тФВ   Instance 3 тФВ
тФВ              тФВ   тФВ              тФВ   тФВ              тФВ
тФВ Zones:       тФВ   тФВ Zones:       тФВ   тФВ Zones:       тФВ
тФВ - Watson     тФВ   тФВ - Westbrook  тФВ   тФВ - City CenterтФВ
тФВ - Japantown  тФВ   тФВ - Heywood    тФВ   тФВ - Pacifica   тФВ
тФФтФАтФАтФАтФАтФАтФАтФмтФАтФАтФАтФАтФАтФАтФАтФШ   тФФтФАтФАтФАтФАтФАтФАтФмтФАтФАтФАтФАтФАтФАтФАтФШ   тФФтФАтФАтФАтФАтФАтФАтФмтФАтФАтФАтФАтФАтФАтФАтФШ
       тФВ                  тФВ                   тФВ
       тФФтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФ╝тФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФШ
                          тФВ
                          тЦ╝
        тФМтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФР
        тФВ        SHARED SERVICES               тФВ
        тФВ  - Redis (state cache)               тФВ
        тФВ  - PostgreSQL (persistent state)     тФВ
        тФВ  - Event Bus (inter-server events)   тФВ
        тФВ  - Global State Manager              тФВ
        тФФтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФАтФШ
```

---

## Game Server Instance

### ╨Ъ╨╛╨╜╤Ж╨╡╨┐╤Ж╨╕╤П

**Game Server Instance** - ╨┐╤А╨╛╤Ж╨╡╤Б╤Б, ╨║╨╛╤В╨╛╤А╤Л╨╣ ╨╛╨▒╤А╨░╨▒╨░╤В╤Л╨▓╨░╨╡╤В gameplay ╨┤╨╗╤П ╨╜╨░╨▒╨╛╤А╨░ ╨╖╨╛╨╜ ╨╕ ╨╕╨│╤А╨╛╨║╨╛╨▓.

**╨е╨░╤А╨░╨║╤В╨╡╤А╨╕╤Б╤В╨╕╨║╨╕:**
- ╨Ю╨▒╤А╨░╨▒╨░╤В╤Л╨▓╨░╨╡╤В 1-5 ╨╖╨╛╨╜ (zones)
- ╨Я╨╛╨┤╨┤╨╡╤А╨╢╨╕╨▓╨░╨╡╤В 500-2000 concurrent players
- ╨Ю╨▒╨╜╨╛╨▓╨╗╤П╨╡╤В game state 20-60 ╤А╨░╨╖ ╨▓ ╤Б╨╡╨║╤Г╨╜╨┤╤Г (tick rate)
- ╨Э╨╡╨╖╨░╨▓╨╕╤Б╨╕╨╝╤Л╨╣ ╨┐╤А╨╛╤Ж╨╡╤Б╤Б (╨╝╨╛╨╢╨╡╤В ╨┐╨░╨┤╨░╤В╤М ╨▒╨╡╨╖ ╨▓╨╗╨╕╤П╨╜╨╕╤П ╨╜╨░ ╨┤╤А╤Г╨│╨╕╨╡)

### ╨б╤В╤А╤Г╨║╤В╤Г╤А╨░

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
        // ╨Ч╨░╨┐╤Г╤Б╤В╨╕╤В╤М game loop
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
  тЖУ
2ms:  Process player input (movement, actions)
  тЖУ
10ms: Update game state (positions, health, cooldowns)
  тЖУ
15ms: Physics/Collision detection
  тЖУ
20ms: Update AI (NPCs behavior)
  тЖУ
30ms: Broadcast state to clients (delta updates)
  тЖУ
35ms: Cleanup (remove disconnected players, etc)
  тЖУ
40ms: End tick (sleep until next tick)
```

**╨Х╤Б╨╗╨╕ tick > 50ms:**
- Log warning
- Skip ╨╜╨╡╨║╤А╨╕╤В╨╕╤З╨╜╤Л╨╡ ╨╛╨┐╨╡╤А╨░╤Ж╨╕╨╕ (AI updates)
- ╨г╨╝╨╡╨╜╤М╤И╨╕╤В╤М broadcast frequency

---

## Zone Management

### ╨Ч╨╛╨╜╤Л (Zones)

**Zone** - ╨╛╨▒╨╗╨░╤Б╤В╤М ╨╕╨│╤А╨╛╨▓╨╛╨│╨╛ ╨╝╨╕╤А╨░ (╤А╨░╨╣╨╛╨╜ Night City)

**╨Я╤А╨╕╨╝╨╡╤А╤Л ╨╖╨╛╨╜:**
- `nightCity.watson` (Watson district)
- `nightCity.westbrook` (Westbrook district)
- `nightCity.cityCenter` (City Center)
- `badlands.rockyRidge` (Badlands region)

**╨е╨░╤А╨░╨║╤В╨╡╤А╨╕╤Б╤В╨╕╨║╨╕ ╨╖╨╛╨╜╤Л:**
- Max players: 100-200 per zone
- Size: 1000x1000 meters (1km┬▓)
- Subdivided into cells (100x100m each)

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `zones`

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

**╨Я╤А╨╛╨▒╨╗╨╡╨╝╨░:** ╨Э╨╡ ╨╜╤Г╨╢╨╜╨╛ ╨╛╤В╨┐╤А╨░╨▓╨╗╤П╤В╤М ALL player positions ALL players (╨┤╨╛╤А╨╛╨│╨╛)

**╨а╨╡╤И╨╡╨╜╨╕╨╡:** Zone Cells (Interest Management)

```
Zone (1000x1000m) ╤А╨░╨╖╨▒╨╕╤В╨░ ╨╜╨░ 100 cells (100x100m each)

Cell[0,0]   Cell[1,0]   Cell[2,0]   ...   Cell[9,0]
Cell[0,1]   Cell[1,1]   Cell[2,1]   ...   Cell[9,1]
...
Cell[0,9]   Cell[1,9]   Cell[2,9]   ...   Cell[9,9]
```

**╨Ш╨│╤А╨╛╨║ ╨▓╨╕╨┤╨╕╤В ╤В╨╛╨╗╤М╨║╨╛:**
- ╨б╨▓╨╛╤О cell
- 8 ╤Б╨╛╤Б╨╡╨┤╨╜╨╕╤Е cells (3x3 grid)

**╨Я╤А╨╕╨╝╨╡╤А:**
```
Player ╨▓ Cell[5,5] ╨▓╨╕╨┤╨╕╤В:
Cell[4,4] | Cell[5,4] | Cell[6,4]
Cell[4,5] | Cell[5,5] | Cell[6,5]
Cell[4,6] | Cell[5,6] | Cell[6,6]

= ╨Ь╨░╨║╤Б╨╕╨╝╤Г╨╝ 9 cells
```

### ╨а╨╡╨░╨╗╨╕╨╖╨░╤Ж╨╕╤П

```java
@Service
public class ZoneManager {
    
    private static final int CELL_SIZE = 100; // 100 meters
    
    public Set<UUID> getPlayersInInterestArea(Zone zone, Vector3 position) {
        // ╨Ю╨┐╤А╨╡╨┤╨╡╨╗╨╕╤В╤М ╤В╨╡╨║╤Г╤Й╤Г╤О cell
        int cellX = (int) (position.x / CELL_SIZE);
        int cellY = (int) (position.y / CELL_SIZE);
        
        Set<UUID> players = new HashSet<>();
        
        // 3x3 grid ╨▓╨╛╨║╤А╤Г╨│ ╨╕╨│╤А╨╛╨║╨░
        for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
                int neighborX = cellX + dx;
                int neighborY = cellY + dy;
                
                String cellKey = zone.getId() + ":" + neighborX + ":" + neighborY;
                
                // ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М ╨╕╨│╤А╨╛╨║╨╛╨▓ ╨▓ ╤Н╤В╨╛╨╣ cell ╨╕╨╖ Redis
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
        // ╨г╨┤╨░╨╗╨╕╤В╤М ╨╕╨╖ ╤Б╤В╨░╤А╨╛╨╣ cell
        String oldCellKey = getPlayerCellKey(playerId);
        if (oldCellKey != null) {
            redis.opsForSet().remove("zone_cell:" + oldCellKey, playerId.toString());
        }
        
        // ╨Ф╨╛╨▒╨░╨▓╨╕╤В╤М ╨▓ ╨╜╨╛╨▓╤Г╤О cell
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

**╨з╤В╨╛ ╤Б╨╕╨╜╤Е╤А╨╛╨╜╨╕╨╖╨╕╤А╤Г╨╡╤В╤Б╤П:**
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

**Client тЖТ Server: Input Messages**
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

**Server тЖТ Client: State Updates**
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

**╨Ч╨░╨▓╨╕╤Б╨╕╤В ╨╛╤В ╤В╨╕╨┐╨░ action:**
```
Combat (╨▓ ╨▒╨╛╤О):          60 updates/sec (16ms)
Movement (╨┤╨▓╨╕╨╢╨╡╨╜╨╕╨╡):     20 updates/sec (50ms)
Idle (╤Б╤В╨╛╨╕╤В ╨╜╨░ ╨╝╨╡╤Б╤В╨╡):   5 updates/sec (200ms)
AFK:                     1 update/sec (1000ms)
```

**╨а╨╡╨░╨╗╨╕╨╖╨░╤Ж╨╕╤П:**
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

**╨Т╤Л╨▒╨╛╤А: WebSocket (TCP)**

**╨Я╨╛╤З╨╡╨╝╤Г ╨Э╨Х UDP:**
- Web browsers ╨╜╨╡ ╨┐╨╛╨┤╨┤╨╡╤А╨╢╨╕╨▓╨░╤О╤В UDP (WebRTC ╤В╨╛╨╗╤М╨║╨╛ ╨┤╨╗╤П voice/video)
- ╨Я╤А╨╛╨▒╨╗╨╡╨╝╤Л ╤Б firewall/NAT
- ╨б╨╗╨╛╨╢╨╜╨╛╤Б╤В╤М ╤А╨╡╨░╨╗╨╕╨╖╨░╤Ж╨╕╨╕ reliable messages

**╨Я╨╛╤З╨╡╨╝╤Г WebSocket (TCP):**
- ╨Я╨╛╨┤╨┤╨╡╤А╨╢╨║╨░ ╨▓╨╛ ╨▓╤Б╨╡╤Е ╨▒╤А╨░╤Г╨╖╨╡╤А╨░╤Е
- Reliable delivery (╨╜╨╡ ╨╜╤Г╨╢╨╜╨╛ ╤А╨╡╨░╨╗╨╕╨╖╨╛╨▓╤Л╨▓╨░╤В╤М acknowledgments)
- ╨Я╤А╨╛╤Й╨╡ ╨┤╨╗╤П web-based ╨║╨╗╨╕╨╡╨╜╤В╨░
- Trade-off: ╨╜╨╡╨╝╨╜╨╛╨│╨╛ ╨▒╨╛╨╗╤М╤И╨╡ latency (╨╜╨╛ ╨┐╤А╨╕╨╡╨╝╨╗╨╡╨╝╨╛ ╨┤╨╗╤П MMORPG)

### Message Types

**Client тЖТ Server:**
```
PLAYER_INPUT       - ╨Ф╨▓╨╕╨╢╨╡╨╜╨╕╨╡, ╨┤╨╡╨╣╤Б╤В╨▓╨╕╤П ╨╕╨│╤А╨╛╨║╨░
CHAT_MESSAGE       - ╨б╨╛╨╛╨▒╤Й╨╡╨╜╨╕╨╡ ╨▓ ╤З╨░╤В
ACTION_USE_SKILL   - ╨Ш╤Б╨┐╨╛╨╗╤М╨╖╨╛╨▓╨░╨╜╨╕╨╡ ╤Б╨┐╨╛╤Б╨╛╨▒╨╜╨╛╤Б╤В╨╕
ACTION_ATTACK      - ╨Р╤В╨░╨║╨░
ACTION_INTERACT    - ╨Т╨╖╨░╨╕╨╝╨╛╨┤╨╡╨╣╤Б╤В╨▓╨╕╨╡ ╤Б ╨╛╨▒╤К╨╡╨║╤В╨╛╨╝
HEARTBEAT          - Keepalive
```

**Server тЖТ Client:**
```
STATE_UPDATE       - ╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╕╨╡ ╤Б╨╛╤Б╤В╨╛╤П╨╜╨╕╤П ╨╝╨╕╤А╨░
COMBAT_EVENT       - ╨б╨╛╨▒╤Л╤В╨╕╨╡ ╨▒╨╛╤П (╤Г╤А╨╛╨╜, ╤Е╨╕╨╗╤Л)
CHAT_MESSAGE       - ╨б╨╛╨╛╨▒╤Й╨╡╨╜╨╕╤П ╨▓ ╤З╨░╤В
SYSTEM_NOTIFICATION - ╨б╨╕╤Б╤В╨╡╨╝╨╜╤Л╨╡ ╤Г╨▓╨╡╨┤╨╛╨╝╨╗╨╡╨╜╨╕╤П
ZONE_CHANGED       - ╨б╨╝╨╡╨╜╨░ ╨╖╨╛╨╜╤Л
PLAYER_DIED        - ╨б╨╝╨╡╤А╤В╤М ╨╕╨│╤А╨╛╨║╨░
```

### Message Serialization

**Binary Protocol (Protobuf or MessagePack)**

**╨Я╤А╨╡╨╕╨╝╤Г╤Й╨╡╤Б╤В╨▓╨░:**
- ╨Ь╨╡╨╜╤М╤И╨╕╨╣ ╤А╨░╨╖╨╝╨╡╤А ╤Б╨╛╨╛╨▒╤Й╨╡╨╜╨╕╨╣ (50-80% reduction vs JSON)
- ╨С╤Л╤Б╤В╤А╨░╤П ╤Б╨╡╤А╨╕╨░╨╗╨╕╨╖╨░╤Ж╨╕╤П/╨┤╨╡╤Б╨╡╤А╨╕╨░╨╗╨╕╨╖╨░╤Ж╨╕╤П
- Typed schema

**╨Я╤А╨╕╨╝╨╡╤А (MessagePack):**
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

**╨Я╤А╨╛╨▒╨╗╨╡╨╝╨░:** Latency 50-100ms тЖТ ╨┤╨▓╨╕╨╢╨╡╨╜╨╕╨╡ ╤З╤Г╨▓╤Б╤В╨▓╤Г╨╡╤В╤Б╤П laggy

**╨а╨╡╤И╨╡╨╜╨╕╨╡:** Client Prediction

```
Player presses "W" (move forward)
  тЖУ
CLIENT: Immediately move forward (predict)
  тЖУ
Send input to server
  тЖУ
SERVER: Process input, update authoritative state
  тЖУ
Send state update back to client
  тЖУ
CLIENT: Reconcile (╨╡╤Б╨╗╨╕ prediction ╨┐╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ - ╨╜╨╕╤З╨╡╨│╨╛ ╨╜╨╡ ╨┤╨╡╨╗╨░╤В╤М, 
                   ╨╡╤Б╨╗╨╕ ╨╜╨╡╨┐╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ - ╨║╨╛╤А╤А╨╡╨║╤В╨╕╤А╨╛╨▓╨░╤В╤М)
```

**╨Р╨╗╨│╨╛╤А╨╕╤В╨╝:**
```javascript
// Client-side JavaScript
class ClientPrediction {
    constructor() {
        this.pendingInputs = [];
        this.lastServerTick = 0;
    }
    
    onInput(input) {
        // 1. ╨б╨╛╤Е╤А╨░╨╜╨╕╤В╤М input
        input.sequence = this.nextSequence++;
        this.pendingInputs.push(input);
        
        // 2. ╨Э╨╡╨╝╨╡╨┤╨╗╨╡╨╜╨╜╨╛ ╨┐╤А╨╕╨╝╨╡╨╜╨╕╤В╤М ╨╗╨╛╨║╨░╨╗╤М╨╜╨╛ (prediction)
        this.applyInput(input);
        
        // 3. ╨Ю╤В╨┐╤А╨░╨▓╨╕╤В╤М ╨╜╨░ ╤Б╨╡╤А╨▓╨╡╤А
        this.sendToServer(input);
    }
    
    onServerUpdate(update) {
        // 1. ╨г╨┤╨░╨╗╨╕╤В╤М ╨╛╨▒╤А╨░╨▒╨╛╤В╨░╨╜╨╜╤Л╨╡ inputs
        this.pendingInputs = this.pendingInputs.filter(
            input => input.sequence > update.lastProcessedSequence
        );
        
        // 2. ╨г╤Б╤В╨░╨╜╨╛╨▓╨╕╤В╤М authoritative state
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
    
    // ╨Ш╤Б╤В╨╛╤А╨╕╤П ╤Б╨╛╤Б╤В╨╛╤П╨╜╨╕╨╣ ╨╕╨│╤А╨╛╨║╨░ (╨┐╨╛╤Б╨╗╨╡╨┤╨╜╨╕╨╡ 1 ╤Б╨╡╨║╤Г╨╜╨┤╨░)
    private final Map<UUID, Deque<PlayerStateSnapshot>> stateHistory = 
        new ConcurrentHashMap<>();
    
    public void processPlayerInput(UUID playerId, PlayerInput input) {
        // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М ╤В╨╡╨║╤Г╤Й╨╡╨╡ ╤Б╨╛╤Б╤В╨╛╤П╨╜╨╕╨╡ ╨╕╨│╤А╨╛╨║╨░
        PlayerState state = getPlayerState(playerId);
        
        // 2. ╨Я╤А╨╕╨╝╨╡╨╜╨╕╤В╤М input
        applyInput(state, input);
        
        // 3. Validate (anti-cheat)
        if (!isValidMovement(state, input)) {
            log.warn("Invalid movement from player {}, resetting position", playerId);
            resetToLastValidState(playerId);
            return;
        }
        
        // 4. ╨б╨╛╤Е╤А╨░╨╜╨╕╤В╤М snapshot ╨▓ ╨╕╤Б╤В╨╛╤А╨╕╤О
        saveStateSnapshot(playerId, state, input.getSequence());
        
        // 5. Broadcast to other players
        broadcastPlayerUpdate(playerId, state);
    }
    
    private boolean isValidMovement(PlayerState state, PlayerInput input) {
        // ╨Я╤А╨╛╨▓╨╡╤А╨║╨╕:
        // - ╨б╨║╨╛╤А╨╛╤Б╤В╤М ╨╜╨╡ ╨┐╤А╨╡╨▓╤Л╤И╨░╨╡╤В max (anti-speedhack)
        // - ╨Я╨╛╨╖╨╕╤Ж╨╕╤П ╨▓ ╨┤╨╛╨┐╤Г╤Б╤В╨╕╨╝╤Л╤Е ╨│╤А╨░╨╜╨╕╤Ж╨░╤Е (╨╜╨╡ ╨▓╤Л╤И╨╡╨╗ ╨╖╨░ ╨║╨░╤А╤В╤Г)
        // - ╨Э╨╡╤В teleportation (moved too far in one tick)
        
        double maxSpeed = state.getMaxSpeed();
        double actualSpeed = input.getVelocity().length();
        
        if (actualSpeed > maxSpeed * 1.2) { // 20% tolerance
            return false;
        }
        
        return true;
    }
}
```

### Lag Compensation ╨┤╨╗╤П Combat

**╨Я╤А╨╛╨▒╨╗╨╡╨╝╨░:** ╨Ш╨│╤А╨╛╨║ ╤Б╤В╤А╨╡╨╗╤П╨╡╤В, ╨╜╨╛ ╤Ж╨╡╨╗╤М ╤Г╨╢╨╡ ╨┐╨╡╤А╨╡╨╝╨╡╤Б╤В╨╕╨╗╨░╤Б╤М (╨╕╨╖-╨╖╨░ latency)

**╨а╨╡╤И╨╡╨╜╨╕╨╡:** Rewind time ╨╜╨░ ╤Б╨╡╤А╨▓╨╡╤А╨╡

```java
@Service
public class CombatLagCompensation {
    
    public void processShot(UUID shooterId, UUID targetId, long clientTimestamp) {
        // 1. ╨Ю╨┐╤А╨╡╨┤╨╡╨╗╨╕╤В╤М latency
        long serverTime = System.currentTimeMillis();
        long latency = serverTime - clientTimestamp;
        
        // 2. Rewind target position ╨╜╨░ moment of shot
        PlayerStateSnapshot targetState = getStateAt(
            targetId,
            clientTimestamp - latency
        );
        
        // 3. ╨Я╤А╨╛╨▓╨╡╤А╨╕╤В╤М hit detection ╨╜╨░ rewound state
        boolean isHit = checkHitDetection(shooterId, targetState);
        
        // 4. ╨Х╤Б╨╗╨╕ hit, ╨┐╤А╨╕╨╝╨╡╨╜╨╕╤В╤М ╤Г╤А╨╛╨╜
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

**╨Я╤А╨╛╨▒╨╗╨╡╨╝╨░:** ╨Ю╤В╨┐╤А╨░╨▓╨╗╤П╤В╤М ╨┐╨╛╨╗╨╜╤Л╨╣ state ╨║╨░╨╢╨┤╤Л╨╣ tick - ╨┤╨╛╤А╨╛╨│╨╛

**╨а╨╡╤И╨╡╨╜╨╕╨╡:** Delta updates (╤В╨╛╨╗╤М╨║╨╛ ╨╕╨╖╨╝╨╡╨╜╨╡╨╜╨╕╤П)

```java
@Service
public class DeltaCompression {
    
    // ╨Я╨╛╤Б╨╗╨╡╨┤╨╜╨╡╨╡ ╨╛╤В╨┐╤А╨░╨▓╨╗╨╡╨╜╨╜╨╛╨╡ ╤Б╨╛╤Б╤В╨╛╤П╨╜╨╕╨╡ ╨┤╨╗╤П ╨║╨░╨╢╨┤╨╛╨│╨╛ ╨╕╨│╤А╨╛╨║╨░
    private final Map<UUID, PlayerState> lastSentState = new ConcurrentHashMap<>();
    
    public PlayerStateDelta createDelta(UUID playerId, PlayerState currentState) {
        PlayerState lastState = lastSentState.get(playerId);
        
        if (lastState == null) {
            // ╨Я╨╡╤А╨▓╤Л╨╣ update - ╨╛╤В╨┐╤А╨░╨▓╨╕╤В╤М ╨▓╤Б╨╡
            lastSentState.put(playerId, currentState.copy());
            return PlayerStateDelta.full(currentState);
        }
        
        // ╨б╨╛╨╖╨┤╨░╤В╤М delta (╤В╨╛╨╗╤М╨║╨╛ ╨╕╨╖╨╝╨╡╨╜╨╡╨╜╨╕╤П)
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
        
        // ... ╨╕ ╤В.╨┤. ╨┤╨╗╤П ╨╛╤Б╤В╨░╨╗╤М╨╜╤Л╤Е ╨┐╨╛╨╗╨╡╨╣
        
        // ╨Ю╨▒╨╜╨╛╨▓╨╕╤В╤М last sent state
        lastSentState.put(playerId, currentState.copy());
        
        return delta;
    }
}
```

**╨н╨║╨╛╨╜╨╛╨╝╨╕╤П:**
```
Full state: ~500 bytes
Delta state: ~50-100 bytes (╨╡╤Б╨╗╨╕ ╤В╨╛╨╗╤М╨║╨╛ position ╨╕╨╖╨╝╨╡╨╜╨╕╨╗╤Б╤П)
= 80-90% reduction
```

### Priority-Based Updates

**╨Я╤А╨╛╨▒╨╗╨╡╨╝╨░:** Bandwidth ╨╛╨│╤А╨░╨╜╨╕╤З╨╡╨╜, ╨╜╨╡ ╨╝╨╛╨╢╨╡╨╝ ╨╛╤В╨┐╤А╨░╨▓╨╕╤В╤М ╨▓╤Б╨╡ updates

**╨а╨╡╤И╨╡╨╜╨╕╨╡:** ╨Я╤А╨╕╨╛╤А╨╕╤В╨╕╨╖╨░╤Ж╨╕╤П

```java
private List<PlayerState> prioritizeUpdates(
    UUID recipientId,
    List<PlayerState> allPlayers
) {
    // ╨б╨╛╤А╤В╨╕╤А╨╛╨▓╨░╤В╤М ╨┐╨╛ ╨┐╤А╨╕╨╛╤А╨╕╤В╨╡╤В╤Г:
    // 1. ╨Ш╨│╤А╨╛╨║╨╕ ╨▓ combat (highest)
    // 2. ╨Ш╨│╤А╨╛╨║╨╕ ╨▒╨╗╨╕╨╖╨║╨╛ (╨┐╨╛ distance)
    // 3. ╨Ш╨│╤А╨╛╨║╨╕ ╨▓ party/guild (medium)
    // 4. ╨Ю╤Б╤В╨░╨╗╤М╨╜╤Л╨╡ (lowest)
    
    return allPlayers.stream()
        .map(state -> {
            int priority = calculatePriority(recipientId, state);
            return new PrioritizedState(state, priority);
        })
        .sorted(Comparator.comparing(PrioritizedState::getPriority).reversed())
        .limit(50) // ╨Ь╨░╨║╤Б╨╕╨╝╤Г╨╝ 50 updates per tick
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

### Interest Management (╨Р╨ЮI)

**Area of Interest (AOI)** - ╨╛╨▒╨╗╨░╤Б╤В╤М ╨▓╨╛╨║╤А╤Г╨│ ╨╕╨│╤А╨╛╨║╨░, ╨│╨┤╨╡ ╨╛╨╜ ╨▓╨╕╨┤╨╕╤В ╨┤╤А╤Г╨│╨╕╤Е

```
╨а╨░╨┤╨╕╤Г╤Б AOI:
- ╨Т╨╕╨╖╤Г╨░╨╗╤М╨╜╤Л╨╣: 100m (╨▓╨╕╨┤╨╕╤В ╨╝╨╛╨┤╨╡╨╗╨╕)
- Extended: 200m (╨▓╨╕╨┤╨╕╤В ╨╜╨░ ╨║╨░╤А╤В╨╡, ╨╜╨╛ ╨╜╨╡ ╨╝╨╛╨┤╨╡╨╗╨╕)
- Out of range: >200m (╨╜╨╡ ╨┐╨╛╨╗╤Г╤З╨░╨╡╤В updates ╨▓╨╛╨╛╨▒╤Й╨╡)
```

**╨а╨╡╨░╨╗╨╕╨╖╨░╤Ж╨╕╤П:**
```java
public Set<UUID> getPlayersInAOI(UUID playerId, int radius) {
    PlayerState player = getPlayerState(playerId);
    Vector3 position = player.getPosition();
    
    // ╨Ш╤Б╨┐╨╛╨╗╤М╨╖╨╛╨▓╨░╤В╤М spatial index (R-Tree ╨╕╨╗╨╕ Grid)
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

**Instance** - ╨╕╨╖╨╛╨╗╨╕╤А╨╛╨▓╨░╨╜╨╜╨░╤П ╨║╨╛╨┐╨╕╤П dungeon/raid ╨┤╨╗╤П ╨│╤А╤Г╨┐╨┐╤Л ╨╕╨│╤А╨╛╨║╨╛╨▓

**╨е╨░╤А╨░╨║╤В╨╡╤А╨╕╤Б╤В╨╕╨║╨╕:**
- ╨б╨╛╨╖╨┤╨░╨╡╤В╤Б╤П ╨┐╤А╨╕ ╨▓╤Е╨╛╨┤╨╡ ╨│╤А╤Г╨┐╨┐╤Л
- ╨Ш╨╖╨╛╨╗╨╕╤А╨╛╨▓╨░╨╜╨░ (╨┤╤А╤Г╨│╨╕╨╡ ╨│╤А╤Г╨┐╨┐╤Л ╨╜╨╡ ╨▓╨╕╨┤╤П╤В)
- ╨б╤Г╤Й╨╡╤Б╤В╨▓╤Г╨╡╤В 2-4 ╤З╨░╤Б╨░
- ╨Р╨▓╤В╨╛╨╝╨░╤В╨╕╤З╨╡╤Б╨║╨╕ ╤Г╨┤╨░╨╗╤П╨╡╤В╤Б╤П ╨┐╨╛╤Б╨╗╨╡ ╨╖╨░╨▓╨╡╤А╤И╨╡╨╜╨╕╤П

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `game_instances`

```sql
CREATE TABLE game_instances (
    id VARCHAR(100) PRIMARY KEY,
    
    -- ╨в╨╕╨┐ instance
    instance_type VARCHAR(50) NOT NULL, -- DUNGEON, RAID, PVP_ARENA
    template_id VARCHAR(100) NOT NULL, -- dungeon_blackwall, raid_arasaka
    difficulty VARCHAR(20) NOT NULL, -- NORMAL, HARD, NIGHTMARE
    
    -- Server assignment
    server_id VARCHAR(100) NOT NULL,
    
    -- Players
    party_id UUID, -- ╨Ф╨╗╤П dungeons
    raid_id UUID, -- ╨Ф╨╗╤П raids
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
    
    -- ╨Ыoot
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
   тЖУ
2. InstanceManager.createInstance(DUNGEON, party)
   тЖУ
3. Select Game Server (load balancing)
   тЖУ
4. Initialize instance (spawn NPCs, set up state)
   тЖУ
5. Teleport players into instance
   тЖУ
6. Instance ACTIVE (game loop runs)
   тЖУ
7. Party completes/fails/exits
   тЖУ
8. Instance COMPLETED
   тЖУ
9. Distribute loot
   тЖУ
10. Teleport players out
   тЖУ
11. Instance cleanup (after 5 minutes)
```

### ╨а╨╡╨░╨╗╨╕╨╖╨░╤Ж╨╕╤П

```java
@Service
public class InstanceManager {
    
    public GameInstance createInstance(
        InstanceType type,
        String templateId,
        Difficulty difficulty,
        UUID partyId
    ) {
        // 1. ╨Т╤Л╨▒╤А╨░╤В╤М Game Server (load balancing)
        String serverId = selectOptimalServer();
        
        // 2. ╨б╨╛╨╖╨┤╨░╤В╤М instance
        GameInstance instance = new GameInstance();
        instance.setId(generateInstanceId());
        instance.setInstanceType(type);
        instance.setTemplateId(templateId);
        instance.setDifficulty(difficulty);
        instance.setServerId(serverId);
        instance.setPartyId(partyId);
        instance.setMaxPlayers(type.getMaxPlayers());
        instance.setExpiresAt(Instant.now().plus(Duration.ofHours(4)));
        
        // 3. ╨б╨╛╤Е╤А╨░╨╜╨╕╤В╤М
        instanceRepository.save(instance);
        
        // 4. ╨Ш╨╜╨╕╤Ж╨╕╨░╨╗╨╕╨╖╨╕╤А╨╛╨▓╨░╤В╤М ╨╜╨░ Game Server
        gameServerClient.initializeInstance(serverId, instance);
        
        // 5. ╨Ю╨┐╤Г╨▒╨╗╨╕╨║╨╛╨▓╨░╤В╤М ╤Б╨╛╨▒╤Л╤В╨╕╨╡
        eventBus.publish(new InstanceCreatedEvent(instance.getId(), partyId));
        
        return instance;
    }
    
    private String selectOptimalServer() {
        // Load balancing: ╨▓╤Л╨▒╤А╨░╤В╤М ╤Б╨╡╤А╨▓╨╡╤А ╤Б ╨╜╨░╨╕╨╝╨╡╨╜╤М╤И╨╡╨╣ ╨╜╨░╨│╤А╤Г╨╖╨║╨╛╨╣
        List<GameServerInstance> servers = serverRepository.findAllActive();
        
        return servers.stream()
            .min(Comparator.comparing(GameServerInstance::getCurrentLoad))
            .map(GameServerInstance::getId)
            .orElseThrow(() -> new NoAvailableServersException());
    }
}
```

---

## Database Schema ╨┤╨╗╤П Real-Time State

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `player_positions`

```sql
CREATE TABLE player_positions (
    player_id UUID PRIMARY KEY,
    
    -- ╨Я╨╛╨╖╨╕╤Ж╨╕╤П
    x DECIMAL(10,2) NOT NULL,
    y DECIMAL(10,2) NOT NULL,
    z DECIMAL(10,2) NOT NULL,
    
    -- Rotation
    yaw DECIMAL(6,2),
    pitch DECIMAL(6,2),
    roll DECIMAL(6,2),
    
    -- ╨Ч╨╛╨╜╨░
    zone_id VARCHAR(100) NOT NULL,
    server_id VARCHAR(100) NOT NULL,
    instance_id VARCHAR(100), -- ╨Ф╨╗╤П dungeons/raids
    
    -- ╨б╨╛╤Б╤В╨╛╤П╨╜╨╕╨╡
    is_moving BOOLEAN DEFAULT FALSE,
    is_in_combat BOOLEAN DEFAULT FALSE,
    current_animation VARCHAR(50),
    
    -- ╨Т╤А╨╡╨╝╨╡╨╜╨╜╨░╤П ╨╝╨╡╤В╨║╨░
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

**NOTE:** ╨Я╨╛╨╖╨╕╤Ж╨╕╨╕ ╤Е╤А╨░╨╜╤П╤В╤Б╤П ╨▓ ╨╛╤Б╨╜╨╛╨▓╨╜╨╛╨╝ ╨▓ Redis (╨┤╨╗╤П ╤Б╨║╨╛╤А╨╛╤Б╤В╨╕), ╨▓ PostgreSQL ╤В╨╛╨╗╤М╨║╨╛ ╨┤╨╗╤П persistence.

---

## Redis ╨┤╨╗╤П Real-Time State

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

**TTL:** 5 ╨╝╨╕╨╜╤Г╤В (╨╡╤Б╨╗╨╕ ╨╕╨│╤А╨╛╨║ disconnect - ╨░╨▓╤В╨╛╤Г╨┤╨░╨╗╨╡╨╜╨╕╨╡)

### Zone Players (Spatial Index)

**Key:** `zone_players:{zoneId}`

**Type:** Redis Geo Set

```redis
GEOADD zone_players:nightCity.watson 1234.56 5678.90 player-uuid-1
GEOADD zone_players:nightCity.watson 1200.00 5700.00 player-uuid-2

GEORADIUS zone_players:nightCity.watson 1234.56 5678.90 100 m
тЖТ Returns players within 100m
```

---

## Monitoring & Performance

### ╨Ь╨╡╤В╤А╨╕╨║╨╕ Game Server

```
gameserver.tick.duration_ms         - ╨Ф╨╗╨╕╤В╨╡╨╗╤М╨╜╨╛╤Б╤В╤М tick
gameserver.tick.rate                - ╨в╨╕╨║╨╕ ╨▓ ╤Б╨╡╨║╤Г╨╜╨┤╤Г
gameserver.players.active           - ╨Р╨║╤В╨╕╨▓╨╜╤Л╤Е ╨╕╨│╤А╨╛╨║╨╛╨▓
gameserver.zones.count              - ╨Ъ╨╛╨╗╨╕╤З╨╡╤Б╤В╨▓╨╛ ╨╖╨╛╨╜
gameserver.cpu.usage                - CPU usage
gameserver.memory.usage             - Memory usage
gameserver.network.bytes_sent       - ╨Ш╤Б╤Е╨╛╨┤╤П╤Й╨╕╨╣ ╤В╤А╨░╤Д╨╕╨║
gameserver.network.bytes_received   - ╨Т╤Е╨╛╨┤╤П╤Й╨╕╨╣ ╤В╤А╨░╤Д╨╕╨║
```

### Alerts

```
tick_duration > 50ms                - WARNING
tick_duration > 100ms               - CRITICAL (╨┐╨╡╤А╨╡╨│╤А╤Г╨╖╨║╨░)
players > 80% capacity              - WARNING (╨╜╤Г╨╢╨╜╨╛ ╨╝╨░╤Б╤И╤В╨░╨▒╨╕╤А╨╛╨▓╨░╨╜╨╕╨╡)
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
  тЖТ Scale up (add server)

If average_cpu < 30% for 30 minutes:
  тЖТ Scale down (remove server, migrate players)
```

---

## ╨б╨▓╤П╨╖╨░╨╜╨╜╤Л╨╡ ╨┤╨╛╨║╤Г╨╝╨╡╨╜╤В╤Л

- `.BRAIN/05-technical/backend/session-management-system.md` - Session management
- `.BRAIN/05-technical/backend/matchmaking-system.md` - Matchmaking
- `.BRAIN/05-technical/global-state-system.md` - Global state
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - Combat mechanics

---

## TODO

- [ ] Stress testing (╤Б╨║╨╛╨╗╤М╨║╨╛ concurrent players ╨╜╨░ ╨╛╨┤╨╕╨╜ ╤Б╨╡╤А╨▓╨╡╤А?)
- [ ] Lag compensation ╤В╨╡╤Б╤В╨╕╤А╨╛╨▓╨░╨╜╨╕╨╡ (different latencies 50-200ms)
- [ ] Cross-server zone migration (seamless transition)
- [ ] Disaster recovery (╨╡╤Б╨╗╨╕ Game Server ╨┐╨░╨┤╨░╨╡╤В)

---

## ╨Ш╤Б╤В╨╛╤А╨╕╤П ╨╕╨╖╨╝╨╡╨╜╨╡╨╜╨╕╨╣

- **v1.0.0 (2025-11-06 21:55)** - ╨б╨╛╨╖╨┤╨░╨╜ ╨┤╨╛╨║╤Г╨╝╨╡╨╜╤В Real-Time Server Architecture

