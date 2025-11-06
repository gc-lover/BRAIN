---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:40  
**api-readiness-notes:** Realtime Architecture микрофича. Game server instances, zone management, WebSocket connections. ~390 строк.
---

# Realtime Architecture - Архитектура real-time сервера

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:40  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Realtime server architecture  
**Размер:** ~390 строк ✅

---

## Краткое описание

**Realtime Architecture** - архитектура серверов real-time игровой логики.

**Ключевые возможности:**
- ✅ Game server instances (horizontal scaling)
- ✅ Zone/Instance management
- ✅ WebSocket connections (STOMP over WebSocket)
- ✅ Server discovery (service registry)

---

## Server Architecture

```
Player Client
    ↓ WebSocket
API Gateway (Load Balancer)
    ↓
Game Server Instance 1 (Zone: Watson)
Game Server Instance 2 (Zone: Westbrook)
Game Server Instance 3 (Dungeon: Tech_Vault)
    ↓
Redis (Session, Cache)
PostgreSQL (Persistent Data)
```

---

## Game Server Instance

```java
@Component
public class GameServerInstance {
    
    private final String serverId = UUID.randomUUID().toString();
    private final String region = "US-EAST";
    
    // Zones управляемые этим сервером
    private final Set<String> managedZones = new ConcurrentHashMap<>();
    
    // Active connections
    private final Map<UUID, WebSocketSession> connections = new ConcurrentHashMap<>();
    
    @PostConstruct
    public void register() {
        // Register в service registry
        ServerInfo info = new ServerInfo();
        info.setServerId(serverId);
        info.setRegion(region);
        info.setStatus(ServerStatus.ACTIVE);
        info.setPlayerCount(0);
        info.setMaxPlayers(5000);
        
        serviceRegistry.register(info);
        
        log.info("Game Server {} registered", serverId);
    }
    
    public void assignZone(String zoneId) {
        managedZones.add(zoneId);
        log.info("Server {} now managing zone {}", serverId, zoneId);
    }
    
    public boolean canAcceptPlayer() {
        return connections.size() < 5000;
    }
}
```

---

## Zone Management

```java
@Service
public class ZoneManager {
    
    // Zone → Server mapping
    private final Map<String, String> zoneServerMap = new ConcurrentHashMap<>();
    
    public String getServerForZone(String zoneId) {
        return zoneServerMap.computeIfAbsent(zoneId, this::assignZoneToServer);
    }
    
    private String assignZoneToServer(String zoneId) {
        // Найти наименее загруженный сервер
        List<ServerInfo> servers = serviceRegistry.getActiveServers();
        
        ServerInfo bestServer = servers.stream()
            .min(Comparator.comparingInt(ServerInfo::getPlayerCount))
            .orElseThrow(() -> new NoAvailableServersException());
        
        // Assign zone
        gameServerClient.assignZone(bestServer.getServerId(), zoneId);
        
        return bestServer.getServerId();
    }
    
    public void transferPlayer(UUID playerId, String fromZone, String toZone) {
        String fromServer = getServerForZone(fromZone);
        String toServer = getServerForZone(toZone);
        
        if (fromServer.equals(toServer)) {
            // Same server - instant transfer
            return;
        }
        
        // Cross-server transfer
        // 1. Save state на fromServer
        // 2. Load state на toServer
        // 3. Reconnect WebSocket
    }
}
```

---

## WebSocket Configuration

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
            .setAllowedOriginPatterns("*")
            .withSockJS();
    }
}

@Controller
public class GameWebSocketController {
    
    @MessageMapping("/game/move")
    @SendTo("/topic/zone/{zoneId}/players")
    public PlayerMovedMessage handlePlayerMove(
        @DestinationVariable String zoneId,
        @Payload MoveRequest request,
        Principal principal
    ) {
        UUID playerId = UUID.fromString(principal.getName());
        
        // Validate move
        if (!movementValidator.isValidMove(playerId, request.getPosition())) {
            throw new InvalidMoveException();
        }
        
        // Update position
        playerService.updatePosition(playerId, request.getPosition());
        
        // Broadcast to zone
        return new PlayerMovedMessage(playerId, request.getPosition());
    }
}
```

---

## Server Discovery (Eureka)

```yaml
# application.yml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    instance-id: ${spring.application.name}:${random.value}
    lease-renewal-interval-in-seconds: 5
    lease-expiration-duration-in-seconds: 10
```

---

## API Endpoints

**WS `/ws`** - WebSocket endpoint
**POST `/app/game/move`** - STOMP message (move)
**GET `/api/v1/servers/info`** - server info

---

## Связанные документы

- `.BRAIN/05-technical/backend/realtime/realtime-sync.md` - Sync (микрофича 2/3)
- `.BRAIN/05-technical/backend/realtime/realtime-optimization.md` - Optimization (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:40)** - Микрофича 1/3: Realtime Architecture (split from realtime-server-architecture.md)

