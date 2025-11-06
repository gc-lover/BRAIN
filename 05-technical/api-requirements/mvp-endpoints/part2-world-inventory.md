# MVP Endpoints - Part 2: World & Inventory

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:27  
**Часть:** 2 из 4

[← Part 1](./part1-auth-characters.md) | [Навигация](./README.md) | [Part 3 →](./part3-quests-interactions.md)

---

## 3. Locations

### GET /api/v1/locations
**Получить список доступных локаций**

**Response 200:**
```json
{
  "locations": [
    {
      "id": "uuid",
      "name": "Night City - Watson",
      "description": "...",
      "available": true
    }
  ]
}
```

---

### GET /api/v1/locations/{locationId}
**Детали локации**

**Response 200:**
```json
{
  "id": "uuid",
  "name": "Night City - Watson",
  "description": "...",
  "npcs": [...],
  "quests": [...],
  "shops": [...]
}
```

---

### POST /api/v1/characters/{characterId}/move
**Переместить персонажа в локацию**

**Request:**
```json
{
  "locationId": "uuid"
}
```

**Response 200:**
```json
{
  "currentLocation": "Night City - Watson",
  "message": "Moved successfully"
}
```

---

## 4. Inventory

### GET /api/v1/characters/{characterId}/inventory
**Получить инвентарь**

**Response 200:**
```json
{
  "capacity": 100,
  "used": 45,
  "items": [
    {
      "id": "uuid",
      "name": "Mantis Blades",
      "type": "weapon",
      "quantity": 1,
      "equipped": true
    }
  ]
}
```

---

### POST /api/v1/characters/{characterId}/inventory/equip
**Надеть/снять предмет**

**Request:**
```json
{
  "itemId": "uuid",
  "action": "equip"
}
```

**Response 200:**
```json
{
  "item": {...},
  "equipped": true
}
```

---

### DELETE /api/v1/characters/{characterId}/inventory/{itemId}
**Удалить предмет из инвентаря**

**Response 200:**
```json
{
  "message": "Item removed"
}
```

---

[Part 3: Quests & Interactions →](./part3-quests-interactions.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:27) - Создан из mvp-endpoints.md

