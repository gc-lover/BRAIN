---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Matchmaking Algorithm микрофича. Алгоритмы подбора, балансировка команд, team composition. ~380 строк.
---

# Matchmaking Algorithm - Алгоритмы подбора

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:30  
**Приоритет:** критический  
**Автор:** AI Brain Manager

**Микрофича:** Matchmaking algorithm  
**Размер:** ~380 строк ✅

---


**API Tasks Status:**
- 🚫 Документ отмечен как OBSOLETE (устаревшая split версия)
- 📝 Причина: Consolidated into unified document
- 🔄 Статус: not-applicable
- ⚠️ Этот документ является split версией, которая была объединена в consolidated документ

---

## Краткое описание

**Matchmaking Algorithm** - алгоритмы для справедливого подбора и балансировки команд.

**Ключевые возможности:**
- ✅ PvP match algorithm (балансировка по MMR)
- ✅ PvE match algorithm (role-based)
- ✅ Team balancing (snake draft)
- ✅ Match quality score
- ✅ Anti-smurf detection

---

## PvP Match Algorithm

```java
private Match findPvPMatch(List<QueueEntry> queue, int teamSize) {
    int requiredPlayers = teamSize * 2; // 2 команды
    
    if (queue.size() < requiredPlayers) {
        return null;
    }
    
    // 1. Найти группу с близким рейтингом
    for (int i = 0; i <= queue.size() - requiredPlayers; i++) {
        List<QueueEntry> candidates = queue.subList(i, i + requiredPlayers);
        
        // 2. Проверить рейтинг
        int minRating = candidates.stream().mapToInt(QueueEntry::getRating).min().orElse(0);
        int maxRating = candidates.stream().mapToInt(QueueEntry::getRating).max().orElse(0);
        int spread = maxRating - minRating;
        
        if (spread > candidates.get(0).getCurrentRatingRange()) {
            continue; // Слишком большой разброс
        }
        
        // 3. Балансировка команд
        TeamDivision division = balanceTeams(candidates, teamSize);
        
        if (division.getRatingDifference() > 100) {
            continue; // Несбалансированы
        }
        
        return new Match(division.getTeamA(), division.getTeamB());
    }
    
    return null;
}
```

---

## Team Balancing

### Snake Draft Algorithm

```java
private TeamDivision balanceTeams(List<QueueEntry> players, int teamSize) {
    // Сортировать по рейтингу
    players.sort(Comparator.comparing(QueueEntry::getRating).reversed());
    
    List<QueueEntry> teamA = new ArrayList<>();
    List<QueueEntry> teamB = new ArrayList<>();
    
    // Snake draft: A B B A A B B A...
    for (int i = 0; i < players.size(); i++) {
        if (i % 4 == 0 || i % 4 == 3) {
            teamA.add(players.get(i));
        } else {
            teamB.add(players.get(i));
        }
    }
    
    int avgRatingA = teamA.stream().mapToInt(QueueEntry::getRating).average().orElse(0);
    int avgRatingB = teamB.stream().mapToInt(QueueEntry::getRating).average().orElse(0);
    
    return new TeamDivision(teamA, teamB, avgRatingA, avgRatingB);
}
```

---

## PvE Match Algorithm

```java
private Match findPvEMatch(List<QueueEntry> queue, int requiredPlayers) {
    // PvE нужен 1 Tank, 1 Healer, 3 DPS
    
    Map<Role, List<QueueEntry>> byRole = queue.stream()
        .collect(Collectors.groupingBy(QueueEntry::getPreferredRole));
    
    // Проверить роли
    if (byRole.getOrDefault(Role.TANK, List.of()).isEmpty() ||
        byRole.getOrDefault(Role.HEALER, List.of()).isEmpty()) {
        return null; // Нет tank/healer
    }
    
    // Выбрать игроков
    List<QueueEntry> matchPlayers = new ArrayList<>();
    matchPlayers.add(byRole.get(Role.TANK).get(0));
    matchPlayers.add(byRole.get(Role.HEALER).get(0));
    
    // 3 DPS
    List<QueueEntry> dpsPool = new ArrayList<>();
    dpsPool.addAll(byRole.getOrDefault(Role.DPS, List.of()));
    
    if (dpsPool.size() < 3) {
        return null;
    }
    
    matchPlayers.addAll(dpsPool.subList(0, 3));
    
    return new Match(matchPlayers, null); // PvE - одна команда
}
```

---

## Match Quality Score

```
Match Quality = 
    Rating Balance (40%) + 
    Role Distribution (30%) + 
    Wait Time Fairness (20%) + 
    Latency (10%)
```

---

## API Endpoints

**POST `/api/v1/matchmaking/matches/{id}/accept`** - принять матч
**POST `/api/v1/matchmaking/matches/{id}/decline`** - отклонить

---

## Связанные документы

- `.BRAIN/05-technical/backend/matchmaking/matchmaking-queue.md` - Queue (микрофича 1/3)
- `.BRAIN/05-technical/backend/matchmaking/matchmaking-rating.md` - Rating (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Микрофича 2/3: Matchmaking Algorithm (split from matchmaking-system.md)




