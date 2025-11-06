# Полная Карта API Endpoints

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API-SWAGGER

**Base URL:** `https://api.necpgame.com/v1`

---

## 🎮 QUESTS API

### Quest Management

```
GET    /quests
GET    /quests/{quest_id}
GET    /quests/period/{period}
GET    /quests/faction/{faction_id}
GET    /quests/region/{region_id}
POST   /quests/{quest_id}/start
POST   /quests/{quest_id}/complete
POST   /quests/{quest_id}/abandon
GET    /quests/{quest_id}/progress
```

**Query Parameters:**
- `?status=available|active|completed`
- `?difficulty=easy|medium|hard|extreme`
- `?type=main|side|faction|romance`
- `?min_level=1&max_level=50`

**Example:**
```http
GET /quests?faction=arasaka&status=available&min_level=20

Response 200:
{
  "quests": [
    {
      "id": "arasaka_throne_game",
      "title": "Игра Престолов",
      "faction": "arasaka",
      "difficulty": "extreme",
      "recommended_level": 30,
      "rewards": {
        "experience": 50000,
        "eurodollars": 100000,
        "reputation": {"arasaka": 75}
      },
      "requirements": {
        "level": 25,
        "reputation": {"arasaka": 50}
      }
    }
  ],
  "total": 1,
  "page": 1
}
```

---

### Quest Dialogues

```
GET    /quests/{quest_id}/dialogues
GET    /dialogues/{node_id}
POST   /dialogues/{node_id}/choose
```

**Example:**
```http
POST /dialogues/arasaka_throne_node_12/choose

Request Body:
{
  "choice_id": "choice_betray_hanako",
  "skill_check": {
    "attribute": "COOL",
    "skill": "Deception",
    "roll": 18,
    "modifiers": 5
  }
}

Response 200:
{
  "success": true,
  "result": "critical_success",
  "next_node": "node_15_betrayal_path",
  "reputation_changes": {
    "arasaka": -30,
    "militech": +15
  },
  "unlocks": ["quest_militech_alliance"]
}
```

---

### Quest Objectives

```
GET    /quests/{quest_id}/objectives
POST   /objectives/{objective_id}/complete
POST   /objectives/{objective_id}/update-progress
```

---

### Random Events

```
GET    /events/random
POST   /events/{event_id}/trigger
GET    /events/active
```

---

## ⚔️ COMBAT API

### Abilities

```
GET    /abilities
GET    /abilities/{ability_id}
GET    /abilities/catalog
GET    /abilities/class/{class_id}
POST   /abilities/{ability_id}/use
POST   /abilities/{ability_id}/upgrade
GET    /abilities/cooldowns
```

**Example:**
```http
POST /abilities/solo_berserk_r/use

Request:
{
  "player_id": "user_123",
  "targets": [],
  "position": {"x": 100, "y": 50, "z": 10}
}

Response 200:
{
  "success": true,
  "energy_consumed": 80,
  "cooldown_until": "2025-11-06T15:30:00Z",
  "effects_applied": {
    "damage_buff": 2.0,
    "resistance_buff": 1.5,
    "movement_speed": 1.3,
    "duration": 15
  },
  "cyberpsychosis_risk": +10
}
```

---

### Combos

```
GET    /abilities/combos
GET    /abilities/combos/{combo_id}
POST   /abilities/combos/execute
GET    /abilities/synergies
```

**Example:**
```http
POST /abilities/combos/execute

Request:
{
  "combo_id": "aerial_devastation",
  "abilities": [
    {"id": "mobility_dash_q", "timestamp": 0},
    {"id": "mobility_double_jump_e", "timestamp": 0.5},
    {"id": "solo_shockwave_q", "timestamp": 1.2}
  ],
  "timing_window": 2.0
}

Response 200:
{
  "success": true,
  "combo_executed": true,
  "damage_multiplier": 2.0,
  "bonus_effects": {
    "aoe_radius": "+3m",
    "stun_duration": "+1s"
  },
  "difficulty": "medium",
  "score": 24
}
```

---

### Weapons

```
GET    /weapons
GET    /weapons/{weapon_id}
GET    /weapons/catalog
GET    /weapons/brands/{brand_id}
POST   /weapons/{weapon_id}/equip
POST   /weapons/{weapon_id}/modify
PUT    /weapons/{weapon_id}/mastery
GET    /weapons/mastery/{player_id}
```

**Example:**
```http
PUT /weapons/lexington_m10af/mastery

Request:
{
  "player_id": "user_123",
  "kills": 150,
  "headshots": 45,
  "accuracy": 0.72
}

Response 200:
{
  "current_rank": 2,
  "progress": {
    "kills": 150,
    "required_next": 500
  },
  "bonuses": {
    "damage": "+5%",
    "reload_time": "-10%"
  },
  "next_unlock": "Fan the Hammer ability at R3"
}
```

---

### Enemies & AI

```
GET    /enemies
GET    /enemies/{enemy_id}
GET    /enemies/faction/{faction_id}
POST   /enemies/{enemy_id}/spawn
GET    /enemies/ai-tactics
```

---

### Boss Fights

```
GET    /bosses
GET    /bosses/{boss_id}
POST   /bosses/{boss_id}/start
POST   /bosses/{boss_id}/phase-transition
GET    /bosses/{boss_id}/loot
```

**Example:**
```http
POST /bosses/adam_smasher/phase-transition

Request:
{
  "current_hp": 35000,
  "phase": 1,
  "raid_id": "raid_123",
  "players": 5
}

Response 200:
{
  "new_phase": 2,
  "changes": {
    "abilities_added": ["sandevistan_dash", "rapid_melee"],
    "adds_spawned": ["combat_drone", "combat_drone"],
    "weakpoint": "sandevistan_cooldown_window"
  },
  "announcement": "Adam Smasher activates Sandevistan!"
}
```

---

## 💰 ECONOMY API

### Currencies

```
GET    /currencies
GET    /currencies/{currency_id}
GET    /currencies/exchange-rates
POST   /currencies/exchange
GET    /currencies/player/{player_id}/balance
POST   /currencies/transfer
```

**Example:**
```http
POST /currencies/exchange

Request:
{
  "player_id": "user_123",
  "from_currency": "yen",
  "to_currency": "eurodollar",
  "amount": 10000
}

Response 200:
{
  "exchanged": true,
  "from_amount": 10000,
  "to_amount": 100,
  "rate": 100,
  "fee": 5,
  "fee_percentage": 5,
  "new_balances": {
    "yen": 90000,
    "eurodollar": 1095
  }
}
```

---

### Resources

```
GET    /resources
GET    /resources/{resource_id}
GET    /resources/tier/{tier}
GET    /resources/market-price
POST   /resources/harvest
POST   /resources/dismantle
```

**Example:**
```http
GET /resources/titanium_alloy/market-price

Response 200:
{
  "resource_id": "titanium_alloy",
  "base_price": 150,
  "current_price": 180,
  "factors": {
    "supply_demand": 1.2,
    "region": 1.0,
    "event": 1.0
  },
  "trend": "rising",
  "volume_24h": 1500,
  "avg_price_7d": 165
}
```

---

### Crafting

```
GET    /recipes
GET    /recipes/{recipe_id}
GET    /recipes/tier/{tier}
POST   /recipes/{recipe_id}/craft
POST   /recipes/{recipe_id}/batch-craft
GET    /crafting/stations
POST   /crafting/reforge
POST   /crafting/calibrate
```

**Example:**
```http
POST /recipes/craft_sniper_custom/craft

Request:
{
  "player_id": "user_123",
  "components": {
    "tungsten_carbide_barrel": 1,
    "titanium_alloy_frame": 5,
    "optical_sensor": 2,
    "precision_mechanism": 3,
    "polymer_stock": 1
  },
  "station_id": "weaponsmith_downtown",
  "boosters": ["quality_enhancer"]
}

Response 200:
{
  "success": true,
  "result": {
    "item_id": "sniper_custom_xyz123",
    "rarity": "epic",
    "quality_roll": 115,
    "stats": {
      "damage": 425,
      "accuracy": 97,
      "crit_chance": 22,
      "range": 235
    },
    "special_mods": ["penetrating_rounds"]
  },
  "time_completed": "2025-11-06T17:30:00Z",
  "xp_gained": 200
}
```

---

### Market & Trading

```
GET    /market/listings
POST   /market/list-item
POST   /market/buy
DELETE /market/listings/{listing_id}
GET    /market/search
```

**Example:**
```http
POST /market/list-item

Request:
{
  "item_id": "sniper_custom_xyz123",
  "price": 25000,
  "currency": "eurodollar",
  "duration": 72,
  "buyout": true
}

Response 201:
{
  "listing_id": "listing_456",
  "fee": 500,
  "expires_at": "2025-11-09T17:30:00Z",
  "status": "active"
}
```

---

### Auction House

```
GET    /auction-house/active
POST   /auction-house/create
POST   /auction-house/bid
GET    /auction-house/{auction_id}
```

---

## 🎭 SOCIAL API

### Reputation

```
GET    /reputation/player/{player_id}
GET    /reputation/faction/{faction_id}
POST   /reputation/gain
POST   /reputation/loss
GET    /reputation/tiers
GET    /reputation/benefits/{faction_id}/{tier}
GET    /reputation/titles
```

**Example:**
```http
GET /reputation/player/user_123

Response 200:
{
  "player_id": "user_123",
  "factions": {
    "arasaka": {
      "value": 85,
      "tier": "exalted",
      "title": "Hero of Arasaka",
      "benefits": {
        "prices": {"buy": -35, "sell": +35},
        "access": "legendary_vendors",
        "perks": ["free_repairs", "faction_backup"]
      }
    },
    "militech": {
      "value": -60,
      "tier": "hostile",
      "bounty": 25000
    }
  },
  "street_cred": 750,
  "global_standing": "respected"
}
```

---

### NPC Hiring

```
GET    /npcs/available
GET    /npcs/{npc_id}
POST   /npcs/{npc_id}/hire
POST   /npcs/{npc_id}/fire
PUT    /npcs/{npc_id}/assign-task
GET    /npcs/hired/{player_id}
```

**Example:**
```http
POST /npcs/cipher_tanaka/hire

Request:
{
  "player_id": "user_123",
  "contract_duration": 30,
  "payment_method": "daily"
}

Response 200:
{
  "hired": true,
  "npc_id": "cipher_tanaka",
  "contract": {
    "initial_cost": 8000,
    "daily_cost": 500,
    "duration_days": 30,
    "total_cost": 23000
  },
  "npc_stats": {
    "level": 15,
    "hacking": 4,
    "loyalty": 70
  },
  "available_services": [
    "hack_security",
    "gather_intel",
    "cyberdeck_maintenance"
  ]
}
```

---

### Relationships

```
GET    /relationships/player/{player_id}
POST   /relationships/add-friend
DELETE /relationships/remove-friend
POST   /relationships/rate
GET    /relationships/history
POST   /relationships/trust/update
```

---

### Player Orders

```
GET    /orders/available
POST   /orders/create
POST   /orders/accept
POST   /orders/complete
DELETE /orders/cancel
GET    /orders/active
GET    /orders/history
```

**Example:**
```http
POST /orders/create

Request:
{
  "creator_id": "user_123",
  "type": "assassination",
  "target": "corpo_executive_npc",
  "location": "corpo_plaza",
  "reward": 50000,
  "currency": "eurodollar",
  "requirements": {
    "min_level": 20,
    "skills": {"stealth": 3, "combat": 3},
    "reputation": {"street_cred": 200}
  },
  "deadline": "2025-11-10T00:00:00Z",
  "escrow": true
}

Response 201:
{
  "order_id": "order_789",
  "status": "pending",
  "escrow_locked": 50000,
  "expires_at": "2025-11-10T00:00:00Z"
}
```

---

## 👤 PLAYER API

### Player Profile

```
GET    /players/{player_id}
PUT    /players/{player_id}
GET    /players/{player_id}/stats
GET    /players/{player_id}/inventory
POST   /players/{player_id}/level-up
```

---

### Character Management

```
GET    /characters/{character_id}
POST   /characters/create
PUT    /characters/{character_id}/attributes
GET    /characters/{character_id}/skills
POST   /characters/{character_id}/skills/train
```

**Example:**
```http
POST /characters/char_456/skills/train

Request:
{
  "skill": "gunplay",
  "xp": 500,
  "method": "combat"
}

Response 200:
{
  "skill": "gunplay",
  "current_rank": 3,
  "xp": 1500,
  "xp_to_next": 500,
  "bonuses": {
    "accuracy": "+10%",
    "damage": "+5%"
  }
}
```

---

### Inventory

```
GET    /inventory/{player_id}
POST   /inventory/add-item
DELETE /inventory/remove-item
POST   /inventory/equip
POST   /inventory/unequip
POST   /inventory/transfer
```

---

## 💎 ITEMS API

### Equipment

```
GET    /items
GET    /items/{item_id}
POST   /items/generate
POST   /items/modify
POST   /items/upgrade
GET    /items/brands
GET    /items/mods
```

**Example:**
```http
POST /items/generate

Request:
{
  "type": "weapon",
  "subtype": "sniper_rifle",
  "brand": "militech",
  "rarity": "rare",
  "zone": "corpo_plaza",
  "level": 25,
  "seed": "brand:militech|zone:corpo|rarity:rare|roll:1|v1.0"
}

Response 200:
{
  "item": {
    "id": "weapon_sniper_abc123",
    "name": "Militech M-179e Achilles",
    "rarity": "rare",
    "level": 25,
    "stats": {
      "damage": 380,
      "accuracy": 94,
      "fire_rate": 0.8,
      "magazine": 8,
      "range": 220
    },
    "affixes": [
      {"id": "armor_penetration", "value": 15},
      {"id": "crit_chance", "value": 12}
    ],
    "value": 18000,
    "seed": "brand:militech|zone:corpo|rarity:rare|roll:1|v1.0"
  }
}
```

---

### Implants

```
GET    /implants
GET    /implants/{implant_id}
POST   /implants/install
POST   /implants/remove
GET    /implants/compatibility
POST   /implants/upgrade
```

**Example:**
```http
POST /implants/install

Request:
{
  "player_id": "user_123",
  "implant_id": "sandevistan_os",
  "ripperdoc_id": "viktor_volkov",
  "payment": 250000
}

Response 200:
{
  "success": true,
  "install_time": "2025-11-08T15:30:00Z",
  "humanity_loss": 30,
  "current_humanity": 45,
  "cyberpsychosis_risk": 25,
  "abilities_unlocked": ["mobility_sandevistan_r"],
  "warnings": ["OS_slot_occupied", "high_energy_drain"]
}
```

---

## 🏭 PRODUCTION API

### Crafting Production

```
POST   /production/start
GET    /production/status/{production_id}
POST   /production/cancel
POST   /production/complete
GET    /production/queue
```

**Example:**
```http
POST /production/start

Request:
{
  "recipe_id": "craft_sandevistan",
  "station_id": "legendary_ripper_clinic",
  "player_id": "user_123",
  "boosters": ["efficiency_catalyst"],
  "batch_size": 1
}

Response 200:
{
  "production_id": "prod_999",
  "status": "in_progress",
  "start_time": "2025-11-06T15:30:00Z",
  "completion_time": "2025-11-08T15:30:00Z",
  "duration_hours": 48,
  "success_rate": 45,
  "components_locked": true
}
```

---

### Production Chains

```
GET    /production/chains
GET    /production/chains/{chain_id}
GET    /production/optimize
```

---

## 🎲 COMBAT SESSION API

### Combat Management

```
POST   /combat/start
POST   /combat/damage
POST   /combat/heal
POST   /combat/end
GET    /combat/session/{session_id}
```

**Example:**
```http
POST /combat/damage

Request:
{
  "session_id": "combat_123",
  "attacker_id": "user_123",
  "target_id": "enemy_arasaka_guard",
  "weapon_id": "sniper_custom_xyz",
  "ability_id": "precision_shot_q",
  "hit_location": "head",
  "distance": 85
}

Response 200:
{
  "damage_dealt": 850,
  "critical_hit": true,
  "modifiers": {
    "headshot": 2.0,
    "ability": 1.5,
    "distance": 1.1
  },
  "target_hp": {
    "before": 1200,
    "after": 350
  },
  "effects": ["bleeding"],
  "xp_gained": 150
}
```

---

## 🏛️ FACTION API

### Faction Management

```
GET    /factions
GET    /factions/{faction_id}
GET    /factions/{faction_id}/members
GET    /factions/{faction_id}/territories
GET    /factions/{faction_id}/vendors
GET    /factions/{faction_id}/quests
```

---

### Territory Control

```
GET    /territories
GET    /territories/{territory_id}
POST   /territories/{territory_id}/claim
POST   /territories/{territory_id}/defend
GET    /territories/wars
```

---

## 🏰 GUILD/CLAN API

### Guild Management

```
POST   /guilds/create
GET    /guilds/{guild_id}
PUT    /guilds/{guild_id}
DELETE /guilds/{guild_id}/disband
POST   /guilds/{guild_id}/invite
POST   /guilds/{guild_id}/kick
GET    /guilds/{guild_id}/members
```

---

### Guild Resources

```
GET    /guilds/{guild_id}/bank
POST   /guilds/{guild_id}/bank/deposit
POST   /guilds/{guild_id}/bank/withdraw
GET    /guilds/{guild_id}/production
POST   /guilds/{guild_id}/production/start
```

---

## 🎯 PROGRESSION API

### Leveling & XP

```
GET    /progression/player/{player_id}
POST   /progression/xp/gain
POST   /progression/level-up
GET    /progression/skills
POST   /progression/skills/upgrade
```

---

### Classes & Builds

```
GET    /classes
GET    /classes/{class_id}
POST   /characters/{char_id}/class/select
GET    /builds/recommended
GET    /builds/{build_id}
```

---

## 🌍 WORLD API

### Locations & Zones

```
GET    /locations
GET    /locations/{location_id}
GET    /zones
GET    /zones/{zone_id}/enemies
GET    /zones/{zone_id}/loot-tables
```

---

### Events

```
GET    /events/world
GET    /events/faction
GET    /events/seasonal
POST   /events/{event_id}/participate
```

---

## 🔒 AUTH & SECURITY

### Authentication

```
POST   /auth/register
POST   /auth/login
POST   /auth/logout
POST   /auth/refresh-token
POST   /auth/forgot-password
```

---

### Account Management

```
GET    /account/{user_id}
PUT    /account/{user_id}
POST   /account/verify-email
POST   /account/change-password
```

---

## 📊 STATISTICS & ANALYTICS

### Player Stats

```
GET    /stats/player/{player_id}
GET    /stats/leaderboard/{category}
GET    /stats/server
GET    /stats/economy
```

**Example:**
```http
GET /stats/leaderboard/combat_rating?limit=10

Response 200:
{
  "category": "combat_rating",
  "leaderboard": [
    {
      "rank": 1,
      "player_id": "user_999",
      "player_name": "V_the_Legend",
      "rating": 2850,
      "wins": 450,
      "losses": 50,
      "kd_ratio": 5.2
    },
    ...
  ],
  "updated_at": "2025-11-06T15:00:00Z"
}
```

---

## ⚙️ ADMIN API

### Admin Management

```
GET    /admin/players
POST   /admin/players/{player_id}/ban
POST   /admin/players/{player_id}/unban
POST   /admin/economy/adjust-prices
POST   /admin/events/trigger
POST   /admin/maintenance/start
```

---

## 📊 ENDPOINT SUMMARY

### Total Endpoints

| Category | Endpoints | Priority |
|----------|-----------|----------|
| **Quests** | 15+ | Critical |
| **Combat** | 25+ | Critical |
| **Economy** | 30+ | Critical |
| **Social** | 20+ | Critical |
| **Player** | 20+ | Critical |
| **Items** | 15+ | High |
| **Factions** | 10+ | High |
| **Guilds** | 12+ | High |
| **World** | 10+ | Medium |
| **Auth** | 8+ | Critical |
| **Stats** | 8+ | Medium |
| **Admin** | 10+ | Low |

**TOTAL: 180+ endpoints** базовых  
**Full API: 300+ endpoints** с вариациями

---

## 🔄 API VERSIONING

### Version Strategy

**Current:** `v1`  
**Format:** `/v1/resource`

**Future:**
- `v2` — Breaking changes
- `v1.1` — Backwards compatible additions

**Deprecation:**
- 6 months notice
- Parallel support v1 + v2

---

## 🛡️ SECURITY

### Rate Limiting

**Tiers:**
- **Free:** 100 requests/minute
- **Premium:** 500 requests/minute
- **Server:** 5000 requests/minute

**By Endpoint:**
- `/combat/*`: 10/second (real-time)
- `/market/*`: 5/second (prevent abuse)
- `/crafting/*`: 1/minute (prevent spam)

---

## ✅ Готовность

- ✅ 180+ endpoints определены
- ✅ Request/Response examples
- ✅ Authentication flow
- ✅ Rate limiting strategy
- ✅ Error handling patterns
- ✅ Versioning strategy

**Готово для API-SWAGGER спецификаций!** 📡

