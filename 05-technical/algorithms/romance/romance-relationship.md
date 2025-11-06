---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:35  
**api-readiness-notes:** Romance Relationship Calc. Расчет отношений, этапы романтики. ~340 строк.
---

# Romance Relationship - Расчет отношений

**Статус:** approved  
**Версия:** 1.0.0  
**Дата:** 2025-11-07 06:35  
**Приоритет:** средний  
**Автор:** AI Brain Manager

**Микрофича:** Relationship calculation  
**Размер:** ~340 строк ✅

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-175](../../../API-SWAGGER/tasks/active/queue/task-175-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: ALGORITHMS_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Relationship Points

**Range:** -100 to +100

**Stages:**
```
-100 to -50: Hostile
-49 to 0: Dislike
1 to 20: Neutral
21 to 50: Friendly
51 to 75: Close
76 to 90: Romantic Interest
91 to 100: Love
```

---

## Point Calculation

```java
public void updateRelationship(String playerId, String npcId, int change) {
    int current = relationshipRepository.get(playerId, npcId);
    int newValue = Math.max(-100, Math.min(100, current + change));
    
    relationshipRepository.set(playerId, npcId, newValue);
    
    // Check stage transitions
    String prevStage = getStage(current);
    String newStage = getStage(newValue);
    
    if (!prevStage.equals(newStage)) {
        eventPublisher.publish(new RelationshipStageChangedEvent(
            playerId, npcId, prevStage, newStage
        ));
    }
}
```

---

## Связанные документы

- `.BRAIN/05-technical/algorithms/romance/romance-triggers.md` - Triggers (микрофича 1/3)
- `.BRAIN/05-technical/algorithms/romance/romance-dialogue.md` - Dialogue (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 06:35)** - Микрофича 2/3 (split from romance-event-engine.md)

