---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:25  
**api-readiness-notes:** World State Player Impact Mechanics. Механика влияния игроков на мир, типы воздействий. ~420 строк.
---

# Player Impact Mechanics - Механика влияния на мир

**Статус:** approved  
**Версия:** 1.0.0  
**Дата:** 2025-11-07 06:25  
**Приоритет:** КРИТИЧЕСКИЙ  
**Автор:** AI Brain Manager

**Микрофича:** Player impact mechanics  
**Размер:** ~420 строк ✅

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-173](../../../API-SWAGGER/tasks/active/queue/task-173-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: WORLD_STATE_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Типы влияния

### 1. Quest Impact (влияние через квесты)

**Механика:**
```
Quest Choice → World State Change
```

**Примеры:**
- Выбор в квесте → изменение судьбы NPC (fate)
- Решение проблемы → изменение контроля территории
- Поддержка фракции → изменение силы фракции

### 2. Economic Impact (экономическое влияние)

**Механика:**
```
Player Actions → Supply/Demand → Prices
```

**Примеры:**
- Массовая продажа → падение цены
- Массовая скупка → рост цены
- Крафт → изменение доступности ресурсов

### 3. Political Impact (политическое влияние)

**Механика:**
```
Player Votes → Election Results
Player Orders → Territory Control
```

**Примеры:**
- Голосование за мэра → избрание
- Заказы на защиту → контроль территории
- Война фракций → изменение границ

### 4. Social Impact (социальное влияние)

**Механика:**
```
Reputation → NPC Behavior
Relationships → New Options
```

**Примеры:**
- Высокая репутация → доступ к контенту
- Романтические отношения → уникальные способности
- Гильдия → коллективное влияние

---

## Aggregation (аггрегация действий)

### Vote Counting

```java
public String calculateTerritoryController(String territoryId) {
    Map<String, Long> votes = playerActionRepository
        .countVotesByTerritory(territoryId);
    
    // Majority wins
    return votes.entrySet().stream()
        .max(Map.Entry.comparingByValue())
        .map(Map.Entry::getKey)
        .orElse("independent");
}
```

### Price Calculation

```java
public int calculateItemPrice(String itemId) {
    long supply = marketRepository.countSupply(itemId);
    long demand = marketRepository.countDemand(itemId);
    
    int basePrice = itemTemplateRepository.getBasePrice(itemId);
    
    // Supply/Demand влияние
    double ratio = (double) demand / supply;
    return (int) (basePrice * ratio);
}
```

---

## Thresholds (пороги влияния)

**Минимальное количество игроков для влияния:**
- Quest impact: 1 игрок (личное влияние)
- Economic impact: 100+ игроков (значимое)
- Political impact: 1000+ игроков (мировое)
- Territory control: 5000+ игроков (война)

**Время применения:**
- Instant (quest choices)
- Hourly (economy recalc)
- Daily (territory control)
- Weekly (elections, seasons)

---

## Связанные документы

- `.BRAIN/02-gameplay/world/world-state/player-impact-systems.md` - Systems (микрофича 2/3)
- `.BRAIN/02-gameplay/world/world-state/player-impact-persistence.md` - Persistence (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 06:25)** - Микрофича 1/3 (split from world-state-player-impact.md)

