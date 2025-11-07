# Quest System Technical Questions (Compact)

---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 16:14  
**api-readiness-notes:** Сводные ответы по архитектуре квестовой системы: ветвления, синхронизация, мультиплеер и последствия.
---

**Статус:** approved  
**Версия:** 2.1.0  
**Дата обновления:** 2025-11-07 16:14  
**Дата создания:** 2025-11-07 02:00

---

## 1. Branching Logic Implementation

- **Хранилище:** `quests`, `quest_branches`, `dialogue_nodes`, `dialogue_choices` (см. `quest-branching-database/part1`).
- **Активация ветки:** запрос `SELECT branch_id FROM quest_branches WHERE conditions -> 'flags' @> ...` (используем GIN индексы).
- **Skill-check:** связь `dialogue_choices.skill_check_id` → `skill_checks` (проверка d20, модификаторы). Результат записывается в `player_quest_choices`.
- **API:** `gameplay-service` endpoint `POST /quests/{questId}/branch` принимает payload с `currentNode`, `choiceId`, `rollResult`.

## 2. World State Synchronization

- **Глобальные изменения:** таблица `world_state` (Part 2). Обновления происходят через `quest_consequences` (тип `WORLD`).
- **API контракт:** `world-service` `PATCH /world/state` — принимает массив изменений `{stateKey, value, questId}`.
- **Конфликты:** используется optimistic locking (поле `updated_at`), при конфликте возвращается `409` и предлагается пересчитать контекст.
- **Кэши:** `world-service` публикует событие `world.state.updated` в Kafka; подписаны `gameplay-service` и `economy-service`.

## 3. Multi-player Quest Coordination

- **Таблица `quest_progress`:** поле `max_concurrent_players`, колонка `current_branch`. Для кооперативных квестов допускается один владелец ветки (`owner_character_id`).
- **Locking:** при попытке сменить ветку другой игрок получает `409` и предложение создать «instance» (копию квеста).
- **Синхронизация:** `gameplay-service` создает запись `quest_sessions` (in-memory + Redis) с участниками и текущим узлом.
- **UI:** HUD обновляется через WebSocket `quest/session/{sessionId}`.

## 4. Consequence Propagation

- **Флаги игрока:** таблица `player_flags` хранит `flag_key`, `value`, `set_by_quest`. Используем для репутации, романтики, сценарных блокировок.
- **Последствия:** `quest_consequences` описывает, что происходит при завершении ветки (устанавливаются флаги, репутация, world-state, loot).
- **Распределение лута:** функции `apply_consequences` вызываются в `gameplay-service` (транзакция: progress update → consequences → rewards).
- **Мониторинг:** запись в `quest_audit` (логирование всех применённых последствий).

## 5. API Targets (рекомендации)

- `api/v1/gameplay/quests/branching-database.yaml` — CRUD по квестам, выборы, skill-check.
- `api/v1/world/state/quest-sync.yaml` — управление world_state.
- `api/v1/social/reputation/flags.yaml` — синхронизация репутации и флагов (использует `player_flags`).
- `api/v1/gameplay/quest-sessions.yaml` — управление мультиплеерными сессиями.

## 6. Observability & Testing

- **Метрики:**
  - `quest_branch_switch_total` (легенда: questId, branchId).
  - `quest_session_concurrency` (гильдии / инстансы).
  - `world_state_conflicts_total`.
- **Логи:** распределяются в `ELK` с тэгом `quest-system`.
- **Автотесты:**
  - Unit: проверки триггеров `apply_consequences`.
  - Integration: сценарий «два игрока, одна ветка» (Redis session + DB).
  - Contract: Pact между `gameplay-service` и `world-service`.

## 7. Dependencies

- Требует включённого расширения PostgreSQL `uuid-ossp` (см. миграции в Part 2).
- Сервисная конфигурация: `gameplay-service` должен иметь доступ к Redis кластеру `quest-session-cache`.
- Для world-state изменений необходим доступ к Kafka topic `world-state`.

## История

- v2.1.0 (2025-11-07 16:14) — Добавлены детальные ответы, API-рекомендации и мониторинг.
- v2.0.0 (2025-11-07 02:07) — Compact (< 50 строк, ссылки на детали).
- v1.0.0 (2025-11-07) — Создан (619 строк).

