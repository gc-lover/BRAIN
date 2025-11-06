---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:40  
**api-readiness-notes:** Inventory Core микрофича. Slots, stacking, weight, pickup/drop. ~340 строк.
---

# Inventory Core - Базовая система инвентаря

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:40  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Inventory slots & stacking  
**Размер:** ~340 строк ✅

---

## Краткое описание

**Inventory Core** - базовая система инвентаря (слоты, стаки, вес).

**Ключевые возможности:**
- ✅ Inventory slots (40 слотов)
- ✅ Item stacking (max 999)
- ✅ Weight/encumbrance system
- ✅ Pickup/Drop items

---

## Database Schema

```sql
CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    item_template_id VARCHAR(100) NOT NULL,
    
    -- Slot
    slot_index INTEGER NOT NULL,
    stack_size INTEGER DEFAULT 1,
    
    -- Stats
    durability INTEGER,
    quality VARCHAR(20), -- COMMON, RARE, EPIC, LEGENDARY
    
    -- Custom data
    custom_data JSONB,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_inventory_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    UNIQUE(character_id, slot_index)
);

CREATE INDEX idx_inventory_character ON inventory_items(character_id);
```

---

## Add Item

```java
@Transactional
public AddItemResult addItem(UUID characterId, String itemTemplateId, int quantity) {
    // 1. Проверить stackable
    ItemTemplate template = itemTemplateRepository.findById(itemTemplateId).orElseThrow();
    
    if (template.isStackable()) {
        return addStackableItem(characterId, template, quantity);
    } else {
        return addNonStackableItem(characterId, template, quantity);
    }
}

private AddItemResult addStackableItem(UUID characterId, ItemTemplate template, int quantity) {
    int maxStackSize = template.getMaxStackSize();
    int remaining = quantity;
    
    // 1. Найти существующие стаки
    List<InventoryItem> existingStacks = inventoryRepository
        .findByCharacterAndTemplate(characterId, template.getId());
    
    for (InventoryItem stack : existingStacks) {
        if (stack.getStackSize() < maxStackSize) {
            int canAdd = Math.min(remaining, maxStackSize - stack.getStackSize());
            stack.setStackSize(stack.getStackSize() + canAdd);
            remaining -= canAdd;
            
            if (remaining == 0) {
                return AddItemResult.success();
            }
        }
    }
    
    // 2. Создать новые стаки
    while (remaining > 0) {
        int slotIndex = findEmptySlot(characterId);
        if (slotIndex == -1) {
            return AddItemResult.fail("Inventory full");
        }
        
        int stackSize = Math.min(remaining, maxStackSize);
        InventoryItem newStack = new InventoryItem();
        newStack.setCharacterId(characterId);
        newStack.setItemTemplateId(template.getId());
        newStack.setSlotIndex(slotIndex);
        newStack.setStackSize(stackSize);
        
        inventoryRepository.save(newStack);
        remaining -= stackSize;
    }
    
    return AddItemResult.success();
}
```

---

## Pickup Item

```java
@PostMapping("/inventory/pickup/{itemId}")
public PickupResponse pickupItem(
    @RequestHeader("Authorization") String token,
    @PathVariable UUID itemId
) {
    UUID playerId = extractPlayerId(token);
    Character character = getActiveCharacter(playerId);
    
    // 1. Проверить дистанцию
    WorldItem worldItem = worldItemRepository.findById(itemId).orElseThrow();
    float distance = Vector3.distance(character.getPosition(), worldItem.getPosition());
    
    if (distance > PICKUP_RADIUS) {
        return error("Too far away");
    }
    
    // 2. Добавить в инвентарь
    AddItemResult result = addItem(character.getId(), worldItem.getItemTemplateId(), worldItem.getQuantity());
    
    if (!result.isSuccess()) {
        return error(result.getMessage());
    }
    
    // 3. Удалить из мира
    worldItemRepository.delete(worldItem);
    
    return PickupResponse.success();
}
```

---

## Drop Item

```java
@PostMapping("/inventory/drop")
public DropResponse dropItem(
    @RequestHeader("Authorization") String token,
    @RequestBody DropRequest request
) {
    UUID playerId = extractPlayerId(token);
    Character character = getActiveCharacter(playerId);
    
    // 1. Найти item
    InventoryItem item = inventoryRepository
        .findByCharacterAndSlot(character.getId(), request.getSlotIndex())
        .orElseThrow(() -> new ItemNotFoundException());
    
    int dropQuantity = request.getQuantity();
    
    // 2. Создать world item
    WorldItem worldItem = new WorldItem();
    worldItem.setItemTemplateId(item.getItemTemplateId());
    worldItem.setQuantity(dropQuantity);
    worldItem.setPosition(character.getPosition());
    worldItem.setZoneId(character.getZoneId());
    worldItem.setExpiresAt(Instant.now().plus(Duration.ofMinutes(5)));
    
    worldItemRepository.save(worldItem);
    
    // 3. Уменьшить стак или удалить
    if (item.getStackSize() > dropQuantity) {
        item.setStackSize(item.getStackSize() - dropQuantity);
        inventoryRepository.save(item);
    } else {
        inventoryRepository.delete(item);
    }
    
    return DropResponse.success(worldItem.getId());
}
```

---

## API Endpoints

**GET `/api/v1/inventory`** - получить инвентарь
**POST `/api/v1/inventory/pickup/{itemId}`** - поднять
**POST `/api/v1/inventory/drop`** - выбросить
**POST `/api/v1/inventory/move`** - переместить слот

---

## Связанные документы

- `.BRAIN/05-technical/backend/inventory/inventory-equipment.md` - Equipment (микрофича 2/3)
- `.BRAIN/05-technical/backend/inventory/inventory-storage.md` - Storage (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:40)** - Микрофича 1/3: Inventory Core (split from inventory-system.md)

