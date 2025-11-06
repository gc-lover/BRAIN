# MVP Endpoints - Part 4: Trading & Technical

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:29  
**Часть:** 4 из 4

[← Part 3](./part3-quests-interactions.md) | [Навигация](./README.md)

---

## 8. Trading (Опционально)

### GET /api/v1/shops/{shopId}/items
**Товары в магазине**

**Response 200:**
```json
{
  "shopName": "Weapon Shop",
  "items": [
    {
      "id": "uuid",
      "name": "Pistol",
      "price": 500,
      "stock": 10
    }
  ]
}
```

---

### POST /api/v1/characters/{characterId}/shops/{shopId}/buy
**Купить предмет**

**Request:**
```json
{
  "itemId": "uuid",
  "quantity": 1
}
```

**Response 200:**
```json
{
  "purchase": {
    "item": {...},
    "totalPrice": 500
  },
  "newBalance": 1500
}
```

---

### POST /api/v1/characters/{characterId}/shops/{shopId}/sell
**Продать предмет**

**Request:**
```json
{
  "itemId": "uuid",
  "quantity": 1
}
```

**Response 200:**
```json
{
  "sale": {
    "item": {...},
    "totalPrice": 250
  },
  "newBalance": 2250
}
```

---

## 9. Error Handling

**Standard Error Response:**
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

**Error Codes:**
- `VALIDATION_ERROR` (400)
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `NOT_FOUND` (404)
- `CONFLICT` (409)
- `INTERNAL_ERROR` (500)

---

## 10. Validation

**General Rules:**
- All requests validated
- Auth required (except /auth/)
- Rate limiting: 100 req/min
- Max request size: 1MB

---

## 11. TODO

- [ ] WebSocket для real-time updates
- [ ] Clan/Guild endpoints
- [ ] PvP endpoints
- [ ] Crafting endpoints
- [ ] Reputation system API

---

## 12. Связанные документы

- [MVP Data Models](../mvp-data-models.md)
- [API Data Models](../../api-specs/api-data-models.md)
- [Authentication System](../../backend/authentication-authorization-system.md)
- [Global State System](../../global-state-system/README.md)

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:29) - Создан из mvp-endpoints.md

