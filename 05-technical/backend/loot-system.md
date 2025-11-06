---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Полная система лута. Loot generation (из таблиц), drops (NPC, containers), distribution (solo/party/raid), roll system (need/greed), personal/shared loot, boss loot, instancing.
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-129: api/v1/loot/loot-generation.yaml (2025-11-07 10:15)
- Last Updated: 2025-11-07 00:18
---



# Loot System - Система генерации и распределения лута

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

---

## Краткое описание

**Loot System** - критически важная система для генерации и распределения добычи. Без этой системы в игре нет progression (нет наград за убийство врагов, открытие контейнеров, выполнение квестов). Обеспечивает справедливое распределение лута между игроками.

**Ключевые возможности:**
- ✅ Loot generation (из loot tables с весами)
- ✅ Loot drops (когда NPC умирает, контейнер открывается)
- ✅ Loot distribution (solo, party, raid)
- ✅ Roll system (need/greed/pass)
- ✅ Personal loot vs shared loot
- ✅ Boss loot (гарантированный + случайный)
- ✅ Loot instancing (каждый видит свой лут)
- ✅ Auto-loot settings
- ✅ Loot history (кто что получил)

---

## Архитектура системы

### Loot Flow

```
NPC/Container Death/Open
    ↓
Generate Loot (from loot tables)
    ↓
Determine Loot Mode (personal/shared)
    ↓
IF PERSONAL:
    Each player gets own loot
    → Directly to inventory
    
IF SHARED:
    Create world drop
    → Players roll (need/greed/pass)
    → Winner gets item
    
Boss Loot:
    Guaranteed items for all
    + Random items (shared/rolled)
```

---

## Database Schema

### Таблица `loot_tables`

```sql
CREATE TABLE loot_tables (
    id VARCHAR(100) PRIMARY KEY,
    
    -- Название
    table_name VARCHAR(200) NOT NULL,
    
    -- Тип
    table_type VARCHAR(50) NOT NULL,
    -- NPC_LOOT, CONTAINER_LOOT, BOSS_LOOT, QUEST_REWARD
    
    -- Связь с источником
    source_id VARCHAR(100), -- NPC ID, Container ID, Boss ID
    
    -- Min/Max items to drop
    min_items INTEGER DEFAULT 1,
    max_items INTEGER DEFAULT 3,
    
    -- Currency
    min_eddies INTEGER DEFAULT 0,
    max_eddies INTEGER DEFAULT 100,
    
    -- Entries (items)
    entries JSONB NOT NULL,
    -- [
    --   {item_template_id: "weapon_pistol", weight: 10, min_qty: 1, max_qty: 1},
    --   {item_template_id: "ammo_pistol", weight: 50, min_qty: 10, max_qty: 50},
    --   ...
    -- ]
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_loot_tables_source ON loot_tables(source_id);
CREATE INDEX idx_loot_tables_type ON loot_tables(table_type);
```

### Таблица `world_drops`

```sql
CREATE TABLE world_drops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Location
    zone_id VARCHAR(100) NOT NULL,
    position_x DECIMAL(10,2) NOT NULL,
    position_y DECIMAL(10,2) NOT NULL,
    position_z DECIMAL(10,2) NOT NULL,
    
    -- Source
    source_type VARCHAR(50) NOT NULL,
    -- NPC_DEATH, CONTAINER_OPEN, PLAYER_DROP
    
    source_id VARCHAR(100), -- NPC ID, Container ID
    
    -- Items
    items JSONB NOT NULL,
    -- [
    --   {item_template_id: "weapon_pistol", quantity: 1},
    --   {item_template_id: "eddies", quantity: 150},
    --   ...
    -- ]
    
    -- Ownership (для personal loot)
    owner_character_id UUID, -- Если personal loot
    party_id UUID, -- Если party loot
    
    -- Loot mode
    loot_mode VARCHAR(20) DEFAULT 'FREE_FOR_ALL',
    -- FREE_FOR_ALL, PERSONAL, PARTY_ROLL, MASTER_LOOTER
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE',
    -- ACTIVE, LOOTED, EXPIRED
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL, -- Auto-cleanup after 5 minutes
    looted_at TIMESTAMP,
    
    CONSTRAINT fk_drop_owner FOREIGN KEY (owner_character_id) 
        REFERENCES characters(id) ON DELETE SET NULL,
    CONSTRAINT fk_drop_party FOREIGN KEY (party_id) 
        REFERENCES parties(id) ON DELETE SET NULL
);

CREATE INDEX idx_drops_zone ON world_drops(zone_id, status);
CREATE INDEX idx_drops_owner ON world_drops(owner_character_id, status);
CREATE INDEX idx_drops_party ON world_drops(party_id, status);
CREATE INDEX idx_drops_expires ON world_drops(expires_at) WHERE status = 'ACTIVE';
```

### Таблица `loot_rolls`

```sql
CREATE TABLE loot_rolls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    world_drop_id UUID NOT NULL,
    item_template_id VARCHAR(100) NOT NULL,
    
    -- Party context
    party_id UUID NOT NULL,
    
    -- Rolls
    rolls JSONB DEFAULT '[]',
    -- [
    --   {character_id: "uuid", roll_type: "NEED", roll_value: 85},
    --   {character_id: "uuid", roll_type: "GREED", roll_value: 42},
    --   {character_id: "uuid", roll_type: "PASS", roll_value: null},
    --   ...
    -- ]
    
    -- Winner
    winner_character_id UUID,
    winner_roll_type VARCHAR(10),
    winner_roll_value INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'PENDING',
    -- PENDING, COMPLETED, EXPIRED
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    expires_at TIMESTAMP NOT NULL, -- 60 seconds to roll
    
    CONSTRAINT fk_roll_drop FOREIGN KEY (world_drop_id) 
        REFERENCES world_drops(id) ON DELETE CASCADE,
    CONSTRAINT fk_roll_party FOREIGN KEY (party_id) 
        REFERENCES parties(id) ON DELETE CASCADE,
    CONSTRAINT fk_roll_winner FOREIGN KEY (winner_character_id) 
        REFERENCES characters(id) ON DELETE SET NULL
);

CREATE INDEX idx_rolls_drop ON loot_rolls(world_drop_id);
CREATE INDEX idx_rolls_party ON loot_rolls(party_id, status);
CREATE INDEX idx_rolls_expires ON loot_rolls(expires_at) WHERE status = 'PENDING';
```

### Таблица `loot_history`

```sql
CREATE TABLE loot_history (
    id BIGSERIAL PRIMARY KEY,
    character_id UUID NOT NULL,
    
    -- Item
    item_template_id VARCHAR(100) NOT NULL,
    quantity INTEGER DEFAULT 1,
    
    -- Source
    source_type VARCHAR(50) NOT NULL,
    -- NPC_LOOT, CONTAINER, BOSS, QUEST, ROLL_WON
    
    source_id VARCHAR(100),
    
    -- Context
    party_id UUID,
    zone_id VARCHAR(100),
    
    -- Timestamp
    looted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_loot_history_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE
);

CREATE INDEX idx_loot_history_character ON loot_history(character_id, looted_at DESC);
CREATE INDEX idx_loot_history_source ON loot_history(source_type, source_id);
```

---

## Loot Generation

### Генерация лута из таблицы

```java
@Service
public class LootService {
    
    @Autowired
    private LootTableRepository lootTableRepository;
    
    @Autowired
    private ItemTemplateRepository itemTemplateRepository;
    
    public LootResult generateLoot(String lootTableId, LootContext context) {
        // 1. Получить loot table
        LootTable table = lootTableRepository.findById(lootTableId)
            .orElseThrow(() -> new LootTableNotFoundException());
        
        // 2. Определить количество предметов
        int itemCount = random.nextInt(
            table.getMaxItems() - table.getMinItems() + 1
        ) + table.getMinItems();
        
        // 3. Сгенерировать предметы
        List<LootItem> items = new ArrayList<>();
        
        for (int i = 0; i < itemCount; i++) {
            LootItem item = rollItem(table, context);
            if (item != null) {
                items.add(item);
            }
        }
        
        // 4. Сгенерировать валюту
        int eddies = 0;
        if (table.getMaxEddies() > 0) {
            eddies = random.nextInt(
                table.getMaxEddies() - table.getMinEddies() + 1
            ) + table.getMinEddies();
            
            // Применить multipliers
            eddies = (int) (eddies * context.getEddiesMultiplier());
        }
        
        if (eddies > 0) {
            items.add(new LootItem("eddies", eddies));
        }
        
        return new LootResult(items);
    }
    
    private LootItem rollItem(LootTable table, LootContext context) {
        // 1. Получить entries
        List<LootEntry> entries = table.getEntries();
        
        // 2. Применить luck modifier
        entries = applyLuckModifier(entries, context.getLuckModifier());
        
        // 3. Weighted random selection
        int totalWeight = entries.stream()
            .mapToInt(LootEntry::getWeight)
            .sum();
        
        int roll = random.nextInt(totalWeight);
        int current = 0;
        
        for (LootEntry entry : entries) {
            current += entry.getWeight();
            if (roll < current) {
                // Выбран этот item
                int quantity = random.nextInt(
                    entry.getMaxQuantity() - entry.getMinQuantity() + 1
                ) + entry.getMinQuantity();
                
                return new LootItem(entry.getItemTemplateId(), quantity);
            }
        }
        
        return null;
    }
    
    private List<LootEntry> applyLuckModifier(List<LootEntry> entries, double luckMod) {
        // Luck увеличивает шанс редких предметов
        return entries.stream()
            .map(entry -> {
                ItemTemplate template = itemTemplateRepository
                    .findById(entry.getItemTemplateId()).get();
                
                int adjustedWeight = entry.getWeight();
                
                // Увеличиваем вес для редких предметов
                switch (template.getRarity()) {
                    case RARE:
                        adjustedWeight *= (1 + luckMod * 0.1);
                        break;
                    case EPIC:
                        adjustedWeight *= (1 + luckMod * 0.2);
                        break;
                    case LEGENDARY:
                        adjustedWeight *= (1 + luckMod * 0.3);
                        break;
                }
                
                return entry.withWeight(adjustedWeight);
            })
            .collect(Collectors.toList());
    }
}
```

### Loot Context

```java
public class LootContext {
    private UUID killerId; // Кто убил/открыл
    private int killerLevel;
    private double luckModifier; // Luck stat modifier
    private double eddiesMultiplier; // Event multiplier
    private boolean isBoss; // Boss loot gets bonus
    private DifficultyLevel difficulty;
    
    // ... getters/setters
}
```

---

## Loot Distribution

### Solo Loot (личный лут)

```java
@Transactional
public void createSoloLoot(
    UUID characterId,
    String lootTableId,
    LootSource source
) {
    // 1. Сгенерировать лут
    Character character = characterRepository.findById(characterId).get();
    
    LootContext context = new LootContext();
    context.setKillerId(characterId);
    context.setKillerLevel(character.getLevel());
    context.setLuckModifier(getLuckModifier(character));
    
    LootResult loot = generateLoot(lootTableId, context);
    
    // 2. Создать world drop (personal)
    WorldDrop drop = new WorldDrop();
    drop.setZoneId(character.getCurrentZone());
    drop.setPosition(getCharacterPosition(characterId));
    drop.setSourceType(source.getType());
    drop.setSourceId(source.getId());
    drop.setItems(loot.getItems());
    drop.setOwnerCharacterId(characterId); // Personal ownership
    drop.setLootMode(LootMode.PERSONAL);
    drop.setExpiresAt(Instant.now().plus(Duration.ofMinutes(5)));
    
    worldDropRepository.save(drop);
    
    // 3. Уведомить игрока
    notificationService.send(
        getAccountId(characterId),
        new LootDroppedNotification(loot.getItems().size())
    );
    
    log.info("Created personal loot drop {} for character {}", drop.getId(), characterId);
}
```

### Party Loot (групповой лут)

```java
@Transactional
public void createPartyLoot(
    UUID partyId,
    String lootTableId,
    LootSource source,
    Vector3 position,
    String zoneId
) {
    // 1. Получить party
    Party party = partyRepository.findById(partyId)
        .orElseThrow(() -> new PartyNotFoundException());
    
    // 2. Определить loot mode
    LootMode lootMode = party.getLootMode();
    
    if (lootMode == LootMode.PERSONAL) {
        // Каждый участник получает свой лут
        for (UUID memberId : party.getMembers()) {
            createSoloLoot(memberId, lootTableId, source);
        }
        return;
    }
    
    // 3. Сгенерировать общий лут
    // Используем лидера party для context
    UUID leaderId = party.getLeaderId();
    Character leader = characterRepository.findById(leaderId).get();
    
    LootContext context = new LootContext();
    context.setKillerId(leaderId);
    context.setKillerLevel(leader.getLevel());
    context.setLuckModifier(getPartyAverageLuck(party));
    
    LootResult loot = generateLoot(lootTableId, context);
    
    // 4. Создать world drop (shared)
    WorldDrop drop = new WorldDrop();
    drop.setZoneId(zoneId);
    drop.setPosition(position);
    drop.setSourceType(source.getType());
    drop.setSourceId(source.getId());
    drop.setItems(loot.getItems());
    drop.setPartyId(partyId);
    drop.setLootMode(lootMode); // PARTY_ROLL or MASTER_LOOTER
    drop.setExpiresAt(Instant.now().plus(Duration.ofMinutes(5)));
    
    worldDropRepository.save(drop);
    
    // 5. Уведомить всю party
    for (UUID memberId : party.getMembers()) {
        notificationService.send(
            getAccountId(memberId),
            new PartyLootDroppedNotification(loot.getItems().size())
        );
    }
    
    log.info("Created party loot drop {} for party {}", drop.getId(), partyId);
}
```

---

## Loot Roll System

### Start Roll

```java
@Transactional
public void startLootRoll(UUID worldDropId, String itemTemplateId, UUID partyId) {
    // 1. Создать loot roll
    LootRoll roll = new LootRoll();
    roll.setWorldDropId(worldDropId);
    roll.setItemTemplateId(itemTemplateId);
    roll.setPartyId(partyId);
    roll.setExpiresAt(Instant.now().plus(Duration.ofSeconds(60)));
    roll.setStatus(RollStatus.PENDING);
    
    rollRepository.save(roll);
    
    // 2. Уведомить всех участников party
    Party party = partyRepository.findById(partyId).get();
    ItemTemplate template = itemTemplateRepository.findById(itemTemplateId).get();
    
    for (UUID memberId : party.getMembers()) {
        webSocketService.sendToPlayer(
            getAccountId(memberId),
            new LootRollStartedMessage(
                roll.getId(),
                template.getItemName(),
                template.getRarity(),
                60 // seconds
            )
        );
    }
    
    log.info("Started loot roll {} for item {} in party {}", 
        roll.getId(), itemTemplateId, partyId);
}
```

### Submit Roll

```java
@Transactional
public void submitRoll(UUID rollId, UUID characterId, RollType rollType) {
    // 1. Получить roll
    LootRoll roll = rollRepository.findById(rollId)
        .orElseThrow(() -> new LootRollNotFoundException());
    
    if (roll.getStatus() != RollStatus.PENDING) {
        throw new RollAlreadyCompletedException();
    }
    
    // 2. Проверить, что игрок в party
    Party party = partyRepository.findById(roll.getPartyId()).get();
    if (!party.getMembers().contains(characterId)) {
        throw new NotInPartyException();
    }
    
    // 3. Проверить, что еще не rollil
    List<PlayerRoll> rolls = roll.getRolls();
    if (rolls.stream().anyMatch(r -> r.getCharacterId().equals(characterId))) {
        throw new AlreadyRolledException();
    }
    
    // 4. Добавить roll
    PlayerRoll playerRoll = new PlayerRoll();
    playerRoll.setCharacterId(characterId);
    playerRoll.setRollType(rollType);
    
    if (rollType != RollType.PASS) {
        playerRoll.setRollValue(random.nextInt(100) + 1); // 1-100
    }
    
    rolls.add(playerRoll);
    roll.setRolls(rolls);
    rollRepository.save(roll);
    
    // 5. Уведомить party о roll
    for (UUID memberId : party.getMembers()) {
        webSocketService.sendToPlayer(
            getAccountId(memberId),
            new PlayerRolledMessage(
                getCharacterName(characterId),
                rollType,
                playerRoll.getRollValue()
            )
        );
    }
    
    // 6. Проверить, все ли проголосовали
    if (rolls.size() == party.getMembers().size()) {
        completeRoll(roll);
    }
    
    log.info("Character {} rolled {} ({}) for roll {}", 
        characterId, rollType, playerRoll.getRollValue(), rollId);
}
```

### Complete Roll

```java
@Transactional
private void completeRoll(LootRoll roll) {
    // 1. Определить победителя
    List<PlayerRoll> rolls = roll.getRolls();
    
    // Приоритет: NEED > GREED > PASS
    // Внутри категории: highest roll
    
    Optional<PlayerRoll> winner = rolls.stream()
        .filter(r -> r.getRollType() == RollType.NEED)
        .max(Comparator.comparing(PlayerRoll::getRollValue));
    
    if (winner.isEmpty()) {
        winner = rolls.stream()
            .filter(r -> r.getRollType() == RollType.GREED)
            .max(Comparator.comparing(PlayerRoll::getRollValue));
    }
    
    if (winner.isEmpty()) {
        // Все сделали PASS, item остается на земле
        roll.setStatus(RollStatus.COMPLETED);
        rollRepository.save(roll);
        
        log.info("Roll {} completed with no winner (all passed)", roll.getId());
        return;
    }
    
    // 2. Обновить roll
    PlayerRoll winnerRoll = winner.get();
    roll.setWinnerCharacterId(winnerRoll.getCharacterId());
    roll.setWinnerRollType(winnerRoll.getRollType());
    roll.setWinnerRollValue(winnerRoll.getRollValue());
    roll.setStatus(RollStatus.COMPLETED);
    roll.setCompletedAt(Instant.now());
    rollRepository.save(roll);
    
    // 3. Дать item победителю
    inventoryService.addItem(
        winnerRoll.getCharacterId(),
        roll.getItemTemplateId(),
        1,
        "ROLL_WON"
    );
    
    // 4. Записать в loot history
    lootHistoryRepository.save(new LootHistory(
        winnerRoll.getCharacterId(),
        roll.getItemTemplateId(),
        1,
        "ROLL_WON",
        roll.getWorldDropId().toString()
    ));
    
    // 5. Уведомить party
    Party party = partyRepository.findById(roll.getPartyId()).get();
    ItemTemplate template = itemTemplateRepository.findById(roll.getItemTemplateId()).get();
    
    for (UUID memberId : party.getMembers()) {
        webSocketService.sendToPlayer(
            getAccountId(memberId),
            new RollCompletedMessage(
                getCharacterName(winnerRoll.getCharacterId()),
                template.getItemName(),
                winnerRoll.getRollType(),
                winnerRoll.getRollValue()
            )
        );
    }
    
    log.info("Roll {} completed, winner: {} with {} ({})", 
        roll.getId(), 
        winnerRoll.getCharacterId(), 
        winnerRoll.getRollValue(),
        winnerRoll.getRollType());
}
```

### Handle Expired Rolls

```java
@Scheduled(fixedDelay = 10000) // Каждые 10 секунд
public void handleExpiredRolls() {
    List<LootRoll> expiredRolls = rollRepository
        .findExpiredPending(Instant.now());
    
    for (LootRoll roll : expiredRolls) {
        // Автоматически PASS для тех, кто не проголосовал
        Party party = partyRepository.findById(roll.getPartyId()).get();
        List<PlayerRoll> rolls = roll.getRolls();
        
        for (UUID memberId : party.getMembers()) {
            boolean hasRolled = rolls.stream()
                .anyMatch(r -> r.getCharacterId().equals(memberId));
            
            if (!hasRolled) {
                PlayerRoll autoPass = new PlayerRoll();
                autoPass.setCharacterId(memberId);
                autoPass.setRollType(RollType.PASS);
                rolls.add(autoPass);
            }
        }
        
        roll.setRolls(rolls);
        rollRepository.save(roll);
        
        // Завершить roll
        completeRoll(roll);
        
        log.info("Auto-completed expired roll {}", roll.getId());
    }
}
```

---

## Boss Loot

### Guaranteed Boss Loot

```java
@Transactional
public void createBossLoot(
    UUID bossId,
    UUID killerId,
    UUID partyId,
    Vector3 position,
    String zoneId
) {
    // 1. Получить boss loot table
    String bossLootTableId = "boss_" + bossId;
    
    // 2. Гарантированные items для всех
    List<String> guaranteedItems = getBossGuaranteedItems(bossId);
    
    if (partyId != null) {
        Party party = partyRepository.findById(partyId).get();
        
        // Каждый член party получает гарантированный лут
        for (UUID memberId : party.getMembers()) {
            for (String itemId : guaranteedItems) {
                inventoryService.addItem(memberId, itemId, 1, "BOSS_GUARANTEED");
            }
        }
    } else {
        // Solo kill
        for (String itemId : guaranteedItems) {
            inventoryService.addItem(killerId, itemId, 1, "BOSS_GUARANTEED");
        }
    }
    
    // 3. Случайный boss loot (shared, с rollами)
    if (partyId != null) {
        createPartyLoot(partyId, bossLootTableId, 
            new LootSource("BOSS", bossId.toString()), position, zoneId);
    } else {
        createSoloLoot(killerId, bossLootTableId, 
            new LootSource("BOSS", bossId.toString()));
    }
    
    // 4. Опубликовать achievement
    achievementService.checkBossKillAchievement(killerId, bossId);
    
    log.info("Created boss loot for boss {}, killer {}, party {}", 
        bossId, killerId, partyId);
}
```

---

## Auto-Loot Settings

### Auto-Loot Configuration

```java
public class AutoLootSettings {
    private boolean enabled = false;
    
    // Auto-loot by rarity
    private boolean autoLootCommon = true;
    private boolean autoLootUncommon = true;
    private boolean autoLootRare = false;
    private boolean autoLootEpic = false;
    private boolean autoLootLegendary = false;
    
    // Auto-loot by type
    private boolean autoLootCurrency = true;
    private boolean autoLootMaterials = true;
    private boolean autoLootConsumables = false;
    private boolean autoLootEquipment = false;
    
    // ... getters/setters
}
```

### Apply Auto-Loot

```java
@Transactional
public void applyAutoLoot(UUID characterId, UUID worldDropId) {
    // 1. Получить settings
    AutoLootSettings settings = getAutoLootSettings(characterId);
    
    if (!settings.isEnabled()) {
        return;
    }
    
    // 2. Получить drop
    WorldDrop drop = worldDropRepository.findById(worldDropId).get();
    
    // 3. Проверить ownership
    if (drop.getOwnerCharacterId() != null && 
        !drop.getOwnerCharacterId().equals(characterId)) {
        return; // Not owner
    }
    
    // 4. Auto-loot eligible items
    List<LootItem> items = drop.getItems();
    List<LootItem> remaining = new ArrayList<>();
    
    for (LootItem item : items) {
        ItemTemplate template = itemTemplateRepository
            .findById(item.getItemTemplateId()).get();
        
        boolean shouldAutoLoot = checkAutoLootEligible(template, settings);
        
        if (shouldAutoLoot) {
            // Add to inventory
            try {
                inventoryService.addItem(
                    characterId,
                    item.getItemTemplateId(),
                    item.getQuantity(),
                    "AUTO_LOOT"
                );
            } catch (InventoryFullException e) {
                // Can't auto-loot, leave on ground
                remaining.add(item);
            }
        } else {
            remaining.add(item);
        }
    }
    
    // 5. Обновить drop
    if (remaining.isEmpty()) {
        // Весь лут забран
        drop.setStatus(DropStatus.LOOTED);
        drop.setLootedAt(Instant.now());
    } else {
        drop.setItems(remaining);
    }
    
    worldDropRepository.save(drop);
}
```

---

## API Endpoints

### Loot Management

**GET `/api/v1/loot/drops/nearby`** - лут рядом с игроком
```json
{
  "drops": [
    {
      "id": "uuid",
      "position": {"x": 1234, "y": 5678, "z": 10},
      "distance": 5.2,
      "items": [
        {
          "itemId": "mantis_blades",
          "name": "Mantis Blades",
          "quantity": 1,
          "rarity": "LEGENDARY"
        }
      ],
      "canLoot": true,
      "expiresIn": 240
    }
  ]
}
```

**POST `/api/v1/loot/pickup`** - подобрать лут
```json
Request:
{
  "dropId": "uuid",
  "itemIds": ["item1", "item2"] // null = all
}

Response:
{
  "pickedUp": 2,
  "remaining": 1,
  "inventoryFull": false
}
```

### Loot Rolls

**GET `/api/v1/loot/rolls/active`** - активные rollы
**POST `/api/v1/loot/rolls/{id}/roll`** - проголосовать
```json
Request:
{
  "rollType": "NEED | GREED | PASS"
}
```

### Loot History

**GET `/api/v1/loot/history`** - история лута
```json
{
  "history": [
    {
      "item": "Mantis Blades",
      "quantity": 1,
      "source": "BOSS",
      "lootedAt": "2025-11-07T05:00:00Z"
    },
    ...
  ],
  "page": 1,
  "total": 150
}
```

### Auto-Loot Settings

**GET `/api/v1/loot/settings`** - настройки auto-loot
**PUT `/api/v1/loot/settings`** - обновить настройки

---

## Интеграция с другими системами

### При убийстве NPC

```
CombatService.npcDeath()
  ↓
→ LootService: generate loot
→ WorldDropService: create world drop
→ QuestService: check quest objectives (kill 10 NPCs)
→ AchievementService: check kill achievements
→ EventBus: publish NPC_KILLED
```

### При получении лута

```
LootService.pickupItem()
  ↓
→ InventoryService: add item to inventory
→ QuestService: check quest objectives (collect 10 items)
→ AchievementService: check collection achievements
→ NotificationService: send pickup notification
→ LootHistoryService: record loot
→ EventBus: publish ITEM_LOOTED
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/inventory-system.md` - Inventory management
- `.BRAIN/02-gameplay/economy/loot-tables.md` - Loot tables definitions
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - Combat system

---

## TODO

- [ ] Loot priority system (для master looter)
- [ ] Loot lockout (boss loot once per week)
- [ ] Loot trade window (trade won items within party for 2 hours)
- [ ] Loot pinata mode (всем random loot при boss kill)

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Loot System

