---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-163: api/docs/integration-architecture.md (2025-11-07 11:30)
- Last Updated: 2025-11-07 00:18
---


# API Integration Map

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for Implementation

---

## 🔗 СИСТЕМНАЯ АРХИТЕКТУРА

```
┌─────────────────────────────────────────────────┐
│                   FRONTEND                       │
│              (FRONT-WEB / UE5)                  │
└────────────────┬────────────────────────────────┘
                 │
                 │ REST API (HTTP/JSON)
                 │
┌────────────────▼────────────────────────────────┐
│                 API GATEWAY                      │
│         (Auth, Rate Limit, Routing)             │
└────────────────┬────────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
┌───────────────┐  ┌───────────────┐
│  BACK-JAVA    │  │  Services     │
│  (Core Logic) │  │  (Microservices)│
└───────┬───────┘  └───────┬───────┘
        │                  │
        └────────┬─────────┘
                 │
        ┌────────▼────────┐
        │   PostgreSQL    │
        │   (Database)    │
        └─────────────────┘
```

---

## 🎯 DATA FLOW DIAGRAMS

### Quest Completion Flow

```
1. Player → Frontend
   ↓
2. POST /quests/{id}/complete
   ↓
3. API Gateway (Auth Check)
   ↓
4. QuestService.completeQuest()
   ├─ Validate objectives completed
   ├─ Calculate rewards
   ├─ Update player progress
   ├─ Trigger reputation changes
   └─ Unlock new quests
   ↓
5. Database Updates:
   ├─ UPDATE quests SET status='completed'
   ├─ UPDATE characters SET xp, level
   ├─ UPDATE reputation
   ├─ INSERT rewards into inventory
   └─ INSERT quest_history
   ↓
6. Response → Frontend
   ├─ Show rewards
   ├─ Show reputation changes
   ├─ Show unlocked content
   └─ Play celebration animation
```

---

### Combat Damage Calculation

```
1. Player shoots enemy
   ↓
2. POST /combat/damage
   ↓
3. CombatService.calculateDamage()
   ├─ Get weapon stats
   ├─ Get player attributes & skills
   ├─ Get enemy armor & resistances
   ├─ Check hit location (head/body)
   ├─ Roll critical hit chance
   ├─ Apply ability modifiers
   ├─ Apply combo bonuses
   └─ Calculate final damage
   ↓
4. Formula:
   Base = weapon.damage
   × (1 + attribute_modifier)
   × (1 + skill_bonus)
   × hit_location_multiplier
   × critical_multiplier
   × ability_multiplier
   × combo_multiplier
   - enemy.armor
   × (1 - enemy.resistance)
   ↓
5. Apply damage to enemy
   ├─ UPDATE enemy HP
   ├─ Check if dead → loot
   ├─ Grant XP
   ├─ Update weapon mastery
   └─ Trigger quest objectives
   ↓
6. Response with damage number & effects
```

---

### Crafting Item Flow

```
1. Player starts craft
   ↓
2. POST /recipes/{id}/craft
   ↓
3. CraftingService.craftItem()
   ├─ Validate requirements (skills, station, license)
   ├─ Check components in inventory
   ├─ Deduct components
   ├─ Deduct currency
   ├─ Roll success chance
   │  ├─ Success: Generate item
   │  │   ├─ ItemGenerationService.generate()
   │  │   ├─ Roll quality variance
   │  │   ├─ Roll affixes
   │  │   └─ Create item entity
   │  └─ Failure: Lose some components
   ├─ Grant XP
   └─ Update crafting level
   ↓
4. Database:
   ├─ DELETE components from inventory
   ├─ INSERT new item
   ├─ UPDATE player currency
   ├─ INSERT craft_history
   └─ UPDATE crafting_xp
   ↓
5. Response with result
```

---

## 🔄 CROSS-SYSTEM INTEGRATIONS

### Quest → Combat

**Trigger:** Quest objective "Kill 10 Arasaka guards"

```
Combat System:
  onEnemyKilled(enemy) {
    if (enemy.faction == "arasaka") {
      QuestService.updateObjective(
        quest_id: "active_quest",
        objective: "kill_arasaka",
        progress: +1
      )
    }
  }
```

---

### Combat → Economy

**Trigger:** Enemy killed, loot dropped

```
Combat System:
  onEnemyKilled(enemy) {
    loot = LootService.rollLoot(enemy.loot_table)
    
    Economy System:
      InventoryService.addItems(player, loot.items)
      CurrencyService.addCurrency(player, loot.eurodollars)
      
    Market Impact:
      if (loot.rare_item) {
        MarketService.updateSupply(item_id, +1)
        PricingService.recalculatePrices()
      }
  }
```

---

### Reputation → All Systems

**Reputation Changes Affect:**

```
Reputation Change → Triggered Events:

1. Quest System:
   - Check newly available quests
   - Check locked quests
   - Update quest requirements

2. Economy:
   - Update vendor prices
   - Update market access
   - Update faction currency exchange

3. Social:
   - Update NPC availability
   - Update dialogue options
   - Update faction member attitudes

4. World:
   - Update zone access
   - Update guard behavior
   - Update faction patrols
```

---

### Crafting → Economy

**New Item Crafted:**

```
Crafting System:
  onItemCrafted(item) {
    
    Economy System:
      MarketService.updateSupply(item.type, +1)
      PricingService.recalculate(item.type)
      
      if (item.rarity >= "rare") {
        NotificationService.notify(
          "New rare item crafted on server!"
        )
      }
    
    Guild System (if applicable):
      GuildService.addToProduction(guild, item)
  }
```

---

## 🎯 SERVICE DEPENDENCIES

### Core Services

**QuestService**
- Dependencies: NPCService, ReputationService, InventoryService
- Used By: Frontend, EventService
- Database: quests, quest_progress, dialogues

**CombatService**
- Dependencies: AbilityService, WeaponService, EnemyService
- Used By: QuestService, PvPService
- Database: combat_sessions, damage_logs

**EconomyService**
- Dependencies: ItemService, CurrencyService, MarketService
- Used By: CraftingService, TradingService, QuestService
- Database: currencies, resources, market_listings

**ReputationService**
- Dependencies: FactionService
- Used By: QuestService, TradingService, CombatService
- Database: reputations, reputation_history

**SocialService**
- Dependencies: ReputationService, NPCService
- Used By: QuestService, OrderService
- Database: relationships, hired_npcs, player_orders

---

## 📡 EVENT-DRIVEN ARCHITECTURE

### Event Bus

**Event Types:**

```typescript
enum EventType {
  // Quest Events
  QUEST_STARTED,
  QUEST_COMPLETED,
  QUEST_FAILED,
  OBJECTIVE_UPDATED,
  
  // Combat Events
  DAMAGE_DEALT,
  ENEMY_KILLED,
  PLAYER_DIED,
  ABILITY_USED,
  COMBO_EXECUTED,
  
  // Economy Events
  ITEM_CRAFTED,
  ITEM_SOLD,
  MARKET_PRICE_CHANGED,
  CURRENCY_EXCHANGED,
  
  // Social Events
  REPUTATION_CHANGED,
  NPC_HIRED,
  ORDER_CREATED,
  ORDER_COMPLETED,
  
  // World Events
  ZONE_CAPTURED,
  FACTION_WAR_STARTED,
  WORLD_EVENT_TRIGGERED
}
```

**Event Flow:**

```
Service A emits event
  ↓
Event Bus receives
  ↓
Multiple services subscribe
  ├─ Service B: Update data
  ├─ Service C: Send notification
  └─ Service D: Log analytics
```

---

## 🔄 REAL-TIME UPDATES

### WebSocket Channels

**Player Channel:**
```
ws://api.necpgame.com/ws/player/{player_id}

Messages:
- quest_update
- combat_event
- reputation_change
- inventory_change
- notification
```

**Combat Channel:**
```
ws://api.necpgame.com/ws/combat/{session_id}

Messages:
- damage_event
- ability_used
- player_joined
- player_left
- combat_ended
```

**Market Channel:**
```
ws://api.necpgame.com/ws/market

Messages:
- new_listing
- item_sold
- price_changed
- auction_bid
```

---

## 📊 CACHING STRATEGY

### Cache Layers

**Level 1: Client Cache**
- Static data (items, abilities, quests definitions)
- TTL: 24 hours
- Invalidation: Version change

**Level 2: API Gateway Cache**
- Frequently requested data (player profiles, market listings)
- TTL: 5 minutes
- Invalidation: On write

**Level 3: Service Cache (Redis)**
- Hot data (active combat sessions, auction bids)
- TTL: 30 seconds
- Invalidation: On update

**Level 4: Database Query Cache**
- Complex queries (leaderboards, stats)
- TTL: 1 minute
- Invalidation: On data change

---

## 🔒 DATA CONSISTENCY

### Transaction Boundaries

**Example: Item Purchase**

```sql
BEGIN TRANSACTION;

-- Lock buyer and seller accounts
SELECT * FROM players WHERE id IN (buyer, seller) FOR UPDATE;

-- Check buyer has funds
IF buyer.eurodollars < price THEN ROLLBACK;

-- Check seller has item
IF item.owner_id != seller THEN ROLLBACK;

-- Transfer
UPDATE players SET eurodollars = eurodollars - price WHERE id = buyer;
UPDATE players SET eurodollars = eurodollars + (price * 0.95) WHERE id = seller; -- 5% fee
UPDATE items SET owner_id = buyer WHERE id = item_id;

-- Log
INSERT INTO transaction_history ...;

COMMIT;
```

---

## 🎯 API CALL SEQUENCES

### Sequence: Start Quest with Dialogue Choice

```
Client → API:
1. GET /quests/{quest_id}
   ← Quest details

2. POST /quests/{quest_id}/start
   ← Quest started, first dialogue node

3. GET /dialogues/{node_id}
   ← Dialogue options

4. POST /dialogues/{node_id}/choose (with skill check)
   ← Skill check result, next node or ending

5. If quest complete:
   POST /quests/{quest_id}/complete
   ← Rewards, reputation changes, XP

6. WebSocket notification:
   ← "Quest completed! +50000 XP"
```

---

### Sequence: Craft Legendary Item

```
Client → API:
1. GET /recipes/craft_sandevistan
   ← Recipe details, requirements

2. GET /inventory/{player_id}/components
   ← Check if player has materials

3. POST /production/start
   ← Production started, 48h timer

4. WebSocket (after 48 hours):
   ← "Sandevistan OS crafting complete!"

5. POST /production/complete/{production_id}
   ← Result: Success/Fail, item if success

6. If success:
   GET /implants/{implant_id}
   POST /implants/install
   ← Implant installed, abilities unlocked
```

---

### Sequence: Hire NPC and Assign Task

```
Client → API:
1. GET /npcs/available
   ← List of hireable NPCs

2. GET /npcs/{npc_id}
   ← NPC details, costs, stats

3. POST /npcs/{npc_id}/hire
   ← Contract created, initial payment

4. PUT /npcs/{npc_id}/assign-task
   ← Task assigned (e.g., "guard_shop")

5. Periodic (every hour):
   GET /npcs/hired/{player_id}
   ← NPC status, loyalty, performance

6. On event (NPC completes task):
   WebSocket: "NPC defeated attacker!"
```

---

## ✅ Готовность

- ✅ System architecture defined
- ✅ Data flow diagrams
- ✅ Service dependencies mapped
- ✅ Event-driven design
- ✅ Real-time WebSocket channels
- ✅ Caching strategy
- ✅ Transaction boundaries
- ✅ API call sequences

**Готово для разработки backend!** 🏗️

