# Step-by-Step Backend Setup Guide

**Версия:** 1.0.0  
**Дата:** 2025-11-07 00:40  
**Для:** Backend разработчиков (Java Spring Boot)

**api-readiness:** not-applicable

---

## Краткое описание

Пошаговое руководство по интеграции системы квестового графа и world state в BACK-JAVA проект.

**Estimated time:** 2-3 часа (базовая интеграция) + 1-2 недели (полная реализация)

---

## 🎯 PREREQUISITES

### Требования

- [x] Java 17+
- [x] Spring Boot 3.x
- [x] PostgreSQL 14+
- [x] Redis (для кэширования)
- [x] Maven 3.8+

### Проверка

```bash
# Java
java -version  # Should be 17+

# PostgreSQL
psql --version  # Should be 14+

# Redis
redis-cli ping  # Should return PONG

# Maven
mvn -version  # Should be 3.8+
```

---

## 📋 STEP 1: Подготовка окружения (10 минут)

### 1.1 Подготовить PostgreSQL

```bash
# Создать базу данных
createdb necpgame

# Или через psql
psql -U postgres
CREATE DATABASE necpgame;
\q
```

### 1.2 Запустить Redis

```bash
# Linux/Mac
redis-server

# Windows (через WSL или Docker)
docker run -d -p 6379:6379 redis:latest
```

### 1.3 Проверить подключение

```bash
# PostgreSQL
psql -d necpgame -c "SELECT version();"

# Redis
redis-cli ping
```

**✅ Checkpoint:** БД и Redis работают

---

## 📋 STEP 2: SQL Миграции (15 минут)

### 2.1 Скопировать миграции

```bash
# Из .BRAIN в ваш проект
cp .BRAIN/04-narrative/narrative-coherence/phase4-database/migrations/*.sql \
   BACK-JAVA/src/main/resources/db/migration/narrative/

# Или используйте прямо из .BRAIN
cd .BRAIN/04-narrative/narrative-coherence/phase4-database/migrations/
```

### 2.2 Настроить переменные окружения

```bash
# Linux/Mac (.bashrc или .zshrc)
export DB_NAME=necpgame
export DB_USER=postgres
export DB_PASSWORD=your_password
export DB_HOST=localhost
export DB_PORT=5432

# Windows (PowerShell profile)
$env:DB_NAME = "necpgame"
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "your_password"
$env:DB_HOST = "localhost"
$env:DB_PORT = "5432"
```

### 2.3 Применить миграции

```bash
# Автоматически (рекомендуется)
./apply-all-migrations.sh  # Linux/Mac
.\apply-all-migrations.ps1  # Windows

# ИЛИ вручную (по одной)
psql -d necpgame -U postgres -f 001-expand-quests-table.sql
psql -d necpgame -U postgres -f 002-create-quest-branches.sql
psql -d necpgame -U postgres -f 003-create-dialogue-system.sql
psql -d necpgame -U postgres -f 004-create-player-systems.sql
psql -d necpgame -U postgres -f 005-create-world-state-system.sql
```

### 2.4 Проверить результат

```bash
psql -d necpgame -U postgres

-- Проверить таблицы
\dt quest*
\dt player*
\dt server*
\dt dialogue*
\dt territory*

-- Должно быть 13 таблиц:
-- quests (расширенная)
-- quest_branches
-- quest_objectives
-- dialogue_nodes
-- dialogue_choices
-- player_quest_choices
-- player_flags
-- player_dialogue_progress
-- player_world_state
-- server_world_state
-- world_state_votes
-- faction_world_state
-- territory_control

\q
```

**✅ Checkpoint:** 13 таблиц созданы, sample data загружена

---

## 📋 STEP 3: Export данных в JSON (20 минут)

### 3.1 Установить зависимости

```bash
# Python
pip install pyyaml

# ИЛИ Node.js
npm install js-yaml
```

### 3.2 Запустить конвертер

```bash
cd .BRAIN/04-narrative/narrative-coherence/phase3-event-matrix/export

# Python (рекомендуется)
python convert-quest-graph.py

# ИЛИ Node.js
node convert-quest-graph.js
```

### 3.3 Проверить результат

```bash
# Должны появиться 4 JSON файла
ls -lh export/

# Проверить содержимое
cat export/quest-dependencies-full.json | head -50

# Проверить размер
du -h export/*.json
```

**Expected output:**
```
export/side-quests-matrix.json          (~50KB)
export/quest-triggers.json              (~30KB)
export/quest-blockers.json              (~40KB)
export/quest-dependencies-full.json     (~100KB)
```

### 3.4 Скопировать JSON в backend

```bash
# Копируем в resources
cp .BRAIN/04-narrative/narrative-coherence/phase3-event-matrix/export/*.json \
   BACK-JAVA/src/main/resources/data/narrative/
```

**✅ Checkpoint:** 4 JSON файла в backend resources

---

## 📋 STEP 4: Добавить зависимости в pom.xml (5 минут)

### 4.1 Открыть pom.xml

```bash
cd BACK-JAVA
vi pom.xml  # или ваш редактор
```

### 4.2 Добавить dependencies

```xml
<!-- Hibernate Types для JSONB support -->
<dependency>
    <groupId>com.vladmihalcea</groupId>
    <artifactId>hibernate-types-55</artifactId>
    <version>2.21.1</version>
</dependency>

<!-- Redis для кэширования -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- WebSocket для real-time updates -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>

<!-- JSON processing -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
</dependency>
```

### 4.3 Обновить зависимости

```bash
mvn clean install
```

**✅ Checkpoint:** Dependencies установлены

---

## 📋 STEP 5: Создать структуру пакетов (5 минут)

### 5.1 Создать директории

```bash
cd BACK-JAVA/src/main/java/com/necpgame/

# Создать пакеты для narrative системы
mkdir -p narrative/entity
mkdir -p narrative/repository
mkdir -p narrative/service
mkdir -p narrative/controller
mkdir -p narrative/dto
mkdir -p narrative/config
```

### 5.2 Структура должна быть:

```
com.necpgame.narrative/
├── entity/          # JPA entities
├── repository/      # Spring Data repositories
├── service/         # Business logic
├── controller/      # REST controllers
├── dto/             # Data Transfer Objects
└── config/          # Configuration classes
```

**✅ Checkpoint:** Структура пакетов готова

---

## 📋 STEP 6: Создать Entities (30 минут)

### 6.1 Открыть backend-integration-complete.md

```bash
# Файл с готовым кодом
cat .BRAIN/04-narrative/narrative-coherence/phase6-documentation/dev-guides/backend-integration-complete.md
```

### 6.2 Copy-paste Entity: Quest.java

**Создать файл:** `BACK-JAVA/src/main/java/com/necpgame/narrative/entity/Quest.java`

**Скопировать код из** `backend-integration-complete.md` секция "Quest.java"

**Ключевые моменты:**
```java
@Entity
@Table(name = "quests")
@TypeDef(name = "jsonb", typeClass = JsonBinaryType.class)
public class Quest {
    @Id
    @Column(length = 100)
    private String id;
    
    // ... остальные поля из документации
    
    @Type(type = "jsonb")
    @Column(name = "required_quests", columnDefinition = "jsonb")
    private List<String> requiredQuests;
    
    // ... getters/setters
}
```

### 6.3 Аналогично создать остальные entities

**Создать по очереди:**
1. `QuestBranch.java` (copy-paste из документации)
2. `DialogueNode.java` (copy-paste)
3. `DialogueChoice.java` (copy-paste)
4. `PlayerFlag.java` (copy-paste)
5. `PlayerWorldState.java` (copy-paste)
6. `ServerWorldState.java` (copy-paste)
7. `TerritoryControl.java` (copy-paste)

**⚠️ Важно:**
- Добавить `@TypeDef` для JSONB support
- Добавить аннотацию `@Type(type = "jsonb")` для JSONB полей
- Проверить naming convention вашего проекта

**✅ Checkpoint:** 8 entities созданы, компилируются без ошибок

---

## 📋 STEP 7: Создать Repositories (15 минут)

### 7.1 QuestRepository.java

**Создать:** `BACK-JAVA/src/main/java/com/necpgame/narrative/repository/QuestRepository.java`

```java
package com.necpgame.narrative.repository;

import com.necpgame.narrative.entity.Quest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestRepository extends JpaRepository<Quest, String> {
    
    @Query("SELECT q FROM Quest q WHERE q.era = :era AND q.isActive = true")
    List<Quest> findByEra(@Param("era") String era);
    
    @Query("SELECT q FROM Quest q WHERE q.type = :type AND q.isActive = true")
    List<Quest> findByType(@Param("type") String type);
    
    @Query("SELECT q FROM Quest q WHERE q.minLevel <= :level " +
           "AND (q.maxLevel IS NULL OR q.maxLevel >= :level)")
    List<Quest> findByLevelRange(@Param("level") Integer level);
}
```

### 7.2 Создать остальные repositories

**По аналогии создать:**
1. `QuestBranchRepository.java`
2. `DialogueNodeRepository.java`
3. `PlayerFlagRepository.java`
4. `ServerWorldStateRepository.java`
5. `TerritoryControlRepository.java`

**Шаблон:**
```java
@Repository
public interface [Name]Repository extends JpaRepository<[Entity], [IdType]> {
    // Custom queries if needed
}
```

**✅ Checkpoint:** 6 repositories созданы

---

## 📋 STEP 8: Конфигурация (10 минут)

### 8.1 application.yml

**Путь:** `BACK-JAVA/src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/necpgame
    username: postgres
    password: ${DB_PASSWORD}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
  
  jpa:
    hibernate:
      ddl-auto: validate  # НЕ create! Миграции уже применены
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
    show-sql: false
  
  redis:
    host: localhost
    port: 6379
    timeout: 2000ms
  
  cache:
    type: redis
    redis:
      time-to-live: 600000  # 10 minutes
```

### 8.2 RedisConfig.java

**Создать:** `BACK-JAVA/src/main/java/com/necpgame/narrative/config/RedisConfig.java`

```java
package com.necpgame.narrative.config;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.time.Duration;

@Configuration
@EnableCaching
public class RedisConfig {
    
    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration
            .defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .disableCachingNullValues()
            .serializeValuesWith(
                RedisSerializationContext.SerializationPair
                    .fromSerializer(new GenericJackson2JsonRedisSerializer())
            );
        
        return RedisCacheManager.builder(factory)
            .cacheDefaults(defaultConfig)
            .withCacheConfiguration("questGraph",
                RedisCacheConfiguration.defaultCacheConfig()
                    .entryTtl(Duration.ofHours(1)))
            .withCacheConfiguration("worldState",
                RedisCacheConfiguration.defaultCacheConfig()
                    .entryTtl(Duration.ofMinutes(5)))
            .build();
    }
}
```

**✅ Checkpoint:** Redis настроен

---

## 📋 STEP 9: Создать QuestGraphService (45 минут)

### 9.1 Создать файл

**Путь:** `BACK-JAVA/src/main/java/com/necpgame/narrative/service/QuestGraphService.java`

### 9.2 Скопировать код

**Из:** `backend-integration-complete.md` секция "QuestGraphService.java"

**Основные методы:**
```java
@Service
@Slf4j
public class QuestGraphService {
    
    @Autowired
    private QuestRepository questRepository;
    
    @Autowired
    private PlayerFlagRepository flagRepository;
    
    // Quest graph cache
    private Map<String, QuestNode> questGraph;
    
    @PostConstruct
    public void loadQuestGraph() {
        // Load from JSON
        try {
            ObjectMapper mapper = new ObjectMapper();
            QuestGraphData data = mapper.readValue(
                new ClassPathResource("data/narrative/quest-dependencies-full.json").getFile(),
                QuestGraphData.class
            );
            
            questGraph = buildGraph(data);
            log.info("Quest graph loaded: {} nodes", data.getNodes().size());
        } catch (IOException e) {
            log.error("Failed to load quest graph", e);
        }
    }
    
    public boolean isQuestAvailable(String questId, UUID characterId) {
        // Полная реализация в документации
    }
    
    public List<QuestSummary> getAvailableQuests(UUID characterId) {
        // Полная реализация в документации
    }
    
    @Transactional
    public QuestChoiceResult processChoice(UUID characterId, String questId, 
                                           Integer nodeId, String choiceId) {
        // Полная реализация в документации
    }
}
```

### 9.3 Создать вспомогательные классы

**QuestGraphData.java** (DTO для JSON):
```java
@Data
public class QuestGraphData {
    private Metadata metadata;
    private List<QuestNode> nodes;
    private List<QuestEdge> edges;
    private Map<String, Object> criticalChains;
}

@Data
class QuestNode {
    private String id;
    private String name;
    private String era;
    private String type;
}

@Data
class QuestEdge {
    private String from;
    private String to;
    private String type;  // requires, unlocks, blocks, influences
    private String timing;
}
```

**✅ Checkpoint:** QuestGraphService работает, граф загружается

---

## 📋 STEP 10: Создать Controllers (30 минут)

### 10.1 QuestController.java

**Создать:** `BACK-JAVA/src/main/java/com/necpgame/narrative/controller/QuestController.java`

```java
@RestController
@RequestMapping("/api/v1/narrative/quests")
@Slf4j
public class QuestController {
    
    @Autowired
    private QuestGraphService questGraphService;
    
    /**
     * GET /api/v1/narrative/quests/available?characterId=xxx
     */
    @GetMapping("/available")
    public ResponseEntity<QuestListResponse> getAvailableQuests(
            @RequestParam UUID characterId,
            @RequestParam(required = false) String era,
            @RequestParam(required = false) String type) {
        
        log.info("Getting available quests for character: {}", characterId);
        
        List<QuestSummary> quests = questGraphService.getAvailableQuests(characterId);
        
        // Filter by era/type if provided
        if (era != null) {
            quests = quests.stream()
                .filter(q -> era.equals(q.getEra()))
                .collect(Collectors.toList());
        }
        
        QuestListResponse response = new QuestListResponse();
        response.setQuests(quests);
        response.setTotal(quests.size());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * GET /api/v1/narrative/quests/{questId}?characterId=xxx
     */
    @GetMapping("/{questId}")
    public ResponseEntity<QuestDetailResponse> getQuestDetails(
            @PathVariable String questId,
            @RequestParam UUID characterId) {
        
        Quest quest = questRepository.findById(questId)
            .orElseThrow(() -> new QuestNotFoundException(questId));
        
        boolean available = questGraphService.isQuestAvailable(questId, characterId);
        
        QuestDetailResponse response = new QuestDetailResponse();
        response.setQuest(toQuestDTO(quest));
        response.setAvailable(available);
        
        if (!available) {
            response.setBlockedBy(
                questGraphService.getBlockReasons(questId, characterId)
            );
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * POST /api/v1/narrative/quests/{questId}/choice
     */
    @PostMapping("/{questId}/choice")
    public ResponseEntity<QuestChoiceResult> makeChoice(
            @PathVariable String questId,
            @RequestBody QuestChoiceRequest request) {
        
        log.info("Processing choice for quest {}: character={}, choice={}",
                 questId, request.getCharacterId(), request.getChoiceId());
        
        QuestChoiceResult result = questGraphService.processChoice(
            request.getCharacterId(),
            questId,
            request.getNodeId(),
            request.getChoiceId()
        );
        
        return ResponseEntity.ok(result);
    }
}
```

### 10.2 Создать DTOs

**QuestListResponse.java:**
```java
@Data
public class QuestListResponse {
    private List<QuestSummary> quests;
    private Integer total;
}

@Data
class QuestSummary {
    private String id;
    private String name;
    private String type;
    private String era;
    private Integer minLevel;
    private Boolean available;
}
```

**QuestChoiceRequest.java:**
```java
@Data
public class QuestChoiceRequest {
    private UUID characterId;
    private Integer nodeId;
    private String choiceId;
}
```

**QuestChoiceResult.java:**
```java
@Data
public class QuestChoiceResult {
    private Boolean success;
    private Map<String, Integer> reputationChanges;
    private List<String> flagsSet;
    private List<String> unlockedQuests;
    private List<String> blockedQuests;
    private List<String> itemsGained;
}
```

**✅ Checkpoint:** REST API endpoints работают

---

## 📋 STEP 11: Тестирование (30 минут)

### 11.1 Запустить backend

```bash
cd BACK-JAVA
./mvnw spring-boot:run

# Ждём запуска
# Должно быть: "Started NecpgameApplication in X seconds"
```

### 11.2 Проверить загрузку графа

**Проверить логи:**
```
Quest graph loaded: 550 nodes, 1200 edges
```

### 11.3 Тестировать API

```bash
# Test 1: Get available quests
curl -X GET "http://localhost:8080/api/v1/narrative/quests/available?characterId=00000000-0000-0000-0000-000000000001"

# Expected: JSON с списком квестов

# Test 2: Get quest details
curl -X GET "http://localhost:8080/api/v1/narrative/quests/MQ-2020-001?characterId=00000000-0000-0000-0000-000000000001"

# Expected: JSON с деталями квеста

# Test 3: Make choice
curl -X POST "http://localhost:8080/api/v1/narrative/quests/MQ-2020-001/choice" \
  -H "Content-Type: application/json" \
  -d '{
    "characterId": "00000000-0000-0000-0000-000000000001",
    "nodeId": 2,
    "choiceId": "A1"
  }'

# Expected: JSON с результатом выбора
```

### 11.4 Проверить БД

```bash
psql -d necpgame -U postgres

-- Проверить что choice сохранился
SELECT * FROM player_quest_choices 
WHERE character_id = '00000000-0000-0000-0000-000000000001';

-- Проверить флаги
SELECT * FROM player_flags 
WHERE character_id = '00000000-0000-0000-0000-000000000001';

\q
```

**✅ Checkpoint:** API работает, данные сохраняются

---

## 📋 STEP 12: WebSocket (опционально, 20 минут)

### 12.1 WebSocketConfig.java

**Создать:** `BACK-JAVA/src/main/java/com/necpgame/narrative/config/WebSocketConfig.java`

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
        registry.addEndpoint("/ws/narrative")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}
```

### 12.2 Notification Service

```java
@Service
public class NarrativeNotificationService {
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    public void notifyQuestUnlocked(UUID characterId, String questId) {
        QuestUnlockedEvent event = new QuestUnlockedEvent(characterId, questId);
        
        messagingTemplate.convertAndSendToUser(
            characterId.toString(),
            "/queue/quests",
            event
        );
    }
}
```

**✅ Checkpoint:** WebSocket работает

---

## 📋 STEP 13: Integration Tests (30 минут)

### 13.1 Создать тест

**Путь:** `BACK-JAVA/src/test/java/com/necpgame/narrative/QuestGraphServiceTest.java`

```java
@SpringBootTest
@AutoConfigureTestDatabase
class QuestGraphServiceTest {
    
    @Autowired
    private QuestGraphService questGraphService;
    
    @Autowired
    private QuestRepository questRepository;
    
    @Test
    void testQuestAvailability_withPrerequisites() {
        // Given
        UUID characterId = UUID.randomUUID();
        
        // Simulate completed prerequisite
        // (в реальности через QuestProgressService)
        
        // When
        boolean available = questGraphService.isQuestAvailable("MQ-2020-002", characterId);
        
        // Then
        assertFalse(available);  // Prerequisites not met
    }
    
    @Test
    void testProcessChoice_setsFlags() {
        // Given
        UUID characterId = UUID.randomUUID();
        
        // When
        QuestChoiceResult result = questGraphService.processChoice(
            characterId, "MQ-2020-001", 2, "A1"
        );
        
        // Then
        assertTrue(result.getSuccess());
        assertTrue(result.getFlagsSet().contains("marco_ally"));
        assertEquals(10, result.getReputationChanges().get("Fixers"));
    }
}
```

### 13.2 Запустить тесты

```bash
mvn test

# Или только narrative tests
mvn test -Dtest=QuestGraphServiceTest
```

**✅ Checkpoint:** Тесты проходят

---

## 📋 STEP 14: Финальная проверка (15 минут)

### 14.1 Проверка БД

```bash
psql -d necpgame

-- Должно быть 13 таблиц
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE 'quest%' 
OR table_name LIKE 'player%' 
OR table_name LIKE 'server%' 
OR table_name LIKE 'dialogue%' 
OR table_name LIKE 'territory%';

-- Проверить sample data
SELECT COUNT(*) FROM quest_branches;  # Должно быть >= 4
SELECT COUNT(*) FROM server_world_state;  # Должно быть >= 3
SELECT COUNT(*) FROM territory_control;  # Должно быть >= 4

\q
```

### 14.2 Проверка API

```bash
# Healthcheck
curl http://localhost:8080/actuator/health

# Quest API
curl http://localhost:8080/api/v1/narrative/quests/available?characterId=test

# Должен вернуть 200 OK
```

### 14.3 Проверка логов

```bash
# Проверить что нет ошибок
tail -f BACK-JAVA/logs/application.log

# Искать:
# ✅ "Quest graph loaded"
# ✅ "Redis connection established"
# ✅ "WebSocket broker configured"
# ❌ Нет SQL errors
# ❌ Нет connection errors
```

**✅ Checkpoint:** Всё работает!

---

## 🎊 ФИНАЛЬНЫЙ CHECKLIST

### Database
- [x] PostgreSQL running
- [x] Database created
- [x] 5 миграций применены
- [x] 13 таблиц созданы
- [x] Sample data загружена
- [x] Индексы созданы

### Backend Code
- [x] Dependencies добавлены (pom.xml)
- [x] 8 Entities созданы
- [x] 6 Repositories созданы
- [x] QuestGraphService создан
- [x] Controllers созданы (2)
- [x] Redis configured
- [x] WebSocket configured

### Data
- [x] JSON файлы экспортированы (4)
- [x] JSON файлы в resources
- [x] Quest graph загружен в память

### Testing
- [x] Unit tests написаны
- [x] Integration tests написаны
- [x] API endpoints протестированы
- [x] WebSocket протестирован

### Documentation
- [x] README обновлён
- [x] API documentation
- [x] Комментарии в коде

---

## 🚀 NEXT STEPS

### Immediate (Week 1)
1. Деплой на dev environment
2. Тестирование с real data
3. Bug fixes

### Short-term (Week 2-3)
4. Performance testing (1000+ concurrent users)
5. Load testing
6. Optimization

### Mid-term (Week 4-5)
7. Deploy to staging
8. QA testing
9. Security audit

### Production (Week 6-7)
10. Final testing
11. Deploy to production
12. Monitor & iterate

---

## 📞 SUPPORT

**Проблемы?**
- См. `troubleshooting-guide.md` (будет создан)
- См. `performance-tuning-guide.md` (будет создан)

**Вопросы по коду?**
- См. `backend-integration-complete.md` (полная документация)
- См. `developer-guide.md` (примеры и best practices)

---

## История изменений

- v1.0.0 (2025-11-07 00:40) - Step-by-step backend setup guide

