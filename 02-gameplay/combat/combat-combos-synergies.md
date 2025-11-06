# Система Комбо и Синергий

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-041: api/v1/gameplay/combat/combos-synergies.yaml (2025-11-06)
- Last Updated: 2025-11-06 23:20
---

---

## 🔗 Типы Синергий

### 1. Ability Combos (Комбо Способностей)
2+ способности вместе → дополнительный эффект

### 2. Team Synergies (Командные Синергии)
Способности разных игроков взаимодействуют

### 3. Equipment Synergies (Экипировка + Способности)
Оружие/броня усиливают способности

### 4. Implant Synergies (Импланты + Способности)
Кибервар меняет способности

### 5. Timing Combos (Синхронизация)
Время использования важно для бонуса

---

## ⚡ ABILITY COMBOS

### Solo Combos

#### Combo #1: "Aerial Devastation"
```
Dash (Q) → Jump → Shockwave Slam (Q)
```
**Execution:**
1. Dash forward (6m)
2. Double Jump mid-dash
3. Shockwave Slam from air

**Bonus:**
- +100% slam damage
- +3m AoE radius
- Stun duration +1s

**Difficulty:** Medium  
**Visual:** Epic aerial maneuver

---

#### Combo #2: "Shadow Assassin"
```
Optical Camo (R) → Shadow Strike (Q) → Mantis Execution (E)
```
**Execution:**
1. Activate invisibility
2. Teleport behind target
3. Execute with mantis blades

**Bonus:**
- Guaranteed critical hit
- +300% damage
- Remain invisible after kill (if kill)

**Difficulty:** Hard  
**Cooldowns:** Long (90s + 15s + 12s)

---

#### Combo #3: "Bullet Time Massacre"
```
Sandevistan (R) → Precision Shots → Combat Slide (E)
```
**Execution:**
1. Activate time-slow
2. Headshot multiple enemies
3. Slide between targets

**Bonus:**
- +50% headshot damage in Sandevistan
- Can target 5-8 enemies
- Perfect accuracy during slide

**Difficulty:** Expert  
**Skill Ceiling:** Very High

---

### Netrunner Combos

#### Combo #4: "System Cascade"
```
Scan (Q) → Quickhack Barrage (Q) → System Overload (R)
```
**Execution:**
1. Scan reveal weaknesses
2. Fire quickhacks (3x)
3. Ultimate system overload

**Bonus:**
- Scanned targets: +50% quickhack damage
- Overload propagates to nearby (chain reaction)
- NetWatch trace delayed

**Difficulty:** Medium

---

#### Combo #5: "Ghost Protocol"
```
Stealth Daemon (E) → Optical Camo (R) → Memory Wipe (R)
```
**Execution:**
1. Disable enemy detection
2. Go invisible
3. Wipe memory of combat

**Bonus:**
- Perfect stealth reset
- Can repeat entire infiltration
- Zero trace risk

**Difficulty:** Hard  
**Use Case:** Perfect heist

---

### Techie Combos

#### Combo #6: "Turret Fortress"
```
Deploy Turret (R) → Shield Dome (R) → EMP Grenade (Q)
```
**Execution:**
1. Deploy auto-turret
2. Shield dome around turret
3. EMP disable enemy electronics

**Bonus:**
- Turret invulnerable in dome
- Turret damage +50%
- Enemy reinforcements disabled

**Difficulty:** Medium  
**Use Case:** Defense missions

---

## 👥 TEAM COMBOS

### 2-Player Combos

#### Team Combo #1: "Tank & Spank"
```
Player 1 (Tank): Taunt (Q)
Player 2 (DPS): Burst combo
```
**Synergy:**
- Tank locks enemy
- DPS free backstab position
- +30% damage (flanking bonus)

**Execution:**
- Simultaneous activation
- Tank holds 5s minimum

---

#### Team Combo #2: "Netrunner Setup"
```
Player 1 (Netrunner): System Overload (R)
Player 2 (DPS): AoE Ultimate
```
**Synergy:**
- Enemies disabled and grouped
- AoE hits all
- +100% damage to disabled targets

**Timing:** Within 2s window

---

#### Team Combo #3: "Медик Спасение"
```
Player 1 (DPS): Aggro everything
Player 2 (Medic): Mass Heal + Shield Dome
```
**Synergy:**
- DPS goes ham without fear
- Medic keeps alive
- Dome blocks retaliation

---

### 3-5 Player Combos

#### Team Combo #4: "Raid Opener"
```
Player 1 (Tank): Charge → Taunt
Player 2 (Netrunner): Scan All → Quickhacks
Player 3 (DPS): Focus Fire marked targets
Player 4 (Support): Buff Drone on DPS
Player 5 (Healer): Shield Dome центр
```

**Synergy:**
- Tank controls boss
- Netrunner disables adds
- DPS nukes priority targets (buffed)
- Team protected in dome

**Bonus:**
- +80% team efficiency
- Boss phase skip possible
- Zero deaths (если executed correctly)

**Difficulty:** Expert  
**Coordination:** Voice comms required

---

## 🔥 ADVANCED COMBOS

### Solo Endgame Combos

#### Combo #7: "One-Shot Build"
```
Equipment: Sniper Rifle + Crit implants
Abilities: Sandevistan (R) + Precision Shot (Q)
Buffs: Combat Stim (+30% damage)
```
**Execution:**
1. Activate all buffs
2. Sandevistan time-slow
3. Precision Shot headshot

**Result:**
- 4,000-8,000 damage (one-shot bosses)
- Requires perfect execution

**Build Investment:** Extreme (BiS gear + implants)

---

#### Combo #8: "Immortal Tank"
```
Passive: Last Stand + Auto-Heal
Active: Fortify (R) → Shield Boost (Q) → Combat Stim (E)
```
**Execution:**
- Stack all defensives
- Trigger Last Stand at 1 HP
- Auto-heal procs
- Repeat rotation

**Result:**
- Survive 20+ seconds under focus fire
- Can solo tank raid bosses

---

## 🎯 SKILL CEILING SYSTEM

### Execution Difficulty

**Easy Combos (Bronze):**
- 2 abilities, любой порядок
- Window: 10s
- Example: Scan → Shoot

**Medium Combos (Silver):**
- 2-3 abilities, specific order
- Window: 5s
- Example: Dash → Shockwave

**Hard Combos (Gold):**
- 3-4 abilities, precise timing
- Window: 2s
- Example: Sandevistan → Multi-Headshots → Slide

**Expert Combos (Platinum):**
- 5+ abilities, frame-perfect
- Window: <1s
- Example: One-Shot Build

**Legendary Combos (Diamond):**
- Team coordination required
- Simultaneous execution
- Window: <2s for all players

---

## ⚙️ SYNERGY MECHANICS

### Damage Multipliers

**Ability Combo Multipliers:**
- 2 abilities: +20% damage
- 3 abilities: +50% damage
- 4+ abilities: +100% damage

**Team Synergy Multipliers:**
- 2 players: +15% team damage
- 3 players: +30%
- 5 players (perfect): +50%

### Cooldown Reduction Combos

**Chain Abilities:**
- Using Ability B after Ability A: A cooldown -30%
- Requires <3s window

**Example:**
- Quickhack → System Overload: Quickhack CD -30%

---

## 🏆 LEGENDARY COMBOS

### "The Perfect Heist"
```
Players: 3 (Stealth DPS, Netrunner, Support)

Player 1: Optical Camo → Silent movement
Player 2: Stealth Daemon → Disable all security
Player 3: Buff Drone on Player 1 → +damage backup
```
**Result:**
- Zero detection possible
- Guards never alerted
- Perfect stealth bonus

---

### "The Raid Wipe"
```
Players: 5 (Full team)

Tank: Taunt boss + Fortify
Netrunner: System Overload (disable adds)
DPS1 & DPS2: Burst ultimates on boss
Healer: Mass Shield on team
```
**Result:**
- Boss phase skip (burst > 40% HP)
- All adds disabled
- Zero team damage taken

---

## 📊 SYNERGY MATRICES

### Equipment + Ability

| Weapon | Ability | Synergy Effect |
|--------|---------|----------------|
| Shotgun | Combat Slide | Perfect accuracy during slide |
| Sniper | Sandevistan | +100% crit damage in slow-mo |
| SMG | Rapid Fire | +150% fire rate total |
| Mantis Blades | Shadow Strike | Guaranteed execute |
| Smart Gun | Scan | Auto-target weaknesses |

### Implant + Ability

| Implant | Ability | Synergy Effect |
|---------|---------|----------------|
| Gorilla Arms | Shockwave Slam | +100 damage, +2m radius |
| Sandevistan | All abilities | Can use multiple in slow-mo |
| Kerenzikov | Dash | Slow-mo during dash |
| Optical Camo | Shadow Strike | Remain invisible after |
| Legendary Deck | System Overload | +10m range, +5 targets |

---

## 🎯 COMBO SCORING SYSTEM

### Rating Combos

**Factors:**
- Execution Difficulty: 1-10
- Damage Output: 1-10
- Visual Impact: 1-10
- Team Coordination: 1-10

**Examples:**

**"Aerial Devastation":**
- Difficulty: 6/10
- Damage: 7/10
- Visual: 9/10
- Coordination: 2/10 (solo)
- **Score: 24/40** (Gold)

**"The Raid Wipe":**
- Difficulty: 9/10
- Damage: 10/10
- Visual: 10/10
- Coordination: 10/10 (5-player)
- **Score: 39/40** (Legendary)

---

## ✅ Готовность

- ✅ 8 Solo combos созданы
- ✅ 4 Team combos созданы
- ✅ 2 Legendary combos созданы
- ✅ Synergy matrices определены
- ✅ Skill ceiling система создана

**Всего: 14+ комбо и synergy-систем** готовы к интеграции!

