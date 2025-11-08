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

## Следующие действия
1. Сформировать конспект требований (REST, WebSocket, Kafka, D&D проверки) для передачи ДУАПИТАСК.
2. Сверить связи с документами `combat-extract`, `combat-hacking-networks`, `combat-hacking-combat-integration` и отразить зависимости в пакете.
3. После снятия запрета на работу в `API-SWAGGER` подготовить задачу, обновить очереди и синхронизировать `implementation-tracker.yaml`.

