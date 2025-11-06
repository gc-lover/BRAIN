---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:45  
**api-readiness-notes:** Loot Distribution микрофича. Roll system, personal loot, party loot, auto-loot, loot history. ~360 строк.
---

# Loot Distribution - Распределение лута

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:45  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Loot distribution & roll system  
**Размер:** ~360 строк ✅

---

## Краткое описание

**Loot Distribution** - распределение лута между игроками (roll system).

**Ключевые возможности:**
- ✅ Roll system (Need/Greed/Pass)
- ✅ Personal loot (30 sec exclusive)
- ✅ Party loot settings
- ✅ Auto-loot (below threshold)
- ✅ Loot history

---

## Loot Modes

```java
public enum LootMode {
    PERSONAL,       // Каждый видит свой лoot
    FREE_FOR_ALL,   // Первый взял
    ROUND_ROBIN,    // По очереди
    MASTER_LOOTER, // Лидер распределяет
    NEED_GREED      // Roll система
}
```

---

## Roll System

```sql
CREATE TABLE loot_rolls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    world_item_id UUID NOT NULL,
    player_id UUID NOT NULL,
    
    roll_type VARCHAR(20) NOT NULL, -- NEED, GREED, PASS
    roll_value INTEGER, -- 1-100 (for NEED/GREED)
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_roll_item FOREIGN KEY (world_item_id) 
        REFERENCES world_items(id) ON DELETE CASCADE,
    CONSTRAINT fk_roll_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(world_item_id, player_id)
);
```

---

## Need/Greed Roll

```java
@PostMapping("/loot/roll")
@Transactional
public RollResponse roll(
    @RequestHeader("Authorization") String token,
    @RequestBody RollRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Проверить, что в party
    Party party = partyService.getPlayerParty(playerId);
    if (party == null || party.getLootMode() != LootMode.NEED_GREED) {
        return error("Not in Need/Greed mode");
    }
    
    // 2. Проверить item
    WorldItem item = worldItemRepository.findById(request.getItemId()).orElseThrow();
    
    // 3. Проверить, что еще не rollил
    if (lootRollRepository.existsByItemAndPlayer(item.getId(), playerId)) {
        return error("Already rolled");
    }
    
    // 4. Roll
    int rollValue = random.nextInt(100) + 1;
    
    LootRoll roll = new LootRoll();
    roll.setWorldItemId(item.getId());
    roll.setPlayerId(playerId);
    roll.setRollType(request.getRollType());
    roll.setRollValue(rollValue);
    
    lootRollRepository.save(roll);
    
    // 5. Notify party
    wsService.broadcastToParty(party.getId(),
        new PlayerRolledMessage(playerId, request.getRollType(), rollValue));
    
    // 6. Проверить, все ли проголосовали
    checkRollCompletion(item.getId(), party.getId());
    
    return RollResponse.success(rollValue);
}

private void checkRollCompletion(UUID itemId, UUID partyId) {
    List<UUID> partyMembers = partyService.getMembers(partyId);
    List<LootRoll> rolls = lootRollRepository.findByItem(itemId);
    
    // Все проголосовали?
    if (rolls.size() < partyMembers.size()) {
        return; // Еще ждем
    }
    
    // Определить победителя
    // 1. NEED rolls (highest)
    Optional<LootRoll> needWinner = rolls.stream()
        .filter(r -> r.getRollType() == RollType.NEED)
        .max(Comparator.comparingInt(LootRoll::getRollValue));
    
    if (needWinner.isPresent()) {
        awardLoot(itemId, needWinner.get().getPlayerId());
        return;
    }
    
    // 2. GREED rolls (highest)
    Optional<LootRoll> greedWinner = rolls.stream()
        .filter(r -> r.getRollType() == RollType.GREED)
        .max(Comparator.comparingInt(LootRoll::getRollValue));
    
    if (greedWinner.isPresent()) {
        awardLoot(itemId, greedWinner.get().getPlayerId());
        return;
    }
    
    // 3. Все PASS - delete item
    worldItemRepository.deleteById(itemId);
}

private void awardLoot(UUID itemId, UUID winnerId) {
    WorldItem item = worldItemRepository.findById(itemId).orElseThrow();
    Character winner = characterRepository.findByPlayerId(winnerId).orElseThrow();
    
    // Add to inventory
    inventoryService.addItem(winner.getId(), item.getItemTemplateId(), item.getQuantity());
    
    // Delete world item
    worldItemRepository.delete(item);
    
    // Notify
    wsService.sendToPlayer(winnerId,
        new LootWonMessage(item.getItemTemplateId(), item.getQuantity()));
}
```

---

## Personal Loot (30 sec exclusive)

```java
@GetMapping("/loot/nearby")
public List<WorldItemDTO> getNearbyLoot(
    @RequestHeader("Authorization") String token
) {
    UUID playerId = extractPlayerId(token);
    Character character = getActiveCharacter(playerId);
    
    List<WorldItem> nearbyItems = worldItemRepository
        .findByZoneAndPosition(character.getZoneId(), character.getPosition(), 10);
    
    Instant now = Instant.now();
    
    return nearbyItems.stream()
        .filter(item -> {
            // Personal loot (30 sec)
            if (item.getOwnerPlayerId() != null) {
                if (!item.getOwnerPlayerId().equals(playerId)) {
                    Duration since = Duration.between(item.getCreatedAt(), now);
                    if (since.getSeconds() < 30) {
                        return false; // Еще личный лут другого игрока
                    }
                }
            }
            return true;
        })
        .map(WorldItemDTO::from)
        .collect(Collectors.toList());
}
```

---

## Auto-Loot

```java
public void enableAutoLoot(UUID characterId, ItemQuality maxQuality) {
    CharacterSettings settings = settingsRepository.findByCharacter(characterId).orElseThrow();
    settings.setAutoLootEnabled(true);
    settings.setAutoLootMaxQuality(maxQuality);
    settingsRepository.save(settings);
}

// При дропе лута
if (character.getSettings().isAutoLootEnabled()) {
    ItemQuality maxQuality = character.getSettings().getAutoLootMaxQuality();
    
    for (LootItem item : loot) {
        if (item.getQuality().ordinal() <= maxQuality.ordinal()) {
            // Auto pickup
            inventoryService.addItem(character.getId(), item.getItemId(), item.getQuantity());
        } else {
            // Drop to world
            createWorldItem(item);
        }
    }
}
```

---

## API Endpoints

**GET `/api/v1/loot/nearby`** - лут рядом
**POST `/api/v1/loot/roll`** - roll NEED/GREED
**PUT `/api/v1/loot/auto-loot`** - настроить auto-loot

---

## Связанные документы

- `.BRAIN/05-technical/backend/loot/loot-generation.md` - Generation (микрофича 1/2)

---

## История изменений

- **v1.0.0 (2025-11-07 05:45)** - Микрофича 2/2: Loot Distribution (split from loot-system.md)

