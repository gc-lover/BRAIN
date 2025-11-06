# MVP Endpoints - Part 1: Auth & Characters

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:26  
**Часть:** 1 из 4

[Навигация](./README.md) | [Part 2 →](./part2-world-inventory.md)

---

## 1. Authentication & Authorization

### POST /api/v1/auth/register
**Регистрация нового аккаунта**

**Request:**
```json
{
  "email": "user@example.com",
  "username": "player1",
  "password": "password123"
}
```

**Response 201:**
```json
{
  "userId": "uuid",
  "email": "user@example.com",
  "username": "player1"
}
```

---

### POST /api/v1/auth/login
**Вход в аккаунт**

**Request:**
```json
{
  "username": "player1",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "accessToken": "JWT_TOKEN",
  "refreshToken": "REFRESH_TOKEN",
  "expiresIn": 3600
}
```

---

### POST /api/v1/auth/logout
**Выход из аккаунта**

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "message": "Logged out successfully"
}
```

---

### POST /api/v1/auth/refresh
**Обновление access token**

**Request:**
```json
{
  "refreshToken": "REFRESH_TOKEN"
}
```

**Response 200:**
```json
{
  "accessToken": "NEW_JWT_TOKEN",
  "expiresIn": 3600
}
```

---

## 2. Characters

### GET /api/v1/characters
**Получить список персонажей пользователя**

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "characters": [
    {
      "id": "uuid",
      "name": "V",
      "origin": "Corpo",
      "lifepath": "Corporate Rat",
      "level": 5,
      "location": "Night City - Watson"
    }
  ]
}
```

---

### POST /api/v1/characters
**Создать нового персонажа**

**Request:**
```json
{
  "name": "V",
  "origin": "Corpo",
  "lifepath": "Corporate Rat",
  "attributes": {
    "body": 5,
    "intelligence": 7,
    "reflex": 6,
    "technical": 5,
    "cool": 8
  }
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "name": "V",
  "origin": "Corpo",
  "level": 1,
  "createdAt": "2025-11-07T01:26:00Z"
}
```

---

### GET /api/v1/characters/{characterId}
**Получить данные персонажа**

**Response 200:**
```json
{
  "id": "uuid",
  "name": "V",
  "level": 5,
  "attributes": {...},
  "skills": {...},
  "inventory": {...},
  "location": "Night City - Watson"
}
```

---

### DELETE /api/v1/characters/{characterId}
**Удалить персонажа**

**Response 200:**
```json
{
  "message": "Character deleted successfully"
}
```

---

[Part 2: World & Inventory →](./part2-world-inventory.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:26) - Создан из mvp-endpoints.md

