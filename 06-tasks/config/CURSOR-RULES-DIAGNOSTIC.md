# Диагностика проблем с правилами Cursor

**Проблема:** Правила в подпапках репозиториев игнорируются, хотя указано `alwaysApply: true`

---

## Текущая структура

```
NECPGAME/ (workspace root)
├── .cursor/rules/
│   └── project-rules.mdc ✅
├── .BRAIN/
│   └── .cursor/rules/
│       ├── brain-rules.mdc ⚠️
│       └── brain-readiness-checker-rules.mdc ⚠️
├── API-SWAGGER/
│   └── .cursor/rules/
│       ├── api-swagger-rules.mdc ⚠️
│       └── api-task-creator-rules.mdc ⚠️
├── BACK-GO/
│   └── .cursor/rules/
│       └── back-go-rules.mdc ⚠️
├── FRONT-WEB/
│   └── .cursor/rules/
│       └── front-web-rules.mdc ⚠️
└── GAME-CPP-FOR-UE5/
    └── .cursor/rules/
        └── game-cpp-rules.mdc ⚠️
```

---

## Проблема

**Cursor IDE применяет правила только из корня workspace!**

Согласно документации Cursor:
- Правила в `.cursor/rules/` применяются автоматически только если они находятся в **корне workspace**
- Правила в подпапках/подмодулях **не применяются автоматически**
- Для применения правил к конкретным файлам нужно использовать `autoAttach` с `globs`

---

## Решение ✅ РЕАЛИЗОВАНО

### Используется Комбинированный подход

**Структура:**
```
NECPGAME/ (workspace root)
└── .cursor/rules/
    ├── project-rules.mdc (alwaysApply: true) ✅ - общие правила для всего проекта
    ├── brain-rules.mdc (autoAttach: [".BRAIN/**/*"]) ✅ - для работы с .BRAIN
    ├── brain-readiness-checker-rules.mdc (autoAttach: [".BRAIN/**/*.md"]) ✅ - для проверки готовности
    ├── api-swagger-rules.mdc (autoAttach: ["API-SWAGGER/**/*"]) ✅ - для работы с API-SWAGGER
    ├── api-task-creator-rules.mdc (autoAttach: ["API-SWAGGER/tasks/**/*", ".BRAIN/**/*.md"]) ✅ - для создания задач
    ├── back-go-rules.mdc (autoAttach: ["BACK-GO/**/*"]) ✅ - для работы с BACK-GO
    ├── front-web-rules.mdc (autoAttach: ["FRONT-WEB/**/*"]) ✅ - для работы с FRONT-WEB
    └── game-cpp-rules.mdc (autoAttach: ["GAME-CPP-FOR-UE5/**/*"]) ✅ - для работы с GAME-CPP-FOR-UE5
```

**Как это работает:**

1. **project-rules.mdc** с `alwaysApply: true` - применяется всегда для всего проекта
2. **Остальные правила** с `autoAttach` - применяются автоматически при работе с файлами в соответствующих директориях
3. **Несколько правил могут применяться одновременно** - например, при работе с `.BRAIN/**/*.md` применяются:
   - `project-rules.mdc` (всегда)
   - `brain-rules.mdc` (autoAttach)
   - `brain-readiness-checker-rules.mdc` (autoAttach, если работа с конфигами)

**Формат правил с autoAttach:**

```markdown
---
description: Описание правила для какого агента
autoAttach:
  globs:
    - ".BRAIN/**/*"
    - ".BRAIN/**/*.md"
alwaysApply: false
---

1. Правило 1
2. Правило 2
...
```

**Преимущества:**
- ✅ Общие правила применяются всегда
- ✅ Специфичные правила применяются автоматически при работе с конкретными файлами
- ✅ Гибкость - каждый агент получает свои правила в зависимости от контекста
- ✅ Не нужно вручную выбирать правила - Cursor применяет их автоматически

---

## Проверка правил

### Как проверить, что правила применяются:

1. **Открыть файл из репозитория** (например, `.BRAIN/README.md`)
2. **Спросить агента:** "Какие правила у тебя есть?"
3. **Агент должен упомянуть** соответствующие правила

### Если правила не применяются:

1. **Проверь структуру:** Правила должны быть в `.cursor/rules/` в корне workspace
2. **Проверь формат:** Должен быть YAML frontmatter с `alwaysApply: true` или `autoAttach`
3. **Перезапусти Cursor:** После изменения правил нужно перезапустить IDE
4. **Проверь `.cursorignore`:** Правила не должны быть в игнорируемых файлах

---

## Рекомендации

1. **Используйте Вариант 1 или Вариант 3:**
   - Переместите все правила в `.cursor/rules/` в корне workspace
   - Используйте префиксы в названиях файлов: `brain-rules.mdc`, `api-swagger-rules.mdc`

2. **Для специфичных правил используйте autoAttach:**
   - Правила, которые должны применяться только к определенным файлам
   - Используйте `globs` для указания путей

3. **Общие правила с alwaysApply: true:**
   - Правила, которые должны применяться всегда (например, project-rules.mdc)

---

## Миграция правил

### Шаги для миграции:

1. **Скопировать все правила в корень:**
   ```bash
   # Создать структуру
   mkdir -p .cursor/rules
   
   # Копировать правила
   cp .BRAIN/.cursor/rules/*.mdc .cursor/rules/
   cp API-SWAGGER/.cursor/rules/*.mdc .cursor/rules/
   cp BACK-GO/.cursor/rules/*.mdc .cursor/rules/
   cp FRONT-WEB/.cursor/rules/*.mdc .cursor/rules/
   cp GAME-CPP-FOR-UE5/.cursor/rules/*.mdc .cursor/rules/
   ```

2. **Обновить правила с autoAttach (если нужно):**
   - Добавить `autoAttach` с `globs` для каждого репозитория

3. **Удалить старые правила:**
   ```bash
   rm -rf .BRAIN/.cursor/rules
   rm -rf API-SWAGGER/.cursor/rules
   rm -rf BACK-GO/.cursor/rules
   rm -rf FRONT-WEB/.cursor/rules
   rm -rf GAME-CPP-FOR-UE5/.cursor/rules
   ```

4. **Перезапустить Cursor IDE**

---

## Пример обновленных правил

### brain-rules.mdc с autoAttach:

```markdown
---
autoAttach:
  globs:
    - ".BRAIN/**/*"
    - ".BRAIN/**/*.md"
alwaysApply: false
---

1. Репозиторий .BRAIN предназначен для хранения идей, концепций, документов по проекту.
...
```

### api-swagger-rules.mdc с autoAttach:

```markdown
---
autoAttach:
  globs:
    - "API-SWAGGER/**/*"
    - "API-SWAGGER/**/*.yaml"
    - "API-SWAGGER/**/*.yml"
alwaysApply: false
---

1. Репозиторий API-SWAGGER содержит централизованную API документацию...
...
```

---

## Дополнительная информация

- [Документация Cursor Rules](https://docs.cursor.com/ru/context/rules)
- [Auto Attach Rules](https://docs.cursor.com/ru/context/rules#auto-attach)
- [Ignore Files](https://docs.cursor.com/ru/context/ignore-files)

---

**Статус:** ✅ РЕАЛИЗОВАНО

Все правила перемещены в `.cursor/rules/` в корне workspace и настроены с `autoAttach` для автоматического применения в зависимости от контекста работы.

**Важно:** После миграции нужно перезапустить Cursor IDE, чтобы правила загрузились корректно.

