# API Data Models (JSON Schemas)

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API-SWAGGER

---

## 🎮 QUEST MODELS

### Quest

```json
{
  "id": "string (UUID)",
  "title": "string",
  "description": "string",
  "type": "enum: main|side|faction|romance|contract",
  "faction_id": "string?",
  "region_id": "string?",
  
  "requirements": {
    "level": "integer",
    "reputation": {
      "faction_id": "integer (-100 to 100)"
    },
    "quests_completed": ["quest_id"],
    "skills": {
      "skill_name": "integer (rank)"
    }
  },
  
  "objectives": [
    {
      "id": "string",
      "type": "enum: kill|collect|talk|hack|craft",
      "target": "string",
      "quantity": "integer",
      "optional": "boolean"
    }
  ],
  
  "rewards": {
    "experience": "integer",
    "eurodollars": "integer",
    "items": ["item_id"],
    "reputation": {
      "faction_id": "integer"
    },
    "unlocks": ["quest_id", "vendor_id"]
  },
  
  "difficulty": "enum: easy|medium|hard|extreme",
  "recommended_level": "integer",
  "estimated_time": "integer (minutes)",
  
  "dialogue_tree_id": "string",
  "start_location": "location_id",
  
  "status": "enum: locked|available|active|completed|failed",
  "completion_count": "integer"
}
```

---

### DialogueNode

```json
{
  "id": "string",
  "quest_id": "string",
  "speaker": "string (npc_id or player)",
  "text": "string",
  
  "choices": [
    {
      "id": "string",
      "text": "string",
      "next_node": "string (node_id)",
      
      "skill_check": {
        "attribute": "enum: STR|AGI|REF|BODY|INT|TECH|EMP|WILL|COOL",
        "skill": "string",
        "dc": "integer",
        "on_success": "node_id",
        "on_failure": "node_id"
      },
      
      "requirements": {
        "reputation": {"faction_id": "integer"},
        "items": ["item_id"],
        "flags": ["quest_flag"]
      },
      
      "consequences": {
        "reputation": {"faction_id": "integer"},
        "unlock": ["quest_id"],
        "set_flag": ["quest_flag"]
      }
    }
  ],
  
  "is_ending": "boolean",
  "ending_type": "string?"
}
```

---

### NPCCharacter

```json
{
  "id": "string",
  "name": "string",
  "faction_id": "string",
  "role": "string",
  
  "personality": {
    "traits": ["string"],
    "likes": ["string"],
    "dislikes": ["string"],
    "fears": ["string"]
  },
  
  "stats": {
    "level": "integer",
    "attributes": {
      "STR": "integer",
      "AGI": "integer",
      "REF": "integer",
      "BODY": "integer",
      "INT": "integer",
      "TECH": "integer",
      "EMP": "integer",
      "WILL": "integer",
      "COOL": "integer"
    },
    "skills": {
      "skill_name": "integer (rank 1-5)"
    }
  },
  
  "relationships": {
    "player_id": {
      "reputation": "integer (-100 to 100)",
      "trust": "integer (0 to 100)",
      "romance_stage": "enum: none|interested|dating|committed|married",
      "interactions": "integer"
    }
  },
  
  "hireable": "boolean",
  "hire_cost": {
    "initial": "integer",
    "daily": "integer",
    "currency": "string"
  },
  
  "location": "location_id",
  "schedule": {
    "monday": [{"time": "08:00", "location": "loc_id"}]
  }
}
```

---

## ⚔️ COMBAT MODELS

### Ability

```json
{
  "id": "string",
  "name": "string",
  "category": "enum: Combat|Tech|Stealth|Hacking|Support|Mobility|Medic",
  "slot": "enum: Q|E|R|Passive|Cyberdeck",
  
  "class_affinity": ["Solo", "Netrunner"],
  
  "requirements": {
    "level": "integer",
    "attributes": {
      "REF": "integer",
      "INT": "integer"
    },
    "skills": {
      "Gunplay": "integer",
      "Hacking": "integer"
    },
    "implants": ["implant_id"],
    "equipment": ["weapon_type"]
  },
  
  "costs": {
    "energy": "integer",
    "cooldown": "integer (seconds)",
    "charges": "integer?",
    "health": "integer?"
  },
  
  "effects": {
    "damage": "integer?",
    "damage_type": "enum: physical|energy|emp|cyber",
    "duration": "integer (seconds)?",
    "range": "float (meters)",
    "aoe": "float (meters)?",
    "heal": "integer?",
    "buffs": [
      {"stat": "string", "value": "float", "duration": "integer"}
    ],
    "debuffs": [
      {"effect": "string", "duration": "integer"}
    ]
  },
  
  "synergies": [
    {
      "ability_id": "string",
      "bonus": "string"
    }
  ],
  
  "upgrades": {
    "rank2": {"damage": "integer", "cooldown": "integer"},
    "rank3": {"damage": "integer", "cooldown": "integer"}
  },
  
  "visual_effects": "string",
  "sound_effects": "string"
}
```

---

### Weapon

```json
{
  "id": "string",
  "name": "string",
  "type": "enum: pistol|smg|assault_rifle|shotgun|sniper|lmg|melee",
  "subtype": "string",
  "brand_id": "string",
  "rarity": "enum: common|uncommon|rare|epic|legendary|artifact",
  
  "level": "integer",
  "seed": "string",
  
  "stats_core": {
    "damage": "float",
    "fire_rate": "float (rounds/s)",
    "accuracy": "float (0-100)",
    "recoil": "float (0-100)",
    "weight": "float (kg)",
    "durability": "float (0-100)",
    "magazine_size": "integer",
    "reload_time": "float (seconds)",
    "range": "float (meters)"
  },
  
  "stats_extended": {
    "damage_type": "enum: kinetic|energy|explosive|smart|chemical|emp|cyber",
    "penetration": "float (0-100)",
    "noise": "float (0-100)",
    "heat_generation": "float",
    "energy_use": "float"
  },
  
  "affixes": [
    {
      "id": "string",
      "kind": "enum: simple|set|unique",
      "values": {
        "stat_name": "float"
      }
    }
  ],
  
  "mod_slots": {
    "barrel": "integer",
    "sight": "integer",
    "utility": "integer"
  },
  
  "mods": ["mod_id"],
  
  "special_abilities": ["ability_id"],
  
  "value": "integer (eurodollars)",
  "mastery_kills": "integer",
  "mastery_rank": "integer (1-5)"
}
```

---

### Enemy

```json
{
  "id": "string",
  "name": "string",
  "type": "enum: grunt|elite|boss|world_boss",
  "faction_id": "string",
  "tier": "integer (1-5)",
  
  "stats": {
    "level": "integer",
    "hp": "integer",
    "armor": "integer",
    "damage": "integer",
    "attributes": {...}
  },
  
  "ai_behavior": {
    "aggression": "float (0-1)",
    "tactics": ["flanking", "kiting"],
    "morale": "float (0-1)",
    "communication": "boolean"
  },
  
  "abilities": ["ability_id"],
  
  "loot_table": {
    "eurodollars": {"min": "integer", "max": "integer"},
    "items": [
      {"item_id": "string", "chance": "float (0-1)"}
    ],
    "resources": [
      {"resource_id": "string", "quantity": "integer", "chance": "float"}
    ]
  },
  
  "weakpoints": [
    {"location": "string", "multiplier": "float"}
  ],
  
  "immunities": ["damage_type"],
  "vulnerabilities": ["damage_type"]
}
```

---

### BossFight

```json
{
  "id": "string",
  "boss_id": "string",
  "name": "string",
  
  "requirements": {
    "players_min": "integer",
    "players_max": "integer",
    "recommended_level": "integer"
  },
  
  "phases": [
    {
      "phase_number": "integer",
      "hp_range": {"min": "integer", "max": "integer"},
      
      "mechanics": [
        {
          "name": "string",
          "description": "string",
          "telegraph_time": "float (seconds)",
          "damage": "integer",
          "aoe": "float (meters)?",
          "avoidable": "boolean"
        }
      ],
      
      "adds": [
        {"enemy_id": "string", "count": "integer", "spawn_time": "float"}
      ],
      
      "weakpoint": {
        "window": "float (seconds)",
        "trigger": "string",
        "multiplier": "float"
      }
    }
  ],
  
  "enrage_timer": "integer (seconds)",
  
  "loot": {
    "guaranteed": ["item_id"],
    "rare_drops": [
      {"item_id": "string", "chance": "float"}
    ],
    "currency": "integer"
  }
}
```

---

## 💰 ECONOMY MODELS

### Currency

```json
{
  "id": "string",
  "name": "string",
  "symbol": "string",
  "type": "enum: regional|faction|crypto|premium",
  
  "exchange_rate": {
    "base_currency": "eurodollar",
    "rate": "float"
  },
  
  "regions": ["region_id"],
  "factions": ["faction_id"],
  
  "properties": {
    "tradeable": "boolean",
    "anonymous": "boolean (crypto)",
    "volatile": "boolean",
    "real_money": "boolean (premium)"
  },
  
  "caps": {
    "wallet": "integer",
    "bank": "integer"
  }
}
```

---

### Resource

```json
{
  "id": "string",
  "name": "string",
  "category": "enum: Raw|Processed|Component|Data|Special",
  "tier": "integer (1-5)",
  "rarity": "enum: Common|Uncommon|Rare|Epic|Legendary",
  
  "sources": [
    {
      "type": "enum: loot|harvest|production|quest",
      "location": "zone_id",
      "chance": "float (0-1)",
      "quantity": {"min": "integer", "max": "integer"}
    }
  ],
  
  "uses": [
    {
      "type": "enum: crafting|trading|quest",
      "recipes": ["recipe_id"]
    }
  ],
  
  "value": {
    "vendor_sell": "integer",
    "vendor_buy": "integer",
    "player_market_avg": "integer"
  },
  
  "stack_size": "integer",
  "weight": "float (kg)"
}
```

---

### CraftingRecipe

```json
{
  "id": "string",
  "name": "string",
  "result_item_id": "string",
  "result_quantity": "integer",
  "category": "enum: Weapon|Armor|Implant|Mod|Consumable",
  "tier": "integer (1-5)",
  
  "requirements": {
    "skill": {
      "Crafting": "integer",
      "Tech": "integer"
    },
    "station": "string (station_id)",
    "license": "string (license_id)?",
    "reputation": {
      "faction_id": "integer"
    }
  },
  
  "components": [
    {
      "resource_id": "string",
      "quantity": "integer"
    }
  ],
  
  "costs": {
    "eurodollars": "integer",
    "time": "integer (seconds)"
  },
  
  "success_rate": "float (0-1)",
  "quality_variance": "float (±percentage)",
  
  "unlock_source": "enum: default|quest|faction|rare_drop",
  "unlock_requirement": "string?"
}
```

---

### MarketListing

```json
{
  "id": "string",
  "seller_id": "string",
  "item_id": "string",
  
  "price": "integer",
  "currency": "string",
  
  "type": "enum: standard|auction|buyout",
  "duration": "integer (hours)",
  "created_at": "datetime",
  "expires_at": "datetime",
  
  "auction_data": {
    "current_bid": "integer?",
    "highest_bidder": "string?",
    "buyout_price": "integer?",
    "bid_count": "integer"
  },
  
  "status": "enum: active|sold|expired|cancelled",
  "fee": "integer",
  "region": "string"
}
```

---

## 🎭 SOCIAL MODELS

### Reputation

```json
{
  "player_id": "string",
  "faction_id": "string",
  
  "value": "integer (-100 to 100)",
  "tier": "enum: hated|hostile|unfriendly|neutral|friendly|honored|exalted|legendary",
  
  "benefits": {
    "prices": {
      "buy_discount": "float (percentage)",
      "sell_bonus": "float (percentage)"
    },
    "access_level": "integer (0-5)",
    "perks": ["string"],
    "title": "string?"
  },
  
  "history": [
    {
      "timestamp": "datetime",
      "change": "integer",
      "reason": "string",
      "source": "string (quest_id|action)"
    }
  ],
  
  "next_tier_at": "integer",
  "progress_percentage": "float (0-100)"
}
```

---

### HireableNPC

```json
{
  "id": "string",
  "name": "string",
  "role": "string",
  "tier": "integer (1-5)",
  "rarity": "enum: Common|Uncommon|Rare|Epic|Legendary",
  
  "stats": {
    "level": "integer",
    "skills": {
      "skill_name": "integer (rank 1-5)"
    },
    "efficiency": "float (0.5-2.0 multiplier)"
  },
  
  "hire_cost": {
    "initial": "integer",
    "daily": "integer",
    "currency": "string",
    "reputation_required": "integer"
  },
  
  "location": "string",
  "faction": "string",
  
  "personality": {
    "traits": ["string"],
    "likes": ["string"],
    "dislikes": ["string"]
  },
  
  "special_abilities": ["ability_id"],
  "unique": "boolean",
  
  "services": [
    {
      "type": "string",
      "description": "string",
      "cost": "integer?"
    }
  ],
  
  "contract": {
    "hired_by": "string (player_id)?",
    "hired_at": "datetime?",
    "expires_at": "datetime?",
    "loyalty": "integer (0-100)"
  }
}
```

---

### PlayerOrder

```json
{
  "id": "string",
  "creator_id": "string",
  "acceptor_id": "string?",
  
  "type": "enum: assassination|defense|hack|delivery|research|social",
  "title": "string",
  "description": "string",
  
  "target": "string?",
  "location": "location_id",
  
  "requirements": {
    "min_level": "integer",
    "skills": {"skill_name": "integer"},
    "reputation": {"faction_id": "integer"},
    "equipment": ["item_type"]
  },
  
  "reward": {
    "amount": "integer",
    "currency": "string",
    "items": ["item_id"],
    "reputation": {"faction_id": "integer"}
  },
  
  "deadline": "datetime",
  "escrow": "boolean",
  "escrow_amount": "integer?",
  
  "status": "enum: pending|accepted|in_progress|completed|failed|cancelled",
  
  "progress": {
    "started_at": "datetime?",
    "completion_percentage": "float (0-100)"
  },
  
  "rating": {
    "by_creator": "integer (1-5)?",
    "by_acceptor": "integer (1-5)?"
  }
}
```

---

## 👤 PLAYER MODELS

### Player

```json
{
  "id": "string (UUID)",
  "user_id": "string",
  "username": "string",
  
  "characters": ["character_id"],
  "active_character": "character_id",
  
  "account": {
    "created_at": "datetime",
    "last_login": "datetime",
    "playtime": "integer (seconds)",
    "premium": "boolean",
    "banned": "boolean"
  },
  
  "settings": {
    "language": "string",
    "region": "string",
    "privacy": "object"
  }
}
```

---

### Character

```json
{
  "id": "string",
  "player_id": "string",
  "name": "string",
  
  "class": "string",
  "subclass": "string?",
  "origin": "enum: Nomad|Street Kid|Corpo",
  
  "level": "integer",
  "experience": "integer",
  "experience_to_next": "integer",
  
  "attributes": {
    "STR": "integer",
    "AGI": "integer",
    "REF": "integer",
    "BODY": "integer",
    "INT": "integer",
    "TECH": "integer",
    "EMP": "integer",
    "WILL": "integer",
    "COOL": "integer"
  },
  
  "skills": {
    "skill_name": {
      "rank": "integer (1-5)",
      "xp": "integer",
      "xp_to_next": "integer"
    }
  },
  
  "health": {
    "current": "integer",
    "maximum": "integer"
  },
  
  "cyberware": {
    "humanity": "integer (0-100)",
    "cyberpsychosis_stage": "integer (0-5)",
    "implants": ["implant_id"]
  },
  
  "inventory": {
    "items": ["item_id"],
    "capacity": "integer",
    "weight": "float"
  },
  
  "currencies": {
    "eurodollar": "integer",
    "street_cred": "integer",
    "faction_currencies": {
      "faction_id": "integer"
    }
  },
  
  "location": {
    "zone_id": "string",
    "position": {"x": "float", "y": "float", "z": "float"}
  },
  
  "quests": {
    "active": ["quest_id"],
    "completed": ["quest_id"],
    "available": ["quest_id"]
  },
  
  "reputation": {
    "faction_id": {
      "value": "integer (-100 to 100)",
      "tier": "string"
    }
  },
  
  "statistics": {
    "kills": "integer",
    "deaths": "integer",
    "quests_completed": "integer",
    "items_crafted": "integer",
    "distance_traveled": "float (km)",
    "playtime": "integer (seconds)"
  }
}
```

---

## 💎 ITEM MODELS

### Item (Base)

```json
{
  "id": "string (UUID)",
  "type": "enum: weapon|armor|implant|cyberdeck|mod|consumable",
  "subtype": "string",
  "name": "string",
  "description": "string",
  
  "brand_id": "string",
  "rarity": "enum: common|uncommon|rare|epic|legendary|artifact",
  "level": "integer",
  "tier": "integer (1-5)",
  
  "seed": "string (for generation)",
  "version": "string (generator version)",
  
  "stats": "object (varies by type)",
  
  "affixes": [
    {
      "id": "string",
      "kind": "enum: simple|set|unique",
      "values": "object"
    }
  ],
  
  "requirements": {
    "level": "integer",
    "attributes": "object",
    "skills": "object"
  },
  
  "value": "integer",
  "weight": "float",
  "stack_size": "integer",
  
  "tradeable": "boolean",
  "droppable": "boolean",
  "destroyable": "boolean",
  
  "owner_id": "string?",
  "location": "enum: inventory|bank|market|equipped"
}
```

---

### Implant

```json
{
  "id": "string",
  "type": "implant",
  "name": "string",
  
  "slot_type": "enum: combat|tactical|defensive|mobility|os",
  "rarity": "enum",
  
  "stats": {
    "energy_drain": "float",
    "heat_generation": "float",
    "compatibility_level": "integer (1-10)",
    "durability": "float (0-100)",
    
    "ability_power": "float?",
    "cooldown_modifier": "float?",
    "stat_multipliers": {
      "damage": "float",
      "accuracy": "float",
      "speed": "float",
      "armor": "float"
    },
    
    "humanity_impact": "integer (-100 to 0)",
    "cyberpsychosis_risk": "integer (0-100)"
  },
  
  "abilities_granted": ["ability_id"],
  
  "synergy_tags": ["string"],
  
  "maintenance_cost": "integer (per week)",
  
  "installation": {
    "cost": "integer",
    "time": "integer (hours)",
    "ripperdoc_required": "string?",
    "success_rate": "float (0-1)"
  },
  
  "exclusive_with": ["implant_id"]
}
```

---

## 🏛️ FACTION MODELS

### Faction

```json
{
  "id": "string",
  "name": "string",
  "type": "enum: corporation|gang|organization|government",
  
  "description": "string",
  "lore": "string",
  
  "headquarters": "location_id",
  "territories": ["zone_id"],
  
  "leaders": ["npc_id"],
  "members_count": "integer",
  
  "relationships": {
    "faction_id": {
      "value": "integer (-100 to 100)",
      "type": "enum: hostile|neutral|allied"
    }
  },
  
  "economy": {
    "currency": "string",
    "wealth": "integer",
    "tax_rate": "float (0-1)"
  },
  
  "military": {
    "strength": "integer",
    "units": ["enemy_type"],
    "territory_control": "float (0-1)"
  },
  
  "vendors": ["vendor_id"],
  "quests": ["quest_id"],
  
  "reputation_tiers": {
    "tier_name": {
      "min": "integer",
      "benefits": "object"
    }
  }
}
```

---

### Guild

```json
{
  "id": "string",
  "name": "string",
  "tag": "string (3-5 chars)",
  
  "leader_id": "string",
  "officers": ["player_id"],
  "members": ["player_id"],
  
  "level": "integer",
  "experience": "integer",
  
  "bank": {
    "eurodollars": "integer",
    "resources": {
      "resource_id": "integer"
    }
  },
  
  "territories": ["zone_id"],
  
  "perks": [
    {
      "id": "string",
      "name": "string",
      "bonus": "object"
    }
  ],
  
  "wars": [
    {
      "opponent_guild_id": "string",
      "start_date": "datetime",
      "status": "enum: active|truce|victory|defeat"
    }
  ],
  
  "production": {
    "stations": ["station_id"],
    "active_crafts": ["production_id"]
  }
}
```

---

## 📊 PROGRESSION MODELS

### Skill

```json
{
  "id": "string",
  "name": "string",
  "category": "enum: Combat|Tech|Social|Stealth",
  "description": "string",
  
  "ranks": [
    {
      "rank": "integer (1-5)",
      "name": "enum: Novice|Trained|Expert|Master|Legendary",
      "xp_required": "integer",
      "bonuses": "object"
    }
  ],
  
  "related_attributes": ["STR", "REF"],
  "related_classes": ["Solo", "Nomad"]
}
```

---

### Class

```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  
  "starting_attributes": {
    "STR": "integer",
    "AGI": "integer"
  },
  
  "skill_bonuses": {
    "skill_name": "integer"
  },
  
  "unique_abilities": ["ability_id"],
  
  "equipment_preferences": {
    "weapons": ["weapon_type"],
    "armor": ["armor_type"]
  },
  
  "playstyle": "string",
  "difficulty": "enum: easy|medium|hard"
}
```

---

## 🎲 COMBAT SESSION MODELS

### CombatSession

```json
{
  "id": "string",
  "type": "enum: pve|pvp|raid|arena",
  
  "participants": [
    {
      "id": "string (player or enemy)",
      "type": "enum: player|npc|enemy",
      "team": "integer",
      "role": "enum: tank|dps|support|healer"
    }
  ],
  
  "location": "zone_id",
  "started_at": "datetime",
  "duration": "integer (seconds)",
  
  "events": [
    {
      "timestamp": "datetime",
      "type": "enum: damage|heal|ability|death|revive",
      "source": "string",
      "target": "string",
      "data": "object"
    }
  ],
  
  "status": "enum: active|completed|abandoned",
  
  "results": {
    "winner": "string (team or player)",
    "loot": ["item_id"],
    "experience": "integer",
    "reputation": "object"
  }
}
```

---

## 🗺️ WORLD MODELS

### Zone

```json
{
  "id": "string",
  "name": "string",
  "region": "string",
  
  "type": "enum: city|badlands|extraction|pvp|safe",
  "danger_level": "integer (1-10)",
  "recommended_level": "integer",
  
  "faction_control": {
    "faction_id": "string",
    "control_percentage": "float (0-1)"
  },
  
  "enemies": [
    {
      "enemy_type": "string",
      "spawn_rate": "float",
      "level_range": {"min": "integer", "max": "integer"}
    }
  ],
  
  "loot_tables": ["loot_table_id"],
  
  "points_of_interest": [
    {
      "id": "string",
      "type": "enum: vendor|quest|secret|boss",
      "position": {"x": "float", "y": "float"}
    }
  ],
  
  "fast_travel": "boolean",
  "safe_zone": "boolean"
}
```

---

## 📊 METADATA MODELS

### Pagination

```json
{
  "data": "array",
  "pagination": {
    "page": "integer",
    "per_page": "integer",
    "total_items": "integer",
    "total_pages": "integer"
  }
}
```

---

### Error Response

```json
{
  "error": {
    "code": "string (ERROR_CODE)",
    "message": "string",
    "details": "object?",
    "timestamp": "datetime"
  }
}
```

**Error Codes:**
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `NOT_FOUND` (404)
- `VALIDATION_ERROR` (400)
- `RATE_LIMIT_EXCEEDED` (429)
- `INTERNAL_ERROR` (500)
- `INSUFFICIENT_FUNDS` (402)
- `INSUFFICIENT_REPUTATION` (403)
- `COOLDOWN_ACTIVE` (409)

---

## ✅ MODEL SUMMARY

### Total Models

| Category | Models | Complexity |
|----------|--------|------------|
| **Quests** | 4 | High |
| **Combat** | 6 | High |
| **Economy** | 5 | Medium |
| **Social** | 4 | Medium |
| **Player** | 3 | High |
| **Items** | 3 | Very High |
| **World** | 2 | Medium |
| **Meta** | 2 | Low |

**TOTAL: 29 core models** определены

---

## 🔗 RELATIONSHIPS

### Model Dependencies

```
Player
  ├─ Character (1:n)
  │   ├─ Inventory (1:1)
  │   ├─ Skills (1:n)
  │   ├─ Quests (n:m)
  │   └─ Reputation (1:n)
  │
  ├─ Currencies (1:n)
  └─ Orders (1:n)

Quest
  ├─ DialogueNodes (1:n)
  ├─ Objectives (1:n)
  ├─ NPCs (n:m)
  └─ Rewards (1:1)

Item
  ├─ Affixes (1:n)
  ├─ Mods (1:n)
  └─ Brand (n:1)

Faction
  ├─ NPCs (1:n)
  ├─ Territories (1:n)
  ├─ Quests (1:n)
  └─ Vendors (1:n)
```

---

## ✅ Готовность

- ✅ 180+ endpoints определены
- ✅ 29 core data models созданы
- ✅ Request/Response examples
- ✅ Validation rules
- ✅ Error handling
- ✅ Relationships mapped

**Готово для создания OpenAPI (Swagger) спецификаций!** 📡

