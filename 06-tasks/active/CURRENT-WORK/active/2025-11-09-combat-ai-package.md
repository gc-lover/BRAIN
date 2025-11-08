# Подготовка пакета для combat AI enemies

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 00:57  
**Связанные документы:** .BRAIN/02-gameplay/combat/combat-ai-enemies.md

---

## Прогресс
- Перепроверены метаданные `.BRAIN/02-gameplay/combat/combat-ai-enemies.md`: статус `approved`, `api-readiness: ready`, актуализирован приоритет `highest`.
- Зафиксированы ключевые REST (`/combat/ai/...`) и WebSocket (`wss://api.necp.game/v1/gameplay/raid/{raidId}`) контракты для дальнейшего разбиения на задачи ДУАПИТАСК.
- Определены зависимости по микросервисам (`world-service`, `social-service`, `economy-service`) и Kafka-топикам (`combat.ai.state`, `world.events.trigger`, `raid.telemetry`).
- Проверено ядро системы проверок `.BRAIN/02-gameplay/combat/combat-dnd-core.md`: подтверждены DC, модификаторы, групповые проверки, добавлено в `ready.md` и `readiness-tracker.yaml`.
- Актуализированы readiness-записи для `combat-abilities`, `combat-stealth`, `combat-freerun` — подтверждён статус `ready`, даты проверки освежены (2025-11-09 01:13), добавлены каталоги `api/v1/gameplay/combat/abilities.yaml`, `api/v1/gameplay/combat/stealth.yaml`, `api/v1/gameplay/combat/freerun.yaml` и соответствующие фронтенд-модули; агрегированная сводка зафиксирована в `2025-11-09-combat-wave-package.md`.

## Материалы и статусы
- `combat-ai-enemies.md` — v1.0.0, `ready`, приоритет `highest`, микросервис `gameplay-service`, модуль `modules/combat/ai`.
- `combat-dnd-core.md` — v1.0.0, `ready`, покрывает DC, модификаторы, преимущества/помехи, целевой каталог `api/v1/gameplay/combat/dnd-core.yaml`.
- `combat-abilities.md` — v1.2.0, `ready`, описывает источники/типы способностей, ограничения, влияние на киберпсихоз; целевой каталог `api/v1/gameplay/combat/abilities.yaml`, модуль `modules/combat/abilities`.
- `combat-stealth.md` — v1.1.0, `ready`, фиксирует каналы обнаружения, импланты, социальную инженерию; целевой каталог `api/v1/gameplay/combat/stealth.yaml`, модуль `modules/combat/stealth`.
- `combat-freerun.md` — v1.1.0, `ready`, определяет паркур и боевые манёвры; целевой каталог `api/v1/gameplay/combat/freerun.yaml`, модуль `modules/combat/movement`.
- Дополнительные зависимости: `combat-combos-synergies.md`, `combat-extract.md`, `combat-hacking-networks.md`, `combat-hacking-combat-integration.md`, `combat-session-backend.md` — все имеют статус `ready` и учтены в очереди.

## Блокеры
- Действует запрет на создание задач в `API-SWAGGER` до отдельного разрешения.

## Черновик пакета для ДУАПИТАСК
- **REST:** `/combat/ai/profiles`, `/combat/ai/profiles/{id}`, `/combat/ai/profiles/{id}/telemetry`, `/combat/raids/{raidId}/phase`, `/combat/ai/encounter`.
- **WebSocket:** `wss://api.necp.game/v1/gameplay/raid/{raidId}` с событиями `PhaseStart`, `MechanicTrigger`, `PlayerDown`, `CheckRequired`.
- **Kafka:** `combat.ai.state`, `world.events.trigger`, `raid.telemetry` — указаны producer/consumer и payload.
- **D&D проверки:** Street REF 15 / TECH 14, Tactical INT 18 / WIS 17, Mythic WIS 20 / TECH 19, Raid INT 22 / STR 21.
- **Схемы БД:** `enemy_ai_profiles`, `enemy_ai_abilities`, `raid_boss_phases` (JSONB поля для поведений и механик).
- **Зависимости:** материалы `combat-extract`, `combat-hacking`, `combat-combos`, `combat-implants`, `combat-session` (все в статусе ready) — обеспечивают связность навыков и телеметрии.

## Следующие действия
1. Оформить бриф ДУАПИТАСК (использовать резюме выше, добавить уровни приоритета и оценки трудозатрат).
2. Приложить список готовых документов (abilities, dnd-core, freerun, combos, hacking, extract) с версиями и целевыми каталогами в виде приложения.
3. Сверить зависимости с другими документами (`combat-extract`, `combat-hacking`, `combat-stealth`) и указать их в итоговом пакете.
4. После разрешения на работу в `API-SWAGGER` подготовить задачу и обновить очереди/трекеры.

