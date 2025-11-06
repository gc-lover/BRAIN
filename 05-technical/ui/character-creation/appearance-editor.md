---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:35  
**api-readiness-notes:** Character Appearance Editor. Внешность персонажа. ~150 строк.
---

# Appearance Editor - Редактор внешности

**Статус:** approved  
**Версия:** 1.0.0  
**Дата:** 2025-11-07 06:35  
**Приоритет:** КРИТИЧЕСКИЙ (MVP)  
**Автор:** AI Brain Manager

**Микрофича:** Appearance customization  
**Размер:** ~150 строк ✅

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-173](../../../API-SWAGGER/tasks/active/queue/task-173-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: UI_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Options

**Body:**
- Skin Tone (10 options)
- Body Type (slim, athletic, muscular)

**Face:**
- Hair Style (20 options)
- Hair Color (15 colors)
- Eye Color (12 colors)
- Face Shape (preset faces)

**Cyberware (visual):**
- Visible implants
- Eye augmentations
- Arm modifications

---

## API

**POST /api/v1/characters** - includes appearance data:

```json
{
  "appearance": {
    "skinTone": "string",
    "bodyType": "athletic",
    "hairStyle": "string",
    "hairColor": "string",
    "eyeColor": "string"
  }
}
```

---

## Связанные документы

- `.BRAIN/05-technical/ui/character-creation/creation-flow.md` - Flow (микрофича 1/2)

---

## История изменений

- **v1.0.0 (2025-11-07 06:35)** - Микрофича 2/2 (split from ui-character-creation.md)

