# Backend Integration: Полное руководство

**Версия:** 1.0.0  
**Дата:** 2025-11-07 00:32

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 00:32

---

## Краткое описание

Полное руководство по интеграции системы квестового графа и world state в Java Spring Boot backend.

---

## Архитектура (3 слоя)

### Layer 1: Data Access (Repository)
- JPA Repositories для всех таблиц
- Custom queries для graph traversal
- Caching layer (Redis)

### Layer 2: Business Logic (Service)
- QuestGraphService - работа с графом
- WorldStateService - управление world state
- QuestProgressService - отслеживание прогресса

### Layer 3: API (Controller)
- REST API endpoints
- WebSocket для real-time updates
- GraphQL (опционально)

---

## Entities (JPA)

### Quest.java

```java
@Entity
@Table(name = "quests")
public class Quest {
    @Id
    @Column(length = 100)
    private String id;
    
    @Column(nullable = false, length = 200)
    private String name;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;
    
    @Column(nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private QuestType type;
    
    @Column(length = 50)
    private String category;
    
    @Column(length = 20)
    @Enumerated(EnumType.STRING)
    private QuestDifficulty difficulty;
    
    @Column(name = "min_level", nullable = false)
    private Integer minLevel = 1;
    
    @Column(name = "max_level")
    private Integer maxLevel;
    
    @Type(type = "jsonb")
    @Column(name = "required_quests", columnDefinition = "jsonb")
    private List<String> requiredQuests;
    
    @Type(type = "jsonb")
    @Column(name = "required_flags", columnDefinition = "jsonb")
    private Map<String, Object> requiredFlags;
    
    @Type(type = "jsonb")
    @Column(name = "required_reputation", columnDefinition = "jsonb")
    private Map<String, Integer> requiredReputation;
    
    @Column(name = "required_class", length = 50)
    private String requiredClass;
    
    @Column(name = "has_branches")
    private Boolean hasBranches = false;
    
    @Column(name = "dialogue_tree_root")
    private Integer dialogueTreeRoot;
    
    @Column(nullable = false, length = 20)
    private String era;
    
    @Column(length = 100)
    private String region;
    
    @OneToMany(mappedBy = "quest", cascade = CascadeType.ALL)
    private List<QuestBranch> branches;
    
    @OneToMany(mappedBy = "quest", cascade = CascadeType.ALL)
    private List<DialogueNode> dialogueNodes;
    
    // Getters, setters, constructors
}

public enum QuestType {
    MAIN, SIDE, FACTION, DAILY, WEEKLY, EVENT, DYNAMIC, ROMANTIC
}
```

### QuestBranch.java

```java
@Entity
@Table(name = "quest_branches")
public class QuestBranch {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "quest_id", nullable = false)
    private Quest quest;
    
    @Column(name = "branch_id", nullable = false, length = 50)
    private String branchId;
    
    @Column(name = "branch_name", nullable = false, length = 200)
    private String branchName;
    
    @Type(type = "jsonb")
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> conditions;
    
    @Type(type = "jsonb")
    @Column(name = "reputation_changes", columnDefinition = "jsonb")
    private Map<String, Integer> reputationChanges;
    
    @Type(type = "jsonb")
    @Column(name = "sets_flags", columnDefinition = "jsonb")
    private List<String> setsFlags;
    
    @Type(type = "jsonb")
    @Column(name = "unlocks_quests", columnDefinition = "jsonb")
    private List<String> unlocksQuests;
    
    @Type(type = "jsonb")
    @Column(name = "locks_quests", columnDefinition = "jsonb")
    private List<String> locksQuests;
    
    // Getters, setters
}
```

---

## Repositories

### QuestRepository.java

```java
@Repository
public interface QuestRepository extends JpaRepository<Quest, String> {
    
    @Query("SELECT q FROM Quest q WHERE q.era = :era AND q.isActive = true")
    List<Quest> findByEra(@Param("era") String era);
    
    @Query("SELECT q FROM Quest q WHERE q.type = :type AND q.isActive = true")
    List<Quest> findByType(@Param("type") QuestType type);
    
    @Query(value = "SELECT q.* FROM quests q WHERE q.tags @> :tag::jsonb", nativeQuery = true)
    List<Quest> findByTag(@Param("tag") String tag);
    
    @Query("SELECT q FROM Quest q WHERE q.minLevel <= :level AND (q.maxLevel IS NULL OR q.maxLevel >= :level)")
    List<Quest> findByLevelRange(@Param("level") Integer level);
}
```

### PlayerFlagRepository.java

```java
@Repository
public interface PlayerFlagRepository extends JpaRepository<PlayerFlag, Long> {
    
    @Query("SELECT pf FROM PlayerFlag pf WHERE pf.characterId = :characterId")
    List<PlayerFlag> findByCharacter(@Param("characterId") UUID characterId);
    
    @Query("SELECT pf FROM PlayerFlag pf WHERE pf.characterId = :characterId AND pf.flagKey = :key")
    Optional<PlayerFlag> findByCharacterAndKey(
        @Param("characterId") UUID characterId,
        @Param("key") String key
    );
    
    @Query("SELECT CASE WHEN COUNT(pf) > 0 THEN TRUE ELSE FALSE END " +
           "FROM PlayerFlag pf WHERE pf.characterId = :characterId " +
           "AND pf.flagKey = :key AND pf.flagValue = :value::jsonb")
    boolean hasFlag(
        @Param("characterId") UUID characterId,
        @Param("key") String key,
        @Param("value") String value
    );
}
```

---

## Services

### QuestGraphService.java

```java
@Service
@Slf4j
public class QuestGraphService {
    
    @Autowired
    private QuestRepository questRepository;
    
    @Autowired
    private PlayerFlagRepository flagRepository;
    
    @Autowired
    private QuestProgressRepository progressRepository;
    
    @Autowired
    private WorldStateService worldStateService;
    
    // Cache for quest graph
    private Map<String, QuestNode> questGraph;
    
    @PostConstruct
    public void loadQuestGraph() {
        // Load from JSON file or database
        try {
            ObjectMapper mapper = new ObjectMapper();
            QuestGraphData data = mapper.readValue(
                new ClassPathResource("quest-dependencies-full.json").getFile(),
                QuestGraphData.class
            );
            
            // Build graph
            questGraph = buildGraph(data);
            log.info("Quest graph loaded: {} nodes, {} edges", 
                     data.getNodes().size(), data.getEdges().size());
        } catch (IOException e) {
            log.error("Failed to load quest graph", e);
        }
    }
    
    /**
     * Check if quest is available for character
     */
    public boolean isQuestAvailable(String questId, UUID characterId) {
        Quest quest = questRepository.findById(questId)
            .orElseThrow(() -> new QuestNotFoundException(questId));
        
        // 1. Check if already completed or active
        if (isQuestCompletedOrActive(questId, characterId)) {
            return false;
        }
        
        // 2. Check prerequisites
        if (!checkPrerequisites(quest, characterId)) {
            return false;
        }
        
        // 3. Check flags
        if (!checkRequiredFlags(quest, characterId)) {
            return false;
        }
        
        // 4. Check reputation
        if (!checkRequiredReputation(quest, characterId)) {
            return false;
        }
        
        // 5. Check if blocked
        if (isQuestBlocked(questId, characterId)) {
            return false;
        }
        
        // 6. Check level
        Integer characterLevel = getCharacterLevel(characterId);
        if (characterLevel < quest.getMinLevel()) {
            return false;
        }
        
        if (quest.getMaxLevel() != null && characterLevel > quest.getMaxLevel()) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Get all available quests for character
     */
    public List<QuestSummary> getAvailableQuests(UUID characterId, QuestFilter filter) {
        String era = getCurrentEra();  // Based on server timeline
        List<Quest> allQuests = questRepository.findByEra(era);
        
        return allQuests.stream()
            .filter(q -> isQuestAvailable(q.getId(), characterId))
            .filter(q -> matchesFilter(q, filter))
            .map(this::toQuestSummary)
            .collect(Collectors.toList());
    }
    
    /**
     * Process quest choice
     */
    @Transactional
    public QuestChoiceResult processChoice(UUID characterId, String questId, 
                                           String nodeId, String choiceId) {
        // Get choice
        DialogueChoice choice = dialogueChoiceRepository
            .findByNodeAndChoice(nodeId, choiceId)
            .orElseThrow(() -> new ChoiceNotFoundException(choiceId));
        
        // Apply consequences
        QuestChoiceResult result = new QuestChoiceResult();
        
        // 1. Reputation changes
        if (choice.getReputationChanges() != null) {
            applyReputationChanges(characterId, choice.getReputationChanges());
            result.setReputationChanges(choice.getReputationChanges());
        }
        
        // 2. Set/unset flags
        if (choice.getSetsFlags() != null) {
            choice.getSetsFlags().forEach(flag -> 
                setPlayerFlag(characterId, flag, true, questId)
            );
            result.setFlagsSet(choice.getSetsFlags());
        }
        
        // 3. Give/remove items
        if (choice.getGivesItems() != null) {
            giveItems(characterId, choice.getGivesItems());
            result.setItemsGained(choice.getGivesItems());
        }
        
        // 4. Unlock/block quests
        unlockQuests(characterId, choice.getUnlocksQuests());
        blockQuests(characterId, choice.getBlocksQuests());
        
        result.setUnlockedQuests(choice.getUnlocksQuests());
        result.setBlockedQuests(choice.getBlocksQuests());
        
        // 5. Audit trail
        savePlayerChoice(characterId, questId, nodeId, choiceId, result);
        
        // 6. Check triggers
        checkEventTriggers(characterId, questId, choiceId);
        
        return result;
    }
    
    private boolean checkPrerequisites(Quest quest, UUID characterId) {
        if (quest.getRequiredQuests() == null || quest.getRequiredQuests().isEmpty()) {
            return true;
        }
        
        for (String prereqId : quest.getRequiredQuests()) {
            if (!isQuestCompleted(prereqId, characterId)) {
                return false;
            }
        }
        
        return true;
    }
    
    private boolean checkRequiredFlags(Quest quest, UUID characterId) {
        if (quest.getRequiredFlags() == null || quest.getRequiredFlags().isEmpty()) {
            return true;
        }
        
        for (Map.Entry<String, Object> entry : quest.getRequiredFlags().entrySet()) {
            if (!flagRepository.hasFlag(characterId, entry.getKey(), entry.getValue().toString())) {
                return false;
            }
        }
        
        return true;
    }
}
```

---

## WorldStateService.java

```java
@Service
@Slf4j
public class WorldStateService {
    
    @Autowired
    private PlayerWorldStateRepository playerStateRepo;
    
    @Autowired
    private ServerWorldStateRepository serverStateRepo;
    
    @Autowired
    private FactionWorldStateRepository factionStateRepo;
    
    @Autowired
    private WorldStateVoteRepository voteRepo;
    
    /**
     * Get combined world state for character
     */
    public WorldStateView getWorldState(UUID characterId, String serverId) {
        WorldStateView combined = new WorldStateView();
        
        // 1. Get server state (highest priority for global events)
        Map<String, Object> serverState = serverStateRepo
            .findByServer(serverId)
            .stream()
            .filter(s -> s.getStatus() == StateStatus.ACTIVE)
            .collect(Collectors.toMap(
                ServerWorldState::getStateKey,
                ServerWorldState::getStateValue
            ));
        
        // 2. Get faction state (if character in faction)
        Map<String, Object> factionState = new HashMap<>();
        String factionId = getCharacterFaction(characterId);
        if (factionId != null) {
            factionState = factionStateRepo
                .findByServerAndFaction(serverId, factionId)
                .stream()
                .collect(Collectors.toMap(
                    FactionWorldState::getStateKey,
                    FactionWorldState::getStateValue
                ));
        }
        
        // 3. Get personal state
        Map<String, Object> personalState = playerStateRepo
            .findByCharacter(characterId)
            .stream()
            .collect(Collectors.toMap(
                PlayerWorldState::getStateKey,
                PlayerWorldState::getStateValue
            ));
        
        // 4. Combine with priorities
        combined.setServerState(serverState);
        combined.setFactionState(factionState);
        combined.setPersonalState(personalState);
        
        // 5. Create merged view
        Map<String, Object> merged = new HashMap<>(serverState);
        merged.putAll(factionState);
        merged.putAll(personalState);  // Personal overrides for personal quests
        
        combined.setMergedView(merged);
        
        return combined;
    }
    
    /**
     * Cast vote for server state change
     */
    @Transactional
    public VoteResult castVote(UUID characterId, String serverId,
                                String stateKey, Object voteValue) {
        // 1. Calculate vote weight (reputation-based)
        int weight = calculateVoteWeight(characterId);
        
        // 2. Save/update vote
        WorldStateVote vote = voteRepo
            .findByServerAndCharacterAndKey(serverId, characterId, stateKey)
            .orElse(new WorldStateVote());
        
        vote.setServerId(serverId);
        vote.setCharacterId(characterId);
        vote.setStateKey(stateKey);
        vote.setVoteValue(voteValue);
        vote.setWeight(weight);
        voteRepo.save(vote);
        
        // 3. Check if threshold reached
        ServerWorldState serverState = serverStateRepo
            .findByServerAndKey(serverId, stateKey)
            .orElseThrow(() -> new StateNotFoundException(stateKey));
        
        int totalVotes = voteRepo.countByServerAndKey(serverId, stateKey);
        int totalWeight = voteRepo.sumWeightByServerAndKey(serverId, stateKey);
        
        VoteResult result = new VoteResult();
        result.setVoteRecorded(true);
        result.setCurrentVotes(totalVotes);
        result.setCurrentWeight(totalWeight);
        result.setThresholdRequired(serverState.getThresholdRequired());
        
        // 4. Apply change if threshold reached
        if (totalWeight >= serverState.getThresholdRequired()) {
            Object winningValue = calculateWinningVote(serverId, stateKey);
            serverState.setStateValue(winningValue);
            serverState.setStatus(StateStatus.ACTIVE);
            serverState.setActivatedAt(Instant.now());
            serverStateRepo.save(serverState);
            
            result.setStatus(VoteStatus.ACTIVE);
            result.setStateValue(winningValue);
            
            // 5. Trigger consequences
            triggerWorldStateChange(serverId, stateKey, winningValue);
            
            // 6. Notify players via WebSocket
            notifyWorldStateChange(serverId, stateKey, winningValue);
        } else {
            result.setStatus(VoteStatus.PENDING);
        }
        
        return result;
    }
    
    /**
     * Update territory control
     */
    @Transactional
    public void updateTerritoryControl(String serverId, String territoryId,
                                       String factionId, int contribution) {
        TerritoryControl territory = territoryRepo
            .findByServerAndTerritory(serverId, territoryId)
            .orElse(new TerritoryControl(serverId, territoryId));
        
        // Calculate new control percentage
        int currentControl = territory.getControlPercentage();
        int newControl = Math.min(100, currentControl + contribution);
        
        // Check if control changed
        if (newControl >= 51 && !factionId.equals(territory.getControllingFaction())) {
            // Faction takes control
            territory.setPreviousController(territory.getControllingFaction());
            territory.setControllingFaction(factionId);
            territory.setControlChangedAt(Instant.now());
            
            // Notify about territory change
            notifyTerritoryChange(serverId, territoryId, factionId);
        }
        
        territory.setControlPercentage(newControl);
        territory.setContested(newControl < 90);  // Contested if < 90%
        territoryRepo.save(territory);
    }
}
```

---

## Controllers

### QuestController.java

```java
@RestController
@RequestMapping("/api/v1/narrative/quests")
@Slf4j
public class QuestController {
    
    @Autowired
    private QuestGraphService questGraphService;
    
    @Autowired
    private QuestProgressService progressService;
    
    /**
     * Get available quests for character
     */
    @GetMapping("/available")
    public ResponseEntity<QuestListResponse> getAvailableQuests(
            @RequestParam UUID characterId,
            @RequestParam(required = false) String era,
            @RequestParam(required = false) String type) {
        
        QuestFilter filter = new QuestFilter();
        filter.setEra(era);
        filter.setType(type);
        
        List<QuestSummary> quests = questGraphService.getAvailableQuests(characterId, filter);
        
        QuestListResponse response = new QuestListResponse();
        response.setQuests(quests);
        response.setTotal(quests.size());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get quest details
     */
    @GetMapping("/{questId}")
    public ResponseEntity<QuestDetailResponse> getQuestDetails(
            @PathVariable String questId,
            @RequestParam UUID characterId) {
        
        Quest quest = questRepository.findById(questId)
            .orElseThrow(() -> new QuestNotFoundException(questId));
        
        boolean available = questGraphService.isQuestAvailable(questId, characterId);
        List<String> blockedBy = available ? Collections.emptyList() : 
                                  questGraphService.getBlockReasons(questId, characterId);
        
        QuestDetailResponse response = new QuestDetailResponse();
        response.setQuest(quest);
        response.setAvailable(available);
        response.setBlockedBy(blockedBy);
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Make quest choice
     */
    @PostMapping("/{questId}/choice")
    public ResponseEntity<QuestChoiceResult> makeChoice(
            @PathVariable String questId,
            @RequestBody QuestChoiceRequest request) {
        
        // Validate quest is active for character
        if (!progressService.isQuestActive(request.getCharacterId(), questId)) {
            return ResponseEntity.badRequest().build();
        }
        
        // Process choice
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

### WorldStateController.java

```java
@RestController
@RequestMapping("/api/v1/narrative/world-state")
public class WorldStateController {
    
    @Autowired
    private WorldStateService worldStateService;
    
    /**
     * Get combined world state
     */
    @GetMapping
    public ResponseEntity<WorldStateView> getWorldState(
            @RequestParam UUID characterId,
            @RequestParam String serverId) {
        
        WorldStateView state = worldStateService.getWorldState(characterId, serverId);
        return ResponseEntity.ok(state);
    }
    
    /**
     * Cast vote for server state
     */
    @PostMapping("/vote")
    public ResponseEntity<VoteResult> castVote(@RequestBody VoteRequest request) {
        VoteResult result = worldStateService.castVote(
            request.getCharacterId(),
            request.getServerId(),
            request.getStateKey(),
            request.getVoteValue()
        );
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * Get territory control
     */
    @GetMapping("/territory-control")
    public ResponseEntity<List<TerritoryControl>> getTerritoryControl(
            @RequestParam String serverId,
            @RequestParam(required = false) String territoryId) {
        
        List<TerritoryControl> territories;
        if (territoryId != null) {
            territories = Collections.singletonList(
                territoryRepo.findByServerAndTerritory(serverId, territoryId)
                    .orElseThrow(() -> new TerritoryNotFoundException(territoryId))
            );
        } else {
            territories = territoryRepo.findByServer(serverId);
        }
        
        return ResponseEntity.ok(territories);
    }
}
```

---

## WebSocket Integration

### WebSocketConfig.java

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

### WorldStateNotificationService.java

```java
@Service
public class WorldStateNotificationService {
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    /**
     * Notify all players on server about world state change
     */
    public void notifyWorldStateChange(String serverId, String stateKey, Object newValue) {
        WorldStateChangeEvent event = new WorldStateChangeEvent();
        event.setServerId(serverId);
        event.setStateKey(stateKey);
        event.setNewValue(newValue);
        event.setTimestamp(Instant.now());
        
        // Send to all players on server
        messagingTemplate.convertAndSend(
            "/topic/server/" + serverId + "/world-state",
            event
        );
        
        log.info("World state changed: server={}, key={}", serverId, stateKey);
    }
    
    /**
     * Notify character about quest unlocked
     */
    public void notifyQuestUnlocked(UUID characterId, String questId, String unlockedBy) {
        QuestUnlockedEvent event = new QuestUnlockedEvent();
        event.setCharacterId(characterId);
        event.setQuestId(questId);
        event.setUnlockedBy(unlockedBy);
        event.setTimestamp(Instant.now());
        
        // Send to specific character
        messagingTemplate.convertAndSendToUser(
            characterId.toString(),
            "/queue/quests",
            event
        );
    }
}
```

---

## Caching Strategy

### RedisConfig.java

```java
@Configuration
@EnableCaching
public class RedisConfig {
    
    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .disableCachingNullValues()
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(factory)
            .cacheDefaults(config)
            .withCacheConfiguration("questGraph",
                RedisCacheConfiguration.defaultCacheConfig().entryTtl(Duration.ofHours(1)))
            .withCacheConfiguration("worldState",
                RedisCacheConfiguration.defaultCacheConfig().entryTtl(Duration.ofMinutes(5)))
            .build();
    }
}
```

### Использование

```java
@Service
public class QuestGraphService {
    
    @Cacheable(value = "questGraph", key = "#questId")
    public Quest getQuest(String questId) {
        return questRepository.findById(questId)
            .orElseThrow(() -> new QuestNotFoundException(questId));
    }
    
    @Cacheable(value = "worldState", key = "#serverId + ':' + #stateKey")
    public ServerWorldState getServerState(String serverId, String stateKey) {
        return serverStateRepo.findByServerAndKey(serverId, stateKey)
            .orElse(null);
    }
    
    @CacheEvict(value = "worldState", key = "#serverId + ':' + #stateKey")
    public void invalidateServerState(String serverId, String stateKey) {
        // Cache automatically evicted
    }
}
```

---

## Performance Optimization

### Database Connection Pool

```yaml
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

### Query Optimization

```java
// Batch loading
@EntityGraph(attributePaths = {"branches", "dialogueNodes"})
List<Quest> findAllWithBranchesAndDialogue();

// Pagination
Page<Quest> findByEra(String era, Pageable pageable);

// Projection for list views
@Query("SELECT new QuestSummary(q.id, q.name, q.type, q.minLevel) " +
       "FROM Quest q WHERE q.era = :era")
List<QuestSummary> findSummariesByEra(@Param("era") String era);
```

---

## Testing

### Integration Test

```java
@SpringBootTest
@AutoConfigureTestDatabase
class QuestGraphServiceIntegrationTest {
    
    @Autowired
    private QuestGraphService questGraphService;
    
    @Test
    void testQuestAvailability_withPrerequisites() {
        // Given
        UUID characterId = createTestCharacter();
        completeQuest(characterId, "MQ-2020-001");
        
        // When
        boolean available = questGraphService.isQuestAvailable("MQ-2020-002", characterId);
        
        // Then
        assertTrue(available);
    }
    
    @Test
    void testQuestBlocked_afterMutualExclusion() {
        // Given
        UUID characterId = createTestCharacter();
        makeChoice(characterId, "MQ-2020-005", "choice_netwatch");
        
        // When
        boolean available = questGraphService.isQuestAvailable("SQ-2030-VB-001", characterId);
        
        // Then
        assertFalse(available);
    }
    
    @Test
    void testWorldStateVoting_threshold() {
        // Given
        String serverId = "server-01";
        String stateKey = "test_state";
        int threshold = 100;
        
        // When
        for (int i = 0; i < 120; i++) {
            UUID charId = UUID.randomUUID();
            worldStateService.castVote(charId, serverId, stateKey, "value_a");
        }
        
        // Then
        ServerWorldState state = serverStateRepo.findByServerAndKey(serverId, stateKey).get();
        assertEquals(StateStatus.ACTIVE, state.getStatus());
    }
}
```

---

## Deployment Checklist

- [ ] SQL migrations applied
- [ ] YAML files converted to JSON
- [ ] JSON files loaded to classpath/resources
- [ ] Quest graph initialized (@PostConstruct)
- [ ] Redis configured and running
- [ ] Database indexes created
- [ ] WebSocket endpoints tested
- [ ] Integration tests passing
- [ ] Performance tests done (1000+ concurrent players)
- [ ] Monitoring configured (quest completion rates, state changes)

---

## Historia изменений

- v1.0.0 (2025-11-07 00:32) - Complete backend integration guide

