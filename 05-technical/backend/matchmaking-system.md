---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:55  
**api-readiness-notes:** Полная система matchmaking для PvP, рейдов, dungeons. Queue system, match criteria, party formation, team balancing, MMR/ELO rating.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-108: api/v1/technical/matchmaking.yaml (2025-11-07)
- Last Updated: 2025-11-07 05:30
---

# Matchmaking System - Система подбора игроков

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:55  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---

## Краткое описание

**Matchmaking System** - система для автоматического подбора игроков в группы для различных активностей (PvP, рейды, dungeons, group quests). Обеспечивает справедливый подбор, балансировку команд и минимизацию времени ожидания.

**Ключевые возможности:**
- ✅ Queue system (очереди для разных активностей)
- ✅ Match criteria (level, role, rating, region)
- ✅ Party formation (автоматическое создание групп)
- ✅ Team balancing (баланс сил команд)
- ✅ MMR/ELO rating system (рейтинговые матчи)
- ✅ Role-based matchmaking (tank, dps, healer, support)
- ✅ Cross-server matchmaking (объединение серверов)

---

## Типы активностей

### 1. PvP Modes

**Arena 3v3:**
- Queue: Solo or Party (1-3 players)
- Roles: 1 Tank, 1 Healer, 1 DPS (flexible)
- Rating: MMR-based matchmaking
- Wait time target: <2 minutes

**Arena 5v5:**
- Queue: Solo or Party (1-5 players)
- Roles: 1-2 Tanks, 1 Healer, 2-3 DPS
- Rating: MMR-based
- Wait time target: <3 minutes

**Battlegrounds 10v10:**
- Queue: Solo or Party (1-5 players)
- Roles: Any composition
- Rating: Casual or Ranked
- Wait time target: <5 minutes

**Faction Wars (20v20+):**
- Queue: Faction members only
- Roles: Any
- No rating (faction-based)
- Wait time: Event-driven (scheduled)

### 2. PvE Modes

**Dungeons (5 players):**
- Queue: Solo or Party (1-5)
- Roles: 1 Tank, 1 Healer, 3 DPS
- Difficulty: Normal, Hard, Nightmare
- Wait time target: <3 minutes

**Raids (10-15 players):**
- Queue: Pre-formed raid group
- Roles: 2 Tanks, 2-3 Healers, 6-10 DPS
- Difficulty: Normal, Hard, Nightmare
- Wait time: До заполнения группы

**World Events (50+ players):**
- No queue (open world, join at location)
- Roles: Any
- Auto-scaling difficulty

---

## Database Schema

### Таблица `matchmaking_queues`

```sql
CREATE TABLE matchmaking_queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Игрок/группа
    player_id UUID, -- Для solo queue
    party_id UUID, -- Для group queue
    is_party BOOLEAN DEFAULT FALSE,
    party_size INTEGER DEFAULT 1,
    
    -- Активность
    activity_type VARCHAR(50) NOT NULL, -- PVP_ARENA_3V3, PVE_DUNGEON, RAID, etc
    difficulty VARCHAR(20), -- NORMAL, HARD, NIGHTMARE
    mode VARCHAR(20), -- CASUAL, RANKED
    
    -- Роль
    preferred_role VARCHAR(20), -- TANK, DPS, HEALER, SUPPORT, ANY
    can_fill BOOLEAN DEFAULT FALSE, -- Может заполнить любую роль
    
    -- Match criteria
    min_level INTEGER NOT NULL,
    max_level INTEGER NOT NULL,
    rating INTEGER, -- MMR для ranked modes
    rating_range INTEGER DEFAULT 200, -- ±200 MMR поиск
    
    -- Регион
    server_id VARCHAR(100) NOT NULL,
    region VARCHAR(100), -- Предпочитаемый регион (для latency)
    allow_cross_region BOOLEAN DEFAULT TRUE,
    
    -- Состояние очереди
    queue_status VARCHAR(20) NOT NULL DEFAULT 'QUEUED',
    -- QUEUED, SEARCHING, MATCHED, ACCEPTED, DECLINED, EXPIRED
    
    -- Временные метки
    queued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    search_started_at TIMESTAMP,
    matched_at TIMESTAMP,
    expires_at TIMESTAMP NOT NULL, -- Queue timeout (10 minutes)
    
    -- Match найден
    match_id UUID, -- FK to matches
    
    -- Расширение поиска
    search_range_expanded_count INTEGER DEFAULT 0, -- Сколько раз расширяли поиск
    current_rating_range INTEGER, -- Текущий диапазон рейтинга
    
    -- Приоритет
    priority INTEGER DEFAULT 0, -- Высокий приоритет = быстрее подбор
    wait_time_bonus INTEGER DEFAULT 0, -- Бонус за долгое ожидание
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_queue_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_queue_party FOREIGN KEY (party_id) 
        REFERENCES parties(id) ON DELETE CASCADE,
    CHECK ((player_id IS NOT NULL AND party_id IS NULL) OR 
           (player_id IS NULL AND party_id IS NOT NULL))
);

CREATE INDEX idx_queue_activity_status ON matchmaking_queues(activity_type, queue_status);
CREATE INDEX idx_queue_rating ON matchmaking_queues(rating, activity_type) 
    WHERE queue_status = 'QUEUED';
CREATE INDEX idx_queue_queued_at ON matchmaking_queues(queued_at DESC) 
    WHERE queue_status = 'QUEUED';
CREATE INDEX idx_queue_player ON matchmaking_queues(player_id) 
    WHERE queue_status IN ('QUEUED', 'MATCHED');
```

### Таблица `matches`

```sql
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Активность
    activity_type VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20),
    mode VARCHAR(20),
    
    -- Команды
    team_a_players JSONB NOT NULL, -- Array of player IDs
    team_b_players JSONB, -- Для PvP (NULL для PvE)
    
    -- Роли
    team_composition JSONB, -- {tanks: 2, healers: 2, dps: 6}
    
    -- Рейтинг
    average_rating_team_a INTEGER,
    average_rating_team_b INTEGER,
    rating_difference INTEGER, -- Разница рейтингов команд
    
    -- Сервер и instance
    server_id VARCHAR(100) NOT NULL,
    instance_id VARCHAR(100), -- Instance для матча
    
    -- Состояние матча
    match_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    -- PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
    
    -- Acceptance
    players_accepted JSONB DEFAULT '[]', -- Array of player IDs who accepted
    players_declined JSONB DEFAULT '[]',
    acceptance_deadline TIMESTAMP, -- Deadline для acceptance (60s)
    
    -- Временные метки
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Результат
    winner_team VARCHAR(1), -- 'A' or 'B' (для PvP)
    match_result JSONB, -- Детали результата
    
    -- Метрики
    match_quality DECIMAL(3,2), -- 0-1 (насколько сбалансированный матч)
    average_wait_time INTEGER, -- Среднее время ожидания игроков (сек)
    
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_match_instance FOREIGN KEY (instance_id) 
        REFERENCES game_instances(id)
);

CREATE INDEX idx_matches_status ON matches(match_status);
CREATE INDEX idx_matches_activity ON matches(activity_type);
CREATE INDEX idx_matches_created ON matches(created_at DESC);
CREATE INDEX idx_matches_acceptance_deadline ON matches(acceptance_deadline) 
    WHERE match_status = 'PENDING';
```

---

## Matchmaking Algorithm

### Queue Flow

```
1. Player enters queue
   ↓
2. Add to matchmaking pool
   ↓
3. Search for compatible players
   ↓
4. Form match (balance teams)
   ↓
5. Send match found notification
   ↓
6. Wait for acceptance (60 seconds)
   ↓
7. If all accepted → Create instance, start match
   If declined → Re-queue declined players, find replacement
```

### Matching Algorithm

```java
@Service
public class MatchmakingEngine {
    
    @Scheduled(fixedDelay = 5000) // Каждые 5 секунд
    public void findMatches() {
        // Для каждого типа активности
        for (ActivityType activityType : ActivityType.values()) {
            findMatchesForActivity(activityType);
        }
    }
    
    private void findMatchesForActivity(ActivityType activityType) {
        // 1. Получить очередь
        List<QueueEntry> queue = queueRepository
            .findQueuedByActivity(activityType);
        
        if (queue.size() < activityType.getRequiredPlayers()) {
            return; // Недостаточно игроков
        }
        
        // 2. Сортировать по времени ожидания (FIFO) + приоритет
        queue.sort(Comparator
            .comparing(QueueEntry::getPriority).reversed()
            .thenComparing(QueueEntry::getQueuedAt)
        );
        
        // 3. Найти лучшие матчи
        while (queue.size() >= activityType.getRequiredPlayers()) {
            Match match = findBestMatch(queue, activityType);
            
            if (match == null) {
                break; // Не можем найти подходящий матч
            }
            
            // 4. Создать матч
            createMatch(match);
            
            // 5. Удалить matched игроков из очереди
            queue.removeAll(match.getPlayers());
        }
        
        // 6. Расширить поиск для ждущих долго
        expandSearchRange(queue);
    }
    
    private Match findBestMatch(List<QueueEntry> queue, ActivityType activity) {
        // Алгоритм подбора зависит от типа активности
        switch (activity) {
            case PVP_ARENA_3V3:
                return findPvPMatch(queue, 3, 3); // 3v3
            case PVE_DUNGEON:
                return findPvEMatch(queue, 5); // 5 players
            case RAID:
                return findRaidMatch(queue, 10); // 10-15 players
            default:
                return null;
        }
    }
}
```

### PvP Match Algorithm

```java
private Match findPvPMatch(List<QueueEntry> queue, int teamSize, int teams) {
    int requiredPlayers = teamSize * teams;
    
    if (queue.size() < requiredPlayers) {
        return null;
    }
    
    // 1. Найти группу игроков с близким рейтингом
    for (int i = 0; i <= queue.size() - requiredPlayers; i++) {
        List<QueueEntry> candidates = queue.subList(i, i + requiredPlayers);
        
        // 2. Проверить рейтинг совместимость
        int minRating = candidates.stream()
            .mapToInt(QueueEntry::getRating)
            .min().orElse(0);
        int maxRating = candidates.stream()
            .mapToInt(QueueEntry::getRating)
            .max().orElse(0);
        
        int ratingSpread = maxRating - minRating;
        int maxAllowedSpread = candidates.get(0).getCurrentRatingRange();
        
        if (ratingSpread > maxAllowedSpread) {
            continue; // Слишком большой разброс рейтинга
        }
        
        // 3. Разделить на команды (балансировка)
        TeamDivision division = balanceTeams(candidates, teamSize);
        
        // 4. Проверить баланс
        if (division.getRatingDifference() > 100) {
            continue; // Команды несбалансированы
        }
        
        // 5. Создать матч
        return new Match(
            activity,
            division.getTeamA(),
            division.getTeamB(),
            division.getAverageRatingA(),
            division.getAverageRatingB()
        );
    }
    
    return null; // Не нашли подходящий матч
}

private TeamDivision balanceTeams(List<QueueEntry> players, int teamSize) {
    // Алгоритм балансировки команд
    // Цель: минимизировать разницу в среднем рейтинге команд
    
    // Сортировать по рейтингу
    players.sort(Comparator.comparing(QueueEntry::getRating).reversed());
    
    // Snake draft: высокий → низкий → низкий → высокий
    List<QueueEntry> teamA = new ArrayList<>();
    List<QueueEntry> teamB = new ArrayList<>();
    
    for (int i = 0; i < players.size(); i++) {
        if (i % 4 == 0 || i % 4 == 3) {
            teamA.add(players.get(i));
        } else {
            teamB.add(players.get(i));
        }
    }
    
    int avgRatingA = teamA.stream()
        .mapToInt(QueueEntry::getRating)
        .average().orElse(0);
    int avgRatingB = teamB.stream()
        .mapToInt(QueueEntry::getRating)
        .average().orElse(0);
    
    return new TeamDivision(
        teamA, teamB,
        avgRatingA, avgRatingB,
        Math.abs(avgRatingA - avgRatingB)
    );
}
```

### PvE Match Algorithm

```java
private Match findPvEMatch(List<QueueEntry> queue, int requiredPlayers) {
    // PvE: нужен 1 Tank, 1 Healer, 3 DPS
    
    // 1. Группировать по ролям
    Map<Role, List<QueueEntry>> byRole = queue.stream()
        .collect(Collectors.groupingBy(QueueEntry::getPreferredRole));
    
    // 2. Проверить наличие нужных ролей
    if (byRole.getOrDefault(Role.TANK, List.of()).isEmpty()) {
        // Нет танков - искать fill players
        byRole.put(Role.TANK, findFillPlayers(queue, Role.TANK));
    }
    
    if (byRole.getOrDefault(Role.HEALER, List.of()).isEmpty()) {
        byRole.put(Role.HEALER, findFillPlayers(queue, Role.HEALER));
    }
    
    if (byRole.get(Role.TANK).isEmpty() || byRole.get(Role.HEALER).isEmpty()) {
        return null; // Не можем создать матч без tank/healer
    }
    
    // 3. Выбрать игроков
    List<QueueEntry> matchPlayers = new ArrayList<>();
    matchPlayers.add(byRole.get(Role.TANK).get(0)); // 1 tank
    matchPlayers.add(byRole.get(Role.HEALER).get(0)); // 1 healer
    
    // 3 DPS (берем из DPS или ANY)
    List<QueueEntry> dpsPool = new ArrayList<>();
    dpsPool.addAll(byRole.getOrDefault(Role.DPS, List.of()));
    dpsPool.addAll(byRole.getOrDefault(Role.ANY, List.of()));
    
    if (dpsPool.size() < 3) {
        return null; // Недостаточно DPS
    }
    
    matchPlayers.addAll(dpsPool.subList(0, 3));
    
    // 4. Проверить level compatibility
    int minLevel = matchPlayers.stream()
        .mapToInt(q -> q.getMinLevel())
        .min().orElse(0);
    int maxLevel = matchPlayers.stream()
        .mapToInt(q -> q.getMaxLevel())
        .max().orElse(100);
    
    if (maxLevel - minLevel > 10) {
        return null; // Слишком большой разброс уровней
    }
    
    // 5. Создать матч
    return new Match(
        activity,
        matchPlayers,
        null, // PvE - только одна команда
        0, 0
    );
}
```

---

## MMR/ELO Rating System

### MMR Calculation

**Initial Rating:** 1500 (для всех новых игроков)

**Формула Elo:**
```
New Rating = Old Rating + K × (Actual Score - Expected Score)

Expected Score = 1 / (1 + 10^((Opponent Rating - Player Rating) / 400))

K-Factor:
- Новички (<30 игр): K = 40 (быстрая калибровка)
- Обычные игроки: K = 20
- Мастера (>100 игр, rating >2000): K = 10 (стабильность)

Actual Score:
- Win: 1.0
- Draw: 0.5
- Loss: 0.0
```

**Пример:**
```
Player Rating: 1600
Opponent Rating: 1700
Expected Score = 1 / (1 + 10^((1700-1600)/400)) = 1 / (1 + 10^0.25) = 0.36

Win: New Rating = 1600 + 20 × (1.0 - 0.36) = 1600 + 12.8 = 1612.8 ≈ 1613
Loss: New Rating = 1600 + 20 × (0.0 - 0.36) = 1600 - 7.2 = 1592.8 ≈ 1593
```

### Rating Tiers

```
0-999:     Bronze
1000-1499: Silver
1500-1999: Gold
2000-2499: Platinum
2500-2999: Diamond
3000-3499: Master
3500+:     Grandmaster
```

### Таблица `player_ratings`

```sql
CREATE TABLE player_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    
    -- Рейтинг по активностям
    activity_type VARCHAR(50) NOT NULL,
    
    -- MMR
    rating INTEGER NOT NULL DEFAULT 1500,
    peak_rating INTEGER DEFAULT 1500, -- Исторический пик
    
    -- Статистика
    games_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2), -- Win rate %
    
    -- Streak
    current_streak INTEGER DEFAULT 0, -- Положительный = винстрик, отрицательный = лузстрик
    best_win_streak INTEGER DEFAULT 0,
    
    -- Ранг
    tier VARCHAR(20), -- BRONZE, SILVER, GOLD, etc
    division INTEGER, -- 1-5 внутри тира
    
    -- League (сезон)
    league_id VARCHAR(50), -- season-2025-11
    
    -- Метаданные
    last_game_at TIMESTAMP,
    rating_updated_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_rating_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, activity_type, league_id)
);

CREATE INDEX idx_ratings_player_activity ON player_ratings(player_id, activity_type);
CREATE INDEX idx_ratings_rating ON player_ratings(rating DESC);
CREATE INDEX idx_ratings_tier ON player_ratings(tier, division);
```

---

## Queue System

### Enter Queue

```java
@PostMapping("/matchmaking/queue")
public ResponseEntity<QueueResponse> enterQueue(
    @RequestHeader("Authorization") String token,
    @RequestBody QueueRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Проверить, не в очереди ли уже
    if (queueRepository.existsByPlayerAndStatus(playerId, QueueStatus.QUEUED)) {
        return ResponseEntity.status(409).body(
            new ErrorResponse("Already in queue")
        );
    }
    
    // 2. Проверить requirements
    Player player = playerRepository.findById(playerId);
    
    if (player.getLevel() < request.getActivity().getMinLevel()) {
        return ResponseEntity.status(403).body(
            new ErrorResponse("Level too low")
        );
    }
    
    // 3. Создать queue entry
    QueueEntry entry = new QueueEntry();
    entry.setPlayerId(playerId);
    entry.setActivityType(request.getActivityType());
    entry.setPreferredRole(request.getRole());
    entry.setMinLevel(player.getLevel() - 5);
    entry.setMaxLevel(player.getLevel() + 5);
    entry.setRating(getRating(playerId, request.getActivityType()));
    entry.setRatingRange(200); // Начальный диапазон
    entry.setServerId(player.getServerId());
    entry.setExpiresAt(Instant.now().plus(Duration.ofMinutes(10)));
    
    entry = queueRepository.save(entry);
    
    // 4. Добавить в Redis queue (для fast matching)
    String queueKey = "queue:" + request.getActivityType();
    redis.opsForList().rightPush(queueKey, entry.getId().toString());
    
    // 5. Опубликовать событие
    eventBus.publish(new PlayerQueuedEvent(
        playerId,
        request.getActivityType()
    ));
    
    // 6. Вернуть ответ
    return ResponseEntity.ok(new QueueResponse(
        entry.getId(),
        "Searching for match...",
        estimateWaitTime(request.getActivityType())
    ));
}
```

### Leave Queue

```java
@DeleteMapping("/matchmaking/queue")
public ResponseEntity<Void> leaveQueue(
    @RequestHeader("Authorization") String token
) {
    UUID playerId = extractPlayerId(token);
    
    // Найти и удалить из очереди
    QueueEntry entry = queueRepository.findActiveByPlayer(playerId);
    
    if (entry != null) {
        entry.setQueueStatus(QueueStatus.CANCELLED);
        queueRepository.save(entry);
        
        // Удалить из Redis
        String queueKey = "queue:" + entry.getActivityType();
        redis.opsForList().remove(queueKey, 1, entry.getId().toString());
        
        eventBus.publish(new PlayerLeftQueueEvent(playerId));
    }
    
    return ResponseEntity.ok().build();
}
```

---

## Match Found (Матч найден)

### Accept/Decline

```java
@PostMapping("/matchmaking/matches/{matchId}/accept")
public ResponseEntity<MatchAcceptResponse> acceptMatch(
    @PathVariable UUID matchId,
    @RequestHeader("Authorization") String token
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Получить матч
    Match match = matchRepository.findById(matchId);
    
    if (match == null || match.getStatus() != MatchStatus.PENDING) {
        return ResponseEntity.status(404).build();
    }
    
    // 2. Проверить deadline
    if (Instant.now().isAfter(match.getAcceptanceDeadline())) {
        return ResponseEntity.status(410).body(
            new ErrorResponse("Acceptance deadline passed")
        );
    }
    
    // 3. Проверить, что игрок в матче
    if (!match.containsPlayer(playerId)) {
        return ResponseEntity.status(403).build();
    }
    
    // 4. Зарегистрировать acceptance
    match.addAcceptedPlayer(playerId);
    matchRepository.save(match);
    
    // 5. Проверить, все ли приняли
    if (match.allPlayersAccepted()) {
        // Запустить матч!
        startMatch(match);
        
        return ResponseEntity.ok(new MatchAcceptResponse(
            true,
            "Match starting!",
            match.getInstanceId()
        ));
    }
    
    // 6. Ждем остальных
    int accepted = match.getAcceptedCount();
    int total = match.getTotalPlayers();
    
    return ResponseEntity.ok(new MatchAcceptResponse(
        false,
        "Waiting for other players (" + accepted + "/" + total + ")",
        null
    ));
}
```

### Match Start

```java
private void startMatch(Match match) {
    // 1. Создать instance
    GameInstance instance = instanceService.createInstance(
        match.getActivityType(),
        match.getDifficulty(),
        match.getTeamAPlayers(),
        match.getTeamBPlayers()
    );
    
    // 2. Обновить матч
    match.setInstanceId(instance.getId());
    match.setStatus(MatchStatus.IN_PROGRESS);
    match.setStartedAt(Instant.now());
    matchRepository.save(match);
    
    // 3. Уведомить всех игроков
    for (UUID playerId : match.getAllPlayers()) {
        webSocketService.sendToPlayer(playerId, new MatchStartedMessage(
            match.getId(),
            instance.getId(),
            instance.getJoinToken()
        ));
    }
    
    // 4. Опубликовать событие
    eventBus.publish(new MatchStartedEvent(
        match.getId(),
        instance.getId(),
        match.getActivityType()
    ));
    
    // 5. Удалить из очередей
    queueRepository.deleteByMatchId(match.getId());
}
```

---

## Wait Time Optimization

### Dynamic Search Range Expansion

```java
@Scheduled(fixedDelay = 15000) // Каждые 15 секунд
public void expandSearchRange() {
    List<QueueEntry> longWaiting = queueRepository
        .findQueuedLongerThan(Duration.ofMinutes(2));
    
    for (QueueEntry entry : longWaiting) {
        // Расширить диапазон рейтинга
        int currentRange = entry.getCurrentRatingRange();
        int newRange = Math.min(currentRange + 100, 1000); // Max ±1000
        
        entry.setCurrentRatingRange(newRange);
        entry.setSearchRangeExpandedCount(
            entry.getSearchRangeExpandedCount() + 1
        );
        
        queueRepository.save(entry);
        
        // Уведомить игрока
        webSocketService.sendToPlayer(
            entry.getPlayerId(),
            new QueueUpdateMessage(
                "Expanding search range to find match faster...",
                newRange
            )
        );
    }
}
```

### Priority Boost

```
Wait time > 5 minutes: priority +1
Wait time > 10 minutes: priority +2
Wait time > 15 minutes: priority +5 (urgent)

Приоритет влияет на порядок в очереди
```

---

## Party Matchmaking (Группы)

### Pre-made Party Queue

```java
@PostMapping("/matchmaking/party/queue")
public ResponseEntity<QueueResponse> queueAsParty(
    @RequestHeader("Authorization") String token,
    @RequestBody PartyQueueRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Получить party
    Party party = partyRepository.findByLeader(playerId);
    
    if (party == null) {
        return ResponseEntity.status(404).body(
            new ErrorResponse("You are not a party leader")
        );
    }
    
    // 2. Проверить размер party
    int partySize = party.getMembers().size();
    int maxPartySize = request.getActivity().getMaxPartySize();
    
    if (partySize > maxPartySize) {
        return ResponseEntity.status(400).body(
            new ErrorResponse("Party too large for this activity")
        );
    }
    
    // 3. Проверить все члены готовы
    if (!party.allMembersReady()) {
        return ResponseEntity.status(400).body(
            new ErrorResponse("Not all party members are ready")
        );
    }
    
    // 4. Создать queue entry для party
    QueueEntry entry = new QueueEntry();
    entry.setPartyId(party.getId());
    entry.setIsParty(true);
    entry.setPartySize(partySize);
    entry.setActivityType(request.getActivityType());
    // Роли: берутся из party composition
    entry.setExpiresAt(Instant.now().plus(Duration.ofMinutes(15)));
    
    entry = queueRepository.save(entry);
    
    // 5. Уведомить всех членов party
    for (UUID memberId : party.getMembers()) {
        webSocketService.sendToPlayer(memberId, new QueueEnteredMessage(
            entry.getId(),
            "Searching for match as a party..."
        ));
    }
    
    return ResponseEntity.ok(new QueueResponse(entry.getId(), "Queued as party"));
}
```

---

## Cross-Server Matchmaking

### Instance Sharding

**Проблема:** Игроки на разных серверах не могут играть вместе

**Решение:** Dedicated Instance Servers

```
Player from Server-01
Player from Server-02
  ↓
Matchmaking Pool (cross-server)
  ↓
Match Found
  ↓
Create Instance on Instance-Server-01
  ↓
Both players join instance
  ↓
Play together
  ↓
After match: Return to home servers
```

**Database:**
```sql
-- Instance servers (отдельные от game servers)
CREATE TABLE instance_servers (
    id VARCHAR(100) PRIMARY KEY,
    server_type VARCHAR(50) NOT NULL, -- DUNGEON, RAID, PVP_ARENA
    max_instances INTEGER NOT NULL,
    current_instances INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ONLINE',
    region VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Game instances
CREATE TABLE game_instances (
    id VARCHAR(100) PRIMARY KEY,
    instance_server_id VARCHAR(100) NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    match_id UUID,
    
    players JSONB NOT NULL, -- Array of player IDs
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    -- CREATED, LOADING, ACTIVE, COMPLETED, FAILED
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    CONSTRAINT fk_instance_server FOREIGN KEY (instance_server_id) 
        REFERENCES instance_servers(id)
);
```

---

## API Endpoints

### Queue Management

**POST `/api/v1/matchmaking/queue`** - войти в очередь
```json
Request:
{
  "activityType": "PVP_ARENA_3V3",
  "role": "DPS",
  "mode": "RANKED"
}

Response:
{
  "queueId": "uuid",
  "position": 15,
  "estimatedWait": "2-3 minutes",
  "status": "SEARCHING"
}
```

**DELETE `/api/v1/matchmaking/queue`** - покинуть очередь

**GET `/api/v1/matchmaking/queue/status`** - статус очереди
```json
{
  "queueId": "uuid",
  "position": 10,
  "waitTime": "1m 30s",
  "playersInQueue": 45,
  "averageWait": "2m 15s"
}
```

### Match Management

**GET `/api/v1/matchmaking/matches/current`** - текущий матч
**POST `/api/v1/matchmaking/matches/{id}/accept`** - принять матч
**POST `/api/v1/matchmaking/matches/{id}/decline`** - отклонить матч

### Party Queue

**POST `/api/v1/matchmaking/party/queue`** - очередь с party
**GET `/api/v1/matchmaking/party/ready-check`** - проверка готовности party

### Ratings

**GET `/api/v1/matchmaking/ratings/{activityType}`** - рейтинг игрока
```json
{
  "rating": 1650,
  "tier": "GOLD",
  "division": 2,
  "wins": 42,
  "losses": 38,
  "winRate": 52.5,
  "rank": 1523, // Global rank
  "percentile": 75.2 // Top 25%
}
```

**GET `/api/v1/matchmaking/leaderboard/{activityType}`** - leaderboard

---

## Балансировка и Fairness

### Match Quality Score

```
Match Quality = 
    Rating Balance (40%) + 
    Role Distribution (30%) + 
    Wait Time Fairness (20%) + 
    Latency (10%)

Rating Balance:
- Разница <50 MMR: 1.0
- Разница 50-100: 0.8
- Разница 100-200: 0.6
- Разница >200: 0.3

Role Distribution:
- Идеальная композиция: 1.0
- Один role missing: 0.7
- Два roles missing: 0.4

Wait Time Fairness:
- Все ждали <3 min: 1.0
- Некоторые ждали >5 min: 0.8
- Некоторые ждали >10 min: 0.5

Latency:
- Все <50ms: 1.0
- Некоторые 50-100ms: 0.8
- Некоторые >100ms: 0.6
```

### Anti-Smurf Detection

```java
// Определение смурфов (опытные игроки на новых аккаунтах)
public boolean isSmurf(UUID playerId) {
    PlayerRating rating = ratingRepository.findByPlayer(playerId);
    
    // Признаки:
    // 1. Высокий win rate (>75%) в первых 10 играх
    if (rating.getGamesPlayed() < 10 && rating.getWinRate() > 75) {
        return true;
    }
    
    // 2. Очень быстрый рост рейтинга
    int ratingGain = rating.getRating() - 1500; // Initial rating
    if (rating.getGamesPlayed() < 20 && ratingGain > 500) {
        return true;
    }
    
    // 3. Статистика не соответствует рейтингу
    // (высокие показатели при низком рейтинге)
    
    return false;
}

// Обработка смурфов
if (isSmurf(playerId)) {
    // Ускорить калибровку (K-factor = 60 вместо 40)
    // Поднять рейтинг быстрее до реального уровня
}
```

---

## Notification System для Matchmaking

### WebSocket Messages

**Queue Status Updates:**
```json
{
  "type": "QUEUE_UPDATE",
  "queueId": "uuid",
  "position": 8,
  "estimatedWait": "1m 30s",
  "playersInQueue": 42
}
```

**Match Found:**
```json
{
  "type": "MATCH_FOUND",
  "matchId": "uuid",
  "activityType": "PVP_ARENA_3V3",
  "averageRating": 1650,
  "deadline": "2025-11-06T21:01:00Z",
  "timeToAccept": 60
}
```

**Match Ready:**
```json
{
  "type": "MATCH_READY",
  "matchId": "uuid",
  "instanceId": "instance-uuid",
  "joinToken": "token",
  "teamAssignment": "A",
  "teammates": [
    {"playerId": "uuid", "name": "PlayerName", "role": "TANK"}
  ]
}
```

**Match Cancelled:**
```json
{
  "type": "MATCH_CANCELLED",
  "matchId": "uuid",
  "reason": "PLAYER_DECLINED",
  "requeueing": true
}
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/session-management-system.md` - Session management
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - PvP/PvE механики
- `.BRAIN/05-technical/start-content/endgame-raids/raid-blackwall-expedition.md` - Raids
- `.BRAIN/05-technical/global-state-system.md` - Global state

---

## TODO

- [ ] Балансировка wait time thresholds
- [ ] Тестирование алгоритма балансировки команд
- [ ] Определить penalties за decline
- [ ] Backfill system (замена вышедших игроков в raid)

---

## История изменений

- **v1.0.0 (2025-11-06 21:55)** - Создан документ Matchmaking System

