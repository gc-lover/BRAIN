---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:05  
**api-readiness-notes:** MVP Auth Endpoints. Register, login, logout, refresh, /me. ~200 строк.
---

# MVP Auth Endpoints - Аутентификация

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** КРИТИЧЕСКИЙ (MVP)  
**Автор:** AI Brain Manager

**Микрофича:** Authentication endpoints  
**Размер:** ~200 строк ✅  
**API Task:** API-TASK-169 (создан)

---

## Микросервисная архитектура

**Ответственный микросервис:** auth-service  
**Порт:** 8081  
**API Gateway:** http://localhost:8080  
**Статус:** ✅ Реализовано

**Маршрутизация:**
```
Frontend → http://localhost:8080/api/v1/auth/*
  ↓ (API Gateway routing)
auth-service (localhost:8081)
  ↓
Response → API Gateway → Frontend
```

**API Tasks Status:**
- ✅ Задача создана: [API-TASK-173](../../../API-SWAGGER/tasks/active/queue/task-173-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: MVP_ENDPOINTS_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Endpoints

### POST /api/v1/auth/register

**Request:**
```json
{
  "email": "string",
  "username": "string",
  "password": "string"
}
```

**Response 200:**
```json
{
  "success": true,
  "accountId": "uuid",
  "message": "Account created"
}
```

**Validation:**
- email: required, email format, unique
- username: required, 3-20 символов, unique
- password: required, минимум 8 символов

---

### POST /api/v1/auth/login

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response 200:**
```json
{
  "success": true,
  "token": "string",
  "refreshToken": "string",
  "expiresIn": 86400,
  "account": {
    "id": "uuid",
    "username": "string",
    "email": "string"
  }
}
```

---

### POST /api/v1/auth/logout

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### GET /api/v1/auth/me

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "createdAt": "datetime",
  "lastLogin": "datetime",
  "isActive": true
}
```

---

### POST /api/v1/auth/refresh

**Request:**
```json
{
  "refreshToken": "string"
}
```

**Response 200:**
```json
{
  "success": true,
  "token": "string",
  "refreshToken": "string",
  "expiresIn": 86400
}
```

---

## Связанные документы

- `.BRAIN/05-technical/api-requirements/mvp-endpoints/gameplay-endpoints.md` - Gameplay (микрофича 2/4)
- `.BRAIN/05-technical/api-requirements/mvp-endpoints/content-endpoints.md` - Content (микрофича 3/4)
- `.BRAIN/05-technical/api-requirements/mvp-endpoints/system-endpoints.md` - System (микрофича 4/4)

---

## История изменений

- **v1.0.0 (2025-11-07 06:05)** - Микрофича 1/4: Auth Endpoints (split from mvp-endpoints.md)

