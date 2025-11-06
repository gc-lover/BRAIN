---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:35  
**api-readiness-notes:** Romance Event Triggers. Условия активации романтических событий. ~340 строк.
---

# Romance Event Triggers - Триггеры событий

**Статус:** approved  
**Версия:** 1.0.0  
**Дата:** 2025-11-07 06:35  
**Приоритет:** средний  
**Автор:** AI Brain Manager

**Микрофича:** Event triggers  
**Размер:** ~340 строк ✅

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-175](../../../API-SWAGGER/tasks/active/queue/task-175-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: ALGORITHMS_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Trigger System

```typescript
interface RomanceTrigger {
  eventId: string;
  npcId: string;
  conditions: {
    minRelationship: number; // 0-100
    requiredFlags: string[];
    requiredQuests: string[];
    minLevel: number;
    location?: string;
    timeOfDay?: "morning" | "afternoon" | "evening" | "night";
  };
}
```

---

## Example Triggers

```typescript
// Morgana Romance Event 1
{
  eventId: "ROMANCE_MORGANA_001",
  npcId: "npc_morgana",
  conditions: {
    minRelationship: 20,
    requiredFlags: ["morgana_trust_start"],
    requiredQuests: ["NCPD-MORGANA-001"],
    minLevel: 10,
    location: "nightCity.watson.ncpdHq",
    timeOfDay: "evening"
  }
}
```

---

## Trigger Evaluation

```java
public boolean canTriggerEvent(String playerId, String eventId) {
    RomanceEvent event = romanceRepository.findById(eventId);
    RomanceTrigger trigger = event.getTrigger();
    
    // Check relationship
    int relationship = relationshipService.get(playerId, trigger.getNpcId());
    if (relationship < trigger.getMinRelationship()) return false;
    
    // Check flags
    if (!flagService.hasAll(playerId, trigger.getRequiredFlags())) return false;
    
    // Check quests
    if (!questService.hasCompleted(playerId, trigger.getRequiredQuests())) return false;
    
    // Check level
    if (getLevel(playerId) < trigger.getMinLevel()) return false;
    
    return true;
}
```

---

## Связанные документы

- `.BRAIN/05-technical/algorithms/romance/romance-relationship.md` - Relationship (микрофича 2/3)
- `.BRAIN/05-technical/algorithms/romance/romance-dialogue.md` - Dialogue (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 06:35)** - Микрофича 1/3 (split from romance-event-engine.md)

