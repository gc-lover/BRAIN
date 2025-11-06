---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Полная система инвентаря. Slots, stacking, weight/encumbrance, pickup/drop, use/consume, equipment slots, bank/stash, transfer items (trade, mail, auction).
---

# Inventory System - Система инвентаря

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

---

## Краткое описание

**Inventory System** - критически важная система для управления предметами игроков. Без этой системы игра не может работать. Обеспечивает хранение, управление, перемещение и использование предметов.

**Ключевые возможности:**
- ✅ Inventory slots (ограниченное количество слотов)
- ✅ Item stacking (складывание однотипных предметов)
- ✅ Weight/Encumbrance system (вес и перегрузка)
- ✅ Item pickup/drop
- ✅ Item use/consume
- ✅ Equipment slots (weapon, armor, implants, cyberware)
- ✅ Bank/Stash storage (дополнительное хранилище)
- ✅ Transfer items (trade, mail, auction)
- ✅ Item durability (износ предметов)
- ✅ Bind-on-Pickup / Bind-on-Equip

---

## Архитектура системы

### Inventory Structure

```
CHARACTER
    │
    ├─→ BACKPACK (Inventory)
    │   ├─ Slot 1: Weapon (stackable: no)
    │   ├─ Slot 2: Ammo x250 (stackable: yes)
    │   ├─ Slot 3: Medikit x5 (stackable: yes)
    │   ├─ ...
    │   └─ Slot 50: (empty)
    │
    ├─→ EQUIPMENT (Equipped items)
    │   ├─ Weapon Slot 1: Mantis Blades
    │   ├─ Weapon Slot 2: Pistol
    │   ├─ Armor: Corpo Suit
    │   ├─ Implants: [Kerenzikov, Sandevistan, ...]
    │   └─ Cyberware: [Optical Implant, Gorilla Arms, ...]
    │
    └─→ BANK/STASH (Shared storage)
        ├─ Slot 1: Materials x999
        ├─ Slot 2: Rare Item
        ├─ ...
        └─ Slot 100: (empty)
```

---

## Database Schema

### Таблица `character_inventory`

```sql
CREATE TABLE character_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    
    -- Инвентарь
    max_slots INTEGER DEFAULT 50,
    current_weight DECIMAL(10,2) DEFAULT 0,
    max_weight DECIMAL(10,2) DEFAULT 200.00, -- Зависит от Body attribute
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_inventory_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    UNIQUE(character_id)
);
```

### Таблица `character_items`

```sql
CREATE TABLE character_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    
    -- Item reference
    item_template_id VARCHAR(100) NOT NULL, -- ID шаблона предмета
    
    -- Location
    storage_type VARCHAR(20) NOT NULL DEFAULT 'BACKPACK',
    -- BACKPACK, EQUIPPED, BANK, STASH
    
    slot_index INTEGER, -- Позиция в инвентаре (0-49 for backpack, 0-99 for bank)
    equipment_slot VARCHAR(50), -- Если EQUIPPED: WEAPON_1, WEAPON_2, ARMOR, etc
    
    -- Quantity (для stackable items)
    quantity INTEGER DEFAULT 1,
    
    -- Durability (для equipment)
    current_durability INTEGER DEFAULT 100,
    max_durability INTEGER DEFAULT 100,
    
    -- Binding
    bind_type VARCHAR(20) DEFAULT 'NONE',
    -- NONE, BIND_ON_PICKUP, BIND_ON_EQUIP, BIND_TO_ACCOUNT
    
    is_bound BOOLEAN DEFAULT FALSE,
    bound_at TIMESTAMP,
    
    -- Modifiers (для уникальных предметов)
    modifiers JSONB, -- {damage_bonus: +10, crit_chance: +5%}
    
    -- Enchantments / Upgrades
    enchantments JSONB DEFAULT '[]',
    upgrade_level INTEGER DEFAULT 0,
    
    -- Acquisition
    acquired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    acquired_from VARCHAR(100), -- LOOT, CRAFT, TRADE, QUEST, PURCHASE
    
    -- Trading
    is_tradeable BOOLEAN DEFAULT TRUE,
    is_sellable BOOLEAN DEFAULT TRUE,
    is_deletable BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_item_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE
);

CREATE INDEX idx_items_character ON character_items(character_id);
CREATE INDEX idx_items_template ON character_items(item_template_id);
CREATE INDEX idx_items_storage ON character_items(character_id, storage_type);
CREATE INDEX idx_items_slot ON character_items(character_id, storage_type, slot_index);
```

### Таблица `item_templates`

```sql
CREATE TABLE item_templates (
    id VARCHAR(100) PRIMARY KEY,
    
    -- Basic info
    item_name VARCHAR(200) NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    -- WEAPON, ARMOR, CONSUMABLE, MATERIAL, QUEST_ITEM, CYBERWARE, IMPLANT, etc
    
    item_subtype VARCHAR(50), -- PISTOL, RIFLE, MELEE, etc
    
    -- Rarity
    rarity VARCHAR(20) DEFAULT 'COMMON',
    -- COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, UNIQUE
    
    -- Stacking
    is_stackable BOOLEAN DEFAULT FALSE,
    max_stack_size INTEGER DEFAULT 1,
    
    -- Weight
    weight DECIMAL(6,2) DEFAULT 1.00,
    
    -- Value
    vendor_price INTEGER DEFAULT 0,
    
    -- Requirements
    required_level INTEGER DEFAULT 1,
    required_attributes JSONB, -- {body: 5, reflexes: 8}
    
    -- Stats (для equipment)
    stats JSONB, -- {damage: 50, armor: 100, etc}
    
    -- Effects (для consumables)
    effects JSONB, -- [{type: "HEAL", value: 50}]
    
    -- Icon
    icon_url VARCHAR(500),
    
    -- Description
    description TEXT,
    lore_text TEXT,
    
    -- Flags
    is_unique BOOLEAN DEFAULT FALSE,
    is_quest_item BOOLEAN DEFAULT FALSE,
    
    -- Binding
    bind_on_pickup BOOLEAN DEFAULT FALSE,
    bind_on_equip BOOLEAN DEFAULT FALSE,
    
    -- Trading
    is_tradeable BOOLEAN DEFAULT TRUE,
    is_sellable BOOLEAN DEFAULT TRUE,
    is_deletable BOOLEAN DEFAULT TRUE,
    
    -- Durability
    has_durability BOOLEAN DEFAULT FALSE,
    base_durability INTEGER DEFAULT 100,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_templates_type ON item_templates(item_type);
CREATE INDEX idx_templates_rarity ON item_templates(rarity);
```

### Таблица `equipment_slots`

```sql
CREATE TABLE equipment_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    
    -- Weapon slots
    weapon_slot_1 UUID, -- FK to character_items
    weapon_slot_2 UUID,
    weapon_slot_3 UUID, -- Unlocks at level 10
    
    -- Armor
    head_slot UUID,
    chest_slot UUID,
    legs_slot UUID,
    boots_slot UUID,
    gloves_slot UUID,
    
    -- Cyberware/Implants (multiple slots)
    cyberware_slots JSONB DEFAULT '[]', -- Array of character_item IDs
    implant_slots JSONB DEFAULT '[]',
    
    -- Accessories
    accessory_slot_1 UUID,
    accessory_slot_2 UUID,
    
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_equipment_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE,
    UNIQUE(character_id)
);
```

### Таблица `bank_storage`

```sql
CREATE TABLE bank_storage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL, -- Shared between characters!
    
    max_slots INTEGER DEFAULT 100,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_bank_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE,
    UNIQUE(account_id)
);
```

---

## Item Pickup

### Подбор предмета с земли

```java
@Service
public class InventoryService {
    
    @Transactional
    public PickupResponse pickupItem(
        UUID characterId,
        String itemTemplateId,
        int quantity
    ) {
        // 1. Получить инвентарь
        CharacterInventory inventory = inventoryRepository
            .findByCharacter(characterId)
            .orElseThrow(() -> new InventoryNotFoundException());
        
        // 2. Получить шаблон предмета
        ItemTemplate template = itemTemplateRepository.findById(itemTemplateId)
            .orElseThrow(() -> new ItemTemplateNotFoundException());
        
        // 3. Проверить вес
        double totalWeight = template.getWeight() * quantity;
        if (inventory.getCurrentWeight() + totalWeight > inventory.getMaxWeight()) {
            throw new OverweightException(
                "Cannot carry more weight. Drop some items or increase Body attribute."
            );
        }
        
        // 4. Проверить requirements
        if (!meetsRequirements(characterId, template)) {
            throw new RequirementsNotMetException(
                "You don't meet the requirements for this item"
            );
        }
        
        // 5. Если stackable, попробовать добавить к существующему стеку
        if (template.isStackable()) {
            Optional<CharacterItem> existingStack = findExistingStack(
                characterId,
                itemTemplateId
            );
            
            if (existingStack.isPresent()) {
                CharacterItem item = existingStack.get();
                
                int newQuantity = item.getQuantity() + quantity;
                if (newQuantity > template.getMaxStackSize()) {
                    // Стек переполнен, создаем новый
                    int overflow = newQuantity - template.getMaxStackSize();
                    item.setQuantity(template.getMaxStackSize());
                    itemRepository.save(item);
                    
                    // Создать новый стек для overflow
                    return pickupItem(characterId, itemTemplateId, overflow);
                } else {
                    item.setQuantity(newQuantity);
                    itemRepository.save(item);
                    
                    return new PickupResponse(item.getId(), "Added to existing stack");
                }
            }
        }
        
        // 6. Найти свободный слот
        int freeSlot = findFreeSlot(characterId, StorageType.BACKPACK);
        if (freeSlot == -1) {
            throw new InventoryFullException("No free inventory slots");
        }
        
        // 7. Создать предмет
        CharacterItem item = new CharacterItem();
        item.setCharacterId(characterId);
        item.setItemTemplateId(itemTemplateId);
        item.setStorageType(StorageType.BACKPACK);
        item.setSlotIndex(freeSlot);
        item.setQuantity(quantity);
        item.setAcquiredFrom("LOOT");
        
        // Bind-on-pickup
        if (template.isBindOnPickup()) {
            item.setBindType(BindType.BIND_ON_PICKUP);
            item.setBound(true);
            item.setBoundAt(Instant.now());
        }
        
        item = itemRepository.save(item);
        
        // 8. Обновить вес
        inventory.setCurrentWeight(inventory.getCurrentWeight() + totalWeight);
        inventoryRepository.save(inventory);
        
        // 9. Логировать
        log.info("Character {} picked up {} x{}", characterId, itemTemplateId, quantity);
        
        // 10. Уведомить
        notificationService.send(
            getAccountId(characterId),
            new ItemPickedUpNotification(template.getItemName(), quantity)
        );
        
        return new PickupResponse(item.getId(), "Item picked up");
    }
    
    private boolean meetsRequirements(UUID characterId, ItemTemplate template) {
        if (template.getRequiredAttributes() == null) {
            return true;
        }
        
        Character character = characterRepository.findById(characterId).get();
        Map<String, Integer> attributes = character.getAttributes();
        Map<String, Integer> required = template.getRequiredAttributes();
        
        for (Map.Entry<String, Integer> entry : required.entrySet()) {
            int playerValue = attributes.getOrDefault(entry.getKey(), 0);
            if (playerValue < entry.getValue()) {
                return false;
            }
        }
        
        return true;
    }
}
```

---

## Item Drop

### Выбросить предмет

```java
@Transactional
public void dropItem(UUID characterId, UUID itemId, int quantity) {
    // 1. Найти предмет
    CharacterItem item = itemRepository.findById(itemId)
        .orElseThrow(() -> new ItemNotFoundException());
    
    if (!item.getCharacterId().equals(characterId)) {
        throw new UnauthorizedItemAccessException();
    }
    
    // 2. Проверить, можно ли выбросить
    if (!item.isDeletable()) {
        throw new CannotDropItemException("This item cannot be dropped");
    }
    
    // 3. Проверить количество
    if (quantity > item.getQuantity()) {
        throw new InsufficientQuantityException();
    }
    
    // 4. Получить template для веса
    ItemTemplate template = itemTemplateRepository.findById(item.getItemTemplateId()).get();
    double weight = template.getWeight() * quantity;
    
    // 5. Уменьшить количество или удалить
    if (quantity == item.getQuantity()) {
        // Удалить полностью
        itemRepository.delete(item);
    } else {
        // Уменьшить количество
        item.setQuantity(item.getQuantity() - quantity);
        itemRepository.save(item);
    }
    
    // 6. Обновить вес
    CharacterInventory inventory = inventoryRepository.findByCharacter(characterId).get();
    inventory.setCurrentWeight(inventory.getCurrentWeight() - weight);
    inventoryRepository.save(inventory);
    
    // 7. Создать world drop (в зоне)
    worldDropService.createDrop(
        getCharacterZone(characterId),
        getCharacterPosition(characterId),
        item.getItemTemplateId(),
        quantity
    );
    
    log.info("Character {} dropped {} x{}", characterId, item.getItemTemplateId(), quantity);
}
```

---

## Item Use/Consume

### Использовать предмет

```java
@Transactional
public UseItemResponse useItem(UUID characterId, UUID itemId) {
    // 1. Найти предмет
    CharacterItem item = itemRepository.findById(itemId)
        .orElseThrow(() -> new ItemNotFoundException());
    
    // 2. Получить template
    ItemTemplate template = itemTemplateRepository.findById(item.getItemTemplateId()).get();
    
    // 3. Проверить тип
    if (template.getItemType() != ItemType.CONSUMABLE) {
        throw new CannotUseItemException("This item is not consumable");
    }
    
    // 4. Применить эффекты
    List<ItemEffect> effects = template.getEffects();
    for (ItemEffect effect : effects) {
        applyEffect(characterId, effect);
    }
    
    // 5. Уменьшить quantity
    if (item.getQuantity() > 1) {
        item.setQuantity(item.getQuantity() - 1);
        itemRepository.save(item);
    } else {
        // Удалить предмет
        itemRepository.delete(item);
    }
    
    // 6. Обновить вес
    CharacterInventory inventory = inventoryRepository.findByCharacter(characterId).get();
    inventory.setCurrentWeight(inventory.getCurrentWeight() - template.getWeight());
    inventoryRepository.save(inventory);
    
    log.info("Character {} used item {}", characterId, template.getItemName());
    
    return new UseItemResponse("Item used successfully", effects);
}

private void applyEffect(UUID characterId, ItemEffect effect) {
    Character character = characterRepository.findById(characterId).get();
    
    switch (effect.getType()) {
        case HEAL:
            int newHealth = Math.min(
                character.getHealth() + effect.getValue(),
                character.getMaxHealth()
            );
            character.setHealth(newHealth);
            characterRepository.save(character);
            break;
            
        case BUFF:
            // Применить временный buff
            buffService.applyBuff(characterId, effect.getBuffId(), effect.getDuration());
            break;
            
        case RESTORE_STAMINA:
            // ...
            break;
            
        // ... other effects
    }
}
```

---

## Equipment System

### Equip Item

```java
@Transactional
public EquipResponse equipItem(UUID characterId, UUID itemId, String equipmentSlot) {
    // 1. Найти предмет
    CharacterItem item = itemRepository.findById(itemId)
        .orElseThrow(() -> new ItemNotFoundException());
    
    if (item.getStorageType() == StorageType.EQUIPPED) {
        throw new ItemAlreadyEquippedException();
    }
    
    // 2. Получить template
    ItemTemplate template = itemTemplateRepository.findById(item.getItemTemplateId()).get();
    
    // 3. Проверить, что это equipment
    if (!isEquipmentType(template.getItemType())) {
        throw new CannotEquipItemException("This item cannot be equipped");
    }
    
    // 4. Проверить requirements
    if (!meetsRequirements(characterId, template)) {
        throw new RequirementsNotMetException();
    }
    
    // 5. Проверить слот
    EquipmentSlots slots = equipmentSlotsRepository.findByCharacter(characterId).get();
    
    UUID currentlyEquipped = getItemInSlot(slots, equipmentSlot);
    
    // 6. Если слот занят, unequip
    if (currentlyEquipped != null) {
        unequipItem(characterId, currentlyEquipped);
    }
    
    // 7. Equip новый предмет
    item.setStorageType(StorageType.EQUIPPED);
    item.setEquipmentSlot(equipmentSlot);
    item.setSlotIndex(null);
    
    // Bind-on-equip
    if (template.isBindOnEquip() && !item.isBound()) {
        item.setBindType(BindType.BIND_ON_EQUIP);
        item.setBound(true);
        item.setBoundAt(Instant.now());
    }
    
    itemRepository.save(item);
    
    // 8. Обновить equipment slots
    setItemInSlot(slots, equipmentSlot, itemId);
    equipmentSlotsRepository.save(slots);
    
    // 9. Пересчитать stats персонажа
    recalculateCharacterStats(characterId);
    
    // 10. Уведомить
    notificationService.send(
        getAccountId(characterId),
        new ItemEquippedNotification(template.getItemName())
    );
    
    log.info("Character {} equipped {} in slot {}", characterId, itemId, equipmentSlot);
    
    return new EquipResponse("Item equipped successfully");
}
```

### Unequip Item

```java
@Transactional
public void unequipItem(UUID characterId, UUID itemId) {
    // 1. Найти предмет
    CharacterItem item = itemRepository.findById(itemId)
        .orElseThrow(() -> new ItemNotFoundException());
    
    // 2. Найти свободный слот в backpack
    int freeSlot = findFreeSlot(characterId, StorageType.BACKPACK);
    if (freeSlot == -1) {
        throw new InventoryFullException("No free slots. Cannot unequip.");
    }
    
    // 3. Переместить в backpack
    String equipmentSlot = item.getEquipmentSlot();
    
    item.setStorageType(StorageType.BACKPACK);
    item.setEquipmentSlot(null);
    item.setSlotIndex(freeSlot);
    itemRepository.save(item);
    
    // 4. Обновить equipment slots
    EquipmentSlots slots = equipmentSlotsRepository.findByCharacter(characterId).get();
    setItemInSlot(slots, equipmentSlot, null);
    equipmentSlotsRepository.save(slots);
    
    // 5. Пересчитать stats
    recalculateCharacterStats(characterId);
    
    log.info("Character {} unequipped {}", characterId, itemId);
}
```

---

## Bank/Stash Storage

### Deposit to Bank

```java
@Transactional
public void depositToBank(UUID characterId, UUID itemId, int quantity) {
    // 1. Найти предмет в backpack
    CharacterItem item = itemRepository.findById(itemId)
        .orElseThrow(() -> new ItemNotFoundException());
    
    if (item.getStorageType() != StorageType.BACKPACK) {
        throw new ItemNotInBackpackException();
    }
    
    // 2. Проверить, можно ли положить в банк
    if (item.isBound()) {
        throw new CannotDepositBoundItemException();
    }
    
    // 3. Проверить bank slots
    UUID accountId = getAccountId(characterId);
    BankStorage bank = bankStorageRepository.findByAccount(accountId).get();
    
    int usedSlots = countBankUsedSlots(accountId);
    if (usedSlots >= bank.getMaxSlots()) {
        throw new BankFullException();
    }
    
    // 4. Переместить в bank
    if (quantity == item.getQuantity()) {
        // Переместить полностью
        int bankSlot = findFreeBankSlot(accountId);
        item.setStorageType(StorageType.BANK);
        item.setSlotIndex(bankSlot);
        itemRepository.save(item);
    } else {
        // Split stack
        item.setQuantity(item.getQuantity() - quantity);
        itemRepository.save(item);
        
        // Создать новый item в банке
        CharacterItem bankItem = item.clone();
        bankItem.setId(UUID.randomUUID());
        bankItem.setQuantity(quantity);
        bankItem.setStorageType(StorageType.BANK);
        bankItem.setSlotIndex(findFreeBankSlot(accountId));
        itemRepository.save(bankItem);
    }
    
    log.info("Character {} deposited {} x{} to bank", characterId, itemId, quantity);
}
```

### Withdraw from Bank

```java
@Transactional
public void withdrawFromBank(UUID characterId, UUID itemId, int quantity) {
    // Similar to deposit, but opposite direction
    // Check backpack space, move item from BANK to BACKPACK
    // ...
}
```

---

## Item Transfer (Trade/Mail/Auction)

### Transfer Item

```java
@Transactional
public void transferItem(
    UUID fromCharacterId,
    UUID toCharacterId,
    UUID itemId,
    int quantity,
    TransferType transferType
) {
    // 1. Найти предмет
    CharacterItem item = itemRepository.findById(itemId)
        .orElseThrow(() -> new ItemNotFoundException());
    
    // 2. Проверить, можно ли передать
    if (item.isBound()) {
        throw new CannotTradeB oundItemException();
    }
    
    if (!item.isTradeable()) {
        throw new ItemNotTradeableException();
    }
    
    // 3. Проверить получателя
    if (!hasInventorySpace(toCharacterId, item.getItemTemplateId(), quantity)) {
        throw new RecipientInventoryFullException();
    }
    
    // 4. Удалить у отправителя
    if (quantity == item.getQuantity()) {
        itemRepository.delete(item);
    } else {
        item.setQuantity(item.getQuantity() - quantity);
        itemRepository.save(item);
    }
    
    // 5. Создать у получателя
    CharacterItem newItem = new CharacterItem();
    newItem.setCharacterId(toCharacterId);
    newItem.setItemTemplateId(item.getItemTemplateId());
    newItem.setQuantity(quantity);
    newItem.setStorageType(StorageType.BACKPACK);
    newItem.setSlotIndex(findFreeSlot(toCharacterId, StorageType.BACKPACK));
    newItem.setAcquiredFrom(transferType.name()); // TRADE, MAIL, AUCTION
    itemRepository.save(newItem);
    
    // 6. Обновить вес у обоих
    updateInventoryWeight(fromCharacterId);
    updateInventoryWeight(toCharacterId);
    
    log.info("Item {} x{} transferred from {} to {} via {}",
        itemId, quantity, fromCharacterId, toCharacterId, transferType);
}
```

---

## Item Durability

### Reduce Durability

```java
public void reduceDurability(UUID itemId, int amount) {
    CharacterItem item = itemRepository.findById(itemId).get();
    ItemTemplate template = itemTemplateRepository.findById(item.getItemTemplateId()).get();
    
    if (!template.hassDurability()) {
        return;
    }
    
    int newDurability = Math.max(0, item.getCurrentDurability() - amount);
    item.setCurrentDurability(newDurability);
    itemRepository.save(item);
    
    // Если durability = 0, item broken
    if (newDurability == 0) {
        handleItemBroken(item);
    } else if (newDurability < item.getMaxDurability() * 0.2) {
        // Low durability warning
        notificationService.send(
            getAccountId(item.getCharacterId()),
            new LowDurabilityWarning(template.getItemName())
        );
    }
}

private void handleItemBroken(CharacterItem item) {
    // Item broken, need repair
    item.setCurrentDurability(0);
    
    // Если equipped, снять stats bonuses
    if (item.getStorageType() == StorageType.EQUIPPED) {
        recalculateCharacterStats(item.getCharacterId());
    }
    
    notificationService.send(
        getAccountId(item.getCharacterId()),
        new ItemBrokenNotification(getItemName(item))
    );
}
```

### Repair Item

```java
@Transactional
public RepairResponse repairItem(UUID characterId, UUID itemId) {
    CharacterItem item = itemRepository.findById(itemId).get();
    
    // Проверить стоимость ремонта
    int repairCost = calculateRepairCost(item);
    
    Character character = characterRepository.findById(characterId).get();
    if (character.getEddies() < repairCost) {
        throw new InsufficientFundsException();
    }
    
    // Списать деньги
    character.setEddies(character.getEddies() - repairCost);
    characterRepository.save(character);
    
    // Восстановить durability
    item.setCurrentDurability(item.getMaxDurability());
    itemRepository.save(item);
    
    // Если equipped, пересчитать stats
    if (item.getStorageType() == StorageType.EQUIPPED) {
        recalculateCharacterStats(characterId);
    }
    
    return new RepairResponse("Item repaired", repairCost);
}

private int calculateRepairCost(CharacterItem item) {
    ItemTemplate template = itemTemplateRepository.findById(item.getItemTemplateId()).get();
    
    double durabilityPercent = (double) item.getCurrentDurability() / item.getMaxDurability();
    double missingPercent = 1.0 - durabilityPercent;
    
    // Стоимость = vendor price * missing durability %
    return (int) (template.getVendorPrice() * missingPercent * 0.5); // 50% от vendor price
}
```

---

## API Endpoints

### Inventory Management

**GET `/api/v1/inventory`** - получить инвентарь
```json
{
  "backpack": {
    "maxSlots": 50,
    "usedSlots": 25,
    "currentWeight": 120.5,
    "maxWeight": 200.0,
    "items": [
      {
        "id": "uuid",
        "templateId": "mantis_blades",
        "name": "Mantis Blades",
        "quantity": 1,
        "slotIndex": 0,
        "weight": 5.0,
        "rarity": "LEGENDARY"
      },
      ...
    ]
  },
  "equipment": {
    "weapon1": {...},
    "weapon2": {...},
    "armor": {...},
    ...
  }
}
```

**POST `/api/v1/inventory/pickup`** - подобрать предмет
**POST `/api/v1/inventory/drop`** - выбросить предмет
**POST `/api/v1/inventory/use`** - использовать предмет

### Equipment

**POST `/api/v1/inventory/equip`** - надеть предмет
**POST `/api/v1/inventory/unequip`** - снять предмет

### Bank/Stash

**GET `/api/v1/inventory/bank`** - банковское хранилище
**POST `/api/v1/inventory/bank/deposit`** - положить в банк
**POST `/api/v1/inventory/bank/withdraw`** - забрать из банка

### Item Management

**GET `/api/v1/inventory/items/{id}`** - информация о предмете
**POST `/api/v1/inventory/items/{id}/split`** - разделить стек
**POST `/api/v1/inventory/items/{id}/move`** - переместить предмет (swap slots)
**POST `/api/v1/inventory/items/{id}/repair`** - починить предмет

---

## Интеграция с другими системами

### При подборе предмета

```
InventoryService.pickupItem()
  ↓
→ QuestService: check quest objectives (collect 10 items)
→ AchievementService: check collection achievements
→ NotificationService: send pickup notification
→ EventBus: publish ITEM_PICKED_UP
```

### При equip

```
InventoryService.equipItem()
  ↓
→ CharacterService: recalculate stats (with item bonuses)
→ VisualService: update character appearance
→ EventBus: publish ITEM_EQUIPPED
```

### При ремонте

```
InventoryService.repairItem()
  ↓
→ EconomyService: deduct repair cost
→ CharacterService: recalculate stats (if equipped)
→ EventBus: publish ITEM_REPAIRED
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/player-character-management.md` - Character management
- `.BRAIN/05-technical/backend/loot-system.md` - Loot generation (будет создан)
- `.BRAIN/02-gameplay/economy/equipment-matrix.md` - Equipment templates
- `.BRAIN/02-gameplay/economy/economy-crafting.md` - Crafting system

---

## TODO

- [ ] Item sorting (by name, rarity, type)
- [ ] Item search/filter
- [ ] Bulk operations (sell all junk, disenchant all)
- [ ] Auto-loot settings
- [ ] Item comparison (when hovering)

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Inventory System

