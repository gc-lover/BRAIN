---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Matchmaking Queue микрофича. Queue system, wait time optimization, priority boost. ~400 строк.
---

# Matchmaking Queue - Система очередей

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:30  
**Приоритет:** критический  
**Автор:** AI Brain Manager

**Микрофича:** Matchmaking queue system  
**Размер:** ~400 строк ✅

---


**API Tasks Status:**
- 🚫 Документ отмечен как OBSOLETE (устаревшая split версия)
- 📝 Причина: Consolidated into unified document
- 🔄 Статус: not-applicable
- ⚠️ Этот документ является split версией, которая была объединена в consolidated документ

---

## Краткое описание

**Matchmaking Queue** - система очередей для подбора игроков в различные активности.

**Ключевые возможности:**
- ✅ Queue system (PvP, PvE, Raids)
- ✅ Wait time optimization
- ✅ Priority boost (за долгое ожидание)
- ✅ Search range expansion
- ✅ Party queue support

---

## Database Schema

```sql
CREATE TABLE matchmaking_queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Игрок/группа
    player_id UUID,
    party_id UUID,
    is_party BOOLEAN DEFAULT FALSE,
    party_size INTEGER DEFAULT 1,
    
    -- Активность
    activity_type VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20),
    mode VARCHAR(20), -- CASUAL, RANKED
    
    -- Роль
    preferred_role VARCHAR(20),
    can_fill BOOLEAN DEFAULT FALSE,
    
    -- Match criteria
    min_level INTEGER NOT NULL,
    max_level INTEGER NOT NULL,
    rating INTEGER,
    rating_range INTEGER DEFAULT 200,
    
    -- Состояние
    queue_status VARCHAR(20) DEFAULT 'QUEUED',
    queued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    
    -- Match
    match_id UUID,
    
    -- Расширение поиска
    search_range_expanded_count INTEGER DEFAULT 0,
    current_rating_range INTEGER,
    
    -- Приоритет
    priority INTEGER DEFAULT 0,
    wait_time_bonus INTEGER DEFAULT 0,
    
    CONSTRAINT fk_queue_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_queue_activity_status ON matchmaking_queues(activity_type, queue_status);
CREATE INDEX idx_queue_rating ON matchmaking_queues(rating) WHERE queue_status = 'QUEUED';
```

---

## Enter Queue

```java
@PostMapping("/matchmaking/queue")
public QueueResponse enterQueue(
    @RequestHeader("Authorization") String token,
    @RequestBody QueueRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Проверки
    if (queueRepository.existsByPlayerAndStatus(playerId, QueueStatus.QUEUED)) {
        return error("Already in queue");
    }
    
    // 2. Создать queue entry
    QueueEntry entry = new QueueEntry();
    entry.setPlayerId(playerId);
    entry.setActivityType(request.getActivityType());
    entry.setPreferredRole(request.getRole());
    entry.setRating(getRating(playerId, request.getActivityType()));
    entry.setRatingRange(200); // Начальный
    entry.setExpiresAt(Instant.now().plus(Duration.ofMinutes(10)));
    
    entry = queueRepository.save(entry);
    
    // 3. Redis queue
    redis.opsForList().rightPush(
        "queue:" + request.getActivityType(),
        entry.getId().toString()
    );
    
    return new QueueResponse(entry.getId(), estimateWaitTime(request));
}
```

---

## Wait Time Optimization

### Search Range Expansion

```java
@Scheduled(fixedDelay = 15000) // Каждые 15 секунд
public void expandSearchRange() {
    List<QueueEntry> longWaiting = queueRepository
        .findQueuedLongerThan(Duration.ofMinutes(2));
    
    for (QueueEntry entry : longWaiting) {
        // Расширить диапазон
        int newRange = Math.min(entry.getCurrentRatingRange() + 100, 1000);
        entry.setCurrentRatingRange(newRange);
        entry.setSearchRangeExpandedCount(entry.getSearchRangeExpandedCount() + 1);
        queueRepository.save(entry);
        
        // Уведомить
        wsService.sendToPlayer(entry.getPlayerId(),
            new QueueUpdateMessage("Expanding search range...", newRange));
    }
}
```

### Priority Boost

```
Wait time > 5 min: priority +1
Wait time > 10 min: priority +2
Wait time > 15 min: priority +5 (urgent)
```

---

## API Endpoints

**POST `/api/v1/matchmaking/queue`** - войти в очередь
**DELETE `/api/v1/matchmaking/queue`** - покинуть
**GET `/api/v1/matchmaking/queue/status`** - статус очереди

---

## Связанные документы

- `.BRAIN/05-technical/backend/matchmaking/matchmaking-algorithm.md` - Algorithm (микрофича 2/3)
- `.BRAIN/05-technical/backend/matchmaking/matchmaking-rating.md` - Rating (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Микрофича 1/3: Matchmaking Queue (split from matchmaking-system.md)




