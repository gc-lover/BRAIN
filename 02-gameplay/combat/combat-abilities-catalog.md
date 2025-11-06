# Каталог Боевых Способностей

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API

**target-domain:** gameplay-combat  
**target-microservice:** gameplay-service (port 8083)  
**target-frontend-module:** modules/combat/abilities

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-039: api/v1/gameplay/combat/abilities-catalog.yaml (2025-11-06)
- Last Updated: 2025-11-06 23:10
---

---

## 📖 Структура Способности

```yaml
ability:
  id: "unique_id"
  name: "Название"
  category: "Combat|Tech|Stealth|Hacking|Support"
  slot: "Q|E|R|Passive"
  class_affinity: ["Solo", "Netrunner", ...]
  
  requirements:
    level: 5
    attributes: {REF: 12, INT: 10}
    skills: {Gunplay: 3, Hacking: 2}
    implants: ["cyberware_id"]
    equipment: ["weapon_type"]
  
  costs:
    energy: 30
    cooldown: 15s
    charges: 2
  
  effects:
    damage: 150
    duration: 5s
    range: 20m
    aoe: 5m
    type: "physical|energy|emp|cyber"
  
  synergies:
    - ability_id: "combo_bonus"
    - implant_id: "power_boost"
  
  upgrades:
    rank2: {damage: 200, cooldown: 12s}
    rank3: {damage: 250, cooldown: 10s}
```

---

## ⚔️ COMBAT ABILITIES (Боевые)

### Solo / Assault Specialist

#### 1. **Berserk Mode** (R - Ultimate)

**ID:** `solo_berserk_r`  
**Slot:** R (Ultimate)  
**Class:** Solo, Nomad  

**Requirements:**
- Level: 10
- STR ≥ 14, BODY ≥ 12
- Skill: Melee Combat R3+
- Implant: Berserk Operating System

**Costs:**
- Energy: 80
- Cooldown: 180s
- Duration: 15s

**Effects:**
- Damage +100%
- Damage Resistance +50%
- Movement Speed +30%
- Health Regen +50 HP/s
- Melee attacks ignore 50% armor
- Cannot use ranged weapons
- Cyberpsychosis risk +10

**Visual:**
- Red glitch overlay
- Screen shake
- Heartbeat audio intensifies

**Synergies:**
- `gorilla_arms` → +50% melee damage
- `subdermal_armor` → +20% resistance
- `pain_editor` → Duration +5s

**Upgrades:**
- R2: Duration 20s, Damage +120%
- R3: Duration 25s, Damage +150%, Team buff +20% damage

---

#### 2. **Combat Slide** (E - Signature)

**ID:** `solo_combat_slide_e`  
**Slot:** E (Signature)  
**Class:** Solo, Nomad

**Requirements:**
- AGI ≥ 10
- Skill: Mobility R2+
- Implant: Cyber Legs

**Costs:**
- Energy: 15
- Cooldown: 8s
- Charges: 2

**Effects:**
- Slide 8m forward while shooting
- Accuracy -30% during slide
- Immune to knockback
- Can trigger combo with other abilities

**Visual:**
- Trail effect
- Dust particles

**Synergies:**
- `shotgun` → Perfect accuracy during slide
- `reinforced_ankles` → Distance +3m
- `sandevistan` → Can use during bullet time

**Combos:**
- `combat_slide` + `shockwave` → AoE explosion on landing

---

#### 3. **Shockwave Slam** (Q - Tactical)

**ID:** `solo_shockwave_q`  
**Slot:** Q (Tactical)  
**Class:** Solo

**Requirements:**
- STR ≥ 12, BODY ≥ 10
- Implant: Gorilla Arms or Power Legs

**Costs:**
- Energy: 40
- Cooldown: 20s

**Effects:**
- Jump and slam ground
- 200 Physical damage в радиусе 5m
- Knockback enemies 3m
- Stun 2s

**Visual:**
- Ground crack effect
- Shockwave ripple

**Synergies:**
- `gorilla_arms` → Damage +100, Radius +2m
- `reinforced_skeleton` → Can slam from higher
- `combat_slide` → Combo: slide into shockwave

---

### Netrunner / Hacking Specialist

#### 4. **System Overload** (R - Ultimate)

**ID:** `netrunner_overload_r`  
**Slot:** R (Ultimate)  
**Class:** Netrunner

**Requirements:**
- INT ≥ 14, TECH ≥ 12
- Skill: Hacking R4+
- Implant: Advanced Cyberdeck

**Costs:**
- Energy: 100 (Cyberdeck RAM)
- Cooldown: 240s
- Cast time: 3s

**Effects:**
- Hack all enemies in 30m radius
- Target 1: Suicide (weapon self-fire)
- Target 2-5: Blind (cyberoptics disabled) 10s
- Target 6-10: Slow (cyberlegs disabled) 8s
- Others: Minor damage over time

**Visual:**
- Red digital wave expanding
- Targets glitch and spark

**Synergies:**
- `legendary_cyberdeck` → Range +10m, Targets +5
- `heat_sink` → Cooldown -60s
- `ice_breaker` → Ignore 50% ICE resistance

**Risk:**
- Trace counter hack +30%
- Humanity -5 per use

---

#### 5. **Stealth Daemon** (E - Signature)

**ID:** `netrunner_stealth_daemon_e`  
**Slot:** E (Signature)  
**Class:** Netrunner

**Requirements:**
- INT ≥ 10
- Skill: Hacking R2+
- Implant: Cyberdeck

**Costs:**
- Energy: 25 (RAM)
- Cooldown: 15s
- Duration: 10s

**Effects:**
- Upload daemon to enemy
- Enemy cameras ignore you
- Enemy motion sensors disabled
- Turrets friendly to you

**Visual:**
- Green hack lines
- Enemy systems turn green

**Synergies:**
- `optic_camo` → Duration +5s
- `stealth_runner` skill → Detection -50%

---

#### 6. **Quickhack Barrage** (Q - Tactical)

**ID:** `netrunner_quickhack_q`  
**Slot:** Q (Tactical)  
**Class:** Netrunner

**Costs:**
- Energy: 30 RAM
- Cooldown: 12s
- Charges: 3

**Effects:**
- Fire 3 quickhacks rapid succession
- Choose from: Blind, Weapon Jam, Cyberware Disable
- Each 50 damage + effect

**Synergies:**
- `quickhack_modules` → +2 charges
- `cyberdeck_overclock` → No cooldown for 10s (ultimate combo)

---

## 🔧 TECH ABILITIES (Технические)

### Techie / Engineer Specialist

#### 7. **Deploy Turret** (R - Ultimate)

**ID:** `techie_turret_r`  
**Slot:** R (Ultimate)  
**Class:** Techie

**Requirements:**
- TECH ≥ 14, INT ≥ 10
- Skill: Tech R4+

**Costs:**
- Energy: 80
- Cooldown: 120s
- Duration: 60s or destroyed

**Effects:**
- Deploy auto-turret
- 80 DPS to nearest enemy
- 500 HP turret
- Range 25m
- Can hack turret for upgrades

**Visual:**
- Mechanical deployment animation
- Laser targeting beams

**Synergies:**
- `tech_weapons` → Turret damage +50%
- `smart_targeting` → Turret range +10m
- Multiple turrets possible (2 max)

---

#### 8. **EMP Grenade** (Q - Tactical)

**ID:** `techie_emp_grenade_q`  
**Slot:** Q (Tactical)  
**Class:** Techie, Solo

**Costs:**
- Energy: 35
- Cooldown: 18s
- Charges: 2

**Effects:**
- Throw EMP grenade (range 20m)
- 8m AoE explosion
- 150 EMP damage to cyberware
- Disable implants 8s
- Disable electronics (cameras, turrets)

**Visual:**
- Blue electric explosion
- Cyberware spark effects

**Synergies:**
- `cyber_weapons` → Damage +100 to robots
- `emp_shielding` → Player immune to own EMP

---

#### 9. **Repair Drone** (E - Signature)

**ID:** `techie_repair_drone_e`  
**Slot:** E (Signature)  
**Class:** Techie, Medtech

**Costs:**
- Energy: 20
- Cooldown: 25s
- Duration: 15s

**Effects:**
- Deploy repair drone
- Heals ally or self: 50 HP/s
- Repairs cyberware damage
- Can heal turrets/vehicles

**Visual:**
- Hovering drone with repair beam

**Synergies:**
- `medical_implants` → Heal rate +25 HP/s
- `tech_efficiency` → Duration +10s

---

## 🥷 STEALTH ABILITIES (Скрытность)

#### 10. **Optical Camo** (R - Ultimate)

**ID:** `stealth_optical_camo_r`  
**Slot:** R (Ultimate)  
**Class:** Solo, Netrunner (Stealth builds)

**Requirements:**
- AGI ≥ 12, COOL ≥ 10
- Skill: Stealth R3+
- Implant: Optical Camo System

**Costs:**
- Energy: 60
- Cooldown: 90s
- Duration: 20s or until attack

**Effects:**
- Full invisibility
- Movement speed -20%
- Breaking: attacking, sprinting, taking damage
- Detection radius -80%

**Visual:**
- Predator-style shimmer
- Partial transparency

**Synergies:**
- `silent_footsteps` → Movement speed normal
- `stealth_runner` → Duration +10s

**Upgrades:**
- R2: Duration 25s, can attack once without breaking
- R3: Duration 30s, can attack twice

---

#### 11. **Shadow Strike** (Q - Tactical)

**ID:** `stealth_shadow_strike_q`  
**Slot:** Q (Tactical)  
**Class:** Solo (Stealth)

**Costs:**
- Energy: 25
- Cooldown: 15s

**Effects:**
- Teleport behind enemy (8m range)
- Auto-execute if undetected
- +200% backstab damage
- Enter stealth for 3s after

**Visual:**
- Shadow teleport effect
- Smoke puff

**Synergies:**
- `mantis_blades` → Instant kill on low HP enemies
- `sandevistan` → Can teleport to multiple targets

---

#### 12. **Smoke Grenade** (E - Signature)

**ID:** `stealth_smoke_e`  
**Slot:** E (Signature)  
**Class:** All classes

**Costs:**
- Energy: 0 (free)
- Cooldown: 30s
- Duration: 8s

**Effects:**
- Smoke cloud 6m radius
- Blocks enemy vision
- Player detection -70% in smoke
- Can see through own smoke (implant)

**Synergies:**
- `thermal_optics` → See enemies through smoke
- `gas_mask` → Immune to toxic damage in smoke

---

## 🛡️ SUPPORT ABILITIES (Поддержка)

#### 13. **Combat Stim** (E - Signature)

**ID:** `support_combat_stim_e`  
**Slot:** E (Signature)  
**Class:** Medtech, Solo

**Costs:**
- Energy: 20
- Cooldown: 20s

**Effects:**
- Heal 150 HP instantly
- +30% damage for 8s
- -20% damage taken for 8s
- Cure bleeding, poison

**Visual:**
- Injection animation
- Green buff aura

**Synergies:**
- `medical_expertise` → Heal +50 HP
- `pain_editor` → No cyberpsychosis risk

---

#### 14. **Shield Dome** (R - Ultimate)

**ID:** `support_shield_dome_r`  
**Slot:** R (Ultimate)  
**Class:** Solo (Tank), Techie

**Costs:**
- Energy: 70
- Cooldown: 150s
- Duration: 15s

**Effects:**
- Deploy 8m shield dome
- Blocks 80% incoming damage
- Allies inside: +20% damage output
- 2000 HP shield (can be destroyed)

**Visual:**
- Blue energy dome
- Shimmer effect

**Synergies:**
- `tech_armor` → Shield HP +500
- Team inside → Heal 30 HP/s

---

#### 15. **Scan Enemy** (Q - Tactical)

**ID:** `support_scan_q`  
**Slot:** Q (Tactical)  
**Class:** All (Intelligence builds)

**Costs:**
- Energy: 15
- Cooldown: 8s

**Effects:**
- Scan enemy: reveal HP, armor, implants
- Mark for team (visible through walls) 10s
- +15% damage to scanned enemy
- Reveal weaknesses (headshot multiplier shown)

**Visual:**
- AR overlay scan lines
- Enemy outline glows

**Synergies:**
- `kiroshi_optics` → Scan range +50%
- `tactical_analysis` → Show enemy abilities

---

## ⚡ MOBILITY ABILITIES (Мобильность)

#### 16. **Sandevistan** (R - Ultimate)

**ID:** `mobility_sandevistan_r`  
**Slot:** R (Ultimate)  
**Class:** Solo (REF builds)

**Requirements:**
- REF ≥ 16, AGI ≥ 14
- Implant: Sandevistan Operating System
- **Exclusive:** Cannot use with Berserk or Cyberdeck

**Costs:**
- Energy: 90
- Cooldown: 180s
- Duration: 10s

**Effects:**
- Slow time 70% (enemies move slow)
- Player normal speed
- +50% damage
- Can dodge bullets
- Cyberpsychosis risk +15

**Visual:**
- Blue time-slow effect
- Motion blur on player
- Enemies in slow-mo

**Synergies:**
- `kerenzikov` → Duration +5s
- `reflex_tuner` → Cooldown -30s

**Lore:** Легендарный имплант из Cyberpunk 2077

---

#### 17. **Double Jump** (E - Signature)

**ID:** `mobility_double_jump_e`  
**Slot:** E (Signature)  
**Class:** All

**Requirements:**
- AGI ≥ 8
- Implant: Cyber Legs (Jump upgrade)

**Costs:**
- Energy: 10
- Cooldown: 5s
- Charges: 2

**Effects:**
- Jump again in mid-air
- Height: 4m per jump
- Can shoot while jumping
- Combo with parkour

**Synergies:**
- `reinforced_tendons` → Height +2m
- `parkour_mastery` → 3rd jump possible

---

#### 18. **Dash** (Q - Tactical)

**ID:** `mobility_dash_q`  
**Slot:** Q (Tactical)  
**Class:** All

**Costs:**
- Energy: 20
- Cooldown: 10s
- Charges: 2

**Effects:**
- Instant dash 6m (any direction)
- I-frames 0.5s (invulnerable)
- Can dash through enemies
- Can cancel reload with dash

**Visual:**
- Speed blur
- After-image trail

**Synergies:**
- `kerenzikov` → Slow-mo during dash
- `melee_weapons` → Auto-attack after dash

**Combos:**
- `dash` + `shockwave` → Aerial slam
- `dash` + `shadow_strike` → Extended range

---

## 🌐 HACKING ABILITIES (Хакерство)

### Netrunner Specialist

#### 19. **Remote Detonation** (Q - Tactical)

**ID:** `hack_remote_detonate_q`  
**Slot:** Q (Tactical)  
**Class:** Netrunner

**Requirements:**
- INT ≥ 12
- Skill: Hacking R3+
- Cyberdeck

**Costs:**
- RAM: 30
- Cooldown: 15s

**Effects:**
- Detonate enemy grenades in inventory
- 250 explosion damage + AoE 5m
- Kills enemy if low HP
- Panic nearby enemies

**Visual:**
- Red hack lines to target
- Explosion from enemy

**Synergies:**
- `offensive_daemons` → AoE +3m
- Can chain to nearby enemies

---

#### 20. **Cyberware Malfunction** (E - Signature)

**ID:** `hack_cyberware_malfunction_e`  
**Slot:** E (Signature)  
**Class:** Netrunner

**Costs:**
- RAM: 25
- Cooldown: 18s

**Effects:**
- Disable random enemy implant 10s
- 50% chance: weapon jams
- 30% chance: cyberoptics blind
- 20% chance: cyberlegs fail (fall)

**Visual:**
- Orange glitch effect on enemy
- Sparks from cyberware

**Synergies:**
- `scanner` → Choose which implant to disable
- `ice_breaker` → Ignore 50% resistance

---

#### 21. **Memory Wipe** (R - Ultimate)

**ID:** `hack_memory_wipe_r`  
**Slot:** R (Ultimate)  
**Class:** Netrunner

**Requirements:**
- INT ≥ 16
- Skill: Hacking R5 (Legendary)
- Cyberdeck: Legendary tier

**Costs:**
- RAM: 120
- Cooldown: 300s
- Cast time: 5s

**Effects:**
- Wipe combat memory of all enemies in 20m
- Enemies forget player (reset aggro)
- Enemies confused 15s
- Can re-stealth

**Visual:**
- Purple neural wave
- Enemies clutch heads

**Synergies:**
- `neural_link` → Permanent memory wipe (enemies never remember)

**Risk:**
- NetWatch trace +50%
- Cyberpsychosis risk +10

---

## 💉 MEDIC ABILITIES (Медицинские)

#### 22. **Healing Field** (R - Ultimate)

**ID:** `medic_healing_field_r`  
**Slot:** R (Ultimate)  
**Class:** Medtech

**Requirements:**
- TECH ≥ 12, EMP ≥ 10
- Skill: Medicine R4+

**Costs:**
- Energy: 65
- Cooldown: 120s
- Duration: 20s

**Effects:**
- Deploy 10m healing zone
- 40 HP/s for all allies inside
- Cure poison, bleeding, burning
- +10% damage resistance

**Visual:**
- Green medical nanites
- Healing particles

**Synergies:**
- `medical_implants` → Heal rate 60 HP/s
- `biomonitor` → Also restore energy

---

#### 23. **Combat Revival** (E - Signature)

**ID:** `medic_revival_e`  
**Slot:** E (Signature)  
**Class:** Medtech

**Costs:**
- Energy: 40
- Cooldown: 45s

**Effects:**
- Revive downed ally (5s cast)
- Restore 50% HP
- Immunity 3s after revive
- Can revive self once/mission (if implant)

**Synergies:**
- `defibrillator_implant` → Can self-revive
- `trauma_team_training` → Instant cast

---

## 🎯 TACTICAL ABILITIES (Тактические)

#### 24. **Recon Drone** (Q - Tactical)

**ID:** `tactical_recon_drone_q`  
**Slot:** Q (Tactical)  
**Class:** Netrunner, Techie

**Costs:**
- Energy: 20
- Cooldown: 30s
- Duration: 30s

**Effects:**
- Deploy recon drone
- Scout area safely
- Mark enemies (wall hack)
- Can hack devices through drone

**Visual:**
- Small flying drone
- AR markers

**Synergies:**
- `drone_combat_module` → Drone can shoot
- `stealth_coating` → Drone invisible

---

#### 25. **Flashbang** (Q - Tactical)

**ID:** `tactical_flashbang_q`  
**Slot:** Q (Tactical)  
**Class:** All

**Costs:**
- Energy: 0 (free)
- Cooldown: 25s
- Charges: 2

**Effects:**
- Throw flashbang (15m range)
- Blind enemies 4s in 6m AoE
- Deafen (no audio cues) 6s

**Synergies:**
- `flash_protection` → Player immune
- `tactical_optics` → See through flash

---

## 🔥 СПЕЦИАЛЬНЫЕ СПОСОБНОСТИ

#### 26. **Kerenzikov** (Passive)

**ID:** `special_kerenzikov_passive`  
**Slot:** Passive  
**Class:** Solo (REF builds)

**Requirements:**
- Implant: Kerenzikov

**Effects:**
- When aim + dodge: Time slows 50% for 3s
- Cooldown: 10s
- Can shoot in slow-mo

**Lore:** Популярный имплант из Cyberpunk

---

#### 27. **Mantis Blades Execution** (E - Signature)

**ID:** `melee_mantis_execution_e`  
**Slot:** E (Signature)  
**Class:** Solo (Melee)

**Requirements:**
- Implant: Mantis Blades

**Costs:**
- Energy: 30
- Cooldown: 12s

**Effects:**
- Leap 10m to enemy
- Execute if HP < 30%
- Otherwise: 250 damage
- Lifesteal 50% damage dealt

**Visual:**
- Brutal melee animation
- Blood effects

**Synergies:**
- `sandevistan` → Can execute multiple in slow-mo

---

## 📊 ABILITY SLOTS SYSTEM

### Loadout Structure

```
┌─────────────────────────────────┐
│   ABILITY LOADOUT               │
├─────────────────────────────────┤
│ Q: [Tactical 1]  [Tactical 2]   │
│ E: [Signature]                  │
│ R: [Ultimate]                   │
│ Passive: [Slot 1] [Slot 2] [3]  │
│ Cyberdeck: [Quickhack slots x6] │
└─────────────────────────────────┘
```

**Limits:**
- Q slots: 2 tactical abilities
- E slot: 1 signature ability
- R slot: 1 ultimate (exclusive)
- Passive slots: 3
- Cyberdeck: 6 quickhack programs (if Netrunner)

---

## 🔄 ABILITY SYNERGY MATRIX

### Equipment Synergies

| Ability | Equipment | Bonus |
|---------|-----------|-------|
| Berserk | Gorilla Arms | +50% melee damage |
| Sandevistan | Kerenzikov | +5s duration |
| System Overload | Legendary Deck | +10m range |
| Optical Camo | Silent Footsteps | Normal movement |
| Combat Slide | Shotgun | Perfect accuracy |

### Combo Synergies

| Combo | Effect |
|-------|--------|
| Dash + Shockwave | Aerial slam attack |
| Shadow Strike + Mantis | Guaranteed execute |
| Smoke + Optical Camo | Perfect infiltration |
| EMP + System Overload | Total system shutdown |
| Scan + Quickhack | +50% quickhack damage |

---

## ⚖️ BALANCE NOTES

### Power Levels

**Tier 1 (Lvl 1-10):**
- Q abilities: 50-100 damage, 15-20s CD
- E abilities: Utility focused
- R abilities: 200-300 damage, 120s CD

**Tier 2 (Lvl 11-25):**
- Q: 100-200 damage, 12-18s CD
- E: Enhanced effects
- R: 400-600 damage, 150s CD

**Tier 3 (Lvl 26-50):**
- Q: 200-400 damage, 10-15s CD
- E: Powerful utility
- R: 800-1200 damage, 180s CD

**Tier 4 (Lvl 51+):**
- Q: 400-800 damage, 8-12s CD
- E: Game-changing
- R: 1500-3000 damage, 240s CD

---

## ✅ Готовность

**Для API:**
- ✅ 27 способностей детально описаны
- ✅ Все параметры определены
- ✅ Синергии прописаны
- ✅ Балансировка по тирам

**Следующий шаг:** Создать ещё 50+ способностей для полного охвата!

