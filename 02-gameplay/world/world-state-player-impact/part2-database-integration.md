# World State Player Impact - Part 2: Database & Integration

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:55  
**Часть:** 2 из 2

[← Part 1](./part1-systems-mechanics.md) | [Навигация](./README.md)

---

## Database Schema

### player_world_state (Personal)

```sql
CREATE TABLE player_world_state (
  id UUID PRIMARY KEY,
  player_id UUID NOT NULL,
  state_key VARCHAR(100) NOT NULL, -- "npc_X_alive", "faction_Y_reputation"
  state_value JSONB NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  UNIQUE(player_id, state_key)
);
```

### server_world_state (Collective)

```sql
CREATE TABLE server_world_state (
  id UUID PRIMARY KEY,
  server_id VARCHAR(50) NOT NULL,
  state_key VARCHAR(100) NOT NULL,
  state_value JSONB NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  UNIQUE(server_id, state_key)
);
```

### faction_world_state (Factional)

```sql
CREATE TABLE faction_world_state (
  id UUID PRIMARY KEY,
  faction_id UUID NOT NULL,
  territory_id UUID NOT NULL,
  control_percentage INTEGER NOT NULL, -- 0-100
  influence_points BIGINT NOT NULL,
  timestamp TIMESTAMP NOT NULL
);
```

---

## API Endpoints

### Personal

```
GET  /api/v1/world-state/player/{playerId}
POST /api/v1/world-state/player/{playerId}/update
```

### Collective

```
GET  /api/v1/world-state/server/{serverId}
POST /api/v1/world-state/server/{serverId}/vote
GET  /api/v1/world-state/server/{serverId}/events
```

### Factional

```
GET  /api/v1/world-state/faction/{factionId}/territories
POST /api/v1/world-state/faction/{factionId}/influence
```

---

## Integration с Global State System

**Event Flow:**
1. Player action → Event generated
2. Event → Event Bus (Kafka)
3. Event Bus → World State Manager
4. World State Manager → Update appropriate layer(s)
5. World State Manager → Broadcast changes (WebSocket)

**Observers:**
- Quest System (observes personal state)
- Territory System (observes factional state)
- Event System (observes collective state)

---

## WebSocket Updates

**Real-time channels:**
- `/topic/player/{playerId}/world-state` - personal changes
- `/topic/server/{serverId}/world-state` - collective changes
- `/topic/faction/{factionId}/territories` - factional changes

---

## Performance Optimization

**Caching:**
- Personal state: Redis (5 min TTL)
- Collective state: Redis (1 min TTL)
- Factional state: Redis (10 min TTL)

**Indexing:**
```sql
CREATE INDEX idx_player_state_lookup ON player_world_state(player_id, state_key);
CREATE INDEX idx_server_state_lookup ON server_world_state(server_id, state_key);
```

---

## Связанные документы

- [Global State System](../../../05-technical/global-state-system/README.md)
- [Quest System](../../../04-narrative/quest-system.md)

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:55) - Создан из world-state-player-impact.md

