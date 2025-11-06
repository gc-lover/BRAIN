---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:19  
**api-readiness-notes:** Централизованный документ о влиянии игроков на глобальное состояние мира. Объединяет все системы: экономику, политику, территории, фракции, события, социальные структуры.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-070: api/v1/gameplay/world/world-state.yaml (2025-11-07)
- Last Updated: 2025-11-07 01:45
---

# Влияние игроков на глобальное состояние мира

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:19  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---

## Краткое описание

Этот документ описывает **централизованную систему влияния игроков на глобальное состояние мира** в NECPGAME. Объединяет влияния от всех игровых систем (экономика, политика, квесты, боевая система, социальные механики) и описывает, как действия отдельных игроков и групп влияют на мир в масштабах сервера.

**Ключевая концепция:** Живой мир (KENSHI + RIMWORLD) + влияние игроков (EVE Online + WOW) + последствия выборов (Baldur's Gate 3).

---

## Обоснование

### Источники вдохновения

**KENSHI:**
- Мир живет сам по себе
- События происходят без участия игрока
- Фракции воюют, торгуют, развиваются независимо

**RIMWORLD:**
- Мир реагирует на действия игроков
- Фракции помнят поступки игроков
- События влияют на всех

**EVE Online:**
- Игроки реально влияют на экономику
- Крупные корпорации меняют политическую карту
- Войны меняют контроль территорий

**WOW:**
- Мировые события требуют участия многих игроков
- Прогресс сервера зависит от игроков
- Фазирование мира (разные состояния для разных игроков)

**Baldur's Gate 3:**
- Выборы игрока имеют реальные последствия
- Мир меняется в зависимости от решений
- Невозможность вернуть назад

---

## Архитектура системы мирового состояния

### Уровни влияния

```
Индивидуальный уровень
    ↓
Групповой уровень (кланы, party)
    ↓
Фракционный уровень (репутация, членство)
    ↓
Региональный уровень (города, районы)
    ↓
Глобальный уровень (сервер, мир)
```

### Категории мирового состояния

**1. TERRITORY_CONTROL** - Контроль территорий
- Какая фракция контролирует регион/район
- Сила контроля (0-100)
- Активные конфликты

**2. FACTION_POWER** - Могущество фракций
- Экономическая мощь
- Военная сила
- Политическое влияние

**3. ECONOMY_STATE** - Экономическое состояние
- Цены на ресурсы (динамические)
- Доступность товаров
- Торговые маршруты (активные/заблокированные)

**4. POLITICAL_STATE** - Политическое состояние
- Войны между фракциями
- Альянсы и договоры
- Законы и ограничения

**5. NPC_FATE** - Судьбы NPC
- Жив/мертв/изгнан/реформирован
- Положение в мире
- Влияние на события

**6. TECHNOLOGY_STATE** - Технологический прогресс
- Доступные импланты
- Уровень киберпространства
- Блэкволл состояние

**7. ENVIRONMENT_STATE** - Состояние окружения
- Климат и экология
- Разрушения от войн
- Восстановление регионов

**8. SOCIAL_STATE** - Социальное состояние
- Настроения населения
- Протесты и движения
- Культурные изменения

---

## Системы влияния на мир

### 1. Квестовая система

**Источник:** Выборы игрока в квестах

**Механика влияния:**
- Каждый квест имеет ветви (paths) с разными последствиями
- Последствия применяются к world_state при завершении квеста
- Последствия могут быть локальными (персонаж) или глобальными (сервер)

**Типы последствий:**
- Изменение контроля территорий
- Изменение судьбы NPC (жив/мертв)
- Изменение репутации фракций
- Разблокировка/блокировка квестов
- Изменение мирового состояния (флаги, значения)

**Примеры:**
```
Квест "Капитан Моргана: Грань"
→ Путь Правды → world_state: {npcFates: {morgana: "hero"}, NCPD: "reformed"}
→ Путь Коррупции → world_state: {npcFates: {morgana: "exiled"}, NCPD: "corrupt"}
```

**Формула влияния:**
```
World State Change = Quest Consequence × Player Count Impact × Era Multiplier
```

**Пороги для глобального изменения:**
- Малое влияние: 1-10 игроков (локальное)
- Среднее влияние: 11-100 игроков (региональное)
- Большое влияние: 101-1000 игроков (глобальное)
- Массовое влияние: 1000+ игроков (мировое событие)

**Связанные документы:**
- `.BRAIN/04-narrative/quest-system.md`
- `.BRAIN/06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md`

---

### 2. Экономическая система

**Источник:** Торговля, крафт, производство игроков

**Механика влияния:**
- Спрос/предложение влияет на цены (динамические)
- Массовая торговля влияет на экономику региона
- Производственные цепочки влияют на доступность ресурсов
- Монополии игроков влияют на рынки

**Типы влияния:**
- Изменение цен на товары (±5-50%)
- Дефицит/избыток ресурсов
- Торговые маршруты (открытие/закрытие)
- Экономические кризисы/бумы

**Формулы:**
```
Price = BasePrice × SupplyDemandMultiplier × RegionalMultiplier × EventMultiplier

SupplyDemandMultiplier = 1 + (Demand - Supply) / (Demand + Supply)
- Demand высокий, Supply низкий → цена растет
- Demand низкий, Supply высокий → цена падает

RegionalMultiplier = 1 + (RegionWealth - 50) / 100
- Богатые регионы: +20-50% цены
- Бедные регионы: -20-50% цены

EventMultiplier = 1 + EventModifier
- Война: +30% на оружие
- Кризис: +50% на еду
- Технологический прорыв: -30% на старые товары
```

**Пороги для влияния:**
- Малое влияние: 10-100 сделок в день (локальное изменение цен ±5%)
- Среднее влияние: 100-1000 сделок в день (региональное изменение цен ±15%)
- Большое влияние: 1000-10000 сделок в день (глобальное изменение цен ±30%)
- Кризис: 10000+ сделок или резкое изменение спроса (кризис/бум ±50%)

**Примеры:**
```
Ситуация: Война Arasaka vs Militech
→ Спрос на оружие ↑ (×1.3)
→ Спрос на импланты ↑ (×1.2)
→ Торговые маршруты через зону конфликта закрыты
→ Цены в соседних регионах ↑ (дефицит)
```

**Связанные документы:**
- `.BRAIN/02-gameplay/economy/economy-world-impact.md`
- `.BRAIN/02-gameplay/economy/economy-pricing-detailed.md`
- `.BRAIN/02-gameplay/economy/economy-production-chains.md`

---

### 3. Боевая система и PvP/PvE

**Источник:** Экстракт зоны, рейды, PvP, Faction Wars

**Механика влияния:**
- Победа в Faction War изменяет контроль территории
- Рейды на босов открывают новые технологии
- Защита/захват зон влияет на фракции
- PvP конфликты влияют на репутацию

**Типы влияния:**
- Изменение контроля территорий
- Разблокировка контента (после raid босса)
- Изменение PvP зон (безопасные/опасные)
- Награды для всего сервера

**Формулы:**
```
Territory Control Strength = 
    (Defending Faction Power × 0.6) + (Player Defenders × 0.4)

Faction Power = Economic Power + Military Power + Political Influence
- Economic Power: 0-100 (от economy-world-impact)
- Military Power: 0-100 (от числа боевых NPC и игроков)
- Political Influence: 0-100 (от репутации и альянсов)

Threshold for Territory Change:
- Attacker Power > Defender Power × 1.5 → Territory captured
- Attacker Power > Defender Power × 1.2 → Territory contested
- Attacker Power < Defender Power × 1.2 → Defense holds
```

**Пороги:**
- Малое влияние: 1-5 игроков (локальные стычки)
- Среднее влияние: 5-20 игроков (защита зоны)
- Большое влияние: 20-50 игроков (захват района)
- Массовое влияние: 50+ игроков (faction war, изменение контроля города)

**Примеры:**
```
Событие: Faction War - Arasaka vs Militech (Watson District)
→ Stage 1: 50 игроков Arasaka, 30 игроков Militech
→ Stage 2: 70 Arasaka, 65 Militech (напряжение растет)
→ Stage 3: 100 Arasaka, 95 Militech → Arasaka VICTORY
→ World State: Watson.controller = "Arasaka"
→ Consequences: Militech vendors закрываются, Arasaka vendors открываются, цены меняются
```

**Связанные документы:**
- `.BRAIN/05-technical/start-content/faction-wars/faction-war-system.md`
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md`
- `.BRAIN/02-gameplay/combat/combat-extract.md`

---

### 4. Социальные механики

**Источник:** Репутация, отношения, наем NPC, заказы игроков

**Механика влияния:**
- Репутация с фракциями влияет на доступ к контенту
- Наем NPC изменяет экономику (зарплаты)
- Заказы игроков создают экономические потоки
- Наставничество влияет на обучение новичков

**Типы влияния:**
- Изменение репутации фракций (индивидуальное и массовое)
- Экономические потоки (от заказов и найма)
- Социальные движения (если много игроков действуют вместе)
- Изменение доступного контента (vendors, quests, zones)

**Формулы:**
```
Faction Reputation Global Impact:
- Если >1000 игроков имеют высокую репутацию с фракцией:
  → Faction Power ↑ (+10-20%)
  → Faction Territory Control ↑
  → Новые vendor/quests открываются для всех

NPC Economy Impact:
- Total NPC Salaries Paid = SUM(all_hired_npcs.salary)
- Если Total > Regional GDP × 0.1:
  → Экономическая активность ↑
  → Цены на услуги ↑ (инфляция)
  → Demand на NPC ↑

Player Orders Economy:
- Total Orders Volume = SUM(all_active_orders.value)
- Влияние на рынок услуг (supply/demand)
- Создание специализации игроков
```

**Пороги:**
- Малое влияние: 10-50 игроков (локальное)
- Среднее влияние: 50-500 игроков (региональное)
- Большое влияние: 500-5000 игроков (глобальное)
- Массовое влияние: 5000+ игроков (мировое движение)

**Примеры:**
```
Ситуация: 5000 игроков имеют Exalted репутацию с NetWatch
→ NetWatch faction power ↑ +15%
→ NetWatch контролирует больше территорий
→ Anti-hacking zones ↑ (больше защищенных зон)
→ Цены на NetWatch услуги ↓ (скидки для союзников)
```

**Связанные документы:**
- `.BRAIN/02-gameplay/social/relationships-system.md`
- `.BRAIN/02-gameplay/social/player-orders-world-impact.md`
- `.BRAIN/02-gameplay/social/npc-hiring-world-impact.md`
- `.BRAIN/02-gameplay/social/mentorship-world-impact.md`
- `.BRAIN/02-gameplay/social/reputation-tiers-detailed.md`

---

### 5. Политическая система

**Источник:** Выборы, корпоративные войны, фракционные конфликты

**Механика влияния:**
- Игроки могут голосовать в выборах (мэры, советы)
- Корпоративные интриги (помощь/саботаж корпораций)
- Фракционные войны (выбор стороны)
- Революции и протесты

**Типы влияния:**
- Смена власти в регионах
- Изменение законов (PvP зоны, налоги, доступ)
- Альянсы между фракциями
- Войны и конфликты

**Формулы:**
```
Election Result:
- Total Votes per Candidate = SUM(player_votes)
- Winner = MAX(Total Votes)
- Влияние на мир: новые законы, изменение налогов, доступ к зонам

Faction Alliance Strength:
- Alliance Power = Faction1.Power + Faction2.Power + Player Support
- Player Support = COUNT(players with Exalted reputation) × 10
- Если Alliance Power > Enemy Alliance Power × 1.5:
  → Alliance wins, территории меняют контроль
```

**Пороги:**
- Малое влияние: 100 игроков (локальные выборы)
- Среднее влияние: 500 игроков (региональные выборы)
- Большое влияние: 2000 игроков (выборы мэра города)
- Массовое влияние: 10000+ игроков (глобальные события, войны)

**Примеры:**
```
Событие: Выборы мэра Night City
→ Кандидат А (Arasaka): 5000 голосов
→ Кандидат Б (независимый): 7000 голосов
→ Результат: Независимый мэр побеждает
→ World State: NightCity.mayor = "Independent"
→ Последствия: 
  - Arasaka influence ↓ -10%
  - Налоги ↓ -5%
  - PvP зоны ↑ (больше свободы)
  - Новые квесты от независимого мэра
```

**Связанные документы:**
- `.BRAIN/03-lore/factions/factions-overview.md`
- `.BRAIN/05-technical/mvp-data-json/quests-FACTION-MEDIA-POLITICS.json`

---

### 6. Технологическая система

**Источник:** Исследования, рейды, хакерство, Блэкволл

**Механика влияния:**
- Рейды на боссов разблокируют технологии (для всех)
- Хакерство Блэкволла влияет на киберпространство
- Исследования игроков открывают новые импланты/оружие
- Технологические катастрофы влияют на доступность

**Типы влияния:**
- Разблокировка технологий (импланты, оружие)
- Изменение киберпространства (расширение/сжатие)
- Блэкволл состояние (стабильное/нестабильное)
- Доступность NetWatch услуг

**Формулы:**
```
Technology Unlock Progress:
- Required Player Count = Tech Tier × 100
  - T1 Tech: 100 игроков
  - T2 Tech: 200 игроков
  - T3 Tech: 300 игроков
  - T4 Tech: 400 игроков
  - T5 Tech: 500 игроков

Blackwall Stability:
- Stability = 100 - (Hack Attempts × 0.1) + (NetWatch Defenses × 0.2)
- Если Stability < 50 → Blackwall Breach Event
- Если Stability < 20 → Катастрофа (сеть падает)
```

**Примеры:**
```
Событие: Raid "Blackwall Expedition" завершен (500 игроков участвовало)
→ World State: Blackwall.exploredDepth = "Level5"
→ Technology Unlock: Advanced Netrunning Implants T4
→ Доступно для ВСЕХ игроков на сервере
→ Новые квесты: "Beyond the Blackwall" chain
```

**Связанные документы:**
- `.BRAIN/05-technical/start-content/endgame-raids/raid-blackwall-expedition.md`
- `.BRAIN/02-gameplay/combat/combat-cyberspace.md`
- `.BRAIN/02-gameplay/combat/combat-hacking-networks.md`

---

### 7. Фракционные войны

**Источник:** Участие игроков в Faction Wars

**Механика влияния:**
- Игроки выбирают сторону в войне
- Участие в стадиях войны накапливает очки
- Победившая фракция получает контроль территории
- Проигравшая фракция теряет влияние

**Типы влияния:**
- Контроль территорий (смена владельца)
- Фракционная мощь (±10-30%)
- Доступ к контенту (vendors, quests, zones)
- Визуальные изменения мира (флаги, NPC, patrol)

**Формулы:**
```
Faction War Victory:
- Faction A Score = SUM(player_contributions_A) + Faction A Power
- Faction B Score = SUM(player_contributions_B) + Faction B Power
- Winner = MAX(Faction Scores)

Territory Transfer:
- Winner получает: Territory Control × 1.2
- Loser теряет: Territory Control × 0.7
- Neutral territories: могут быть захвачены

World State Changes:
- Territory.controller = Winner Faction
- Territory.vendors = Winner Faction Vendors
- Territory.patrols = Winner Faction Guards
- Territory.prices = Winner Faction Price Modifiers
```

**Пороги:**
- Малая война: 50-200 игроков (контроль района)
- Средняя война: 200-1000 игроков (контроль нескольких районов)
- Большая война: 1000-5000 игроков (контроль города)
- Мировая война: 5000+ игроков (изменение политической карты)

**Примеры:**
```
Война: Arasaka vs Militech (Watson District)
→ Участники: 2000 игроков Arasaka, 1800 игроков Militech
→ Stage 1-2-3 завершены
→ Результат: Arasaka Victory (52% vs 48%)
→ World State:
  - Watson.controller = "Arasaka"
  - Watson.vendors → Arasaka vendors
  - Watson.patrols → Arasaka security
  - Watson.prices: weapons -10%, Arasaka items -20%
  - Militech.power ↓ -15%
  - Arasaka.power ↑ +15%
```

**Связанные документы:**
- `.BRAIN/05-technical/start-content/faction-wars/faction-war-system.md`
- `.BRAIN/03-lore/factions/factions-overview.md`

---

### 8. Территориальный контроль

**Источник:** Faction Wars, квесты, события

**Механика влияния:**
- Каждая территория имеет контроллера (фракция)
- Контроль может быть оспорен (contested)
- Игроки могут защищать или атаковать территории
- Контроль влияет на геймплей в регионе

**Категории территорий:**
- Районы городов (Watson, Westbrook, etc)
- Целые города (Night City, Tokyo, Berlin)
- Регионы (Badlands, Pacifica, etc)
- Глобальные зоны (киберпространство, Blackwall)

**Формулы:**
```
Territory Control = (Faction Power × 0.5) + (Player Support × 0.3) + (Historical Control × 0.2)

Faction Power: экономическая + военная мощь
Player Support: COUNT(players with high reputation)
Historical Control: как долго фракция контролирует (1-100)

Contest Check:
- Если Challenger Power > Current Controller Power × 1.3:
  → Territory becomes CONTESTED
  → Faction War может начаться
```

**Влияние на геймплей:**
- **Vendors:** Фракционные торговцы
- **Quests:** Квесты от контролирующей фракции
- **Patrols:** Guards и patrol NPCs
- **Prices:** Модификаторы цен (±10-30%)
- **Safety:** PvP зоны или безопасные зоны
- **Access:** Доступ к определенным зонам

**Примеры:**
```
Территория: Watson District
→ Controller: Arasaka (control_strength: 85/100)
→ Влияние на игроков:
  - Vendors: Arasaka shops (оружие -15%, импланты -10%)
  - Quests: Arasaka quest givers активны
  - Patrols: Arasaka security (aggressive к врагам Arasaka)
  - PvP: Безопасная зона для союзников Arasaka
  - Access: Arasaka Tower открыт для Exalted reputation
```

**Связанные документы:**
- `.BRAIN/06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md` (таблица territory_control)

---

### 9. NPC Судьбы (NPC Fates)

**Источник:** Квесты, выборы игроков, события

**Механика влияния:**
- Игроки определяют судьбу важных NPC
- NPC может быть убит, спасен, реформирован, изгнан
- Судьба NPC влияет на доступный контент
- Множественные игроки могут влиять (голосование)

**Типы судеб:**
- ALIVE - жив, доступен для квестов
- DEAD - убит, квесты закрыты
- EXILED - изгнан, контент изменен
- IMPRISONED - в тюрьме, может быть освобожден
- REFORMED - реформирован, новые квесты
- HOSTILE - враждебен, PvP
- FRIENDLY - дружелюбен, бонусы

**Механика для MMORPG:**
```
NPC Fate Voting System:
- Каждый игрок делает выбор в квесте
- Подсчитываются голоса за каждую судьбу
- Судьба с большинством голосов применяется к СЕРВЕРУ
- Меньшинство получает альтернативный контент

Formula:
- NPC Fate = MODE(all_player_choices)
- Если MODE > 50% → эта судьба применяется
- Если нет явного большинства → NPC остается в UNCERTAIN состоянии

Threshold for Permanent Change:
- 100+ игроков прошли квест → судьба фиксируется
- <100 игроков → судьба может измениться
```

**Примеры:**
```
Квест: "Капитан Моргана: Грань"
→ 1000 игроков прошли квест:
  - 600 выбрали "Путь Правды" → Моргана становится героем
  - 300 выбрали "Путь Коррупции" → Моргана изгнана
  - 100 выбрали "Путь Одиночки" → Моргана уходит
→ Результат (60% большинство): Morgana = HERO
→ World State: npc_morgana_fate = "hero"
→ Последствия:
  - NCPD Reform quest chain открывается
  - Моргана становится quest giver
  - NCPD reputation +5 для всех
```

**Связанные документы:**
- `.BRAIN/06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md` (таблица npc_states)
- `.BRAIN/03-lore/characters/characters-overview.md`

---

### 10. Глобальные события

**Источник:** World Events, эпохи, мировые кризисы

**Механика влияния:**
- Мир живет сам по себе (события происходят автоматически)
- Игроки могут влиять на исход событий
- Массовое участие игроков изменяет результат
- События влияют на все системы

**Типы событий:**
- **Political:** Войны, революции, выборы
- **Economic:** Кризисы, бумы, санкции
- **Technological:** Прорывы, катастрофы (DataKrash, Blackwall)
- **Environmental:** Климатические изменения
- **Social:** Протесты, движения

**Формулы:**
```
Event Outcome:
- Base Probability: определена в world-events-framework
- Player Influence = SUM(player_actions) × Player Impact Weight
- Final Probability = Base Probability + Player Influence

Event Impact = Event Magnitude × (1 + Player Participation Rate)
- Event Magnitude: 1-10 (масштаб события)
- Player Participation Rate: 0-2 (0% = 0, 100% = 1, 200% = 2)

Threshold for Player Impact:
- 500+ участников: локальное событие
- 2000+ участников: региональное событие
- 10000+ участников: глобальное событие
```

**Примеры:**
```
Событие: "Blackwall Breach 2077"
→ Base Probability: 80% catastrophe
→ Player Actions: 5000 Netrunners работают над защитой
→ Player Influence: -30% catastrophe chance
→ Final Result: 50% catastrophe (контролируемое)
→ World State:
  - Blackwall.stability = 50/100 (было 80/100)
  - Cyberspace.accessRestricted = true (частично)
  - NetWatch.power ↑ +20% (благодаря игрокам)
  - Новые defensive quests для всех
```

**Связанные документы:**
- `.BRAIN/02-gameplay/world/events/global-events-2020-2093.md`
- `.BRAIN/02-gameplay/world/events/world-events-framework.md`

---

## Механика накопления влияния

### Система весов влияния

**Индивидуальное влияние:**
```
Individual Impact Weight = Base Weight × Level Multiplier × Reputation Multiplier

Base Weight = 1.0 (для всех игроков)
Level Multiplier = 1 + (PlayerLevel / 100)
  - Level 1: ×1.01
  - Level 50: ×1.5
  - Level 100: ×2.0

Reputation Multiplier = 1 + (Reputation Tier / 10)
  - Neutral (Tier 4): ×1.4
  - Friendly (Tier 5): ×1.5
  - Honored (Tier 6): ×1.6
  - Exalted (Tier 7): ×1.7
  - Legendary (Tier 8): ×1.8
```

**Групповое влияние (кланы):**
```
Clan Impact = SUM(member_impacts) × Clan Bonus

Clan Bonus:
- Small clan (<10): ×1.0
- Medium clan (10-50): ×1.2
- Large clan (50-200): ×1.5
- Mega clan (200+): ×2.0
```

**Фракционное влияние:**
```
Faction Impact = (Player Count × Average Impact) + Faction NPC Power

Faction NPC Power:
- Численность NPC
- Экономическая мощь
- Военная сила
- Политическое влияние
```

---

## Распространение влияния

### Локальное → Региональное → Глобальное

**Модель каскадного влияния:**
```
1. Локальное действие (1 игрок):
   → Изменяет локальное состояние (район, NPC)
   
2. Множественные локальные действия (10-100 игроков):
   → Накапливаются в региональное влияние
   → Изменяют состояние региона (город, фракция)
   
3. Региональное влияние (100-1000 игроков):
   → Изменяет состояние нескольких регионов
   → Влияет на глобальные системы (экономика, политика)
   
4. Глобальное влияние (1000+ игроков):
   → Изменяет мировое состояние (сервер)
   → Влияет на всех игроков
   → Создает мировые события
```

**Формула распространения:**
```
Regional Impact = SUM(Local Impacts in Region) × Regional Multiplier
Global Impact = SUM(Regional Impacts) × Global Multiplier

Regional Multiplier:
- Малый регион (1 район): ×0.5
- Средний регион (город): ×1.0
- Большой регион (страна): ×1.5

Global Multiplier:
- Обычное действие: ×0.1
- Важное действие: ×0.5
- Критическое действие: ×1.0
- Мировое событие: ×2.0
```

---

## Временные рамки влияния

### Немедленное влияние
- Выбор в квесте → немедленно применяется
- Покупка товара → немедленно влияет на цены
- Смерть NPC → немедленно блокирует квесты

### Краткосрочное влияние (1-7 дней)
- Репутация фракций → применяется в течение дня
- Экономические изменения → обновляются ежедневно
- Faction War stages → каждые 1-3 дня

### Среднесрочное влияние (1-4 недели)
- Территориальный контроль → изменяется еженедельно
- Технологические разблокировки → раз в 2 недели
- Глобальные события → раз в месяц

### Долгосрочное влияние (1+ месяцев)
- Изменение эпох → по расписанию или через мировые события
- Перманентные изменения мира → навсегда
- Эволюция фракций → постепенно

---

## Категории влияния игроков

### 1. Прямое влияние (Direct Impact)

**Определение:** Игрок напрямую влияет на мировое состояние

**Примеры:**
- Убийство NPC → NPC мертв
- Выбор пути в квесте → последствия применяются
- Покупка товара → цена меняется
- Захват территории → контроль меняется

**Вес:** 100% (полное влияние)

### 2. Косвенное влияние (Indirect Impact)

**Определение:** Действия игрока влияют через систему

**Примеры:**
- Торговля → влияет на экономику → влияет на цены → влияет на доступность
- Репутация → влияет на фракцию → влияет на мощь фракции → влияет на территорию
- Наем NPC → влияет на зарплаты → влияет на экономику → влияет на инфляцию

**Вес:** 10-50% (частичное влияние через цепочку)

### 3. Коллективное влияние (Collective Impact)

**Определение:** Множество игроков влияет вместе

**Примеры:**
- 1000 игроков голосуют → выборы мэра
- 500 игроков участвуют в рейде → технология разблокируется
- 2000 игроков поддерживают фракцию → фракция побеждает в войне

**Вес:** Сумма индивидуальных весов × групповой бонус

### 4. Системное влияние (Systemic Impact)

**Определение:** Влияние через игровые системы (автоматическое)

**Примеры:**
- Экономика балансирует сама (supply/demand)
- Фракции воюют сами (AI)
- События происходят по расписанию
- Мир развивается сам (KENSHI стиль)

**Вес:** Не зависит от игроков (но игроки могут влиять косвенно)

---

## Механика конфликтов влияний

### Когда игроки действуют против друг друга

**Проблема:** 500 игроков хотят Arasaka, 500 хотят Militech

**Решение: Система голосования с весами**

```
Faction A Support = SUM(player_impacts_for_A)
Faction B Support = SUM(player_impacts_for_B)

Winner = MAX(Faction Supports)

Margin of Victory:
- <5% разница: CONTESTED (война продолжается)
- 5-20% разница: NARROW VICTORY (нестабильный контроль)
- 20-50% разница: CLEAR VICTORY (стабильный контроль)
- >50% разница: OVERWHELMING VICTORY (полный контроль)
```

**Последствия по margin:**
- CONTESTED: Territory может быть отбита, постоянные конфликты
- NARROW: Territory контролируется, но часто events
- CLEAR: Territory стабильно контролируется
- OVERWHELMING: Territory полностью контролируется, бонусы

---

## Мировое состояние (World State) - Структура данных

### Глобальные ключи состояния

**Формат:** `category.region.district.key`

**Примеры:**
```
territory.nightCity.watson.controller = "Arasaka"
territory.nightCity.watson.controlStrength = 85
territory.nightCity.watson.contested = false

economy.nightCity.weapons.priceMultiplier = 1.15
economy.nightCity.implants.availability = "high"

politics.nightCity.mayor = "Independent"
politics.nightCity.laws.pvpEnabled = false

npc.morgana.fate = "hero"
npc.morgana.location = "NCPDHeadquarters"
npc.johnnySilverhand.state = "DEAD"

technology.blackwall.stability = 65
technology.cyberspace.accessLevel = "restricted"

social.nightCity.population.mood = "tense"
social.nightCity.protests.active = true
```

---

## Синхронизация мирового состояния (MMORPG)

### Модель синхронизации

**Server-wide State:**
- Одно состояние на сервер
- Все игроки видят одинаковое мировое состояние
- Изменения применяются глобально

**Phasing (фазирование):**
- Личные квесты: используют phasing (игрок видит свою версию)
- Глобальные события: все видят одинаково
- NPC судьбы: глобальные (голосование)

**Формула синхронизации:**
```
Update Frequency:
- Critical changes (territory control): instant
- Economic changes (prices): every 5 minutes
- Reputation changes: every hour
- Global events: scheduled or event-driven

Sync Strategy:
- WebSocket для критических изменений
- Polling для некритических
- Event-driven для мировых событий
```

---

## Отображение влияния для игрока

### UI элементы

**World State Dashboard:**
- Текущий контроль территорий (карта)
- Экономическое состояние (цены, доступность)
- Политическая обстановка (войны, альянсы)
- NPC судьбы (важные персонажи)
- Глобальные события (активные, предстоящие)

**Player Impact Dashboard:**
- Личный вклад в мировое состояние
- Рейтинг влияния на сервере
- История изменений мира (где игрок участвовал)
- Достижения за влияние на мир

**Notifications:**
- "Watson District захвачен Arasaka!" (territory change)
- "Капитан Моргана стала героем благодаря действиям игроков!" (NPC fate)
- "Blackwall стабилизирован силами Netrunners!" (technology)
- "Выборы в Night City: Независимый мэр победил!" (politics)

---

## Интеграция с существующими системами

### Связь с БД (таблицы)

**Из `quest-branching-database-design.md`:**
- `world_state` - хранение мирового состояния
- `world_state_history` - история изменений
- `territory_control` - контроль территорий
- `npc_states` - состояние NPC
- `player_quest_choices` - выборы игроков
- `quest_consequences` - последствия квестов

### Связь с игровыми системами

**Экономика:**
- `economy-world-impact.md` → цены, ресурсы
- `economy-pricing-detailed.md` → формулы цен
- `trading-routes-global.md` → торговые маршруты

**Социальные механики:**
- `relationships-system.md` → репутация
- `player-orders-world-impact.md` → заказы
- `npc-hiring-world-impact.md` → наем NPC
- `mentorship-world-impact.md` → наставничество

**Боевая система:**
- `combat-pvp-pve.md` → PvP зоны
- `combat-extract.md` → экстракт зоны

**Квесты:**
- `quest-system.md` → система квестов
- Quest branching → ветвления и последствия

**Мировые события:**
- `world-events-framework.md` → фреймворк событий
- `global-events-2020-2093.md` → глобальные события

---

## API Endpoints для мирового состояния

### Чтение состояния

**GET `/api/v1/world/state`** - получить полное мировое состояние сервера
```json
{
  "serverId": "server-01",
  "timestamp": "2025-11-06T21:00:00Z",
  "territories": {
    "nightCity": {
      "watson": {
        "controller": "Arasaka",
        "controlStrength": 85,
        "contested": false
      }
    }
  },
  "economy": {
    "priceMultipliers": {
      "weapons": 1.15,
      "implants": 0.95
    }
  },
  "npcFates": {
    "morgana": "hero",
    "johnnySilverhand": "dead"
  },
  "globalEvents": {
    "active": ["blackwall-breach-2077"],
    "upcoming": ["parametric-fair-2082"]
  }
}
```

**GET `/api/v1/world/state/{category}`** - получить состояние по категории
- `/api/v1/world/state/territories`
- `/api/v1/world/state/economy`
- `/api/v1/world/state/npc-fates`
- `/api/v1/world/state/global-events`

**GET `/api/v1/world/state/history`** - история изменений мирового состояния

### Влияние на состояние

**POST `/api/v1/world/state/player-impact`** - зарегистрировать влияние игрока
```json
{
  "playerId": "uuid",
  "impactType": "QUEST_CHOICE | ECONOMIC_ACTION | COMBAT_ACTION | SOCIAL_ACTION",
  "category": "TERRITORY_CONTROL | FACTION_POWER | ECONOMY_STATE | ...",
  "changes": {
    "territoryControl": {"watson": {"arasaka": +5}},
    "economy": {"weapons": {"demand": +100}}
  },
  "weight": 1.5
}
```

**GET `/api/v1/world/player-impact/{playerId}`** - получить влияние конкретного игрока
```json
{
  "playerId": "uuid",
  "totalImpact": 1500,
  "impactByCategory": {
    "territory": 500,
    "economy": 300,
    "politics": 200
  },
  "worldChanges": [
    {
      "stateKey": "territory.nightCity.watson.controller",
      "oldValue": "Militech",
      "newValue": "Arasaka",
      "playerContribution": "5%"
    }
  ]
}
```

---

## Балансировка влияния

### Предотвращение доминирования

**Проблема:** Большие кланы могут доминировать над миром

**Решения:**

**1. Diminishing Returns (Уменьшающаяся отдача):**
```
Effective Impact = Base Impact / (1 + ln(Player Count / 100))

100 игроков: ×1.0
1000 игроков: ×0.4 (diminished)
10000 игроков: ×0.2 (heavily diminished)
```

**2. Counterbalance System (Система противовесов):**
```
Если одна фракция доминирует (>70% контроля):
→ Другие фракции получают бонусы (+30% power)
→ Глобальные события помогают слабым
→ Игроки получают квесты против доминанта
```

**3. Region Caps (Ограничения по регионам):**
```
Максимальный контроль одной фракции:
- Район: 100% (может полностью контролировать)
- Город: 80% (не может монополизировать весь город)
- Страна: 60% (должны быть другие фракции)
- Глобально: 40% (не может доминировать над миром)
```

**4. Rotation Events (События ротации):**
```
Каждые 1-2 месяца:
→ Глобальное событие, которое меняет баланс сил
→ Новые фракции усиливаются
→ Старые фракции ослабляются
→ Территории могут быть переопределены
```

---

## Примеры сценариев влияния

### Сценарий 1: Малая группа игроков (5-10)

**Действие:** 10 игроков завершают квест "Защита торговца"

**Влияние:**
- Локальное: Торговец выживает, его shop остается открытым
- Репутация: +10 с Nomads (индивидуально)
- Экономика: Торговый маршрут остается активным
- World State: `npc.trader_nomad.fate = "alive"`

**Масштаб:** Локальный (один район)

### Сценарий 2: Средняя группа (50-100)

**Действие:** 100 игроков поддерживают NCPD в квесте "Реформа полиции"

**Влияние:**
- Региональное: NCPD усиливается в Watson
- Репутация: +15 с NCPD (индивидуально)
- Политика: NCPD.power ↑ +10%
- World State: `politics.nightCity.ncpd = "reformed"`
- Территория: NCPD контроль в Watson ↑ +15%

**Масштаб:** Региональный (город)

### Сценарий 3: Большая группа (500-1000)

**Действие:** 1000 игроков участвуют в Faction War (Arasaka vs Militech)

**Влияние:**
- Глобальное: Смена контроля нескольких районов
- Экономика: Цены на оружие ↑ +30% (война)
- Политика: Arasaka побеждает, Militech.power ↓ -20%
- World State:
  - `territory.nightCity.watson.controller = "Arasaka"`
  - `territory.nightCity.cityCenter.controller = "Arasaka"`
  - `factionPower.arasaka = 75` (было 60)
  - `factionPower.militech = 40` (было 50)
- Территория: 3 района меняют контроль
- Vendors: Arasaka vendors открываются, Militech закрываются

**Масштаб:** Глобальный (весь сервер)

### Сценарий 4: Массовое участие (5000+)

**Действие:** 5000 Netrunners защищают Blackwall от breach

**Влияние:**
- Мировое: Blackwall стабилизирован
- Технология: Advanced Netrunning Implants T4 разблокированы
- World State:
  - `technology.blackwall.stability = 80` (было 30)
  - `technology.blackwall.breachPrevented = true`
  - `technology.implants.t4Netrunning = "unlocked"`
- Новые квесты: "Deep Dive" chain для всех
- NetWatch.power ↑ +25%
- Экономика: Цены на Netrunning импланты ↓ -20% (доступность)

**Масштаб:** Мировое событие (влияет на всю игру)

---

## Отслеживание влияния

### Player Impact Score

**Формула:**
```
Player Impact Score = 
    Quest Impact + Economic Impact + Combat Impact + Social Impact

Quest Impact = SUM(quest_consequences.weight × path_rarity)
Economic Impact = (Total Trades × 0.01) + (Production Value × 0.001)
Combat Impact = (PvP Wins × 10) + (PvE Boss Kills × 50) + (Territory Defenses × 100)
Social Impact = (Reputation Changes × 5) + (NPC Relationships × 10)
```

### Leaderboard

**Категории:**
- Топ по общему влиянию на мир
- Топ по экономическому влиянию
- Топ по политическому влиянию
- Топ по военному влиянию (PvP, territory)
- Топ по социальному влиянию (reputation, relationships)

**Награды:**
- Топ-10: Уникальные титулы ("World Shaper", "Kingmaker")
- Топ-100: Специальные rewards
- Отображение в UI (leaderboard)

---

## Ограничения и правила

### 1. Невозможность полного контроля

**Правило:** Ни один игрок/клан не может контролировать весь мир

**Механизмы:**
- Diminishing returns от количества
- Region caps (максимум 40-80% контроля)
- Counterbalance events (события против доминантов)
- AI фракции всегда присутствуют

### 2. Обратимость изменений

**Частично обратимые:**
- Контроль территорий (может быть отбит)
- Экономическое состояние (цены восстанавливаются)
- Политика (выборы могут изменить)

**Необратимые:**
- Смерть NPC (навсегда, если нет воскрешения)
- Разблокировка технологий (навсегда)
- Исторические события (эпохи не откатываются)

### 3. Защита от эксплойтов

**Защиты:**
- Rate limiting на изменения world state
- Проверка валидности влияния (anti-cheat)
- Минимальные пороги для изменений (нельзя изменить 1 действием)
- Логирование всех изменений (аудит)

---

## Интеграция с лигами (эпохами)

### Изменение мира между лигами

**Каждая лига (season):**
- Начинается с определенного world state (базовое состояние эпохи)
- Игроки влияют на мир в течение лиги
- В конце лиги: world state фиксируется
- Следующая лига: может начаться с нового состояния ИЛИ продолжить

**Механика:**
```
League Start:
→ World State reset to era baseline (2020, 2030, 2045, etc)
→ Players start influencing

League End:
→ World State saved as "league_N_final_state"
→ Top contributors rewarded
→ Statistics published

Next League:
→ Option A: Continue from final state (persistent world)
→ Option B: Reset to next era baseline (fresh start)
```

**Связанные документы:**
- `.BRAIN/03-lore/universe.md` (лиги и эпохи)

---

## Примеры влияния по системам

### Квесты → World State

```
Квест: "Война Валентинос против Maelstrom"
→ 2000 игроков выбрали Valentinos
→ 1500 игроков выбрали Maelstrom

World State Changes:
- territory.nightCity.heywood.controller = "Valentinos" (было "contested")
- territory.nightCity.heywood.controlStrength = 60
- factionPower.valentinos = 55 (было 45)
- factionPower.maelstrom = 35 (было 40)
- npc.joseValentino.fate = "gangLeader" (усилился)
- npc.royce.fate = "weakened" (ослаб)

Последствия для игроков:
- Valentinos vendors: доступны в Heywood
- Maelstrom vendors: закрыты в Heywood
- Новые квесты: Valentinos expansion chain
- Цены: Valentinos items -20% в Heywood
```

### Экономика → World State

```
Действие: 10000 игроков массово покупают оружие (война)
→ Demand на оружие ↑ ×5
→ Supply не успевает за demand

World State Changes:
- economy.weapons.demand = 500000 (было 100000)
- economy.weapons.supply = 150000 (медленно растет)
- economy.weapons.priceMultiplier = 2.5 (было 1.0)
- economy.weapons.availability = "low" (было "medium")

Последствия:
- Цены на оружие ↑ +150%
- Crafters получают больше заказов
- Производственные цепочки активируются
- Новые trade routes открываются (для импорта)
```

### Боевая система → World State

```
Событие: Raid "Corpo Tower Assault" (500 игроков)
→ Босс убит: Arasaka CEO падает
→ Arasaka теряет контроль

World State Changes:
- npc.arasakaCEO.fate = "dead"
- factionPower.arasaka = 50 (было 75) - драматическое падение
- territory.nightCity.corporatePlaza.controller = "contested" (было "Arasaka")
- technology.arasakaImplants.availability = "low" (disrupted)

Последствия:
- Arasaka territories становятся contested
- Другие фракции начинают экспансию
- Новые квесты: "Power Vacuum" chain
- Экономика: Arasaka items ↑ +50% (дефицит)
```

### Социальные → World State

```
Действие: 1000 игроков имеют Exalted с NetWatch
→ Массовая поддержка фракции

World State Changes:
- factionPower.netwatch = 70 (было 55)
- territory.nightCity.netWatchBuilding.safetyLevel = "high"
- politics.netwatch.influence = "strong"

Последствия:
- NetWatch может начать expansion
- Anti-hacking zones ↑
- Цены на NetWatch услуги ↓ -15% (для союзников)
- Новые NetWatch quests для всех
```

---

## Система приоритетов влияния

### Иерархия влияний (что важнее)

**1. Критические (Priority: 10):**
- Смерть важного NPC
- Смена контроля города
- Технологическая катастрофа
- Мировое событие

**2. Высокие (Priority: 7-9):**
- Смена контроля района
- Faction War результаты
- Экономический кризис
- Политические выборы

**3. Средние (Priority: 4-6):**
- Репутационные изменения
- Экономические изменения (цены)
- NPC судьбы (обычные)
- Разблокировка контента

**4. Низкие (Priority: 1-3):**
- Локальные изменения
- Личные флаги игроков
- Малые экономические сдвиги

**Правило разрешения конфликтов:**
```
Если два влияния конфликтуют:
→ Применяется влияние с более высоким priority
→ Если priority равны → применяется влияние с большим player count
→ Если player count равен → применяется более раннее по времени
```

---

## Визуализация влияния

### World Map (Карта мира)

**Отображение:**
- Цвет территорий = контролирующая фракция
- Интенсивность цвета = сила контроля
- Contested зоны = мигающие/полосатые
- Иконки = активные события

**Легенда:**
```
Красный: Arasaka
Синий: Militech
Желтый: Nomads
Зеленый: NetWatch
Фиолетовый: VoodooBoys
Оранжевый: Valentinos
Серый: Neutral/Independent
```

### Timeline (Хронология изменений)

**Формат:**
```
2025-11-06 21:00 - Watson District captured by Arasaka (2000 players)
2025-11-06 20:00 - Captain Morgana became a hero (1000 players voted)
2025-11-06 19:00 - Weapon prices increased +30% (war demand)
2025-11-06 18:00 - NetWatch expanded to Westbrook (500 players support)
```

### Impact Heatmap (Тепловая карта влияния)

**Показывает:**
- Где игроки наиболее активно влияют на мир
- Горячие точки (hotspots) - активные зоны изменений
- Холодные зоны - стабильные регионы

---

## Технические детали

### Хранение в БД

**Таблица `world_state`:**
```sql
CREATE TABLE world_state (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL,
    state_key VARCHAR(200) NOT NULL,
    state_value TEXT NOT NULL,
    state_type VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    region VARCHAR(100),
    description TEXT,
    set_by_quest_id VARCHAR(100),
    set_by_event_id VARCHAR(100),
    affected_players_count INTEGER DEFAULT 0,
    previous_value TEXT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(server_id, state_key)
);
```

**Индексы:**
- `(server_id, category, region)` - быстрый поиск по региону
- `(state_key)` - быстрый поиск конкретного ключа
- `(changed_at)` - хронология изменений

### Кэширование

**Redis Cache:**
```
Key: world_state:{serverId}:{category}
TTL: 5 minutes (для некритических)
TTL: 1 minute (для критических)

Invalidation:
- При изменении world state → invalidate cache
- Broadcast через WebSocket всем игрокам
```

### WebSocket события

**Events:**
```
WORLD_STATE_CHANGED:
{
  "category": "TERRITORY_CONTROL",
  "stateKey": "territory.nightCity.watson.controller",
  "oldValue": "Militech",
  "newValue": "Arasaka",
  "timestamp": "2025-11-06T21:00:00Z",
  "affectedPlayers": 2000
}

GLOBAL_EVENT_TRIGGERED:
{
  "eventId": "blackwall-breach-2077",
  "eventType": "TECHNOLOGICAL_CATASTROPHE",
  "severity": "HIGH",
  "affectedRegions": ["all"],
  "timestamp": "2025-11-06T21:00:00Z"
}
```

---

## Метрики и аналитика

### Метрики влияния

**Для игроков:**
- Total World Impact Score
- Impact by Category (quest, economy, combat, social)
- World Changes Caused (count)
- Participation in Global Events (count)

**Для сервера:**
- Total World State Changes per Day
- Most Active Regions (where players impact most)
- Most Influential Players (top 100)
- Faction Power Distribution
- Territory Control Distribution

**Для разработчиков:**
- Популярность квестовых путей (%)
- Экономический баланс (inflation/deflation)
- Faction balance (распределение сил)
- Player retention по влиянию на мир

---

## Связанные документы

### Игровые системы
- `.BRAIN/02-gameplay/economy/economy-world-impact.md` - влияние экономики
- `.BRAIN/02-gameplay/social/player-orders-world-impact.md` - влияние заказов
- `.BRAIN/02-gameplay/social/npc-hiring-world-impact.md` - влияние найма NPC
- `.BRAIN/02-gameplay/social/mentorship-world-impact.md` - влияние наставничества
- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - PvP/PvE влияние

### Квесты и события
- `.BRAIN/04-narrative/quest-system.md` - система квестов
- `.BRAIN/02-gameplay/world/events/global-events-2020-2093.md` - глобальные события
- `.BRAIN/02-gameplay/world/events/world-events-framework.md` - фреймворк событий

### Технические
- `.BRAIN/06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md` - БД для ветвления
- `.BRAIN/05-technical/api-specs/api-endpoints-complete.md` - API endpoints

### Лор и концепции
- `.BRAIN/01-concepts/core-pillars.md` - столпы игры (выборы имеют значение)
- `.BRAIN/03-lore/universe.md` - лиги и эпохи
- `.BRAIN/03-lore/factions/factions-overview.md` - фракции

---

## TODO для дальнейшей проработки

**Балансировка (низкий приоритет, не блокирует API):**
- [ ] Точная балансировка формул влияния (коэффициенты, пороги)
- [ ] Балансировка diminishing returns (подобрать оптимальные значения)
- [ ] Балансировка region caps по фракциям
- [ ] Балансировка частоты rotation events

**Детализация (средний приоритет):**
- [ ] Детализация phasing system для MMORPG (личное vs глобальное состояние)
- [ ] Детализация событий ротации баланса сил
- [ ] Детализация системы противовесов (counterbalance)

**Интеграция (высокий приоритет, но после API):**
- [ ] Интеграция с UI (world map, dashboards, notifications)
- [ ] Интеграция с аналитикой (метрики, leaderboards)
- [ ] Интеграция с WebSocket (real-time updates)

---

## История изменений

- **v1.0.0 (2025-11-06 21:19)** - Создан централизованный документ о влиянии игроков на мировое состояние
  - Определены 8 категорий мирового состояния
  - Описаны 10 систем влияния на мир
  - Разработаны формулы накопления и распространения влияния
  - Определены пороги влияния (локальное → глобальное)
  - Описана система балансировки и защиты от доминирования
  - Приведены примеры сценариев влияния
  - Определены API endpoints и технические детали
  - Связаны все существующие системы влияния на мир

---

## Заключение

Этот документ объединяет ВСЕ системы влияния игроков на мир:
- ✅ Квесты и выборы
- ✅ Экономика и торговля
- ✅ Боевая система (PvP/PvE, Faction Wars)
- ✅ Социальные механики (репутация, наем, заказы)
- ✅ Политика и выборы
- ✅ Технологии и исследования
- ✅ Территориальный контроль
- ✅ NPC судьбы
- ✅ Глобальные события

**Ключевые принципы:**
1. **Живой мир** - мир существует независимо от игроков
2. **Реальное влияние** - действия игроков реально меняют мир
3. **Масштабируемость** - от локального до глобального
4. **Баланс** - защита от доминирования
5. **Последствия** - выборы имеют значение
6. **MMORPG** - множество игроков влияют вместе

**Готовность:** READY для создания API задач! ✅

