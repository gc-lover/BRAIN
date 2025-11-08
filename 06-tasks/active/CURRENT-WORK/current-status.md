# Текущий статус активных направлений

**Обновлено:** 2025-11-09 01:15  
**Ответственный:** Brain Manager

---

## Active
- Combat Systems Wave 1 — документы по combat-session, combat-ai-enemies, combat-implants-types, combat-dnd-core, combat-dnd-integration-shooter, combat-abilities, combat-shooting, combat-combos-synergies, combat-extract, combat-freerun, combat-hacking-networks, combat-hacking-combat-integration, combat-cyberspace и arena-system имеют статус ready; готовим единый пакет (`current note: 2025-11-09-combat-ai-package.md`) для передачи в ДУАПИТАСК; обновлены ссылки на целевые каталоги в `ready.md` и `readiness-tracker.yaml` для AI/arena/D&D интеграции.
- Economy Core Refresh — trade-system и inventory-system/part1-core-system остаются в приоритете high, необходимо синхронизировать постановку задач с economy-service без запуска в API-SWAGGER самостоятельно.
- Quest Engine Package — материал `.BRAIN/05-technical/backend/quest-engine-backend.md` (ready) увязан с `combat-dnd-core.md` и `quest-system.md`; выделены REST точки, Event Bus и схемы хранения, карточка в `ready.md` обновлена; рабочий файл `2025-11-09-quest-engine-package.md` ведёт сводку для будущего пакета ДУАПИТАСК.
## Pending
- Auth/Characters/Progression — ждём слот ДУАПИТАСК для задач по auth README, character-management и progression-backend.
- gameplay-service/arena-system — подтвердить приоритет и окно ДУАПИТАСК для `.BRAIN/02-gameplay/combat/arena-system.md` (ready, рейтинговые циклы, `api/v1/gameplay/combat/arena-system.yaml`).
- gameplay-service/dnd-core — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-dnd-core.md` (ready, ядро проверок, `api/v1/gameplay/combat/dnd-core.yaml`).
- gameplay-service/dnd-integration-shooter — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-dnd-integration-shooter.md` (ready, микро-проверки, `api/v1/gameplay/combat/dnd-integration-shooter.yaml`).
- gameplay-service/abilities — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-abilities.md` (ready, источники и типы способностей, `api/v1/gameplay/combat/abilities.yaml`).
- gameplay-service/freerun — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-freerun.md` (ready, паркур и мобильность, `api/v1/gameplay/combat/freerun.yaml`).
- gameplay-service/stealth — подготовить пакет задач по `.BRAIN/02-gameplay/combat/combat-stealth.md` (ready, системы скрытности, `api/v1/gameplay/combat/stealth.yaml`).
- gameplay-service/quests — финализировать REST/WS декомпозицию для ДУАПИТАСК после утверждения пакета.
## Blocked
- *(блокеров нет)*

---

> После добавления задач обновите этот файл, синхронизируйте `TODO.md`, `readiness-tracker.yaml` и уведомления для ДУАПИТАСК.

