---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:05  
**api-readiness-notes:** MVP Content Endpoints. Quests, NPC, Combat, Trading. ~380 строк.
---

# MVP Content Endpoints - Контент игры

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 06:05  
**Приоритет:** КРИТИЧЕСКИЙ (MVP)  
**Автор:** AI Brain Manager

**Микрофича:** Quests, NPCs, Combat, Trading  
**Размер:** ~380 строк ✅  
**API Task:** API-TASK-169

---

## Quests

### GET /api/v1/quests/available

**Query Params:**
- `characterId` (required)
- `city` (optional)
- `zone` (optional)

**Response 200:**
```json
{
  "quests": [
    {
      "id": "NCPD-MORGANA-001",
      "title": "string",
      "description": "string",
      "level": 1,
      "type": "main|side|extract",
      "location": {
        "city": "nightCity",
        "zone": "watson"
      },
      "rewards": {
        "experience": 1000,
        "eurodollars": 500
      }
    }
  ]
}
```

---

### POST /api/v1/quests/start

**Request:**
```json
{
  "characterId": "uuid",
  "questId": "NCPD-MORGANA-001"
}
```

**Response 200:**
```json
{
  "success": true,
  "quest": {
    "id": "NCPD-MORGANA-001",
    "status": "active",
    "currentNode": 1
  }
}
```

---

### GET /api/v1/quests/{questId}/progress

**Query:** `characterId`

**Response 200:**
```json
{
  "questId": "NCPD-MORGANA-001",
  "status": "active",
  "currentNode": 2,
  "currentBranch": "pathTruth",
  "completedObjectives": ["obj_1", "obj_2"],
  "choices": [
    {
      "nodeId": 2,
      "choiceId": "A2",
      "choiceText": "Доложить IA",
      "timestamp": "datetime"
    }
  ]
}
```

---

### POST /api/v1/quests/{questId}/choice

**Request:**
```json
{
  "characterId": "uuid",
  "nodeId": 2,
  "choiceId": "A2"
}
```

**Response 200:**
```json
{
  "success": true,
  "nextNode": 4,
  "branchId": "pathTruth",
  "consequences": {
    "reputation": {"NCPD": +10},
    "flags": ["morgana_truth_start"]
  }
}
```

---

## NPC Interaction

### GET /api/v1/npcs/{npcId}

**Response 200:**
```json
{
  "id": "npc_morgana",
  "name": "Morgana Blackburn",
  "type": "quest_giver",
  "location": {
    "city": "nightCity",
    "zone": "watson",
    "location": "ncpd_hq"
  },
  "relationship": 0,
  "availableQuests": ["NCPD-MORGANA-001"],
  "availableDialogues": ["greeting_neutral"]
}
```

---

### POST /api/v1/npcs/{npcId}/interact

**Request:**
```json
{
  "characterId": "uuid",
  "interactionType": "dialogue|trade|hire"
}
```

**Response 200:**
```json
{
  "success": true,
  "dialogue": {
    "text": "string",
    "responses": [
      {"id": "resp_1", "text": "string"}
    ]
  }
}
```

---

## Combat (Text-based)

### POST /api/v1/combat/start

**Request:**
```json
{
  "characterId": "uuid",
  "enemyId": "string"
}
```

**Response 200:**
```json
{
  "combatId": "uuid",
  "turn": 1,
  "player": {
    "hp": 100,
    "abilities": ["attack", "defend", "special"]
  },
  "enemy": {
    "name": "Gang Member",
    "hp": 50,
    "abilities": ["attack"]
  }
}
```

---

### POST /api/v1/combat/{combatId}/action

**Request:**
```json
{
  "characterId": "uuid",
  "action": "attack|defend|ability",
  "abilityId": "string"
}
```

**Response 200:**
```json
{
  "success": true,
  "playerAction": {
    "type": "attack",
    "damage": 15
  },
  "enemyAction": {
    "type": "attack",
    "damage": 8
  },
  "playerHp": 92,
  "enemyHp": 35,
  "combatEnded": false
}
```

---

## Trading

### GET /api/v1/trade/market/{city}

**Response 200:**
```json
{
  "items": [
    {
      "id": "uuid",
      "itemId": "pistol_rare",
      "name": "Rare Pistol",
      "price": 2000,
      "sellerId": "uuid",
      "stock": 1
    }
  ]
}
```

---

### POST /api/v1/trade/buy

**Request:**
```json
{
  "characterId": "uuid",
  "listingId": "uuid",
  "quantity": 1
}
```

**Response 200:**
```json
{
  "success": true,
  "item": {
    "id": "uuid",
    "name": "Rare Pistol"
  },
  "paidAmount": 2000
}
```

---

## Связанные документы

- `.BRAIN/05-technical/api-requirements/mvp-endpoints/auth-endpoints.md` - Auth (микрофича 1/4)
- `.BRAIN/05-technical/api-requirements/mvp-endpoints/gameplay-endpoints.md` - Gameplay (микрофича 2/4)
- `.BRAIN/05-technical/api-requirements/mvp-endpoints/system-endpoints.md` - System (микрофича 4/4)

---

## История изменений

- **v1.0.0 (2025-11-07 06:05)** - Микрофича 3/4: Content Endpoints (split from mvp-endpoints.md)

