---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 02:30  
**api-readiness-notes:** Battle Pass System. Сезонный прогресс, бесплатный/премиум треки, rewards. ~390 строк.
---

# Battle Pass System - Боевой пропуск

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07 02:30  
**Приоритет:** HIGH (Monetization + Engagement!)  
**Автор:** AI Brain Manager

**Микрофича:** Battle pass core mechanics  
**Размер:** ~390 строк ✅

---

## Краткое описание

**Battle Pass System** - сезонная система прогресса с наградами для retention и monetization.

**Ключевые возможности:**
- ✅ Free Track (бесплатный трек) - все игроки
- ✅ Premium Track (премиум трек) - за покупку
- ✅ 100 Levels прогресса
- ✅ Unique Rewards (эксклюзивные награды)
- ✅ Weekly Challenges (еженедельные задания)
- ✅ Season Duration (3 месяца)

---

## Архитектура системы

```
Player completes actions
    ↓
Earn Battle Pass XP
    ↓
Level Up (1-100)
    ↓
Unlock Rewards (Free/Premium tracks)
    ↓
Claim Rewards
    ↓
Season Ends → New Season
```

---

## Battle Pass Structure

### Dual Track System

```
Level 1  [Free: 100 Eddies]      [Premium: Legendary Skin]
Level 2  [Free: ---]             [Premium: 500 Eddies]
Level 3  [Free: Rare Item]       [Premium: Epic Item]
Level 4  [Free: ---]             [Premium: XP Boost +10%]
Level 5  [Free: 200 Eddies]      [Premium: Legendary Weapon]
...
Level 50 [Free: Epic Item]       [Premium: Exclusive Mount]
...
Level 100 [Free: Legendary]      [Premium: Ultimate Reward]
```

**Rewards pattern:**
- Free track: rewards every 5 levels
- Premium track: rewards every level
- Milestone rewards: 25, 50, 75, 100

---

## Database Schema

### Таблица `battle_pass_seasons`

```sql
CREATE TABLE battle_pass_seasons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Season info
    season_number INTEGER UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    theme VARCHAR(100),
    description TEXT,
    
    -- Duration
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    
    -- Levels
    max_level INTEGER DEFAULT 100,
    xp_per_level INTEGER DEFAULT 1000,
    
    -- Pricing
    premium_price INTEGER NOT NULL,
    premium_currency VARCHAR(20) DEFAULT 'PREMIUM',
    
    -- Status
    status VARCHAR(20) DEFAULT 'SCHEDULED',
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_battle_pass_status ON battle_pass_seasons(status);
CREATE INDEX idx_battle_pass_dates ON battle_pass_seasons(start_date, end_date);
```

### Таблица `battle_pass_rewards`

```sql
CREATE TABLE battle_pass_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    season_id UUID NOT NULL,
    
    -- Level
    level INTEGER NOT NULL,
    
    -- Track
    track VARCHAR(20) NOT NULL,
    
    -- Reward
    reward_type VARCHAR(50) NOT NULL,
    reward_data JSONB NOT NULL,
    
    -- Display
    display_name VARCHAR(200),
    icon VARCHAR(255),
    rarity VARCHAR(20),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_bp_reward_season FOREIGN KEY (season_id) 
        REFERENCES battle_pass_seasons(id) ON DELETE CASCADE,
    UNIQUE(season_id, level, track)
);

CREATE INDEX idx_bp_rewards_season_level ON battle_pass_rewards(season_id, level);
```

### Таблица `player_battle_pass_progress`

```sql
CREATE TABLE player_battle_pass_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    season_id UUID NOT NULL,
    
    -- Progress
    current_level INTEGER DEFAULT 1,
    current_xp INTEGER DEFAULT 0,
    total_xp_earned INTEGER DEFAULT 0,
    
    -- Premium status
    has_premium BOOLEAN DEFAULT FALSE,
    premium_purchased_at TIMESTAMP,
    
    -- Claimed rewards
    claimed_free_levels INTEGER[] DEFAULT '{}',
    claimed_premium_levels INTEGER[] DEFAULT '{}',
    
    -- Timestamps
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_xp_earned_at TIMESTAMP,
    
    CONSTRAINT fk_bp_progress_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_bp_progress_season FOREIGN KEY (season_id) 
        REFERENCES battle_pass_seasons(id) ON DELETE CASCADE,
    
    UNIQUE(player_id, season_id)
);

CREATE INDEX idx_bp_progress_player ON player_battle_pass_progress(player_id);
CREATE INDEX idx_bp_progress_season ON player_battle_pass_progress(season_id);
```

---

## XP Earning System

### XP Sources

```java
public enum BattlePassXPSource {
    DAILY_QUEST(100),           // За daily quest
    WEEKLY_CHALLENGE(500),      // За weekly challenge
    MATCH_WIN(50),              // За победу в матче
    MATCH_PLAYED(25),           // За участие
    QUEST_COMPLETE(200),        // За квест
    ACHIEVEMENT_UNLOCK(150),    // За достижение
    PLAYTIME(10);              // За час игры
    
    private final int baseXP;
}
```

### Award XP

```java
@Service
public class BattlePassService {
    
    public void awardXP(UUID playerId, BattlePassXPSource source, int multiplier) {
        // Get current season
        BattlePassSeason season = getCurrentSeason();
        
        // Get or create progress
        PlayerBattlePassProgress progress = getOrCreateProgress(playerId, season.getId());
        
        // Calculate XP
        int xpEarned = source.getBaseXP() * multiplier;
        
        // Add XP
        progress.setCurrentXP(progress.getCurrentXP() + xpEarned);
        progress.setTotalXPEarned(progress.getTotalXPEarned() + xpEarned);
        progress.setLastXPEarnedAt(Instant.now());
        
        // Check for level ups
        int xpPerLevel = season.getXpPerLevel();
        while (progress.getCurrentXP() >= xpPerLevel && 
               progress.getCurrentLevel() < season.getMaxLevel()) {
            
            // Level up!
            progress.setCurrentLevel(progress.getCurrentLevel() + 1);
            progress.setCurrentXP(progress.getCurrentXP() - xpPerLevel);
            
            // Notify player
            notifyLevelUp(playerId, progress.getCurrentLevel());
            
            // Track analytics
            analyticsService.trackBattlePassLevelUp(playerId, progress.getCurrentLevel());
        }
        
        progressRepository.save(progress);
        
        // Publish event
        eventBus.publish(new BattlePassXPEarnedEvent(playerId, xpEarned));
        
        log.info("Battle Pass XP awarded: player={}, source={}, xp={}", 
            playerId, source, xpEarned);
    }
}
```

---

## Claim Rewards

```java
public List<Reward> claimReward(UUID playerId, int level) {
    PlayerBattlePassProgress progress = getProgress(playerId);
    
    // Validate level unlocked
    if (level > progress.getCurrentLevel()) {
        throw new LevelNotUnlockedException(level);
    }
    
    List<Reward> rewards = new ArrayList<>();
    
    // Check free track
    if (!progress.getClaimedFreeLevels().contains(level)) {
        Reward freeReward = getReward(progress.getSeasonId(), level, "FREE");
        if (freeReward != null) {
            grantReward(playerId, freeReward);
            rewards.add(freeReward);
            
            // Mark as claimed
            progress.getClaimedFreeLevels().add(level);
        }
    }
    
    // Check premium track
    if (progress.isHasPremium() && 
        !progress.getClaimedPremiumLevels().contains(level)) {
        
        Reward premiumReward = getReward(progress.getSeasonId(), level, "PREMIUM");
        if (premiumReward != null) {
            grantReward(playerId, premiumReward);
            rewards.add(premiumReward);
            
            // Mark as claimed
            progress.getClaimedPremiumLevels().add(level);
        }
    }
    
    progressRepository.save(progress);
    
    return rewards;
}
```

---

## Premium Purchase

```java
public void purchasePremium(UUID playerId) {
    PlayerBattlePassProgress progress = getProgress(playerId);
    BattlePassSeason season = seasonRepository.findById(progress.getSeasonId())
        .orElseThrow();
    
    // Check if already purchased
    if (progress.isHasPremium()) {
        throw new AlreadyPurchasedException();
    }
    
    // Check currency
    if (!hasPremiumCurrency(playerId, season.getPremiumPrice())) {
        throw new InsufficientCurrencyException();
    }
    
    // Deduct currency
    deductPremiumCurrency(playerId, season.getPremiumPrice());
    
    // Grant premium
    progress.setHasPremium(true);
    progress.setPremiumPurchasedAt(Instant.now());
    
    progressRepository.save(progress);
    
    // Notify player
    notificationService.send(playerId, 
        new BattlePassPremiumUnlockedNotification(season));
    
    // Analytics
    analyticsService.trackBattlePassPurchase(playerId, season.getId());
    
    log.info("Battle Pass premium purchased: player={}, season={}", 
        playerId, season.getId());
}
```

---

## Weekly Challenges

```java
@Service
public class BattlePassChallengeService {
    
    public List<BattlePassChallenge> generateWeeklyChallenges(UUID seasonId) {
        List<BattlePassChallenge> challenges = new ArrayList<>();
        
        // Generate 5 challenges
        challenges.add(createChallenge("Play 10 matches", 500));
        challenges.add(createChallenge("Complete 5 daily quests", 750));
        challenges.add(createChallenge("Earn 50,000 eddies", 1000));
        challenges.add(createChallenge("Win 5 arena matches", 1250));
        challenges.add(createChallenge("Complete 3 main quests", 1500));
        
        return challenges;
    }
    
    public void completeChallenge(UUID playerId, UUID challengeId) {
        BattlePassChallenge challenge = challengeRepository.findById(challengeId)
            .orElseThrow();
        
        // Award XP
        awardXP(playerId, BattlePassXPSource.WEEKLY_CHALLENGE, challenge.getXpReward());
        
        // Mark complete
        markChallengeComplete(playerId, challengeId);
        
        // Achievement
        achievementService.trackProgress(playerId, "weekly_challenge_complete", Map.of());
    }
}
```

---

## API Endpoints

**GET `/api/v1/battle-pass/current`** - текущий сезон

```json
Response:
{
  "seasonId": "uuid",
  "seasonNumber": 1,
  "name": "Season 1: Night City Legends",
  "theme": "Corpo Wars",
  "startDate": "2025-12-01T00:00:00Z",
  "endDate": "2026-03-01T00:00:00Z",
  "daysRemaining": 85,
  "maxLevel": 100,
  "premiumPrice": 1000
}
```

**GET `/api/v1/battle-pass/progress`** - прогресс игрока

```json
Response:
{
  "playerId": "uuid",
  "seasonId": "uuid",
  "currentLevel": 42,
  "currentXP": 750,
  "xpToNextLevel": 250,
  "totalXPEarned": 42750,
  "hasPremium": true,
  "claimedRewards": {
    "free": [1, 2, 3, 5, 10, 15, 20, 25, 30, 35, 40],
    "premium": [1, 2, 3, 4, 5, ..., 42]
  },
  "unclaimedRewards": {
    "free": [],
    "premium": []
  }
}
```

**POST `/api/v1/battle-pass/claim/{level}`** - claim reward

**POST `/api/v1/battle-pass/purchase-premium`** - купить premium

**GET `/api/v1/battle-pass/challenges/weekly`** - weekly challenges

---

## Reward Types

```json
{
  "type": "CURRENCY",
  "data": {"currency": "EDDIES", "amount": 1000}
}

{
  "type": "ITEM",
  "data": {"itemId": "LEGENDARY_WEAPON_001", "quantity": 1}
}

{
  "type": "COSMETIC",
  "data": {"cosmeticId": "SKIN_SEASON1_EXCLUSIVE"}
}

{
  "type": "XP_BOOST",
  "data": {"percentage": 10, "duration": "7d"}
}

{
  "type": "TITLE",
  "data": {"titleCode": "SEASON_1_CHAMPION"}
}

{
  "type": "EMOTE",
  "data": {"emoteId": "VICTORY_DANCE_01"}
}
```

---

## Season Progression

### XP Requirements

```java
// Linear progression
Level 1-50:   1000 XP per level = 50,000 total
Level 51-75:  1500 XP per level = 37,500 total
Level 76-100: 2000 XP per level = 50,000 total

Total XP for level 100: 137,500 XP
```

### Time Estimates

```
Casual player (1h/day):
- 500 XP per day
- 275 days to reach level 100 (without boosts)
- Season: 90 days → Level ~32

Active player (3h/day):
- 1500 XP per day
- 92 days to reach level 100
- Season: 90 days → Level ~98

Hardcore player (6h/day):
- 3000 XP per day
- 46 days to reach level 100
- Season: 90 days → Level 100 (with time to spare)
```

---

## Premium Benefits

### What Premium Gives

```
1. Premium Rewards Track
   - Exclusive skins/items/cosmetics
   - 3x more rewards than free

2. XP Boosts
   - +10% XP boost (permanent for season)
   - Faster progression

3. Exclusive Cosmetics
   - Legendary skins
   - Exclusive emotes
   - Unique titles

4. Early Access
   - New features/content
   - Beta testing

5. Support Development
   - Help fund game development
```

---

## Weekly Challenges

```json
{
  "weekNumber": 5,
  "startDate": "2025-11-04T00:00:00Z",
  "endDate": "2025-11-11T00:00:00Z",
  
  "challenges": [
    {
      "id": "uuid",
      "description": "Play 10 matches",
      "progress": 7,
      "target": 10,
      "xpReward": 500,
      "completed": false
    },
    {
      "id": "uuid",
      "description": "Complete 5 daily quests",
      "progress": 5,
      "target": 5,
      "xpReward": 750,
      "completed": true
    },
    {
      "id": "uuid",
      "description": "Earn 50,000 eddies",
      "progress": 42000,
      "target": 50000,
      "xpReward": 1000,
      "completed": false
    }
  ]
}
```

---

## Season End & Rollover

### End of Season

```java
@Scheduled(cron = "0 0 0 1 * *") // 1st of month
public void checkSeasonEnd() {
    List<BattlePassSeason> endingSeasons = seasonRepository
        .findByEndDateAndStatus(LocalDate.now(), SeasonStatus.ACTIVE);
    
    for (BattlePassSeason season : endingSeasons) {
        endSeason(season);
    }
}

private void endSeason(BattlePassSeason season) {
    log.info("Ending Battle Pass season: {}", season.getId());
    
    // 1. Finalize player progress
    List<PlayerBattlePassProgress> allProgress = progressRepository
        .findBySeason(season.getId());
    
    for (PlayerBattlePassProgress progress : allProgress) {
        finalizePlayerProgress(progress);
    }
    
    // 2. Mark season complete
    season.setStatus(SeasonStatus.COMPLETED);
    seasonRepository.save(season);
    
    // 3. Archive old season data
    archiveSeasonData(season.getId());
    
    // 4. Start new season (if scheduled)
    startNewSeasonIfScheduled();
    
    log.info("Season ended: {}", season.getId());
}

private void finalizePlayerProgress(PlayerBattlePassProgress progress) {
    // Save final stats
    BattlePassStats stats = new BattlePassStats();
    stats.setPlayerId(progress.getPlayerId());
    stats.setSeasonId(progress.getSeasonId());
    stats.setFinalLevel(progress.getCurrentLevel());
    stats.setTotalXPEarned(progress.getTotalXPEarned());
    stats.setHadPremium(progress.isHasPremium());
    
    statsRepository.save(stats);
    
    // Award season completion rewards
    if (progress.getCurrentLevel() >= 100) {
        grantSeasonCompletionReward(progress.getPlayerId());
    }
}
```

---

## Связанные документы

- [Daily Reset System](../daily-reset/daily-reset-compact.md)
- [Achievement System](../achievement/achievement-core.md)
- [Premium Currency System](../../economy/premium-currency.md)

