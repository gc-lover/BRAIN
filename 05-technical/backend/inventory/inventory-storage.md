---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:40  
**api-readiness-notes:** Inventory Storage микрофича. Bank/stash, use/consume items, quick slots. ~320 строк.
---

# Inventory Storage - Хранение и использование

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:40  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Storage & consumables  
**Размер:** ~320 строк ✅

---

## Краткое описание

**Inventory Storage** - банк, использование предметов, быстрые слоты.

**Ключевые возможности:**
- ✅ Bank/Stash (200 slots)
- ✅ Use/Consume items
- ✅ Quick slots (hotbar)

---

## Bank Storage

```sql
CREATE TABLE bank_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    item_template_id VARCHAR(100) NOT NULL,
    
    slot_index INTEGER NOT NULL,
    stack_size INTEGER DEFAULT 1,
    
    custom_data JSONB,
    
    deposited_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_bank_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, slot_index)
);
```

---

## Deposit to Bank

```java
@PostMapping("/bank/deposit")
@Transactional
public BankResponse deposit(
    @RequestHeader("Authorization") String token,
    @RequestBody BankDepositRequest request
) {
    UUID playerId = extractPlayerId(token);
    Character character = getActiveCharacter(playerId);
    
    // 1. Проверить дистанцию до банка
    if (!isNearBank(character.getPosition())) {
        return error("Not near a bank");
    }
    
    // 2. Найти item
    InventoryItem item = inventoryRepository
        .findByCharacterAndSlot(character.getId(), request.getSlotIndex())
        .orElseThrow();
    
    // 3. Найти свободный слот в банке
    int bankSlot = findEmptyBankSlot(playerId);
    if (bankSlot == -1) {
        return error("Bank full");
    }
    
    // 4. Переместить в банк
    BankItem bankItem = new BankItem();
    bankItem.setPlayerId(playerId);
    bankItem.setItemTemplateId(item.getItemTemplateId());
    bankItem.setSlotIndex(bankSlot);
    bankItem.setStackSize(item.getStackSize());
    
    bankItemRepository.save(bankItem);
    inventoryRepository.delete(item);
    
    return BankResponse.success();
}
```

---

## Use/Consume Item

```java
@PostMapping("/inventory/use")
@Transactional
public UseItemResponse useItem(
    @RequestHeader("Authorization") String token,
    @RequestBody UseItemRequest request
) {
    UUID playerId = extractPlayerId(token);
    Character character = getActiveCharacter(playerId);
    
    // 1. Найти item
    InventoryItem item = inventoryRepository
        .findByCharacterAndSlot(character.getId(), request.getSlotIndex())
        .orElseThrow();
    
    ItemTemplate template = itemTemplateRepository
        .findById(item.getItemTemplateId())
        .orElseThrow();
    
    // 2. Проверить usable
    if (template.getItemType() != ItemType.CONSUMABLE) {
        return error("Item is not usable");
    }
    
    // 3. Apply effect
    applyItemEffect(character, template);
    
    // 4. Consume (уменьшить стак)
    if (item.getStackSize() > 1) {
        item.setStackSize(item.getStackSize() - 1);
        inventoryRepository.save(item);
    } else {
        inventoryRepository.delete(item);
    }
    
    // 5. Cooldown
    setCooldown(character.getId(), template.getId(), template.getCooldown());
    
    return UseItemResponse.success();
}

private void applyItemEffect(Character character, ItemTemplate item) {
    switch (item.getEffectType()) {
        case HEAL:
            character.setCurrentHealth(
                Math.min(character.getMaxHealth(), 
                         character.getCurrentHealth() + item.getEffectValue())
            );
            break;
            
        case BUFF:
            buffService.applyBuff(character.getId(), item.getBuffId(), item.getDuration());
            break;
            
        // ... other effects
    }
    
    characterRepository.save(character);
}
```

---

## Quick Slots (Hotbar)

```sql
CREATE TABLE quick_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    slot_index INTEGER NOT NULL, -- 0-9
    
    item_type VARCHAR(20) NOT NULL, -- INVENTORY, SKILL, EMOTE
    reference_id UUID, -- InventoryItem ID or Skill ID
    
    CONSTRAINT fk_quickslot_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    UNIQUE(character_id, slot_index)
);
```

---

## API Endpoints

**GET `/api/v1/bank`** - содержимое банка
**POST `/api/v1/bank/deposit`** - положить в банк
**POST `/api/v1/bank/withdraw`** - взять из банка
**POST `/api/v1/inventory/use`** - использовать
**PUT `/api/v1/quickslots/{index}`** - настроить hotbar

---

## Связанные документы

- `.BRAIN/05-technical/backend/inventory/inventory-core.md` - Core (микрофича 1/3)
- `.BRAIN/05-technical/backend/inventory/inventory-equipment.md` - Equipment (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:40)** - Микрофича 3/3: Inventory Storage (split from inventory-system.md)

