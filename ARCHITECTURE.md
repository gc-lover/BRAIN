# Архитектура директорий .BRAIN

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
├── 04-narrative/                      # Повествование и квесты
│   ├── README.md                      # Обзор повествования
│   ├── quest-system/                  # Система квестов
│   │   ├── README.md                  # Обзор квестов
│   │   ├── main-quests.md             # Основные квесты
│   │   ├── side-quests.md             # Побочные квесты
│   │   ├── daily-quests.md            # Ежедневные квесты
│   │   └── quest-mechanics.md         # Механики квестов
│   ├── branching-stories/             # Ветвление сюжета
│   │   ├── README.md                  # Обзор ветвления
│   │   ├── choice-consequences.md      # Последствия выбора
│   │   └── story-branches.md          # Ветви сюжета
│   ├── dialogues/                     # Диалоги
│   │   ├── README.md                  # Обзор диалогов
│   │   ├── dialogue-system.md          # Система диалогов
│   │   └── dialogue-examples.md        # Примеры диалогов
│   └── romances/                      # Романтические линии
│       ├── README.md                  # Обзор романтических линий
│       └── romance-options.md          # Варианты романтики
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
└── 08-references/                     # Справочные материалы
    ├── README.md                      # Обзор справочников
    ├── glossary.md                    # Глоссарий терминов
    ├── abbreviations.md               # Сокращения
    └── links.md                       # Полезные ссылки
```

## Принципы организации

### 1. Нумерация директорий
- Директории пронумерованы для логического порядка обработки
- От концепций к реализации

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

## Формат документов

### Шаблон документа

```markdown
# Название документа

**Статус:** draft | review | approved | deprecated  
**Версия:** 1.0.0  
**Дата создания:** YYYY-MM-DD  
**Последнее обновление:** YYYY-MM-DD  
**Приоритет:** низкий | средний | высокий | критический

---
**API Tasks Status:**
- Status: not_created | created | in_progress | completed
- Tasks: 
  - API-TASK-XXX: api/v1/path/to/file.yaml (YYYY-MM-DD)
- Last Updated: YYYY-MM-DD
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

