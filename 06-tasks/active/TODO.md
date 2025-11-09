# TODO — Brain Manager

**Обновлено:** 2025-11-09 09:38  
**Ответственный:** Brain Manager

---

## Critical
- [x] Провести аудит `.BRAIN` и удалить устаревшие блоки `API Tasks Status` (2025-11-09 00:25).
## High
- [~] Combat Systems Wave 1 — собрать материалы (combat-session, combat-ai-enemies, combat-implants-types, combat-dnd-core, combat-dnd-integration-shooter, combat-abilities, combat-shooting, combat-combos-synergies, combat-extract, combat-freerun, combat-hacking-networks, combat-hacking-combat-integration, combat-cyberspace, arena-system) и передать пакет ДУАПИТАСК (2025-11-09 01:44).
- [~] Economy Core Refresh — синхронизировать постановку задач для `.BRAIN/05-technical/backend/trade-system.md` и `.BRAIN/05-technical/backend/inventory-system/part1-core-system.md` (REST/Events подготовлены, ждём слот, 2025-11-09 02:20).
- [~] Auth/Characters/Progression — оформить бриф по auth README, character-management и progression-backend (REST/Events/Storage, 2025-11-09 02:47).
- [~] Quest Engine Package — подготовить материалы `.BRAIN/05-technical/backend/quest-engine-backend.md` для передачи в ДУАПИТАСК (REST/WebSocket/Events/Storage сводка, 2025-11-09 01:19).
## Medium
- [~] Combat Shooting — подготовить материалы `.BRAIN/02-gameplay/combat/combat-shooting.md` (TTK, отдача, импланты) для передачи в ДУАПИТАСК (2025-11-09 01:37).
- [~] Combat Stealth — подготовить материалы `.BRAIN/02-gameplay/combat/combat-stealth.md` (каналы обнаружения, импланты) для передачи в ДУАПИТАСК (2025-11-09 01:39).
- [~] Combat Abilities — подготовить материалы `.BRAIN/02-gameplay/combat/combat-abilities.md` (источники, ранги, ограничения) для передачи в ДУАПИТАСК (2025-11-09 01:42).
- [~] Combat D&D Core — подготовить материалы `.BRAIN/02-gameplay/combat/combat-dnd-core.md` (DC, модификаторы, групповые проверки) для передачи в ДУАПИТАСК (2025-11-09 01:44).
- [~] Combat Combos — подготовить материалы `.BRAIN/02-gameplay/combat/combat-combos-synergies.md` (solo/team/equipment synergies, scoring) для передачи в ДУАПИТАСК (2025-11-09 02:48).
- [ ] Combat Freerun — подготовить brief по `.BRAIN/02-gameplay/combat/combat-freerun.md` (паркур, боевые манёвры) для ДУАПИТАСК (2025-11-09 01:22).
- [!] Player Market Analytics — детализация `.BRAIN/02-gameplay/economy/player-market/player-market-analytics.md`: оформить API контракты витрин, SQL/ETL схемы и финальную матрицу KPI перед передачей в ДУАПИТАСК (2025-11-09 09:34).
- [!] Player Market API — доработать `.BRAIN/02-gameplay/economy/player-market/player-market-api.md`: добавить авторизацию, ошибки, схемы запросов/ответов, событийные потоки и интеграцию с БД/аналитикой перед постановкой задач economy-service (2025-11-09 09:42).
## Low
- [!] Quest 034 Николай II — добавить версию, статус, сценарные зависимости и цели API для передачи в ДУАПИТАСК (2025-11-09 09:35).
- [!] Quest 035 Кунсткамера — расширить структуру, добавить версию/статус, расписать ветвления, награды и целевые API quest-engine перед передачей в ДУАПИТАСК (2025-11-09 09:43).
- [!] Quest 037 Love Hotel — оформить статус/версию/приоритет, расписать ветвления и награды, определить целевые микросервисы и каталоги API перед передачей ДУАПИТАСК (2025-11-09 09:36).
- [!] Quest 035 Имплантная зависимость — привести `.BRAIN/03-lore/_03-lore/timeline-author/quests/cis/moscow/2061-2077/quest-035-implant-addiction.md` к QUEST-TEMPLATE, расписать ветвления лечения, связать с имплантами и подготовить цели API quest-engine/economy (2025-11-09 09:37).
- [!] Granville Island Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-009-granville-island.md`: описать ветвления, NPC, зависимости с quest-engine и KPI наград перед передачей в ДУАПИТАСК (2025-11-09 09:35).
- [!] Most Livable City Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-010-most-livable-city.md`: расписать сценарио, livability KPI, интеграции с экономикой и социальными системами перед постановкой задач (2025-11-09 09:35).
- [!] White House Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-001-white-house.md`: описать контроль доступа, NPC Secret Service, развилки туров и целевые API каталоги quest-engine (2025-11-09 09:35).
- [!] Capitol Building Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-002-capitol-building.md`: структурировать ветви, NPC и события Jan 6, определить интеграции и каталоги API quest-engine (2025-11-09 09:35).
- [!] Lincoln Memorial Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-003-lincoln-memorial.md`: привести к QUEST-TEMPLATE, добавить ветвления, NPC и KPI для интеграции с quest-engine (2025-11-09 09:35).
- [!] Smithsonian Museums Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-004-smithsonian-museums.md`: сформировать маршруты, NPC, KPI и интеграции с образовательными/экономическими системами перед постановкой задач (2025-11-09 09:35).
- [!] Washington Monument Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-005-washington-monument.md`: описать бронирование, очереди, погодные ограничения, NPC и KPI для интеграции с системами туризма/безопасности (2025-11-09 09:35).
- [!] Vietnam Memorial Quest — доработать `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-006-vietnam-memorial.md`: добавить сценарии взаимодействия с ветеранами, моральные выборы, KPI и интеграции с системами эмоций/социальных связей (2025-11-09 09:35).
- [!] Phoenix Urban Sprawl Quest — привести `.BRAIN/03-lore/_03-lore/timeline-author/quests/america/phoenix/2020-2029/quest-010-urban-sprawl.md` к QUEST-TEMPLATE, добавить ветвления, KPI, связи с narrative-service и определить каталоги API/фронтенда перед постановкой задач (2025-11-09 09:36).

---

> Обновляйте статусы: `[ ]` открыто, `[~]` в работе, `[x]` выполнено, `[!]` блокер.

