---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Matchmaking Rating микрофича. MMR/ELO system, rating tiers, anti-smurf. ~340 строк.
---

# Matchmaking Rating - Рейтинговая система

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:30  
**Приоритет:** критический  
**Автор:** AI Brain Manager

**Микрофича:** MMR/ELO rating system  
**Размер:** ~340 строк ✅

---


**API Tasks Status:**
- 🚫 Документ отмечен как OBSOLETE (устаревшая split версия)
- 📝 Причина: Consolidated into unified document
- 🔄 Статус: not-applicable
- ⚠️ Этот документ является split версией, которая была объединена в consolidated документ

---

## Краткое описание

**Matchmaking Rating** - система рейтингов MMR/ELO для ranked матчей.

**Ключевые возможности:**
- ✅ MMR/ELO calculation
- ✅ Rating tiers (Bronze → Grandmaster)
- ✅ Anti-smurf detection
- ✅ Seasonal ratings

---

## Database Schema

```sql
CREATE TABLE player_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    
    -- MMR
    rating INTEGER DEFAULT 1500,
    peak_rating INTEGER DEFAULT 1500,
    
    -- Stats
    games_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2),
    
    -- Streak
    current_streak INTEGER DEFAULT 0,
    best_win_streak INTEGER DEFAULT 0,
    
    -- Tier
    tier VARCHAR(20), -- BRONZE, SILVER, GOLD, etc
    division INTEGER, -- 1-5
    
    -- League (season)
    league_id VARCHAR(50),
    
    last_game_at TIMESTAMP,
    
    CONSTRAINT fk_rating_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, activity_type, league_id)
);

CREATE INDEX idx_ratings_rating ON player_ratings(rating DESC);
CREATE INDEX idx_ratings_tier ON player_ratings(tier, division);
```

---

## MMR Calculation (Elo Formula)

```
New Rating = Old Rating + K × (Actual Score - Expected Score)

Expected Score = 1 / (1 + 10^((Opponent Rating - Player Rating) / 400))

K-Factor:
- Новички (<30 игр): K = 40
- Обычные: K = 20
- Мастера (>100 игр, rating >2000): K = 10

Actual Score:
- Win: 1.0
- Draw: 0.5
- Loss: 0.0
```

**Example:**
```
Player: 1600, Opponent: 1700
Expected = 1 / (1 + 10^0.25) = 0.36

Win: 1600 + 20 × (1.0 - 0.36) = 1613
Loss: 1600 + 20 × (0.0 - 0.36) = 1593
```

---

## Rating Tiers

```
0-999:     Bronze
1000-1499: Silver
1500-1999: Gold
2000-2499: Platinum
2500-2999: Diamond
3000-3499: Master
3500+:     Grandmaster
```

---

## Anti-Smurf Detection

```java
public boolean isSmurf(UUID playerId) {
    PlayerRating rating = ratingRepository.findByPlayer(playerId);
    
    // Высокий win rate в первых 10 играх
    if (rating.getGamesPlayed() < 10 && rating.getWinRate() > 75) {
        return true;
    }
    
    // Быстрый рост
    int ratingGain = rating.getRating() - 1500;
    if (rating.getGamesPlayed() < 20 && ratingGain > 500) {
        return true;
    }
    
    return false;
}
```

---

## API Endpoints

**GET `/api/v1/matchmaking/ratings/{activityType}`** - рейтинг игрока
**GET `/api/v1/matchmaking/leaderboard/{activityType}`** - leaderboard

---

## Связанные документы

- `.BRAIN/05-technical/backend/matchmaking/matchmaking-queue.md` - Queue (микрофича 1/3)
- `.BRAIN/05-technical/backend/matchmaking/matchmaking-algorithm.md` - Algorithm (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Микрофича 3/3: Matchmaking Rating (split from matchmaking-system.md)




