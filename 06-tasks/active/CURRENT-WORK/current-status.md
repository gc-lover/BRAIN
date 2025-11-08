# Текущий статус активных направлений

**Обновлено:** 2025-11-09 01:04  
**Ответственный:** Brain Manager

---

## Active
- Combat Systems Wave 1 — документы по combat-session, combat-ai-enemies, combat-implants-types, combat-dnd-core, combat-dnd-integration-shooter, combat-abilities, combat-shooting, combat-combos-synergies, combat-extract, combat-freerun, combat-hacking-networks, combat-hacking-combat-integration, combat-cyberspace и arena-system имеют статус ready; готовим единый пакет (`current note: 2025-11-09-combat-ai-package.md`) для передачи в ДУАПИТАСК.
- Economy Core Refresh — trade-system и inventory-system/part1-core-system остаются в приоритете high, необходимо синхронизировать постановку задач с economy-service без запуска в API-SWAGGER самостоятельно.
## Pending
- Auth/Characters/Progression — ждём слот ДУАПИТАСК для задач по auth README, character-management и progression-backend.
- gameplay-service/arena-system — подтвердить приоритет и окно ДУАПИТАСК для `.BRAIN/02-gameplay/combat/arena-system.md` (ready, рейтинговые циклы, `api/v1/gameplay/combat/arena-system.yaml`).
- gameplay-service/dnd-integration-shooter — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-dnd-integration-shooter.md` (ready, микро-проверки, `api/v1/gameplay/combat/dnd-integration-shooter.yaml`).
- gameplay-service/stealth — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-stealth.md` (ready, системы скрытности, `api/v1/gameplay/combat/stealth.yaml`).
- gameplay-service/quests — подготовить пакет задач на основе `.BRAIN/05-technical/backend/quest-engine-backend.md` (ready, quest state machine + D&D checks).
## Blocked
- *(блокеров нет)*

---

> После добавления задач обновите этот файл, синхронизируйте `TODO.md`, `readiness-tracker.yaml` и уведомления для ДУАПИТАСК.

