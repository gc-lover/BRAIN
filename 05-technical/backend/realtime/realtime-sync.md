---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:40  
**api-readiness-notes:** Realtime Sync микрофича. Position sync, tick rate, interpolation, lag compensation. ~390 строк.
---

# Realtime Sync - Синхронизация состояния

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:40  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Player position synchronization  
**Размер:** ~390 строк ✅

---

## Краткое описание

**Realtime Sync** - синхронизация позиций игроков и состояния мира.

**Ключевые возможности:**
- ✅ Position synchronization (20 ticks/sec)
- ✅ Client-side prediction
- ✅ Server reconciliation
- ✅ Lag compensation
- ✅ Interpolation

---

## Tick System

```java
@Scheduled(fixedRate = 50) // 20 ticks/sec
public void gameTick() {
    long tickStart = System.currentTimeMillis();
    
    // 1. Process player inputs
    processInputs();
    
    // 2. Update world state
    updateWorldState();
    
    // 3. Detect collisions
    detectCollisions();
    
    // 4. Broadcast updates
    broadcastWorldState();
    
    long tickDuration = System.currentTimeMillis() - tickStart;
    if (tickDuration > 50) {
        log.warn("Tick overrun: {}ms", tickDuration);
    }
}
```

---

## Position Synchronization

```java
@MessageMapping("/game/move")
public void handlePlayerMove(
    @Payload MoveRequest request,
    Principal principal
) {
    UUID playerId = UUID.fromString(principal.getName());
    
    // Client-side prediction: client отправляет предполагаемую позицию
    Vector3 clientPosition = request.getPosition();
    long clientTick = request.getTick();
    
    // Server reconciliation
    PlayerState serverState = getPlayerState(playerId);
    Vector3 serverPosition = serverState.getPosition();
    
    float distance = Vector3.distance(clientPosition, serverPosition);
    
    if (distance > MAX_DESYNC_THRESHOLD) {
        // Слишком большая рассинхронизация - force correct
        wsService.sendToPlayer(playerId, 
            new ForcePositionMessage(serverPosition, serverState.getTick()));
        return;
    }
    
    // Принять позицию клиента
    serverState.setPosition(clientPosition);
    serverState.setTick(clientTick);
    
    // Broadcast to nearby players (AoI - Area of Interest)
    List<UUID> nearbyPlayers = locationService.getPlayersNearby(clientPosition, 100);
    wsService.broadcastToPlayers(nearbyPlayers,
        new PlayerMovedMessage(playerId, clientPosition, clientTick));
}
```

---

## Client-Side Prediction

```typescript
// Frontend (TypeScript)
class MovementPredictor {
    private pendingMoves: MoveInput[] = [];
    
    applyInput(input: MoveInput) {
        // Apply locally
        this.localPlayer.position.add(input.direction);
        
        // Store для reconciliation
        this.pendingMoves.push(input);
        
        // Send to server
        this.ws.send({
            type: 'MOVE',
            position: this.localPlayer.position,
            tick: this.currentTick,
            inputId: input.id
        });
    }
    
    reconcile(serverState: PlayerState) {
        // Remove acknowledged inputs
        this.pendingMoves = this.pendingMoves.filter(
            move => move.tick > serverState.tick
        );
        
        // Reset to server position
        this.localPlayer.position = serverState.position;
        
        // Re-apply pending inputs
        for (const move of this.pendingMoves) {
            this.localPlayer.position.add(move.direction);
        }
    }
}
```

---

## Lag Compensation

```java
public boolean isHit(UUID shooterId, UUID targetId, Vector3 aimPosition, long clientTick) {
    // Shooter видел target 100ms назад (RTT = 100ms)
    // Rollback target position на 100ms назад
    
    long rtt = getRTT(shooterId);
    long compensationTime = rtt / 2; // 50ms
    
    // Найти историческую позицию target
    Vector3 historicPosition = positionHistory.getPosition(
        targetId,
        clientTick - compensationTime
    );
    
    // Проверить попадание
    return Physics.raycast(aimPosition, historicPosition, hitboxRadius);
}

// Position History (circular buffer)
private static class PositionHistory {
    private final Map<UUID, CircularBuffer<PositionSnapshot>> history = new ConcurrentHashMap<>();
    
    public void record(UUID playerId, Vector3 position, long tick) {
        history.computeIfAbsent(playerId, k -> new CircularBuffer<>(60)) // 60 ticks = 3 sec
            .add(new PositionSnapshot(position, tick));
    }
    
    public Vector3 getPosition(UUID playerId, long tick) {
        CircularBuffer<PositionSnapshot> buffer = history.get(playerId);
        if (buffer == null) return null;
        
        // Найти ближайший snapshot
        return buffer.stream()
            .min(Comparator.comparingLong(s -> Math.abs(s.tick - tick)))
            .map(s -> s.position)
            .orElse(null);
    }
}
```

---

## Interpolation (Frontend)

```typescript
class PositionInterpolator {
    interpolate(from: Vector3, to: Vector3, alpha: number): Vector3 {
        return {
            x: from.x + (to.x - from.x) * alpha,
            y: from.y + (to.y - from.y) * alpha,
            z: from.z + (to.z - from.z) * alpha
        };
    }
    
    render() {
        const now = Date.now();
        const renderTime = now - 100; // 100ms interpolation delay
        
        for (const player of this.otherPlayers) {
            const [prev, next] = player.getSnapshots(renderTime);
            
            if (!prev || !next) continue;
            
            const alpha = (renderTime - prev.time) / (next.time - prev.time);
            player.renderPosition = this.interpolate(prev.position, next.position, alpha);
        }
    }
}
```

---

## API Endpoints

**WS `/app/game/move`** - move player
**WS `/topic/zone/{zoneId}/players`** - player updates

---

## Связанные документы

- `.BRAIN/05-technical/backend/realtime/realtime-architecture.md` - Architecture (микрофича 1/3)
- `.BRAIN/05-technical/backend/realtime/realtime-optimization.md` - Optimization (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:40)** - Микрофича 2/3: Realtime Sync (split from realtime-server-architecture.md)

