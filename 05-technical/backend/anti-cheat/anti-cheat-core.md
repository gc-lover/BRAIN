---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 01:59  
**api-readiness-notes:** Anti-Cheat System. Детекция читов, validation, ban system. ~400 строк.
---

# Anti-Cheat System - Core System

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07 01:59  
**Приоритет:** КРИТИЧЕСКИЙ (Security!)  
**Автор:** AI Brain Manager

**Микрофича:** Anti-cheat detection & prevention  
**Размер:** ~400 строк ✅

---

## Краткое описание

**Anti-Cheat System** - критически важная система защиты от читеров в MMORPG.

**Ключевые возможности:**
- ✅ Server-side validation (все действия)
- ✅ Anomaly detection (подозрительное поведение)
- ✅ Rate limiting (защита от спама)
- ✅ Ban system (автоматический + manual)
- ✅ Replay system (для расследования)
- ✅ Report system (жалобы игроков)

---

## Архитектура системы

```
Client Action
    ↓
Server Validation (все проверки)
    ↓
Anomaly Detection (ML/rules)
    ↓
Suspicious? → Flag for Review
    ↓
Auto-Ban (если критично) or Manual Review
```

---

## Server-Side Validation

### Movement Validation

```java
@Service
public class MovementValidator {
    
    private static final double MAX_SPEED = 10.0; // м/с
    private static final double TELEPORT_THRESHOLD = 100.0; // м
    
    public boolean validateMovement(UUID playerId, Position oldPos, Position newPos, float deltaTime) {
        double distance = calculateDistance(oldPos, newPos);
        double speed = distance / deltaTime;
        
        // 1. Speed check
        if (speed > MAX_SPEED * 1.5) { // 50% tolerance
            logSuspiciousActivity(playerId, "SPEED_HACK", Map.of(
                "speed", speed,
                "maxSpeed", MAX_SPEED,
                "distance", distance,
                "deltaTime", deltaTime
            ));
            return false;
        }
        
        // 2. Teleport check
        if (distance > TELEPORT_THRESHOLD && deltaTime < 1.0) {
            logSuspiciousActivity(playerId, "TELEPORT", Map.of(
                "distance", distance,
                "deltaTime", deltaTime
            ));
            return false;
        }
        
        // 3. Collision check (wall hacks)
        if (isInsideWall(newPos)) {
            logSuspiciousActivity(playerId, "NOCLIP", Map.of(
                "position", newPos
            ));
            return false;
        }
        
        return true;
    }
}
```

### Combat Validation

```java
@Service
public class CombatValidator {
    
    public boolean validateDamage(UUID attackerId, UUID targetId, int damage) {
        Player attacker = getPlayer(attackerId);
        
        // 1. Max damage check
        int maxPossibleDamage = calculateMaxDamage(attacker);
        
        if (damage > maxPossibleDamage * 1.2) {
            logSuspiciousActivity(attackerId, "DAMAGE_HACK", Map.of(
                "reported", damage,
                "max", maxPossibleDamage
            ));
            return false;
        }
        
        // 2. Rate of fire check
        if (!validateRateOfFire(attackerId)) {
            logSuspiciousActivity(attackerId, "RAPID_FIRE", Map.of());
            return false;
        }
        
        // 3. Ammo check
        if (!hasEnoughAmmo(attackerId)) {
            logSuspiciousActivity(attackerId, "INFINITE_AMMO", Map.of());
            return false;
        }
        
        return true;
    }
    
    public boolean validateHeadshot(UUID attackerId, Position attackerPos, Position targetPos) {
        // Check if headshot is physically possible
        double distance = calculateDistance(attackerPos, targetPos);
        double angle = calculateAngle(attackerPos, targetPos);
        
        // Too far for headshot?
        if (distance > 500) {
            logSuspiciousActivity(attackerId, "IMPOSSIBLE_HEADSHOT", Map.of(
                "distance", distance
            ));
            return false;
        }
        
        // Inhuman accuracy?
        PlayerStats stats = getPlayerStats(attackerId);
        if (stats.getHeadshotRate() > 95.0) { // >95% headshot rate suspicious
            logSuspiciousActivity(attackerId, "AIMBOT_SUSPECTED", Map.of(
                "headshotRate", stats.getHeadshotRate()
            ));
        }
        
        return true;
    }
}
```

### Economy Validation

```java
@Service
public class EconomyValidator {
    
    public boolean validateTrade(UUID playerId, TradeRequest trade) {
        // 1. Item ownership check
        if (!playerOwnsItems(playerId, trade.getItems())) {
            logSuspiciousActivity(playerId, "ITEM_DUPLICATION", Map.of(
                "items", trade.getItems()
            ));
            return false;
        }
        
        // 2. Currency check
        if (!hasCurrency(playerId, trade.getCurrency())) {
            logSuspiciousActivity(playerId, "CURRENCY_HACK", Map.of(
                "claimed", trade.getCurrency(),
                "actual", getPlayerCurrency(playerId)
            ));
            return false;
        }
        
        // 3. Unrealistic wealth check
        if (isWealthSuspicious(playerId)) {
            flagForReview(playerId, "SUSPICIOUS_WEALTH");
        }
        
        return true;
    }
    
    private boolean isWealthSuspicious(UUID playerId) {
        Player player = getPlayer(playerId);
        
        // New player with millions - suspicious
        if (player.getPlaytimeHours() < 10 && player.getNetWorth() > 1000000) {
            return true;
        }
        
        // Wealth growth too fast
        long wealthGrowth = player.getNetWorth() - player.getNetWorthYesterday();
        if (wealthGrowth > 500000 && player.getLevel() < 30) {
            return true;
        }
        
        return false;
    }
}
```

---

## Anomaly Detection

### Pattern Detection

```java
@Service
public class AnomalyDetector {
    
    public void detectAnomalies(UUID playerId) {
        PlayerBehavior behavior = analyzeBehavior(playerId);
        
        List<Anomaly> anomalies = new ArrayList<>();
        
        // 1. Kill rate anomaly
        if (behavior.getKillsPerHour() > 500) { // Inhuman
            anomalies.add(new Anomaly("HIGH_KILL_RATE", behavior.getKillsPerHour()));
        }
        
        // 2. Perfect accuracy
        if (behavior.getAccuracy() > 98.0 && behavior.getShotsFired() > 1000) {
            anomalies.add(new Anomaly("PERFECT_ACCURACY", behavior.getAccuracy()));
        }
        
        // 3. Instant quest completions
        if (behavior.getAverageQuestTime() < 60) { // <1 min per quest
            anomalies.add(new Anomaly("INSTANT_QUESTS", behavior.getAverageQuestTime()));
        }
        
        // 4. Impossible progression
        if (behavior.getLevelsPerHour() > 5) {
            anomalies.add(new Anomaly("IMPOSSIBLE_PROGRESSION", behavior.getLevelsPerHour()));
        }
        
        // 5. Store anomalies
        if (!anomalies.isEmpty()) {
            storeAnomalies(playerId, anomalies);
            
            // Auto-ban if critical
            if (isCriticalAnomaly(anomalies)) {
                autoBan(playerId, "CRITICAL_ANOMALY", anomalies);
            } else {
                flagForReview(playerId, anomalies);
            }
        }
    }
}
```

---

## Ban System

### Ban Types

```java
public enum BanType {
    TEMPORARY,    // Временный (1h/1d/7d/30d)
    PERMANENT,    // Навсегда
    SHADOW,       // Shadow ban (игрок не знает)
    HARDWARE      // Hardware ID ban
}

public enum BanReason {
    SPEED_HACK,
    TELEPORT_HACK,
    AIMBOT,
    WALL_HACK,
    ITEM_DUPLICATION,
    CURRENCY_HACK,
    EXPLOIT_ABUSE,
    TOXIC_BEHAVIOR,
    RMT              // Real Money Trading
}
```

### Auto-Ban Logic

```java
@Service
public class BanService {
    
    public void autoBan(UUID playerId, String reason, Object evidence) {
        Player player = getPlayer(playerId);
        
        // Determine ban duration
        BanDuration duration = determineBanDuration(reason, player);
        
        // Create ban
        PlayerBan ban = new PlayerBan();
        ban.setPlayerId(playerId);
        ban.setReason(reason);
        ban.setType(duration.getType());
        ban.setDuration(duration.getDuration());
        ban.setEvidence(evidence);
        ban.setBannedBy("SYSTEM");
        ban.setBannedAt(Instant.now());
        
        if (duration.getType() != BanType.PERMANENT) {
            ban.setExpiresAt(Instant.now().plus(duration.getDuration()));
        }
        
        banRepository.save(ban);
        
        // Update account status
        accountService.updateStatus(player.getAccountId(), AccountStatus.BANNED);
        
        // Kick from game
        sessionManager.kickPlayer(playerId, "BANNED: " + reason);
        
        // Notify moderators
        notifyModerators(new BanNotification(player, ban));
        
        log.warn("Player auto-banned: playerId={}, reason={}", playerId, reason);
    }
    
    private BanDuration determineBanDuration(String reason, Player player) {
        // First offense
        if (!hasPreivousBans(player.getId())) {
            return switch (reason) {
                case "SPEED_HACK", "TELEPORT_HACK" -> 
                    new BanDuration(BanType.TEMPORARY, Duration.ofDays(7));
                case "AIMBOT", "WALL_HACK" -> 
                    new BanDuration(BanType.TEMPORARY, Duration.ofDays(30));
                case "ITEM_DUPLICATION", "CURRENCY_HACK" -> 
                    new BanDuration(BanType.PERMANENT, null);
                default -> new BanDuration(BanType.TEMPORARY, Duration.ofDays(1));
            };
        }
        
        // Repeat offender → permanent
        return new BanDuration(BanType.PERMANENT, null);
    }
}
```

---

## Player Report System

### Report Submission

```java
@PostMapping("/api/v1/reports/submit")
public ResponseEntity<Void> submitReport(
    @AuthenticatedUser Player reporter,
    @RequestBody ReportRequest request
) {
    // Validate
    if (reporter.getId().equals(request.getReportedPlayerId())) {
        throw new CannotReportYourselfException();
    }
    
    // Create report
    PlayerReport report = new PlayerReport();
    report.setReporterId(reporter.getId());
    report.setReportedPlayerId(request.getReportedPlayerId());
    report.setReason(request.getReason());
    report.setDescription(request.getDescription());
    report.setEvidence(request.getEvidenceUrls());
    report.setStatus(ReportStatus.PENDING);
    
    reportRepository.save(report);
    
    // Check for multiple reports
    long recentReports = reportRepository
        .countRecentReports(request.getReportedPlayerId(), Duration.ofHours(24));
    
    if (recentReports >= 10) {
        // Many reports → high priority review
        flagForUrgentReview(request.getReportedPlayerId(), report);
        
        // Consider auto-ban
        if (recentReports >= 20) {
            autoBan(request.getReportedPlayerId(), 
                "MASS_REPORTS", 
                Map.of("reportCount", recentReports));
        }
    }
    
    return ResponseEntity.ok().build();
}
```

---

## Database Schema

### Таблица `player_bans`

```sql
CREATE TABLE player_bans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    account_id UUID NOT NULL,
    
    -- Ban details
    ban_type VARCHAR(20) NOT NULL,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    evidence JSONB,
    
    -- Duration
    banned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    
    -- Who banned
    banned_by UUID,
    banned_by_type VARCHAR(20) DEFAULT 'SYSTEM',
    
    -- Appeal
    appeal_status VARCHAR(20),
    appeal_text TEXT,
    appeal_reviewed_by UUID,
    appeal_decision TEXT,
    
    -- Hardware ban
    hardware_id VARCHAR(255),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_ban_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_ban_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE INDEX idx_bans_player ON player_bans(player_id);
CREATE INDEX idx_bans_expires ON player_bans(expires_at) 
    WHERE expires_at IS NOT NULL;
```

### Таблица `suspicious_activities`

```sql
CREATE TABLE suspicious_activities (
    id BIGSERIAL PRIMARY KEY,
    player_id UUID NOT NULL,
    
    -- Activity
    activity_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) DEFAULT 'LOW',
    
    -- Details
    details JSONB NOT NULL,
    
    -- Review
    reviewed BOOLEAN DEFAULT FALSE,
    reviewed_by UUID,
    reviewed_at TIMESTAMP,
    action_taken VARCHAR(100),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_suspicious_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_suspicious_player ON suspicious_activities(player_id);
CREATE INDEX idx_suspicious_reviewed ON suspicious_activities(reviewed) 
    WHERE reviewed = FALSE;
CREATE INDEX idx_suspicious_severity ON suspicious_activities(severity);
```

---

## Rate Limiting

### Action Rate Limits

```java
@Service
public class RateLimiter {
    
    private static final Map<String, RateLimit> LIMITS = Map.of(
        "CHAT_MESSAGE", new RateLimit(10, Duration.ofMinutes(1)),
        "TRADE_REQUEST", new RateLimit(20, Duration.ofMinutes(5)),
        "ITEM_DROP", new RateLimit(100, Duration.ofMinutes(1)),
        "QUEST_COMPLETE", new RateLimit(50, Duration.ofHours(1)),
        "API_CALL", new RateLimit(100, Duration.ofMinutes(1))
    );
    
    public boolean checkLimit(UUID playerId, String action) {
        String key = "ratelimit:" + playerId + ":" + action;
        RateLimit limit = LIMITS.get(action);
        
        // Get current count
        Long count = (Long) redis.opsForValue().get(key);
        
        if (count == null) {
            // First action
            redis.opsForValue().set(key, 1L, limit.getDuration());
            return true;
        }
        
        if (count >= limit.getMaxCount()) {
            // Limit exceeded
            logSuspiciousActivity(playerId, "RATE_LIMIT_EXCEEDED", Map.of(
                "action", action,
                "count", count,
                "limit", limit.getMaxCount()
            ));
            return false;
        }
        
        // Increment
        redis.opsForValue().increment(key);
        return true;
    }
}
```

---

## Cheat Detection Rules

### Impossible Actions

```java
public class CheatDetectionRules {
    
    // Rule 1: Impossible stats
    public boolean checkImpossibleStats(Player player) {
        // Level 10 with level 50 items?
        if (player.getLevel() < 20 && hasHighLevelItems(player, 40)) {
            return true;
        }
        
        // Max skills too fast?
        if (player.getPlaytimeHours() < 10 && hasMaxSkills(player)) {
            return true;
        }
        
        return false;
    }
    
    // Rule 2: Impossible timing
    public boolean checkImpossibleTiming(QuestCompletion completion) {
        // Quest completed in 10 seconds (should take 30 min)?
        if (completion.getDuration() < 60 && completion.getExpectedDuration() > 1800) {
            return true;
        }
        
        return false;
    }
    
    // Rule 3: Impossible inventory
    public boolean checkImpossibleInventory(Player player) {
        // More items than possible to carry?
        if (player.getInventory().getItemCount() > player.getInventory().getMaxSlots() * 2) {
            return true;
        }
        
        // Items that don't exist in game?
        if (hasInvalidItems(player)) {
            return true;
        }
        
        return false;
    }
}
```

---

## Machine Learning Detection

### Behavioral Analysis

```python
class CheatDetectionML:
    """ML model для детекции читов"""
    
    def predict_cheat_probability(self, player_id):
        # Get features
        features = extract_features(player_id)
        
        # Features:
        # - Kill/Death ratio
        # - Headshot percentage
        # - Average damage per shot
        # - Movement patterns
        # - Resource gain rate
        # - Quest completion speed
        # - Trading patterns
        
        # ML model prediction
        probability = self.model.predict(features)
        
        if probability > 0.85:
            return "HIGH_RISK"
        elif probability > 0.60:
            return "MEDIUM_RISK"
        else:
            return "LOW_RISK"
```

---

## API Endpoints

**POST `/api/v1/reports/submit`** - report player

```json
Request:
{
  "reportedPlayerId": "uuid",
  "reason": "CHEATING",
  "description": "Player teleporting and aimbotting",
  "evidenceUrls": ["screenshot1.png", "video1.mp4"]
}
```

**GET `/api/v1/admin/suspicious-activities`** - список подозрительных

**POST `/api/v1/admin/ban`** - забанить игрока

**POST `/api/v1/admin/unban`** - разбанить

---

## Связанные документы

- [Authentication System](../auth/auth-authorization-security.md)
- [Session Management](../session/session-lifecycle-heartbeat.md)
- [Admin Tools](../admin/admin-tools-core.md)

