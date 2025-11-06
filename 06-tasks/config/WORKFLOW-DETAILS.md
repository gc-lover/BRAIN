# Детальное описание воркфлоу проекта NECPGAME

**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06  
**Версия:** 1.0.0

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-06 22:42  
**api-readiness-notes:** Служебный справочный документ, описывает воркфлоу проекта для агентов, не предназначен для создания API

---

## Краткое описание

Этот документ содержит детальное описание каждого этапа воркфлоу разработки в проекте NECPGAME.

Для каждого агента описаны: входные данные, выходные данные, обязательные действия, чеклисты и примеры.

**См. также:** [DEVELOPMENT-WORKFLOW.md](../../../DEVELOPMENT-WORKFLOW.md) - визуальная диаграмма и обзор воркфлоу

---

## Этап 1: МЕНЕДЖЕР (Brain Manager Agent)

### Роль
Создание и управление документами с концепциями и механиками игры в репозитории .BRAIN

### Документ агента
[.BRAIN/МЕНЕДЖЕР.MD](../../МЕНЕДЖЕР.MD)

### Входные данные
- Идея или задача от пользователя
- Существующие документы .BRAIN (для контекста)
- TODO.md (список задач)
- CURRENT-WORK/* (текущая работа и статусы)
- open-questions.md (открытые вопросы)

### Обязательные действия

**При создании нового документа:**
1. Создать файл в соответствующей директории .BRAIN
2. Добавить метаданные:
   - Статус: draft
   - Версия: 1.0.0
   - Дата создания
   - Приоритет
3. Структурировать документ (описание, детали, примеры)
4. Определить первичную api-readiness (обычно needs-work)

**При проработке документа:**
1. Прорабатывать детали механик, правила, примеры
2. Обновлять статус: draft → review → approved
3. Обновлять api-readiness по мере проработки
4. Отвечать на открытые вопросы

**Перед массовым созданием однотипных документов:**
1. **ОБЯЗАТЕЛЬНО создать шаблон**
2. Сохранить шаблон в ARCHITECTURE.md
3. Использовать шаблон для всех однотипных документов

**При завершении работы:**
1. Проверить, что метаданные обновлены
2. Определить api-readiness
3. Обновить TODO.md (если нужно)
4. Обновить CURRENT-WORK/current-status.md (если нужно)
5. **Сделать коммит через autocommit**

### Выходные данные
- Документы .BRAIN со статусом draft/review/approved
- Документы с определённым api-readiness
- Обновлённый TODO.md (если применимо)
- Обновлённый CURRENT-WORK (если применимо)

### Системы отслеживания
**Обновляет:**
- Метаданные документов (status, api-readiness)
- TODO.md
- CURRENT-WORK/*

**Не обновляет:**
- readiness-tracker.yaml
- brain-mapping.yaml
- implementation-tracker.yaml

### Чеклист завершения

- [ ] Документ создан/обновлён
- [ ] Метаданные заполнены (статус, версия, дата, приоритет)
- [ ] api-readiness определён
- [ ] Документ структурирован и понятен
- [ ] Нет критичных TODO (или они документированы)
- [ ] TODO.md обновлён (если нужно)
- [ ] CURRENT-WORK обновлён (если нужно)
- [ ] Коммит сделан

### Следующий этап
Brain Readiness Checker (опционально) или ДУАПИТАСК (если api-readiness: ready)

### Примеры

**Пример 1: Создание нового документа**
```markdown
# Система романтических отношений

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Приоритет:** средний  
**api-readiness:** needs-work  
**api-readiness-notes:** Нужно проработать детали механики отношений
```

**Пример 2: Документ готов к API**
```markdown
# Система романтических отношений

**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 20:00  
**Приоритет:** средний  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 20:00  
**api-readiness-notes:** Готов к созданию API задачи
```

---

## Этап 2: Brain Readiness Checker (опционально)

### Роль
Проверка готовности документов .BRAIN к созданию API задач

### Документ агента
[.BRAIN/06-tasks/config/ЧЕКБРЕЙН.MD](./ЧЕКБРЕЙН.MD)

### Входные данные
- Документы .BRAIN (любые)
- readiness-check-guide.md (критерии готовности)
- readiness-tracker.yaml (предыдущие проверки)

### Обязательные действия

**При проверке документа:**
1. **Получить РЕАЛЬНОЕ время из системы** (Windows: `powershell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm'"`)
2. Применить критерии готовности из readiness-check-guide.md
3. Определить статус api-readiness (ready/needs-work/blocked/in-review/not-applicable)
4. Обновить метаданные документа:
   - api-readiness
   - api-readiness-check-date (РЕАЛЬНОЕ время!)
   - api-readiness-notes
5. Обновить readiness-tracker.yaml:
   - Добавить/обновить запись
   - Указать проблемы (issues) если есть
   - Использовать то же РЕАЛЬНОЕ время
6. Создать отчёт о готовности (если нужно)

**При массовой проверке:**
1. Сканировать все .md файлы в указанной директории
2. Игнорировать служебные файлы
3. Применять критерии ко всем документам
4. Обновлять метаданные документов и tracker
5. **Сделать коммит через autocommit**

### Выходные данные
- Обновлённые метаданные документов (api-readiness)
- Обновлённый readiness-tracker.yaml
- Отчёт о готовности документов (опционально)

### Системы отслеживания
**Обновляет:**
- Метаданные документов (api-readiness, api-readiness-check-date, api-readiness-notes)
- readiness-tracker.yaml

**Не обновляет:**
- brain-mapping.yaml
- implementation-tracker.yaml

### Чеклист завершения

- [ ] Все документы проверены по критериям
- [ ] РЕАЛЬНОЕ время получено из системы
- [ ] Метаданные документов обновлены
- [ ] readiness-tracker.yaml обновлён
- [ ] Отчёт создан (если нужно)
- [ ] Коммит сделан

### Следующий этап
ДУАПИТАСК (для документов с api-readiness: ready)

### Примеры

**Пример: Обновление метаданных документа**
```markdown
# До проверки
**api-readiness:** needs-work

# После проверки
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06 20:30
**api-readiness-notes:** Все критерии готовности выполнены
```

---

## Этап 3: ДУАПИТАСК (API Task Creator Agent)

### Роль
Создание заданий для API Executor из готовых документов .BRAIN

### Документ агента
[API-SWAGGER/ДУАПИТАСК.MD](../../../API-SWAGGER/ДУАПИТАСК.MD)

### Входные данные
- Документы .BRAIN с api-readiness: ready
- task-creation-guide.md (инструкция)
- api-generation-task-template.md (шаблон задания)
- checklist.md (чеклист проверки)
- brain-mapping.yaml (предыдущие задания)

### Обязательные действия

**При создании задания:**
1. Прочитать документ .BRAIN полностью
2. Извлечь всю информацию (механики, правила, зависимости)
3. Определить целевую структуру API
4. Создать полное самодостаточное задание по шаблону
5. Заполнить все секции (метаданные, источники, план, endpoints, модели, критерии, FAQ)
6. Проверить задание по чеклисту
7. Сохранить задание в tasks/active/queue/task-XXX-description.md
8. Обновить brain-mapping.yaml:
   - Добавить запись
   - status: queued
   - Указать связи (source, target, task_id)
9. Обновить документ .BRAIN:
   - Добавить секцию "API Tasks Status"
   - Указать task_id и статус
10. **Сделать коммит через autocommit**

**При создании нескольких заданий:**
1. Создать задания для каждого документа
2. Учесть зависимости между заданиями
3. Обновить brain-mapping.yaml для всех заданий
4. Обновить все документы .BRAIN
5. **Сделать коммит через autocommit**

### Выходные данные
- Задания в tasks/active/queue/task-XXX-description.md
- Обновлённый brain-mapping.yaml (status: queued)
- Обновлённые документы .BRAIN (секция API Tasks Status)

### Системы отслеживания
**Обновляет:**
- brain-mapping.yaml (создаёт запись с status: queued)
- Документы .BRAIN (добавляет секцию API Tasks Status)

**Не обновляет:**
- readiness-tracker.yaml
- implementation-tracker.yaml

### Чеклист завершения

- [ ] Документ .BRAIN прочитан полностью
- [ ] Задание создано по шаблону
- [ ] Все секции заполнены
- [ ] Задание прошло чеклист
- [ ] Задание сохранено в tasks/active/queue/
- [ ] brain-mapping.yaml обновлён
- [ ] Документ .BRAIN обновлён (секция API Tasks Status)
- [ ] Целевой путь API соответствует архитектуре
- [ ] Коммит сделан

### Следующий этап
АПИТАСК (читает задания из queue/)

### Примеры

**Пример: Запись в brain-mapping.yaml**
```yaml
- source: ".BRAIN/02-gameplay/social/romance-system.md"
  target: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  task_file: "tasks/active/queue/task-065-romance-system-api.md"
  status: "queued"
  created: "2025-11-06 20:00"
  version: "v1.1.0"
```

**Пример: Секция в документе .BRAIN**
```markdown
---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-065: api/v1/gameplay/social/romance-system.yaml (2025-11-06)
- Last Updated: 2025-11-06 20:00
---
```

---

## Этап 4: АПИТАСК (API Executor Agent)

### Роль
Создание OpenAPI спецификаций на основе заданий

### Документ агента
[API-SWAGGER/АПИТАСК.MD](../../../API-SWAGGER/АПИТАСК.MD)

### Входные данные
- Задание из tasks/active/queue/task-XXX-description.md
- api-swagger-rules.mdc (правила)
- Существующие API спецификации (для стиля)
- shared/common/* (общие компоненты)

### Обязательные действия

**При создании API спецификации:**
1. Прочитать задание полностью
2. Создать OpenAPI спецификацию:
   - Определить endpoints (методы, пути, параметры, ответы)
   - Создать модели данных (schemas)
   - Использовать общие компоненты из shared/common/
   - Использовать единую модель Error
   - Избегать конфликтов имён (GameCharacter вместо Character)
3. Соблюдать ограничение 400 строк на файл
4. Если больше 400 строк - разбить на несколько файлов
5. Проверить API по критериям приемки
6. Сохранить API в api/v1/.../file.yaml
7. Обновить brain-mapping.yaml:
   - status: completed
   - completed: дата и время
8. **ОБЯЗАТЕЛЬНО создать запись в implementation-tracker.yaml:**
   - api_path: путь к созданному API
   - task_id: ID задания
   - api_status: "completed"
   - backend.status: "not_started"
   - frontend.status: "not_started"
9. Переместить задание в tasks/completed/YYYY-MM-DD/
10. **Сделать коммит через autocommit**

### Выходные данные
- OpenAPI спецификация в api/v1/.../file.yaml
- README.md в директории (если несколько файлов)
- Обновлённый brain-mapping.yaml (status: completed)
- **Запись в implementation-tracker.yaml** (новая)
- Задание в tasks/completed/

### Системы отслеживания
**Обновляет:**
- brain-mapping.yaml (status: completed)
- **implementation-tracker.yaml (создаёт запись)** ⚠️ ОБЯЗАТЕЛЬНО!

**Не обновляет:**
- readiness-tracker.yaml

### Чеклист завершения

- [ ] Задание прочитано полностью
- [ ] API спецификация создана
- [ ] API валидна (OpenAPI 3.0.3)
- [ ] Используются общие компоненты из shared/common/
- [ ] Размер файла ≤ 400 строк (или разбито)
- [ ] README.md создан (если несколько файлов)
- [ ] Проверено по критериям приемки
- [ ] brain-mapping.yaml обновлён (status: completed)
- [ ] **implementation-tracker.yaml запись создана** ⚠️ ОБЯЗАТЕЛЬНО!
- [ ] Задание перемещено в completed/
- [ ] Коммит сделан

### Следующий этап
БЭКТАСК и ФРОНТТАСК (читают implementation-tracker.yaml)

### Примеры

**Пример: Запись в implementation-tracker.yaml (создаётся АПИТАСК)**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "not_started"
  frontend:
    status: "not_started"
```

**Пример: Обновление brain-mapping.yaml**
```yaml
- source: ".BRAIN/02-gameplay/social/romance-system.md"
  target: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  status: "completed"  # ← Обновлено
  completed: "2025-11-06 21:00"  # ← Добавлено
```

---

## Этап 5: БЭКТАСК (Backend Agent)

### Роль
Создание backend реализации на Java Spring Boot

### Документ агента
[BACK-GO/docs/БЭКТАСК.MD](../../../BACK-GO/docs/БЭКТАСК.MD)

### Входные данные
- OpenAPI спецификация из API-SWAGGER/api/v1/
- Запись в implementation-tracker.yaml (backend.status: not_started)
- MANUAL-TEMPLATES.md (шаблоны)

### Обязательные действия

**При НАЧАЛЕ работы (ОБЯЗАТЕЛЬНО):**
1. **Получить РЕАЛЬНОЕ время из системы**
2. Открыть implementation-tracker.yaml
3. Найти запись для API (по api_path)
4. Обновить:
   - backend.status: "in_progress"
   - backend.started: "YYYY-MM-DD HH:MM" (РЕАЛЬНОЕ время!)
   - backend.agent: "Backend Agent"
5. **Сделать коммит обновления tracker**

**Основная работа:**
6. Генерировать контракты из OpenAPI:
   - DTOs (модели данных)
   - API Interfaces (REST контракты со Spring MVC аннотациями)
   - Service Interfaces (контракты бизнес-логики)
7. Создать реализацию вручную:
   - Entities (JPA сущности с relationships)
   - Repositories (Spring Data с custom queries)
   - Controllers (реализуют API Interfaces)
   - ServiceImpl (реализуют Service Interfaces)
8. Создать Liquibase миграции для БД
9. Создать seed данные (с проверкой существования)
10. Протестировать API (curl/Postman)

**При ЗАВЕРШЕНИИ работы (ОБЯЗАТЕЛЬНО):**
11. **Получить РЕАЛЬНОЕ время из системы**
12. Открыть implementation-tracker.yaml
13. Обновить:
    - backend.status: "completed" (или "failed")
    - backend.completed: "YYYY-MM-DD HH:MM" (РЕАЛЬНОЕ время!)
    - backend.commit: "хэш коммита"
    - backend.notes: "примечания" (опционально)
14. **Сделать коммит через autocommit**

### Выходные данные
- Backend код в BACK-GO/src/main/java/
- Liquibase миграции в src/main/resources/db/changelog/
- Обновлённый implementation-tracker.yaml (backend.status: completed)
- Коммит в git

### Системы отслеживания
**Обновляет:**
- **implementation-tracker.yaml (backend поля)** ⚠️ ОБЯЗАТЕЛЬНО!

**Не обновляет:**
- readiness-tracker.yaml
- brain-mapping.yaml

### Чеклист завершения

**Перед началом:**
- [ ] API спецификация существует
- [ ] implementation-tracker.yaml запись существует
- [ ] РЕАЛЬНОЕ время получено
- [ ] **implementation-tracker.yaml обновлён (backend.status: in_progress)**

**Перед завершением:**
- [ ] Контракты сгенерированы
- [ ] Реализация создана (Entities, Repos, Controllers, Services)
- [ ] Liquibase миграции созданы
- [ ] Seed данные созданы
- [ ] API протестирован
- [ ] РЕАЛЬНОЕ время получено
- [ ] **implementation-tracker.yaml обновлён (backend.status: completed)**
- [ ] Коммит сделан

### Следующий этап
ФРОНТТАСК (проверяет backend.status: completed перед началом)

### Примеры

**Пример: Обновление при НАЧАЛЕ работы**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "in_progress"  # ← Обновлено
    started: "2025-11-07 10:00"  # ← Добавлено (РЕАЛЬНОЕ время!)
    agent: "Backend Agent"  # ← Добавлено
  frontend:
    status: "not_started"
```

**Пример: Обновление при ЗАВЕРШЕНИИ работы**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "completed"  # ← Обновлено
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"  # ← Добавлено (РЕАЛЬНОЕ время!)
    agent: "Backend Agent"
    commit: "abc123def456"  # ← Добавлено
    notes: ""
  frontend:
    status: "not_started"
```

---

## Этап 6: ФРОНТТАСК (Frontend Agent)

### Роль
Создание frontend реализации на React + TypeScript

### Документ агента
[FRONT-WEB/ФРОНТТАСК.MD](../../../FRONT-WEB/ФРОНТТАСК.MD)

### Входные данные
- OpenAPI спецификация из API-SWAGGER/api/v1/
- Запись в implementation-tracker.yaml (frontend.status: not_started, **backend.status: completed**)

### Обязательные действия

**Перед НАЧАЛОМ работы (КРИТИЧЕСКАЯ ПРОВЕРКА):**
1. Открыть implementation-tracker.yaml
2. Найти запись для API (по api_path)
3. **ПРОВЕРИТЬ: backend.status ДОЛЖЕН быть "completed"**
4. Если backend.status != "completed", **НЕ НАЧИНАТЬ работу!**

**При НАЧАЛЕ работы (ОБЯЗАТЕЛЬНО):**
5. **Получить РЕАЛЬНОЕ время из системы**
6. Обновить implementation-tracker.yaml:
   - frontend.status: "in_progress"
   - frontend.started: "YYYY-MM-DD HH:MM" (РЕАЛЬНОЕ время!)
   - frontend.agent: "Frontend Agent"
7. **Сделать коммит обновления tracker**

**Основная работа:**
8. Генерировать TypeScript клиент и React Query хуки (Orval)
9. Создать feature-based структуру (features/[feature-name]/)
10. Создать страницы (pages) для роутинга
11. Настроить роуты в app/router.tsx (React Router)
12. Создать компоненты с использованием Material UI (MUI)
13. Интегрировать с сгенерированными хуками (useQuery, useMutation)
14. Добавить защищённые роуты (если требуется)
15. Протестировать интеграцию с бекендом

**При ЗАВЕРШЕНИИ работы (ОБЯЗАТЕЛЬНО):**
16. **Получить РЕАЛЬНОЕ время из системы**
17. Открыть implementation-tracker.yaml
18. Обновить:
    - frontend.status: "completed" (или "failed")
    - frontend.completed: "YYYY-MM-DD HH:MM" (РЕАЛЬНОЕ время!)
    - frontend.commit: "хэш коммита"
    - frontend.notes: "примечания" (опционально)
19. **Сделать коммит через autocommit**

### Выходные данные
- Frontend код в FRONT-WEB/src/
- Сгенерированные хуки в src/api/generated/
- Обновлённый implementation-tracker.yaml (frontend.status: completed)
- Коммит в git

### Системы отслеживания
**Обновляет:**
- **implementation-tracker.yaml (frontend поля)** ⚠️ ОБЯЗАТЕЛЬНО!

**Не обновляет:**
- readiness-tracker.yaml
- brain-mapping.yaml

### Чеклист завершения

**Перед началом:**
- [ ] API спецификация существует
- [ ] **Бекенд реализован (backend.status: completed)** ⚠️ КРИТИЧНО!
- [ ] implementation-tracker.yaml запись существует
- [ ] РЕАЛЬНОЕ время получено
- [ ] **implementation-tracker.yaml обновлён (frontend.status: in_progress)**

**Перед завершением:**
- [ ] TypeScript клиент и хуки сгенерированы (Orval)
- [ ] Feature-based структура создана
- [ ] Страницы (pages) созданы
- [ ] Роуты настроены (React Router)
- [ ] Компоненты созданы (с MUI)
- [ ] Интеграция с бекендом протестирована
- [ ] РЕАЛЬНОЕ время получено
- [ ] **implementation-tracker.yaml обновлён (frontend.status: completed)**
- [ ] Коммит сделан

### Следующий этап
✅ ГОТОВАЯ ФИЧА

### Примеры

**Пример: Обновление при НАЧАЛЕ работы**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "completed"  # ← Проверено!
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"
    agent: "Backend Agent"
    commit: "abc123def456"
  frontend:
    status: "in_progress"  # ← Обновлено
    started: "2025-11-07 16:00"  # ← Добавлено (РЕАЛЬНОЕ время!)
    agent: "Frontend Agent"  # ← Добавлено
```

**Пример: Обновление при ЗАВЕРШЕНИИ работы**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "completed"
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"
    agent: "Backend Agent"
    commit: "abc123def456"
  frontend:
    status: "completed"  # ← Обновлено
    started: "2025-11-07 16:00"
    completed: "2025-11-07 20:00"  # ← Добавлено (РЕАЛЬНОЕ время!)
    agent: "Frontend Agent"
    commit: "def456ghi789"  # ← Добавлено
    notes: ""
```

---

## Полный пример: От идеи до реализации

### Фича: Система романтических отношений

#### 1. МЕНЕДЖЕР создаёт документ

```markdown
Файл: .BRAIN/02-gameplay/social/romance-system.md

**Статус:** draft
**Версия:** 1.0.0
**Дата создания:** 2025-11-06 14:00
**api-readiness:** needs-work
```

**Действия МЕНЕДЖЕР:**
- Создал документ
- Проработал механики
- Обновил статус: draft → review → approved
- Обновил api-readiness: needs-work → ready
- Сделал коммит

**Результат:**
```markdown
**Статус:** approved
**Версия:** 1.1.0
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06 19:00
```

#### 2. Brain Readiness Checker проверяет (опционально)

**Действия Brain Readiness Checker:**
- Проверил документ по критериям
- Подтвердил api-readiness: ready
- Обновил readiness-tracker.yaml
- Сделал коммит

**Результат в readiness-tracker.yaml:**
```yaml
- path: ".BRAIN/02-gameplay/social/romance-system.md"
  status: "ready"
  version: "1.1.0"
  checked: "2025-11-06 19:30"
  checker: "Brain Readiness Checker"
  notes: "Готов к созданию API задачи"
```

#### 3. ДУАПИТАСК создаёт задание

**Действия ДУАПИТАСК:**
- Прочитал документ .BRAIN
- Создал полное задание
- Сохранил в tasks/active/queue/task-065-romance-system-api.md
- Обновил brain-mapping.yaml
- Обновил документ .BRAIN (секция API Tasks Status)
- Сделал коммит

**Результат в brain-mapping.yaml:**
```yaml
- source: ".BRAIN/02-gameplay/social/romance-system.md"
  target: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  task_file: "tasks/active/queue/task-065-romance-system-api.md"
  status: "queued"
  created: "2025-11-06 20:00"
```

#### 4. АПИТАСК создаёт API

**Действия АПИТАСК:**
- Прочитал задание
- Создал OpenAPI спецификацию
- Сохранил в api/v1/gameplay/social/romance-system.yaml
- Обновил brain-mapping.yaml (status: completed)
- **Создал запись в implementation-tracker.yaml**
- Переместил задание в completed/
- Сделал коммит

**Результат в brain-mapping.yaml:**
```yaml
- source: ".BRAIN/02-gameplay/social/romance-system.md"
  target: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  status: "completed"
  completed: "2025-11-06 21:00"
```

**Результат в implementation-tracker.yaml (новая запись):**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "not_started"
  frontend:
    status: "not_started"
```

#### 5. БЭКТАСК реализует backend

**Действия БЭКТАСК (начало):**
- Получил реальное время: 2025-11-07 10:00
- Обновил implementation-tracker.yaml (backend.status: in_progress)
- Сделал коммит

**Действия БЭКТАСК (основная работа):**
- Сгенерировал контракты из OpenAPI
- Создал Entities (RomanceEntity, RomanceEventEntity)
- Создал Repositories
- Создал Controllers (реализуют API интерфейсы)
- Создал ServiceImpl
- Создал Liquibase миграции
- Создал seed данные
- Протестировал API

**Действия БЭКТАСК (завершение):**
- Получил реальное время: 2025-11-07 15:00
- Обновил implementation-tracker.yaml (backend.status: completed)
- Сделал коммит

**Результат в implementation-tracker.yaml:**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "completed"
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"
    agent: "Backend Agent"
    commit: "abc123def456"
  frontend:
    status: "not_started"
```

#### 6. ФРОНТТАСК реализует frontend

**Действия ФРОНТТАСК (проверка перед началом):**
- Проверил backend.status: completed ✅

**Действия ФРОНТТАСК (начало):**
- Получил реальное время: 2025-11-07 16:00
- Обновил implementation-tracker.yaml (frontend.status: in_progress)
- Сделал коммит

**Действия ФРОНТТАСК (основная работа):**
- Сгенерировал TypeScript клиент и React Query хуки (Orval)
- Создал feature структуру: features/social/romance/
- Создал страницы: pages/RomanceSystemPage.tsx
- Настроил роуты в app/router.tsx
- Создал компоненты с MUI
- Интегрировал с хуками
- Протестировал интеграцию с бекендом

**Действия ФРОНТТАСК (завершение):**
- Получил реальное время: 2025-11-07 20:00
- Обновил implementation-tracker.yaml (frontend.status: completed)
- Сделал коммит

**Результат в implementation-tracker.yaml:**
```yaml
- api_path: "api/v1/gameplay/social/romance-system.yaml"
  task_id: "API-TASK-065"
  api_status: "completed"
  backend:
    status: "completed"
    started: "2025-11-07 10:00"
    completed: "2025-11-07 15:00"
    agent: "Backend Agent"
    commit: "abc123def456"
  frontend:
    status: "completed"
    started: "2025-11-07 16:00"
    completed: "2025-11-07 20:00"
    agent: "Frontend Agent"
    commit: "def456ghi789"
```

#### Результат: ✅ ГОТОВАЯ ФИЧА!

---

## Часто задаваемые вопросы

### 1. Что делать, если забыл обновить implementation-tracker.yaml?

1. Немедленно обнови tracker
2. Получи РЕАЛЬНОЕ время из системы
3. Укажи примерное время начала/завершения (если помнишь)
4. Добавь примечание в notes
5. Сделай коммит

---

### 2. Можно ли пропустить Brain Readiness Checker?

Да, это опциональный этап.

Если МЕНЕДЖЕР уверен, что документ готов (api-readiness: ready), можно сразу перейти к ДУАПИТАСК.

---

### 3. Что делать, если БЭКТАСК провалился?

1. Проверь backend.notes в implementation-tracker.yaml
2. Исправь проблему
3. Обнови backend.status обратно на in_progress
4. После исправления обнови на completed

---

### 4. Как получить РЕАЛЬНОЕ время из системы?

**Windows:**
```powershell
powershell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm'"
```

**Linux/Mac:**
```bash
date '+%Y-%m-%d %H:%M'
```

**НЕ ВЫДУМЫВАЙ ВРЕМЯ!** Всегда используй команды выше.

---

## Ссылки на документы

### Основные документы
- **Воркфлоу проекта:** [DEVELOPMENT-WORKFLOW.md](../../../DEVELOPMENT-WORKFLOW.md)
- **Статусы:** [STATUSES-GUIDE.md](./STATUSES-GUIDE.md)
- **Шаблоны:** [TEMPLATES-GUIDE.md](./TEMPLATES-GUIDE.md)
- **Реестр агентов:** [AGENTS-REGISTRY.md](./AGENTS-REGISTRY.md)

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

