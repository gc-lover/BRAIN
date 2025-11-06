# Authentication System - Part 2: Authorization

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:12  
**Часть:** 2 из 2

[← Part 1](./part1-authentication.md) | [Навигация](./README.md)

---

## RBAC (Role-Based Access Control)

### Roles

```java
public enum Role {
    PLAYER,      // Regular player
    PREMIUM,     // Premium subscriber
    MODERATOR,   // Moderator
    ADMIN,       // Administrator
    DEVELOPER    // Developer access
}
```

### Permissions

```java
public enum Permission {
    // Player
    PLAY_GAME,
    CREATE_CHARACTER,
    TRADE_ITEMS,
    
    // Premium
    ACCESS_PREMIUM_FEATURES,
    CREATE_CLAN,
    
    // Moderator
    MODERATE_CHAT,
    BAN_PLAYER,
    VIEW_REPORTS,
    
    // Admin
    MANAGE_USERS,
    MANAGE_GAME_SETTINGS,
    VIEW_ANALYTICS,
    
    // Developer
    ACCESS_DEBUG_TOOLS,
    MODIFY_DATABASE
}
```

---

## Permission Checking

```java
@Service
public class AuthorizationService {
    
    public boolean hasPermission(User user, Permission permission) {
        Set<Permission> userPermissions = getRolePermissions(user.getRole());
        return userPermissions.contains(permission);
    }
    
    private Set<Permission> getRolePermissions(Role role) {
        return switch (role) {
            case PLAYER -> Set.of(
                Permission.PLAY_GAME,
                Permission.CREATE_CHARACTER,
                Permission.TRADE_ITEMS
            );
            case PREMIUM -> Set.of(
                Permission.PLAY_GAME,
                Permission.CREATE_CHARACTER,
                Permission.TRADE_ITEMS,
                Permission.ACCESS_PREMIUM_FEATURES,
                Permission.CREATE_CLAN
            );
            case MODERATOR -> Set.of(
                Permission.PLAY_GAME,
                Permission.MODERATE_CHAT,
                Permission.BAN_PLAYER,
                Permission.VIEW_REPORTS
            );
            case ADMIN -> Set.of(
                Permission.MANAGE_USERS,
                Permission.MANAGE_GAME_SETTINGS,
                Permission.VIEW_ANALYTICS,
                Permission.MODERATE_CHAT,
                Permission.BAN_PLAYER
            );
            case DEVELOPER -> Permission.all();
        };
    }
}
```

---

## Security Annotations

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresPermission {
    Permission[] value();
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresRole {
    Role[] value();
}
```

**Usage:**

```java
@RestController
@RequestMapping("/api/v1/admin")
public class AdminController {
    
    @RequiresRole(Role.ADMIN)
    @GetMapping("/users")
    public ResponseEntity<?> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }
    
    @RequiresPermission(Permission.BAN_PLAYER)
    @PostMapping("/ban/{userId}")
    public ResponseEntity<?> banUser(@PathVariable UUID userId) {
        userService.banUser(userId);
        return ResponseEntity.ok("User banned");
    }
}
```

---

## Security Interceptor

```java
@Component
public class AuthorizationInterceptor implements HandlerInterceptor {
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        HandlerMethod handlerMethod = (HandlerMethod) handler;
        
        // Check @RequiresRole
        RequiresRole requiresRole = handlerMethod.getMethodAnnotation(RequiresRole.class);
        if (requiresRole != null) {
            User user = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (!Arrays.asList(requiresRole.value()).contains(user.getRole())) {
                throw new AccessDeniedException("Insufficient role");
            }
        }
        
        // Check @RequiresPermission
        RequiresPermission requiresPermission = handlerMethod.getMethodAnnotation(RequiresPermission.class);
        if (requiresPermission != null) {
            User user = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (!authorizationService.hasAnyPermission(user, requiresPermission.value())) {
                throw new AccessDeniedException("Insufficient permissions");
            }
        }
        
        return true;
    }
}
```

---

## Rate Limiting

```java
@Component
public class RateLimitingService {
    
    private final Cache<String, Integer> requestCounts = CacheBuilder.newBuilder()
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .build();
    
    public boolean allowRequest(String userId, int maxRequests) {
        Integer count = requestCounts.getIfPresent(userId);
        
        if (count == null) {
            requestCounts.put(userId, 1);
            return true;
        }
        
        if (count >= maxRequests) {
            return false;  // Rate limit exceeded
        }
        
        requestCounts.put(userId, count + 1);
        return true;
    }
}
```

**Usage:**

```java
@PostMapping("/api/v1/quests/{questId}/complete")
public ResponseEntity<?> completeQuest(@PathVariable String questId) {
    User user = getCurrentUser();
    
    if (!rateLimitingService.allowRequest(user.getId().toString(), 10)) {
        return ResponseEntity.status(429).body("Too many requests");
    }
    
    questService.completeQuest(questId, user);
    return ResponseEntity.ok("Quest completed");
}
```

---

## IP Whitelisting (for Admin)

```java
@Configuration
public class SecurityConfig {
    
    @Value("${admin.allowed.ips}")
    private List<String> adminAllowedIPs;
    
    @Bean
    public FilterRegistrationBean<IPWhitelistFilter> ipWhitelistFilter() {
        FilterRegistrationBean<IPWhitelistFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new IPWhitelistFilter(adminAllowedIPs));
        registrationBean.addUrlPatterns("/api/v1/admin/*");
        return registrationBean;
    }
}
```

---

## Audit Logging

```java
@Entity
public class AuditLog {
    @Id
    private UUID id;
    
    private UUID userId;
    private String action;  // "LOGIN", "BAN_USER", "DELETE_CHARACTER"
    private String details;  // JSON
    private Timestamp timestamp;
    private String ipAddress;
}

@Service
public class AuditService {
    
    @Async
    public void logAction(User user, String action, String details) {
        AuditLog log = AuditLog.builder()
            .userId(user.getId())
            .action(action)
            .details(details)
            .timestamp(Instant.now())
            .ipAddress(getClientIP())
            .build();
        
        auditLogRepository.save(log);
    }
}
```

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:12) - Создан из authentication-authorization-system.md

