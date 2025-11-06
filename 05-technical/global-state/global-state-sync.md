---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:00  
**api-readiness-notes:** Global State Sync микрофича. MMORPG sync, conflict resolution, persistence, event replay, versioning. ~450 строк.
---

# Global State Sync - Синхронизация и персистентность

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 06:00  
**Приоритет:** КРИТИЧЕСКИЙ  
**Автор:** AI Brain Manager

**Микрофича:** Synchronization & Persistence  
**Размер:** ~450 строк ✅  
**API Task:** API-TASK-074 (api/v1/technical/global-state.yaml)

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-173](../../../API-SWAGGER/tasks/active/queue/task-173-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: GLOBAL_STATE_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Краткое описание

**Global State Sync** - синхронизация состояния между игроками (MMORPG).

**Ключевые возможности:**
- ✅ MMORPG Synchronization (3 модели)
- ✅ Conflict Resolution (4 стратегии)
- ✅ Persistence Strategy (WAL)
- ✅ Event Replay
- ✅ State Versioning (optimistic locking)
- ✅ Real-Time Sync (WebSocket)

---

## Модели синхронизации

### 1. Server-Wide State

**Что:**
- World state (территории, фракции)
- NPC fates (судьбы важных NPC)
- Economy state (цены, доступность)
- Global events

**Характеристики:**
- Все игроки видят одинаково
- Изменения применяются глобально
- Синхронизация через WebSocket
- Eventual consistency

### 2. Player-Specific State

**Что:**
- Quest progress
- Player flags
- Inventory
- Attributes и skills

**Характеристики:**
- Каждый игрок видит свое
- Изменения локальные
- Синхронизация только для владельца
- Strong consistency

### 3. Phased State

**Что:**
- Квестовые фазы (разные игроки видят разные версии NPC)
- Персональные изменения мира
- Instance-based content

**Характеристики:**
- Игроки в разных фазах видят разное
- Используется для сюжетных квестов
- Сложнее в реализации

---

## Conflict Resolution

### 1. Last Write Wins

```
Player A: Territory.watson = "Arasaka" (21:00:00)
Player B: Territory.watson = "Militech" (21:00:01)
→ Result: Militech (последняя запись)

❌ Может потерять важные изменения
```

### 2. Voting System

```
Player A: Vote "Arasaka"
Player B: Vote "Militech"
... 1000 игроков голосуют ...
→ Count votes
→ Result: Majority wins

✅ Для мировых событий и NPC fates
```

### 3. Event Versioning

```
Current Version: 100
Event A: expects v100 → accepted, v101
Event B: expects v100 → rejected (stale)
Event B': retry with v101 → accepted, v102

✅ Для критичных операций
```

### 4. Merge Strategy

```
State: Territory.watson.controlStrength = 50
Event A: +10 (attack) → 60
Event B: +5 (defense) → 55
→ Merge: SUM(+10, +5) = 65

✅ Для накопительных изменений
```

---

## Persistence Strategy

### Write-Ahead Log (WAL)

**Концепция:**
1. Событие записывается в Event Store (append-only log)
2. Затем применяется к State Store
3. Если State Store упадет → восстановление из Event Store

**Гарантии:**
- Events are NEVER lost
- State can ALWAYS be reconstructed
- Full audit trail

### Transactional Outbox Pattern

```sql
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
```

**Процесс:**
```sql
BEGIN TRANSACTION;
    -- 1. Записать событие в outbox
    INSERT INTO event_outbox (event_id, event_type, event_data, state_changes)
    VALUES (...);
    
    -- 2. Обновить state (в той же транзакции)
    UPDATE global_state SET ... WHERE state_key = ...;
COMMIT;

-- 3. Отдельный процесс публикует события из outbox
```

### Idempotency

```java
@Transactional
public void processEvent(GameEvent event) {
    // 1. Проверить, было ли событие уже обработано
    if (processedEventRepository.exists(event.getEventId())) {
        return; // Идемпотентность
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

```sql
CREATE TABLE processed_events (
    event_id UUID PRIMARY KEY,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processor_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Периодическая очистка (старше 30 дней)
DELETE FROM processed_events WHERE created_at < NOW() - INTERVAL '30 days';
```

---

## Event Replay

### Use Cases

**1. Восстановление после сбоя:**
```
State Store corrupted
→ Replay all events
→ Reconstruct state
```

**2. Миграция данных:**
```
Изменение структуры state
→ Replay events with new handlers
→ Transform to new format
```

**3. Тестирование:**
```
Тестирование feature
→ Replay production events
→ Test new logic
```

**4. Аналитика:**
```
Анализ поведения
→ Replay events для игрока
→ Получить insights
```

### Replay Engine

```java
@Service
public class EventReplayEngine {
    
    public void replayAll(String serverId, Instant from, Instant to) {
        int batchSize = 1000;
        long offset = 0;
        
        while (true) {
            List<GameEvent> events = eventRepository.findByServerAndTimeRange(
                serverId, from, to, offset, batchSize
            );
            
            if (events.isEmpty()) break;
            
            for (GameEvent event : events) {
                try {
                    replayEvent(event);
                } catch (Exception e) {
                    log.error("Error replaying event {}", event.getEventId());
                }
            }
            
            offset += batchSize;
        }
    }
    
    private void replayEvent(GameEvent event) {
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

## State Versioning

### Optimistic Locking

```java
@Transactional
public void updateStateWithVersion(
    String stateKey,
    Object newValue,
    int expectedVersion
) {
    GlobalState state = stateRepository.findByKeyForUpdate(stateKey);
    
    if (state.getVersion() != expectedVersion) {
        throw new OptimisticLockException(
            "State version mismatch: expected " + expectedVersion + 
            ", actual " + state.getVersion()
        );
    }
    
    state.setValue(newValue);
    state.setVersion(state.getVersion() + 1);
    stateRepository.save(state);
}
```

**SQL Level:**
```sql
UPDATE global_state
SET 
    state_value = :newValue,
    version = version + 1,
    updated_at = NOW()
WHERE 
    state_key = :stateKey
    AND version = :expectedVersion;
```

---

## Real-Time Synchronization

### WebSocket Channels

```typescript
// Player channel
ws://api.necpgame.com/ws/player/{playerId}
Events:
- player.level.changed
- player.quest.updated
- player.inventory.changed

// World channel
ws://api.necpgame.com/ws/world/{serverId}
Events:
- world.territory.captured
- world.npc.fate.changed
- world.faction.power.changed

// Economy channel
ws://api.necpgame.com/ws/economy/{serverId}
Events:
- economy.price.changed
- economy.auction.bid

// Combat channel
ws://api.necpgame.com/ws/combat/{sessionId}
Events:
- combat.damage.dealt
- combat.player.died
```

### Message Format

```json
{
  "messageType": "STATE_CHANGED",
  "timestamp": "2025-11-07T06:00:00Z",
  "serverId": "server-01",
  "stateChange": {
    "category": "WORLD",
    "stateKey": "world.territory.watson.controller",
    "previousValue": "Militech",
    "newValue": "Arasaka",
    "version": 1523
  },
  "eventId": "uuid",
  "affectedPlayers": 3800
}
```

### Broadcasting

```java
// Targeted
webSocketService.sendToPlayers(event.getAffectedPlayers(), message);

// Regional
webSocketService.sendToRegion("nightCity.watson", message);

// Server-wide
webSocketService.sendToServer(serverId, message);

// Selective
webSocketService.sendWhere(
    player -> player.getLocation().startsWith("nightCity"),
    message
);
```

---

## API Endpoints

**WS `/ws/player/{playerId}`** - player updates
**WS `/ws/world/{serverId}`** - world updates
**POST `/api/v1/events/replay`** - replay events (admin)

---

## Связанные документы

- `.BRAIN/05-technical/global-state/global-state-core.md` - Core (микрофича 1/5)
- `.BRAIN/05-technical/global-state/global-state-events.md` - Events (микрофича 2/5)
- `.BRAIN/05-technical/global-state/global-state-management.md` - Management (микрофича 3/5)
- `.BRAIN/05-technical/global-state/global-state-operations.md` - Operations (микрофича 5/5)

---

## История изменений

- **v1.0.0 (2025-11-07 06:00)** - Микрофича 4/5: Global State Sync (split from global-state-system.md)

