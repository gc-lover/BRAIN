# AI Противников и Враги

**Версия:** 1.0.0  
**Дата:** 2025-11-06  
**Статус:** Ready for API

---

## 🤖 ФИЛОСОФИЯ AI

### Принципы

1. **Реалистичное Поведение** — враги действуют логично
2. **Разнообразие** — разные типы = разные тактики
3. **Адаптация** — AI учится на действиях игрока
4. **Интеллект** — сложные враги используют комбо и тактики
5. **Честная Игра** — AI не читерит (знает только то, что видит)

### Уровни Сложности AI

**Level 1 (Trash Mobs):**
- Простое поведение
- Predictable patterns
- Solo или малые группы

**Level 2 (Elites):**
- Тактическое поведение
- Используют укрытия
- Координируются в группах

**Level 3 (Bosses):**
- Сложные паттерны
- Уникальные механики
- Адаптация к стратегии игрока

**Level 4 (World Bosses / Raid):**
- Многофазные бои
- Требуют координации 5+ игроков
- Уникальные mechanics per boss

---

## 👥 ТИПЫ ВРАГОВ

### 1. CORPO GUARDS (Корпо-Охрана)

#### Arasaka Security

**Role:** Defensive, organized  
**Difficulty:** Medium

**Stats:**
- HP: 500
- Armor: 150
- Damage: 45/shot
- Weapons: Arasaka rifles, pistols

**AI Behavior:**

**Phase 1: Patrol (Unalerted)**
- Patrol routes (predictable)
- Check points of interest
- Communication with team (radio chatter)

**Phase 2: Alert**
- Call backup (30s ETA)
- Take cover immediately
- Suppressive fire
- Flank if 2+ guards

**Phase 3: Combat**
- Focus fire priority targets
- Use cover-to-cover movement
- Throw grenades at player cover
- Retreat if HP < 30%

**Abilities:**
- **Combat Stim** (heal 200 HP, 60s CD)
- **Flashbang** (blind player, 45s CD)
- **Call Drone** (support drone, once per fight)

**Weaknesses:**
- Predictable patrol routes
- Radio can be hacked (disable comms)
- Expensive to corpo (retreat easily)

---

#### Militech Soldiers

**Role:** Aggressive, military tactics  
**Difficulty:** Hard

**Stats:**
- HP: 600
- Armor: 200
- Damage: 55/shot

**AI Behavior:**
- Squad tactics (3-5 units)
- Bounding overwatch (leapfrog advance)
- Suppressive fire + flanking
- Air support possible (drones)

**Abilities:**
- **Tactical Grenade** (frag or smoke)
- **Combat Stim**
- **Mounted Turret** (deploy for defense)

**Special:**
- Veteran Soldiers: Can use player-like abilities
- Coordinated ultimates

---

### 2. GANGERS (Банды)

#### 6th Street

**Role:** Patriotic, organized, well-armed  
**Difficulty:** Medium

**Stats:**
- HP: 400
- Armor: 100
- Damage: 40/shot

**AI Behavior:**
- Aggressive pushes
- Suppressive fire
- Loud and proud (no stealth)
- Fight to last man (high morale)

**Tactics:**
- Frontal assaults
- Overwhelming fire
- Vehicles (ram player)

---

#### Maelstrom

**Role:** Cybernetic, unpredictable, aggressive  
**Difficulty:** Hard

**Stats:**
- HP: 450
- Armor: 50
- Cyberware: 80%+ body

**Special Traits:**
- High cyberware → vulnerable to EMP
- Berserk mode (low HP)
- Implant abilities

**AI Behavior:**
- Erratic movement
- Melee rushes
- Optical camo (stealth members)
- Tech weapons

**Variants:**
- **Chrome Berserker:** Melee, gorilla arms, berserk ultimate
- **Cyber Shooter:** Mantis blades + rifle
- **Netrunner:** Hacks player cyberware

---

#### Tyger Claws

**Role:** Agile, melee-focused, honorable  
**Difficulty:** Medium-Hard

**Stats:**
- HP: 380
- Armor: 80

**AI Behavior:**
- Melee preference (katanas, mantis blades)
- Acrobatic (jumps, wall-runs)
- Honor code (1v1 duels if possible)

**Abilities:**
- **Dash Strike** (close distance быстро)
- **Bullet Deflection** (katana deflect)
- **Smoke Bombs**

---

#### Valentinos

**Role:** Familia, loyal, tactical  
**Difficulty:** Medium

**AI Behavior:**
- Protect each other
- Retreat if outnumbered
- Call for backup (familia)
- Avenge fallen (morale boost if ally dies)

**Special:**
- Higher morale in groups
- Revenge damage boost (+30% if ally killed)

---

#### Voodoo Boys

**Role:** Netrunners, mysterious  
**Difficulty:** Very Hard

**AI Behavior:**
- Hacking priority (disable player cyberware)
- Stealth (optical camo)
- Minimal direct combat
- Environmental hacks (turrets, traps)

**Abilities:**
- **System Overload** (mass disable)
- **Daemon Upload** (damage over time)
- **Optical Camo** (go invisible)

**Weakness:**
- Low HP (300-400)
- Weak in direct gunfight
- Rely on hacks

---

### 3. SCAVENGERS (Скавенджеры)

**Role:** Scavengers, desperate, dirty  
**Difficulty:** Easy-Medium

**Stats:**
- HP: 300-400
- Armor: 20-50
- Weapons: Trash tier, mixed

**AI Behavior:**
- Ambush tactics
- Flee if losing (low morale)
- Use traps, mines
- Dirty tricks (poison, fire)

**Special:**
- Trap Master: Lay mines dynamically
- Desperate: Suicide grenades when cornered

---

### 4. MECHS & ROBOTS

#### Combat Drones

**Variants:**

**A. Scout Drone**
```yaml
  hp: 100
  speed: Fast
  role: Detection, marking
  weapons: None
  
  ai:
    - Fly erratic patterns
    - Mark player for team
    - Self-destruct if threatened
```

**B. Combat Drone**
```yaml
  hp: 300
  armor: 100
  weapons: Mini-gun (30 DPS)
  
  ai:
    - Circle strafe player
    - Suppressive fire
    - Return to cover at 30% HP
```

**C. Heavy Drone**
```yaml
  hp: 800
  armor: 250
  weapons: Rockets + EMP
  
  ai:
    - Tank role (protect organics)
    - Missile barrage (AoE)
    - EMP pulse (disable player cyberware)
```

---

#### Security Mechs

**Level 1: "Cerberus" Guard Mech**
```yaml
  hp: 1500
  armor: 400
  weapons: Dual machine guns
  
  phases:
    phase1:
      - Stationary turret mode
      - 360° rotation
      - Thermal vision
    
    phase2: (HP < 50%)
      - Mobile mode
      - Chase player
      - Melee slam attacks
  
  weaknesses:
    - Exposed core when overheated
    - EMP stuns 5s
    - Slow turn speed
```

---

### 5. CYBERPSYCHOS (Киберпсихопаты)

**Concept:** Mini-bosses. MaxTac contracts.

**Characteristics:**
- Extremely high cyberware (90-100%)
- Humanity = 0
- Unpredictable
- Devastating abilities

**Example: "The Beast"** (из квеста MaxTac)
```yaml
  name: "Маркус «Зверь» Коул"
  hp: 3000
  armor: 300
  cyberware: Gorilla Arms, Subdermal Armor, Berserk OS
  
  phases:
    phase1: (100-70% HP)
      - Aggressive melee
      - Throw objects
      - Roar (fear effect)
    
    phase2: (70-40% HP)
      - Berserk activated
      - +100% damage, +50% resist
      - Charges players
      - Shockwave slams
    
    phase3: (40-0% HP)
      - Permanent berserk
      - Grab and throw players
      - AoE ground pounds
      - Invulnerable periods
  
  mechanics:
    - Weakpoint: Exposed during charge (REF check 14)
    - EMP stuns briefly
    - Humanity appeals (EMP check 16): может остановить
  
  rewards:
    - 5000 credits
    - Gorilla Arms (legendary)
    - MaxTac rep +30
```

---

## 🏆 BOSS ENEMIES

### Boss Design Philosophy

1. **Telegraphed Attacks** — показывают, что будут делать
2. **Weakpoint Windows** — уязвимы в определённые моменты
3. **Phase Transitions** — меняются на определённых HP%
4. **Skill-based** — можно no-hit победить
5. **Fair** — нет random one-shots

---

### Boss Example #1: "Adam Smasher"

```yaml
  name: "Адам Смэшер"
  lore: "Легендарный киборг-наёмник Arasaka"
  type: Raid Boss
  players_required: 5
  hp: 50,000
  armor: 1,000
  
  phases:
    phase1: (100-70%)
      mechanics:
        - Heavy cannon fire (dodge red zones)
        - Missile barrage (3-second telegraph)
        - Stomp (knockback melee players)
      weakpoint: "Exposed core after missile barrage (5s window)"
    
    phase2: (70-40%)
      changes:
        - Sandevistan activated (moves fast)
        - Dash attacks
        - Rapid melee combos
      adds: "2x Combat Drones spawn"
      weakpoint: "Sandevistan cooldown (8s window)"
    
    phase3: (40-0%)
      mechanics:
        - Berserk mode
        - Area-denial (fire zones)
        - Grab and execute (one-shot if caught)
        - Ultimate: Orbital bombardment (team wipe if don't hide)
      enrage: "10 minutes (DPS check)"
  
  strategy:
    tank: "Holds boss, dodges stomps"
    dps: "Focus weakpoints only"
    healer: "Sustain tank, cleanse fire"
    support: "Disable drones"
  
  rewards:
    - 100,000 credits
    - Smasher's Cannon (exotic weapon)
    - Arasaka Legendary Armor set piece
```

---

### Boss Example #2: "Blackwall Guardian"

```yaml
  name: "Страж Блэкволла"
  type: Rogue AI
  location: Cyberspace
  players_required: 3-5 (Netrunners preferred)
  
  hp: 30,000 (virtual)
  defense: ICE Layers (3)
  
  phases:
    phase1: "ICE Barrier"
      - Break 3 ICE layers (netrunner checks INT 14, 16, 18)
      - Physical damage reduced 90%
      - Quickhacks deal full damage
    
    phase2: "Code Assault"
      - Fires malicious code (DoT)
      - Summons lesser AI entities
      - Reality glitches (visual distortion)
    
    phase3: "Blackwall Breach"
      - Opens portals (other AIs)
      - Mass system overload
      - Final stand
  
  mechanics:
    - Netrunner role critical (break ICE)
    - Non-netrunners: shoot AI entities
    - Healer: Cleanse code corruption
  
  rewards:
    - Legendary Cyberdeck
    - AI Fragment (pet/companion AI)
    - Blackwall Access (quest unlock)
```

---

## 🎯 AI TACTICS LIBRARY

### Tactic: Flanking

**Used By:** Militech, 6th Street, Elite Corpos  
**Execution:**
1. 2+ enemies
2. One suppresses (front)
3. Others flank (sides/behind)
4. Coordinate fire from multiple angles

**Counter:**
- Watch flanks
- Reposition constantly
- AoE to disrupt

---

### Tactic: Kiting

**Used By:** Snipers, Drones, Agile enemies  
**Execution:**
1. Maintain distance
2. Shoot and retreat
3. Use mobility to avoid melee

**Counter:**
- Close distance quickly (dash)
- Slow/stun abilities
- Snipe them first

---

### Tactic: Swarm

**Used By:** Scavs, Animals (low-level)  
**Execution:**
1. Rush en masse
2. Overwhelm with numbers
3. Melee focus

**Counter:**
- AoE damage
- Choke points
- Kiting

---

### Tactic: Hacker Disable

**Used By:** Voodoo Boys, Netrunners  
**Execution:**
1. Stay at range
2. Hack player cyberware (disable abilities)
3. Let team kill disabled player

**Counter:**
- ICE firewall implant
- Rush netrunner (kill first)
- EMP shielding

---

## 📊 ENEMY TIER SYSTEM

### Tier 0: Civilian (Non-Combat)

```yaml
  hp: 100
  weapons: None or improvised
  ai: Flee on sight of combat
  threat: Zero
```

### Tier 1: Street Thug

```yaml
  hp: 250-350
  armor: 0-50
  weapons: Pistols, bats
  ai: Basic (shoot, hide, flee if losing)
  difficulty: Easy
  spawn: Street encounters
```

### Tier 2: Gang Member

```yaml
  hp: 400-500
  armor: 50-100
  weapons: SMGs, shotguns
  ai: Intermediate (flanking, grenades)
  difficulty: Medium
  spawn: Gang territories
```

### Tier 3: Professional (Corpo/Mercenary)

```yaml
  hp: 600-800
  armor: 150-200
  weapons: Assault rifles, tech weapons
  ai: Advanced (tactics, abilities)
  difficulty: Hard
  spawn: Corporate zones, contracts
```

### Tier 4: Elite (MaxTac, Special Forces)

```yaml
  hp: 1000-1500
  armor: 300-400
  weapons: Legendary tier
  ai: Expert (player-like behavior)
  abilities: Full loadout (Q/E/R)
  difficulty: Very Hard
  spawn: Endgame content
```

### Tier 5: Boss

```yaml
  hp: 5,000-50,000
  mechanics: Unique per boss
  difficulty: Extreme
  players: 1-5 depending on boss
```

---

## 🧠 ADVANCED AI BEHAVIORS

### Adaptive Learning

**System:**
- AI tracks player tactics
- Adapts after 2-3 encounters
- Changes behavior to counter player

**Example:**
```
Player uses stealth often
→ Enemy patrols increase
→ Motion sensors deployed
→ Unpredictable routes
```

**Player uses sniping**
```
→ Enemies use smoke grenades
→ Zigzag movement
→ Counter-snipers deployed
```

---

### Emotion System (Advanced AI)

**Morale States:**

**High Morale:**
- Aggressive
- Holds ground
- Coordinated

**Normal Morale:**
- Standard behavior
- Balanced tactics

**Low Morale:**
- Defensive
- Seeks cover
- May flee

**Broken Morale:**
- Flee on sight
- Surrender possible
- No combat effectiveness

**Morale Factors:**
- Allies killed: -10% per death
- Boss present: +20%
- Outnumbered: -30%
- Player reputation: -5% per legend level

---

### Communication System

**Radio Chatter:**
- Enemies communicate
- Player can intercept (with implant)
- Hack radio: false info

**Callouts:**
- "Flanking left!"
- "Grenade out!"
- "Reloading!"
- "Man down!"

**Intel Value:**
- Know enemy intentions
- Predict attacks
- Counter tactics

---

## 🎯 SPECIAL ENEMY TYPES

### Netrunner Enemies

**AI Priority:**
1. Disable player cyberware FIRST
2. Stay at maximum range
3. Behind cover/allies
4. Escape if approached

**Quickhacks Used:**
- Weapon Jam (30s disable)
- Cyberoptics Blind (10s)
- Cyberware Malfunction
- System Overload (ultimate)

**Counter:**
- Kill ASAP (priority target)
- ICE firewall (reduce hack effectiveness)
- Trace and counter-hack

---

### Sniper Enemies

**AI Behavior:**
- Perched high ground
- Laser sight (telegraph)
- Relocate after 3 shots
- Escape smoke/flashbang

**Telegraph:**
- Red laser on player (2s warning)
- Audio cue (rifle charging)
- Glint in scope

**Counter:**
- Take cover when laser appears
- Counter-snipe
- Flank and rush

---

### Melee Rushers

**AI Behavior:**
- Sprint at player
- Dodge bullets (AGI)
- Close distance (parkour)
- Overwhelming DPS if reach

**Types:**
- **Maelstrom Berserker** (gorilla arms)
- **Animals Member** (raw strength)
- **Tyger Claws Assassin** (mantis blades)

**Counter:**
- Kiting (maintain distance)
- Slow/stun
- High DPS burst

---

## 🏆 BOSS CATALOG

### Boss #1: "Royce" (Maelstrom Leader)

```yaml
  hp: 8,000
  phases: 3
  difficulty: Hard
  players: 1-2
  
  phase1:
    - Ranged combat (heavy rifle)
    - Deploy combat drones (2)
    - EMP grenades
  
  phase2: (HP < 60%)
    - Activate berserk implants
    - Melee rushes (gorilla arms)
    - Shockwave attacks
  
  phase3: (HP < 30%)
    - Cyberpsychosis triggered
    - Erratic behavior
    - Massive damage, low accuracy
    - Environmental destruction
  
  weakpoints:
    - Overheated implants (glowing red)
    - Stagger during charge (REF 12)
  
  special_mechanic:
    - Can talk down (EMP check 14): Peaceful resolution
```

---

### Boss #2: "Sasquatch" (Animals Alpha)

```yaml
  hp: 12,000
  size: Large (3m tall)
  phases: 2
  
  phase1:
    - Ground pounds (AoE)
    - Grab and throw (one-shot if caught)
    - Summon pack (4-6 Animals)
  
  phase2: (HP < 40%)
    - Enrage (+ steroids)
    - +50% damage, +30% speed
    - Destroys environment
    - Thunder clap (AoE stun)
  
  mechanics:
    - Weak point: Head (but high up, hard to hit)
    - Slow turn speed (can flank)
    - Tired after big attacks (5s window)
  
  arena: "Gym (destructible environment)"
```

---

### Boss #3: "Placide" (Voodoo Boys Hacker)

```yaml
  hp: 6,000 (physical), Infinite (in Net)
  difficulty: Very Hard
  players: 2-3 (need netrunner)
  
  two_phases:
    physical_world:
      - Placide in church
      - Protected by NetWatch ICE
      - Summons netrunner allies
      - Hacks player continuously
    
    cyberspace:
      - Pull players into Net
      - Virtual combat
      - Reality glitches
      - NetWatch interference
  
  win_conditions:
    option1: "Kill physical body (break ICE first)"
    option2: "Defeat in cyberspace (netrunner duel)"
    option3: "Negotiate (EMP 15, INT 14)"
  
  mechanics:
    - ICE Layers: 3 (must hack через)
    - Virtual damage = real damage (if in Net)
    - Can trap player in Net (permanent death?)
```

---

## 📈 DIFFICULTY SCALING

### Dynamic Difficulty

**Factors:**
- Player level
- Group size
- Player skill (tracks performance)
- Zone danger level
- Time of day (some enemies stronger at night)

**Scaling Formula:**
```
Enemy HP = Base_HP × (1 + 0.1 × Player_Level)
Enemy Damage = Base_Damage × (1 + 0.05 × Player_Level)
Enemy AI = Base_AI + Player_Skill_Tier
```

**Player Skill Tiers:**
- Beginner: Basic AI
- Intermediate: +Flanking
- Advanced: +Abilities
- Expert: +Adaptive
- Master: +Prediction

---

## ✅ Готовность

- ✅ 10+ типов врагов созданы
- ✅ AI behaviors детализированы
- ✅ 3 boss fights спроектированы
- ✅ Adaptive AI система создана
- ✅ Difficulty scaling определён

**Для геймдизайна готово!**

