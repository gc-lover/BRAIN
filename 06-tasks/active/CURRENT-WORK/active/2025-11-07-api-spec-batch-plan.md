---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 16:14  
**api-readiness-notes:** План партии API спецификаций: мир, социальные рейтинги, рейд и квестовое ветвление готовы к генерации задач.
---

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Дата обновления:** 2025-11-07 16:14  
**Приоритет:** high  
**Ответственный:** Brain Manager  
**Связанные документы:** `2025-11-07-hybrid-media-references-expansion.md`, `2025-11-07-hybrid-media-legal-package.md`, `quest-branching-database/part1-analysis-core.md`, `quest-branching-database/part2-advanced-examples.md`, `quest-system-tech-questions-compact.md`

# План партии API спецификаций — 2025-11-08

## 1. Контекст

- Цель: сформировать очередь задач для API-SWAGGER по готовым документам `.BRAIN` (world, social, gameplay, economy).
- Фокус: гибридные события (`Throne of Sand`, `Neon Popularity Reset`, `Quantum Reef Siege`) и система ветвящихся квестов.
- Все исходные документы имеют `api-readiness: ready` (проверка 2025-11-07 16:14).

## 2. Область партии

| № | Документ (.BRAIN) | Микросервис | Планируемый API-файл | Зависимости | Статус |
|---|-------------------|-------------|----------------------|-------------|--------|
| 1 | `2025-11-07-hybrid-media-references-expansion.md` (разд. 1 «Throne of Sand») | `world-service (8086)` | `api/v1/world/events/throne-of-sand.yaml` | `world/events` ready, нет блокеров | ready |
| 2 | `2025-11-07-hybrid-media-references-expansion.md` (разд. 2 «Neon Popularity Reset») + `2025-11-07-hybrid-media-legal-package.md` | `social-service (8084)` | `api/v1/social/events/neon-popularity-reset.yaml` | Требует уведомлений UI (`shared/ui/Toast`) — специфицированы | ready |
| 3 | `2025-11-07-hybrid-media-references-expansion.md` (разд. 3 «Quantum Reef Siege`) | `gameplay-service (8083)` | `api/v1/gameplay/raids/quantum-reef-siege.yaml` | Данные обучения пилотов → `auth-service` credential schema | ready |
| 4 | `quest-branching-database/part1-analysis-core.md` + `part2-advanced-examples.md` | `gameplay-service (8083)` + `social-service (8084)` | `api/v1/gameplay/quests/branching-database.yaml` | Требует согласования с `quest-system-tech-questions-compact.md` | ready |
| 5 | `quest-system-tech-questions-compact.md` (ответы по синхронизации world/social) | `world-service` + `economy-service` | `api/v1/world/state/quest-sync.yaml` | Использует таблицы world_state, quest_consequences | ready |

## 3. Подготовка входных данных

- Проверены ссылки на moodboard/audio: `mood/throne-v1`, `mood/neon-v1`, `mood/reef-v1`, `audio/throne-anemo`, `audio/neon-loop`, `audio/reef-res`.
- SQL схемы для квестовой БД адаптированы к PostgreSQL (`uuid_generate_v4`, индексы GIN).
- Требования к UI-компонентам задокументированы (варианты `CyberpunkButton`, `SyncMeter`).
- Legal пакет подготовлен: `../../config/legal-approvals-template.md` заполнен, риски учтены.

## 4. Таймлайн партии

| Этап | Дата/время | Действие | Ответственный | Выход |
|------|-------------|----------|---------------|-------|
| Prep | 2025-11-07 18:00 | Проверка readiness + обновление трекера | Brain Manager | Обновлённый `readiness-tracker.yaml` |
| Task Creation | 2025-11-08 10:00 | Генерация задач для API Task Creator | Brain Manager → `ДУАПИТАСК` | 5 задач в `API-SWAGGER/tasks/active/queue` |
| Review | 2025-11-08 14:00 | Внутренний review задач | API Task Creator | Комментарии, при необходимости корректировка | 
| Handoff | 2025-11-08 16:00 | Передача в `АПИТАСК` | API Task Creator | Подтверждение получения |

## 5. Риски и меры

- **Пересечение с существующими API:** сверка с `API-SWAGGER/api/v1/world` и `social` — дубликатов не обнаружено; при конфликте использовать суффикс `-v2`.
- **Нагрузка на микросервисы:** рейдовые endpoints требуют проверок производительности → отметить в задачах необходимость нагрузочного теста.
- **Согласование артистики:** moodboard/аудио уже утверждены legal-пакетом, претензий не ожидается.
- **Квестовая БД:** убедиться, что `uuid-ossp` расширение включено в миграции (зафиксировать в задаче).

## 6. Инструкции для API Task Creator

1. Для каждой строки таблицы (раздел 2) создать задачу в `API-SWAGGER/tasks/active/queue/` с шаблоном `api-generation-task-template.md`.
2. Указать `source_documents` и `planned_api` из таблицы, добавить примечание по зависимостям.
3. После генерации задач обновить `brain-mapping.yaml` (связать документы `.BRAIN` с задачами API).
4. Сообщить Brain Manager об окончании через `CURRENT-WORK/current-status.md`.

## 7. Логи

- 2025-11-07 16:14 — План партии создан, подтверждена готовность 5 документов, назначен таймлайн 2025-11-08.
