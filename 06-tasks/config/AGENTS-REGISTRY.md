# Реестр агентов проекта

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-03 00:04  
**api-readiness-notes:** Служебный конфигурационный файл, описывает агентов проекта и их правила, не предназначен для создания API

**Назначение:** Документ содержит список всех агентов проекта и их правила

---

## Агенты проекта

### 1. Brain Manager Agent

**Имя агента:** `brain-manager`  
**Роль:** Концептуальное управление и разработка идей  
**Правило:** `.cursor/rules/brain-rules.mdc`  
**Применяется к:** `.BRAIN/**/*`, `.BRAIN/**/*.md`  
**Описание:** Управляет концепциями и идеями проекта в репозитории .BRAIN

---

### 2. Brain Readiness Checker Agent

**Имя агента:** `brain-readiness-checker`  
**Роль:** Проверка готовности документов к созданию API задач  
**Правило:** `.cursor/rules/brain-readiness-checker-rules.mdc`  
**Применяется к:** `.BRAIN/**/*.md`, `.BRAIN/06-tasks/config/**/*`  
**Описание:** Проверяет документы в .BRAIN и определяет их готовность к созданию API задач для API-SWAGGER

---

### 3. API Task Creator Agent

**Имя агента:** `api-task-creator`  
**Роль:** Создание задач из .BRAIN документов для API-SWAGGER  
**Правило:** `.cursor/rules/api-task-creator-rules.mdc`  
**Применяется к:** `API-SWAGGER/tasks/**/*`, `.BRAIN/**/*.md`  
**Описание:** Преобразует документы из .BRAIN в полные задания для агентов-исполнителей в API-SWAGGER

---

### 4. API Executor Agent

**Имя агента:** `api-executor`  
**Роль:** Создание и поддержка API спецификаций  
**Правило:** `.cursor/rules/api-swagger-rules.mdc`  
**Применяется к:** `API-SWAGGER/**/*`, `API-SWAGGER/**/*.yaml`, `API-SWAGGER/**/*.yml`, `API-SWAGGER/**/*.json`  
**Описание:** Создает и поддерживает API спецификации в формате OpenAPI/Swagger

---

### 5. Backend Agent

**Имя агента:** `backend-agent`  
**Роль:** Разработка бекенда на Go  
**Правило:** `.cursor/rules/back-go-rules.mdc`  
**Применяется к:** `BACK-GO/**/*`, `BACK-GO/**/*.go`  
**Описание:** Разрабатывает бекенд сервис на языке Go

---

### 6. Frontend Agent

**Имя агента:** `frontend-agent`  
**Роль:** Разработка фронтенда веб-приложения  
**Правило:** `.cursor/rules/front-web-rules.mdc`  
**Применяется к:** `FRONT-WEB/**/*`, `FRONT-WEB/**/*.ts`, `FRONT-WEB/**/*.tsx`, `FRONT-WEB/**/*.js`, `FRONT-WEB/**/*.jsx`  
**Описание:** Разрабатывает веб-фронтенд для текстовой версии игры

---

### 7. Game Agent

**Имя агента:** `game-agent`  
**Роль:** Разработка прослойки между BACK-GO и UE5  
**Правило:** `.cursor/rules/game-cpp-rules.mdc`  
**Применяется к:** `GAME-CPP-FOR-UE5/**/*`, `GAME-CPP-FOR-UE5/**/*.cpp`, `GAME-CPP-FOR-UE5/**/*.h`, `GAME-CPP-FOR-UE5/**/*.hpp`  
**Описание:** Разрабатывает прослойку между BACK-GO и Unreal Engine 5

---

### 8. Все агенты (общие правила)

**Имя агента:** `all-agents`  
**Роль:** Общие правила проекта  
**Правило:** `.cursor/rules/project-rules.mdc`  
**Применяется к:** Всё (alwaysApply: true)  
**Описание:** Общие правила проекта, применяются ко всем агентам

---

## Структура метаданных правил

Каждое правило содержит метаданные с информацией об агенте:

```yaml
---
# АГЕНТ: Название агента
# РОЛЬ: Роль агента в проекте
description: Описание правила для агента
agent: имя-агента (snake_case)
role: Роль агента
autoAttach:
  globs:
    - "путь/к/файлам/**/*"
alwaysApply: false
---
```

---

## Как использовать

### Для добавления нового агента:

1. Создайте файл `.cursor/rules/new-agent-rules.mdc`
2. Добавьте метаданные с информацией об агенте:

```yaml
---
# АГЕНТ: New Agent Name
# РОЛЬ: Роль нового агента
description: Правила для New Agent - описание
agent: new-agent
role: Роль агента
autoAttach:
  globs:
    - "PATH/**/*"
alwaysApply: false
---

1. Правило 1
2. Правило 2
...
```

3. Добавьте запись в этот реестр
4. Перезапустите Cursor IDE

---

## Поиск правила для агента

Чтобы найти правило для конкретного агента:

1. Используйте поле `agent` в frontmatter правила
2. Или используйте название файла (например, `brain-rules.mdc` для `brain-manager`)
3. Или проверьте этот реестр

---

**Последнее обновление:** 2025-01-02


