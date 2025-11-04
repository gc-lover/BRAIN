# Быстрое руководство по правилам Cursor

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-03 00:04  
**api-readiness-notes:** Служебный конфигурационный файл, описание правил Cursor, не предназначен для создания API

## Структура правил

Все правила находятся в `.cursor/rules/` в корне workspace и применяются автоматически в зависимости от контекста работы.

### Общие правила (всегда применяются)

- **project-rules.mdc** - `alwaysApply: true`
  - Применяются для всего проекта
  - Общие принципы: SOLID, DRY, KISS
  - Описание репозиториев и цепочка взаимодействий

### Правила по репозиториям (применяются автоматически)

#### .BRAIN

- **brain-rules.mdc** - `autoAttach: [".BRAIN/**/*"]`
  - Правила для работы с репозиторием .BRAIN
  - Применяются при работе с любыми файлами в `.BRAIN/`

- **brain-readiness-checker-rules.mdc** - `autoAttach: [".BRAIN/**/*.md"]`
  - Правила для AI проверяющего готовность документов
  - Применяются при работе с markdown файлами в `.BRAIN/`

#### API-SWAGGER

- **api-swagger-rules.mdc** - `autoAttach: ["API-SWAGGER/**/*"]`
  - Правила для работы с репозиторием API-SWAGGER
  - Применяются при работе с API спецификациями

- **api-task-creator-rules.mdc** - `autoAttach: ["API-SWAGGER/tasks/**/*", ".BRAIN/**/*.md"]`
  - Правила для AI создателя заданий
  - Применяются при работе с задачами или .BRAIN документами

#### BACK-JAVA

- **back-go-rules.mdc** - `autoAttach: ["BACK-JAVA/**/*"]`
  - Правила для работы с бекендом на Java Spring Boot
  - Применяются при работе с файлами в `BACK-JAVA/`

#### FRONT-WEB

- **front-web-rules.mdc** - `autoAttach: ["FRONT-WEB/**/*"]`
  - Правила для работы с фронтендом
  - Применяются при работе с файлами в `FRONT-WEB/`

#### GAME-CPP-FOR-UE5

- **game-cpp-rules.mdc** - `autoAttach: ["GAME-CPP-FOR-UE5/**/*"]`
  - Правила для работы с прослойкой для UE5
  - Применяются при работе с файлами в `GAME-CPP-FOR-UE5/`

---

## Как это работает

### Пример 1: Работа с .BRAIN документами

При открытии файла `.BRAIN/01-concepts/vision.md` автоматически применяются:
1. **project-rules.mdc** (всегда)
2. **brain-rules.mdc** (autoAttach)
3. **brain-readiness-checker-rules.mdc** (autoAttach для .md файлов)

### Пример 2: Работа с API спецификациями

При открытии файла `API-SWAGGER/openapi.yaml` автоматически применяются:
1. **project-rules.mdc** (всегда)
2. **api-swagger-rules.mdc** (autoAttach)

### Пример 3: Создание задачи из .BRAIN документа

При работе с файлами `API-SWAGGER/tasks/active/queue/task-001.md` и `.BRAIN/02-gameplay/combat/shooter-mechanics.md` применяются:
1. **project-rules.mdc** (всегда)
2. **api-task-creator-rules.mdc** (autoAttach для tasks и .BRAIN)
3. **brain-rules.mdc** (autoAttach для .BRAIN)
4. **api-swagger-rules.mdc** (autoAttach для API-SWAGGER)

---

## Проверка применения правил

### Как проверить, что правила применяются:

1. Откройте файл из нужного репозитория (например, `.BRAIN/README.md`)
2. Спросите агента: "Какие правила у тебя сейчас применены?"
3. Агент должен упомянуть соответствующие правила

### Если правила не применяются:

1. **Перезапустите Cursor IDE** - правила загружаются при старте
2. Проверьте, что файл находится в правильной директории
3. Проверьте формат правила (должен быть YAML frontmatter с `autoAttach` или `alwaysApply`)

---

## Агенты и их правила

### Brain Manager Agent
- **Правила:** project-rules.mdc + brain-rules.mdc
- **Работает с:** `.BRAIN/**/*`

### Brain Readiness Checker Agent
- **Правила:** project-rules.mdc + brain-readiness-checker-rules.mdc
- **Работает с:** `.BRAIN/**/*.md`, `.BRAIN/06-tasks/config/**/*`

### API Task Creator Agent
- **Правила:** project-rules.mdc + api-task-creator-rules.mdc + brain-rules.mdc
- **Работает с:** `API-SWAGGER/tasks/**/*`, `.BRAIN/**/*.md`

### API Executor Agent
- **Правила:** project-rules.mdc + api-swagger-rules.mdc
- **Работает с:** `API-SWAGGER/**/*.yaml`, `API-SWAGGER/**/*.yml`

### Backend Agent
- **Правила:** project-rules.mdc + back-go-rules.mdc
- **Работает с:** `BACK-JAVA/**/*.java`

### Frontend Agent
- **Правила:** project-rules.mdc + front-web-rules.mdc
- **Работает с:** `FRONT-WEB/**/*.ts`, `FRONT-WEB/**/*.tsx`

### Game Agent
- **Правила:** project-rules.mdc + game-cpp-rules.mdc
- **Работает с:** `GAME-CPP-FOR-UE5/**/*.cpp`, `GAME-CPP-FOR-UE5/**/*.h`

---

## Добавление новых правил

Если нужно добавить новое правило для другого агента:

1. Создайте файл `.cursor/rules/new-agent-rules.mdc`
2. Добавьте frontmatter с `autoAttach`:

```markdown
---
description: Описание правила
autoAttach:
  globs:
    - "PATH/TO/REPO/**/*"
alwaysApply: false
---

1. Правило 1
2. Правило 2
...
```

3. Перезапустите Cursor IDE

---

**Последнее обновление:** 2025-01-02

