# Performance Tuning Guide: Quest System

**Версия:** 1.0.0  
**Дата:** 2025-11-07 00:44  
**Для:** Backend разработчиков, DevOps

**api-readiness:** not-applicable

---

## Краткое описание

Руководство по оптимизации производительности системы квестового графа для AAA MMORPG (1М+ concurrent users).

---

## 🎯 PERFORMANCE TARGETS

### Целевые метрики

| Операция | Target | Acceptable | Critical |
|----------|--------|------------|----------|
| Get available quests | < 100ms | < 200ms | > 500ms |
| Quest details | < 50ms | < 100ms | > 200ms |
| Process choice | < 200ms | < 500ms | > 1000ms |
| World state vote | < 100ms | < 200ms | > 500ms |
| WebSocket notification | < 10ms | < 50ms | > 100ms |

### Нагрузка

- **Concurrent users:** 1,000,000+
- **Requests/second:** 10,000+
- **DB connections:** 100-200
- **Redis connections:** 50-100
- **Response time 95th percentile:** < 200ms

---

## 🚀 TIER 1: Database Optimization

### 1.1 Индексы (критично!)

```sql
-- ОБЯЗАТЕЛЬНЫЕ индексы (уже в миграциях)
CREATE INDEX idx_quests_era_level ON quests(era, min_level, max_level);
CREATE INDEX idx_quests_type_active ON quests(type, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_player_flags_character_key ON player_flags(character_id, flag_key);

-- ДОПОЛНИТЕЛЬНЫЕ для production
CREATE INDEX idx_quest_progress_character_status 
ON quest_progress(character_id, status) 
WHERE status IN ('ACTIVE', 'COMPLETED');

CREATE INDEX idx_quest_branches_quest_conditions 
ON quest_branches(quest_id) 
INCLUDE (conditions, sets_flags);

CREATE INDEX idx_dialogue_nodes_quest_type 
ON dialogue_nodes(quest_id, node_type);

-- GIN индексы для JSONB (поиск внутри JSON)
CREATE INDEX idx_quests_tags_gin ON quests USING GIN(tags);
CREATE INDEX idx_quests_required_flags_gin ON quests USING GIN(required_flags);
CREATE INDEX idx_player_flags_value_gin ON player_flags USING GIN(flag_value);
```

**Impact:** 10x-100x ускорение queries

### 1.2 Партиционирование (для больших таблиц)

```sql
-- Партиционирование player_quest_choices по времени
CREATE TABLE player_quest_choices (
    id UUID PRIMARY KEY,
    character_id UUID NOT NULL,
    quest_id VARCHAR(100) NOT NULL,
    chosen_at TIMESTAMP NOT NULL,
    -- ...
) PARTITION BY RANGE (chosen_at);

-- Партиции по месяцам
CREATE TABLE player_quest_choices_2025_01 PARTITION OF player_quest_choices
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE player_quest_choices_2025_02 PARTITION OF player_quest_choices
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- И так далее...
```

**Impact:** 5x-10x для audit queries

### 1.3 Materialized Views (для часто запрашиваемых данных)

```sql
-- Кэш доступных квестов по уровням
CREATE MATERIALIZED VIEW available_quests_by_level AS
SELECT 
    min_level,
    max_level,
    array_agg(id) as quest_ids,
    COUNT(*) as quest_count
FROM quests
WHERE is_active = TRUE
GROUP BY min_level, max_level;

CREATE INDEX ON available_quests_by_level(min_level, max_level);

-- Обновлять раз в час
REFRESH MATERIALIZED VIEW CONCURRENTLY available_quests_by_level;
```

**Impact:** 20x для quest filtering

### 1.4 Connection Pooling

```yaml
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 200        # Для 1M users
      minimum-idle: 20
      connection-timeout: 30000     # 30 seconds
      idle-timeout: 600000          # 10 minutes
      max-lifetime: 1800000         # 30 minutes
      leak-detection-threshold: 60000  # Detect leaks
```

**Impact:** Stable under high load

---

## 🚀 TIER 2: Application Layer Optimization

### 2.1 Caching Strategy (Redis)

**Quest Graph (долгий TTL):**

```java
@Cacheable(value = "questGraph", key = "#questId", unless = "#result == null")
public Quest getQuest(String questId) {
    return questRepository.findById(questId).orElseThrow();
}

// Config
@Bean
public RedisCacheConfiguration questGraphCacheConfig() {
    return RedisCacheConfiguration.defaultCacheConfig()
        .entryTtl(Duration.ofHours(24))  // 24 часа - quest data меняется редко
        .disableCachingNullValues();
}
```

**World State (короткий TTL):**

```java
@Cacheable(value = "worldState", key = "#serverId + ':' + #stateKey")
public ServerWorldState getServerState(String serverId, String stateKey) {
    return serverStateRepository.findByServerAndKey(serverId, stateKey).orElse(null);
}

// Config
@Bean
public RedisCacheConfiguration worldStateCacheConfig() {
    return RedisCacheConfiguration.defaultCacheConfig()
        .entryTtl(Duration.ofMinutes(5))  // 5 минут - state меняется часто
        .disableCachingNullValues();
}
```

**Player Flags (session-based):**

```java
// Кэшировать в HTTP session, не Redis
@Service
@Scope(value = "session", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class PlayerSessionCache {
    private Map<String, Object> flags = new ConcurrentHashMap<>();
    
    public Object getFlag(String key) {
        return flags.computeIfAbsent(key, k -> loadFromDB(k));
    }
}
```

**Impact:** 50x-100x для repeated requests

### 2.2 Query Optimization

**N+1 Problem fix:**

```java
// ПЛОХО - N+1 queries
List<Quest> quests = questRepository.findAll();  // 1 query
for (Quest q : quests) {
    q.getBranches().size();  // N queries!
}

// ХОРОШО - одиn query с JOIN FETCH
@Query("SELECT DISTINCT q FROM Quest q LEFT JOIN FETCH q.branches WHERE q.era = :era")
List<Quest> findByEraWithBranches(@Param("era") String era);
```

**Batch loading:**

```java
@Entity
public class Quest {
    @OneToMany(fetch = FetchType.LAZY)
    @BatchSize(size = 20)  // Загружать по 20 за раз
    private List<QuestBranch> branches;
}
```

**Projections (только нужные поля):**

```java
// Вместо полного Quest entity
public interface QuestSummaryProjection {
    String getId();
    String getName();
    String getType();
    Integer getMinLevel();
}

@Query("SELECT q FROM Quest q WHERE q.era = :era")
List<QuestSummaryProjection> findSummariesByEra(@Param("era") String era);
```

**Impact:** 5x-10x для list operations

### 2.3 Async Processing

**Для non-critical операций:**

```java
@Service
public class AsyncQuestService {
    
    @Async
    public CompletableFuture<Void> savePlayerChoice(UUID characterId, 
                                                     String questId, 
                                                     String choiceId) {
        // Audit trail - можно async
        PlayerQuestChoice choice = new PlayerQuestChoice();
        choice.setCharacterId(characterId);
        choice.setQuestId(questId);
        choice.setChoiceId(choiceId);
        choiceRepository.save(choice);
        
        return CompletableFuture.completedFuture(null);
    }
}
```

**Config:**

```java
@Configuration
@EnableAsync
public class AsyncConfig {
    
    @Bean
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(50);
        executor.setQueueCapacity(1000);
        executor.setThreadNamePrefix("async-quest-");
        executor.initialize();
        return executor;
    }
}
```

**Impact:** Не блокирует main thread

---

## 🚀 TIER 3: Advanced Optimization

### 3.1 Quest Graph Preprocessing

**Вместо загрузки всего графа - строить lookup tables:**

```java
@Service
public class QuestGraphService {
    
    // Вместо полного графа
    private Map<String, List<String>> questDependencies;  // questId → prerequisites
    private Map<String, List<String>> questUnlocks;       // questId → unlocks
    private Map<String, List<String>> questBlocks;        // questId → blocks
    
    @PostConstruct
    public void buildLookupTables() {
        QuestGraphData data = loadGraphData();
        
        questDependencies = data.getEdges().stream()
            .filter(e -> e.getType().equals("requires"))
            .collect(Collectors.groupingBy(
                QuestEdge::getTo,
                Collectors.mapping(QuestEdge::getFrom, Collectors.toList())
            ));
        
        questUnlocks = data.getEdges().stream()
            .filter(e -> e.getType().equals("unlocks"))
            .collect(Collectors.groupingBy(
                QuestEdge::getFrom,
                Collectors.mapping(QuestEdge::getTo, Collectors.toList())
            ));
        
        // Аналогично для blocks
    }
    
    // Теперь lookup O(1) вместо graph traversal O(N)
    public List<String> getPrerequisites(String questId) {
        return questDependencies.getOrDefault(questId, Collections.emptyList());
    }
}
```

**Impact:** 100x для dependency checks

### 3.2 Read Replicas (для масштабирования)

```yaml
# application.yml
spring:
  datasource:
    master:
      url: jdbc:postgresql://master:5432/necpgame
    replica:
      url: jdbc:postgresql://replica:5432/necpgame
```

```java
// Read from replica, write to master
@Configuration
public class DataSourceConfig {
    
    @Bean
    @Primary
    public DataSource dataSource() {
        return new LazyConnectionDataSourceProxy(routingDataSource());
    }
    
    @Bean
    public DataSource routingDataSource() {
        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put(DatabaseType.MASTER, masterDataSource());
        targetDataSources.put(DatabaseType.REPLICA, replicaDataSource());
        
        ReplicationRoutingDataSource routingDataSource = new ReplicationRoutingDataSource();
        routingDataSource.setTargetDataSources(targetDataSources);
        routingDataSource.setDefaultTargetDataSource(masterDataSource());
        
        return routingDataSource;
    }
}

// Use @Transactional(readOnly = true) для reads
@Transactional(readOnly = true)
public List<Quest> getAvailableQuests(UUID characterId) {
    // Пойдёт на replica
}
```

**Impact:** 2x-5x read capacity

### 3.3 Database Sharding (для 1М+ users)

**Shard by character_id:**

```java
// Shard function
public String getShardId(UUID characterId) {
    // Hash-based sharding
    int hash = Math.abs(characterId.hashCode());
    int shardNumber = hash % TOTAL_SHARDS;  // e.g. 10 shards
    return "shard-" + shardNumber;
}

// Route queries to correct shard
public Quest getQuest(UUID characterId, String questId) {
    String shardId = getShardId(characterId);
    DataSource dataSource = getDataSourceForShard(shardId);
    
    // Query on specific shard
}
```

**Impact:** Linear scalability

### 3.4 Denormalization (для hot paths)

**Кэш часто используемых данных в quest table:**

```sql
-- Добавить denormalized поля
ALTER TABLE quests ADD COLUMN prerequisite_count INTEGER;
ALTER TABLE quests ADD COLUMN unlocks_count INTEGER;
ALTER TABLE quests ADD COLUMN average_completion_time INTEGER;  -- В минутах

-- Update triggers
CREATE OR REPLACE FUNCTION update_quest_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update denormalized stats
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Impact:** Избегает JOINs

---

## 🚀 TIER 4: Caching Strategies

### 4.1 Multi-Layer Cache

```
Request → L1 (HTTP session) → L2 (Redis) → L3 (DB)
```

**L1 - Session Cache:**

```java
@Component
@Scope(value = "session", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class SessionCache {
    private Map<String, Quest> questCache = new ConcurrentHashMap<>();
    private Map<String, Boolean> availabilityCache = new ConcurrentHashMap<>();
    
    public Quest getQuest(String questId) {
        return questCache.computeIfAbsent(questId, this::loadFromRedis);
    }
}
```

**L2 - Redis Cache (показан выше)**

**L3 - Database**

**Impact:** 1000x для repeated requests в session

### 4.2 Cache Warming

**Pre-load популярных квестов:**

```java
@Component
public class CacheWarmer {
    
    @Scheduled(fixedRate = 3600000)  // Каждый час
    public void warmCache() {
        log.info("Warming quest cache...");
        
        // Load top 100 most popular quests
        List<String> popularQuests = getPopularQuestIds();
        
        for (String questId : popularQuests) {
            questGraphService.getQuest(questId);  // Loads into cache
        }
        
        log.info("Cache warmed: {} quests", popularQuests.size());
    }
}
```

**Impact:** Faster first requests

### 4.3 Cache Invalidation Strategy

```java
@Service
public class QuestCacheManager {
    
    @Autowired
    private CacheManager cacheManager;
    
    // Invalidate when quest updated
    @CacheEvict(value = "questGraph", key = "#questId")
    public void invalidateQuest(String questId) {
        log.debug("Cache invalidated: quest={}", questId);
    }
    
    // Invalidate related quests
    public void invalidateQuestChain(String questId) {
        List<String> relatedQuests = getRelatedQuests(questId);
        for (String related : relatedQuests) {
            invalidateQuest(related);
        }
    }
    
    // Smart invalidation
    public void onQuestCompleted(UUID characterId, String questId) {
        // Invalidate только affected quests
        List<String> unlockedQuests = getUnlockedBy(questId);
        for (String unlocked : unlockedQuests) {
            invalidateQuest(unlocked);
        }
    }
}
```

---

## 🚀 TIER 5: Query Optimization

### 5.1 Batch Operations

**Вместо:**

```java
// ПЛОХО - N queries
for (String questId : questIds) {
    Quest quest = questRepository.findById(questId).get();
    // Process
}
```

**Используйте:**

```java
// ХОРОШО - 1 query
List<Quest> quests = questRepository.findAllById(questIds);
Map<String, Quest> questMap = quests.stream()
    .collect(Collectors.toMap(Quest::getId, Function.identity()));

for (String questId : questIds) {
    Quest quest = questMap.get(questId);
    // Process
}
```

### 5.2 Projection для списков

```java
// Вместо полного Quest объекта
interface QuestListProjection {
    String getId();
    String getName();
    String getType();
    Integer getMinLevel();
    // Только нужные поля!
}

@Query("SELECT q.id as id, q.name as name, q.type as type, q.minLevel as minLevel " +
       "FROM Quest q WHERE q.era = :era")
List<QuestListProjection> findProjectionsByEra(@Param("era") String era);
```

**Impact:** 3x-5x меньше данных

### 5.3 Pagination

```java
// Для больших списков
@GetMapping("/available")
public ResponseEntity<Page<QuestSummary>> getAvailableQuests(
        @RequestParam UUID characterId,
        @PageableDefault(size = 20, sort = "minLevel") Pageable pageable) {
    
    Page<QuestSummary> quests = questGraphService.getAvailableQuests(characterId, pageable);
    return ResponseEntity.ok(quests);
}
```

**Impact:** Constant memory usage

---

## 🚀 TIER 6: World State Optimization

### 6.1 Vote Aggregation

**Вместо обновления на каждый голос:**

```java
// Batch votes
@Scheduled(fixedRate = 60000)  // Каждую минуту
public void processVoteBatch() {
    List<ServerWorldState> pendingStates = serverStateRepository
        .findByStatus(StateStatus.PENDING);
    
    for (ServerWorldState state : pendingStates) {
        int totalWeight = voteRepository.sumWeightByServerAndKey(
            state.getServerId(), state.getStateKey()
        );
        
        if (totalWeight >= state.getThresholdRequired()) {
            applyStateChange(state);
        }
    }
}
```

**Impact:** 60x меньше DB writes

### 6.2 Territory Control Optimization

**Use Redis для real-time tracking:**

```java
@Service
public class TerritoryControlCache {
    
    @Autowired
    private RedisTemplate<String, TerritoryControl> redisTemplate;
    
    public void updateControl(String serverId, String territoryId, int contribution) {
        String key = "territory:" + serverId + ":" + territoryId;
        
        // Update в Redis
        redisTemplate.opsForHash().increment(key, "control", contribution);
        
        // Sync to DB каждые 5 минут
    }
    
    @Scheduled(fixedRate = 300000)  // 5 минут
    public void syncToDatabase() {
        // Batch update DB from Redis
    }
}
```

**Impact:** 300x меньше DB writes

---

## 🚀 TIER 7: Network Optimization

### 7.1 Response Compression

```yaml
# application.yml
server:
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/xml,text/plain
    min-response-size: 1024  # 1KB
```

**Impact:** 3x-5x меньше traffic

### 7.2 HTTP/2

```yaml
server:
  http2:
    enabled: true
```

**Impact:** Parallel requests

### 7.3 CDN для статичных данных

```java
// Quest descriptions, images - на CDN
@Value("${cdn.url}")
private String cdnUrl;

public QuestDTO toDTO(Quest quest) {
    QuestDTO dto = new QuestDTO();
    dto.setId(quest.getId());
    dto.setImageUrl(cdnUrl + "/quests/" + quest.getId() + ".jpg");
    return dto;
}
```

---

## 🚀 TIER 8: Monitoring & Metrics

### 8.1 Micrometer Metrics

```java
@Service
public class QuestMetricsService {
    
    private final Counter questCompletedCounter;
    private final Timer questProcessingTimer;
    
    public QuestMetricsService(MeterRegistry registry) {
        this.questCompletedCounter = Counter.builder("quests.completed")
            .description("Total quests completed")
            .tag("type", "all")
            .register(registry);
        
        this.questProcessingTimer = Timer.builder("quests.processing.time")
            .description("Quest processing time")
            .register(registry);
    }
    
    public void recordQuestCompleted(Quest quest) {
        questCompletedCounter.increment();
        
        // Tag by type
        Counter.builder("quests.completed")
            .tag("type", quest.getType().name())
            .register(registry)
            .increment();
    }
    
    public void recordProcessingTime(long milliseconds) {
        questProcessingTimer.record(milliseconds, TimeUnit.MILLISECONDS);
    }
}
```

### 8.2 Custom Health Indicators

```java
@Component
public class QuestSystemHealthIndicator implements HealthIndicator {
    
    @Autowired
    private QuestRepository questRepository;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Override
    public Health health() {
        try {
            // Check database
            long questCount = questRepository.count();
            
            // Check Redis
            redisTemplate.opsForValue().get("health:check");
            
            // Check quest graph
            boolean graphLoaded = questGraphService.isGraphLoaded();
            
            return Health.up()
                .withDetail("questCount", questCount)
                .withDetail("redisConnected", true)
                .withDetail("graphLoaded", graphLoaded)
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

### 8.3 Slow Query Detection

```java
@Aspect
@Component
public class QueryPerformanceAspect {
    
    @Around("execution(* com.necpgame.narrative.repository.*.*(..))")
    public Object logQueryPerformance(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        
        Object result = joinPoint.proceed();
        
        long duration = System.currentTimeMillis() - start;
        
        if (duration > 100) {  // > 100ms
            log.warn("Slow query detected: method={}, duration={}ms",
                     joinPoint.getSignature().getName(), duration);
        }
        
        return result;
    }
}
```

---

## 📊 BENCHMARKS

### Expected Performance (after optimization)

**Single Server (32 cores, 128GB RAM):**
- Concurrent users: 100,000
- Requests/sec: 5,000
- Average response time: 50ms
- 95th percentile: 150ms
- 99th percentile: 300ms

**Cluster (10 servers):**
- Concurrent users: 1,000,000+
- Requests/sec: 50,000+
- Average response time: 50ms
- 95th percentile: 150ms
- 99th percentile: 300ms

### Load Testing

```bash
# Apache Bench
ab -n 10000 -c 100 http://localhost:8080/api/v1/narrative/quests/available?characterId=test

# JMeter script
jmeter -n -t quest-system-load-test.jmx -l results.jtl

# Expected results:
# - 0% errors
# - Average response time < 100ms
# - Throughput > 1000 req/sec (single server)
```

---

## 🎯 OPTIMIZATION CHECKLIST

### Database (критично)
- [x] Все индексы созданы (15+)
- [x] Connection pool настроен (200 connections)
- [ ] Партиционирование применено (для больших таблиц)
- [ ] Materialized views созданы (опционально)
- [ ] Read replicas настроены (для масштабирования)

### Application
- [x] Redis caching настроен
- [x] Query optimization (projections, batch)
- [x] Async processing для non-critical
- [ ] Quest graph preprocessing (lookup tables)
- [ ] Response compression enabled

### Network
- [ ] HTTP/2 enabled
- [ ] CDN для статики
- [ ] Load balancer настроен

### Monitoring
- [ ] Metrics configured (Micrometer)
- [ ] Health checks добавлены
- [ ] Slow query detection
- [ ] Alerting настроен

---

## 📚 СВЯЗАННЫЕ ДОКУМЕНТЫ

- [Step-by-Step Setup](./step-by-step-backend-setup.md) - начальная настройка
- [Troubleshooting Guide](./troubleshooting-guide.md) - решение проблем
- [Backend Integration](./backend-integration-complete.md) - полный код

---

## История изменений

- v1.0.0 (2025-11-07 00:44) - Performance tuning guide created

