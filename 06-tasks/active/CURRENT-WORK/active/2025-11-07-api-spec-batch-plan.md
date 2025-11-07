---
**Статус:** approved  
**Версия:** 1.2.0  
**Дата создания:** 2025-11-07 02:45  
**Обновлено:** 2025-11-07 20:07  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 20:07  
**api-readiness-notes:** Обновлённый план партионной генерации OpenAPI. Добавлены арены, лут-хант, подземелья, лайв-эвенты и лор-справочники.
---

# План подготовки партий для ДУАПИТАСК (API спецификации)

## Цель

Разбить микрофичи на партии для передачи в ДУАПИТАСК (API Task Creator). Каждая партия: 9–12 документов, сгруппированных по домену. Все документы имеют `api-readiness: ready`.

## Сводка статусов

| Batch | Тематика | Кол-во docs | Статус |
|-------|----------|-------------|--------|
| 01 | Core & Infrastructure | 11 | готов к запуску |
| 02 | Gameplay & Social | 10 | готов |
| 03 | Economy & Monetization | 10 | готов |
| 04 | Sessions & World State | 9 | готов |
| 05 | Competitive & Events | 8 | готов (новые документы) |
| 06 | Lore Support | 2 | not-applicable (справочники) |

---

## Batch 01 - Core & Infrastructure (11 docs)
1. `05-technical/backend/achievement/achievement-core.md`
2. `05-technical/backend/achievement/achievement-tracking.md`
3. `05-technical/backend/achievement/achievement-examples-api.md`
4. `05-technical/backend/leaderboard/leaderboard-core.md`
5. `05-technical/backend/daily-reset/daily-reset-compact.md`
6. `05-technical/backend/maintenance/maintenance-mode-system.md`
7. `05-technical/backend/support/support-ticket-system.md`
8. `05-technical/backend/announcement/announcement-system.md`
9. `05-technical/backend/voice-chat/voice-chat-system.md`
10. `05-technical/backend/referral/referral-system.md`
11. `05-technical/backend/companion/companion-system.md`

## Batch 02 - Gameplay & Social (10 docs)
1. `05-technical/backend/matchmaking/matchmaking-algorithm.md`
2. `05-technical/backend/matchmaking/matchmaking-queue.md`
3. `05-technical/backend/matchmaking/matchmaking-rating.md`
4. `05-technical/backend/party-system.md`
5. `05-technical/backend/guild-system-backend.md`
6. `05-technical/backend/clan-war/clan-war-system.md`
7. `05-technical/backend/housing/housing-system.md`
8. `05-technical/backend/chat/chat-channels.md`
9. `05-technical/backend/chat/chat-features.md`
10. `05-technical/backend/chat/chat-moderation.md`

## Batch 03 - Economy & Monetization (10 docs)
1. `05-technical/backend/inventory-system/part1-core-system.md`
2. `05-technical/backend/inventory-system/part2-advanced-features.md`
3. `05-technical/backend/loot-system/part1-loot-generation.md`
4. `05-technical/backend/loot-system/part2-advanced-loot.md`
5. `05-technical/backend/trade-system.md`
6. `05-technical/backend/battle-pass/part1-core-progression.md`
7. `05-technical/backend/battle-pass/part2-rewards-challenges.md`
8. `05-technical/backend/cosmetic/cosmetic-system.md`
9. `05-technical/backend/daily-weekly-reset-system.md`
10. `05-technical/backend/mail-system.md`

## Batch 04 - Sessions, Realtime & Player State (9 docs)
1. `05-technical/backend/player-character-mgmt/part1-creation-deletion.md`
2. `05-technical/backend/player-character-mgmt/part2-switching-management.md`
3. `05-technical/backend/session/session-lifecycle-heartbeat.md`
4. `05-technical/backend/session/session-reconnection-monitoring.md`
5. `05-technical/backend/realtime-server/part1-architecture-zones.md`
6. `05-technical/backend/realtime-server/part2-protocol-optimization.md`
7. `05-technical/backend/quest-engine-backend.md`
8. `05-technical/backend/progression-backend.md`
9. `05-technical/backend/friend-system.md`

## Batch 05 - Competitive & Events (8 docs)
1. `02-gameplay/combat/arena-system.md`
2. `02-gameplay/combat/loot-hunt-system.md`
3. `02-gameplay/world/dungeons/dungeon-scenarios-catalog.md`
4. `02-gameplay/world/events/live-events-system.md`
5. `05-technical/backend/voice-lobby/voice-lobby-system.md`
6. `05-technical/backend/leaderboard/leaderboard-core.md`
7. `05-technical/backend/announcement/announcement-system.md`
8. `05-technical/backend/anti-cheat/anti-cheat-core.md`

## Batch 06 - Lore Support (Reference)
1. `03-lore/activities/activities-lore-compendium.md`
2. `03-lore/characters/activity-npc-roster.md`

> Batch 06 передаётся Brain Readiness Checker как справочная коллекция, без постановки API задач.

---

## Следующие шаги

1. Запустить ДУАПИТАСК для Batch 01 (core) → далее Batch 02–05
2. Создать YAML файлы: `batch-01-core.yaml`, `batch-02-gameplay.yaml`, `batch-03-economy.yaml`, `batch-04-state.yaml`, `batch-05-competitive.yaml`
3. Обновить `brain-mapping.yaml` после генерации API задач
4. Вести лог прогресса в `CURRENT-WORK/current-status.md`
5. Подготовить Batch 07 (economy live ops, housing expansions) после сдачи Batch 05

---

## Лог работ

- 2025-11-07 02:45 — создан базовый план
- 2025-11-07 20:07 — добавлены Competitive & Events + Lore Support


