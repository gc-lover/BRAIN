# Детальные процедуры работы Clear Agent (КЛИР)

**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 23:16  
**Версия:** 1.0.0

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-06 23:16  
**api-readiness-notes:** Служебный документ с процедурами для агента КЛИР, не предназначен для создания API

**Назначение:** Детальное описание процедур архивации для Clear Agent

**Основной документ:** См. [КЛИР.MD](./КЛИР.MD)

---

## Процедура 1: Поиск завершенных фич

### Алгоритм:

**1. Читает implementation-tracker.yaml:**

```yaml
implementations:
  - api_path: "api/v1/feature1.yaml"
    backend: { status: "completed", completed: "2025-11-05 15:00", commit: "abc123" }
    frontend: { status: "completed", completed: "2025-11-05 20:00", commit: "def456" }
    # ✅ Готова к архивации
    
  - api_path: "api/v1/feature2.yaml"
    backend: { status: "completed", completed: "2025-11-05 12:00" }
    frontend: { status: "in_progress", started: "2025-11-05 16:00" }
    # ❌ НЕ готова (frontend не завершен)
```

**2. Собирает список завершенных:** `[feature1]`

**3. Для каждой фичи собирает полные данные** из всех трекеров

---

## Процедура 2: Формирование отчета о фиче

### Шаблон отчета:

```markdown
## [ID] Название фичи

**Завершено:** YYYY-MM-DD  
**API:** `api/v1/path/to/api.yaml`  
**Task ID:** API-TASK-XXX  
**Источник:** `.BRAIN/path/to/document.md`

### Timeline разработки

| Этап | Дата начала | Дата завершения | Длительность | Агент |
|------|-------------|-----------------|--------------|-------|
| API-readiness | - | YYYY-MM-DD HH:MM | - | МЕНЕДЖЕР/Brain Checker |
| Задание создано | - | YYYY-MM-DD HH:MM | - | ДУАПИТАСК |
| API создан | - | YYYY-MM-DD HH:MM | - | АПИТАСК |
| Backend | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | 4.5h | Backend Agent |
| Frontend | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | 4h | Frontend Agent |
| **ИТОГО** | - | - | **3 дня** | - |

### Endpoints реализовано: 3

- `POST /api/v1/...` - [описание]
- `GET /api/v1/...` - [описание]
- `PUT /api/v1/...` - [описание]

### Модели данных: 5

- ModelName1, ModelName2, ModelName3, ModelName4, ModelName5

### Commits:
- Backend: `abc123d` (BACK-GO)
- Frontend: `def456g` (FRONT-WEB)
- API: `ghi789j` (API-SWAGGER)

### Ссылки:
- [Документ .BRAIN](.BRAIN/path/to/document.md)
- [API спецификация](API-SWAGGER/api/v1/path/to/api.yaml)
- [Задание](API-SWAGGER/tasks/completed/YYYY-MM-DD/task-XXX-description.md)

---
```

### Размер отчета:

- **~40-50 строк на фичу**
- **Лимит файла:** 400-500 строк = ~10 фич в одном файле

### Если превышен лимит:

- Создать следующий файл: `feature-reports-002.md`
- Продолжить запись туда

---

## Процедура 3: Архивация записи из трекера

### Для implementation-tracker.yaml:

**1. Читает запись:**
```yaml
- api_path: "api/v1/feature1.yaml"
  task_id: "API-TASK-026"
  # ... все данные
```

**2. Копирует в архив** `.BRAIN/06-tasks/archive/completed-trackers/implementation-tracker/2025-11.yaml`:
```yaml
archived_implementations:
  - api_path: "api/v1/feature1.yaml"
    task_id: "API-TASK-026"
    # ... все данные
    archived_at: "2025-11-06 23:16"  # РЕАЛЬНОЕ время!
    archived_by: "Clear Agent"
```

**3. Удаляет из активного** `implementation-tracker.yaml`

**4. Сохраняет оба файла**

### Аналогично для brain-mapping.yaml и readiness-tracker.yaml

---

## Процедура 4: Очистка TODO.md

### Алгоритм:

**1. Читает TODO.md**

**2. Находит выполненные задачи:**
```markdown
- [x] Реализовать систему создания персонажей
- [x] Создать API для романсов
- [ ] Разработать систему крафта  # ← Не трогаем
```

**3. Переносит в архив** `06-tasks/archive/completed-todos/2025-11.md`:
```markdown
# Архив выполненных задач за Ноябрь 2025

## Завершено 2025-11-06:
- [x] Реализовать систему создания персонажей (Завершено: 2025-11-05)
- [x] Создать API для романсов (Завершено: 2025-11-06)
```

**4. Удаляет из TODO.md**

**5. Сохраняет оба файла**

---

## Процедура 5: Создание статистики

### Генерирует файл статистики за месяц:

**Путь:** `.BRAIN/06-tasks/archive/statistics/monthly/YYYY-MM-stats.md`

**Содержание:**
```markdown
# Статистика за Ноябрь 2025

**Период:** 2025-11-01 - 2025-11-30  
**Создано:** 2025-11-06 23:16 (Clear Agent)

## Завершенные фичи

**Всего:** 15 фич

### По категориям:
- Gameplay: 8 фич
- Social: 4 фичи
- Auth: 2 фичи
- Economy: 1 фича

### По агентам:
- Backend Agent: 15 реализаций
- Frontend Agent: 15 реализаций

## Среднее время разработки

- От идеи до API: 2.5 дня
- Backend: 4.5 часа
- Frontend: 4 часа
- Полный цикл: 3 дня

## Топ-5 самых быстрых фич:
1. [Фича 1] - 1 день
2. [Фича 2] - 1.5 дня
...

## Топ-5 самых долгих фич:
1. [Фича 1] - 7 дней
2. [Фича 2] - 5 дней
...

## Созданные API endpoints: 45
## Созданные модели данных: 78
## Миграций БД: 12
```

**Обновляет общую статистику:**

**Путь:** `.BRAIN/06-tasks/archive/statistics/overall-stats.md`

---

## Процедура 6: Обновление индексов

**Обновляет файлы:**

1. `.BRAIN/06-tasks/archive/INDEX.md` - общий индекс всего архива
2. `.BRAIN/06-tasks/archive/completed-features/YYYY-MM/README.md` - индекс отчетов месяца
3. `.BRAIN/06-tasks/archive/README.md` - описание структуры архива

### Формат INDEX.md:

```markdown
# Индекс архива завершенных работ

**Последнее обновление:** 2025-11-06 23:16 (Clear Agent)

## Быстрая навигация

### По категориям:
- Gameplay: 8 фич
- Social: 4 фичи
...

### По датам:
- Ноябрь 2025: 15 фич
...

### Статистика:
- [Общая статистика](./statistics/overall-stats.md)
- [Помесячная статистика](./statistics/monthly/)
```

---

## Обязательные проверки перед удалением

### Чеклист безопасности:

1. **Резервная копия:**
   - [ ] Запись СКОПИРОВАНА в архив
   - [ ] Архивный файл СОХРАНЕН
   - [ ] Содержимое архивного файла ПРОВЕРЕНО

2. **Проверка данных:**
   - [ ] Все поля скопированы корректно
   - [ ] archived_at и archived_by добавлены
   - [ ] РЕАЛЬНОЕ время использовано

3. **Только после всех проверок:**
   - [ ] Удалить запись из активного трекера
   - [ ] Сохранить активный трекер
   - [ ] Проверить, что запись удалена

---

**Версия документа:** 1.0.0  
**Дата последнего обновления:** 2025-11-06 23:16

