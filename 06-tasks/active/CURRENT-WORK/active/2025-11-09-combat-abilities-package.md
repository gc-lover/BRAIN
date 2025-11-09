# Подготовка пакета для combat abilities

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:42  
**Связанные документы:** `.BRAIN/02-gameplay/combat/combat-abilities.md`

---

## Прогресс
- `combat-abilities.md` перепроверен 2025-11-09 01:42: статус `approved`, `api-readiness: ready`, каталог `api/v1/gameplay/combat/abilities.yaml`, фронтенд `modules/combat/abilities`.
- Зафиксированы источники (дерево прокачки, импланты, экипировка), ранги, cooldown, синергии и влияние на киберпсихоз.
- Собраны зависимости: `combat-implants-types`, `combat-combos-synergies`, `combat-shooting`, `combat-stealth`, `combat-ai-enemies`, `progression-backend`, `quest-engine-backend`.

## REST/Events (черновик)
- **REST:** `/combat/abilities/catalog`, `/combat/abilities/{abilityId}`, `/combat/abilities/loadouts`, `/combat/abilities/synergies`, `/combat/abilities/cooldowns`.
- **Events:** `combat.ability.activated`, `combat.ability.cooldown-started`, `combat.ability.cooldown-finished`, `combat.ability.synergy-triggered`, `combat.ability.cyberpsychosis-updated`.
- **WebSocket (опционально):** `wss://api.necp.game/v1/gameplay/combat/abilities/{sessionId}` для real-time обновлений эффектов.

## Storage
- Таблицы `abilities_catalog`, `ability_loadouts`, `ability_synergies`, `ability_cooldowns`, `ability_effects` (JSONB описание эффектов и модификаторов).

## Следующие действия
1. Декомпозировать REST/Events/WS на задачи для ДУАПИТАСК (описать payload/ответы, связи с другими системами).
2. Зафиксировать список зависимых документов и контракты в приложении к брифу.
3. После разрешения на API-SWAGGER подготовить задачи и обновить очереди/трекеры.

