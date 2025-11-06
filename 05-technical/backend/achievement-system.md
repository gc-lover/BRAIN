---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-136: api/v1/achievements/achievements.yaml (2025-11-07 10:32)
- Last Updated: 2025-11-07 00:18
---


# Achievement System - Система достижений

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** средний (Engagement)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20
**api-readiness-notes:** Полная система достижений. Definitions, progress tracking, unlock rewards, titles/badges, categories, rarity, event-driven tracking. Готов к API!

---

## Краткое описание

Система достижений (Achievements) для NECPGAME — мотивация игроков, отслеживание прогресса, награды.

**Микрофича:** Achievements (definitions, tracking, rewards, notifications)

---

## Микросервисная архитектура

**Ответственный микросервис:** world-service  
**Порт:** 8086  
**API Gateway маршрут:** `/api/v1/world/achievements/*`  
**Статус:** 📋 В планах (Фаза 3)

**Взаимодействие с другими сервисами:**
- Подписывается на события от ВСЕХ сервисов для tracking
- notification-service: уведомление об unlock
- mail-service (social): отправка rewards

**Event Bus события (подписывается на множество):**
- `combat:enemy-killed` → track combat achievements
- `quest:completed` → track quest achievements
- `friend:added` → track social achievements
- `trade:completed` → track economy achievements
- `character:level-up` → track progression achievements

**Паттерн:** Achievement service - event consumer, отслеживает прогресс на основе событий

---

## 🏆 Концепция

**Achievement (Достижение)** — награда за выполнение определенного действия или достижение цели.

**Цели системы:**
1. **Мотивация** - игроки хотят собрать все achievements
2. **Retention** - long-term goals
3. **Discovery** - показывает возможности игры
4. **Prestige** - показать достижения другим
5. **Rewards** - tangible benefits

---

## 📋 Категории достижений

### 1. Combat (Боевые)

```
"First Blood" - Kill first enemy
"Centurion" - Kill 100 enemies
"Slayer" - Kill 1,000 enemies
"God of War" - Kill 10,000 enemies

"Headshot Master" - 1,000 headshots
"Melee Specialist" - 500 melee kills
"Hacker Elite" - Hack 100 enemies

"Raid Clearer" - Complete first raid
"Raid Master" - Complete all raids
```

### 2. Exploration (Исследование)

```
"Tourist" - Visit all Night City districts
"Globetrotter" - Visit all regions (Night City, Tokyo, Europe, Badlands)
"Explorer" - Discover 100 locations
"Cartographer" - Discover all locations

"Fast Travel Unlocked" - Unlock 50 fast travel points
```

### 3. Economic (Экономические)

```
"First Sale" - Sell first item on auction
"Merchant" - Sell 100 items
"Trading Tycoon" - Sell items worth 1M eddies

"Investor" - Buy first stock
"Portfolio Manager" - Own 10 different stocks
"Warren Buffett" - Portfolio value 10M eddies

"Penny Pincher" - Save 100k eddies
"Millionaire" - Have 1M eddies
"Billionaire" - Have 1B eddies (insane goal!)
```

### 4. Social (Социальные)

```
"Friendly" - Add 10 friends
"Popular" - Add 50 friends
"Social Butterfly" - Add 100 friends

"Guild Member" - Join a guild
"Guild Leader" - Create a guild
"Guild Master" - Lead guild to rank 10

"Mentor" - Train 5 apprentices
"Master Teacher" - Train 50 apprentices
```

### 5. Quests (Квестовые)

```
"Quest Beginner" - Complete first quest
"Quest Enthusiast" - Complete 50 quests
"Quest Master" - Complete 500 quests

"Main Story" - Complete main questline
"Side Quest Completionist" - Complete all side quests

"Choices Matter" - Make 100 quest choices
"Butterfly Effect" - Trigger major world event through choices
```

### 6. Progression (Прокачка)

```
"Leveled Up" - Reach level 10
"Veteran" - Reach level 30
"Legend" - Reach level 50
"Max Level" - Reach level cap

"Skilled" - Max out one skill
"Jack of All Trades" - Level 10 in all skills
"Master of All" - Max all skills

"Implanted" - Install first implant
"Cyborg" - Install 10 implants
"Full Chrome" - Fill all implant slots
```

### 7. PvP (Киберспортивные)

```
"First Victory" - Win first PvP match
"Gladiator" - Win 100 PvP matches
"Champion" - Reach top 100 in ranked

"Killstreak" - Get 10 kills without dying
"Ace" - Get 5 kills in one round
"MVP" - Be MVP 50 times
```

### 8. Special (Специальные)

```
"Early Adopter" - Play during beta
"Founder" - Support game at launch
"Veteran Player" - Play for 1 year

"Bug Hunter" - Report 10 bugs
"Community Hero" - Help 50 new players

"Lucky" - Win lottery jackpot
"Collector" - Collect all legendary items
```

---

## 🎯 Типы достижений

### Standard Achievements

**Описание:** Обычные достижения (можно разблокировать один раз)

**Пример:**
```
Achievement: "First Blood"
Description: "Kill your first enemy"
Type: STANDARD
Reward: 100 eddies + title "Rookie"
Points: 10
```

### Progressive Achievements

**Описание:** Многоуровневые достижения

**Пример:**
```
Achievement: "Killer" (5 tiers)

Tier 1: Kill 10 enemies (Novice Killer)
Tier 2: Kill 100 enemies (Killer)
Tier 3: Kill 1,000 enemies (Master Killer)
Tier 4: Kill 5,000 enemies (Elite Killer)
Tier 5: Kill 10,000 enemies (Legendary Killer)

Each tier: Better rewards
```

### Secret Achievements

**Описание:** Скрытые достижения (не показывают условия)

**Пример:**
```
Achievement: "???"
Description: "???"
Hint: "Do something unexpected..."

Actual: "Betray both Arasaka and Militech in quest"
Unlocks when done: "Double Agent" achievement revealed
```

### Limited-Time Achievements

**Описание:** Временные достижения (события)

**Пример:**
```
Achievement: "Halloween 2077"
Available: October 25-31 only
Description: "Complete Halloween event"
Reward: Exclusive skin
```

---

## 📊 Progress Tracking

### Auto-tracking

**Механика:**
```
System automatically tracks:
- Kills (enemy type, total, method)
- Quests completed
- Money earned
- Items sold
- Locations discovered
- Etc.

When threshold reached:
→ Achievement unlocked!
→ Notification shown
→ Reward granted
```

### Manual tracking

**Механика:**
```
Special achievements require manual check:
- "Make specific choice in quest"
- "Don't use fast travel for 10 hours"
- "Complete raid without dying"

System checks conditions on specific events
```

---

## 🎁 Rewards

### Reward Types

**1. Achievement Points:**
```
Each achievement: 10-100 points
Total points: Public display (bragging rights)
Leaderboard: Top achievement hunters
```

**2. Titles:**
```
"The Legendary"
"Merchant Prince"
"PvP Champion"

Display above character name
```

**3. Cosmetics:**
```
Exclusive skins
Emotes
Decorations
Mount skins (if mounts exist)
```

**4. Currency:**
```
Eddies: 100-10,000
Premium currency: 10-100 (rare)
```

**5. Items:**
```
Unique weapons (cosmetic variants)
Special implants
Consumables
```

**6. Stats/Perks:**
```
+1% XP gain (permanent)
+50 max inventory slots
Exclusive fast travel point
```

---

## 🔔 Notifications

### Achievement Unlocked

**UI:**
```
┌─────────────────────────────────────┐
│ 🏆 ACHIEVEMENT UNLOCKED!            │
├─────────────────────────────────────┤
│                                     │
│         [TROPHY ICON]               │
│                                     │
│ "First Blood"                       │
│ Kill your first enemy               │
│                                     │
│ Reward: 100 eddies + "Rookie" title │
│ Achievement Points: +10             │
│                                     │
│ [View All Achievements]             │
└─────────────────────────────────────┘

Animation: Trophy pops up, shines, sound effect
```

### Progress Notification

```
Progress: "Centurion" (Kill 100 enemies)
Current: 95/100 (95%)

→ Show progress bar when approaching (90%+)
→ Build anticipation for unlock
```

---

## 📊 Структура БД

### Achievements Definition

```sql
CREATE TABLE achievements (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    
    achievement_type VARCHAR(20) NOT NULL, -- "STANDARD", "PROGRESSIVE", "SECRET", "LIMITED_TIME"
    
    -- Условия
    requirements JSONB NOT NULL,
    -- {type: "KILL_COUNT", target: "enemy", count: 100}
    
    -- Награды
    rewards JSONB NOT NULL,
    -- {points: 10, eddies: 100, title: "Rookie"}
    
    -- Progressive
    tier INTEGER DEFAULT 1,
    parent_achievement_id VARCHAR(100), -- For progressive
    
    -- Secret
    is_secret BOOLEAN DEFAULT FALSE,
    hint TEXT,
    
    -- Limited-time
    available_from TIMESTAMP,
    available_to TIMESTAMP,
    
    -- Display
    icon VARCHAR(200),
    rarity VARCHAR(20), -- "COMMON", "RARE", "EPIC", "LEGENDARY"
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_achievements_category ON achievements(category);
CREATE INDEX idx_achievements_type ON achievements(achievement_type);
CREATE INDEX idx_achievements_rarity ON achievements(rarity);
```

### Player Achievements

```sql
CREATE TABLE player_achievements (
    player_id UUID NOT NULL,
    achievement_id VARCHAR(100) NOT NULL,
    
    -- Progress
    current_progress INTEGER DEFAULT 0,
    required_progress INTEGER NOT NULL,
    progress_percent DECIMAL(5,2) DEFAULT 0,
    
    -- Status
    is_unlocked BOOLEAN DEFAULT FALSE,
    unlocked_at TIMESTAMP,
    
    -- Reward claimed
    reward_claimed BOOLEAN DEFAULT FALSE,
    claimed_at TIMESTAMP,
    
    -- Tracking
    first_progress_at TIMESTAMP,
    last_progress_at TIMESTAMP,
    
    PRIMARY KEY (player_id, achievement_id),
    
    CONSTRAINT fk_player_achievement_player FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_achievement_def FOREIGN KEY (achievement_id) REFERENCES achievements(id)
);

CREATE INDEX idx_player_achievements_unlocked ON player_achievements(player_id, is_unlocked);
CREATE INDEX idx_player_achievements_progress ON player_achievements(player_id) WHERE is_unlocked = FALSE;
```

### Achievement Tracking Events

```sql
CREATE TABLE achievement_tracking_events (
    id BIGSERIAL PRIMARY KEY,
    player_id UUID NOT NULL,
    
    event_type VARCHAR(50) NOT NULL, -- "KILL", "QUEST_COMPLETE", "ITEM_SELL"
    event_data JSONB NOT NULL,
    
    -- Achievements affected
    achievements_progressed JSONB, -- List of achievement IDs that progressed
    achievements_unlocked JSONB, -- List of achievement IDs unlocked
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_achievement_events_player ON achievement_tracking_events(player_id, created_at DESC);
```

---

## 🔗 API Endpoints

```
GET    /achievements                 - List all achievements
GET    /achievements/{id}             - Achievement details
GET    /achievements/player/{playerId} - Player's achievements
POST   /achievements/claim-reward     - Claim achievement reward

GET    /achievements/leaderboard      - Top achievement hunters
GET    /achievements/categories       - Categories with counts

WS     /achievements/live             - Real-time achievement unlocks
```

---

## 🎮 Примеры

### Пример 1: Simple Achievement

```
Kill first enemy:
→ Event: ENEMY_KILLED
→ Check: achievements requiring kills
→ "First Blood": 1/1 → UNLOCKED!
→ Notification shown
→ Reward granted: 100 eddies + title
```

### Пример 2: Progressive Achievement

```
"Centurion" (Kill 100 enemies)

Current: 0/100
Kill 1st: 1/100 (1%)
Kill 10th: 10/100 (10%)
Kill 50th: 50/100 (50%)
Kill 90th: 90/100 (90%) ← Show "almost there!" notification
Kill 100th: 100/100 → UNLOCKED!
```

### Пример 3: Secret Achievement

```
Achievement: "???" (secret)
Hint: "Try something unusual in Corpo Plaza..."

Actual: "Jump from top of Arasaka Tower and survive"

Player does it:
→ Achievement revealed: "Leap of Faith"
→ Reward: Special emote "Swan Dive"
→ Points: 50 (rare achievement!)
```

---

## 🔗 Связанные документы

- `leaderboard-system.md` - Рейтинги

---

## История изменений

- v1.0.0 (2025-11-06 23:00) - Создание системы достижений

