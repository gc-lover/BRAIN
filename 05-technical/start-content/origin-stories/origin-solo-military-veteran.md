---
**Статус:** review  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Приоритет:** высокий  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:50  
**api-readiness-notes:** Полная origin story для Solo «Military Veteran». 3 квеста, 18 узлов диалогов. Соответствует `quest-origin-solo-01` через `03`.
---

# ORIGIN STORY: Solo — Military Veteran


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-167](../../../API-SWAGGER/tasks/active/queue/task-167-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## 1. Обзор origin

**Класс:** Solo
**Backstory:** Бывший военный / corpo-security
**Архетип:** Disciplined warrior seeking purpose in Night City
**Длительность:** 3 квеста, уровень 1 → 3
**Эпоха:** 2020-2030
**Тема:** От военной дисциплины к уличным контрактам

## 2. Backstory: Предыстория персонажа

**До Night City:**
- Служба в corpo-security (Arasaka OR Militech, выбор игрока)
- Участие в конфликтах до DataKrash
- Потеря отряда в 2020 (DataKrash casualties)
- Увольнение / дезертирство (branching backstory choice)
- Прибытие в Night City в поисках работы и цели

**Personality Traits:**
- Дисциплинированный (military training)
- Одиночка (lost team, trust issues)
- Навыки боя (combat proficiency)
- Ищет искупления / новую цель

**Starting Bonuses (Origin Perks):**
- +2 к тактике (military training)
- +1 AC (combat experience)
- Starting weapon: `item-weapon-basic` (military-grade pistol)

## 3. QUEST 1: Первый контракт (ID: `quest-origin-solo-01-first-gig`)

### Синопсис:
Прибытие в Night City. Встреча с Сарой Миллер (NCPD). Первый контракт — зачистка бандитов. Доказательство навыков.

### Диалоговое дерево (8 узлов):

NODE[intro]: Прибытие в Night City → «Улицы, неон, хаос.»
- [Найти работу] → NODE[meet_sarah]

NODE[meet_sarah]: Сара Миллер → «Новенький? Выглядишь как военный.»
- [Бывший corpo-security] → NODE[corpo_past]
- [Просто ищу работу] → NODE[neutral]

NODE[corpo_past]: «Corpo? (подозрительно) Почему ушёл?»
- [Увольнение после DataKrash] → NODE[backstory_1]
- [Дезертировал] → NODE[backstory_2]

NODE[backstory_1]: «Понятно. DataKrash многих уволил.» (+neutral reputation)
- [Нужна работа] → NODE[job_offer]

NODE[backstory_2]: «Дезертир? (напряжение) Ладно. Прошлое — прошлое.» (−5 NCPD reputation)
- [Нужна работа] → NODE[job_offer]

NODE[neutral]: «Работа есть. Покажи навыки.»
- [Что нужно сделать?] → NODE[job_offer]

NODE[job_offer]: «Зачистка. Бандиты в Watson. 3 цели. Проще простого.»
- [Принять] → NODE[combat_prep]

NODE[combat_prep]: Watson → «Бандиты впереди.»
- [Атаковать] → NODE[combat]

NODE[combat]: Бой (3 бандита, AC 11, HP 30 каждый)
- win → NODE[combat_won]
- lose → NODE[combat_lost]

NODE[combat_won]: Сара → «Неплохо. Военная выучка видна. Добро пожаловать в Night City.»
- [Получить оплату] → NODE[complete]

NODE[combat_lost]: «Медпункт. Навыки ржавеют?»
- [Попытаться снова] → NODE[combat]

NODE[complete]: +200 XP, +300 eddies, `item-weapon-basic`, +10 NCPD reputation

### Objectives:
1) Прибыть в Night City
2) Встретить Сару Миллер
3) Первый бой (3 врага)

## 4. QUEST 2: Построение репутации (ID: `quest-origin-solo-02-reputation`)

### Синопсис:
Серия контрактов для построения репутации. 3 контракта: охрана, эскорт, зачистка.

### Диалоговое дерево (6 узлов):

NODE[start]: Сара → «Репутация растёт. Вот 3 контракта.»
- [Принять] → NODE[contract_1]

NODE[contract_1]: «Контракт 1: Охрана торговца.» → бой (5 врагов)
- win → NODE[contract_2]

NODE[contract_2]: «Контракт 2: Эскорт VIP.» → travel + случайная встреча (3 врага)
- win → NODE[contract_3]

NODE[contract_3]: «Контракт 3: Зачистка территории.» → бой (7 врагов)
- win → NODE[reputation_built]

NODE[reputation_built]: Сара → «Репутация Solo растёт. Город замечает тебя.»
- [Спасибо] → NODE[complete]

NODE[complete]: +350 XP, +450 eddies, `item-armor-basic`, +15 NCPD reputation

### Objectives:
1) Контракт 1: Охрана (5 врагов)
2) Контракт 2: Эскорт
3) Контракт 3: Зачистка (7 врагов)

## 5. QUEST 3: Соперник (ID: `quest-origin-solo-03-rival`)

### Синопсис:
Соперник-Solo (бывший товарищ по оружию OR местный legend) бросает вызов. Дуэль 1v1. Доказать, что ты лучший. Финал origin story.

### Диалоговое дерево (4 узла):

NODE[start]: Соперник → «Новый Solo? Докажи свою ценность. Дуэль.»
- [Принять] → NODE[duel_prep]
- [Отказаться] → NODE[shame] (origin incomplete, −20 reputation)

NODE[duel_prep]: «Правила: один на один. До первой крови.»
- [Готов] → NODE[duel]

NODE[duel]: Дуэль (1v1, Rival AC 15, HP 100, d8+3 damage)
- [TACTICS 14 Тактическое преимущество] → success NODE[duel_advantage] / direct fight
- win → NODE[victory]
- lose → NODE[defeat]

NODE[duel_advantage]: «Тактика даёт преимущество.» (+2 AC, +d4 damage для дуэли)
- win → NODE[victory]

NODE[victory]: Соперник → «(уважение) Ты хорош. Добро пожаловать, Solo.»
- [Получить награду] → NODE[complete]

NODE[defeat]: «Медпункт. Репутация пострадала.» (−10 reputation, может повторить)

NODE[complete]: +500 XP, +600 eddies, `item-rival-trophy`, +20 Independent reputation
- **Title Unlocked:** «Solo of Night City»
- **Origin Complete:** Solo backstory завершён

### Objectives:
1) Принять вызов соперника
2) Дуэль с соперником (1v1)

## 6. API Mapping

### Endpoints:
- POST `/api/v1/origin/start` (classId, backstoryChoice)
- POST `/api/v1/origin/quest-complete` (originQuestId)
- GET `/api/v1/origin/status` (playerId) → returns completed origin quests, unlocked perks
- POST `/api/v1/combat/duel` (playerId, rivalId, duelType)

## 7. Origin Perks (Permanent)

После завершения origin story Solo получает:
- **Military Training:** +2 к TACTICS checks
- **Combat Veteran:** +1 AC permanently
- **Solo Reputation:** Starting reputation с NCPD +20
- **Title:** «Solo of Night City»

## 8. Branching Backstories

**Выбор в Quest 1:**
- **Corpo-security уволен:** +neutral NCPD reputation, access to corpo contacts
- **Дезертир:** −5 NCPD reputation, но +street cred, access to underground

**Влияние на геймплей:**
- Corpo-security: легче работать с NCPD, corpo faction quests
- Дезертир: легче работать с бандами, independent quests

## 9. Соответствие JSON

См. `mvp-data-json/quests.json`:
- `quest-origin-solo-01-first-gig`
- `quest-origin-solo-02-reputation`
- `quest-origin-solo-03-rival`

Metadata fields:
- `originClass`: "solo"
- `originStage`: 1-3
- `backstory`: "military-veteran"
- `originFinal`: true (quest 3)

## 10. Тесты

- Corpo-security path → NCPD reputation boost
- Дезертир path → street cred boost
- Duel победа → origin complete
- Duel провал → retry available
- Origin perks applied correctly

## 11. История изменений
- v1.0.0 (2025-11-06) — полная origin story Solo (3 квеста, 18 узлов).

