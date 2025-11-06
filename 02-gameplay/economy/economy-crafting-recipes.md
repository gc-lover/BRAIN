---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-155: api/v1/economy/crafting-recipes.yaml (2025-11-07 11:12)
- Last Updated: 2025-11-07 00:18
---


# Рецепты Крафта

**Версия:** 2.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API

---

## 🔨 СТРУКТУРА РЕЦЕПТА

```yaml
recipe:
  id: "unique_id"
  name: "Название предмета"
  result_item: "item_id"
  result_quantity: 1
  category: "Weapon|Armor|Implant|Mod|Consumable"
  tier: 1-5
  
  requirements:
    skill: {Crafting: 3, Tech: 5}
    station: "workbench_basic"
    license: "L1_weaponsmith"
    reputation: {Faction: 50}
  
  components:
    - {resource_id: "steel_ingot", quantity: 10}
    - {resource_id: "weapon_parts", quantity: 5}
  
  costs:
    eurodollars: 500
    time: 300s
  
  success_rate: 95%
  quality_variance: ±10%
  
  unlock_source: "default|quest|faction|rare_drop"
```

---

## 🔫 WEAPON RECIPES

### Tier 1: Basic Weapons

#### Recipe #1: "Budget Pistol"

```yaml
id: "craft_pistol_budget"
result: Pistol (Common, Budget Arms brand)
tier: 1

components:
  - Weapon Parts: 15
  - Steel Ingot: 8
  - Circuit Board: 3
  - Spring Mechanism: 5

requirements:
  skill: {Crafting: 1}
  station: "workbench_basic"
  license: None

costs:
  eurodollars: 300
  time: 10 minutes

success_rate: 100%
quality: Common (fixed)

stats_result:
  damage: 35-40
  accuracy: 75-80%
  magazine: 12
```

**Unlock:** Default (all players know)

---

#### Recipe #2: "Militech M-10AF Lexington"

```yaml
id: "craft_lexington"
result: Militech M-10AF Lexington (Uncommon)
tier: 2

components:
  - Titanium Alloy: 3
  - Weapon Parts: 20
  - Processor Chip: 2
  - Militech Blueprint Fragment: 1

requirements:
  skill: {Crafting: 3, Gunplay: 2}
  station: "workbench_advanced"
  license: "L1_gunsmith"

costs:
  eurodollars: 2,500
  time: 30 minutes

success_rate: 90%
quality: Uncommon-Rare (RNG)

stats_result:
  damage: 50-60
  accuracy: 85-92%
  fire_rate: 4/s
```

**Unlock:** Quest "Militech Contracts" or Militech Rep 200

---

### Tier 3: Advanced Weapons

#### Recipe #3: "Custom Sniper Rifle"

```yaml
id: "craft_sniper_custom"
result: Custom Sniper (Rare-Epic)
tier: 3

components:
  - Tungsten Carbide Barrel: 1
  - Titanium Alloy Frame: 5
  - Optical Sensor: 2
  - Precision Mechanism: 3
  - Polymer Stock: 1

requirements:
  skill: {Crafting: 5, Tech: 4}
  station: "weaponsmith_station"
  license: "L2_gunsmith"
  reputation: {Gunsmiths_Guild: 500}

costs:
  eurodollars: 15,000
  time: 2 hours

success_rate: 75%
quality: Rare (70%), Epic (25%), Failed (5%)

stats_result:
  damage: 350-450
  accuracy: 95-98%
  crit_chance: +15-25%
  range: 200-250m
  
  special_chance: 30%
  special_effects:
    - "Penetrating rounds"
    - "Thermal scope"
    - "Stabilized platform"
```

**Unlock:** Rare drop from legendary gunsmiths or faction quest

---

### Tier 5: Legendary Weapons

#### Recipe #4: "Malorian Arms 3516" (Replica)

```yaml
id: "craft_malorian_replica"
result: Malorian Arms 3516 (Legendary replica)
tier: 5

lore: "Реплика легендарного пистолета Джонни Сильверхэнда"

components:
  - Legendary Weapon Frame: 1
  - Incendiary Mechanism: 2
  - Neural Matrix: 1
  - Malorian Blueprint (Quest item): 1
  - Silver Inlay: 3
  - 100,000 €$ (crafting fee)

requirements:
  skill: {Crafting: 10, Gunplay: 8}
  station: "legendary_forge"
  license: "L3_master_gunsmith"
  reputation: {Fixers: 1000, Street_Cred: 800}
  quest: "Silverhand's Legacy" (completed)

costs:
  time: 24 hours (real-time)
  
success_rate: 50%
  on_fail: "Components lost, keep blueprint"

stats_result:
  damage: 140-160
  crit_chance: +25%
  crit_damage: +50%
  special: "Incendiary rounds (fire DoT)"
  unique: "Headshots instant-kill < 30% HP"
```

**Unlock:** Complete quest chain "Silverhand's Legacy"  
**Limit:** Max 1 per player

---

## 🛡️ ARMOR RECIPES

### Tier 2: Reinforced Armor

#### Recipe #5: "Corpo Security Vest"

```yaml
id: "craft_corpo_vest"
result: Security Vest (Uncommon-Rare)
tier: 2

components:
  - Titanium Alloy Plates: 8
  - Kevlar Fabric: 10
  - Armor Plates: 15
  - Ballistic Weave: 5

requirements:
  skill: {Crafting: 3}
  station: "armor_workbench"

costs:
  eurodollars: 3,000
  time: 45 minutes

stats_result:
  armor: 120-160
  resistances: {physical: 15-20%, energy: 5-10%}
  weight: 8-10kg
  mobility_penalty: -10%
```

---

### Tier 4: Elite Armor

#### Recipe #6: "Arasaka Full-Body Suit"

```yaml
id: "craft_arasaka_suit"
result: Arasaka Elite Armor Set (Epic)
tier: 4

components:
  - Arasaka Nano-Weave: 20
  - Carbon Fiber Plates: 15
  - Smart Fabric: 10
  - Arasaka Badge (Quest): 1

requirements:
  skill: {Crafting: 7, Tech: 6}
  station: "corpo_fabricator"
  license: "L2_armorsmith"
  reputation: {Arasaka: 800}

costs:
  eurodollars: 50,000
  time: 8 hours

stats_result:
  armor: 300-350 (full set)
  resistances: {physical: 30%, energy: 25%, hack: 40%}
  set_bonus: "+15% accuracy with Arasaka weapons"
```

---

## 🧠 IMPLANT RECIPES

### Tier 2: Basic Implants

#### Recipe #7: "Cyber-Eyes (Basic)"

```yaml
id: "craft_cyber_eyes_basic"
result: Kiroshi Optics Mk.1 (Uncommon)
tier: 2

components:
  - Optical Sensor: 2
  - Circuit Board: 8
  - Neural Interface: 1
  - Synthetic Blood: 3

requirements:
  skill: {Tech: 4, Medicine: 2}
  station: "ripper_clinic"
  license: "L1_cyberware"

costs:
  eurodollars: 5,000
  time: 1 hour
  installation_fee: 2,000 €$ (ripperdoc)

success_rate: 90%
  on_fail: "Component loss, no injury"

effects:
  - "Zoom 2x"
  - "Target analysis"
  - "Night vision"
  - "Humanity: -5"
```

---

### Tier 4: Advanced Implants

#### Recipe #8: "Sandevistan Operating System"

```yaml
id: "craft_sandevistan"
result: Sandevistan OS (Legendary)
tier: 5

lore: "Легендарная система замедления времени"

components:
  - Neural Matrix: 3
  - Quantum Processor: 1
  - Reflex Booster: 5
  - Militech Neural Chip: 1
  - 200,000 €$ (parts sourcing)

requirements:
  skill: {Tech: 10, Medicine: 8, Crafting: 9}
  station: "advanced_ripper_clinic"
  license: "L3_master_cyberware"
  reputation: {Rippers_Guild: 1500}
  quest: "Time Bender" (completed)

costs:
  time: 48 hours
  installation_fee: 50,000 €$

success_rate: 40%
  on_fail: "50% components lost, 50% downgraded to Rare variant"

effects:
  - "R Ability: Slow time 70% for 10s"
  - "Cooldown: 180s"
  - "+50% damage during slow-mo"
  - "Humanity: -30"
  - "Cyberpsychosis risk: +15"
```

**Unlock:** Quest "Time Bender" + Legendary Ripperdoc access  
**Note:** Only 1 OS implant can be equipped (exclusive with Berserk, Cyberdeck)

---

## 🔧 WEAPON MODS RECIPES

#### Recipe #9: "Silencer (Advanced)"

```yaml
id: "craft_silencer_advanced"
result: Advanced Silencer (Rare)
tier: 3

components:
  - Titanium Tube: 2
  - Sound Dampening Foam: 5
  - Precision Thread: 1

requirements:
  skill: {Crafting: 4}
  station: "mod_workbench"

costs:
  eurodollars: 1,500
  time: 20 minutes

effects:
  - "-15% damage (reduced from -20%)"
  - "Silent shots"
  - "+stealth"
```

---

#### Recipe #10: "Smart Targeting Module"

```yaml
id: "craft_smart_module"
result: Smart Link Module (Epic)
tier: 4

components:
  - Processor Chip: 5
  - Optical Sensor: 3
  - AI Micro-Core: 1
  - Kang Tao License: 1

requirements:
  skill: {Tech: 6, Hacking: 4}
  station: "electronics_lab"
  implant_required: "smart_link_hand"

costs:
  eurodollars: 12,000
  time: 3 hours

effects:
  - "Auto-targeting"
  - "Ammo counter in HUD"
  - "+15% accuracy"
  - "Lock 3 targets"
```

---

## 💊 CONSUMABLES RECIPES

#### Recipe #11: "Combat Stim"

```yaml
id: "craft_combat_stim"
result: Combat Stim (Common)
quantity: 5 stims

components:
  - Synthetic Blood: 2
  - Adrenaline Compound: 3
  - Nano-Boosters: 1

requirements:
  skill: {Medicine: 2}
  station: "med_station"

costs:
  eurodollars: 300
  time: 5 minutes

effects_per_stim:
  - "Heal 150 HP instantly"
  - "+30% damage for 8s"
  - "-20% damage taken for 8s"
```

---

#### Recipe #12: "EMP Grenade"

```yaml
id: "craft_emp_grenade"
result: EMP Grenade (Uncommon)
quantity: 3 grenades

components:
  - EMP Core: 1
  - Explosive Compound: 2
  - Circuit Board: 3
  - Detonator: 1

requirements:
  skill: {Tech: 3}
  station: "explosives_bench"
  license: "explosives_permit"

costs:
  eurodollars: 800
  time: 15 minutes

effects_per_grenade:
  - "8m AoE"
  - "150 EMP damage to cyberware"
  - "Disable implants 8s"
```

---

## 🧬 BIO-MODS & SPECIAL

#### Recipe #13: "Humanity Restoration Therapy"

```yaml
id: "craft_humanity_therapy"
result: Humanity Therapy Package (Rare)
tier: 3

lore: "Восстановление человечности после имплантов"

components:
  - Neuro-Plastics: 5
  - Synthetic Blood: 10
  - Therapy Module: 1
  - Psychiatric Data: 1

requirements:
  skill: {Medicine: 6, EMP: 8}
  station: "medical_facility"
  license: "L2_medtech"

costs:
  eurodollars: 25,000
  time: 6 hours

effects:
  - "Restore +20 Humanity"
  - "Reduce cyberpsychosis symptoms"
  - "Cooldown: 7 days (cannot spam)"
```

**Unlock:** Quest "Path to Humanity" or Medtech Rep 1000

---

## 📊 CRAFTING TIERS & PROGRESSION

### Tier System

**Tier 1 (Lvl 1-10):**
- Basic weapons, armor
- Common materials only
- Workbench basic
- Success rate: 95-100%

**Tier 2 (Lvl 11-20):**
- Uncommon weapons, implants
- Mixed materials
- Advanced workbench
- Success rate: 85-95%

**Tier 3 (Lvl 21-35):**
- Rare equipment, advanced implants
- Rare materials required
- Specialized stations
- Success rate: 70-85%

**Tier 4 (Lvl 36-50):**
- Epic gear, OS implants
- Epic+ materials
- Master stations
- Success rate: 50-75%

**Tier 5 (Lvl 51+):**
- Legendary items
- Artifact materials
- Legendary forges
- Success rate: 25-50%
- **High risk, high reward**

---

## 🏭 PRODUCTION STATIONS

### Station Types

**1. Basic Workbench**
- Cost: 5,000 €$
- Location: Player apartment
- Can craft: T1 items
- Upgrade to Advanced: 20,000 €$

**2. Advanced Workbench**
- Craft: T1-T2
- Faster production (-20% time)
- Higher success rates (+5%)

**3. Specialized Stations**

**Weaponsmith Station:**
- Craft: Weapons T1-T4
- Special: Weapon-only bonuses
- Cost: 50,000 €$

**Ripper Clinic (Portable):**
- Craft: Implants T1-T3
- Requires: Medicine skill
- Cost: 80,000 €$ + License

**Electronics Lab:**
- Craft: Cyberdecks, mods, smart systems
- Requires: Tech + Hacking skills
- Cost: 60,000 €$

**Legendary Forge:**
- Craft: T5 items
- Location: Faction HQ only (cannot own)
- Access: Reputation + quest

---

## 🔄 CRAFTING MECHANICS

### Quality Variance

**Base Recipe → Result:**
- ±10% stat variance (RNG)
- Higher skill → tighter variance
- Master crafter (Skill 10): ±5% only

**Example:**
```
Recipe: Damage 100
Novice craft: 90-110 damage
Master craft: 95-105 damage
```

### Critical Success

**Chance:** (Crafting Skill × 2)%  
**Effect:** +1 rarity tier OR +special mod

**Example:**
- Crafting Rare item
- Critical success (10% chance at Skill 5)
- Result: Epic quality!

### Critical Failure

**Chance:** (10 - Crafting Skill)%  
**Effect:** Component loss OR quality downgrade

**Protection:**
- Insurance: Pay 20% recipe cost → Refund 50% components on fail
- Master License: Reduces fail chance by 50%

---

## 📈 CRAFTING LEVELING

### XP System

**Gain XP:**
- Craft T1: 10 XP
- Craft T2: 50 XP
- Craft T3: 200 XP
- Craft T4: 800 XP
- Craft T5: 3,000 XP

**Levels:**
- Level 1→2: 100 XP
- Level 2→3: 500 XP
- Level 3→4: 2,000 XP
- Level 4→5: 8,000 XP
- Level 5→10: Exponential scaling

**Bonuses per Level:**
- +2% success rate
- -5% material cost
- -10% time
- Unlock higher tier recipes

---

## 🎯 RECIPE ACQUISITION

### How to Learn Recipes

**1. Default (Free):**
- Basic weapons (T1)
- Basic armor (T1)
- Simple consumables

**2. Skill Level:**
- Auto-unlock at Crafting milestones
- Crafting 3: T2 recipes
- Crafting 5: T3 recipes
- Crafting 8: T4 recipes
- Crafting 10: T5 recipes

**3. Quest Rewards:**
- Malorian replica: Quest chain
- Legendary implants: Faction quests
- Unique mods: Special missions

**4. Loot Drops:**
- Rare drops from bosses (5-15%)
- Encrypted data shards (decrypt for recipe)
- Corporate R&D hack (steal blueprints)

**5. Purchase:**
- Vendors: Common-Rare recipes (1k-50k €$)
- Faction vendors: Exclusive recipes
- Black market: Illegal recipes (stolen corpo blueprints)

**6. Hacking:**
- Corporate databases: Blueprint theft
- Competitor analysis: Reverse-engineer
- Industrial espionage quests

---

## ⚙️ ADVANCED CRAFTING

### Modification & Reforge

**Reforge System:**
- Cost: 50% original craft cost
- Reroll affixes on item
- Keep base item
- Risk: 10% destroy item

**Upgrade System:**
- Upgrade rarity: Common → Uncommon
- Cost: Original recipe + upgrade materials
- Success rate: 60%
- Cannot upgrade Legendary (already max)

**Calibration:**
- Fine-tune stats (±5%)
- Cost: 10% recipe cost
- No fail chance
- Limit: 3 times per item

---

## 💼 MASS PRODUCTION

### Batch Crafting

**Requirements:**
- Crafting Skill 6+
- Production Facility (player-owned or rented)
- Bulk materials

**Benefits:**
- Craft 10x items simultaneously
- -30% time per item (efficiency)
- -20% material cost (bulk discount)

**Usage:**
- Supply guild/clan
- Trade на auction house
- Fulfill contracts

---

## ✅ Готовность

- ✅ 13 конкретных рецептов созданы
- ✅ Tier 1-5 progression defined
- ✅ Station system детализирована
- ✅ Quality variance mechanics
- ✅ Recipe acquisition methods
- ✅ Advanced systems (reforge, batch)

**Для API готово! Можно создавать endpoints!** 🔨

