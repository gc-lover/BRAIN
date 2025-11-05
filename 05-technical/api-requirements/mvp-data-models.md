# Модели данных для MVP

**Статус:** draft  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-04  
**Последнее обновление:** 2025-11-04  
**Приоритет:** критический

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-05 18:08  
**api-readiness-notes:** Добавлены модели навыков (Skill/CharacterSkill) и требования/эффекты. Требуется сверка с progression-*.md и equipment/implants.

---

## Общее описание

Детальные модели данных для MVP текстовой версии NECPGAME. Определяет все структуры данных, используемые в API endpoints, включая типы данных, ограничения, связи и бизнес-правила.

**Цель:** Создать полную спецификацию моделей данных для MVP, чтобы можно было создать API спецификацию в API-SWAGGER.

---

## 1. Основные модели

### 1.1. Account (Аккаунт)

**Описание:** Аккаунт пользователя в системе

**Структура:**
```json
{
  "id": "uuid",
  "email": "string",
  "username": "string",
  "passwordHash": "string",
  "createdAt": "datetime",
  "lastLogin": "datetime|null",
  "isActive": "boolean"
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор аккаунта
- `email` (string, required, unique, max 255) - email адрес, формат: стандартный email
- `username` (string, required, unique, 3-20 символов) - логин пользователя, допустимые символы: буквы (a-z, A-Z), цифры (0-9), подчеркивания (_)
- `passwordHash` (string, required, max 255) - хеш пароля (bcrypt), не возвращается в API
- `createdAt` (datetime, required) - дата создания аккаунта
- `lastLogin` (datetime, nullable) - дата последнего входа
- `isActive` (boolean, required, default: true) - активен ли аккаунт

**Валидация:**
- Email должен быть валидным email адресом
- Username должен быть уникальным
- Email должен быть уникальным
- Password должен быть минимум 8 символов (при создании)

**Связи:**
- Один ко многим с Character (один аккаунт может иметь несколько персонажей)

**Бизнес-правила:**
- Максимум 5 персонажей на аккаунт (конфигурируемо)
- После регистрации аккаунт создается с `isActive = true`
- `lastLogin` обновляется при каждом входе

---

### 1.2. Character (Персонаж)

**Описание:** Игровой персонаж

**Структура:**
```json
{
  "id": "uuid",
  "accountId": "uuid",
  "name": "string",
  "class": "string",
  "origin": "string",
  "faction": "string",
  "city": "string",
  "locationId": "uuid",
  "level": "integer",
  "experience": "integer",
  "gender": "string",
  "height": "integer",
  "distinctiveFeatures": "string|null",
  "health": {
    "current": "integer",
    "max": "integer"
  },
  "energy": {
    "current": "integer",
    "max": "integer"
  },
  "humanity": {
    "current": "integer",
    "max": "integer"
  },
  "attributes": {
    "strength": "integer",
    "reflexes": "integer",
    "intelligence": "integer",
    "technical": "integer",
    "cool": "integer"
  },
  "money": "integer",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор персонажа
- `accountId` (UUID, required, foreign key → Account.id) - ID аккаунта владельца
- `name` (string, required, unique per account, 2-30 символов) - имя персонажа, допустимые символы: буквы, цифры, пробелы, дефисы
- `class` (string, required, enum) - класс персонажа (Solo, Netrunner, Techie)
- `origin` (string, required, enum) - происхождение (Street Kid, Corpo, Nomad)
- `faction` (string, required, enum) - стартовая фракция (из списка доступных)
- `city` (string, required) - город для старта (для MVP только "Night City")
- `locationId` (UUID, required, foreign key → Location.id) - текущая локация персонажа
- `level` (integer, required, default: 1, min: 1, max: 50) - уровень персонажа
- `experience` (integer, required, default: 0, min: 0) - текущий опыт персонажа
- `gender` (string, required, enum: "male"|"female"|"other") - пол персонажа
- `height` (integer, required, min: 150, max: 220) - рост в см
- `distinctiveFeatures` (string, nullable, max 500 символов) - отличительные черты
- `health` (object, required) - здоровье персонажа
  - `current` (integer, required, min: 0, max: max) - текущее здоровье
  - `max` (integer, required, min: 1) - максимальное здоровье
- `energy` (object, required) - энергия персонажа
  - `current` (integer, required, min: 0, max: max) - текущая энергия
  - `max` (integer, required, min: 1) - максимальная энергия
- `humanity` (object, required) - человечность персонажа
  - `current` (integer, required, min: 0, max: max) - текущая человечность
  - `max` (integer, required, min: 1, default: 100) - максимальная человечность
- `attributes` (object, required) - основные характеристики
  - `strength` (integer, required, min: 1, max: 20) - сила
  - `reflexes` (integer, required, min: 1, max: 20) - ловкость
  - `intelligence` (integer, required, min: 1, max: 20) - интеллект
  - `technical` (integer, required, min: 1, max: 20) - техника
  - `cool` (integer, required, min: 1, max: 20) - холоднокровие
- `money` (integer, required, default: 500, min: 0) - деньги персонажа (eddies)
- `createdAt` (datetime, required) - дата создания персонажа
- `updatedAt` (datetime, required) - дата последнего обновления

**Валидация:**
- Имя должно быть уникальным для аккаунта
- Класс должен быть из доступных классов
- Происхождение должно быть из доступных происхождений
- Фракция должна быть доступна в городе
- Сумма атрибутов не должна превышать начальные значения класса + бонусы

**Связи:**
- Многие к одному с Account (несколько персонажей на один аккаунт)
- Многие к одному с Location (персонаж в одной локации)
- Один ко многим с InventoryItem (персонаж имеет много предметов)
- Один ко многим с QuestProgress (персонаж имеет много квестов)
- Один ко многим с CharacterReputation (персонаж имеет репутацию с фракциями)

**Бизнес-правила:**
- Максимум 5 персонажей на аккаунт
- При создании персонаж получает начальные характеристики в зависимости от класса
- При создании персонаж получает стартовые деньги в зависимости от происхождения
- При создании персонаж получает стартовое снаряжение в зависимости от класса
- Здоровье и энергия восстанавливаются при отдыхе или использовании предметов
- Человечность уменьшается при использовании имплантов (для будущего)

**Расчет значений:**
- `health.max` = 100 + (level - 1) * 10
- `energy.max` = 100 + (level - 1) * 10
- `humanity.max` = 100 (базовое, может уменьшаться при использовании имплантов)

---

### 1.3. Location (Локация)

**Описание:** Игровая локация (район или точка интереса)

**Структура:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "city": "string",
  "district": "string",
  "dangerLevel": "string",
  "minLevel": "integer",
  "type": "string",
  "connectedLocations": ["uuid"]
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор локации
- `name` (string, required, max 255) - название локации
- `description` (string, required, max 2000) - описание локации
- `city` (string, required) - город локации (для MVP только "Night City")
- `district` (string, required) - район города (Downtown, Watson, Westbrook, Santo Domingo, Heywood)
- `dangerLevel` (string, required, enum: "low"|"medium"|"high"|"extreme") - уровень опасности
- `minLevel` (integer, required, default: 1, min: 1) - минимальный уровень для доступа
- `type` (string, required, enum) - тип локации (residential, commercial, industrial, criminal, corporate)
- `connectedLocations` (array of UUID, required) - связанные локации (для перемещения)

**Валидация:**
- Название должно быть уникальным в городе
- Опасность должна соответствовать району
- Минимальный уровень должен быть обоснован

**Связи:**
- Один ко многим с Character (много персонажей в одной локации)
- Один ко многим с NPC (много NPC в одной локации)
- Многие ко многим с Location (связанные локации)

**Бизнес-правила:**
- Для MVP определено 5 районов в Night City
- Каждый район имеет несколько точек интереса
- Перемещение возможно только между связанными локациями
- Доступность локации зависит от уровня персонажа

---

### 1.4. NPC (Non-Player Character)

**Описание:** Неигровой персонаж

**Структура:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "locationId": "uuid",
  "faction": "string",
  "type": "string",
  "reputation": {
    "faction": "string",
    "baseValue": "integer"
  }
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор NPC
- `name` (string, required, max 255) - имя NPC
- `description` (string, required, max 1000) - описание NPC
- `locationId` (UUID, required, foreign key → Location.id) - локация NPC
- `faction` (string, required, enum) - фракция NPC (из списка доступных)
- `type` (string, required, enum: "trader"|"quest_giver"|"guard"|"citizen"|"enemy") - тип NPC
- `reputation` (object, required) - базовая репутация NPC с фракцией
  - `faction` (string, required) - фракция для репутации
  - `baseValue` (integer, required, default: 0, min: -100, max: 100) - базовое значение репутации

**Валидация:**
- Имя должно быть уникальным в локации (опционально)
- Фракция должна быть из списка доступных
- Тип должен соответствовать функциональности NPC

**Связи:**
- Многие к одному с Location (много NPC в одной локации)
- Один ко многим с Quest (NPC может давать квесты)
- Один к одному с Shop (торговец имеет магазин)

**Бизнес-правила:**
- Для MVP определено 10 NPC
- Каждый NPC имеет базовую функциональность (торговля, квесты, информация)
- Репутация персонажа с фракцией NPC влияет на взаимодействие
- Некоторые NPC могут быть врагами (для боя)

---

### 1.5. Item (Предмет)

**Описание:** Игровой предмет (оружие, броня, медикаменты, ресурсы)

**Структура:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "type": "string",
  "subtype": "string",
  "rarity": "string",
  "level": "integer",
  "price": "integer",
  "weight": "integer",
  "stats": {
    "damage": "integer|null",
    "defense": "integer|null",
    "healthRestore": "integer|null",
    "energyRestore": "integer|null"
  },
  "requirements": {
    "level": "integer|null",
    "class": "string|null",
    "attributes": {
      "strength": "integer|null",
      "reflexes": "integer|null",
      "intelligence": "integer|null",
      "technical": "integer|null",
      "cool": "integer|null"
    }
  }
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор предмета
- `name` (string, required, max 255) - название предмета
- `description` (string, required, max 1000) - описание предмета
- `type` (string, required, enum: "weapon"|"armor"|"implant"|"consumable"|"resource"|"quest") - тип предмета
- `subtype` (string, required, enum) - подтип предмета (зависит от type)
  - Для weapon: "pistol"|"rifle"|"smg"|"sniper"|"melee"
  - Для armor: "head"|"body"|"arms"|"legs"
  - Для consumable: "medical"|"energy"|"food"
  - Для resource: "crafting"|"component"|"electronics"
- `rarity` (string, required, enum: "common"|"uncommon"|"rare"|"epic"|"legendary") - редкость предмета
- `level` (integer, required, default: 1, min: 1) - уровень предмета
- `price` (integer, required, min: 0) - базовая цена предмета (eddies)
- `weight` (integer, required, min: 0) - вес предмета (кг)
- `stats` (object, required) - характеристики предмета
  - `damage` (integer, nullable, min: 0) - урон (для оружия)
  - `defense` (integer, nullable, min: 0) - защита (для брони)
  - `healthRestore` (integer, nullable, min: 0) - восстановление здоровья (для медикаментов)
  - `energyRestore` (integer, nullable, min: 0) - восстановление энергии (для стимуляторов)
- `requirements` (object, required) - требования для использования предмета
  - `level` (integer, nullable, min: 1) - минимальный уровень
  - `class` (string, nullable, enum) - требуемый класс
  - `attributes` (object, nullable) - требуемые атрибуты
    - `strength` (integer, nullable, min: 1, max: 20)
    - `reflexes` (integer, nullable, min: 1, max: 20)
    - `intelligence` (integer, nullable, min: 1, max: 20)
    - `technical` (integer, nullable, min: 1, max: 20)
    - `cool` (integer, nullable, min: 1, max: 20)

**Валидация:**
- Название должно быть уникальным
- Подтип должен соответствовать типу
- Статы должны соответствовать типу предмета
- Требования должны быть валидными

**Связи:**
- Один ко многим с InventoryItem (предмет может быть в инвентаре многих персонажей)
- Один ко многим с ShopItem (предмет может быть в магазинах многих NPC)

**Бизнес-правила:**
- Для MVP определено 15 предметов
- Предметы распределены по уровням (1-7)
- Цена зависит от редкости и уровня
- Предметы могут иметь требования (уровень, класс, атрибуты)

---

### 1.6. InventoryItem (Предмет в инвентаре)

**Описание:** Предмет в инвентаре персонажа

**Структура:**
```json
{
  "id": "uuid",
  "characterId": "uuid",
  "itemId": "uuid",
  "quantity": "integer",
  "equipped": "boolean",
  "slot": "string|null"
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор предмета в инвентаре
- `characterId` (UUID, required, foreign key → Character.id) - ID персонажа
- `itemId` (UUID, required, foreign key → Item.id) - ID предмета
- `quantity` (integer, required, default: 1, min: 1) - количество предметов
- `equipped` (boolean, required, default: false) - экипирован ли предмет
- `slot` (string, nullable, enum: "head"|"body"|"arms"|"legs"|"weapon1"|"weapon2") - слот экипировки (если экипирован)

**Валидация:**
- Персонаж должен существовать
- Предмет должен существовать
- Количество должно быть положительным
- Слот должен соответствовать типу предмета

**Связи:**
- Многие к одному с Character (много предметов у одного персонажа)
- Многие к одному с Item (много экземпляров одного предмета)

**Бизнес-правила:**
- Максимальный вес инвентаря зависит от уровня персонажа (100 + level * 10)
- Предмет может быть экипирован только в подходящий слот
- В одном слоте может быть только один предмет
- Квестовые предметы не могут быть проданы

---

### 1.7. Quest (Квест)

**Описание:** Игровой квест

**Структура:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "type": "string",
  "giverNpcId": "uuid",
  "level": "integer",
  "objectives": [
    {
      "id": "string",
      "description": "string",
      "type": "string",
      "target": {
        "type": "string",
        "id": "uuid|string"
      },
      "quantity": "integer"
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
  "requirements": {
    "level": "integer|null",
    "reputation": {
      "faction": "string|null",
      "minValue": "integer|null"
    },
    "completedQuests": ["uuid"]
  }
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор квеста
- `name` (string, required, max 255) - название квеста
- `description` (string, required, max 2000) - описание квеста
- `type` (string, required, enum: "main"|"side"|"daily"|"weekly"|"faction") - тип квеста
- `giverNpcId` (UUID, required, foreign key → NPC.id) - NPC, который дает квест
- `level` (integer, required, min: 1) - рекомендуемый уровень квеста
- `objectives` (array, required, min: 1) - цели квеста
  - `id` (string, required) - уникальный идентификатор цели
  - `description` (string, required, max 500) - описание цели
  - `type` (string, required, enum: "location"|"npc"|"item"|"kill"|"delivery") - тип цели
  - `target` (object, required) - цель цели
    - `type` (string, required) - тип цели (location, npc, item, enemy)
    - `id` (UUID or string, required) - ID цели
  - `quantity` (integer, required, default: 1, min: 1) - количество для выполнения
- `rewards` (object, required) - награды за выполнение квеста
  - `experience` (integer, required, min: 0) - опыт
  - `money` (integer, required, min: 0) - деньги
  - `items` (array of UUID, nullable) - предметы (ID предметов)
  - `reputation` (object, nullable) - репутация
    - `faction` (string, required) - фракция
    - `amount` (integer, required, min: -100, max: 100) - изменение репутации
- `requirements` (object, required) - требования для принятия квеста
  - `level` (integer, nullable, min: 1) - минимальный уровень
  - `reputation` (object, nullable) - требования к репутации
    - `faction` (string, required) - фракция
    - `minValue` (integer, required, min: -100, max: 100) - минимальное значение репутации
  - `completedQuests` (array of UUID, nullable) - выполненные квесты (предварительные)

**Валидация:**
- Название должно быть уникальным
- NPC должен существовать
- Цели должны быть валидными
- Награды должны быть валидными
- Требования должны быть валидными

**Связи:**
- Многие к одному с NPC (много квестов от одного NPC)
- Один ко многим с QuestProgress (много прогрессов выполнения одного квеста)
- Один ко многим с QuestItem (квест может требовать предметы)

**Бизнес-правила:**
- Для MVP определено 5 квестов
- Квесты распределены по уровням (1-5)
- Квесты могут иметь предварительные требования
- После выполнения квеста награды выдаются персонажу

---

### 1.8. QuestProgress (Прогресс квеста)

**Описание:** Прогресс выполнения квеста персонажем

**Структура:**
```json
{
  "id": "uuid",
  "characterId": "uuid",
  "questId": "uuid",
  "status": "string",
  "objectivesProgress": [
    {
      "objectiveId": "string",
      "completed": "boolean",
      "currentQuantity": "integer"
    }
  ],
  "acceptedAt": "datetime|null",
  "completedAt": "datetime|null"
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор прогресса
- `characterId` (UUID, required, foreign key → Character.id) - ID персонажа
- `questId` (UUID, required, foreign key → Quest.id) - ID квеста
- `status` (string, required, enum: "available"|"active"|"completed"|"abandoned") - статус квеста
- `objectivesProgress` (array, required) - прогресс по целям
  - `objectiveId` (string, required) - ID цели из квеста
  - `completed` (boolean, required, default: false) - выполнена ли цель
  - `currentQuantity` (integer, required, default: 0, min: 0) - текущее количество для цели
- `acceptedAt` (datetime, nullable) - дата принятия квеста
- `completedAt` (datetime, nullable) - дата завершения квеста

**Валидация:**
- Персонаж должен существовать
- Квест должен существовать
- Статус должен быть валидным
- Прогресс по целям должен соответствовать целям квеста

**Связи:**
- Многие к одному с Character (много прогрессов у одного персонажа)
- Многие к одному с Quest (много прогрессов одного квеста)

**Бизнес-правила:**
- Один персонаж может иметь только один прогресс по квесту
- Квест становится активным после принятия
- Квест становится завершенным когда все цели выполнены
- После завершения квест не может быть принят снова (для MVP)

---

### 1.9. CharacterReputation (Репутация персонажа)

**Описание:** Репутация персонажа с фракциями

**Структура:**
```json
{
  "id": "uuid",
  "characterId": "uuid",
  "faction": "string",
  "value": "integer",
  "updatedAt": "datetime"
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор репутации
- `characterId` (UUID, required, foreign key → Character.id) - ID персонажа
- `faction` (string, required, enum) - фракция (из списка доступных)
- `value` (integer, required, default: 0, min: -100, max: 100) - значение репутации
- `updatedAt` (datetime, required) - дата последнего обновления

**Валидация:**
- Персонаж должен существовать
- Фракция должна быть из списка доступных
- Значение должно быть в диапазоне -100 до 100

**Связи:**
- Многие к одному с Character (много репутаций у одного персонажа)

**Бизнес-правила:**
- Один персонаж может иметь репутацию с несколькими фракциями
- Репутация влияет на цены торговцев, доступность квестов, диалоги
- Репутация изменяется при выполнении квестов, взаимодействии с NPC

---

### 1.10. Combat (Бой)

**Описание:** Активный бой персонажа с врагом

**Структура:**
```json
{
  "id": "uuid",
  "characterId": "uuid",
  "enemyId": "uuid",
  "locationId": "uuid",
  "status": "string",
  "turn": "string",
  "characterHealth": {
    "current": "integer",
    "max": "integer"
  },
  "characterEnergy": {
    "current": "integer",
    "max": "integer"
  },
  "enemyHealth": {
    "current": "integer",
    "max": "integer"
  },
  "combatLog": [
    {
      "timestamp": "datetime",
      "actor": "string",
      "action": "string",
      "description": "string",
      "damage": "integer|null",
      "effects": ["string"]
    }
  ],
  "startedAt": "datetime",
  "endedAt": "datetime|null",
  "victory": "boolean|null"
}
```

**Поля:**
- `id` (UUID, required, primary key) - уникальный идентификатор боя
- `characterId` (UUID, required, foreign key → Character.id) - ID персонажа
- `enemyId` (UUID, required, foreign key → NPC.id) - ID врага (NPC)
- `locationId` (UUID, required, foreign key → Location.id) - ID локации боя
- `status` (string, required, enum: "active"|"ended") - статус боя
- `turn` (string, required, enum: "player"|"enemy") - чей ход
- `characterHealth` (object, required) - здоровье персонажа в бою
  - `current` (integer, required, min: 0, max: max)
  - `max` (integer, required, min: 1)
- `characterEnergy` (object, required) - энергия персонажа в бою
  - `current` (integer, required, min: 0, max: max)
  - `max` (integer, required, min: 1)
- `enemyHealth` (object, required) - здоровье врага в бою
  - `current` (integer, required, min: 0, max: max)
  - `max` (integer, required, min: 1)
- `combatLog` (array, required) - лог боя
  - `timestamp` (datetime, required) - время действия
  - `actor` (string, required, enum: "player"|"enemy") - кто выполнил действие
  - `action` (string, required) - тип действия
  - `description` (string, required, max 500) - описание действия
  - `damage` (integer, nullable, min: 0) - урон
  - `effects` (array of string, nullable) - эффекты
- `startedAt` (datetime, required) - дата начала боя
- `endedAt` (datetime, nullable) - дата окончания боя
- `victory` (boolean, nullable) - победа персонажа (null если бой не завершен)

**Валидация:**
- Персонаж должен существовать
- Враг должен существовать и быть типа "enemy"
- Локация должна существовать
- Статус должен быть валидным

**Связи:**
- Многие к одному с Character (много боев у одного персонажа)
- Многие к одному с NPC (много боев с одним врагом)
- Многие к одному с Location (много боев в одной локации)

**Бизнес-правила:**
- Бой может быть начат только если персонаж и враг в одной локации
- Бой заканчивается когда здоровье персонажа или врага достигает 0
- После победы выдаются награды (опыт, деньги, лут)
- После завершения бой архивируется или удаляется

---

## 2. Справочные модели

### 2.1. CharacterClass (Класс персонажа)

**Описание:** Класс персонажа (справочник)

**Структура:**
```json
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
  },
  "startingSkills": ["string"],
  "startingEquipment": ["uuid"]
}
```

**Поля:**
- `id` (string, required, primary key) - идентификатор класса (Solo, Netrunner, Techie)
- `name` (string, required, max 255) - название класса
- `description` (string, required, max 1000) - описание класса
- `startingAttributes` (object, required) - начальные характеристики
  - Все атрибуты (integer, required, min: 1, max: 20)
- `startingSkills` (array of string, nullable) - начальные навыки
- `startingEquipment` (array of UUID, nullable) - стартовое снаряжение (ID предметов)

**Бизнес-правила:**
- Для MVP определено 3 класса (Solo, Netrunner, Techie)
- Каждый класс имеет уникальные начальные характеристики
- Сумма начальных атрибутов должна быть одинаковой для всех классов (для баланса)

---

### 2.2. CharacterOrigin (Происхождение персонажа)

**Описание:** Происхождение персонажа (справочник)

**Структура:**
```json
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
```

**Поля:**
- `id` (string, required, primary key) - идентификатор происхождения (Street Kid, Corpo, Nomad)
- `name` (string, required, max 255) - название происхождения
- `description` (string, required, max 1000) - описание происхождения
- `bonuses` (object, required) - бонусы происхождения
  - `reputation` (object, nullable) - бонус репутации
    - `faction` (string, required) - фракция
    - `value` (integer, required, min: -100, max: 100) - значение бонуса
  - `startingMoney` (integer, required, min: 0) - стартовые деньги

**Бизнес-правила:**
- Для MVP определено 3 происхождения (Street Kid, Corpo, Nomad)
- Каждое происхождение дает бонусы при создании персонажа

---

### 2.3. Faction (Фракция)

**Описание:** Фракция (справочник)

**Структура:**
```json
{
  "id": "string",
  "name": "string",
  "type": "string",
  "description": "string",
  "availableInCities": ["string"]
}
```

**Поля:**
- `id` (string, required, primary key) - идентификатор фракции
- `name` (string, required, max 255) - название фракции
- `type` (string, required, enum: "corporation"|"gang"|"organization") - тип фракции
- `description` (string, required, max 1000) - описание фракции
- `availableInCities` (array of string, required) - доступные города (для MVP только "Night City")

**Бизнес-правила:**
- Для MVP определено 5 фракций (Arasaka, Militech, Valentinos, Maelstrom, NCPD)
- Фракции доступны в определенных городах
- Репутация с фракциями влияет на игровой процесс

---

### 2.4. City (Город)

**Описание:** Город (справочник)

**Структура:**
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "availableFactions": ["string"]
}
```

**Поля:**
- `id` (string, required, primary key) - идентификатор города
- `name` (string, required, max 255) - название города
- `description` (string, required, max 1000) - описание города
- `availableFactions` (array of string, required) - доступные фракции (ID фракций)

**Бизнес-правила:**
- Для MVP доступен только "Night City"
- Город имеет список доступных фракций

---

### 2.5. Skill (Навык)

**Описание:** Справочник навыков (активные/пассивные/поддерживающие)

**Структура:**
```json
{
  "id": "string",
  "name": "string",
  "category": "string",
  "type": "string",
  "base": {
    "value": "number",
    "resource": "string",
    "cooldownSec": "number"
  },
  "attributeCoefficients": {
    "STR": "number",
    "REF": "number",
    "INT": "number",
    "TECH": "number",
    "COOL": "number",
    "AGI": "number",
    "WILL": "number",
    "EMP": "number"
  },
  "requirements": {
    "level": "integer|null",
    "class": "string|null",
    "subclass": "string|null",
    "attributes": {"STR":"integer|null","REF":"integer|null","INT":"integer|null","TECH":"integer|null","COOL":"integer|null","AGI":"integer|null","WILL":"integer|null","EMP":"integer|null"},
    "items": [{"type":"string","subtype":"string"}],
    "implants": [{"slotType":"string","tier":"string|null"}]
  },
  "links": {
    "items": ["uuid"],
    "implants": ["uuid"],
    "synergyTags": ["string"]
  },
  "rankScaling": {
    "ranks": [
      {"rank":1,"baseBonus":0.0,"costReduction":0.0,"cooldownReduction":0.0},
      {"rank":2,"baseBonus":0.05,"costReduction":0.05,"cooldownReduction":0.05},
      {"rank":3,"baseBonus":0.10,"costReduction":0.10,"cooldownReduction":0.10},
      {"rank":4,"baseBonus":0.15,"costReduction":0.15,"cooldownReduction":0.15},
      {"rank":5,"baseBonus":0.20,"costReduction":0.20,"cooldownReduction":0.20}
    ]
  },
  "exclusiveTo": {"class":"string|null","subclass":"string|null"},
  "description": "string"
}
```

**Поля:**
- `type` (enum): "active"|"passive"|"support"
- `category` (enum): gunplay|melee|mobility|stealth|hacking|tech|social
- `base.value` — базовый эффект (проценты/единицы) для формул из `progression-skills.md`
- `attributeCoefficients` — коэффициенты атрибутов (см. `progression-attributes.md`)
- `requirements.items/implants` — соответствуют типам из `equipment-matrix.md` и `combat-implants-types.md`

---

### 2.6. CharacterSkill (Навык персонажа)

**Описание:** Прогресс и ранги навыков персонажа

**Структура:**
```json
{
  "id": "uuid",
  "characterId": "uuid",
  "skillId": "string",
  "rank": "integer",
  "experience": "integer",
  "lastUsedAt": "datetime|null"
}
```

**Поля:**
- `rank` (1-5)
- `experience` — опыт навыка (используется для апа ранга)
- `lastUsedAt` — анти-абуз/лимиты (см. дневной мягкий лимит)

**Связи:**
- Многие к одному с Character
- Многие к одному со Skill

---

## 3. Связи между моделями

### 3.1. Диаграмма связей

```
Account (1) ──< (N) Character
Character (1) ──< (N) InventoryItem
Character (1) ──< (N) QuestProgress
Character (1) ──< (N) CharacterReputation
Character (1) ──< (N) Combat

Location (1) ──< (N) Character
Location (1) ──< (N) NPC
Location (1) ──< (N) Combat

NPC (1) ──< (N) Quest
NPC (1) ──< (1) Shop (опционально)

Item (1) ──< (N) InventoryItem
Item (1) ──< (N) ShopItem (опционально)

Quest (1) ──< (N) QuestProgress
```

---

## 4. TODO и вопросы

### 4.1. Критические TODO

**TODO:** Детализация системы навыков (Skills):
- [x] Базовые модели Skill/CharacterSkill (в этом документе)
- [ ] Наполнение справочника навыков (по категориям)
- [ ] Связи с предметами/имплантами (ID, теги)

**TODO:** Детализация системы перков (Perks) - требуется для разнообразия персонажей.

**TODO:** Детализация системы имплантов (Implants) - требуется для будущего функционала.

**TODO:** Детализация системы магазинов (Shops) - требуется для полноценной торговли.

**TODO:** Детализация системы времени (GameTime) - требуется для реалистичности игрового процесса.

---

### 4.2. Вопросы для проработки

**Q1:** Нужна ли отдельная таблица для навыков персонажа?
- **Решение (гибридный подход):** Да, для навыков нужна отдельная таблица CharacterSkill, чтобы можно было отслеживать прогресс каждого навыка отдельно.

**Q2:** Нужна ли отдельная таблица для магазинов NPC?
- **Решение:** Да, для торговцев нужна таблица Shop с ShopItem для управления товарами в магазинах.

**Q3:** Нужна ли отдельная таблица для логов действий?
- **Решение:** Для MVP не нужна, но для будущего можно добавить таблицу CharacterActionLog для отслеживания действий персонажа.

---

## 5. Связанные документы

- [API Endpoints](./mvp-endpoints.md) - endpoints, использующие эти модели
- [Минимальный набор данных](../mvp-initial-data.md) - конкретные данные для MVP
- [План MVP](../mvp-text-version-plan.md) - общий план MVP

---

## История изменений

- v1.0.0 (2025-11-04) - Создание документа с детальными моделями данных для MVP

