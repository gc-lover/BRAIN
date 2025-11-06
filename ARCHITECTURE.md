# Архитектура директорий .BRAIN

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-06 23:16  
**api-readiness-notes:** Служебный файл, описание архитектуры репозитория, не предназначен для создания API

**Последнее обновление:** 2025-11-07 - Добавлены секции о микросервисной архитектуре бэкенда, модульной архитектуре фронтенда и библиотеке UI компонентов


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-176](../../../API-SWAGGER/tasks/active/queue/task-176-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: OTHER
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Предлагаемая структура

```
.BRAIN/
├── README.md                          # Описание репозитория
├── ARCHITECTURE.md                    # Этот документ - описание архитектуры
│
├── 01-concepts/                       # Базовые концепции и видение
│   ├── README.md                      # Обзор концепций
│   ├── vision.md                      # Видение проекта
│   ├── design-philosophy.md           # Философия дизайна
│   └── core-pillars.md                # Основные столпы игры
│
├── 02-gameplay/                       # Игровая механика
│   ├── README.md                      # Обзор игровых механик
│   ├── combat/                        # Боевая система
│   │   ├── README.md                  # Обзор боевой системы
│   │   ├── shooter-mechanics.md       # Механики шутера
│   │   ├── extraction-mechanics.md    # Механики экстрактшутера
│   │   ├── abilities/                 # Система способностей
│   │   │   ├── README.md              # Обзор способностей
│   │   │   ├── active-abilities.md    # Активные способности
│   │   │   ├── passive-abilities.md   # Пассивные способности
│   │   │   └── ultimate-abilities.md  # Ультимативные способности
│   │   └── implants/                  # Импланты и модификации
│   │       ├── README.md              # Обзор имплантов
│   │       ├── cyberware.md            # Кибервар
│   │       ├── modifications.md        # Модификации
│   │       └── enhancements.md         # Улучшения
│   ├── progression/                   # Прокачка и развитие
│   │   ├── README.md                  # Обзор прокачки
│   │   ├── skill-system/              # Система навыков
│   │   │   ├── README.md              # Обзор навыков
│   │   │   ├── combat-skills.md        # Боевые навыки
│   │   │   ├── tech-skills.md          # Технические навыки
│   │   │   └── social-skills.md        # Социальные навыки
│   │   ├── leveling/                  # Уровни и опыт
│   │   │   ├── README.md              # Обзор уровней
│   │   │   ├── character-levels.md     # Уровни персонажа
│   │   │   ├── skill-levels.md         # Уровни навыков
│   │   │   └── experience-sources.md   # Источники опыта
│   │   └── equipment/                 # Экипировка и заточка
│   │       ├── README.md              # Обзор экипировки
│   │       ├── weapons.md              # Оружие
│   │       ├── armor.md                # Броня
│   │       ├── accessories.md          # Аксессуары
│   │       └── enhancement.md          # Заточка и улучшение
│   ├── economy/                       # Экономика
│   │   ├── README.md                  # Обзор экономики
│   │   ├── trading/                   # Торговля
│   │   │   ├── README.md              # Обзор торговли
│   │   │   ├── markets.md              # Рынки
│   │   │   ├── contracts.md            # Контракты
│   │   │   └── auction-house.md         # Аукционный дом
│   │   ├── crafting/                  # Крафт
│   │   │   ├── README.md              # Обзор крафта
│   │   │   ├── item-crafting.md        # Крафт предметов
│   │   │   ├── modification-crafting.md # Крафт модификаций
│   │   │   └── recipes.md              # Рецепты
│   │   └── currency/                  # Валюты и ресурсы
│   │       ├── README.md              # Обзор валют
│   │       ├── currencies.md           # Валюты
│   │       └── resources.md            # Ресурсы
│   ├── social/                        # Социальные механики
│   │   ├── README.md                  # Обзор социальных механик
│   │   ├── guilds/                    # Кланы и гильдии
│   │   │   ├── README.md              # Обзор кланов
│   │   │   ├── guild-system.md         # Система кланов
│   │   │   ├── guild-wars.md          # Войны кланов
│   │   │   └── guild-features.md       # Функции кланов
│   │   ├── relationships/             # Отношения с NPC
│   │   │   ├── README.md              # Обзор отношений
│   │   │   ├── npc-relationships.md    # Отношения с NPC
│   │   │   ├── reputation-system.md    # Система репутации
│   │   │   └── romances.md             # Романтические отношения
│   │   └── pvp/                       # PvP механики
│   │       ├── README.md              # Обзор PvP
│   │       ├── arenas.md              # Арены
│   │       ├── battlegrounds.md        # Поля боя
│   │       └── tournaments.md          # Турниры
│   └── world/                         # Игровой мир
│       ├── README.md                  # Обзор игрового мира
│       ├── events/                    # Мировые события
│       │   ├── README.md              # Обзор событий
│       │   ├── dynamic-events.md       # Динамические события
│       │   ├── global-events.md       # Глобальные события
│       │   └── faction-events.md      # События фракций
│       ├── raids/                     # Рейды
│       │   ├── README.md              # Обзор рейдов
│       │   ├── raid-mechanics.md       # Механики рейдов
│       │   └── raid-instances.md       # Инстансы рейдов
│       └── building/                  # Строительство
│           ├── README.md              # Обзор строительства
│           ├── base-building.md        # Строительство базы
│           └── territory-building.md   # Строительство территории
│
├── 03-lore/                           # Лор и сеттинг
│   ├── README.md                      # Обзор лора
│   ├── universe/                      # Вселенная CYBERPUNK
│   │   ├── README.md                  # Обзор вселенной
│   │   ├── world-building.md           # Построение мира
│   │   ├── history.md                  # История
│   │   └── timeline.md                 # Хронология
│   ├── factions/                      # Фракции
│   │   ├── README.md                  # Обзор фракций
│   │   ├── corporations/              # Корпорации
│   │   │   ├── README.md              # Обзор корпораций
│   │   │   ├── megacorps.md            # Мегакорпорации
│   │   │   └── corporations-list.md    # Список корпораций
│   │   ├── gangs/                     # Банды
│   │   │   ├── README.md              # Обзор банд
│   │   │   └── gangs-list.md          # Список банд
│   │   └── organizations/             # Организации
│   │       ├── README.md              # Обзор организаций
│   │       └── organizations-list.md   # Список организаций
│   ├── locations/                     # Локации
│   │   ├── README.md                  # Обзор локаций
│   │   ├── cities/                    # Города
│   │   │   ├── README.md              # Обзор городов
│   │   │   └── cities-list.md         # Список городов
│   │   └── zones/                     # Зоны и районы
│   │       ├── README.md              # Обзор зон
│   │       └── zones-list.md          # Список зон
│   └── characters/                    # Персонажи
│       ├── README.md                  # Обзор персонажей
│       ├── npcs/                      # NPC
│       │   ├── README.md              # Обзор NPC
│       │   ├── important-npcs.md       # Важные NPC
│       │   └── npcs-list.md            # Список NPC
│       └── protagonists/              # Протагонисты
│           ├── README.md              # Обзор протагонистов
│           └── character-creation.md   # Создание персонажа
│
├── 04-narrative/                      # Повествование и литературная часть
│   ├── README.md                      # Обзор повествования
│   ├── quest-system.md                # Система квестов (общая механика)
│   ├── scenarios/                     # Сценарии
│   │   ├── README.md                  # Обзор сценариев
│   │   ├── game-start/                # Сценарии начала игры
│   │   ├── events/                     # Сценарии событий
│   │   ├── interactions/              # Сценарии взаимодействий
│   │   └── branching/                  # Сценарии ветвления
│   ├── quests/                        # Квесты
│   │   ├── README.md                  # Обзор квестов
│   │   ├── main/                       # Основные квесты
│   │   ├── side/                       # Побочные квесты
│   │   ├── faction/                    # Квесты фракций
│   │   ├── event/                      # Квесты событий
│   │   └── player/                     # Квесты игроков
│   ├── lore/                           # Лор игры
│   │   ├── README.md                  # Обзор лора
│   │   ├── universe/                   # История вселенной
│   │   ├── cities/                     # История городов
│   │   ├── factions/                    # История фракций
│   │   ├── events/                     # История событий
│   │   └── mythology/                  # Мифология и легенды
│   ├── npc-lore/                       # Лор NPC
│   │   ├── README.md                  # Обзор лора NPC
│   │   ├── NPC-TEMPLATE.md            # Шаблон для создания NPC
│   │   ├── era-index.md               # Индекс NPC по эпохам (ссылки на таймлайн)
│   │   ├── important-npcs-list.md     # Список важных NPC
│   │   ├── important/                  # Важные NPC
│   │   │   ├── marco-fix-sanchez.md    # Марко "Фикс" Санчес
│   │   │   ├── jose-tiger-ramirez.md   # Хосе "Тигр" Рамирес
│   │   │   └── [другие важные NPC]     # Другие важные NPC (отдельные файлы)
│   │   └── common/                     # Второстепенные NPC
│   │       ├── README.md               # Обзор второстепенных NPC
│   │       ├── traders/                # Торговцы
│   │       │   └── [торговцы.md]       # Торговцы (отдельные файлы)
│   │       ├── citizens/               # Обычные горожане
│   │       │   └── [горожане.md]       # Горожане (отдельные файлы)
│   │       ├── enemies/                # Враги и бандиты
│   │       │   └── [враги.md]          # Враги (отдельные файлы)
│   │       └── service/                # Служебные NPC
│   │           └── [служебные.md]     # Служебные NPC (отдельные файлы)
│   ├── events-lore/                    # Лор событий
│   │   ├── README.md                  # Обзор лора событий
│   │   ├── world/                      # Мировые события
│   │   ├── faction/                    # События фракций
│   │   ├── location/                    # События локаций
│   │   └── dynamic/                     # Динамические события
│   ├── stories/                        # Истории и повествования
│   │   ├── README.md                  # Обзор историй
│   │   ├── characters/                 # Истории персонажей
│   │   ├── factions/                    # Истории фракций
│   │   ├── locations/                   # Истории локаций
│   │   ├── short/                       # Короткие рассказы
│   │   └── epic/                        # Эпические истории
│   └── dialogues/                      # Диалоги
│       ├── README.md                  # Обзор диалогов
│       ├── npc/                        # Диалоги NPC
│       ├── quest/                       # Диалоги квестов
│       ├── event/                       # Диалоги событий
│       ├── branching/                   # Ветвление диалогов
│       └── romance/                     # Романтические диалоги
│
├── 05-technical/                      # Технические задания
│   ├── README.md                      # Обзор технических заданий
│   ├── api-requirements/              # Требования к API
│   │   ├── README.md                  # Обзор требований к API
│   │   ├── endpoints/                 # Endpoints
│   │   │   ├── README.md              # Обзор endpoints
│   │   │   ├── authentication.md       # Аутентификация
│   │   │   ├── game-mechanics.md       # Игровые механики
│   │   │   └── social-features.md     # Социальные функции
│   │   └── data-models/               # Модели данных
│   │       ├── README.md              # Обзор моделей данных
│   │       ├── entities.md             # Сущности
│   │       └── value-objects.md        # Объекты значений
│   ├── database/                      # База данных
│   │   ├── README.md                  # Обзор БД
│   │   ├── schema/                    # Схема БД
│   │   │   ├── README.md              # Обзор схемы
│   │   │   └── tables.md              # Таблицы
│   │   └── migrations/                 # Миграции
│   │       ├── README.md              # Обзор миграций
│   │       └── migration-history.md    # История миграций
│   └── architecture/                  # Архитектура
│       ├── README.md                  # Обзор архитектуры
│       ├── backend/                   # Архитектура бекенда
│       │   ├── README.md              # Обзор бекенда
│       │   ├── services.md            # Сервисы
│       │   ├── repositories.md         # Репозитории
│       │   └── middleware.md          # Middleware
│       └── frontend/                  # Архитектура фронтенда
│           ├── README.md              # Обзор фронтенда
│           ├── components.md          # Компоненты
│           ├── state-management.md    # Управление состоянием
│           └── routing.md            # Роутинг
│
├── 06-tasks/                          # Задания для AI агентов
│   ├── README.md                      # Обзор заданий
│   ├── active/                        # Активные задания
│   │   └── TODO.md                    # Список задач
│   ├── completed/                    # Выполненные задания
│   ├── archive/                       # Архив завершенных работ (управляется КЛИР)
│   │   ├── README.md                  # Описание архива
│   │   ├── INDEX.md                   # Индекс архива
│   │   ├── completed-features/        # Отчеты о фичах (400-500 строк)
│   │   │   ├── YYYY-MM/               # Группировка по месяцам
│   │   │   │   ├── feature-reports-001.md  # Отчеты часть 1
│   │   │   │   ├── feature-reports-002.md  # Отчеты часть 2
│   │   │   │   └── README.md          # Индекс месяца
│   │   │   └── README.md              # Описание структуры
│   │   ├── completed-trackers/        # Архив трекеров
│   │   │   ├── implementation-tracker/
│   │   │   ├── brain-mapping/
│   │   │   ├── readiness-tracker/
│   │   │   └── README.md
│   │   ├── statistics/                # Статистика
│   │   │   ├── monthly/               # Помесячная
│   │   │   ├── overall-stats.md       # Общая
│   │   │   └── README.md
│   │   ├── completed-todos/           # Архив TODO
│   │   └── resolved-questions/        # Архив вопросов
│   ├── config/                        # Конфигурация и трекеры
│   │   ├── readiness-tracker.yaml    # Трекер готовности документов (очищается КЛИР)
│   │   ├── implementation-tracker.yaml # Трекер реализации backend/frontend (очищается КЛИР)
│   │   ├── STATUSES-GUIDE.md         # Справочник систем статусов
│   │   ├── WORKFLOW-DETAILS.md       # Детали воркфлоу агентов
│   │   └── TEMPLATES-GUIDE.md        # Справочник шаблонов
│   ├── ideas/                         # Идеи проекта
│   │   └── IDEA-TEMPLATE.md          # Шаблон идеи
│   └── templates/                     # Шаблоны заданий
│
├── 07-research/                       # Исследования и анализ
│   ├── README.md                      # Обзор исследований
│   ├── inspiration/                   # Анализ источников вдохновения
│   │   ├── README.md                  # Обзор источников вдохновения
│   │   ├── games-analysis/            # Анализ игр
│   │   │   ├── README.md              # Обзор анализа игр
│   │   │   ├── baldur-gate-3.md       # BALDUR GATE 3
│   │   │   ├── cyberpunk-2077.md      # CYBERPUNK 2077
│   │   │   ├── valorant.md            # VALORANT
│   │   │   ├── tarkov.md              # TARKOV
│   │   │   └── ...                    # Другие игры
│   │   └── features-comparison/       # Сравнение фич
│   │       ├── README.md              # Обзор сравнений
│   │       └── feature-matrix.md      # Матрица сравнения
│   └── market/                        # Рыночный анализ
│       ├── README.md                  # Обзор рынка
│       ├── competitors/               # Анализ конкурентов
│       │   ├── README.md              # Обзор конкурентов
│       │   └── competitors-list.md    # Список конкурентов
│       └── market-trends.md          # Рыночные тренды
│
├── 08-references/                     # Справочные материалы
│   ├── README.md                      # Обзор справочников
│   ├── glossary.md                    # Глоссарий терминов
│   ├── abbreviations.md               # Сокращения
│   └── links.md                       # Полезные ссылки
│
└── 09-reports/                        # Отчеты и summaries
    ├── README.md                      # Обзор отчетов
    ├── session-reports/               # Отчеты по рабочим сессиям
    │   ├── README.md                  # Обзор session reports
    │   └── YYYY-MM-DD/                # Отчеты за конкретную дату
    │       ├── SESSION-SUMMARY-*.md    # Краткая сводка
    │       ├── MEGA-SESSION-SUMMARY-*.md # Расширенная сводка
    │       ├── ULTIMATE-SESSION-SUMMARY-*.md # Полная сводка
    │       ├── FINAL-SESSION-REPORT-*.md # Финальный отчет
    │       ├── BRAIN-READINESS-FINAL-REPORT-*.md # Отчет о готовности
    │       └── README.md               # Описание отчетов дня
    └── next-steps/                     # Планы на будущее
        ├── README.md                   # Обзор планов
        └── NEXT-STEPS.md               # Текущий план действий
```

## Принципы организации

### 1. Нумерация директорий
- Директории пронумерованы для логического порядка обработки
- От концепций к реализации

**Директории верхнего уровня:**
- `01-concepts/` - Базовые концепции и видение проекта
- `02-gameplay/` - Игровые механики (боевая система, прогрессия, экономика, социальные механики)
- `03-lore/` - Лор и сеттинг (вселенная, фракции, локации, персонажи)
- `04-narrative/` - Повествование (квесты, диалоги, сценарии, лор NPC)
- `05-technical/` - Технические задания (API, БД, архитектура)
- `06-tasks/` - Задачи и управление проектом (TODO, идеи, текущая работа)
- `07-research/` - Исследования и анализ (источники вдохновения, рынок)
- `08-references/` - Справочные материалы (глоссарий, сокращения, ссылки)
- `09-reports/` - Отчеты и summaries (session reports, планы)

### 2. Иерархическая структура
- От общего к частному
- Каждая категория имеет README.md с обзором
- Детализация в подкаталогах

### 3. Версионирование
- Каждый документ имеет статус и версию в метаданных
- История изменений в Git

### 4. Связи между документами
- Использование ссылок Markdown
- Упоминание связанных документов
- Связи с API-SWAGGER через упоминания

### 5. Статусы документов
- `draft` - черновик
- `review` - на проверке
- `approved` - утвержден
- `deprecated` - устарел

### 6. Шаблоны документов

**ОБЯЗАТЕЛЬНОЕ правило:** Перед массовым созданием однотипных документов (3+) необходимо создать шаблон.

**Где хранятся шаблоны:**
1. **В этом файле** (ARCHITECTURE.md) - основное хранилище с описанием всех шаблонов
2. **В соответствующих директориях** - файлы `[ТИП]-TEMPLATE.md`

**Существующие шаблоны:**
- **IDEA-TEMPLATE.md** (`.BRAIN/06-tasks/ideas/IDEA-TEMPLATE.md`) - шаблон для идей
- **NPC-TEMPLATE.md** (`.BRAIN/04-narrative/npc-lore/NPC-TEMPLATE.md`) - шаблон для описания NPC

**Планируемые шаблоны:**
- QUEST-TEMPLATE.md - для квестов (в разработке)
- LOCATION-TEMPLATE.md - для локаций (в разработке)
- FACTION-TEMPLATE.md - для фракций (в разработке)

**Подробнее о шаблонах:** См. [TEMPLATES-GUIDE.md](./06-tasks/config/TEMPLATES-GUIDE.md)

### 7. Системы отслеживания

**В проекте используется 3 системы отслеживания:**

1. **readiness-tracker.yaml** (`06-tasks/config/`) - готовность документов к созданию API (очищается КЛИР)
2. **brain-mapping.yaml** (`API-SWAGGER/tasks/config/`) - связи .BRAIN → задания API (очищается КЛИР)
3. **implementation-tracker.yaml** (`06-tasks/config/`) - статусы реализации backend/frontend (очищается КЛИР)

**Подробнее:** См. [STATUSES-GUIDE.md](./06-tasks/config/STATUSES-GUIDE.md)

### 8. Архивация завершенных работ

**Управляется агентом:** Clear Agent (КЛИР)

**Директория:** `06-tasks/archive/`

**Что архивируется:**
- Завершенные фичи (отчеты разбиты по 400-500 строк)
- Записи из трекеров (группировка по месяцам)
- Выполненные задачи из TODO.md
- Решенные вопросы из open-questions.md

**Структура архива:**
- `completed-features/YYYY-MM/` - отчеты о фичах
- `completed-trackers/[tracker-name]/YYYY-MM.yaml` - архивы трекеров
- `statistics/` - статистика и отчеты
- `INDEX.md` - общий индекс для поиска

**Подробнее:** См. [КЛИР.MD](./КЛИР.MD)

## Формат документов

### Шаблон документа

```markdown
# Название документа

**Статус:** draft | review | approved | deprecated  
**Версия:** 1.0.0  
**Дата создания:** YYYY-MM-DD  
**Последнее обновление:** YYYY-MM-DD  
**Приоритет:** низкий | средний | высокий | критический

**api-readiness:** ready | needs-work | blocked | in-review | not-applicable  
**api-readiness-check-date:** YYYY-MM-DD HH:MM  
**api-readiness-notes:** Заметки о готовности/проблемах (опционально)

---

## Описание

Краткое описание документа.

## Содержание

1. Раздел 1
2. Раздел 2

## Детали

Подробное описание...

## Связанные документы

- [Название документа](./path/to/doc.md)
- API: [Название API](./path/to/api.md)

## История изменений

- v1.0.0 (YYYY-MM-DD) - Создание документа
```

## Рабочий процесс

1. **Идея** → Создается в соответствующей категории как `draft`
2. **Проработка** → Документ развивается и детализируется
3. **Review** → Статус меняется на `review`
4. **Утверждение** → После проверки статус `approved`
5. **API Design** → На основе утвержденных концепций создаются API спецификации
6. **Реализация** → Технические задания для реализации

## Интеграция с API-SWAGGER

- Технические документы ссылаются на соответствующие API спецификации
- Используется формат: `API-SWAGGER: [название API]`
- Обратная связь - API спецификации ссылаются на исходные концепции

