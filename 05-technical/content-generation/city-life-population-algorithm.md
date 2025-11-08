---
**api-readiness:** needs-work  
**api-readiness-check-date:** 2025-11-07 20:35
**api-readiness-notes:** Алгоритм наполнения городов с ER-схемами, Kafka payload и baseline. Требуется оформить swagger-задачи и интеграцию в API-SWAGGER.
---

# Алгоритм наполнения городов NPC и инфраструктурой

**Статус:** В разработке — ER+Baseline итерация  
**Версия:** 0.3.0  
**Дата:** 2025-11-07 20:35  
**Приоритет:** Высокий  
**Автор:** AI Brain Manager

**Микросервисы:** world-service (8086), social-service (8084), economy-service (8085), gameplay-service (8083)  
**Фронтенд модули:** world (production), social (production), economy (production), gameplay (MVP)

---

## Цель и ключевые эффекты

- Создать живые города с динамичной плотностью NPC, инфраструктурой и активностями, которые реагируют на действия игрока и глобальные события.
- Обеспечить согласованность между лором (`03-lore/locations`), механиками (`02-gameplay/world`) и технической реализацией (`05-technical`).
- Подготовить данные и процессы для последующей автоматизации API задач и наполнения БД без жёстко захардкоженных сущностей.

---

## Входные данные и каталоги

- `world_city_blueprints` — стационарные контуры районов, доступные площади, транспортные узлы (world-service).
- `npc_archetype_library` — архетипы NPC, роли, поведенческие шаблоны, требования к инфраструктуре (social-service + контент-пайплайн).
- `infrastructure_catalog` — типы объектов (жильё, сервисы, развлечения, безопасность, нелегальная инфраструктура) с емкостями и потребностями в персонале (economy-service).
- `event_schedule` — список глобальных и локальных событий, влияющих на трафик и потребности (world-service events).
- `player_impact_stream` — данные о владениях фракций, прогрессе квестов, экономических трендах игроков (gameplay-service + economy-service telemetry).

---

## Поток наполнения города

1. **Сегментация районов:** кластеризация кварталов по функциям (жилая, деловая, промышленная, культурная, криминальная, смешанная) на основе blueprint и исторических метрик.
2. **Расчёт спроса:** определение потребностей в инфраструктуре и NPC по целевым метрикам плотности, событиям, времени суток и влиянию фракций.
3. **Генерация инфраструктуры:** подбор объектов из каталога с учётом лимитов площади, энергопотребления, синергий и зависимостей.
4. **Формирование NPC-пула:** сбор архетипов с культурными фильтрами, сюжетными связями и квотами редкости.
5. **Назначение расписаний:** построение FSM, маршрутов и режимов (день, ночь, события, чрезвычайка) с учётом транспорта и угроз.
6. **Интеграция событий:** наложение глобальных/локальных ивентов, временных локаций и уникальных NPC.
7. **Синхронизация с миром:** публикация конфигурации в `world_state`, `social_graph`, `economy_supply`; генерация патчей для фронтенда.
8. **Реакция на игрока:** асинхронный пересчёт затронутых сегментов при захватах, росте криминала, экономических всплесках.

---

## Алгоритмические детали

### Сегментация районов
- Метрики: `density`, `wealth`, `crime`, `tech`, `culture`, `faction` ∈ [0,1].
- Скоринг: `score = Σ(weight_i * metric_i)` (веса задаёт world-service).
- Кластеризация: k-prototypes (k = 6–8) для смешанных признаков.
- Псевдокод:

```
for segment in city.blueprint:
    features = buildFeatureVector(segment)
    clusterId = clusterModel.predict(features)
    profile = profileCatalog[clusterId]
    saveDistrictProfile(segment.id, profile)
```

### Оптимизация инфраструктуры
- Ограничения: площадь, энергобюджет, бюджет, безопасность, шум.
- Цель: `maximize coverage * α + economy * β + security * γ - penalties`.
- Стратегия: обязательные объекты (линейные ограничения) + локальный поиск (simulated annealing) для вариативных.

### Построение пула NPC
- Квоты: `quota(role) = base(role, profile) * demand_modifier * event_modifier`.
- Фильтры: культура, язык, фракции, редкость.
- Выход: `npc_profile` (личность, связи, сюжетные триггеры, привязка к инфраструктуре).

### Генерация расписаний
- FSM: состояния `home`, `work`, `leisure`, `transit`, `event`, `underground`.
- Шаблоны: рабочий день, ночная смена, криминал, турист, уникальный сюжет.
- Маршруты: граф дорог/метро/туннелей; economy-service корректирует веса при перегрузке.

### Динамический адаптер
- Подписка: `world.events.*`, `social.relations.*`, `economy.alerts.*`, `gameplay.player-impact.*`.
- Быстрые триггеры (< 1 игровой минуты) и плановые (ночные batch-пересчёты).
- Патчи world_state включают таймкоды для согласованной визуализации.

---

## Модули алгоритма

1. **Сегментация и профили:** формирование `district_profile`.
2. **Планировщик инфраструктуры:** обязательные/вариативные объекты, зависимые сервисы.
3. **Генератор NPC:** архетипы, связи, редкость, культурные фильтры.
4. **Планировщик расписаний:** FSM, тайм-слоты, маршруты.
5. **Динамический адаптер:** события, обновление мирового состояния.
6. **Контур качества:** валидация метрик, AI load tests, QA сценарии.

---

## Интеграция по микросервисам

- **world-service (8086):** blueprint городов, события, версионирование мирового состояния.
- **social-service (8084):** NPC, расписания, социальные графы.
- **economy-service (8085):** инфраструктура, ресурсы, нелегальные рынки.
- **gameplay-service (8083):** телеметрия игроков, квесты, боевые события.

Фронтенд: `world` отображает динамику города, `social` — NPC и связи, `economy` — торговые точки и цены, `gameplay` — квесты и активности.

---

## ER-схемы и таблицы

### `city_districts` (world-service)
| Поле | Тип | Описание |
| --- | --- | --- |
| `city_id` | UUID | Город |
| `district_id` | UUID | Район |
| `name` | text | Локализуемое название |
| `profile` | enum | residential, corporate, industrial, cultural, criminal, mixed |
| `metrics` | jsonb | Метрики (density, wealth, crime, tech, culture, faction) |
| `faction_dominance` | jsonb | Влияние фракций |
| `population_target` | int | Целевая плотность NPC |
| `energy_budget` | int | Энергобюджет |
| `area_sq_m` | int | Площадь |
| `version` | int | Версия состояния |
| `updated_at` | timestamptz | Последнее обновление |

### `infrastructure_instances` (economy-service)
| Поле | Тип | Описание |
| --- | --- | --- |
| `instance_id` | UUID | Объект |
| `district_id` | UUID | Район |
| `category` | enum | housing, transit, security, entertainment, medical, black_market, civic |
| `template_id` | UUID | Каталожный шаблон |
| `capacity` | int | Вместимость |
| `required_staff` | jsonb | Персонал по ролям |
| `energy_cost` | int | Энергопотребление |
| `open_hours` | jsonb | Графики работы |
| `risk_level` | enum | low, medium, high |
| `owner_faction` | UUID | Контролирующая фракция |
| `state` | enum | planned, active, degraded, offline |
| `version` | int | Версия объекта |

### `npc_profiles` (social-service)
| Поле | Тип | Описание |
| --- | --- | --- |
| `npc_id` | UUID | Уникальный NPC |
| `archetype_id` | UUID | Архетип |
| `rarity` | enum | common, uncommon, elite, legendary, unique |
| `district_id` | UUID | Базовый район |
| `home_instance_id` | UUID | Жилище |
| `work_instance_id` | UUID | Работа |
| `faction_id` | UUID | Фракция |
| `personality_traits` | jsonb | Черты личности |
| `relationships` | jsonb | Связи (friends, rivals, romance) |
| `language_pack` | jsonb | Поддерживаемые языки |
| `priority_score` | numeric | Приоритет симуляции |
| `status` | enum | active, inactive, story_locked |
| `version` | int | Версия профиля |

### `npc_schedules` (social-service)
| Поле | Тип | Описание |
| --- | --- | --- |
| `schedule_id` | UUID | Расписание |
| `npc_id` | UUID | NPC |
| `mode` | enum | normal_day, night_shift, event_mode, emergency |
| `fsm` | jsonb | Описание автомата |
| `slots` | jsonb | Слоты `{from, to, location, activity, transport}` |
| `valid_from` | timestamptz | Начало действия |
| `valid_to` | timestamptz | Окончание |
| `version` | int | Версия расписания |

### `world_events_bindings` (world-service)
| Поле | Тип | Описание |
| --- | --- | --- |
| `event_id` | UUID | Событие |
| `district_id` | UUID | Район |
| `demand_modifiers` | jsonb | Модификаторы спроса |
| `npc_modifiers` | jsonb | Коррекция квот |
| `duration` | int | Длительность (мин) |
| `severity` | enum | minor, major, critical |

### `player_impact_log` (gameplay-service)
| Поле | Тип | Описание |
| --- | --- | --- |
| `impact_id` | UUID | Событие влияния |
| `player_id` | UUID | Игрок |
| `impact_type` | enum | quest, combat, economy, social |
| `delta` | jsonb | Изменения метрик |
| `affected_districts` | uuid[] | Список районов |
| `timestamp` | timestamptz | Время события |
| `processed` | boolean | Обработано ли |

Все таблицы синхронизируются через CDC → Kafka, поддерживая версионность и идемпотентность.

---

## Событийная шина и API (черновик)

- **Topic:** `world.city.lifecycle.v1`
  - Key: `cityId`
  - Payload: `{ version, cityId, generatedAt, districts[], infrastructure[] }`
- **Topic:** `social.npc.schedule.v1`
  - Key: `npcId`
  - Payload: `{ npcId, scheduleVersion, mode, stateMachine, slots[] }`
- **Topic:** `economy.infrastructure.alerts`
  - Key: `districtId`
  - Payload: `{ objectId, loadFactor, forecastLoad, status }`
- **Topic:** `gameplay.player.impact`
  - Key: `impactId`
  - Payload: `{ playerId, factionDelta, questId, affectedDistricts[], severity }`

```json
// world.city.lifecycle.v1
{
  "version": 27,
  "cityId": "night-city",
  "generatedAt": "2025-11-07T19:55:00Z",
  "districts": [
    {
      "districtId": "watson",
      "profile": "industrial",
      "metrics": {"density": 0.72, "crime": 0.82},
      "infrastructureVersion": 14
    }
  ],
  "infrastructure": [
    {"instanceId": "infra-001", "category": "transit", "state": "active"}
  ]
}

// social.npc.schedule.v1
{
  "npcId": "npc-8f1c",
  "scheduleVersion": 5,
  "mode": "normal_day",
  "stateMachine": {
    "states": ["home", "transit", "work", "leisure"],
    "transitions": ["home->transit", "transit->work"]
  },
  "slots": [
    {"from": "06:00", "to": "08:00", "location": "home", "activity": "wake_up"},
    {"from": "08:00", "to": "08:45", "location": "metro-12", "activity": "commute", "transport": "metro"}
  ]
}
```

**REST (outline):**
- `POST /world/cities/{cityId}/recompute`
  - Request: `{ "scope": "district", "targets": ["watson"], "reason": "player_impact", "triggerId": "impact-123" }`
  - Response 202: `{ "jobId": "recompute-456", "eta": "PT3M" }`
- `GET /world/cities/{cityId}/snapshot`
  - Query: `include=metrics,infrastructure,npcOverview`
  - Response: агрегированное состояние, метрики живости, распределение ролей.
- `GET /social/npc/{npcId}`
  - Response: профиль, расписание, связи, текущий статус.
- `GET /economy/districts/{districtId}/infrastructure`
  - Query: `state=active,degraded`
  - Response: объекты с `loadFactor`, `forecastLoad`, SLA обслуживания.

---

## Baseline города (пакет 1)

### Night City / Watson
```json
{
  "cityId": "night-city",
  "districtId": "watson",
  "populationTarget": 800000,
  "profile": "industrial",
  "metrics": {
    "density": 0.72,
    "wealth": 0.35,
    "crime": 0.82,
    "tech": 0.65,
    "culture": 0.44,
    "faction": 0.70
  },
  "factions": {
    "maelstrom": 0.45,
    "tyger-claws": 0.20,
    "arasaka": 0.12,
    "ncpd": 0.05
  },
  "culturalNotes": ["постиндустриальные кварталы", "уличный техно", "черный рынок имплантов"],
  "keyEvents": ["black-market-weekend", "maelstrom-block-party"],
  "restrictedContent": ["корпоративные VIP-ивенты"]
}
```

### Night City / Westbrook
```json
{
  "cityId": "night-city",
  "districtId": "westbrook",
  "populationTarget": 300000,
  "profile": "corporate",
  "metrics": {
    "density": 0.58,
    "wealth": 0.92,
    "crime": 0.30,
    "tech": 0.88,
    "culture": 0.76,
    "faction": 0.85
  },
  "factions": {
    "arasaka": 0.45,
    "tyger-claws": 0.30,
    "kang-tao": 0.12,
    "city-elites": 0.08
  },
  "culturalNotes": ["роскошные небоскребы", "VIP-клубы", "техно-сады"],
  "keyEvents": ["neon-opera-night", "corporate-summit"],
  "restrictedContent": ["уличные протесты", "массовые криминальные митинги"]
}
```

### Tokyo / Shinjuku
```json
{
  "cityId": "tokyo",
  "districtId": "shinjuku",
  "populationTarget": 550000,
  "profile": "mixed",
  "metrics": {
    "density": 0.90,
    "wealth": 0.75,
    "crime": 0.40,
    "tech": 0.93,
    "culture": 0.88,
    "faction": 0.65
  },
  "factions": {
    "megacorp-syndicates": 0.30,
    "local-yakuza": 0.22,
    "nightlife-collective": 0.15,
    "metro-authority": 0.10
  },
  "culturalNotes": ["неоновые арки", "мультикультурный фуд-корт", "VR-театры"],
  "keyEvents": ["hanabi-skyline", "vr-kabuki-week"],
  "restrictedContent": ["гротескные хоррор-перформансы"]
}
```

### Berlin / Kreuzberg
```json
{
  "cityId": "berlin",
  "districtId": "kreuzberg",
  "populationTarget": 260000,
  "profile": "cultural",
  "metrics": {
    "density": 0.55,
    "wealth": 0.50,
    "crime": 0.45,
    "tech": 0.70,
    "culture": 0.94,
    "faction": 0.52
  },
  "factions": {
    "flux-kollektiv": 0.30,
    "urban-phantoms": 0.20,
    "eurodyne": 0.18,
    "stahlfist": 0.12
  },
  "culturalNotes": ["техно-бункеры", "арт-карнавалы", "политические форумы"],
  "keyEvents": ["berlin-sky-rave", "freedom-assembly"],
  "restrictedContent": ["корпоративные милитаристские парады"]
}
```

Файлы baseline сохраняются в `content-generation/baseline/{city}.json` и служат входом для world-service/social-service.

---

## Проверка лора

- **Watson** — соответствует `03-lore/locations/night-city/watson-detailed-2020-2093.md`: население 800k, доминирование Maelstrom и Kabuki Market.
- **Westbrook** — отражает `03-lore/locations/night-city/westbrook-detailed-2020-2093.md`: элитный район, контроль Tyger Claws и корпоратов.
- **Shinjuku** — согласован с `03-lore/locations/world-cities/tokyo-detailed-2020-2093.md`: деловой центр, Kabukicho, контроль Arasaka/якудза.
- **Kreuzberg** — выровнен с `03-lore/locations/world-cities/berlin-detailed-2020-2093.md`: автономные коммуны Flux Kollektiv, арт-протесты.

---

## План симуляций и мониторинга

1. **Суточная симуляция (24h):** три сценария (будни, выходной, глобальное событие); 5000 игроков-ботов; выход — тепловые карты плотности, отчёт по SLA.
2. **Нагрузочный стресс:** одновременные сценарии «corporate raid», «street protest», «weather storm»; контроль пропускной способности Kafka и latency REST.
3. **QA маршрутов:** визуализация 1000 NPC, автоматические проверки `routeLatency < 5 мин`, `collisionProbability < 0.02`.
4. **Мониторинг:** Grafana (живость, плотность, нагрузка инфраструктуры, очередь пересчётов); алерты `npcDensityDeviation > 0.2`, `queueLag > 120s`, `eventProcessingError > 0`.
5. **Трассировка:** trace-id формата `CITY-DISTRICT-NPC`, хранение логов 48 часов, архив в объектное хранилище.

---

## Метрики живости города

- Средняя плотность NPC по районам/времени суток (±15%).
- Коэффициент использования инфраструктуры (60–85%).
- Индекс разнообразия ролей (Shannon Index > 1.8).
- Доля динамичных NPC (≥25%).
- SLA реакции на события: <3 игровых минут (локальные), <15 (глобальные).

---

## Дальнейшая проработка

1. Оформить swagger-задачи для API-SWAGGER на основе ER-схем и REST-outline.
2. Финализировать baseline с лор-командой, подтвердить культурные ограничения.
3. Запустить 24h симуляции и стресс-тесты, собрать отчёты по метрикам.
4. Настроить интеграцию событийной шины и SLA пересчётов в прод pipeline.
5. Подготовить пакет для API Task Creator (описание эндпоинтов, зависимостей, входных данных).

---

## Связанные документы

- `.BRAIN/03-lore/locations/night-city/watson-detailed-2020-2093.md`
- `.BRAIN/03-lore/locations/night-city/westbrook-detailed-2020-2093.md`
- `.BRAIN/03-lore/locations/world-cities/tokyo-detailed-2020-2093.md`
- `.BRAIN/03-lore/locations/world-cities/berlin-detailed-2020-2093.md`
- `.BRAIN/02-gameplay/world/world-state/`
- `.BRAIN/05-technical/content-generation/npc-profile-generator/`
- `.BRAIN/05-technical/global-state/`
