# MVP Endpoints - Part 3: Quests & Interactions

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:28  
**Часть:** 3 из 4

[← Part 2](./part2-world-inventory.md) | [Навигация](./README.md) | [Part 4 →](./part4-trading-technical.md)

---

## 5. Quests

### GET /api/v1/characters/{characterId}/quests
**Список квестов персонажа**

**Response 200:**
```json
{
  "active": [...],
  "completed": [...],
  "available": [...]
}
```

---

### POST /api/v1/characters/{characterId}/quests/{questId}/start
**Начать квест**

**Response 200:**
```json
{
  "quest": {
    "id": "uuid",
    "name": "The Rescue",
    "status": "active",
    "objectives": [...]
  }
}
```

---

### POST /api/v1/characters/{characterId}/quests/{questId}/complete
**Завершить квест**

**Response 200:**
```json
{
  "quest": {...},
  "rewards": {
    "experience": 500,
    "money": 1000,
    "items": [...]
  }
}
```

---

## 6. NPC & Interactions

### GET /api/v1/npcs/{npcId}
**Информация об NPC**

**Response 200:**
```json
{
  "id": "uuid",
  "name": "Jackie Welles",
  "faction": "Valentinos",
  "relationship": 50,
  "dialogue": [...]
}
```

---

### POST /api/v1/characters/{characterId}/npcs/{npcId}/interact
**Взаимодействие с NPC**

**Request:**
```json
{
  "action": "talk",
  "dialogueChoice": "option1"
}
```

**Response 200:**
```json
{
  "npcResponse": "...",
  "relationshipChange": +5,
  "nextChoices": [...]
}
```

---

## 7. Combat (Текстовый)

### POST /api/v1/characters/{characterId}/combat/start
**Начать бой**

**Request:**
```json
{
  "enemyId": "uuid"
}
```

**Response 200:**
```json
{
  "combatId": "uuid",
  "player": {...},
  "enemy": {...},
  "turn": 1
}
```

---

### POST /api/v1/characters/{characterId}/combat/{combatId}/action
**Действие в бою**

**Request:**
```json
{
  "action": "attack",
  "target": "enemy",
  "ability": "pistol_shot"
}
```

**Response 200:**
```json
{
  "result": "hit",
  "damage": 25,
  "enemyHP": 75,
  "nextTurn": "player"
}
```

---

[Part 4: Trading & Technical →](./part4-trading-technical.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:28) - Создан из mvp-endpoints.md

