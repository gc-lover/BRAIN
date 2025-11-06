---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:40  
**api-readiness-notes:** Realtime Optimization микрофича. Bandwidth optimization, AoI filtering, compression. ~380 строк.
---

# Realtime Optimization - Оптимизация производительности

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:40  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Performance optimization  
**Размер:** ~380 строк ✅

---

## Краткое описание

**Realtime Optimization** - оптимизация пропускной способности и производительности.

**Ключевые возможности:**
- ✅ Bandwidth optimization (delta compression)
- ✅ Area of Interest (AoI) filtering
- ✅ Message batching
- ✅ Binary protocol (MessagePack)

---

## Bandwidth Optimization

### Delta Compression

```java
public PlayerUpdateMessage createDeltaUpdate(PlayerState previous, PlayerState current) {
    PlayerUpdateMessage delta = new PlayerUpdateMessage();
    delta.setPlayerId(current.getPlayerId());
    
    // Только изменившиеся поля
    if (!previous.getPosition().equals(current.getPosition())) {
        delta.setPosition(current.getPosition());
    }
    
    if (previous.getHealth() != current.getHealth()) {
        delta.setHealth(current.getHealth());
    }
    
    if (!previous.getRotation().equals(current.getRotation())) {
        delta.setRotation(current.getRotation());
    }
    
    return delta;
}
```

### Quantization

```java
// Reduce precision для экономии bandwidth
public short quantizePosition(float value) {
    // Map float [-1000, 1000] → short [-32768, 32767]
    return (short) (value / 1000.0f * 32767);
}

public float dequantizePosition(short value) {
    return (value / 32767.0f) * 1000.0f;
}
```

---

## Area of Interest (AoI)

```java
@Service
public class AoIManager {
    
    private static final float AOI_RADIUS = 100.0f; // meters
    
    public List<UUID> getPlayersInAoI(UUID playerId) {
        PlayerState player = getPlayerState(playerId);
        Vector3 position = player.getPosition();
        String zoneId = player.getZoneId();
        
        // Spatial grid lookup (O(1))
        return spatialGrid.query(zoneId, position, AOI_RADIUS);
    }
    
    public void broadcastToAoI(UUID senderId, GameMessage message) {
        List<UUID> recipients = getPlayersInAoI(senderId);
        
        // Exclude sender
        recipients.remove(senderId);
        
        wsService.broadcastToPlayers(recipients, message);
    }
}

// Spatial Grid для быстрого поиска
public class SpatialGrid {
    private final float cellSize = 50.0f; // 50x50m cells
    private final Map<String, Map<GridCell, Set<UUID>>> grids = new ConcurrentHashMap<>();
    
    public void updatePlayerCell(UUID playerId, String zoneId, Vector3 position) {
        GridCell cell = getCell(position);
        
        Map<GridCell, Set<UUID>> grid = grids.computeIfAbsent(
            zoneId, k -> new ConcurrentHashMap<>()
        );
        
        // Remove from old cell
        removeFromAllCells(playerId, grid);
        
        // Add to new cell
        grid.computeIfAbsent(cell, k -> ConcurrentHashMap.newKeySet())
            .add(playerId);
    }
    
    public List<UUID> query(String zoneId, Vector3 position, float radius) {
        Map<GridCell, Set<UUID>> grid = grids.get(zoneId);
        if (grid == null) return List.of();
        
        // Check surrounding cells
        List<GridCell> cells = getSurroundingCells(position, radius);
        
        return cells.stream()
            .flatMap(cell -> grid.getOrDefault(cell, Set.of()).stream())
            .collect(Collectors.toList());
    }
}
```

---

## Message Batching

```java
@Scheduled(fixedRate = 50) // 20 times/sec
public void flushBatchedMessages() {
    for (UUID playerId : pendingMessages.keySet()) {
        List<GameMessage> messages = pendingMessages.remove(playerId);
        
        if (messages == null || messages.isEmpty()) {
            continue;
        }
        
        // Batch messages
        BatchMessage batch = new BatchMessage(messages);
        wsService.sendToPlayer(playerId, batch);
    }
}

public void queueMessage(UUID playerId, GameMessage message) {
    pendingMessages.computeIfAbsent(playerId, k -> new CopyOnWriteArrayList<>())
        .add(message);
}
```

---

## Binary Protocol (MessagePack)

```java
@Configuration
public class MessagePackConfig {
    
    @Bean
    public MessageConverter messageConverter() {
        // Use MessagePack instead of JSON
        return new MessagePackMessageConverter();
    }
}

// Example: JSON vs MessagePack
// JSON: {"playerId":"abc-123","position":{"x":100.5,"y":50.0,"z":200.3}}  (72 bytes)
// MessagePack: Binary format (35 bytes)  → 51% reduction!
```

---

## Update Frequency Scaling

```java
public int getUpdateFrequency(float distance) {
    // Near: 20 updates/sec
    // Medium (50m): 10 updates/sec
    // Far (100m): 5 updates/sec
    
    if (distance < 50) {
        return 50; // ms (20/sec)
    } else if (distance < 100) {
        return 100; // ms (10/sec)
    } else {
        return 200; // ms (5/sec)
    }
}
```

---

## API Endpoints

**WS `/topic/zone/{zoneId}/aoi`** - AoI updates

---

## Связанные документы

- `.BRAIN/05-technical/backend/realtime/realtime-architecture.md` - Architecture (микрофича 1/3)
- `.BRAIN/05-technical/backend/realtime/realtime-sync.md` - Sync (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:40)** - Микрофича 3/3: Realtime Optimization (split from realtime-server-architecture.md)

