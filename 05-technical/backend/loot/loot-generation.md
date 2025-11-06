---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:45  
**api-readiness-notes:** Loot Generation микрофича. Loot tables, weighted random, drop rates, boss loot. ~380 строк.
---

# Loot Generation - Генерация лута

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:45  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Loot generation from tables  
**Размер:** ~380 строк ✅

---

## Краткое описание

**Loot Generation** - генерация лута из loot tables (weighted random).

**Ключевые возможности:**
- ✅ Loot tables (по врагам/боссам)
- ✅ Weighted random selection
- ✅ Drop rates (common, rare, epic)
- ✅ Boss guaranteed loot

---

## Database Schema

```sql
CREATE TABLE loot_tables (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- For what (mob, boss, chest, etc)
    source_type VARCHAR(50) NOT NULL,
    source_id VARCHAR(100),
    
    -- Guaranteed drops
    guaranteed_items JSONB, -- [{itemId, quantity, quality}]
    
    -- Random pools
    loot_pools JSONB, -- [{items, dropChance, minRolls, maxRolls}]
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_loot_source ON loot_tables(source_type, source_id);
```

---

## Loot Table Structure

```json
{
  "id": "boss_cyberdragon_001",
  "name": "Cyber Dragon Loot",
  "source_type": "BOSS",
  "guaranteed_items": [
    {
      "itemId": "currency_credits",
      "quantity": 1000,
      "quality": "COMMON"
    }
  ],
  "loot_pools": [
    {
      "poolName": "Weapons",
      "dropChance": 1.0,
      "minRolls": 1,
      "maxRolls": 2,
      "items": [
        {
          "itemId": "weapon_plasma_rifle_epic",
          "weight": 5,
          "quantity": 1,
          "quality": "EPIC"
        },
        {
          "itemId": "weapon_laser_sword_rare",
          "weight": 15,
          "quantity": 1,
          "quality": "RARE"
        }
      ]
    },
    {
      "poolName": "Materials",
      "dropChance": 0.5,
      "minRolls": 2,
      "maxRolls": 5,
      "items": [
        {
          "itemId": "material_quantum_core",
          "weight": 10,
          "quantity": 1,
          "quality": "RARE"
        }
      ]
    }
  ]
}
```

---

## Loot Generation Algorithm

```java
@Service
public class LootGenerator {
    
    public List<LootItem> generateLoot(String lootTableId, float luckModifier) {
        LootTable table = lootTableRepository.findById(lootTableId).orElseThrow();
        List<LootItem> generatedLoot = new ArrayList<>();
        
        // 1. Guaranteed items
        for (GuaranteedItem item : table.getGuaranteedItems()) {
            generatedLoot.add(new LootItem(
                item.getItemId(),
                item.getQuantity(),
                item.getQuality()
            ));
        }
        
        // 2. Random pools
        for (LootPool pool : table.getLootPools()) {
            // Roll for pool drop
            if (random.nextFloat() > pool.getDropChance() * (1 + luckModifier)) {
                continue; // Pool не выпал
            }
            
            // Determine roll count
            int rolls = random.nextInt(pool.getMaxRolls() - pool.getMinRolls() + 1) 
                      + pool.getMinRolls();
            
            // Roll items
            for (int i = 0; i < rolls; i++) {
                LootItem item = rollWeightedRandom(pool.getItems());
                if (item != null) {
                    generatedLoot.add(item);
                }
            }
        }
        
        return generatedLoot;
    }
    
    private LootItem rollWeightedRandom(List<LootPoolItem> items) {
        int totalWeight = items.stream().mapToInt(LootPoolItem::getWeight).sum();
        int roll = random.nextInt(totalWeight);
        
        int cumulative = 0;
        for (LootPoolItem item : items) {
            cumulative += item.getWeight();
            if (roll < cumulative) {
                return new LootItem(
                    item.getItemId(),
                    item.getQuantity(),
                    item.getQuality()
                );
            }
        }
        
        return null;
    }
}
```

---

## Drop on Enemy Death

```java
@Transactional
public void onEnemyDeath(UUID enemyId, UUID killerId) {
    Enemy enemy = enemyRepository.findById(enemyId).orElseThrow();
    String lootTableId = enemy.getLootTableId();
    
    if (lootTableId == null) {
        return; // No loot
    }
    
    // Generate loot
    Character killer = characterRepository.findById(killerId).orElse(null);
    float luckModifier = killer != null ? killer.getLuckStat() / 100.0f : 0.0f;
    
    List<LootItem> loot = lootGenerator.generateLoot(lootTableId, luckModifier);
    
    if (loot.isEmpty()) {
        return;
    }
    
    // Create world items
    Vector3 dropPosition = enemy.getPosition();
    
    for (LootItem item : loot) {
        WorldItem worldItem = new WorldItem();
        worldItem.setItemTemplateId(item.getItemId());
        worldItem.setQuantity(item.getQuantity());
        worldItem.setPosition(dropPosition);
        worldItem.setZoneId(enemy.getZoneId());
        worldItem.setOwnerPlayerId(getPlayerId(killerId)); // 30 sec personal loot
        worldItem.setExpiresAt(Instant.now().plus(Duration.ofMinutes(5)));
        
        worldItemRepository.save(worldItem);
    }
    
    // Notify
    wsService.broadcastToZone(enemy.getZoneId(),
        new LootDroppedMessage(enemy.getId(), loot.size()));
}
```

---

## API Endpoints

**GET `/api/v1/loot-tables/{id}`** - loot table (admin)
**POST `/api/v1/loot-tables`** - создать (admin)

---

## Связанные документы

- `.BRAIN/05-technical/backend/loot/loot-distribution.md` - Distribution (микрофича 2/2)

---

## История изменений

- **v1.0.0 (2025-11-07 05:45)** - Микрофича 1/2: Loot Generation (split from loot-system.md)

