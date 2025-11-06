# Архив трекеров

**Управляется агентом:** Clear Agent (КЛИР)  
**Последнее обновление:** 2025-11-06 23:16

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-06 23:16  
**api-readiness-notes:** Директория с архивами трекеров, не предназначена для создания API

---

## Назначение

Эта директория содержит **архивные копии записей из трекеров** для завершенных фич.

**Трекеры:**
1. **implementation-tracker** - статусы реализации backend/frontend
2. **brain-mapping** - связи .BRAIN → задания → API
3. **readiness-tracker** - готовность документов .BRAIN

**Группировка:** По месяцам (`YYYY-MM.yaml`)

---

## Структура директории

```
completed-trackers/
├── README.md                      # Этот файл
├── implementation-tracker/
│   ├── 2025-11.yaml               # Архив за ноябрь 2025
│   ├── 2025-12.yaml               # Архив за декабрь 2025
│   └── README.md                  # Индекс архивов
├── brain-mapping/
│   ├── 2025-11.yaml
│   └── README.md
└── readiness-tracker/
    ├── 2025-11.yaml
    └── README.md
```

---

## Формат архивных файлов

### implementation-tracker/YYYY-MM.yaml

```yaml
# Архив завершенных реализаций за YYYY-MM
# Создано: YYYY-MM-DD HH:MM (Clear Agent)
# Источник: implementation-tracker.yaml

archived_implementations:
  - api_path: "api/v1/path/to/api.yaml"
    task_id: "API-TASK-XXX"
    # ... все исходные поля
    archived_at: "YYYY-MM-DD HH:MM"
    archived_by: "Clear Agent"
```

---

## Архивированные месяцы

**Всего месяцев:** 0

*(Будет обновлено после первой архивации)*

---

**Для поиска в архиве используйте:** [INDEX.md](../INDEX.md)

