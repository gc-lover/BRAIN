# Справочник систем статусов проекта NECPGAME

**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06  
**Версия:** 1.0.0

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-06 22:42  
**api-readiness-notes:** Служебный справочный документ, описывает системы статусов для агентов, не предназначен для создания API

---

## Краткое описание

В проекте NECPGAME используется **4 системы статусов** для отслеживания процесса разработки от идеи до реализации.

Этот документ объясняет все системы статусов, кто их обновляет, когда и зачем.

---

## Обзор систем статусов

| Система | Где используется | Кто обновляет | Назначение |
|---------|-----------------|---------------|------------|
| **Document Status** | Метаданные документов .BRAIN | МЕНЕДЖЕР | Статус проработки документа |
| **API Readiness** | Метаданные документов .BRAIN, readiness-tracker.yaml | МЕНЕДЖЕР, Brain Readiness Checker | Готовность к созданию API |
| **Task Status** | brain-mapping.yaml | ДУАПИТАСК, АПИТАСК | Статус задания API |
| **Implementation Status** | implementation-tracker.yaml | АПИТАСК, БЭКТАСК, ФРОНТТАСК | Статус реализации backend/frontend |

---

## Система 1: Document Status

### Описание

Статус проработки документа в .BRAIN. Показывает, насколько документ завершён и проверен.

### Где используется

В метаданных документов .BRAIN (в начале файла):

```markdown
**Статус:** draft | review | approved | deprecated
```

### Кто обновляет

**МЕНЕДЖЕР** (Brain Manager Agent)

### Статусы

| Статус | Описание | Когда используется |
|--------|----------|-------------------|
| `draft` | Черновик | Документ создан, но не завершён. Идёт проработка деталей. |
| `review` | На проверке | Документ завершён и готов к проверке. Проверяется на полноту и корректность. |
| `approved` | Утверждён | Документ проверен и утверждён. Готов к использованию. |
| `deprecated` | Устарел | Документ больше не актуален. Заменён новой версией или не используется. |

### Переходы между статусами

```
draft → review → approved
                    ↓
                deprecated
```

### Примеры

**Пример 1: Новый документ**
```markdown
**Статус:** draft
**Версия:** 1.0.0
```

**Пример 2: Документ на проверке**
```markdown
**Статус:** review
**Версия:** 1.0.0
```

**Пример 3: Утверждённый документ**
```markdown
**Статус:** approved
**Версия:** 1.1.0
```

---

## Система 2: API Readiness

### Описание

Готовность документа .BRAIN к созданию задачи для API-SWAGGER. Показывает, достаточно ли деталей для создания API спецификации.

### Где используется

1. **В метаданных документов .BRAIN** (в начале файла):
```markdown
**api-readiness:** ready | needs-work | blocked | in-review | not-applicable
**api-readiness-check-date:** YYYY-MM-DD HH:MM
**api-readiness-notes:** Заметки о статусе/проблемах
```

2. **В readiness-tracker.yaml:**
```yaml
documents:
  - path: ".BRAIN/02-gameplay/combat/shooter-mechanics.md"
    status: "ready"
    checked: "2025-11-06 20:00"
    checker: "Brain Readiness Checker"
    notes: "Готов к созданию API задачи"
```

### Кто обновляет

1. **МЕНЕДЖЕР** - первичная оценка в метаданных документа
2. **Brain Readiness Checker** - детальная проверка, обновляет метаданные и readiness-tracker.yaml

### Статусы

| Статус | Описание | Когда используется | Действия |
|--------|----------|-------------------|----------|
| `ready` | Готов к созданию API задачи | Документ содержит все необходимые детали для API. Статус: approved/review, нет блокирующих TODO, достаточно конкретики. | Можно создавать задачу через ДУАПИТАСК |
| `needs-work` | Требуется доработка | Недостаточно деталей, есть блокирующие TODO, слишком общий. | Доработать документ по списку issues |
| `blocked` | Заблокирован зависимостями | Зависит от незавершенных документов. Невозможно создать API без завершения зависимостей. | Завершить зависимости, затем перепроверить |
| `in-review` | Проверяется на готовность | Документ проверяется в данный момент. | Дождаться завершения проверки |
| `not-applicable` | Не предназначен для API | Концептуальный документ без механик. Служебный/справочный документ. | Не создавать API задачи |

### Переходы между статусами

```
draft (документ) → in-review → ready → task-created (в ДУАПИТАСК)
                              ↓
                         needs-work → (доработка) → in-review
                              ↓
                          blocked → (разблокировка) → in-review

review/approved (документ) → ready → task-created
```

### Критерии готовности (для статуса `ready`)

Документ считается готовым, если:

1. ✅ **Статус документа:** approved или review (не draft)
2. ✅ **Полнота информации:** достаточно деталей для создания API спецификации
3. ✅ **Отсутствие блокирующих TODO:** нет критичных TODO, которые блокируют создание API
4. ✅ **Конкретность:** документ содержит конкретные механики/концепции (не слишком общий)
5. ✅ **Структурированность:** документ понятен и логичен
6. ✅ **Версионирование:** документ имеет версию
7. ✅ **Документация:** есть описание концепций, примеры (если применимо)

### Связь с Document Status

| Document Status | Возможные api-readiness | Примечания |
|----------------|------------------------|------------|
| `draft` | needs-work, in-review, not-applicable | Редко ready, только если очень детальный |
| `review` | in-review, ready, needs-work | Обычный путь к ready |
| `approved` | ready, not-applicable | Готовые документы |

### Примеры

**Пример 1: Готовый документ**
```markdown
**Статус:** approved
**Версия:** 1.1.0
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06 20:00
**api-readiness-notes:** Готов к созданию API задачи
```

**Пример 2: Нужна доработка**
```markdown
**Статус:** draft
**Версия:** 1.0.0
**api-readiness:** needs-work
**api-readiness-check-date:** 2025-11-06 20:00
**api-readiness-notes:** Блокирующий TODO: "Список конкретных корпораций будет проработан позже"
```

**Пример 3: Не применимо**
```markdown
**Статус:** approved
**Версия:** 1.0.0
**api-readiness:** not-applicable
**api-readiness-check-date:** 2025-11-06 20:00
**api-readiness-notes:** Концептуальный документ без механик, не предназначен для создания API
```

---

## Система 3: Task Status

### Описание

Статус задания для создания API спецификации. Отслеживает, на каком этапе находится задание от создания до выполнения.

### Где используется

**В brain-mapping.yaml:**
```yaml
mappings:
  - source: ".BRAIN/02-gameplay/combat/shooter-mechanics.md"
    target: "api/v1/gameplay/combat/shooter-mechanics.yaml"
    task_id: "API-TASK-037"
    task_file: "tasks/active/queue/task-037-shooter-mechanics-api.md"
    status: "queued"
    created: "2025-11-06 15:00"
    updated: "2025-11-06 15:00"
```

### Кто обновляет

1. **ДУАПИТАСК (API Task Creator)** - создаёт запись (status: queued)
2. **АПИТАСК (API Executor)** - обновляет статус (in_progress → completed)

### Статусы

| Статус | Описание | Когда используется | Кто устанавливает |
|--------|----------|-------------------|-------------------|
| `queued` | Задание в очереди | Задание создано и ждёт выполнения в tasks/active/queue/ | ДУАПИТАСК |
| `assigned` | Задание назначено | Задание назначено конкретному агенту (опционально) | АПИТАСК (опционально) |
| `in_progress` | Задание в работе | API спецификация создаётся в данный момент | АПИТАСК (опционально) |
| `completed` | Задание завершено | API спецификация создана и сохранена | АПИТАСК |
| `failed` | Задание провалилось | Не удалось создать API спецификацию | АПИТАСК |

### Переходы между статусов

```
queued → assigned → in_progress → completed
                                 ↓
                              failed
```

Или упрощённо:
```
queued → in_progress → completed
                     ↓
                  failed
```

### Примеры

**Пример 1: Задание в очереди**
```yaml
- source: ".BRAIN/02-gameplay/combat/shooter-mechanics.md"
  task_id: "API-TASK-037"
  status: "queued"
  created: "2025-11-06 15:00"
```

**Пример 2: Задание завершено**
```yaml
- source: ".BRAIN/02-gameplay/combat/shooter-mechanics.md"
  target: "api/v1/gameplay/combat/shooter-mechanics.yaml"
  task_id: "API-TASK-037"
  status: "completed"
  created: "2025-11-06 15:00"
  updated: "2025-11-06 20:00"
  completed: "2025-11-06 20:00"
```

---

## Система 4: Implementation Status

### Описание

Статус реализации backend и frontend для каждого API. Отслеживает, реализован ли API на бекенде и фронтенде.

### Где используется

**В implementation-tracker.yaml:**
```yaml
implementations:
  - api_path: "api/v1/auth/character-creation.yaml"
    task_id: "API-TASK-026"
    api_status: "completed"
    backend:
      status: "completed"
      started: "2025-11-07 10:00"
      completed: "2025-11-07 15:00"
      agent: "Backend Agent"
      commit: "abc123def"
      notes: ""
    frontend:
      status: "completed"
      started: "2025-11-07 16:00"
      completed: "2025-11-07 20:00"
      agent: "Frontend Agent"
      commit: "def456ghi"
      notes: ""
```

### Кто обновляет

1. **АПИТАСК** - создаёт запись после создания API (api_status: completed, backend/frontend: not_started)
2. **БЭКТАСК** - обновляет backend.status (in_progress → completed)
3. **ФРОНТТАСК** - обновляет frontend.status (in_progress → completed)

### Статусы

| Статус | Описание | Когда используется | Кто устанавливает |
|--------|----------|-------------------|-------------------|
| `not_started` | Реализация ещё не начата | API создан, но реализация не начата | АПИТАСК |
| `in_progress` | Реализация в процессе | Backend/Frontend создаётся в данный момент | БЭКТАСК/ФРОНТТАСК |
| `completed` | Реализация завершена | Backend/Frontend реализован и протестирован | БЭКТАСК/ФРОНТТАСК |
| `failed` | Реализация провалилась | Не удалось реализовать (см. notes) | БЭКТАСК/ФРОНТТАСК |

### Переходы между статусов

**Backend:**
```
not_started → in_progress → completed
                          ↓
                       failed
```

**Frontend:**
```
not_started → in_progress → completed
                          ↓
                       failed
```

**⚠️ ВАЖНО:** Frontend начинается **только после** backend.status: completed

### Полный жизненный цикл

```
[АПИТАСК создаёт запись]
api_status: completed
backend.status: not_started
frontend.status: not_started
    ↓
[БЭКТАСК начинает работу]
backend.status: in_progress
    ↓
[БЭКТАСК завершает работу]
backend.status: completed
    ↓
[ФРОНТТАСК начинает работу] ← Только после backend: completed!
frontend.status: in_progress
    ↓
[ФРОНТТАСК завершает работу]
frontend.status: completed
    ↓
✅ ГОТОВАЯ ФИЧА
```

### Примеры

**Пример 1: API создан, реализация не начата**
```yaml
- api_path: "api/v1/gameplay/combat/shooter.yaml"
  task_id: "API-TASK-037"
  api_status: "completed"
  backend:
    status: "not_started"
  frontend:
    status: "not_started"
```

**Пример 2: Backend в процессе**
```yaml
- api_path: "api/v1/gameplay/combat/shooter.yaml"
  task_id: "API-TASK-037"
  api_status: "completed"
  backend:
    status: "in_progress"
    started: "2025-11-07 10:00"
    agent: "Backend Agent"
  frontend:
    status: "not_started"
```

**Пример 3: Backend завершён, frontend в процессе**
```yaml
- api_path: "api/v1/gameplay/combat/shooter.yaml"
  task_id: "API-TASK-037"
  api_status: "completed"
  backend:
    status: "completed"
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"
    agent: "Backend Agent"
    commit: "abc123def"
  frontend:
    status: "in_progress"
    started: "2025-11-07 16:00"
    agent: "Frontend Agent"
```

**Пример 4: Полностью завершено**
```yaml
- api_path: "api/v1/gameplay/combat/shooter.yaml"
  task_id: "API-TASK-037"
  api_status: "completed"
  backend:
    status: "completed"
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"
    agent: "Backend Agent"
    commit: "abc123def"
  frontend:
    status: "completed"
    started: "2025-11-07 16:00"
    completed: "2025-11-07 20:00"
    agent: "Frontend Agent"
    commit: "def456ghi"
```

---

## Таблица: Кто что обновляет

| Агент | Document Status | API Readiness | Task Status | Implementation Status |
|-------|----------------|---------------|-------------|----------------------|
| **МЕНЕДЖЕР** | ✅ Обновляет | ✅ Первичная оценка | ❌ | ❌ |
| **Brain Readiness Checker** | ❌ | ✅ Обновляет | ❌ | ❌ |
| **ДУАПИТАСК** | ❌ | ❌ | ✅ Создаёт (queued) | ❌ |
| **АПИТАСК** | ❌ | ❌ | ✅ Обновляет (completed) | ✅ Создаёт запись |
| **БЭКТАСК** | ❌ | ❌ | ❌ | ✅ Обновляет backend |
| **ФРОНТТАСК** | ❌ | ❌ | ❌ | ✅ Обновляет frontend |

---

## Примеры полного прохождения фичи

### Пример: Система стрельбы

**1. МЕНЕДЖЕР создаёт документ**
```markdown
Файл: .BRAIN/02-gameplay/combat/shooter-mechanics.md
Статус: draft → review → approved
api-readiness: needs-work → ready
```

**2. Brain Readiness Checker проверяет**
```yaml
# readiness-tracker.yaml
- path: ".BRAIN/02-gameplay/combat/shooter-mechanics.md"
  status: "ready"
  checked: "2025-11-06 20:00"
```

**3. ДУАПИТАСК создаёт задание**
```yaml
# brain-mapping.yaml
- source: ".BRAIN/02-gameplay/combat/shooter-mechanics.md"
  task_id: "API-TASK-037"
  status: "queued"
```

**4. АПИТАСК создаёт API**
```yaml
# brain-mapping.yaml
status: "completed"

# implementation-tracker.yaml (новая запись)
- api_path: "api/v1/gameplay/combat/shooter-mechanics.yaml"
  task_id: "API-TASK-037"
  api_status: "completed"
  backend:
    status: "not_started"
  frontend:
    status: "not_started"
```

**5. БЭКТАСК реализует backend**
```yaml
# implementation-tracker.yaml (обновление)
backend:
  status: "in_progress" → "completed"
  started: "2025-11-07 10:00"
  completed: "2025-11-07 15:00"
  commit: "abc123"
```

**6. ФРОНТТАСК реализует frontend**
```yaml
# implementation-tracker.yaml (обновление)
frontend:
  status: "in_progress" → "completed"
  started: "2025-11-07 16:00"
  completed: "2025-11-07 20:00"
  commit: "def456"
```

**Результат:** ✅ Готовая фича!

---

## Часто задаваемые вопросы

### 1. В чём разница между Document Status и API Readiness?

- **Document Status** - общий статус документа (draft/review/approved)
- **API Readiness** - готовность конкретно к созданию API (ready/needs-work/blocked)

Документ может быть approved, но api-readiness: needs-work (если не хватает деталей для API).

---

### 2. Когда документ готов к созданию API задачи?

Когда **api-readiness: ready**.

Это означает:
- Статус: approved или review
- Достаточно деталей для API
- Нет блокирующих TODO
- Документ конкретен и структурирован

---

### 3. Что делать, если backend.status: failed?

1. Проверь backend.notes - там описана проблема
2. Исправь проблему
3. Обнови backend.status обратно на in_progress
4. После исправления обнови на completed

---

### 4. Можно ли делать фронтенд параллельно с бекендом?

**Нет!** Фронтенд начинается **только после** backend.status: completed.

**Причина:** Фронтенд зависит от готового API для тестирования интеграции.

---

### 5. Как узнать, какие API готовы к реализации?

Проверь `implementation-tracker.yaml`:
- api_status: completed
- backend.status: not_started ← готов к реализации бекенда
- backend.status: completed + frontend.status: not_started ← готов к реализации фронтенда

---

### 6. Зачем нужно столько систем статусов?

Каждая система отслеживает свой этап:
1. **Document Status** - проработка документа
2. **API Readiness** - готовность к API
3. **Task Status** - создание API спецификации
4. **Implementation Status** - реализация backend/frontend

Вместе они дают полную картину процесса разработки от идеи до реализации.

---

## Ссылки на документы

### Основные документы
- **Воркфлоу проекта:** [DEVELOPMENT-WORKFLOW.md](../../../DEVELOPMENT-WORKFLOW.md)
- **Детали воркфлоу:** [WORKFLOW-DETAILS.md](./WORKFLOW-DETAILS.md)
- **Реестр агентов:** [AGENTS-REGISTRY.md](./AGENTS-REGISTRY.md)

### Системы отслеживания
- **readiness-tracker.yaml:** [readiness-tracker.yaml](./readiness-tracker.yaml)
- **brain-mapping.yaml:** [brain-mapping.yaml](../../../API-SWAGGER/tasks/config/brain-mapping.yaml)
- **implementation-tracker.yaml:** [implementation-tracker.yaml](./implementation-tracker.yaml)

### Документы агентов
- **МЕНЕДЖЕР:** [МЕНЕДЖЕР.MD](../../МЕНЕДЖЕР.MD)
- **Brain Readiness Checker:** [ЧЕКБРЕЙН.MD](./ЧЕКБРЕЙН.MD)
- **ДУАПИТАСК:** [ДУАПИТАСК.MD](../../../API-SWAGGER/ДУАПИТАСК.MD)
- **АПИТАСК:** [АПИТАСК.MD](../../../API-SWAGGER/АПИТАСК.MD)
- **БЭКТАСК:** [БЭКТАСК.MD](../../../BACK-GO/docs/БЭКТАСК.MD)
- **ФРОНТТАСК:** [ФРОНТТАСК.MD](../../../FRONT-WEB/ФРОНТТАСК.MD)

---

**Версия документа:** 1.0.0  
**Дата последнего обновления:** 2025-11-06

