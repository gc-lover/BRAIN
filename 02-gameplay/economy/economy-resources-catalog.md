# Каталог Ресурсов и Материалов

**Версия:** 2.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-096: api/v1/gameplay/economy/resources-catalog.yaml (2025-11-07)
- Last Updated: 2025-11-07 04:30
---

---

## 📦 СТРУКТУРА РЕСУРСА

```yaml
resource:
  id: "unique_id"
  name: "Название"
  category: "Raw|Processed|Component|Data|Special"
  tier: 1-5
  rarity: "Common|Uncommon|Rare|Epic|Legendary"
  
  sources:
    - type: "loot|harvest|production|quest"
      location: "zone_id"
      chance: 0.15
  
  uses:
    - type: "crafting|trading|quest"
      recipes: ["recipe_ids"]
  
  value:
    vendor_sell: 100
    vendor_buy: 150
    player_market: 120-180
  
  stack_size: 999
  weight: 0.1kg
```

---

## ⛏️ RAW MATERIALS (Сырьё)

### Tier 1: Basic Metals

#### 1. **Scrap Metal** (Металлолом)

**Rarity:** Common  
**Sources:**
- Loot: Scavengers (60%), destroyed robots (80%)
- Harvest: Junkyards, abandoned buildings
- Dismantle: Common weapons/armor

**Uses:**
- Craft: Basic weapons, armor plates
- Trading: Bulk commodity

**Value:**
- Vendor Sell: 2 €$
- Vendor Buy: 5 €$
- Player Market: 3-4 €$

**Stack:** 999  
**Weight:** 0.5kg per unit

---

#### 2. **Steel Ingot** (Стальной слиток)

**Rarity:** Common  
**Tier:** 1

**Production:**
- Smelt: 10x Scrap Metal + 5x Carbon → 1x Steel Ingot
- Time: 30 seconds
- Station: Basic Forge

**Uses:**
- Weapon frames
- Armor plates
- Building materials

**Value:** 20 €$ (vendor sell)

---

### Tier 2: Advanced Metals

#### 3. **Titanium Alloy** (Титановый сплав)

**Rarity:** Uncommon  
**Tier:** 2

**Sources:**
- Loot: Corpo Guards (15%), Mechs (40%)
- Extraction zones: Industrial sectors
- Dismantle: Uncommon+ armor

**Production:**
- 5x Steel Ingot + 3x Titanium Ore + 1x Catalyst → 1x Titanium Alloy
- Time: 2 minutes
- Station: Advanced Forge

**Uses:**
- High-tier armor
- Weapon barrels
- Implant housings

**Value:** 150 €$

---

#### 4. **Tungsten Carbide** (Карбид вольфрама)

**Rarity:** Rare  
**Tier:** 3

**Sources:**
- Loot: MaxTac (5%), Heavy Mechs (25%)
- Extraction: Militech facilities
- Quest rewards

**Uses:**
- Armor-piercing rounds
- Reinforced implants
- Heavy weapons

**Value:** 800 €$

---

## 🔬 ELECTRONIC COMPONENTS

### Tier 1: Basic

#### 5. **Circuit Board** (Печатная плата)

**Rarity:** Common

**Sources:**
- Dismantle: Electronics, drones
- Loot: Scavs (40%), general loot
- Vendors: Electronic shops

**Uses:**
- Basic implants
- Weapon smart-systems
- Cyberdecks (low-tier)

**Value:** 15 €$  
**Stack:** 999  
**Weight:** 0.1kg

---

#### 6. **Processor Chip** (Процессорный чип)

**Rarity:** Uncommon  
**Tier:** 2

**Sources:**
- Dismantle: Rare+ electronics
- Loot: Netrunners (30%), Drones (20%)
- Production: 5x Circuit Board + 2x Silicon → 1x Processor

**Uses:**
- Cyberdecks
- Smart weapons
- Advanced implants

**Value:** 120 €$

---

### Tier 3: Advanced

#### 7. **Neural Matrix** (Нейронная матрица)

**Rarity:** Rare  
**Tier:** 3

**Sources:**
- Loot: Cyberpsychos (50%), High-tier netrunners (25%)
- Extraction: Biotech labs
- Quest: Specific corp missions

**Uses:**
- Legendary cyberdecks
- OS implants (Sandevistan, Berserk)
- Brain-interface systems

**Value:** 2,500 €$  
**Stack:** 50

---

#### 8. **Quantum Core** (Квантовое ядро)

**Rarity:** Legendary  
**Tier:** 5

**Sources:**
- Boss drops: Blackwall Guardian (100%)
- Raid rewards: Corpo datacenter raids
- Ultra-rare extraction zones

**Uses:**
- Legendary cyberdecks
- Ultimate-tier crafts
- Experimental implants

**Value:** 50,000 €$  
**Stack:** 10  
**Unique:** Only 1 can be equipped

---

## 🧪 CHEMICAL & BIOLOGICAL

#### 9. **Synthetic Blood** (Синтетическая кровь)

**Rarity:** Uncommon

**Sources:**
- Vendors: Medical shops
- Loot: Medtech enemies, clinics
- Production: Bio-labs

**Uses:**
- Medical implants
- Bio-mods
- Healing items crafting

**Value:** 80 €$

---

#### 10. **Neuro-Plastics** (Нейропластика)

**Rarity:** Rare  
**Tier:** 3

**Sources:**
- Loot: Ripperdocs (40%), Bio-labs
- Extraction: Biotechnica facilities
- Black market

**Uses:**
- Neural implants
- Interface systems
- Brain-chips

**Value:** 1,200 €$

---

## 💾 DATA & INFORMATION

### Digital Resources

#### 11. **Encrypted Data Shard** (Зашифрованный датачип)

**Rarity:** Common-Rare (variable)

**Sources:**
- Hacking: Corporate systems
- Loot: Netrunners (80%)
- Quest rewards

**Contents (RNG):**
- Crafting recipes (15%)
- Eurodollars (200-5,000) (40%)
- Intel/Blackmail (30%)
- Junk data (15%)

**Value:** 50-5,000 €$ (depends on content)  
**Decrypt Cost:** 100-1,000 €$ (or Hacking skill check)

---

#### 12. **Corporate Blueprint** (Корпоративный чертёж)

**Rarity:** Epic  
**Tier:** 4

**Sources:**
- Hack: Corporate R&D databases
- Heist missions
- Rare quest rewards

**Types:**
- Weapon blueprints (craft legendary weapons)
- Implant blueprints (exclusive cyberware)
- Tech blueprints (vehicles, equipment)

**Value:** 10,000-50,000 €$

**Note:** Consumable (single-use learn recipe)

---

#### 13. **Blackmail Material** (Компромат)

**Rarity:** Rare-Legendary

**Sources:**
- Investigation quests
- Hacking personal files
- Surveillance

**Usage:**
- Quests (leverage)
- Trade to Fixers (5,000-50,000 €$)
- Blackmail NPC directly

**Value:** Variable (depends on target)

---

## 🔧 CRAFTING COMPONENTS

### Tier 1-2: Basic

#### 14. **Weapon Parts** (Запчасти оружия)

**Rarity:** Common

**Sources:**
- Dismantle weapons (100%)
- Loot: Gunsmiths
- Vendors

**Uses:**
- Repair weapons
- Craft basic weapons
- Weapon mods

**Value:** 10 €$  
**Stack:** 999

---

#### 15. **Armor Plates** (Бронепластины)

**Rarity:** Common-Uncommon

**Tiers:**
- Basic Plate: Common, 5 €$
- Reinforced Plate: Uncommon, 50 €$
- Composite Plate: Rare, 300 €$

**Uses:**
- Armor crafting
- Armor upgrades
- Mods

---

### Tier 3-4: Advanced

#### 16. **Servo Motor** (Сервомотор)

**Rarity:** Uncommon-Rare  
**Tier:** 2-3

**Sources:**
- Dismantle: Cyber-limbs
- Loot: Mechs (60%), Cyborgs (40%)

**Uses:**
- Gorilla Arms
- Mantis Blades
- Cyber-legs

**Value:** 500 €$ (rare variant)

---

#### 17. **Optical Sensor** (Оптический сенсор)

**Rarity:** Rare  
**Tier:** 3

**Sources:**
- Dismantle: Kiroshi optics
- Loot: Snipers (30%), Drones (50%)

**Uses:**
- Cyberoptics
- Smart weapon systems
- Targeting implants

**Value:** 800 €$

---

## 🌟 EXOTIC MATERIALS

#### 18. **Militech Spec-Ops Tech** (Спецтех Militech)

**Rarity:** Epic  
**Tier:** 4

**Sources:**
- Raid: Militech facilities
- Boss drop: Militech commanders (20%)
- Black market (rare)

**Uses:**
- Mil-spec weapons
- Tactical implants
- Spec-ops gear

**Value:** 8,000 €$  
**Stack:** 10

---

#### 19. **Arasaka Nano-Assemblers** (Нано-сборщики Arasaka)

**Rarity:** Legendary  
**Tier:** 5

**Sources:**
- Raid: Arasaka Tower (1% drop)
- Quest: Corpo espionage missions
- Extremely rare

**Uses:**
- Craft: Self-repairing armor
- Craft: Auto-maintenance implants
- Legendary-tier crafts only

**Value:** 100,000 €$  
**Stack:** 1 (unique component)

---

#### 20. **AI Fragment** (Фрагмент ИИ)

**Rarity:** Artifact  
**Tier:** 5

**Lore:** Piece of rogue AI from beyond Blackwall

**Sources:**
- Boss: Blackwall Guardian (guaranteed)
- Quest: Bartmoss Legacy ending
- Ultra-rare (maybe 5 exist per server)

**Uses:**
- Craft: Sentient cyberdecks
- Craft: AI-assisted systems
- Quest items

**Value:** Priceless (cannot vendor)  
**Trade:** Player-to-Player only (millions €$)

---

## 📊 RESOURCE TIER SYSTEM

### Tier Classification

| Tier | Rarity Range | Zones | Vendors | Value Range |
|------|--------------|-------|---------|-------------|
| **T1** | Common | All | Yes | 1-50 €$ |
| **T2** | Common-Uncommon | Medium+ | Yes | 50-300 €$ |
| **T3** | Uncommon-Rare | Hard+ | Limited | 300-2,000 €$ |
| **T4** | Rare-Epic | Very Hard | Rare | 2k-20k €$ |
| **T5** | Epic-Legendary | Extreme/Raid | No | 20k-500k €$ |

---

## 🗺️ RESOURCE LOCATIONS

### By Zone Type

**Watson (Industrial):**
- Scrap Metal (abundant)
- Circuit Boards (common)
- Weapon Parts (common)

**Corpo Plaza:**
- Corporate Blueprints (rare, heavily guarded)
- Encrypted Data (uncommon)
- Premium components (epic)

**Badlands:**
- Raw ore (common)
- Salvage (common)
- Nomad-specific materials

**Pacifica:**
- Black market goods
- Stolen components
- Crypto currencies

---

## 📈 SUPPLY & DEMAND

### Dynamic Pricing

**High Demand Resources:**
- Neural Matrix (everyone wants for OS implants)
- Quantum Core (endgame crafts)
- Titanium Alloy (mid-game bottleneck)

**Price Fluctuation:**
- Base price ±50% depending on:
  - Server economy
  - Recent events
  - Faction control
  - Player production

**Example:**
```
Titanium Alloy base: 150 €$
Low supply: 225 €$ (+50%)
High demand: 195 €$ (+30%)
Event bonus: 120 €$ (-20%)
```

---

## ✅ Готовность

- ✅ 20+ ресурсов детализировано
- ✅ Tier system (T1-T5)
- ✅ Sources (loot, harvest, production)
- ✅ Values и pricing
- ✅ Dynamic economy factors

**Следующий шаг:** Рецепты крафта!

