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
1. Сформировать краткое резюме требований (REST, WebSocket, Kafka потоки, D&D проверки) для передачи ДУАПИТАСК.
2. Сверить зависимости с другими документами (`combat-extract`, `combat-hacking`) и указать их в итоговом пакете.
3. После разрешения на работу в `API-SWAGGER` подготовить задачу и обновить очереди/трекеры.

