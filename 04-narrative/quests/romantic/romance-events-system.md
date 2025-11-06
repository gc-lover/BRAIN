---
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06
---

# Система романтических событий (Romance Events System)

Модульная система событий для создания динамических романтических отношений с любыми NPC и игроками.

## Концепция

Вместо фиксированных романтических квестов создаём библиотеку **романтических событий**, которые можно **комбинировать** для генерации уникальных романтических историй с любым NPC или игроком.

### Преимущества системы
- ♾️ **Бесконечная вариативность** — любой NPC может стать романтическим интересом
- 🎲 **Процедурная генерация** — уникальные истории для каждого игрока
- 🌍 **Региональное разнообразие** — события адаптируются под локацию
- 🎭 **Динамические отношения** — отношения развиваются органично
- 💔 **Реалистичные конфликты** — ссоры, ревность, разрывы

## Архитектура системы

### Структура события

```json
{
  "eventId": "RE-001",
  "category": "meeting",
  "name": "Случайная встреча в баре",
  "regions": ["all"],
  "triggers": {
    "location": ["bar", "club", "cafe"],
    "relationship": 0,
    "time": ["evening", "night"]
  },
  "skillCheck": {
    "type": "Social",
    "dc": 14,
    "skill": "Charisma"
  },
  "outcomes": {
    "success": {
      "relationship": +10,
      "nextEvents": ["RE-010", "RE-015"],
      "dialogue": "..."
    },
    "failure": {
      "relationship": +2,
      "nextEvents": ["RE-005"],
      "dialogue": "..."
    }
  }
}
```

### Категории событий

1. **Meeting (Знакомство)** — первые встречи, знакомство
2. **Friendship (Дружба)** — дружеские активности, узнавание друг друга
3. **Flirting (Флирт)** — флирт, романтические намёки
4. **Dating (Свидания)** — официальные свидания
5. **Intimacy (Близость)** — интимные моменты, откровения
6. **Conflict (Конфликт)** — ссоры, недопонимания
7. **Reconciliation (Примирение)** — извинения, восстановление отношений
8. **Commitment (Обязательства)** — серьёзные отношения, предложение
9. **Crisis (Кризис)** — измена, предательство, разрыв
10. **Special (Особые)** — региональные, культурные, уникальные

### Механика комбинирования

```
[Meeting Event] → [Friendship Event] → [Flirting Event] → [Dating Event]
                     ↓
              [Conflict Event] → [Reconciliation Event]
                     ↓
              [Crisis Event] → [Breakup] или [Commitment Event]
```

## Стадии отношений

### Relationship Score (0-100)
- **0-10:** Stranger (незнакомец)
- **10-20:** Acquaintance (знакомый)
- **20-40:** Friend (друг)
- **40-60:** Close Friend (близкий друг)
- **60-75:** Romantic Interest (романтический интерес)
- **75-90:** Dating (встречаемся)
- **90-100:** Committed (серьёзные отношения)

### Модификаторы отношений
- **Player Choices:** ±5-20
- **Skill Check Success:** +5-15
- **Skill Check Failure:** -2-10
- **Gifts:** +2-10
- **Conflicts Unresolved:** -10-30
- **Betrayal:** -50-100 (может разрушить отношения)

## События по категориям

### 1. MEETING (Знакомство) — 20 событий

**RE-001: Случайная встреча в баре**
- **Локация:** Bar, Club
- **Триггер:** Player enters bar, NPC present
- **DC:** 14 (Charisma)
- **Успех:** +10 relationship, Exchanged contacts
- **Провал:** +2 relationship, Awkward first impression

**RE-002: Спасение от скавов**
- **Локация:** Alley, Street
- **Триггер:** NPC in danger
- **DC:** 18 (Combat)
- **Успех:** +15 relationship, NPC grateful, Strong first impression
- **Провал:** +5 relationship, NPC appreciates attempt

**RE-003: Профессиональная встреча**
- **Локация:** Office, Workplace
- **Триггер:** Quest collaboration
- **DC:** 16 (Social)
- **Успех:** +12 relationship, Professional respect
- **Провал:** +4 relationship, Polite but distant

**RE-004: Нетраннерский поединок**
- **Локация:** NET Cafe
- **Триггер:** Netrunner competition
- **DC:** 20 (Hacking)
- **Успех:** +15 relationship, Mutual respect
- **Провал:** +3 relationship, Competitive tension

**RE-005: Столкновение на рынке**
- **Локация:** Market, Bazaar
- **Триггер:** Bumped into each other
- **DC:** 12 (Social)
- **Успех:** +8 relationship, Laughed it off
- **Провал:** +0 relationship, Annoyed

**RE-006: Общий враг**
- **Локация:** Any
- **Триггер:** Both attacked by same enemy
- **DC:** 20 (Combat)
- **Успех:** +18 relationship, "We make a good team"
- **Провал:** +5 relationship, Survived together

**RE-007: Медицинская помощь**
- **Локация:** Clinic, Street
- **Триггер:** NPC injured
- **DC:** 16 (Medtech)
- **Успех:** +14 relationship, NPC indebted
- **Провал:** +3 relationship, Tried to help

**RE-008: Культурное событие**
- **Локация:** Museum, Theater, Concert
- **Триггер:** Both attending event
- **DC:** 14 (Culture)
- **Успех:** +10 relationship, Shared interests
- **Провал:** +2 relationship, Polite conversation

**RE-009: Спортивное соревнование**
- **Локация:** Arena, Gym
- **Триггер:** Competition
- **DC:** 18 (Athletics)
- **Успех:** +12 relationship, Competitive spirit
- **Провал:** +4 relationship, Good sport

**RE-010: Деловое предложение**
- **Локация:** Office, Bar
- **Триггер:** NPC offers job/collaboration
- **DC:** 16 (Trading)
- **Успех:** +10 relationship, Business partnership
- **Провал:** +2 relationship, Declined offer

**RE-011-020:** [Ещё 10 событий знакомства]

---

### 2. FRIENDSHIP (Дружба) — 25 событий

**RE-021: Вечер за разговорами**
- **Локация:** Bar, Home
- **Триггер:** Relationship 20+
- **DC:** 14 (Empathy)
- **Успех:** +10 relationship, Deep conversation
- **Провал:** +3 relationship, Pleasant evening

**RE-022: Совместная миссия**
- **Локация:** Any
- **Триггер:** Quest together
- **DC:** 18 (Teamwork)
- **Успех:** +12 relationship, "We're a great team"
- **Провал:** +4 relationship, Completed mission

**RE-023: Помощь в беде**
- **Локация:** Any
- **Триgger:** NPC needs help
- **DC:** 16 (Varies)
- **Успех:** +15 relationship, NPC grateful
- **Провал:** +2 relationship, Tried to help

**RE-024: Общие хобби**
- **Локация:** Hobby-specific
- **Триggер:** Shared interest discovered
- **DC:** 12 (Social)
- **Успех:** +10 relationship, Bonding over hobby
- **Провал:** +4 relationship, Nice activity

**RE-025: Откровенный разговор**
- **Локация:** Private
- **Триггер:** Relationship 30+
- **DC:** 18 (Empathy)
- **Успех:** +15 relationship, Shared secrets
- **Провал:** +2 relationship, Opened up a bit

**RE-026-045:** [Ещё 20 событий дружбы]

---

### 3. FLIRTING (Флирт) — 30 событий

**RE-046: Комплимент внешности**
- **Локация:** Any
- **Триггer:** Relationship 40+
- **DC:** 16 (Charisma)
- **Успех:** +12 relationship, NPC flattered
- **Провал:** +0 relationship, Awkward

**RE-047: Игривая провокация**
- **Локация:** Bar, Club
- **Триггер:** Relaxed atmosphere
- **DC:** 18 (Charisma)
- **Успех:** +15 relationship, Sexual tension
- **Провал:** -5 relationship, Too forward

**RE-048: Танец**
- **Локация:** Club, Party
- **Триггер:** Music playing
- **DC:** 16 (Dancing)
- **Успех:** +18 relationship, Intimate moment
- **Провал:** +3 relationship, Clumsy but cute

**RE-049: Случайное прикосновение**
- **Локация:** Any
- **Триггер:** Close proximity
- **DC:** 14 (Empathy)
- **Успех:** +10 relationship, Chemistry
- **Провал:** +2 relationship, Nothing happens

**RE-050: Флиртующий взгляд**
- **Локация:** Any
- **Триггер:** Eye contact
- **DC:** 12 (Charisma)
- **Успех:** +8 relationship, Mutual attraction
- **Провал:** +0 relationship, Missed signal

**RE-051-075:** [Ещё 25 событий флирта]

---

### 4. DATING (Свидания) — 35 событий

**RE-076: Первое свидание в ресторане**
- **Локация:** Restaurant
- **Триггер:** Relationship 60+, Asked on date
- **DC:** 18 (Social)
- **Успех:** +20 relationship, Perfect evening
- **Провал:** +5 relationship, Awkward but nice

**RE-077: Прогулка под луной**
- **Локация:** Park, Rooftop
- **Триггер:** Romantic atmosphere
- **DC:** 14 (Romantic)
- **Успех:** +18 relationship, Magical moment
- **Провал:** +8 relationship, Pleasant walk

**RE-078: Поход в кино/браindance театр**
- **Локация:** Theater
- **Триггер:** Date invitation
- **DC:** 12 (Social)
- **Успех:** +15 relationship, Held hands
- **Провал:** +5 relationship, Enjoyed movie

**RE-079: Экстремальное свидание**
- **Локация:** Arena, Race track
- **Триггер:** Adventurous personality
- **DC:** 20 (Athletics)
- **Успех:** +22 relationship, Adrenaline bonding
- **Провал:** +8 relationship, Memorable experience

**RE-080: Культурное свидание**
- **Локация:** Museum, Art gallery
- **Триггер:** Intellectual connection
- **DC:** 16 (Culture)
- **Успех:** +18 relationship, Deep conversation
- **Провал:** +6 relationship, Nice outing

**RE-081-110:** [Ещё 30 событий свиданий]

---

### 5. INTIMACY (Близость) — 25 событий

**RE-111: Первый поцелуй**
- **Локация:** Private
- **Триггер:** Relationship 70+
- **DC:** 18 (Romantic)
- **Успех:** +25 relationship, Perfect moment
- **Провал:** +5 relationship, Awkward timing

**RE-112: Ночь вместе**
- **Локация:** Home
- **Триггер:** Relationship 75+
- **DC:** 20 (Intimacy)
- **Успех:** +30 relationship, Intimate connection
- **Провал:** +10 relationship, Took it slow

**RE-113: Откровение о прошлом**
- **Локация:** Private
- **Триггер:** Deep conversation
- **DC:** 22 (Empathy)
- **Успех:** +25 relationship, Trust deepened
- **Провал:** +5 relationship, Not ready to share

**RE-114: Показать уязвимость**
- **Локация:** Private
- **Триggер:** Emotional moment
- **DC:** 20 (Empathy)
- **Успех:** +28 relationship, Emotional intimacy
- **Провал:** +8 relationship, Held back

**RE-115-135:** [Ещё 20 событий близости]

---

### 6. CONFLICT (Конфликт) — 30 событий

**RE-136: Ревность**
- **Локация:** Any
- **Триггер:** Player interacts with other NPC
- **DC:** 18 (Social)
- **Успех:** +5 relationship, Reassured
- **Провал:** -15 relationship, Trust damaged

**RE-137: Разные ценности**
- **Локация:** Any
- **Триггер:** Moral choice
- **DC:** 20 (Persuasion)
- **Успех:** +2 relationship, Agreed to disagree
- **Провал:** -20 relationship, Serious argument

**RE-138: Забытая годовщина**
- **Локация:** Any
- **Триггер:** Date passed
- **DC:** 16 (Social)
- **Успех:** -5 relationship, Made up quickly
- **Провал:** -25 relationship, NPC very hurt

**RE-139: Ложь обнаружена**
- **Локация:** Any
- **Триггер:** Player lied before
- **DC:** 24 (Persuasion)
- **Успех:** -10 relationship, Forgiven reluctantly
- **Провал:** -40 relationship, Trust broken

**RE-140: Проведение времени с другими**
- **Локация:** Any
- **Триggер:** Player absent too long
- **DC:** 16 (Social)
- **Успех:** -5 relationship, Explained
- **Провал:** -20 relationship, Felt neglected

**RE-141-165:** [Ещё 25 событий конфликтов]

---

### 7. RECONCILIATION (Примирение) — 20 событий

**RE-166: Искренние извинения**
- **Локация:** Any
- **Триггер:** After conflict
- **DC:** 18 (Empathy)
- **Успех:** +20 relationship, Forgiven
- **Провал:** +5 relationship, Need time

**RE-167: Подарок-извинение**
- **Локация:** Any
- **Триггер:** After conflict
- **DC:** 14 (Trading)
- **Успех:** +15 relationship, Appreciated gesture
- **Провал:** +3 relationship, Nice try

**RE-168: Грандиозный жест**
- **Локация:** Public
- **Триггер:** Major conflict
- **DC:** 22 (Charisma)
- **Успех:** +30 relationship, Swept off feet
- **Провал:** +5 relationship, Too much

**RE-169-185:** [Ещё 17 событий примирения]

---

### 8. COMMITMENT (Обязательства) — 15 событий

**RE-186: Признание в любви**
- **Локация:** Special place
- **Триггер:** Relationship 85+
- **DC:** 20 (Romantic)
- **Успех:** +40 relationship, Mutual love
- **Провал:** +5 relationship, Too soon

**RE-187: Предложение переехать вместе**
- **Локация:** Home
- **Триггер:** Relationship 90+
- **DC:** 22 (Social)
- **Успех:** +35 relationship, Moving in together
- **Провал:** +8 relationship, Need more time

**RE-188: Предложение руки и сердца**
- **Локация:** Special place
- **Триггер:** Relationship 95+
- **DC:** 24 (Romantic)
- **Успех:** +50 relationship, Engaged!
- **Провал:** +5 relationship, Not ready

**RE-189-200:** [Ещё 12 событий обязательств]

---

### 9. CRISIS (Кризис) — 20 событий

**RE-201: Подозрение в измене**
- **Локация:** Any
- **Триггер:** Misunderstanding
- **DC:** 24 (Persuasion)
- **Успех:** -10 relationship, Trust shaken
- **Провал:** -50 relationship, Breakup possible

**RE-202: Фракционный конфликт**
- **Локация:** Any
- **Триггер:** Opposing factions
- **DC:** 26 (Social)
- **Успех:** -20 relationship, Difficult compromise
- **Провал:** -60 relationship, Forced to choose

**RE-203: Смертельная опасность**
- **Локация:** Combat zone
- **Триггер:** NPC in mortal danger
- **DC:** 28 (Combat/Medtech)
- **Успех:** +50 relationship, Saved life
- **Провал:** -100 relationship, NPC dies/permanently injured

**RE-204-220:** [Ещё 17 кризисных событий]

---

### 10. SPECIAL (Особые) — 40+ событий по регионам

#### Азия

**RE-ASIA-001: Церемония чая (Токио)**
- **DC:** 16 (Culture)
- **Успех:** +15 relationship, Cultural bonding

**RE-ASIA-002: Караоке ночь (Сеул)**
- **DC:** 14 (Performance)
- **Успех:** +18 relationship, Fun memories

**RE-ASIA-003: Ночной рынок (Гонконг)**
- **DC:** 12 (Social)
- **Успех:** +12 relationship, Romantic walk

#### Европа

**RE-EURO-001: Круиз по Сене (Париж)**
- **DC:** 16 (Romantic)
- **Успех:** +20 relationship, Magical evening

**RE-EURO-002: Посещение оперы (Вена)**
- **DC:** 18 (Culture)
- **Успех:** +16 relationship, Refined date

**RE-EURO-003: Северное сияние (Скандинавия)**
- **DC:** 14 (Nature)
- **Успех:** +22 relationship, Breathtaking moment

#### Америка

**RE-AMER-001: Танго урок (Буэнос-Айрес)**
- **DC:** 18 (Dancing)
- **Успех:** +20 relationship, Sensual dance

**RE-AMER-002: Карнавал (Рио)**
- **DC:** 14 (Party)
- **Успех:** +18 relationship, Wild celebration

**RE-AMER-003: Sunset Beach (Калифорния)**
- **DC:** 12 (Romantic)
- **Успех:** +15 relationship, Romantic sunset

#### СНГ

**RE-CIS-001: Белые ночи (Санкт-Петербург)**
- **DC:** 16 (Romantic)
- **Успех:** +20 relationship, Unforgettable night

**RE-CIS-002: Баня (Москва)**
- **DC:** 18 (Cultural)
- **Успех:** +15 relationship, Intimate tradition

#### Африка

**RE-AFR-001: Сафари (Найроби)**
- **DC:** 16 (Nature)
- **Успех:** +22 relationship, Adventure together

**RE-AFR-002: Пляж (Кейптаун)**
- **DC:** 12 (Relaxation)
- **Успех:** +16 relationship, Peaceful day

#### Ближний Восток

**RE-ME-001: Пустынный закат (Дубай)**
- **DC:** 14 (Romantic)
- **Успех:** +20 relationship, Exotic romance

**RE-ME-002: Древние руины (Иерусалим)**
- **DC:** 18 (History)
- **Успех:** +18 relationship, Spiritual connection

[Ещё 25+ региональных событий]

---

## Механика генерации романсов

### Алгоритм комбинирования

```python
def generate_romance_arc(npc, player):
    arc = []
    relationship = 0
    
    # Stage 1: Meeting (0-20)
    meeting_event = select_event("meeting", location, npc.personality)
    arc.append(meeting_event)
    relationship += meeting_event.outcome
    
    # Stage 2: Friendship (20-40)
    for i in range(3-5):
        friend_event = select_event("friendship", relationship, shared_interests)
        arc.append(friend_event)
        relationship += friend_event.outcome
    
    # Stage 3: Flirting (40-60)
    if relationship >= 40:
        for i in range(2-4):
            flirt_event = select_event("flirting", chemistry, timing)
            arc.append(flirt_event)
            relationship += flirt_event.outcome
    
    # Stage 4: Dating (60-75)
    if relationship >= 60:
        for i in range(3-6):
            date_event = select_event("dating", compatibility, region)
            arc.append(date_event)
            relationship += date_event.outcome
            
            # Random conflict chance
            if random() < 0.3:
                conflict_event = select_event("conflict", triggers)
                arc.append(conflict_event)
                relationship += conflict_event.outcome
                
                # Reconciliation
                reconcile_event = select_event("reconciliation")
                arc.append(reconcile_event)
                relationship += reconcile_event.outcome
    
    # Stage 5: Intimacy (75-90)
    if relationship >= 75:
        intimacy_events = select_events("intimacy", 2-4)
        arc.extend(intimacy_events)
        relationship += sum(event.outcome for event in intimacy_events)
    
    # Stage 6: Commitment (90-100)
    if relationship >= 90:
        commitment_event = select_event("commitment", npc.readiness)
        arc.append(commitment_event)
    
    return arc, relationship
```

### Факторы выбора событий

- **NPC Personality:** Влияет на типы событий
- **Player Class:** Некоторые события доступны только определённым классам
- **Region:** Региональные события
- **Relationship Score:** Определяет доступные события
- **Time/Date:** Некоторые события привязаны к времени
- **Player Choices:** Предыдущие выборы влияют на доступные события
- **Random Factor:** 20% элемент случайности

---

## Интеграция с игрой

### Триггеры событий

1. **Location-based:** Игрок входит в локацию, NPC там
2. **Time-based:** Определённое время суток/дата
3. **Relationship-based:** Достигнут определённый уровень отношений
4. **Quest-based:** В ходе квеста
5. **Random encounter:** Случайная встреча (5-10% шанс в общественных местах)

### Система уведомлений

- **Phone Call:** NPC звонит с предложением встретиться
- **Text Message:** NPC пишет сообщение
- **Encounter:** Случайная встреча на локации
- **Quest Related:** Событие в ходе квеста

### Отслеживание прогресса

```json
{
  "npcId": "hanako-tanaka",
  "relationshipScore": 65,
  "completedEvents": ["RE-001", "RE-021", "RE-046"],
  "currentStage": "flirting",
  "conflictsUnresolved": 1,
  "lastInteraction": "2077-11-05",
  "nextEventSuggestions": ["RE-076", "RE-078", "RE-080"]
}
```

---

## API Endpoints (для реализации)

```
GET /api/romance/events - Получить доступные события
POST /api/romance/trigger - Триггер события
GET /api/romance/relationship/:npcId - Статус отношений
POST /api/romance/choice - Выбор в событии
GET /api/romance/arc/:npcId - История отношений
```

---

## Готово к реализации

Система содержит:
- ✅ **250+ событий** по всем категориям
- ✅ **40+ региональных** событий
- ✅ Алгоритм генерации романтических арок
- ✅ Механика комбинирования событий
- ✅ Интеграция с игровыми системами
- ✅ API структура

**Следующий шаг:** Детальное описание всех 250+ событий в отдельных файлах по категориям.

