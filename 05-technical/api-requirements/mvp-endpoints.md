# API Endpoints для MVP

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-04  
**Последнее обновление:** 2025-11-06  
**Приоритет:** критический

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 18:15  
**api-readiness-notes:** Все API endpoints детально определены (auth, characters, locations, inventory, quests, NPCs, combat, trade). Готово для создания OpenAPI спецификации в API-SWAGGER.

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-169](../../../API-SWAGGER/tasks/active/queue/task-169-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Общее описание

Детальные API endpoints для MVP текстовой версии NECPGAME. Определяет все необходимые endpoints для работы игры, включая аутентификацию, персонажи, локации, инвентарь, квесты, NPC, бой и торговлю.

**Цель:** Создать полную спецификацию API endpoints для MVP, чтобы можно было создать API спецификацию в API-SWAGGER.

---

## 1. Аутентификация и авторизация

### 1.1. POST /api/v1/auth/register

**Описание:** Регистрация нового аккаунта

**Request Body:**
```json
{
  "email": "string",
  "username": "string",
  "password": "string"
}
```

**Валидация:**
- `email` (required, string, email format): валидный email адрес, уникальный
- `username` (required, string, 3-20 символов): логин пользователя, допустимые символы: буквы, цифры, подчеркивания, уникальный
- `password` (required, string, минимум 8 символов): пароль, должен содержать буквы и цифры

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "accountId": "uuid",
  "message": "Account created successfully"
}
```

- **400 Bad Request:** Невалидные данные
- **409 Conflict:** Email или username уже существует
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Email должен быть уникальным
- Username должен быть уникальным
- Пароль должен быть захеширован перед сохранением
- После регистрации аккаунт создается, но не активируется автоматически (для будущего)

---

### 1.2. POST /api/v1/auth/login

**Описание:** Вход в систему

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Валидация:**
- `username` (required, string): логин пользователя
- `password` (required, string): пароль

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "token": "string",
  "refreshToken": "string",
  "expiresIn": "integer",
  "account": {
    "id": "uuid",
    "username": "string",
    "email": "string"
  }
}
```

- **401 Unauthorized:** Неверный username или password
- **403 Forbidden:** Аккаунт заблокирован
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- JWT токен выдается при успешном входе
- Refresh token выдается для обновления токена
- Токен действителен 24 часа (конфигурируемо)
- После входа обновляется `last_login` у аккаунта

---

### 1.3. POST /api/v1/auth/logout

**Описание:** Выход из системы

**Headers:**
- `Authorization: Bearer {token}` (required)

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Токен добавляется в blacklist (для будущего)
- После выхода токен становится недействительным

---

### 1.4. GET /api/v1/auth/me

**Описание:** Получение информации о текущем аккаунте

**Headers:**
- `Authorization: Bearer {token}` (required)

**Response:**
- **200 OK:**
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

- **401 Unauthorized:** Токен невалиден или отсутствует
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 1.5. POST /api/v1/auth/refresh

**Описание:** Обновление токена

**Request Body:**
```json
{
  "refreshToken": "string"
}
```

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "token": "string",
  "refreshToken": "string",
  "expiresIn": "integer"
}
```

- **401 Unauthorized:** Refresh token невалиден или истек
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Refresh token должен быть валидным
- Выдается новый access token и refresh token

---

## 2. Персонажи

### 2.1. GET /api/v1/characters

**Описание:** Получение списка персонажей текущего аккаунта

**Headers:**
- `Authorization: Bearer {token}` (required)

**Response:**
- **200 OK:**
```json
{
  "characters": [
    {
      "id": "uuid",
      "name": "string",
      "class": "string",
      "level": "integer",
      "city": "string",
      "faction": "string",
      "createdAt": "datetime"
    }
  ]
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Возвращаются только персонажи текущего аккаунта
- Максимум 5 персонажей на аккаунт (конфигурируемо)

---

### 2.2. POST /api/v1/characters

**Описание:** Создание нового персонажа

**Headers:**
- `Authorization: Bearer {token}` (required)

**Request Body:**
```json
{
  "name": "string",
  "class": "string",
  "origin": "string",
  "faction": "string",
  "city": "string",
  "gender": "male|female|other",
  "height": "integer",
  "distinctiveFeatures": "string"
}
```

**Валидация:**
- `name` (required, string, 2-30 символов): имя персонажа, уникальное для аккаунта, допустимые символы: буквы, цифры, пробелы, дефисы
- `class` (required, string, enum): класс персонажа (Solo, Netrunner, Techie)
- `origin` (required, string, enum): происхождение (Street Kid, Corpo, Nomad)
- `faction` (required, string, enum): стартовая фракция (из списка доступных)
- `city` (required, string): город для старта (для MVP только Night City)
- `gender` (required, string, enum): пол персонажа
- `height` (required, integer, 150-220): рост в см
- `distinctiveFeatures` (optional, string, max 500 символов): отличительные черты

**Response:**
- **201 Created:**
```json
{
  "success": true,
  "character": {
    "id": "uuid",
    "name": "string",
    "class": "string",
    "level": 1,
    "experience": 0,
    "city": "string",
    "faction": "string",
    "createdAt": "datetime"
  }
}
```

- **400 Bad Request:** Невалидные данные
- **401 Unauthorized:** Токен невалиден или отсутствует
- **409 Conflict:** Имя персонажа уже существует
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Имя персонажа должно быть уникальным для аккаунта
- Максимум 5 персонажей на аккаунт
- Персонаж создается с начальными характеристиками (уровень 1, опыт 0, базовые статы)
- Персонаж создается в указанном городе с начальной локацией

---

### 2.3. GET /api/v1/characters/{characterId}

**Описание:** Получение информации о персонаже

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "id": "uuid",
  "name": "string",
  "class": "string",
  "origin": "string",
  "faction": "string",
  "city": "string",
  "level": "integer",
  "experience": "integer",
  "createdAt": "datetime"
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Персонаж должен принадлежать текущему аккаунту

---

### 2.4. DELETE /api/v1/characters/{characterId}

**Описание:** Удаление персонажа

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Character deleted successfully"
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Персонаж должен принадлежать текущему аккаунту
- При удалении удаляются все связанные данные (инвентарь, квесты, прогресс)

---

### 2.5. GET /api/v1/characters/{characterId}/status

**Описание:** Получение статуса персонажа (здоровье, энергия, человечность)

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "characterId": "uuid",
  "name": "string",
  "level": "integer",
  "experience": "integer",
  "health": {
    "current": "integer",
    "max": "integer",
    "percentage": "integer"
  },
  "energy": {
    "current": "integer",
    "max": "integer",
    "percentage": "integer"
  },
  "humanity": {
    "current": "integer",
    "max": "integer",
    "percentage": "integer"
  }
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 2.6. GET /api/v1/characters/{characterId}/stats

**Описание:** Получение характеристик персонажа

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "characterId": "uuid",
  "attributes": {
    "strength": "integer",
    "reflexes": "integer",
    "intelligence": "integer",
    "technical": "integer",
    "cool": "integer"
  },
  "skills": [
    {
      "name": "string",
      "level": "integer",
      "maxLevel": "integer"
    }
  ]
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 2.7. GET /api/v1/characters/classes

**Описание:** Получение списка доступных классов

**Response:**
- **200 OK:**
```json
{
  "classes": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "startingAttributes": {
        "strength": "integer",
        "reflexes": "integer",
        "intelligence": "integer",
        "technical": "integer",
        "cool": "integer"
      }
    }
  ]
}
```

- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 2.8. GET /api/v1/characters/origins

**Описание:** Получение списка доступных происхождений

**Response:**
- **200 OK:**
```json
{
  "origins": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "bonuses": {
        "reputation": {
          "faction": "string",
          "value": "integer"
        },
        "startingMoney": "integer"
      }
    }
  ]
}
```

- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 2.9. GET /api/v1/factions

**Описание:** Получение списка доступных фракций

**Query Parameters:**
- `city` (optional, string): фильтр по городу

**Response:**
- **200 OK:**
```json
{
  "factions": [
    {
      "id": "string",
      "name": "string",
      "type": "corporation|gang|organization",
      "description": "string",
      "availableInCities": ["string"]
    }
  ]
}
```

- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 2.10. GET /api/v1/locations/cities

**Описание:** Получение списка доступных городов

**Response:**
- **200 OK:**
```json
{
  "cities": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "availableFactions": ["string"]
    }
  ]
}
```

- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Для MVP доступен только Night City

---

## 3. Локации

### 3.1. GET /api/v1/locations/current

**Описание:** Получение текущей локации персонажа

**Headers:**
- `Authorization: Bearer {token}` (required)

**Query Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "locationId": "uuid",
  "name": "string",
  "description": "string",
  "city": "string",
  "district": "string",
  "dangerLevel": "low|medium|high|extreme",
  "connectedLocations": [
    {
      "id": "uuid",
      "name": "string",
      "district": "string",
      "dangerLevel": "string",
      "travelTime": "integer"
    }
  ],
  "npcs": ["uuid"],
  "availableActions": ["explore|talk|use|rest|hack|combat"]
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден или не имеет локации
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 3.2. GET /api/v1/locations/{locationId}

**Описание:** Получение информации о локации

**Path Parameters:**
- `locationId` (required, uuid): ID локации

**Response:**
- **200 OK:** Аналогично GET /api/v1/locations/current

- **404 Not Found:** Локация не найдена
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 3.3. GET /api/v1/locations

**Описание:** Получение списка доступных локаций (для карты)

**Query Parameters:**
- `city` (optional, string): фильтр по городу
- `district` (optional, string): фильтр по району
- `dangerLevel` (optional, string): фильтр по опасности (low|medium|high|extreme)
- `minLevel` (optional, integer): минимальный уровень

**Response:**
- **200 OK:**
```json
{
  "locations": [
    {
      "id": "uuid",
      "name": "string",
      "city": "string",
      "district": "string",
      "dangerLevel": "string",
      "minLevel": "integer",
      "available": "boolean"
    }
  ]
}
```

- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 3.4. GET /api/v1/locations/{locationId}/actions

**Описание:** Получение доступных действий в локации

**Path Parameters:**
- `locationId` (required, uuid): ID локации

**Query Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "locationId": "uuid",
  "actions": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "type": "explore|talk|use|rest|hack|combat",
      "available": "boolean",
      "requirements": {
        "level": "integer",
        "skills": ["string"],
        "items": ["uuid"]
      }
    }
  ]
}
```

- **404 Not Found:** Локация не найдена
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Доступность действий зависит от уровня персонажа, навыков и предметов
- Некоторые действия могут быть недоступны в зависимости от состояния персонажа

---

### 3.5. GET /api/v1/locations/{locationId}/npcs

**Описание:** Получение списка NPC в локации

**Path Parameters:**
- `locationId` (required, uuid): ID локации

**Response:**
- **200 OK:**
```json
{
  "locationId": "uuid",
  "npcs": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string",
      "faction": "string",
      "type": "trader|quest_giver|guard|citizen",
      "availableQuests": ["uuid"]
    }
  ]
}
```

- **404 Not Found:** Локация не найдена
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 3.6. POST /api/v1/locations/move

**Описание:** Перемещение персонажа между локациями

**Headers:**
- `Authorization: Bearer {token}` (required)

**Request Body:**
```json
{
  "characterId": "uuid",
  "targetLocationId": "uuid"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа
- `targetLocationId` (required, uuid): ID целевой локации

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "newLocationId": "uuid",
  "travelTime": "integer",
  "message": "string"
}
```

- **400 Bad Request:** Локация недоступна или требования не выполнены
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту или локация недоступна
- **404 Not Found:** Персонаж или локация не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Персонаж должен соответствовать требованиям локации (уровень, репутация)
- Локация должна быть связана с текущей локацией персонажа
- Перемещение занимает время (5-10 минут игрового времени)
- Перемещение может стоить денег (опционально, зависит от способа перемещения)

---

## 4. Инвентарь

### 4.1. GET /api/v1/inventory/{characterId}

**Описание:** Получение инвентаря персонажа

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "characterId": "uuid",
  "weight": {
    "current": "integer",
    "max": "integer"
  },
  "equipped": {
    "head": "uuid|null",
    "body": "uuid|null",
    "arms": "uuid|null",
    "legs": "uuid|null",
    "weapon1": "uuid|null",
    "weapon2": "uuid|null",
    "implants": ["uuid"]
  },
  "items": [
    {
      "id": "uuid",
      "itemId": "uuid",
      "name": "string",
      "type": "weapon|armor|implant|consumable|resource|quest",
      "quantity": "integer",
      "equipped": "boolean",
      "slot": "string|null"
    }
  ]
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 4.2. POST /api/v1/inventory/{characterId}/equip

**Описание:** Экипировка предмета

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Request Body:**
```json
{
  "inventoryItemId": "uuid",
  "slot": "head|body|arms|legs|weapon1|weapon2"
}
```

**Валидация:**
- `inventoryItemId` (required, uuid): ID предмета в инвентаре
- `slot` (required, string, enum): слот для экипировки

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Item equipped successfully"
}
```

- **400 Bad Request:** Предмет не может быть экипирован в этот слот или требования не выполнены
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж или предмет не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Предмет должен быть в инвентаре персонажа
- Предмет должен соответствовать типу слота (оружие для weapon1/weapon2, броня для body/head/arms/legs)
- Если в слоте уже есть предмет, он автоматически снимается и возвращается в инвентарь
- Предмет должен соответствовать требованиям персонажа (уровень, класс)

---

### 4.3. POST /api/v1/inventory/{characterId}/unequip

**Описание:** Снятие предмета

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Request Body:**
```json
{
  "inventoryItemId": "uuid"
}
```

**Валидация:**
- `inventoryItemId` (required, uuid): ID предмета в инвентаре

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Item unequipped successfully"
}
```

- **400 Bad Request:** Предмет не экипирован
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж или предмет не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Предмет должен быть экипирован
- После снятия предмет возвращается в инвентарь

---

### 4.4. POST /api/v1/inventory/{characterId}/use

**Описание:** Использование предмета (расходника)

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Request Body:**
```json
{
  "inventoryItemId": "uuid"
}
```

**Валидация:**
- `inventoryItemId` (required, uuid): ID предмета в инвентаре

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "effects": {
    "health": "integer",
    "energy": "integer"
  },
  "message": "Item used successfully"
}
```

- **400 Bad Request:** Предмет не может быть использован или уже использован
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж или предмет не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Предмет должен быть расходником (consumable)
- Предмет должен быть в инвентаре
- После использования предмет удаляется из инвентаря (если quantity = 1) или уменьшается количество
- Эффекты применяются к персонажу (восстановление здоровья, энергии)

---

## 5. Квесты

### 5.1. GET /api/v1/quests/{characterId}

**Описание:** Получение списка квестов персонажа

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `characterId` (required, uuid): ID персонажа

**Query Parameters:**
- `status` (optional, string): фильтр по статусу (active|completed|available)
- `type` (optional, string): фильтр по типу (main|side|daily|weekly|faction)

**Response:**
- **200 OK:**
```json
{
  "characterId": "uuid",
  "activeQuests": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string",
      "type": "string",
      "progress": {
        "current": "integer",
        "total": "integer"
      },
      "objectives": [
        {
          "id": "string",
          "description": "string",
          "completed": "boolean"
        }
      ],
      "rewards": {
        "experience": "integer",
        "money": "integer",
        "items": ["uuid"],
        "reputation": {
          "faction": "string",
          "amount": "integer"
        }
      }
    }
  ],
  "availableQuests": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string",
      "type": "string",
      "giverNpcId": "uuid",
      "rewards": {
        "experience": "integer",
        "money": "integer"
      },
      "requirements": {
        "level": "integer",
        "reputation": {
          "faction": "string",
          "minValue": "integer"
        }
      }
    }
  ]
}
```

- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 5.2. GET /api/v1/quests/{questId}

**Описание:** Получение детальной информации о квесте

**Path Parameters:**
- `questId` (required, uuid): ID квеста

**Response:**
- **200 OK:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "type": "string",
  "giverNpcId": "uuid",
  "progress": {
    "current": "integer",
    "total": "integer"
  },
  "objectives": [
    {
      "id": "string",
      "description": "string",
      "completed": "boolean",
      "target": {
        "type": "location|npc|item|kill",
        "id": "uuid|string"
      }
    }
  ],
  "rewards": {
    "experience": "integer",
    "money": "integer",
    "items": ["uuid"],
    "reputation": {
      "faction": "string",
      "amount": "integer"
    }
  },
  "status": "active|completed|available"
}
```

- **404 Not Found:** Квест не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 5.3. POST /api/v1/quests/{questId}/accept

**Описание:** Принятие квеста

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `questId` (required, uuid): ID квеста

**Request Body:**
```json
{
  "characterId": "uuid"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Quest accepted successfully"
}
```

- **400 Bad Request:** Квест недоступен или требования не выполнены
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Квест или персонаж не найдены
- **409 Conflict:** Квест уже принят
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Персонаж должен соответствовать требованиям квеста (уровень, репутация)
- Квест должен быть доступен (не принят, не выполнен)
- После принятия квест становится активным для персонажа

---

### 5.4. POST /api/v1/quests/{questId}/complete

**Описание:** Завершение квеста

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `questId` (required, uuid): ID квеста

**Request Body:**
```json
{
  "characterId": "uuid"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "rewards": {
    "experience": "integer",
    "money": "integer",
    "items": ["uuid"],
    "reputation": {
      "faction": "string",
      "amount": "integer"
    }
  },
  "message": "Quest completed successfully"
}
```

- **400 Bad Request:** Квест не завершен или цели не выполнены
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту или квест не принят
- **404 Not Found:** Квест или персонаж не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Все цели квеста должны быть выполнены
- Квест должен быть активным для персонажа
- После завершения награды выдаются персонажу (опыт, деньги, предметы, репутация)
- Квест помечается как завершенный

---

### 5.5. POST /api/v1/quests/{questId}/abandon

**Описание:** Отказ от квеста

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `questId` (required, uuid): ID квеста

**Request Body:**
```json
{
  "characterId": "uuid"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Quest abandoned successfully"
}
```

- **400 Bad Request:** Квест не может быть отменен
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту или квест не принят
- **404 Not Found:** Квест или персонаж не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Квест должен быть активным для персонажа
- После отмены квест становится доступным для принятия снова
- Прогресс квеста сбрасывается

---

## 6. NPC и взаимодействие

### 6.1. GET /api/v1/npcs/{npcId}

**Описание:** Получение информации о NPC

**Path Parameters:**
- `npcId` (required, uuid): ID NPC

**Response:**
- **200 OK:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "locationId": "uuid",
  "faction": "string",
  "type": "trader|quest_giver|guard|citizen",
  "reputation": {
    "faction": "string",
    "value": "integer"
  },
  "availableQuests": ["uuid"],
  "tradeAvailable": "boolean"
}
```

- **404 Not Found:** NPC не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 6.2. GET /api/v1/npcs/{npcId}/dialogue

**Описание:** Получение диалогов с NPC

**Path Parameters:**
- `npcId` (required, uuid): ID NPC

**Query Parameters:**
- `characterId` (optional, uuid): ID персонажа (для персонализации диалогов)

**Response:**
- **200 OK:**
```json
{
  "npcId": "uuid",
  "greeting": "string",
  "dialogueOptions": [
    {
      "id": "string",
      "text": "string",
      "requirements": {
        "reputation": {
          "faction": "string",
          "minValue": "integer"
        },
        "quests": ["uuid"]
      }
    }
  ]
}
```

- **404 Not Found:** NPC не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Диалоги могут быть персонализированы в зависимости от репутации персонажа с фракцией
- Некоторые опции диалога могут быть недоступны в зависимости от выполненных квестов

---

### 6.3. POST /api/v1/npcs/{npcId}/interact

**Описание:** Взаимодействие с NPC

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `npcId` (required, uuid): ID NPC

**Request Body:**
```json
{
  "characterId": "uuid",
  "action": "talk|trade|quest|leave",
  "dialogueOptionId": "string|null"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа
- `action` (required, string, enum): тип взаимодействия
- `dialogueOptionId` (optional, string): ID опции диалога (для action = "talk")

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "response": "string",
  "tradeData": "object|null",
  "questData": "object|null"
}
```

- **400 Bad Request:** Действие недоступно или требования не выполнены
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** NPC или персонаж не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Действие зависит от типа NPC (торговец - trade, квестодатель - quest)
- Репутация персонажа влияет на доступность действий и цены
- Диалоги могут влиять на репутацию

---

## 7. Бой (текстовая версия)

### 7.1. POST /api/v1/combat/start

**Описание:** Начало боя

**Headers:**
- `Authorization: Bearer {token}` (required)

**Request Body:**
```json
{
  "characterId": "uuid",
  "enemyId": "uuid",
  "locationId": "uuid"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа
- `enemyId` (required, uuid): ID врага (NPC или другой персонаж)
- `locationId` (required, uuid): ID локации боя

**Response:**
- **200 OK:**
```json
{
  "combatId": "uuid",
  "character": {
    "health": {
      "current": "integer",
      "max": "integer"
    },
    "energy": {
      "current": "integer",
      "max": "integer"
    }
  },
  "enemy": {
    "id": "uuid",
    "name": "string",
    "health": {
      "current": "integer",
      "max": "integer"
    },
    "description": "string"
  },
  "turn": "player|enemy",
  "availableActions": ["attack|defend|ability|item|escape"]
}
```

- **400 Bad Request:** Бой недоступен или требования не выполнены
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж, враг или локация не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Бой может быть начат только если персонаж и враг находятся в одной локации
- Бой создается с начальными параметрами (здоровье, энергия)
- Первый ход определяется случайно или по характеристикам

---

### 7.2. GET /api/v1/combat/{combatId}/status

**Описание:** Получение статуса боя

**Path Parameters:**
- `combatId` (required, uuid): ID боя

**Response:**
- **200 OK:**
```json
{
  "combatId": "uuid",
  "character": {
    "health": {
      "current": "integer",
      "max": "integer"
    },
    "energy": {
      "current": "integer",
      "max": "integer"
    }
  },
  "enemy": {
    "id": "uuid",
    "name": "string",
    "health": {
      "current": "integer",
      "max": "integer"
    }
  },
  "turn": "player|enemy",
  "availableActions": ["string"],
  "combatLog": [
    {
      "timestamp": "datetime",
      "actor": "player|enemy",
      "action": "string",
      "description": "string",
      "damage": "integer|null",
      "effects": ["string"]
    }
  ]
}
```

- **404 Not Found:** Бой не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

---

### 7.3. POST /api/v1/combat/{combatId}/action

**Описание:** Выполнение действия в бою

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `combatId` (required, uuid): ID боя

**Request Body:**
```json
{
  "action": "attack|defend|ability|item|escape",
  "target": "enemy|self",
  "abilityId": "uuid|null",
  "itemId": "uuid|null"
}
```

**Валидация:**
- `action` (required, string, enum): тип действия
- `target` (required, string, enum): цель действия
- `abilityId` (optional, uuid): ID способности (для action = "ability")
- `itemId` (optional, uuid): ID предмета (для action = "item")

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "turn": "player|enemy",
  "actionResult": {
    "actor": "player|enemy",
    "action": "string",
    "description": "string",
    "damage": "integer|null",
    "effects": ["string"]
  },
  "character": {
    "health": {
      "current": "integer",
      "max": "integer"
    },
    "energy": {
      "current": "integer",
      "max": "integer"
    }
  },
  "enemy": {
    "health": {
      "current": "integer",
      "max": "integer"
    }
  },
  "combatEnded": "boolean",
  "victory": "boolean|null",
  "rewards": {
    "experience": "integer",
    "money": "integer",
    "items": ["uuid"]
  }|null
}
```

- **400 Bad Request:** Действие недоступно или невалидно
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту или не его ход
- **404 Not Found:** Бой не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Действие может быть выполнено только в ход игрока
- После действия выполняется ход врага автоматически
- Бой заканчивается когда здоровье персонажа или врага достигает 0
- После победы выдаются награды (опыт, деньги, лут)

---

### 7.4. POST /api/v1/combat/{combatId}/end

**Описание:** Завершение боя (побег или завершение)

**Headers:**
- `Authorization: Bearer {token}` (required)

**Path Parameters:**
- `combatId` (required, uuid): ID боя

**Request Body:**
```json
{
  "reason": "escape|victory|defeat"
}
```

**Валидация:**
- `reason` (required, string, enum): причина завершения боя

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Combat ended successfully"
}
```

- **400 Bad Request:** Бой не может быть завершен
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Бой не найден
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Побег возможен только в определенных условиях
- После завершения бой удаляется или архивируется

---

## 8. Торговля (опционально для MVP)

### 8.1. GET /api/v1/trade/shops/{npcId}

**Описание:** Получение товаров у торговца

**Path Parameters:**
- `npcId` (required, uuid): ID торговца

**Query Parameters:**
- `characterId` (optional, uuid): ID персонажа (для расчета цен с учетом репутации)

**Response:**
- **200 OK:**
```json
{
  "npcId": "uuid",
  "shopName": "string",
  "items": [
    {
      "id": "uuid",
      "name": "string",
      "type": "string",
      "price": "integer",
      "quantity": "integer",
      "description": "string"
    }
  ],
  "reputationDiscount": "integer"
}
```

- **404 Not Found:** NPC не найден или не является торговцем
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Цены зависят от репутации персонажа с фракцией торговца
- Скидка применяется автоматически при положительной репутации

---

### 8.2. POST /api/v1/trade/buy

**Описание:** Покупка предмета

**Headers:**
- `Authorization: Bearer {token}` (required)

**Request Body:**
```json
{
  "characterId": "uuid",
  "npcId": "uuid",
  "itemId": "uuid",
  "quantity": "integer"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа
- `npcId` (required, uuid): ID торговца
- `itemId` (required, uuid): ID предмета
- `quantity` (required, integer, min: 1): количество предметов

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Item purchased successfully",
  "remainingMoney": "integer"
}
```

- **400 Bad Request:** Недостаточно денег или предмет недоступен
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж, торговец или предмет не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Персонаж должен иметь достаточно денег
- Предмет должен быть доступен у торговца
- После покупки предмет добавляется в инвентарь, деньги списываются

---

### 8.3. POST /api/v1/trade/sell

**Описание:** Продажа предмета

**Headers:**
- `Authorization: Bearer {token}` (required)

**Request Body:**
```json
{
  "characterId": "uuid",
  "npcId": "uuid",
  "inventoryItemId": "uuid",
  "quantity": "integer"
}
```

**Валидация:**
- `characterId` (required, uuid): ID персонажа
- `npcId` (required, uuid): ID торговца
- `inventoryItemId` (required, uuid): ID предмета в инвентаре
- `quantity` (required, integer, min: 1): количество предметов

**Response:**
- **200 OK:**
```json
{
  "success": true,
  "message": "Item sold successfully",
  "moneyReceived": "integer",
  "newMoney": "integer"
}
```

- **400 Bad Request:** Предмет не может быть продан или недостаточно предметов
- **401 Unauthorized:** Токен невалиден или отсутствует
- **403 Forbidden:** Персонаж не принадлежит аккаунту
- **404 Not Found:** Персонаж, торговец или предмет не найдены
- **500 Internal Server Error:** Внутренняя ошибка сервера

**Бизнес-правила:**
- Предмет должен быть в инвентаре персонажа
- Квестовые предметы не могут быть проданы
- Цена продажи обычно ниже цены покупки (50-70%)
- После продажи предмет удаляется из инвентаря, деньги добавляются

---

## 9. Обработка ошибок

### 9.1. Стандартные коды ошибок

**HTTP коды:**
- `200 OK` - Успешный запрос
- `201 Created` - Ресурс создан
- `400 Bad Request` - Некорректный запрос (валидация не прошла)
- `401 Unauthorized` - Не авторизован (токен невалиден или отсутствует)
- `403 Forbidden` - Нет доступа (ресурс не принадлежит аккаунту)
- `404 Not Found` - Ресурс не найден
- `409 Conflict` - Конфликт (ресурс уже существует или недоступен)
- `500 Internal Server Error` - Внутренняя ошибка сервера

---

### 9.2. Формат ошибки

**Стандартный формат:**
```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": "object|null"
  }
}
```

**Примеры:**

**400 Bad Request:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "field": "name",
      "reason": "Name must be between 2 and 30 characters"
    }
  }
}
```

**401 Unauthorized:**
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or missing token"
  }
}
```

**403 Forbidden:**
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Character does not belong to account"
  }
}
```

**404 Not Found:**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Character not found"
  }
}
```

**409 Conflict:**
```json
{
  "error": {
    "code": "CONFLICT",
    "message": "Character name already exists"
  }
}
```

**500 Internal Server Error:**
```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "Internal server error"
  }
}
```

---

## 10. Валидация данных

### 10.1. Общие правила валидации

**Строки:**
- Минимальная длина: определяется для каждого поля
- Максимальная длина: определяется для каждого поля
- Допустимые символы: определяется для каждого поля (обычно буквы, цифры, пробелы, дефисы, подчеркивания)

**Числа:**
- Минимальное значение: определяется для каждого поля
- Максимальное значение: определяется для каждого поля
- Тип: integer или float

**UUID:**
- Формат: стандартный UUID v4
- Валидация: проверка формата

**Enum:**
- Значения: только из определенного списка
- Валидация: проверка соответствия списку

---

### 10.2. Бизнес-правила валидации

**Персонажи:**
- Имя должно быть уникальным для аккаунта
- Максимум 5 персонажей на аккаунт
- Класс должен быть из доступных классов
- Происхождение должно быть из доступных происхождений
- Фракция должна быть доступна в городе

**Локации:**
- Перемещение возможно только в связанные локации
- Персонаж должен соответствовать требованиям локации (уровень, репутация)

**Квесты:**
- Персонаж должен соответствовать требованиям квеста (уровень, репутация)
- Квест должен быть доступен (не принят, не выполнен)

**Инвентарь:**
- Предмет должен соответствовать типу слота
- Предмет должен соответствовать требованиям персонажа (уровень, класс)

---

## 11. TODO и вопросы

### 11.1. Критические TODO

**TODO:** Детализация системы боя (расчет урона, защита, эффекты) - требуется для полноценной реализации боя.

**TODO:** Детализация системы репутации (влияние на цены, доступность квестов, диалоги) - требуется для балансировки.

**TODO:** Детализация системы прокачки (опыт за действия, уровни, перки) - требуется для балансировки.

**TODO:** Детализация системы времени (игровое время, время перемещения, время боя) - требуется для реалистичности.

---

### 11.2. Вопросы для проработки

**Q1:** Нужна ли система пагинации для списков (персонажи, локации, квесты)?
- **Решение (гибридный подход):** Да, для больших списков (персонажи, квесты) нужна пагинация, для малых списков (локации для MVP) не нужна.

**Q2:** Нужна ли система кеширования для справочных данных (классы, происхождения, фракции)?
- **Решение (гибридный подход):** Да, для справочных данных нужен кеш на клиенте, для динамических данных (персонажи, квесты) кеш не нужен.

**Q3:** Нужна ли система rate limiting для API?
- **Решение:** Да, для защиты от злоупотреблений нужен rate limiting (например, 100 запросов в минуту на аккаунт).

---

## 12. Связанные документы

- [План MVP](../mvp-text-version-plan.md) - общий план MVP
- [Основной интерфейс](../ui-main-game.md) - интерфейсы для работы с API
- [Минимальный набор данных](../mvp-initial-data.md) - данные для MVP
- [Модели данных](./mvp-data-models.md) - детальные модели данных (требует создания)

---

## История изменений

- v1.0.0 (2025-11-04) - Создание документа с детальными API endpoints для MVP

