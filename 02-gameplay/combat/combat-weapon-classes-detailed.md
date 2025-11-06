# Детальные Классы Оружия

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-042: api/v1/gameplay/combat/weapons.yaml (2025-11-06)
- Last Updated: 2025-11-06 23:25
---

---

## 🔫 PISTOLS (Пистолеты)

### Характеристики Класса

**Base Stats:**
- Damage: 40-80 per shot
- Fire Rate: 3-5 rounds/s
- Magazine: 12-21 rounds
- Range: Effective 15m, Max 40m
- Accuracy: High (85-95%)

**Movement Penalty:** -5% (минимальный)  
**Reload Time:** 1.2-1.8s

---

### Подклассы Пистолетов

#### A. Revolvers (Револьверы)

**Philosophy:** Высокий урон, низкая скорострельность

**Iconic Example: "Malorian Arms 3516"**
```yaml
weapon:
  id: "malorian_3516"
  name: "Malorian Arms 3516"
  rarity: Legendary
  lore: "Пистолет Джонни Сильверхэнда"
  
  stats:
    damage: 150
    fire_rate: 1.5 rounds/s
    magazine: 6
    reload: 2.5s
    crit_chance: +25%
    crit_damage: +50%
    
  special:
    - "Incendiary rounds (fire damage over time)"
    - "Headshots instant kill enemies < 30% HP"
    
  requirements:
    level: 20
    REF: 14
    skill_gunplay: 4
```

**Variants:**
- **Classic Revolver** — 6 rounds, 120 damage
- **Heavy Revolver** — 5 rounds, 180 damage, -20% fire rate
- **Quick-Draw Revolver** — 8 rounds, 90 damage, +50% draw speed

---

#### B. Semi-Auto Pistols

**Philosophy:** Баланс урона и скорострельности

**Iconic Example: "Militech M-10AF Lexington"**
```yaml
weapon:
  id: "lexington_m10af"
  name: "Militech M-10AF Lexington"
  rarity: Common
  lore: "Стандарт NCPD и корпо-охраны"
  
  stats:
    damage: 55
    fire_rate: 4 rounds/s
    magazine: 15
    reload: 1.5s
    accuracy: 90%
    
  mods_slots: 3
  compatible_mods:
    - Silencer
    - Extended Magazine
    - Smart Targeting
```

---

#### C. Smart Pistols

**Philosophy:** Авто-наведение, tech-focused

**Requirements:**
- Smart Link implant (cyberware)
- TECH ≥ 10

**Mechanics:**
- Auto-track targets
- Bullets curve to target
- Can shoot around corners
- -20% damage (balance)

---

### Pistol Abilities

**Special Abilities (зависят от модели):**

1. **Fan the Hammer** (Revolvers)
   - Fire all 6 rounds instantly
   - -40% accuracy
   - Cooldown: 30s

2. **Precision Mode** (Semi-Auto)
   - Zoom 2x, perfect accuracy
   - -50% fire rate
   - Toggle mode

3. **Smart Tracking** (Smart Pistols)
   - Lock 3 targets
   - Auto-fire at all 3
   - Cooldown: 15s

---

## 🔫 ASSAULT RIFLES (Штурмовые Винтовки)

### Характеристики Класса

**Base Stats:**
- Damage: 30-50 per shot
- Fire Rate: 8-12 rounds/s
- Magazine: 30-50 rounds
- Range: Effective 30m, Max 80m
- Accuracy: Medium (70-85%)

**Movement Penalty:** -20%  
**Reload Time:** 2.0-3.0s

---

### Подклассы AR

#### A. Burst Rifles

**Example: "Militech M-251s Ajax"**
```yaml
  fire_mode: 3-round burst
  damage: 45 per shot
  burst_damage: 135 total
  fire_rate: 3 bursts/s
  magazine: 30 (10 bursts)
  
  special:
    - "Perfect accuracy if stationary"
    - "+20% damage на первую пулю в бурсте"
```

---

#### B. Full-Auto Rifles

**Example: "Kang Tao Type-41"**
```yaml
  fire_mode: Full-auto
  damage: 38
  fire_rate: 10 rounds/s
  magazine: 40
  
  special:
    - "Smart targeting (requires implant)"
    - "Каждая 5-я пуля: +50% damage"
```

---

#### C. Tactical Rifles

**Example: "Arasaka HJKE-11 Yukimura"**
```yaml
  fire_mode: Semi-auto + Full-auto toggle
  damage: 48 (semi), 35 (auto)
  fire_rate: 5 (semi), 9 (auto)
  magazine: 35
  accuracy: 95% (semi), 75% (auto)
  
  special:
    - "Adaptive fire mode"
    - "Semi: +crit chance, Auto: +fire rate"
```

---

## 🔫 SHOTGUNS (Дробовики)

### Характеристики Класса

**Base Stats:**
- Damage: 120-250 per shot (close range)
- Fire Rate: 0.8-2 rounds/s
- Magazine: 6-12 shells
- Range: Effective 8m, Max 20m
- Spread: Wide (12 pellets)

**Movement Penalty:** -15%  
**Reload Time:** 2.5-4.0s (или per shell)

---

### Подклассы Shotgun

#### A. Pump-Action

**Example: "Carnage"**
```yaml
  type: Pump-action
  damage: 250
  fire_rate: 0.8/s
  magazine: 8
  reload: 0.8s per shell
  
  special:
    - "Massive stagger на close range"
    - "Can reload-cancel with dash"
```

---

#### B. Auto-Shotgun

**Example: "Constitution Arms Liberty"**
```yaml
  type: Auto-shotgun
  damage: 140
  fire_rate: 2/s
  magazine: 12
  
  special:
    - "Suppressive fire: enemies take cover"
    - "Destroys cover faster"
```

---

## 🔫 SNIPER RIFLES (Снайперские)

### Характеристики Класса

**Base Stats:**
- Damage: 200-600 per shot
- Fire Rate: 0.5-1.5 rounds/s
- Magazine: 5-10 rounds
- Range: Effective 100m+, Max 300m
- Accuracy: Very High (98%)

**Scope:** 4x-12x zoom  
**Movement Penalty:** -40%

---

### Подклассы Sniper

#### A. Bolt-Action (Высокий урон)

**Example: "Grad Sniper"**
```yaml
  damage: 550
  fire_rate: 0.6/s
  magazine: 5
  
  special:
    - "Penetrates walls (2m concrete)"
    - "Headshot: instant kill most enemies"
    - "Charge shot: hold for +100% damage"
```

---

#### B. Tech Sniper (Проникающий)

**Example: "Nekomata"**
```yaml
  damage: 400
  fire_rate: 1/s
  magazine: 8
  
  special:
    - "Charge to penetrate: hits all in line"
    - "Can shoot through cover"
    - "Ricochet bullets off walls"
```

---

## 🔫 SMG (Пистолеты-пулемёты)

**Base Stats:**
- Damage: 20-35 per shot
- Fire Rate: 12-18 rounds/s
- Magazine: 25-40
- Range: 12m effective
- Accuracy: Medium (70%)

**Movement Penalty:** -10%  
**Best For:** Close-range, high mobility

**Example: "Budgetarms Divided We Stand"**
```yaml
  damage: 28
  fire_rate: 15/s
  magazine: 30
  
  special:
    - "Fires FASTER when moving"
    - "+30% damage when hipfiring"
```

---

## 🔫 LMG (Лёгкие пулемёты)

**Base Stats:**
- Damage: 35-60 per shot
- Fire Rate: 8-10 rounds/s
- Magazine: 75-150 rounds
- Range: 40m

**Movement Penalty:** -35%  
**Spin-up Time:** 1s before full fire rate

**Example: "Defender LMG"**
```yaml
  damage: 48
  fire_rate: 9/s
  magazine: 100
  
  special:
    - "Sustained fire: accuracy increases"
    - "Suppressive fire: enemies -50% accuracy"
    - "Destroys cover"
```

---

## ⚔️ MELEE WEAPONS

### Blade Weapons

#### Katanas

**Example: "Satori"**
```yaml
  damage: 180 per swing
  attack_speed: 2/s
  range: 2m
  
  special:
    - "Deflect bullets (timing required)"
    - "Combo attacks: 3-hit combo +200% damage"
    - "Bleeding effect: 50 damage over 5s"
```

---

### Cyberware Weapons

#### Mantis Blades

```yaml
  damage: 200 per hit
  attack_speed: 2.5/s
  range: 2.5m
  
  special:
    - "Leap attack (10m range)"
    - "Execute enemies < 30% HP"
    - "Cannot be disarmed"
  
  synergies:
    - Sandevistan: Attack multiple in slow-mo
    - Berserk: +100% damage
```

#### Gorilla Arms

```yaml
  damage: 150 per punch
  attack_speed: 1.5/s
  
  special:
    - "Charge punch: 300 damage, knockback"
    - "Open locked doors (STR check bonus)"
    - "Shockwave Slam ability"
```

#### Monowire

```yaml
  damage: 120 per hit
  attack_speed: 3/s
  range: 5m (whip)
  
  special:
    - "Hack while attacking (netrunner combo)"
    - "AoE sweep: hit multiple"
    - "Electrified: +EMP damage"
```

---

## 🚀 EXOTIC WEAPONS

### Legendary Tier

#### "Skippy" (Smart Pistol AI)

```yaml
  sentient: true
  personality: "Annoying but helpful"
  
  modes:
    - "Puppy-Loving Pacifist" (non-lethal)
    - "Stone Cold Killer" (lethal)
  
  special:
    - "Talks to player"
    - "Aimbot mode after 50 kills"
    - "Self-upgrading"
```

#### "Prejudice" (Pistol)

```yaml
  damage: 200
  magazine: 6
  
  special:
    - "Explosive rounds"
    - "Each kill: +10% damage (stacks 10x)"
    - "Reset on reload"
```

#### "Comrade's Hammer" (Revolver)

```yaml
  damage: 800
  magazine: 1
  reload: 5s
  
  special:
    - "One-shot most enemies"
    - "Explosive ammo"
    - "Dismembers on kill"
```

---

## 📊 WEAPON TIERS

### Tier Classification

**Common (White):**
- Base damage
- No special abilities
- 2 mod slots

**Uncommon (Green):**
- +10% damage
- 1 minor special
- 3 mod slots

**Rare (Blue):**
- +25% damage
- 1 special ability
- 4 mod slots

**Epic (Purple):**
- +50% damage
- 2 special abilities
- 5 mod slots
- Unique visual

**Legendary (Orange):**
- +100% damage
- 3+ special abilities
- 6 mod slots
- Unique name, lore, visual
- Cannot be crafted (only looted/quested)

---

## 🎯 WEAPON MODS

### Universal Mods

1. **Silencer**
   - -20% damage
   - +Stealth (silent shots)
   - No muzzle flash

2. **Extended Magazine**
   - +50% magazine size
   - +10% reload time

3. **Scope**
   - 2x-8x zoom
   - +accuracy at range
   - -peripheral vision

4. **Smart Link**
   - Requires implant
   - Auto-targeting
   - Ammo counter in vision

### Weapon-Specific Mods

**Pistol Mods:**
- Fast-Draw Holster (+50% draw speed)
- Burst Fire Mod (3-round burst)
- Ricochet Targeting (bullets bounce)

**Rifle Mods:**
- Bipod (deploy for -recoil)
- Grenade Launcher (underbarrel)
- Smart Rounds (seek targets)

**Shotgun Mods:**
- Dragon Breath Rounds (fire damage)
- Slug Ammunition (single projectile, +range)
- Flechette Rounds (armor penetration)

**Sniper Mods:**
- Thermal Scope (see through walls)
- Penetrator Rounds (shoot through cover)
- Stabilization System (-sway)

---

## 🏭 WEAPON BRANDS

### Arasaka (Japan)

**Style:** Precision, elegance, tech  
**Bonus:** +Accuracy, +Crit Chance  
**Weakness:** Lower raw damage

**Signature Weapons:**
- HJKE-11 Yukimura (AR)
- Tsunami Nue (Pistol)
- JKE-X2 Kenshin (Sniper)

---

### Militech (NUSA)

**Style:** Military, reliable, modular  
**Bonus:** +Damage, +Mod Slots  
**Weakness:** Heavy, slow

**Signature Weapons:**
- M-251s Ajax (AR)
- M-10AF Lexington (Pistol)
- M-179e Achilles (Sniper)

---

### Kang Tao (China)

**Style:** Smart weapons, tech-heavy  
**Bonus:** Smart targeting, tech synergies  
**Requirements:** Smart Link implant

**Signature Weapons:**
- Type-41 (AR)
- Dian (Pistol)
- G-58 Dian (SMG)

---

### Budget Arms (Street)

**Style:** Cheap, unreliable, weird  
**Bonus:** Unique mechanics  
**Weakness:** Low quality, jam chance

**Signature Weapons:**
- Divided We Stand (SMG)
- Carnage (Shotgun)
- Budget Rifle (AR)

---

### Constitutional Arms (Patriotic)

**Style:** American, loud, powerful  
**Bonus:** High damage, patriotic buffs  

**Signature Weapons:**
- Liberty (Shotgun)
- Unity (Pistol)
- Patriot (AR)

---

## ⚔️ MELEE WEAPONS

### Katanas

**Iconic: "Satori"**
```yaml
  damage: 200
  attack_speed: 2/s
  crit_chance: +30%
  
  special:
    - "Deflect bullets (timing mini-game)"
    - "Dash-strike: leap 8m"
    - "Finisher: decapitation animation"
  
  lore: "Meч саби Saburo Arasaka"
```

### Machetes

**Style:** Brutal, bleeding damage

```yaml
  damage: 160
  attack_speed: 2.5/s
  
  special:
    - "Bleeding: 60 damage over 6s"
    - "Heavy attack: dismember limbs"
```

### Clubs/Bats

**Style:** Blunt, stun damage

```yaml
  damage: 140
  attack_speed: 2/s
  
  special:
    - "Stun on hit: 1s"
    - "Knockback: 2m"
    - "Charge attack: 300 damage"
```

---

## ⚡ ENERGY WEAPONS

### Characteristics

**Tech Weapons (Charge & Penetrate):**
- Hold to charge
- Shoot through walls
- EMP damage bonus to cyberware

**Example: "Widow Maker"**
```yaml
  type: Tech Sniper
  damage: 350 (base), 700 (charged)
  
  special:
    - "Charge 2s: shoot through any cover"
    - "X-ray scope: see enemies through walls"
```

**Power Weapons (Raw damage):**
- No charge
- Highest damage
- Ricochet bullets

**Smart Weapons (Auto-aim):**
- Require Smart Link
- Track multiple targets
- Lower skill floor

---

## 💥 EXPLOSIVE WEAPONS

### Grenade Launcher

```yaml
  damage: 350 (direct), 200 (splash)
  fire_rate: 1/s
  magazine: 6
  aoe: 8m
  
  ammo_types:
    - Frag (damage)
    - EMP (disable cyberware)
    - Flashbang (blind)
    - Incendiary (fire DoT)
```

### Rocket Launcher

```yaml
  damage: 1200 (direct), 600 (splash)
  fire_rate: 0.5/s
  magazine: 1
  reload: 5s
  aoe: 12m
  
  special:
    - "Lock-on to vehicles"
    - "Destroys cover completely"
    - "Friendly fire: YES"
```

---

## 🎯 WEAPON MASTERY SYSTEM

### Progression per Weapon Class

**Kills Required:**
- Rank 1 (Novice): 0 kills
- Rank 2 (Trained): 100 kills
- Rank 3 (Expert): 500 kills
- Rank 4 (Master): 2,000 kills
- Rank 5 (Legend): 10,000 kills

**Bonuses per Rank:**

**Pistols:**
- R1: Base
- R2: +5% damage, -10% reload time
- R3: +10% damage, +10% accuracy, Fan the Hammer ability
- R4: +15% damage, +20% accuracy, +10% crit chance
- R5: +25% damage, +30% accuracy, +25% crit, Legendary ability

**Snipers:**
- R3: Hold breath 2x longer
- R4: Bullet time on scope
- R5: Penetrate 2 targets

**Shotguns:**
- R3: Reload while sprinting
- R4: -50% spread
- R5: Explosive shells

---

## 📈 META WEAPONS (По контенту)

### PvE Meta

**Solo Play:**
1. Assault Rifle (versatile)
2. Shotgun (close encounters)
3. Sniper (safe distance)

**Group Play:**
- Tank: Shotgun/LMG
- DPS: Assault Rifle/Sniper
- Support: SMG/Pistol

### PvP Meta

**Arena:**
1. Sniper (one-shots)
2. Shotgun (close maps)
3. Smart Pistol (consistent)

**Open World:**
1. Assault Rifle
2. Sniper
3. SMG

### Extraction (Tarkov-style)

**Best Picks:**
1. Suppressed AR (versatile + stealth)
2. Pistol sidearm (backup, light)
3. Melee (silent kills)

---

## ✅ Готовность

- ✅ 7 классов оружия детализированы
- ✅ 20+ конкретных моделей созданы
- ✅ Brand bonuses определены
- ✅ Mod system прописана
- ✅ Mastery progression создана
- ✅ Meta recommendations даны

**Для API готово!**

