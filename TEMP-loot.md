---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** ╨Я╨╛╨╗╨╜╨░╤П ╤Б╨╕╤Б╤В╨╡╨╝╨░ ╨╗╤Г╤В╨░. Loot generation (╨╕╨╖ ╤В╨░╨▒╨╗╨╕╤Ж), drops (NPC, containers), distribution (solo/party/raid), roll system (need/greed), personal/shared loot, boss loot, instancing.
---

# Loot System - ╨б╨╕╤Б╤В╨╡╨╝╨░ ╨│╨╡╨╜╨╡╤А╨░╤Ж╨╕╨╕ ╨╕ ╤А╨░╤Б╨┐╤А╨╡╨┤╨╡╨╗╨╡╨╜╨╕╤П ╨╗╤Г╤В╨░

**╨б╤В╨░╤В╤Г╤Б:** approved  
**╨Т╨╡╤А╤Б╨╕╤П:** 1.0.0  
**╨Ф╨░╤В╨░ ╤Б╨╛╨╖╨┤╨░╨╜╨╕╤П:** 2025-11-07  
**╨Я╨╛╤Б╨╗╨╡╨┤╨╜╨╡╨╡ ╨╛╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╕╨╡:** 2025-11-07 05:20  
**╨Я╤А╨╕╨╛╤А╨╕╤В╨╡╤В:** ╨Ъ╨а╨Ш╨в╨Ш╨з╨Х╨б╨Ъ╨Ш╨Щ (MVP ╨▒╨╗╨╛╨║╨╡╤А!)  
**╨Р╨▓╤В╨╛╤А:** AI Brain Manager

---

## ╨Ъ╤А╨░╤В╨║╨╛╨╡ ╨╛╨┐╨╕╤Б╨░╨╜╨╕╨╡

**Loot System** - ╨║╤А╨╕╤В╨╕╤З╨╡╤Б╨║╨╕ ╨▓╨░╨╢╨╜╨░╤П ╤Б╨╕╤Б╤В╨╡╨╝╨░ ╨┤╨╗╤П ╨│╨╡╨╜╨╡╤А╨░╤Ж╨╕╨╕ ╨╕ ╤А╨░╤Б╨┐╤А╨╡╨┤╨╡╨╗╨╡╨╜╨╕╤П ╨┤╨╛╨▒╤Л╤З╨╕. ╨С╨╡╨╖ ╤Н╤В╨╛╨╣ ╤Б╨╕╤Б╤В╨╡╨╝╤Л ╨▓ ╨╕╨│╤А╨╡ ╨╜╨╡╤В progression (╨╜╨╡╤В ╨╜╨░╨│╤А╨░╨┤ ╨╖╨░ ╤Г╨▒╨╕╨╣╤Б╤В╨▓╨╛ ╨▓╤А╨░╨│╨╛╨▓, ╨╛╤В╨║╤А╤Л╤В╨╕╨╡ ╨║╨╛╨╜╤В╨╡╨╣╨╜╨╡╤А╨╛╨▓, ╨▓╤Л╨┐╨╛╨╗╨╜╨╡╨╜╨╕╨╡ ╨║╨▓╨╡╤Б╤В╨╛╨▓). ╨Ю╨▒╨╡╤Б╨┐╨╡╤З╨╕╨▓╨░╨╡╤В ╤Б╨┐╤А╨░╨▓╨╡╨┤╨╗╨╕╨▓╨╛╨╡ ╤А╨░╤Б╨┐╤А╨╡╨┤╨╡╨╗╨╡╨╜╨╕╨╡ ╨╗╤Г╤В╨░ ╨╝╨╡╨╢╨┤╤Г ╨╕╨│╤А╨╛╨║╨░╨╝╨╕.

**╨Ъ╨╗╤О╤З╨╡╨▓╤Л╨╡ ╨▓╨╛╨╖╨╝╨╛╨╢╨╜╨╛╤Б╤В╨╕:**
- тЬЕ Loot generation (╨╕╨╖ loot tables ╤Б ╨▓╨╡╤Б╨░╨╝╨╕)
- тЬЕ Loot drops (╨║╨╛╨│╨┤╨░ NPC ╤Г╨╝╨╕╤А╨░╨╡╤В, ╨║╨╛╨╜╤В╨╡╨╣╨╜╨╡╤А ╨╛╤В╨║╤А╤Л╨▓╨░╨╡╤В╤Б╤П)
- тЬЕ Loot distribution (solo, party, raid)
- тЬЕ Roll system (need/greed/pass)
- тЬЕ Personal loot vs shared loot
- тЬЕ Boss loot (╨│╨░╤А╨░╨╜╤В╨╕╤А╨╛╨▓╨░╨╜╨╜╤Л╨╣ + ╤Б╨╗╤Г╤З╨░╨╣╨╜╤Л╨╣)
- тЬЕ Loot instancing (╨║╨░╨╢╨┤╤Л╨╣ ╨▓╨╕╨┤╨╕╤В ╤Б╨▓╨╛╨╣ ╨╗╤Г╤В)
- тЬЕ Auto-loot settings
- тЬЕ Loot history (╨║╤В╨╛ ╤З╤В╨╛ ╨┐╨╛╨╗╤Г╤З╨╕╨╗)

---

## ╨Р╤А╤Е╨╕╤В╨╡╨║╤В╤Г╤А╨░ ╤Б╨╕╤Б╤В╨╡╨╝╤Л

### Loot Flow

```
NPC/Container Death/Open
    тЖУ
Generate Loot (from loot tables)
    тЖУ
Determine Loot Mode (personal/shared)
    тЖУ
IF PERSONAL:
    Each player gets own loot
    тЖТ Directly to inventory
    
IF SHARED:
    Create world drop
    тЖТ Players roll (need/greed/pass)
    тЖТ Winner gets item
    
Boss Loot:
    Guaranteed items for all
    + Random items (shared/rolled)
```

---

## Database Schema

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `loot_tables`

```sql
CREATE TABLE loot_tables (
    id VARCHAR(100) PRIMARY KEY,
    
    -- ╨Э╨░╨╖╨▓╨░╨╜╨╕╨╡
    table_name VARCHAR(200) NOT NULL,
    
    -- ╨в╨╕╨┐
    table_type VARCHAR(50) NOT NULL,
    -- NPC_LOOT, CONTAINER_LOOT, BOSS_LOOT, QUEST_REWARD
    
    -- ╨б╨▓╤П╨╖╤М ╤Б ╨╕╤Б╤В╨╛╤З╨╜╨╕╨║╨╛╨╝
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

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `world_drops`

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
    
    -- Ownership (╨┤╨╗╤П personal loot)
    owner_character_id UUID, -- ╨Х╤Б╨╗╨╕ personal loot
    party_id UUID, -- ╨Х╤Б╨╗╨╕ party loot
    
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

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `loot_rolls`

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

### ╨в╨░╨▒╨╗╨╕╤Ж╨░ `loot_history`

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

### ╨У╨╡╨╜╨╡╤А╨░╤Ж╨╕╤П ╨╗╤Г╤В╨░ ╨╕╨╖ ╤В╨░╨▒╨╗╨╕╤Ж╤Л

```java
@Service
public class LootService {
    
    @Autowired
    private LootTableRepository lootTableRepository;
    
    @Autowired
    private ItemTemplateRepository itemTemplateRepository;
    
    public LootResult generateLoot(String lootTableId, LootContext context) {
        // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М loot table
        LootTable table = lootTableRepository.findById(lootTableId)
            .orElseThrow(() -> new LootTableNotFoundException());
        
        // 2. ╨Ю╨┐╤А╨╡╨┤╨╡╨╗╨╕╤В╤М ╨║╨╛╨╗╨╕╤З╨╡╤Б╤В╨▓╨╛ ╨┐╤А╨╡╨┤╨╝╨╡╤В╨╛╨▓
        int itemCount = random.nextInt(
            table.getMaxItems() - table.getMinItems() + 1
        ) + table.getMinItems();
        
        // 3. ╨б╨│╨╡╨╜╨╡╤А╨╕╤А╨╛╨▓╨░╤В╤М ╨┐╤А╨╡╨┤╨╝╨╡╤В╤Л
        List<LootItem> items = new ArrayList<>();
        
        for (int i = 0; i < itemCount; i++) {
            LootItem item = rollItem(table, context);
            if (item != null) {
                items.add(item);
            }
        }
        
        // 4. ╨б╨│╨╡╨╜╨╡╤А╨╕╤А╨╛╨▓╨░╤В╤М ╨▓╨░╨╗╤О╤В╤Г
        int eddies = 0;
        if (table.getMaxEddies() > 0) {
            eddies = random.nextInt(
                table.getMaxEddies() - table.getMinEddies() + 1
            ) + table.getMinEddies();
            
            // ╨Я╤А╨╕╨╝╨╡╨╜╨╕╤В╤М multipliers
            eddies = (int) (eddies * context.getEddiesMultiplier());
        }
        
        if (eddies > 0) {
            items.add(new LootItem("eddies", eddies));
        }
        
        return new LootResult(items);
    }
    
    private LootItem rollItem(LootTable table, LootContext context) {
        // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М entries
        List<LootEntry> entries = table.getEntries();
        
        // 2. ╨Я╤А╨╕╨╝╨╡╨╜╨╕╤В╤М luck modifier
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
                // ╨Т╤Л╨▒╤А╨░╨╜ ╤Н╤В╨╛╤В item
                int quantity = random.nextInt(
                    entry.getMaxQuantity() - entry.getMinQuantity() + 1
                ) + entry.getMinQuantity();
                
                return new LootItem(entry.getItemTemplateId(), quantity);
            }
        }
        
        return null;
    }
    
    private List<LootEntry> applyLuckModifier(List<LootEntry> entries, double luckMod) {
        // Luck ╤Г╨▓╨╡╨╗╨╕╤З╨╕╨▓╨░╨╡╤В ╤И╨░╨╜╤Б ╤А╨╡╨┤╨║╨╕╤Е ╨┐╤А╨╡╨┤╨╝╨╡╤В╨╛╨▓
        return entries.stream()
            .map(entry -> {
                ItemTemplate template = itemTemplateRepository
                    .findById(entry.getItemTemplateId()).get();
                
                int adjustedWeight = entry.getWeight();
                
                // ╨г╨▓╨╡╨╗╨╕╤З╨╕╨▓╨░╨╡╨╝ ╨▓╨╡╤Б ╨┤╨╗╤П ╤А╨╡╨┤╨║╨╕╤Е ╨┐╤А╨╡╨┤╨╝╨╡╤В╨╛╨▓
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
    private UUID killerId; // ╨Ъ╤В╨╛ ╤Г╨▒╨╕╨╗/╨╛╤В╨║╤А╤Л╨╗
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

### Solo Loot (╨╗╨╕╤З╨╜╤Л╨╣ ╨╗╤Г╤В)

```java
@Transactional
public void createSoloLoot(
    UUID characterId,
    String lootTableId,
    LootSource source
) {
    // 1. ╨б╨│╨╡╨╜╨╡╤А╨╕╤А╨╛╨▓╨░╤В╤М ╨╗╤Г╤В
    Character character = characterRepository.findById(characterId).get();
    
    LootContext context = new LootContext();
    context.setKillerId(characterId);
    context.setKillerLevel(character.getLevel());
    context.setLuckModifier(getLuckModifier(character));
    
    LootResult loot = generateLoot(lootTableId, context);
    
    // 2. ╨б╨╛╨╖╨┤╨░╤В╤М world drop (personal)
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
    
    // 3. ╨г╨▓╨╡╨┤╨╛╨╝╨╕╤В╤М ╨╕╨│╤А╨╛╨║╨░
    notificationService.send(
        getAccountId(characterId),
        new LootDroppedNotification(loot.getItems().size())
    );
    
    log.info("Created personal loot drop {} for character {}", drop.getId(), characterId);
}
```

### Party Loot (╨│╤А╤Г╨┐╨┐╨╛╨▓╨╛╨╣ ╨╗╤Г╤В)

```java
@Transactional
public void createPartyLoot(
    UUID partyId,
    String lootTableId,
    LootSource source,
    Vector3 position,
    String zoneId
) {
    // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М party
    Party party = partyRepository.findById(partyId)
        .orElseThrow(() -> new PartyNotFoundException());
    
    // 2. ╨Ю╨┐╤А╨╡╨┤╨╡╨╗╨╕╤В╤М loot mode
    LootMode lootMode = party.getLootMode();
    
    if (lootMode == LootMode.PERSONAL) {
        // ╨Ъ╨░╨╢╨┤╤Л╨╣ ╤Г╤З╨░╤Б╤В╨╜╨╕╨║ ╨┐╨╛╨╗╤Г╤З╨░╨╡╤В ╤Б╨▓╨╛╨╣ ╨╗╤Г╤В
        for (UUID memberId : party.getMembers()) {
            createSoloLoot(memberId, lootTableId, source);
        }
        return;
    }
    
    // 3. ╨б╨│╨╡╨╜╨╡╤А╨╕╤А╨╛╨▓╨░╤В╤М ╨╛╨▒╤Й╨╕╨╣ ╨╗╤Г╤В
    // ╨Ш╤Б╨┐╨╛╨╗╤М╨╖╤Г╨╡╨╝ ╨╗╨╕╨┤╨╡╤А╨░ party ╨┤╨╗╤П context
    UUID leaderId = party.getLeaderId();
    Character leader = characterRepository.findById(leaderId).get();
    
    LootContext context = new LootContext();
    context.setKillerId(leaderId);
    context.setKillerLevel(leader.getLevel());
    context.setLuckModifier(getPartyAverageLuck(party));
    
    LootResult loot = generateLoot(lootTableId, context);
    
    // 4. ╨б╨╛╨╖╨┤╨░╤В╤М world drop (shared)
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
    
    // 5. ╨г╨▓╨╡╨┤╨╛╨╝╨╕╤В╤М ╨▓╤Б╤О party
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
    // 1. ╨б╨╛╨╖╨┤╨░╤В╤М loot roll
    LootRoll roll = new LootRoll();
    roll.setWorldDropId(worldDropId);
    roll.setItemTemplateId(itemTemplateId);
    roll.setPartyId(partyId);
    roll.setExpiresAt(Instant.now().plus(Duration.ofSeconds(60)));
    roll.setStatus(RollStatus.PENDING);
    
    rollRepository.save(roll);
    
    // 2. ╨г╨▓╨╡╨┤╨╛╨╝╨╕╤В╤М ╨▓╤Б╨╡╤Е ╤Г╤З╨░╤Б╤В╨╜╨╕╨║╨╛╨▓ party
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
    // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М roll
    LootRoll roll = rollRepository.findById(rollId)
        .orElseThrow(() -> new LootRollNotFoundException());
    
    if (roll.getStatus() != RollStatus.PENDING) {
        throw new RollAlreadyCompletedException();
    }
    
    // 2. ╨Я╤А╨╛╨▓╨╡╤А╨╕╤В╤М, ╤З╤В╨╛ ╨╕╨│╤А╨╛╨║ ╨▓ party
    Party party = partyRepository.findById(roll.getPartyId()).get();
    if (!party.getMembers().contains(characterId)) {
        throw new NotInPartyException();
    }
    
    // 3. ╨Я╤А╨╛╨▓╨╡╤А╨╕╤В╤М, ╤З╤В╨╛ ╨╡╤Й╨╡ ╨╜╨╡ rollil
    List<PlayerRoll> rolls = roll.getRolls();
    if (rolls.stream().anyMatch(r -> r.getCharacterId().equals(characterId))) {
        throw new AlreadyRolledException();
    }
    
    // 4. ╨Ф╨╛╨▒╨░╨▓╨╕╤В╤М roll
    PlayerRoll playerRoll = new PlayerRoll();
    playerRoll.setCharacterId(characterId);
    playerRoll.setRollType(rollType);
    
    if (rollType != RollType.PASS) {
        playerRoll.setRollValue(random.nextInt(100) + 1); // 1-100
    }
    
    rolls.add(playerRoll);
    roll.setRolls(rolls);
    rollRepository.save(roll);
    
    // 5. ╨г╨▓╨╡╨┤╨╛╨╝╨╕╤В╤М party ╨╛ roll
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
    
    // 6. ╨Я╤А╨╛╨▓╨╡╤А╨╕╤В╤М, ╨▓╤Б╨╡ ╨╗╨╕ ╨┐╤А╨╛╨│╨╛╨╗╨╛╤Б╨╛╨▓╨░╨╗╨╕
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
    // 1. ╨Ю╨┐╤А╨╡╨┤╨╡╨╗╨╕╤В╤М ╨┐╨╛╨▒╨╡╨┤╨╕╤В╨╡╨╗╤П
    List<PlayerRoll> rolls = roll.getRolls();
    
    // ╨Я╤А╨╕╨╛╤А╨╕╤В╨╡╤В: NEED > GREED > PASS
    // ╨Т╨╜╤Г╤В╤А╨╕ ╨║╨░╤В╨╡╨│╨╛╤А╨╕╨╕: highest roll
    
    Optional<PlayerRoll> winner = rolls.stream()
        .filter(r -> r.getRollType() == RollType.NEED)
        .max(Comparator.comparing(PlayerRoll::getRollValue));
    
    if (winner.isEmpty()) {
        winner = rolls.stream()
            .filter(r -> r.getRollType() == RollType.GREED)
            .max(Comparator.comparing(PlayerRoll::getRollValue));
    }
    
    if (winner.isEmpty()) {
        // ╨Т╤Б╨╡ ╤Б╨┤╨╡╨╗╨░╨╗╨╕ PASS, item ╨╛╤Б╤В╨░╨╡╤В╤Б╤П ╨╜╨░ ╨╖╨╡╨╝╨╗╨╡
        roll.setStatus(RollStatus.COMPLETED);
        rollRepository.save(roll);
        
        log.info("Roll {} completed with no winner (all passed)", roll.getId());
        return;
    }
    
    // 2. ╨Ю╨▒╨╜╨╛╨▓╨╕╤В╤М roll
    PlayerRoll winnerRoll = winner.get();
    roll.setWinnerCharacterId(winnerRoll.getCharacterId());
    roll.setWinnerRollType(winnerRoll.getRollType());
    roll.setWinnerRollValue(winnerRoll.getRollValue());
    roll.setStatus(RollStatus.COMPLETED);
    roll.setCompletedAt(Instant.now());
    rollRepository.save(roll);
    
    // 3. ╨Ф╨░╤В╤М item ╨┐╨╛╨▒╨╡╨┤╨╕╤В╨╡╨╗╤О
    inventoryService.addItem(
        winnerRoll.getCharacterId(),
        roll.getItemTemplateId(),
        1,
        "ROLL_WON"
    );
    
    // 4. ╨Ч╨░╨┐╨╕╤Б╨░╤В╤М ╨▓ loot history
    lootHistoryRepository.save(new LootHistory(
        winnerRoll.getCharacterId(),
        roll.getItemTemplateId(),
        1,
        "ROLL_WON",
        roll.getWorldDropId().toString()
    ));
    
    // 5. ╨г╨▓╨╡╨┤╨╛╨╝╨╕╤В╤М party
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
@Scheduled(fixedDelay = 10000) // ╨Ъ╨░╨╢╨┤╤Л╨╡ 10 ╤Б╨╡╨║╤Г╨╜╨┤
public void handleExpiredRolls() {
    List<LootRoll> expiredRolls = rollRepository
        .findExpiredPending(Instant.now());
    
    for (LootRoll roll : expiredRolls) {
        // ╨Р╨▓╤В╨╛╨╝╨░╤В╨╕╤З╨╡╤Б╨║╨╕ PASS ╨┤╨╗╤П ╤В╨╡╤Е, ╨║╤В╨╛ ╨╜╨╡ ╨┐╤А╨╛╨│╨╛╨╗╨╛╤Б╨╛╨▓╨░╨╗
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
        
        // ╨Ч╨░╨▓╨╡╤А╤И╨╕╤В╤М roll
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
    // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М boss loot table
    String bossLootTableId = "boss_" + bossId;
    
    // 2. ╨У╨░╤А╨░╨╜╤В╨╕╤А╨╛╨▓╨░╨╜╨╜╤Л╨╡ items ╨┤╨╗╤П ╨▓╤Б╨╡╤Е
    List<String> guaranteedItems = getBossGuaranteedItems(bossId);
    
    if (partyId != null) {
        Party party = partyRepository.findById(partyId).get();
        
        // ╨Ъ╨░╨╢╨┤╤Л╨╣ ╤З╨╗╨╡╨╜ party ╨┐╨╛╨╗╤Г╤З╨░╨╡╤В ╨│╨░╤А╨░╨╜╤В╨╕╤А╨╛╨▓╨░╨╜╨╜╤Л╨╣ ╨╗╤Г╤В
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
    
    // 3. ╨б╨╗╤Г╤З╨░╨╣╨╜╤Л╨╣ boss loot (shared, ╤Б roll╨░╨╝╨╕)
    if (partyId != null) {
        createPartyLoot(partyId, bossLootTableId, 
            new LootSource("BOSS", bossId.toString()), position, zoneId);
    } else {
        createSoloLoot(killerId, bossLootTableId, 
            new LootSource("BOSS", bossId.toString()));
    }
    
    // 4. ╨Ю╨┐╤Г╨▒╨╗╨╕╨║╨╛╨▓╨░╤В╤М achievement
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
    // 1. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М settings
    AutoLootSettings settings = getAutoLootSettings(characterId);
    
    if (!settings.isEnabled()) {
        return;
    }
    
    // 2. ╨Я╨╛╨╗╤Г╤З╨╕╤В╤М drop
    WorldDrop drop = worldDropRepository.findById(worldDropId).get();
    
    // 3. ╨Я╤А╨╛╨▓╨╡╤А╨╕╤В╤М ownership
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
    
    // 5. ╨Ю╨▒╨╜╨╛╨▓╨╕╤В╤М drop
    if (remaining.isEmpty()) {
        // ╨Т╨╡╤Б╤М ╨╗╤Г╤В ╨╖╨░╨▒╤А╨░╨╜
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

**GET `/api/v1/loot/drops/nearby`** - ╨╗╤Г╤В ╤А╤П╨┤╨╛╨╝ ╤Б ╨╕╨│╤А╨╛╨║╨╛╨╝
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

**POST `/api/v1/loot/pickup`** - ╨┐╨╛╨┤╨╛╨▒╤А╨░╤В╤М ╨╗╤Г╤В
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

**GET `/api/v1/loot/rolls/active`** - ╨░╨║╤В╨╕╨▓╨╜╤Л╨╡ roll╤Л
**POST `/api/v1/loot/rolls/{id}/roll`** - ╨┐╤А╨╛╨│╨╛╨╗╨╛╤Б╨╛╨▓╨░╤В╤М
```json
Request:
{
  "rollType": "NEED | GREED | PASS"
}
```

### Loot History

**GET `/api/v1/loot/history`** - ╨╕╤Б╤В╨╛╤А╨╕╤П ╨╗╤Г╤В╨░
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

**GET `/api/v1/loot/settings`** - ╨╜╨░╤Б╤В╤А╨╛╨╣╨║╨╕ auto-loot
**PUT `/api/v1/loot/settings`** - ╨╛╨▒╨╜╨╛╨▓╨╕╤В╤М ╨╜╨░╤Б╤В╤А╨╛╨╣╨║╨╕

---

## ╨Ш╨╜╤В╨╡╨│╤А╨░╤Ж╨╕╤П ╤Б ╨┤╤А╤Г╨│╨╕╨╝╨╕ ╤Б╨╕╤Б╤В╨╡╨╝╨░╨╝╨╕

### ╨Я╤А╨╕ ╤Г╨▒╨╕╨╣╤Б╤В╨▓╨╡ NPC

```
CombatService.npcDeath()
  тЖУ
тЖТ LootService: generate loot
тЖТ WorldDropService: create world drop
тЖТ QuestService: check quest objectives (kill 10 NPCs)
тЖТ AchievementService: check kill achievements
тЖТ EventBus: publish NPC_KILLED
```

### ╨Я╤А╨╕ ╨┐╨╛╨╗╤Г╤З╨╡╨╜╨╕╨╕ ╨╗╤Г╤В╨░

```
LootService.pickupItem()
  тЖУ
тЖТ InventoryService: add item to inventory
тЖТ QuestService: check quest objectives (collect 10 items)
тЖТ AchievementService: check collection achievements
тЖТ NotificationService: send pickup notification
тЖТ LootHistoryService: record loot
тЖТ EventBus: publish ITEM_LOOTED
```

---

## ╨б╨▓╤П╨╖╨░╨╜╨╜╤Л╨╡ ╨┤╨╛╨║╤Г╨╝╨╡╨╜╤В╤Л

- `.BRAIN/05-technical/backend/inventory-system.md` - Inventory management
- `.BRAIN/02-gameplay/economy/loot-tables.md` - Loot tables definitions
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - Combat system

---

## TODO

- [ ] Loot priority system (╨┤╨╗╤П master looter)
- [ ] Loot lockout (boss loot once per week)
- [ ] Loot trade window (trade won items within party for 2 hours)
- [ ] Loot pinata mode (╨▓╤Б╨╡╨╝ random loot ╨┐╤А╨╕ boss kill)

---

## ╨Ш╤Б╤В╨╛╤А╨╕╤П ╨╕╨╖╨╝╨╡╨╜╨╡╨╜╨╕╨╣

- **v1.0.0 (2025-11-07 05:20)** - ╨б╨╛╨╖╨┤╨░╨╜ ╨┤╨╛╨║╤Г╨╝╨╡╨╜╤В Loot System

