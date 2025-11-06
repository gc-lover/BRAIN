---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:40  
**api-readiness-notes:** Inventory Equipment микрофича. Equipment slots, equip/unequip, stats calculation, durability. ~330 строк.
---

# Inventory Equipment - Система экипировки

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:40  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Equipment & stats  
**Размер:** ~330 строк ✅

---

## Краткое описание

**Inventory Equipment** - система экипировки (надеть/снять, бонусы статов).

**Ключевые возможности:**
- ✅ Equipment slots (head, chest, weapon, etc)
- ✅ Equip/Unequip items
- ✅ Stats calculation (armor, damage)
- ✅ Durability system

---

## Equipment Slots

```java
public enum EquipmentSlot {
    HEAD,           // Helmet
    CHEST,          // Armor
    LEGS,           // Pants
    FEET,           // Boots
    HANDS,          // Gloves
    MAIN_HAND,      // Weapon
    OFF_HAND,       // Shield / Second weapon
    ACCESSORY_1,    // Ring / Necklace
    ACCESSORY_2,
    BACK            // Cloak / Jetpack
}
```

---

## Database Schema

```sql
CREATE TABLE equipped_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    slot VARCHAR(20) NOT NULL,
    
    inventory_item_id UUID NOT NULL,
    
    -- Durability
    current_durability INTEGER NOT NULL,
    max_durability INTEGER NOT NULL,
    
    equipped_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_equipped_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_equipped_item FOREIGN KEY (inventory_item_id) 
        REFERENCES inventory_items(id) ON DELETE CASCADE,
    UNIQUE(character_id, slot)
);
```

---

## Equip Item

```java
@PostMapping("/equipment/equip")
@Transactional
public EquipResponse equipItem(
    @RequestHeader("Authorization") String token,
    @RequestBody EquipRequest request
) {
    UUID playerId = extractPlayerId(token);
    Character character = getActiveCharacter(playerId);
    
    // 1. Найти item в инвентаре
    InventoryItem item = inventoryRepository
        .findByCharacterAndSlot(character.getId(), request.getSlotIndex())
        .orElseThrow();
    
    ItemTemplate template = itemTemplateRepository.findById(item.getItemTemplateId()).orElseThrow();
    
    // 2. Проверить slot
    EquipmentSlot targetSlot = template.getEquipmentSlot();
    if (targetSlot == null) {
        return error("Item is not equippable");
    }
    
    // 3. Проверить requirements
    if (!meetsRequirements(character, template)) {
        return error("Requirements not met");
    }
    
    // 4. Unequip current (if any)
    Optional<EquippedItem> currentEquipped = equippedRepository
        .findByCharacterAndSlot(character.getId(), targetSlot);
    
    if (currentEquipped.isPresent()) {
        unequipItem(character.getId(), targetSlot);
    }
    
    // 5. Equip new
    EquippedItem equipped = new EquippedItem();
    equipped.setCharacterId(character.getId());
    equipped.setSlot(targetSlot);
    equipped.setInventoryItemId(item.getId());
    equipped.setCurrentDurability(template.getMaxDurability());
    equipped.setMaxDurability(template.getMaxDurability());
    
    equippedRepository.save(equipped);
    
    // 6. Recalculate stats
    recalculateCharacterStats(character.getId());
    
    return EquipResponse.success();
}
```

---

## Stats Calculation

```java
@Transactional(readOnly = true)
public CharacterStats calculateTotalStats(UUID characterId) {
    Character character = characterRepository.findById(characterId).orElseThrow();
    
    // Base stats
    CharacterStats stats = new CharacterStats();
    stats.setHealth(character.getBaseHealth());
    stats.setArmor(0);
    stats.setDamage(character.getBaseDamage());
    
    // Equipment bonuses
    List<EquippedItem> equipped = equippedRepository.findByCharacter(characterId);
    
    for (EquippedItem item : equipped) {
        ItemTemplate template = itemTemplateRepository
            .findById(item.getInventoryItem().getItemTemplateId())
            .orElseThrow();
        
        // Add bonuses
        if (template.getArmorBonus() != null) {
            stats.addArmor(template.getArmorBonus());
        }
        
        if (template.getDamageBonus() != null) {
            stats.addDamage(template.getDamageBonus());
        }
        
        if (template.getHealthBonus() != null) {
            stats.addHealth(template.getHealthBonus());
        }
    }
    
    return stats;
}
```

---

## Durability Loss

```java
public void damageDurability(UUID characterId, EquipmentSlot slot, int damageAmount) {
    EquippedItem item = equippedRepository
        .findByCharacterAndSlot(characterId, slot)
        .orElse(null);
    
    if (item == null) return;
    
    int newDurability = Math.max(0, item.getCurrentDurability() - damageAmount);
    item.setCurrentDurability(newDurability);
    equippedRepository.save(item);
    
    // Broken?
    if (newDurability == 0) {
        wsService.sendToPlayer(getPlayerId(characterId),
            new ItemBrokenMessage(slot, item.getId()));
        
        // Может автоматически unequip
        // unequipItem(characterId, slot);
    }
}
```

---

## API Endpoints

**GET `/api/v1/equipment`** - текущая экипировка
**POST `/api/v1/equipment/equip`** - надеть
**POST `/api/v1/equipment/unequip`** - снять

---

## Связанные документы

- `.BRAIN/05-technical/backend/inventory/inventory-core.md` - Core (микрофича 1/3)
- `.BRAIN/05-technical/backend/inventory/inventory-storage.md` - Storage (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:40)** - Микрофича 2/3: Inventory Equipment (split from inventory-system.md)

