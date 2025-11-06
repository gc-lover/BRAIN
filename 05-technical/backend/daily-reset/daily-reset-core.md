---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 01:59  
**api-readiness-notes:** Daily Reset System. Ежедневный сброс лимитов, daily quests, rewards. ~390 строк.
---

# Daily Reset System - Core System

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07 01:59  
**Приоритет:** HIGH (ENGAGEMENT!)  
**Автор:** AI Brain Manager

**Микрофича:** Daily reset mechanics  
**Размер:** ~390 строк ✅

---

## Краткое описание

**Daily Reset System** - система ежедневного сброса для поддержания engagement и создания рутины для игроков.

**Ключевые возможности:**
- ✅ Daily Quest reset (ежедневные квесты)
- ✅ Daily Limits reset (лимиты на активности)
- ✅ Daily Rewards (ежедневные награды)
- ✅ Login Streak tracking (серии входов)
- ✅ Weekly/Monthly resets (недельные/месячные)
- ✅ Timezone support (по часовым поясам)

---

## Архитектура системы

```
Scheduled Job (00:00 server time)
    ↓
Daily Reset Service
    ↓
Reset Daily Quests
Reset Daily Limits
Reset Daily Rewards
Check Login Streaks
    ↓
Publish Events
    ↓
Notify Players (if online)
```

---

## Что сбрасывается ежедневно

### 1. Daily Quests (Ежедневные квесты)

**Механика:**
```
00:00 Server Time:
- Old daily quests → abandoned/expired
- New daily quests → generated for all players
```

**Типы:**
- Combat dailies (kill 50 enemies)
- Craft dailies (craft 10 items)
- Social dailies (help 3 players)
- Economy dailies (trade 5 items)

**Rewards:**
- Experience (500-2000 XP)
- Currency (100-500 eddies)
- Reputation (+50-200)
- Daily tokens (для daily shop)

---

### 2. Daily Limits (Лимиты активностей)

**Что ограничивается:**
```
Dungeon runs: 5/day
Arena matches: 10/day
Boss kills (specific): 3/day
Daily shop purchases: 3/day
Crafting rare items: 5/day
Guild donations: 1/day
```

**Reset:**
```sql
UPDATE player_daily_limits
SET current_count = 0
WHERE reset_date < CURRENT_DATE;
```

---

### 3. Daily Rewards (Ежедневные награды)

**Login rewards (за вход):**
```
Day 1: 100 eddies
Day 2: 200 eddies
Day 3: 300 eddies + 1 rare item
Day 4: 400 eddies
Day 5: 500 eddies + 1 epic item
Day 6: 600 eddies
Day 7: 1000 eddies + 1 legendary item
```

**Streak bonus:**
```
7-day streak: +500 bonus eddies
30-day streak: +5000 eddies + exclusive title
100-day streak: +legendary mount
```

---

### 4. Weekly Resets (Недельные)

**Что сбрасывается еженедельно (Monday 00:00):**
- Weekly quests
- Weekly dungeon lockouts
- Weekly raid resets
- Weekly arena rankings
- Weekly guild activities

---

### 5. Monthly Resets (Месячные)

**Что сбрасывается ежемесячно (1st day 00:00):**
- Monthly quests
- Seasonal rankings
- Monthly shop rotation
- Monthly events

---

## Database Schema

### Таблица `daily_reset_config`

```sql
CREATE TABLE daily_reset_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reset type
    reset_type VARCHAR(50) NOT NULL,
    reset_frequency VARCHAR(20) NOT NULL,
    
    -- Schedule
    reset_time TIME DEFAULT '00:00:00',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- For weekly/monthly
    reset_day_of_week INTEGER,
    reset_day_of_month INTEGER,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_reset_at TIMESTAMP,
    next_reset_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reset_config_next_reset 
    ON daily_reset_config(next_reset_at) 
    WHERE is_active = TRUE;
```

### Таблица `player_daily_quests`

```sql
CREATE TABLE player_daily_quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    quest_id UUID NOT NULL,
    
    -- Assignment
    assigned_date DATE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE',
    progress INTEGER DEFAULT 0,
    max_progress INTEGER NOT NULL,
    
    -- Completion
    completed_at TIMESTAMP,
    rewards_claimed BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_daily_quest_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, quest_id, assigned_date)
);

CREATE INDEX idx_daily_quests_player_date 
    ON player_daily_quests(player_id, assigned_date);
CREATE INDEX idx_daily_quests_expires 
    ON player_daily_quests(expires_at) 
    WHERE status = 'ACTIVE';
```

### Таблица `player_daily_limits`

```sql
CREATE TABLE player_daily_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    
    -- Limit type
    limit_type VARCHAR(50) NOT NULL,
    
    -- Limits
    max_count INTEGER NOT NULL,
    current_count INTEGER DEFAULT 0,
    
    -- Reset
    reset_date DATE NOT NULL,
    
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_daily_limit_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, limit_type, reset_date)
);

CREATE INDEX idx_daily_limits_player_type 
    ON player_daily_limits(player_id, limit_type);
CREATE INDEX idx_daily_limits_reset 
    ON player_daily_limits(reset_date);
```

### Таблица `player_login_streak`

```sql
CREATE TABLE player_login_streak (
    player_id UUID PRIMARY KEY,
    
    -- Current streak
    current_streak INTEGER DEFAULT 0,
    last_login_date DATE,
    
    -- Records
    longest_streak INTEGER DEFAULT 0,
    total_logins INTEGER DEFAULT 0,
    
    -- Rewards
    next_reward_day INTEGER DEFAULT 1,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_login_streak_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_login_streak_last_login 
    ON player_login_streak(last_login_date);
```

---

## Daily Reset Job

### Main Reset Service

```java
@Service
public class DailyResetService {
    
    @Scheduled(cron = "0 0 0 * * *") // 00:00 every day
    public void executeDailyReset() {
        log.info("Starting daily reset...");
        
        Instant startTime = Instant.now();
        
        try {
            // 1. Reset daily quests
            resetDailyQuests();
            
            // 2. Reset daily limits
            resetDailyLimits();
            
            // 3. Generate new daily quests
            generateDailyQuests();
            
            // 4. Update login streaks (mark missed days)
            updateLoginStreaks();
            
            // 5. Reset daily shops
            resetDailyShops();
            
            // 6. Cleanup expired data
            cleanupExpiredData();
            
            // 7. Publish event
            eventBus.publish(new DailyResetCompletedEvent(
                LocalDate.now()
            ));
            
            Instant endTime = Instant.now();
            long duration = Duration.between(startTime, endTime).toMillis();
            
            log.info("Daily reset completed in {}ms", duration);
            
        } catch (Exception e) {
            log.error("Daily reset failed", e);
            alertAdmins("Daily reset failed: " + e.getMessage());
        }
    }
    
    private void resetDailyQuests() {
        // Expire old dailies
        int expired = dailyQuestRepository.expireOldQuests(LocalDate.now());
        log.info("Expired {} daily quests", expired);
    }
    
    private void resetDailyLimits() {
        // Reset all limits to 0
        int reset = dailyLimitRepository.resetAllLimits(LocalDate.now());
        log.info("Reset {} daily limits", reset);
    }
    
    private void generateDailyQuests() {
        // Get all active players (logged in last 30 days)
        List<Player> activePlayers = playerRepository
            .findActivePlayers(30);
        
        for (Player player : activePlayers) {
            // Generate 5 daily quests per player
            List<DailyQuest> quests = dailyQuestGenerator
                .generate(player, 5);
            
            for (DailyQuest quest : quests) {
                createPlayerDailyQuest(player.getId(), quest);
            }
        }
        
        log.info("Generated daily quests for {} players", activePlayers.size());
    }
}
```

---

## Login Streak System

### Track Login

```java
@Service
public class LoginStreakService {
    
    public void trackLogin(UUID playerId) {
        PlayerLoginStreak streak = streakRepository
            .findById(playerId)
            .orElseGet(() -> createNewStreak(playerId));
        
        LocalDate today = LocalDate.now();
        LocalDate lastLogin = streak.getLastLoginDate();
        
        // Already logged in today
        if (today.equals(lastLogin)) {
            return;
        }
        
        // Check if consecutive
        if (lastLogin != null && today.equals(lastLogin.plusDays(1))) {
            // Streak continues!
            streak.setCurrentStreak(streak.getCurrentStreak() + 1);
        } else {
            // Streak broken
            if (streak.getCurrentStreak() > streak.getLongestStreak()) {
                streak.setLongestStreak(streak.getCurrentStreak());
            }
            streak.setCurrentStreak(1); // Reset to 1
        }
        
        streak.setLastLoginDate(today);
        streak.setTotalLogins(streak.getTotalLogins() + 1);
        
        streakRepository.save(streak);
        
        // Check for streak milestones
        checkStreakMilestones(playerId, streak.getCurrentStreak());
        
        // Grant login reward
        grantLoginReward(playerId, streak.getCurrentStreak());
    }
    
    private void checkStreakMilestones(UUID playerId, int streak) {
        if (streak == 7) {
            grantReward(playerId, REWARD_7_DAY_STREAK);
            achievementService.unlock(playerId, "ACH_LOGIN_STREAK_7");
        } else if (streak == 30) {
            grantReward(playerId, REWARD_30_DAY_STREAK);
            achievementService.unlock(playerId, "ACH_LOGIN_STREAK_30");
        } else if (streak == 100) {
            grantReward(playerId, REWARD_100_DAY_STREAK);
            achievementService.unlock(playerId, "ACH_LOGIN_STREAK_100");
        }
    }
}
```

---

## Daily Quest Generation

### Quest Pool

```java
public class DailyQuestGenerator {
    
    public List<DailyQuest> generate(Player player, int count) {
        List<DailyQuest> quests = new ArrayList<>();
        
        // Get quest pool for player level
        List<DailyQuestTemplate> pool = getQuestPool(player.getLevel());
        
        // Select diverse quests (1 combat, 1 craft, 1 social, 2 random)
        quests.add(selectQuest(pool, "COMBAT"));
        quests.add(selectQuest(pool, "CRAFT"));
        quests.add(selectQuest(pool, "SOCIAL"));
        quests.add(selectQuest(pool, "RANDOM"));
        quests.add(selectQuest(pool, "RANDOM"));
        
        // Customize rewards based on level
        for (DailyQuest quest : quests) {
            customizeRewards(quest, player.getLevel());
        }
        
        return quests;
    }
    
    private DailyQuest selectQuest(List<DailyQuestTemplate> pool, String category) {
        // Filter by category
        List<DailyQuestTemplate> filtered = pool.stream()
            .filter(q -> category.equals("RANDOM") || q.getCategory().equals(category))
            .collect(Collectors.toList());
        
        // Random selection
        DailyQuestTemplate template = filtered.get(
            random.nextInt(filtered.size())
        );
        
        return instantiateQuest(template);
    }
}
```

### Quest Templates

```json
{
  "id": "DAILY_COMBAT_01",
  "name": "Street Cleaner",
  "description": "Eliminate 50 gang members in Night City",
  "category": "COMBAT",
  "level_range": [10, 50],
  
  "objectives": [
    {
      "type": "kill_count",
      "target": {"enemy_faction": "GANG", "count": 50},
      "progress_tracking": "automatic"
    }
  ],
  
  "rewards": {
    "experience": 1000,
    "eddies": 500,
    "reputation": {"faction": "NCPD", "amount": 100},
    "daily_tokens": 1
  },
  
  "time_limit": "24h"
}
```

---

## Daily Limit System

### Limit Types

```java
public enum DailyLimitType {
    DUNGEON_RUNS("dungeon_runs", 5),
    ARENA_MATCHES("arena_matches", 10),
    BOSS_KILLS("boss_kills", 3),
    DAILY_SHOP("daily_shop_purchases", 3),
    RARE_CRAFTS("rare_crafting", 5),
    GUILD_DONATIONS("guild_donations", 1),
    DAILY_QUEST_REROLLS("quest_rerolls", 2);
    
    private final String code;
    private final int maxCount;
}
```

### Check Limit

```java
@Service
public class DailyLimitService {
    
    public boolean canPerformAction(UUID playerId, DailyLimitType limitType) {
        PlayerDailyLimit limit = getLimitOrCreate(playerId, limitType);
        
        return limit.getCurrentCount() < limit.getMaxCount();
    }
    
    public void incrementLimit(UUID playerId, DailyLimitType limitType) {
        PlayerDailyLimit limit = getLimitOrCreate(playerId, limitType);
        
        if (limit.getCurrentCount() >= limit.getMaxCount()) {
            throw new DailyLimitExceededException(limitType);
        }
        
        limit.setCurrentCount(limit.getCurrentCount() + 1);
        limitRepository.save(limit);
    }
    
    private PlayerDailyLimit getLimitOrCreate(UUID playerId, DailyLimitType limitType) {
        LocalDate today = LocalDate.now();
        
        return limitRepository
            .findByPlayerAndTypeAndDate(playerId, limitType.getCode(), today)
            .orElseGet(() -> createNewLimit(playerId, limitType, today));
    }
}
```

---

## Login Reward System

### Daily Login Rewards

```java
@Service
public class LoginRewardService {
    
    public LoginReward claimDailyReward(UUID playerId) {
        PlayerLoginStreak streak = streakRepository.findById(playerId)
            .orElseThrow(() -> new NotFoundException("Streak not found"));
        
        // Check if already claimed today
        if (streak.getLastRewardClaimDate() != null && 
            streak.getLastRewardClaimDate().equals(LocalDate.now())) {
            throw new RewardAlreadyClaimedException();
        }
        
        // Get reward for current day in cycle
        int rewardDay = (streak.getCurrentStreak() - 1) % 7 + 1; // 1-7 cycle
        LoginReward reward = getRewardForDay(rewardDay);
        
        // Grant reward
        rewardService.grant(playerId, reward);
        
        // Update claim date
        streak.setLastRewardClaimDate(LocalDate.now());
        streakRepository.save(streak);
        
        return reward;
    }
    
    private LoginReward getRewardForDay(int day) {
        return switch (day) {
            case 1 -> new LoginReward(100, 0, List.of());
            case 2 -> new LoginReward(200, 0, List.of());
            case 3 -> new LoginReward(300, 0, List.of("RARE_ITEM_RANDOM"));
            case 4 -> new LoginReward(400, 0, List.of());
            case 5 -> new LoginReward(500, 0, List.of("EPIC_ITEM_RANDOM"));
            case 6 -> new LoginReward(600, 0, List.of());
            case 7 -> new LoginReward(1000, 0, List.of("LEGENDARY_ITEM_RANDOM"));
            default -> new LoginReward(100, 0, List.of());
        };
    }
}
```

---

## Timezone Support

### Per-Player Reset Time

```java
@Service
public class TimezoneResetService {
    
    public Instant getNextResetTime(UUID playerId) {
        Player player = playerRepository.findById(playerId);
        
        ZoneId playerTimezone = ZoneId.of(player.getTimezone());
        LocalDate today = LocalDate.now(playerTimezone);
        LocalDate tomorrow = today.plusDays(1);
        
        ZonedDateTime nextReset = tomorrow.atStartOfDay(playerTimezone);
        
        return nextReset.toInstant();
    }
    
    public boolean isAfterReset(UUID playerId, Instant timestamp) {
        Instant lastReset = getLastResetTime(playerId);
        return timestamp.isAfter(lastReset);
    }
}
```

---

## Weekly Reset

### Weekly Reset Job

```java
@Scheduled(cron = "0 0 0 * * MON") // Monday 00:00
public void executeWeeklyReset() {
    log.info("Starting weekly reset...");
    
    // 1. Reset weekly quests
    weeklyQuestRepository.expireAll();
    
    // 2. Reset raid lockouts
    raidLockoutRepository.resetAll();
    
    // 3. Reset weekly limits
    weeklyLimitRepository.resetAll();
    
    // 4. Snapshot weekly leaderboards
    leaderboardService.snapshotWeekly();
    
    // 5. Distribute weekly rewards
    weeklyRewardService.distributeRewards();
    
    // 6. Generate new weekly content
    weeklyContentGenerator.generate();
    
    log.info("Weekly reset completed");
}
```

---

## API Endpoints

**GET `/api/v1/daily/status`** - статус daily resets

```json
Response:
{
  "nextDailyReset": "2025-11-08T00:00:00Z",
  "nextWeeklyReset": "2025-11-11T00:00:00Z",
  "nextMonthlyReset": "2025-12-01T00:00:00Z",
  
  "dailyQuests": {
    "available": 5,
    "completed": 2,
    "expiresIn": "18h 30m"
  },
  
  "dailyLimits": {
    "dungeonRuns": {"current": 3, "max": 5},
    "arenaMatches": {"current": 7, "max": 10},
    "bossKills": {"current": 2, "max": 3}
  },
  
  "loginStreak": {
    "current": 12,
    "longest": 45,
    "nextReward": "Day 13 - 300 eddies"
  }
}
```

**GET `/api/v1/daily/quests`** - daily quests игрока

**POST `/api/v1/daily/rewards/claim`** - claim daily login reward

**GET `/api/v1/daily/limits`** - текущие лимиты

---

## Monitoring

### Metrics

```
daily_reset.duration_ms          - время выполнения reset
daily_reset.quests_generated     - сколько квестов сгенерировано
daily_reset.players_active       - активные игроки
daily_reset.streaks_broken       - сколько серий прервано
daily_reset.longest_streak       - самая длинная серия
```

---

## Связанные документы

- [Achievement System](../achievement/achievement-core.md)
- [Quest System](../../../04-narrative/quests/quest-system.md)
- [Notification System](../notification-system.md)

