# Подготовка пакета для combat D&D core

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:44  
**Связанные документы:** `.BRAIN/02-gameplay/combat/combat-dnd-core.md`

---

## Прогресс
- `combat-dnd-core.md` перепроверен 2025-11-09 01:44: статус `approved`, `api-readiness: ready`, каталог `api/v1/gameplay/combat/dnd-core.yaml`, фронтенд `modules/combat/mechanics`.
- Подтверждены формулы DC, модификаторы, преимущества/помехи, групповые проверки, связь с атрибутами и навыками.
- Собраны зависимости: `quest-engine-backend`, `combat-dnd-integration-shooter`, `combat-abilities`, `combat-stealth`, `combat-hacking-networks`, `progression-backend`, `economy` (лут/таблицы).

## REST/Events (черновик)
- **REST:** `/combat/dnd-core/checks`, `/combat/dnd-core/modifiers`, `/combat/dnd-core/groups`, `/combat/dnd-core/advantage`, `/combat/dnd-core/config`.
- **Events:** `dnd.check.requested`, `dnd.check.resolved`, `dnd.modifier.applied`, `dnd.advantage.triggered`, `dnd.groupcheck.started`.
- **Integration Hooks:** REST webhook для `quest-engine-backend` и `combat-dnd-integration-shooter` (микро-проверки).

## Storage
- Таблицы `dnd_checks`, `dnd_modifiers`, `dnd_group_checks`, `dnd_advantage`, `dnd_config` (JSONB для параметров).

## Следующие действия
1. Декомпозировать REST/Events на задачи для ДУАПИТАСК, описать payload/ответы.
2. Зафиксировать интеграции с квестами, боем и экономикой в приложении к брифу.
3. После разрешения на API-SWAGGER подготовить пакет задач и обновить очереди/трекеры.

