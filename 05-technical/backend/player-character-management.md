---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Полная система управления игроками и персонажами. Account profiles, character creation/deletion, character switching, slots, data storage, appearance customization.
---

# Player & Character Management System - Управление игроками и персонажами

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

---

## Краткое описание

**Player & Character Management System** - критически важная система для управления профилями игроков и их персонажами. Без этой системы игра не может запуститься. Обеспечивает создание, хранение, переключение и управление персонажами игроков.

**Ключевые возможности:**
- ✅ Player profiles (профили пользователей)
- ✅ Character creation/deletion
- ✅ Character switching (переключение между персонажами)
- ✅ Character slots (ограничение количества персонажей)
- ✅ Character data storage (attributes, skills, inventory IDs, progress)
- ✅ Character appearance (кастомизация внешности)
- ✅ Character naming (уникальные имена, валидация)
- ✅ Character restore (восстановление удаленных персонажей)

---

## Архитектура системы

### High-Level Overview

```
┌─────────────┐
│   ACCOUNT   │ (Authentication System)
└──────┬──────┘
       │
       │ Has 1-5 characters
       ▼
┌──────────────────┐
│   CHARACTERS     │ (This system)
│  - Character 1   │
│  - Character 2   │
│  - Character 3   │
└──────┬───────────┘
       │
       │ Each character has:
       ├─→ Attributes (STR, DEX, etc)
       ├─→ Skills (Hacking, Shooting, etc)
       ├─→ Inventory (items)
       ├─→ Quest Progress
       ├─→ Reputation
       ├─→ Appearance (customization)
       └─→ World State (location, faction)
```

---

## Database Schema

### Таблица `players`

```sql
CREATE TABLE players (
    -- Идентификация
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    
    -- Профиль игрока (account-wide данные)
    premium_currency INTEGER DEFAULT 0, -- Не привязано к персонажу
    total_playtime INTEGER DEFAULT 0, -- Суммарное время всех персонажей
    
    -- Settings (account-wide)
    ui_settings JSONB DEFAULT '{}',
    audio_settings JSONB DEFAULT '{}',
    graphics_settings JSONB DEFAULT '{}',
    
    -- Social
    friend_list UUID[] DEFAULT '{}',
    blocked_players UUID[] DEFAULT '{}',
    
    -- Preferences
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_player_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE,
    UNIQUE(account_id)
);

CREATE INDEX idx_players_account ON players(account_id);
```

### Таблица `characters`

```sql
CREATE TABLE characters (
    -- Идентификация
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    account_id UUID NOT NULL, -- Денормализация для быстрого доступа
    
    -- Основная информация
    character_name VARCHAR(50) UNIQUE NOT NULL,
    
    -- Class & Origin
    class VARCHAR(50) NOT NULL, -- SOLO, NETRUNNER, TECHIE, FIXER, NOMAD
    origin VARCHAR(50) NOT NULL, -- CORPO, STREETKID, NOMAD, CUSTOM
    
    -- Level & Experience
    level INTEGER DEFAULT 1,
    experience BIGINT DEFAULT 0,
    experience_to_next_level BIGINT DEFAULT 1000,
    
    -- Attributes (базовые характеристики)
    attributes JSONB NOT NULL,
    -- {
    --   "body": 5,
    --   "reflexes": 5,
    --   "technical_ability": 5,
    --   "intelligence": 5,
    --   "cool": 5,
    --   "empathy": 5
    -- }
    
    -- Skills (навыки, уровни 0-100)
    skills JSONB NOT NULL DEFAULT '{}',
    -- {
    --   "hacking": 15,
    --   "shooting": 20,
    --   ...
    -- }
    
    -- Derived Stats (производные параметры)
    health INTEGER NOT NULL DEFAULT 100,
    max_health INTEGER NOT NULL DEFAULT 100,
    armor INTEGER DEFAULT 0,
    cyberpsychosis INTEGER DEFAULT 0,
    max_cyberpsychosis INTEGER DEFAULT 100,
    
    -- Currency
    eddies BIGINT DEFAULT 0, -- Основная валюта
    
    -- Appearance (внешность)
    appearance JSONB NOT NULL,
    -- {
    --   "bodyType": 1,
    --   "skinTone": 5,
    --   "hairStyle": 12,
    --   "hairColor": "#FF5733",
    --   "eyeColor": "#1E90FF",
    --   "tattoos": [1, 5, 8],
    --   "scars": [2],
    --   "implants_visible": ["mantis_blades", "optic_implant"]
    -- }
    
    -- World Position
    current_zone VARCHAR(100) NOT NULL DEFAULT 'nightCity.watson.character_creation',
    position_x DECIMAL(10,2) DEFAULT 0,
    position_y DECIMAL(10,2) DEFAULT 0,
    position_z DECIMAL(10,2) DEFAULT 0,
    
    -- Progress
    main_quest_progress INTEGER DEFAULT 0, -- Этап главного квеста
    completed_quests TEXT[] DEFAULT '{}',
    failed_quests TEXT[] DEFAULT '{}',
    
    -- Reputation (по фракциям)
    reputation JSONB DEFAULT '{}',
    -- {
    --   "arasaka": -50,
    --   "militech": 20,
    --   "nomads": 80,
    --   ...
    -- }
    
    -- Playtime
    playtime INTEGER DEFAULT 0, -- Секунды
    
    -- Character Status
    status VARCHAR(20) DEFAULT 'ACTIVE',
    -- ACTIVE, IN_COMBAT, AFK, DEAD, DELETED
    
    is_alive BOOLEAN DEFAULT TRUE,
    death_count INTEGER DEFAULT 0,
    last_death_at TIMESTAMP,
    
    -- Deletion (soft delete)
    deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP,
    can_restore_until TIMESTAMP, -- 30 days grace period
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_played_at TIMESTAMP,
    
    CONSTRAINT fk_character_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_character_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE INDEX idx_characters_player ON characters(player_id);
CREATE INDEX idx_characters_account ON characters(account_id);
CREATE INDEX idx_characters_name ON characters(character_name);
CREATE INDEX idx_characters_zone ON characters(current_zone) WHERE deleted = FALSE;
CREATE INDEX idx_characters_deleted ON characters(deleted, can_restore_until);
```

### Таблица `character_slots`

```sql
CREATE TABLE character_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    
    -- Слоты
    total_slots INTEGER DEFAULT 3, -- Базовое количество
    used_slots INTEGER DEFAULT 0,
    
    -- Premium slots (купленные)
    premium_slots_purchased INTEGER DEFAULT 0,
    max_slots INTEGER DEFAULT 5, -- Максимум (3 базовых + 2 premium)
    
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_slots_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE,
    UNIQUE(account_id)
);
```

### Таблица `character_stats_snapshot`

```sql
CREATE TABLE character_stats_snapshot (
    id BIGSERIAL PRIMARY KEY,
    character_id UUID NOT NULL,
    
    -- Snapshot (для истории)
    level INTEGER,
    health INTEGER,
    eddies BIGINT,
    experience BIGINT,
    playtime INTEGER,
    
    -- Timestamp
    snapshot_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(50), -- DAILY_SNAPSHOT, LEVEL_UP, QUEST_COMPLETE, etc
    
    CONSTRAINT fk_snapshot_character FOREIGN KEY (character_id) 
        REFERENCES characters(id) ON DELETE CASCADE
);

CREATE INDEX idx_snapshot_character ON character_stats_snapshot(character_id, snapshot_at DESC);
```

---

## Character Creation Flow

### Создание персонажа

```java
@Service
public class CharacterService {
    
    @Autowired
    private CharacterRepository characterRepository;
    
    @Autowired
    private CharacterSlotService slotService;
    
    @Autowired
    private EventBus eventBus;
    
    @Transactional
    public CharacterResponse createCharacter(
        UUID accountId,
        CreateCharacterRequest request
    ) {
        // 1. Проверить доступные слоты
        if (!slotService.hasAvailableSlot(accountId)) {
            throw new NoAvailableSlotsException(
                "All character slots are used. Delete a character or purchase more slots."
            );
        }
        
        // 2. Валидация имени
        validateCharacterName(request.getName());
        
        // 3. Проверить уникальность имени (global)
        if (characterRepository.existsByName(request.getName())) {
            throw new CharacterNameTakenException(
                "Character name is already taken"
            );
        }
        
        // 4. Получить player_id
        UUID playerId = getOrCreatePlayer(accountId);
        
        // 5. Создать персонажа
        Character character = new Character();
        character.setPlayerId(playerId);
        character.setAccountId(accountId);
        character.setCharacterName(request.getName());
        character.setClass(request.getCharacterClass());
        character.setOrigin(request.getOrigin());
        
        // 6. Установить начальные атрибуты (зависят от класса)
        Map<String, Integer> initialAttributes = getInitialAttributes(
            request.getCharacterClass(),
            request.getOrigin()
        );
        character.setAttributes(initialAttributes);
        
        // 7. Начальные навыки (зависят от origin)
        Map<String, Integer> initialSkills = getInitialSkills(request.getOrigin());
        character.setSkills(initialSkills);
        
        // 8. Внешность
        character.setAppearance(request.getAppearance());
        
        // 9. Начальная позиция (зависит от origin)
        String startZone = getStartZone(request.getOrigin());
        Vector3 startPosition = getStartPosition(request.getOrigin());
        character.setCurrentZone(startZone);
        character.setPositionX(startPosition.x);
        character.setPositionY(startPosition.y);
        character.setPositionZ(startPosition.z);
        
        // 10. Начальная валюта (зависит от origin)
        long startEddies = getStartEddies(request.getOrigin());
        character.setEddies(startEddies);
        
        // 11. Сохранить
        character = characterRepository.save(character);
        
        // 12. Обновить used slots
        slotService.incrementUsedSlots(accountId);
        
        // 13. Создать начальный инвентарь
        inventoryService.createInitialInventory(
            character.getId(),
            request.getCharacterClass(),
            request.getOrigin()
        );
        
        // 14. Дать начальные квесты
        questService.giveStartingQuests(character.getId(), request.getOrigin());
        
        // 15. Логировать
        log.info("Character created: {} for account {}", character.getId(), accountId);
        
        // 16. Опубликовать событие
        eventBus.publish(new CharacterCreatedEvent(
            character.getId(),
            accountId,
            character.getCharacterName(),
            request.getCharacterClass()
        ));
        
        // 17. Snapshot
        snapshotService.takeSnapshot(
            character.getId(),
            SnapshotReason.CHARACTER_CREATED
        );
        
        return character.toDTO();
    }
    
    private void validateCharacterName(String name) {
        // Length
        if (name.length() < 3 || name.length() > 20) {
            throw new InvalidCharacterNameException(
                "Name must be 3-20 characters"
            );
        }
        
        // Characters (alphanumeric + spaces + hyphens)
        if (!name.matches("^[a-zA-Z0-9 -]+$")) {
            throw new InvalidCharacterNameException(
                "Name can only contain letters, numbers, spaces and hyphens"
            );
        }
        
        // Profanity check
        if (containsProfanity(name)) {
            throw new InvalidCharacterNameException(
                "Name contains inappropriate language"
            );
        }
        
        // Reserved names
        if (isReservedName(name)) {
            throw new InvalidCharacterNameException(
                "This name is reserved"
            );
        }
    }
    
    private Map<String, Integer> getInitialAttributes(
        CharacterClass charClass,
        Origin origin
    ) {
        // Базовые атрибуты
        Map<String, Integer> attributes = new HashMap<>();
        attributes.put("body", 5);
        attributes.put("reflexes", 5);
        attributes.put("technical_ability", 5);
        attributes.put("intelligence", 5);
        attributes.put("cool", 5);
        attributes.put("empathy", 5);
        
        // Бонусы от класса
        switch (charClass) {
            case SOLO:
                attributes.put("body", 7);
                attributes.put("reflexes", 7);
                break;
            case NETRUNNER:
                attributes.put("intelligence", 8);
                attributes.put("technical_ability", 6);
                break;
            case TECHIE:
                attributes.put("technical_ability", 8);
                attributes.put("body", 6);
                break;
            case FIXER:
                attributes.put("cool", 8);
                attributes.put("empathy", 6);
                break;
            case NOMAD:
                attributes.put("body", 6);
                attributes.put("technical_ability", 6);
                attributes.put("reflexes", 6);
                break;
        }
        
        // Бонусы от origin
        switch (origin) {
            case CORPO:
                attributes.put("intelligence", attributes.get("intelligence") + 1);
                break;
            case STREETKID:
                attributes.put("cool", attributes.get("cool") + 1);
                break;
            case NOMAD:
                attributes.put("body", attributes.get("body") + 1);
                break;
        }
        
        return attributes;
    }
}
```

---

## Character Deletion

### Soft Delete (восстановление доступно 30 дней)

```java
@Transactional
public void deleteCharacter(UUID accountId, UUID characterId) {
    // 1. Проверить принадлежность
    Character character = characterRepository.findById(characterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    if (!character.getAccountId().equals(accountId)) {
        throw new UnauthorizedCharacterAccessException();
    }
    
    // 2. Проверить, что не последний персонаж (опционально)
    long activeCharacters = characterRepository.countActiveByAccount(accountId);
    if (activeCharacters == 1) {
        throw new CannotDeleteLastCharacterException(
            "Cannot delete your last character. Create a new one first."
        );
    }
    
    // 3. Soft delete
    character.setDeleted(true);
    character.setDeletedAt(Instant.now());
    character.setCanRestoreUntil(
        Instant.now().plus(Duration.ofDays(30))
    );
    characterRepository.save(character);
    
    // 4. Освободить slot
    slotService.decrementUsedSlots(accountId);
    
    // 5. Закрыть активные сессии персонажа
    sessionManager.closeCharacterSessions(characterId);
    
    // 6. Опубликовать событие
    eventBus.publish(new CharacterDeletedEvent(
        character.getId(),
        accountId,
        character.getCharacterName()
    ));
    
    log.info("Character soft-deleted: {}", characterId);
}
```

### Восстановление персонажа

```java
@Transactional
public CharacterResponse restoreCharacter(UUID accountId, UUID characterId) {
    // 1. Найти удаленного персонажа
    Character character = characterRepository.findById(characterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    if (!character.isDeleted()) {
        throw new CharacterNotDeletedException();
    }
    
    if (!character.getAccountId().equals(accountId)) {
        throw new UnauthorizedCharacterAccessException();
    }
    
    // 2. Проверить grace period
    if (Instant.now().isAfter(character.getCanRestoreUntil())) {
        throw new RestorePeriodExpiredException(
            "Character restore period has expired (30 days)"
        );
    }
    
    // 3. Проверить доступные слоты
    if (!slotService.hasAvailableSlot(accountId)) {
        throw new NoAvailableSlotsException();
    }
    
    // 4. Восстановить
    character.setDeleted(false);
    character.setDeletedAt(null);
    character.setCanRestoreUntil(null);
    characterRepository.save(character);
    
    // 5. Занять slot
    slotService.incrementUsedSlots(accountId);
    
    // 6. Опубликовать событие
    eventBus.publish(new CharacterRestoredEvent(
        character.getId(),
        accountId
    ));
    
    log.info("Character restored: {}", characterId);
    
    return character.toDTO();
}
```

### Hard Delete (через 30 дней)

```java
@Scheduled(cron = "0 0 3 * * *") // Каждый день в 3 AM
public void cleanupDeletedCharacters() {
    Instant now = Instant.now();
    
    // Найти персонажей с истекшим restore period
    List<Character> expiredCharacters = characterRepository
        .findDeletedWithExpiredRestore(now);
    
    for (Character character : expiredCharacters) {
        // Hard delete (каскадное удаление связанных данных)
        characterRepository.delete(character);
        
        log.info("Character permanently deleted: {}", character.getId());
    }
    
    log.info("Cleaned up {} expired characters", expiredCharacters.size());
}
```

---

## Character Switching

### Переключение персонажа

```java
@Transactional
public SwitchCharacterResponse switchCharacter(
    UUID accountId,
    UUID currentCharacterId,
    UUID newCharacterId
) {
    // 1. Проверить принадлежность обоих персонажей
    Character currentChar = characterRepository.findById(currentCharacterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    Character newChar = characterRepository.findById(newCharacterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    if (!currentChar.getAccountId().equals(accountId) ||
        !newChar.getAccountId().equals(accountId)) {
        throw new UnauthorizedCharacterAccessException();
    }
    
    // 2. Проверить, что новый персонаж не удален
    if (newChar.isDeleted()) {
        throw new CharacterDeletedException("Cannot switch to deleted character");
    }
    
    // 3. Сохранить состояние текущего персонажа
    saveCharacterState(currentCharacterId);
    
    // 4. Закрыть текущую сессию персонажа
    sessionManager.closeCharacterSession(currentCharacterId);
    
    // 5. Создать новую сессию для нового персонажа
    SessionResponse newSession = sessionManager.createSessionForCharacter(
        accountId,
        newCharacterId
    );
    
    // 6. Обновить last_played_at
    newChar.setLastPlayedAt(Instant.now());
    characterRepository.save(newChar);
    
    // 7. Опубликовать событие
    eventBus.publish(new CharacterSwitchedEvent(
        accountId,
        currentCharacterId,
        newCharacterId
    ));
    
    return new SwitchCharacterResponse(
        newSession.getSessionToken(),
        newChar.toDTO()
    );
}
```

---

## Character Data Updates

### Update Attributes (при level up)

```java
@Transactional
public void updateAttributes(UUID characterId, Map<String, Integer> newAttributes) {
    Character character = characterRepository.findById(characterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    // Валидация (проверить, что не превышены лимиты)
    validateAttributes(newAttributes, character.getLevel());
    
    // Обновить
    character.setAttributes(newAttributes);
    
    // Пересчитать derived stats
    recalculateDerivedStats(character);
    
    characterRepository.save(character);
    
    // Snapshot
    snapshotService.takeSnapshot(characterId, SnapshotReason.ATTRIBUTE_UPDATE);
}
```

### Update Skills (при использовании)

```java
@Transactional
public void incrementSkill(UUID characterId, String skillName, int amount) {
    Character character = characterRepository.findById(characterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    Map<String, Integer> skills = character.getSkills();
    int currentLevel = skills.getOrDefault(skillName, 0);
    int newLevel = Math.min(currentLevel + amount, 100); // Cap at 100
    
    skills.put(skillName, newLevel);
    character.setSkills(skills);
    
    characterRepository.save(character);
    
    // Уведомить о level up
    if (newLevel % 10 == 0) { // Каждые 10 уровней
        notificationService.send(character.getAccountId(), 
            new SkillLevelUpNotification(skillName, newLevel)
        );
    }
}
```

### Update Position (при движении)

```java
@Transactional
public void updatePosition(
    UUID characterId,
    String zoneId,
    Vector3 position
) {
    Character character = characterRepository.findById(characterId)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    // Обновить позицию
    character.setCurrentZone(zoneId);
    character.setPositionX(position.x);
    character.setPositionY(position.y);
    character.setPositionZ(position.z);
    
    characterRepository.save(character);
    
    // Update Redis (для fast access)
    redis.opsForValue().set(
        "character_position:" + characterId,
        new CharacterPosition(zoneId, position),
        1, TimeUnit.HOURS
    );
}
```

---

## API Endpoints

### Character Management

**GET `/api/v1/characters`** - список персонажей аккаунта
```json
{
  "characters": [
    {
      "id": "uuid",
      "name": "V",
      "class": "SOLO",
      "level": 15,
      "playtime": 36000,
      "lastPlayed": "2025-11-06T20:00:00Z"
    }
  ],
  "totalSlots": 3,
  "usedSlots": 1
}
```

**POST `/api/v1/characters`** - создать персонажа
```json
Request:
{
  "name": "V",
  "class": "SOLO",
  "origin": "STREETKID",
  "appearance": {
    "bodyType": 1,
    "skinTone": 5,
    ...
  }
}

Response:
{
  "id": "uuid",
  "name": "V",
  "class": "SOLO",
  "level": 1,
  "createdAt": "2025-11-07T05:00:00Z"
}
```

**GET `/api/v1/characters/{id}`** - информация о персонаже
**PUT `/api/v1/characters/{id}`** - обновить персонажа (appearance, settings)
**DELETE `/api/v1/characters/{id}`** - удалить персонажа (soft delete)
**POST `/api/v1/characters/{id}/restore`** - восстановить персонажа

### Character Switching

**POST `/api/v1/characters/switch`** - переключиться на другого персонажа
```json
Request:
{
  "currentCharacterId": "uuid-1",
  "newCharacterId": "uuid-2"
}

Response:
{
  "sessionToken": "new-session-token",
  "character": {
    "id": "uuid-2",
    "name": "Johnny",
    ...
  }
}
```

### Character Stats

**GET `/api/v1/characters/{id}/stats`** - статистика персонажа
**GET `/api/v1/characters/{id}/history`** - история snapshots

### Player Profile

**GET `/api/v1/player/profile`** - профиль игрока (account-wide)
**PUT `/api/v1/player/profile`** - обновить профиль
**GET `/api/v1/player/settings`** - настройки
**PUT `/api/v1/player/settings`** - обновить настройки

---

## Character Slots Management

### Покупка дополнительных слотов

```java
@Transactional
public void purchaseCharacterSlot(UUID accountId, int slotsCount) {
    // 1. Проверить текущие слоты
    CharacterSlots slots = slotService.getSlots(accountId);
    
    if (slots.getTotalSlots() + slotsCount > slots.getMaxSlots()) {
        throw new MaxSlotsReachedException("Cannot purchase more slots");
    }
    
    // 2. Проверить стоимость
    int cost = SLOT_COST * slotsCount; // Например, 500 premium currency
    
    if (!playerService.hasPremiumCurrency(accountId, cost)) {
        throw new InsufficientFundsException();
    }
    
    // 3. Списать валюту
    playerService.deductPremiumCurrency(accountId, cost);
    
    // 4. Добавить слоты
    slots.setTotalSlots(slots.getTotalSlots() + slotsCount);
    slots.setPremiumSlotsPurchased(slots.getPremiumSlotsPurchased() + slotsCount);
    slotRepository.save(slots);
    
    log.info("Player {} purchased {} character slots", accountId, slotsCount);
}
```

---

## Integration с другими системами

### При создании персонажа

```
CharacterService.createCharacter()
  ↓
→ InventoryService: create initial inventory
→ QuestService: give starting quests
→ ReputationService: set initial reputation
→ EventBus: publish CHARACTER_CREATED
→ AnalyticsService: record character creation
```

### При level up

```
CharacterService.levelUp()
  ↓
→ AttributeService: unlock attribute points
→ SkillService: unlock skill points
→ NotificationService: send "Level Up!" notification
→ AchievementService: check level achievements
→ EventBus: publish LEVEL_UP
```

### При смерти персонажа

```
CharacterService.handleDeath()
  ↓
→ InventoryService: apply death penalty (item loss)
→ EconomyService: apply gold penalty
→ RespawnService: determine respawn location
→ NotificationService: send death notification
→ EventBus: publish CHARACTER_DIED
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/authentication-authorization-system.md` - Authentication
- `.BRAIN/05-technical/backend/session-management-system.md` - Session management
- `.BRAIN/05-technical/backend/inventory-system.md` - Inventory (будет создан)
- `.BRAIN/02-gameplay/progression/classes-overview.md` - Classes
- `.BRAIN/02-gameplay/progression/progression-attributes.md` - Attributes

---

## TODO

- [ ] Character name change (платная услуга)
- [ ] Character appearance change (платная услуга)
- [ ] Character transfer between accounts (редкий кейс)
- [ ] Character boost (skip to level X)

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Player & Character Management System

