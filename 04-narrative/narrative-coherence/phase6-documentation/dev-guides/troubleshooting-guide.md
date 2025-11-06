# Troubleshooting Guide: Quest System

**Версия:** 1.0.0  
**Дата:** 2025-11-07 00:42

---

## Краткое описание

Руководство по решению типичных проблем при интеграции и работе системы квестового графа.

---

## 🔴 ПРОБЛЕМА 1: Миграции не применяются

### Симптомы
```
ERROR: relation "quests" does not exist
ERROR: column "has_branches" does not exist
```

### Причины и решения

**Причина 1: Базовая таблица quests не существует**

```sql
-- Проверить
psql -d necpgame -c "\dt quests"

-- Если нет, создать базовую
CREATE TABLE quests (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(2000) NOT NULL,
    type VARCHAR(20) NOT NULL,
    level INTEGER NOT NULL,
    giver_npc_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Затем применить миграции
```

**Причина 2: Миграция уже применена частично**

```sql
-- Проверить какие колонки есть
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'quests';

-- Если миграция применена частично, rollback и повторить
-- Или применить только недостающие части
```

**Причина 3: Нет прав**

```bash
# Дать права пользователю
psql -U postgres -d necpgame
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;
```

---

## 🔴 ПРОБЛЕМА 2: Quest graph не загружается

### Симптомы
```
ERROR: Failed to load quest graph
FileNotFoundException: quest-dependencies-full.json
NullPointerException in QuestGraphService
```

### Причины и решения

**Причина 1: JSON файл не найден**

```bash
# Проверить наличие файла
ls -la BACK-JAVA/src/main/resources/data/narrative/

# Если нет, экспортировать
cd .BRAIN/04-narrative/narrative-coherence/phase3-event-matrix/export
python convert-quest-graph.py

# Скопировать
cp export/*.json BACK-JAVA/src/main/resources/data/narrative/
```

**Причина 2: Неверный путь в коде**

```java
// Проверить путь
new ClassPathResource("data/narrative/quest-dependencies-full.json")

// Должен соответствовать реальной структуре
// resources/data/narrative/quest-dependencies-full.json
```

**Причина 3: JSON невалидный**

```bash
# Проверить JSON
cat quest-dependencies-full.json | jq .

# Если ошибка, пересоздать
python convert-quest-graph.py
```

---

## 🔴 ПРОБЛЕМА 3: JSONB не работает

### Симптомы
```
ERROR: column "required_flags" is of type jsonb but expression is of type character varying
ERROR: operator does not exist: jsonb = character varying
```

### Причины и решения

**Причина 1: Hibernate Types не подключен**

```xml
<!-- Добавить в pom.xml -->
<dependency>
    <groupId>com.vladmihalcea</groupId>
    <artifactId>hibernate-types-55</artifactId>
    <version>2.21.1</version>
</dependency>
```

**Причина 2: @TypeDef не добавлен**

```java
// Добавить в Entity
@TypeDef(name = "jsonb", typeClass = JsonBinaryType.class)
public class Quest {
    // ...
    
    @Type(type = "jsonb")
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> requiredFlags;
}
```

**Причина 3: PostgreSQL dialect неверный**

```yaml
# application.yml
spring:
  jpa:
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect  # Правильный
```

---

## 🔴 ПРОБЛЕМА 4: Quest не доступен (ошибочно)

### Симптомы
```
Quest MQ-2020-002 показывается как недоступен,
хотя все prerequisites выполнены
```

### Диагностика

```java
// Добавить debug логирование
log.debug("Checking quest availability: questId={}, characterId={}", questId, characterId);
log.debug("Prerequisites check: {}", checkPrerequisites(quest, characterId));
log.debug("Flags check: {}", checkRequiredFlags(quest, characterId));
log.debug("Reputation check: {}", checkRequiredReputation(quest, characterId));
log.debug("Level check: character={}, required={}", getCharacterLevel(characterId), quest.getMinLevel());
log.debug("Blocked check: {}", isQuestBlocked(questId, characterId));
```

### Решения

**Причина 1: Флаги не установлены**

```sql
-- Проверить флаги
SELECT * FROM player_flags WHERE character_id = 'xxx';

-- Если нет, установить вручную для теста
INSERT INTO player_flags (character_id, flag_key, flag_value, set_by_quest)
VALUES ('xxx', 'test_flag', 'true'::jsonb, 'TEST');
```

**Причина 2: Quest progress не обновился**

```sql
-- Проверить прогресс
SELECT * FROM quest_progress WHERE character_id = 'xxx';

-- Обновить статус prerequisite квеста
UPDATE quest_progress 
SET status = 'COMPLETED', completed_at = NOW()
WHERE character_id = 'xxx' AND quest_id = 'MQ-2020-001';
```

**Причина 3: Репутация недостаточна**

```sql
-- Проверить репутацию (если таблица существует)
SELECT * FROM character_reputation WHERE character_id = 'xxx';

-- Установить для теста
-- UPDATE character_reputation SET reputation = 50 
-- WHERE character_id = 'xxx' AND faction_id = 'NetWatch';
```

---

## 🔴 ПРОБЛЕМА 5: World state votes не применяются

### Симптомы
```
Голоса сохраняются, но server state не меняется
Threshold достигнут, но status = 'pending'
```

### Диагностика

```sql
-- Проверить голоса
SELECT state_key, COUNT(*), SUM(weight) 
FROM world_state_votes 
WHERE server_id = 'server-01' AND state_key = 'test_state'
GROUP BY state_key;

-- Проверить threshold
SELECT state_key, player_votes, vote_weight_total, threshold_required, status
FROM server_world_state
WHERE server_id = 'server-01' AND state_key = 'test_state';
```

### Решения

**Причина 1: Threshold calculation неверный**

```java
// Проверить логику в WorldStateService
int totalWeight = voteRepo.sumWeightByServerAndKey(serverId, stateKey);

// Убедиться что используется weight, а не просто count
```

**Причина 2: Транзакция не закоммичена**

```java
// Добавить @Transactional
@Transactional
public VoteResult castVote(...) {
    // ...
}
```

**Причина 3: Update не выполняется**

```java
// После изменения state - явно save
serverState.setStatus(StateStatus.ACTIVE);
serverStateRepository.save(serverState);  // ВАЖНО!
serverStateRepository.flush();  // Force write
```

---

## 🔴 ПРОБЛЕМА 6: Performance медленный

### Симптомы
```
API отвечает > 1 секунды
БД queries занимают много времени
Redis не кэширует
```

### Решения

**Проблема 1: Нет индексов**

```sql
-- Проверить индексы
\di quest*

-- Если нет, создать
CREATE INDEX idx_quests_level ON quests(min_level, max_level);
CREATE INDEX idx_player_flags_character_key ON player_flags(character_id, flag_key);
```

**Проблема 2: N+1 queries**

```java
// ПЛОХО - N+1 queries
List<Quest> quests = questRepository.findAll();
for (Quest q : quests) {
    q.getBranches();  // Lazy load - еще один query!
}

// ХОРОШО - один query
@EntityGraph(attributePaths = {"branches"})
List<Quest> findAllWithBranches();
```

**Проблема 3: Redis не работает**

```bash
# Проверить Redis
redis-cli
> KEYS quest:*
> GET quest:deps:MQ-2020-001

# Если пусто, проверить @Cacheable аннотации
```

```java
// Добавить кэширование
@Cacheable(value = "questGraph", key = "#questId")
public Quest getQuest(String questId) {
    return questRepository.findById(questId).orElseThrow();
}
```

**Проблема 4: Слишком много данных в response**

```java
// Использовать projections вместо полных entities
@Query("SELECT new QuestSummary(q.id, q.name, q.type) FROM Quest q")
List<QuestSummary> findSummaries();
```

---

## 🔴 ПРОБЛЕМА 7: WebSocket не отправляет события

### Симптомы
```
Клиенты не получают уведомления
WebSocket connection timeout
Events не отправляются
```

### Решения

**Причина 1: CORS настройки**

```java
@Override
public void registerStompEndpoints(StompEndpointRegistry registry) {
    registry.addEndpoint("/ws/narrative")
            .setAllowedOrigins("http://localhost:3000", "http://localhost:5173")  // ВАЖНО!
            .withSockJS();
}
```

**Причина 2: Topic неверный**

```java
// ПЛОХО
messagingTemplate.convertAndSend("/topic/quests", event);

// ХОРОШО - с server ID
messagingTemplate.convertAndSend(
    "/topic/server/" + serverId + "/world-state", 
    event
);
```

**Причина 3: SimpMessagingTemplate не autowired**

```java
@Service
public class NotificationService {
    
    @Autowired  // НЕ ЗАБЫТЬ!
    private SimpMessagingTemplate messagingTemplate;
}
```

---

## 🔴 ПРОБЛЕМА 8: Dialogue tree ошибка

### Симптомы
```
Dead end в dialogue tree
Next node не найден
Infinite loop в диалогах
```

### Решения

**Dead end check:**

```sql
-- Найти узлы без next
SELECT dn.quest_id, dn.node_id, dn.node_type
FROM dialogue_nodes dn
LEFT JOIN dialogue_choices dc ON dn.id = dc.node_id
WHERE dn.node_type = 'choice' 
AND dc.id IS NULL;

-- Должно быть пусто (кроме type='end')
```

**Infinite loop check:**

```java
// Добавить защиту от зацикливания
Set<Integer> visitedNodes = new HashSet<>();
Integer currentNode = dialogueTreeRoot;

while (currentNode != null) {
    if (visitedNodes.contains(currentNode)) {
        throw new DialogueLoopException("Loop detected at node " + currentNode);
    }
    visitedNodes.add(currentNode);
    
    currentNode = getNextNode(currentNode, choice);
}
```

---

## 🔴 ПРОБЛЕМА 9: Memory leak

### Симптомы
```
Heap memory растёт
OutOfMemoryError после нескольких часов
Garbage collection частый
```

### Решения

**Причина 1: Quest graph в памяти слишком большой**

```java
// Вместо хранения всего графа в памяти
// Используйте cache с eviction
@Cacheable(value = "questDeps", key = "#questId", unless = "#result == null")
public List<String> getQuestDependencies(String questId) {
    // Load on demand
}
```

**Причина 2: Dialogue trees не очищаются**

```java
// После завершения квеста очистить dialogue progress
@Transactional
public void completeQuest(UUID characterId, String questId) {
    // ...
    playerDialogueProgressRepository.deleteByCharacterAndQuest(characterId, questId);
}
```

**Причина 3: Session leaks**

```java
// Настроить session timeout
spring:
  session:
    timeout: 30m  # 30 минут idle
```

---

## 🔴 ПРОБЛЕМА 10: Concurrent modification

### Симптомы
```
ConcurrentModificationException
Lost update в world state
Race condition при голосовании
```

### Решения

**Использовать @Version для optimistic locking:**

```java
@Entity
public class ServerWorldState {
    // ...
    
    @Version
    private Long version;  // Hibernate автоматически проверит
}
```

**Использовать database locks:**

```java
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("SELECT s FROM ServerWorldState s WHERE s.serverId = :serverId AND s.stateKey = :key")
Optional<ServerWorldState> findByServerAndKeyForUpdate(
    @Param("serverId") String serverId,
    @Param("key") String key
);
```

**Атомарные операции:**

```sql
-- Использовать UPDATE вместо SELECT + UPDATE
UPDATE server_world_state 
SET player_votes = player_votes + 1,
    vote_weight_total = vote_weight_total + :weight
WHERE server_id = :serverId AND state_key = :stateKey;
```

---

## 🔴 ПРОБЛЕМА 11: Slow queries

### Симптомы
```
Query execution time > 1 секунда
Database CPU 100%
Slow query log полон
```

### Диагностика

```sql
-- Включить slow query log
ALTER DATABASE necpgame SET log_min_duration_statement = 100;  -- 100ms

-- Проверить slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Explain analyze
EXPLAIN ANALYZE
SELECT * FROM quests WHERE era = '2020-2030';
```

### Решения

**Добавить недостающие индексы:**

```sql
-- Для частых queries
CREATE INDEX idx_quests_era_level ON quests(era, min_level);
CREATE INDEX idx_player_flags_lookup ON player_flags(character_id, flag_key, flag_value);
```

**Использовать query hints:**

```java
@QueryHints(@QueryHint(name = "org.hibernate.cacheable", value = "true"))
List<Quest> findByEra(String era);
```

---

## 🔴 ПРОБЛЕМА 12: Redis connection failed

### Симптомы
```
Unable to connect to Redis
RedisConnectionFailureException
Cache not working
```

### Решения

**Проверить Redis:**

```bash
# Запущен ли Redis?
ps aux | grep redis

# Проверить подключение
redis-cli ping

# Если не работает, запустить
redis-server

# Проверить порт
netstat -an | grep 6379
```

**Проверить конфигурацию:**

```yaml
# application.yml
spring:
  redis:
    host: localhost  # Проверить
    port: 6379       # Проверить
    password:        # Если нужен
    timeout: 2000ms
```

**Fallback без Redis:**

```java
// Временно отключить caching
@Configuration
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager();  # In-memory cache
    }
}
```

---

## 🔴 ПРОБЛЕМА 13: Frontend не получает данные

### Симптомы
```
API returns 500
CORS error
Empty response
```

### Решения

**CORS configuration:**

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:3000", "http://localhost:5173")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
```

**Проверить response format:**

```java
// Убедиться что DTO сериализуется
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class QuestSummary {
    private String id;
    private String name;
    // ...
}
```

---

## 🔴 ПРОБЛЕМА 14: Dialogue choice не сохраняется

### Симптомы
```
Choice обрабатывается, но не сохраняется в БД
Флаги не устанавливаются
Репутация не меняется
```

### Решения

**Добавить @Transactional:**

```java
@Service
public class QuestGraphService {
    
    @Transactional  // ВАЖНО!
    public QuestChoiceResult processChoice(...) {
        // Все изменения в одной транзакции
    }
}
```

**Проверить cascade:**

```java
// Убедиться что сохраняются связанные entities
playerFlag.setCharacterId(characterId);
flagRepository.save(playerFlag);  // Явно save
```

**Rollback handling:**

```java
@Transactional(rollbackFor = Exception.class)
public QuestChoiceResult processChoice(...) {
    try {
        // Process
    } catch (Exception e) {
        log.error("Failed to process choice", e);
        throw e;  // Rollback transaction
    }
}
```

---

## 🛠️ DEBUGGING TOOLS

### Логирование

```yaml
# application.yml - для debugging
logging:
  level:
    com.necpgame.narrative: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

### SQL трассировка

```java
// p6spy для логирования SQL
// pom.xml
<dependency>
    <groupId>p6spy</groupId>
    <artifactId>p6spy</artifactId>
    <version>3.9.1</version>
</dependency>

// Добавит красивые SQL логи с параметрами
```

### Redis monitoring

```bash
# Monitor Redis commands
redis-cli monitor

# Check keys
redis-cli KEYS "*"

# Check cache hit rate
redis-cli INFO stats
```

### Database stats

```sql
-- Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
SELECT 
    indexrelname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

---

## 📞 COMMON ERROR MESSAGES

### "Quest not found"
**Причина:** questId неверный или квест не в БД  
**Решение:** Проверить `SELECT * FROM quests WHERE id = 'xxx'`

### "Character not found"
**Причина:** characterId не существует  
**Решение:** Проверить `SELECT * FROM characters WHERE id = 'xxx'`

### "Insufficient reputation"
**Причина:** Репутация < required  
**Решение:** Повысить репутацию или убрать requirement для теста

### "Flag not set"
**Причина:** Required flag отсутствует  
**Решение:** Установить флаг вручную для теста

### "Quest already completed"
**Причина:** Квест уже пройден  
**Решение:** Это нормально, проверить можно через quest_progress

### "Dialogue node not found"
**Причина:** node_id неверный  
**Решение:** Проверить dialogue_nodes таблицу

---

## 🆘 EMERGENCY FIXES

### Быстрый rollback миграций

```bash
# В обратном порядке!
psql -d necpgame -f rollback/005-rollback-world-state.sql
psql -d necpgame -f rollback/004-rollback-player-systems.sql
psql -d necpgame -f rollback/003-rollback-dialogue.sql
psql -d necpgame -f rollback/002-rollback-branches.sql
psql -d necpgame -f rollback/001-rollback-expand-quests.sql
```

### Очистить cache

```bash
# Redis
redis-cli FLUSHDB

# Java
# Restart application
```

### Сбросить test data

```sql
-- ВНИМАНИЕ: Удалит все данные!
TRUNCATE TABLE player_quest_choices CASCADE;
TRUNCATE TABLE player_flags CASCADE;
TRUNCATE TABLE world_state_votes CASCADE;
TRUNCATE TABLE player_dialogue_progress CASCADE;

-- Оставить только базовые квесты и world state
```

---

## 📚 СВЯЗАННЫЕ ДОКУМЕНТЫ

- [Backend Integration Complete](./backend-integration-complete.md) - полный код
- [Step-by-Step Setup](./step-by-step-backend-setup.md) - пошаговая настройка
- [Performance Tuning](./performance-tuning-guide.md) - оптимизация

---

## История изменений

- v1.0.0 (2025-11-07 00:42) - Troubleshooting guide created

