---
**Статус:** updated  
**Дата:** 2025-11-08 17:39  
**Ответственный:** AI Brain Manager
---

# Текущий статус работы (2025-11-08 16:51)

## Новые микрофичи (готовы к API)

- `02-gameplay/combat/arena-system.md` — арены, рейтинги, экономика наград
- `02-gameplay/combat/loot-hunt-system.md` — лутингшутер-цикл, контракты, риск/награда
- `02-gameplay/world/dungeons/dungeon-scenarios-catalog.md` — сценарии подземелий
- `02-gameplay/world/events/live-events-system.md` — лайв-эвенты и календарь
- `03-lore/activities/activities-lore-compendium.md` — лор активностей
- `03-lore/characters/activity-npc-roster.md` — NPC для активностей
- `CURRENT-WORK/active/2025-11-07-anomalous-easter-scenarios.md` — календарь аномалий с REST/Kafka контурами и наградами
- `CURRENT-WORK/active/2025-11-07-crossculture-easter-atlas.md` — сезон Metropolis Threads (граффити, павильоны, рынок, музей)
- `CURRENT-WORK/active/2025-11-07-subliminal-easter-network.md` — сублиминальные сигналы HUD/почта/подкасты с анти-спамом `/knock`

Все документы имеют `api-readiness: ready`, сформированы API контуры (кроме справочников Batch 06).

## Обновлённые планы

- `2025-11-07-api-spec-batch-plan.md` — добавлены Batch 05 (Competitive & Events) и Batch 06 (Lore Reference). YAML-файлы для Batch 05 будут созданы после запуска Batch 01–04.
- API задачи: `API-TASK-364/365` (аномалии), `API-TASK-366/367/368` (Metropolis Threads), `API-TASK-369/370/371` (Subliminal Network) — статус queued в `tasks/active/queue` и `brain-mapping.yaml`.

## Связанные системы

- Интеграции: Voice Lobby, Leaderboard, Announcement, Anti-Cheat, Clan Wars, Economy
- Лор и NPC синхронизированы с игровыми документами; готовы к эскалации в QUEST/LORE пайплайн

## Активные фокусы

- `CURRENT-WORK/active/2025-11-08-gameplay-backend-sync.md` — контроль передачи пакетов в API Executor до 2025-11-10.
- `API-SWAGGER/tasks/active/queue` — мониторинг выполнения задач 364–371 и запуск Batch 01–05 после генерации клиентов.
- Подготовка YAML `batch-05-competitive.yaml` и формирование пакета для Batch 06 (Lore Support).

## Следующие действия

1. Запустить автогенерацию DTO/клиентов в `BACK-GO` и `FRONT-WEB` для задач API-TASK-364..371, зафиксировать результаты.
2. Завершить YAML `batch-05-competitive.yaml` и подготовить исходные материалы для Batch 06 (Lore Support).
3. После генерации обновить `current-status.md`, `TODO.md` и readiness-трекер (при необходимости отметить выполнение).
4. Держать мониторинг по `CURRENT-WORK/active/2025-11-08-gameplay-backend-sync.md` и зафиксировать передачу в API Executor.

## Блокирующие факторы

- нет блокеров; все зависимые документы существуют и готовы


