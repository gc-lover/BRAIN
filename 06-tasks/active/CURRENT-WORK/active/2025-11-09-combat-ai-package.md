# Подготовка пакета для combat AI enemies

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 00:57  
**Связанные документы:** .BRAIN/02-gameplay/combat/combat-ai-enemies.md

---

## Прогресс
- Подтверждена актуальность `.BRAIN/02-gameplay/combat/combat-ai-enemies.md`; readiness — `ready`, микросервис `gameplay-service`, фронтенд `modules/combat/ai`.
- Зафиксированы ключевые REST (`/combat/ai/...`) и WebSocket (`wss://api.necp.game/v1/gameplay/raid/{raidId}`) контракты для будущего разбиения на API задачи.
- Идентифицированы зависимости по микросервисам (`world-service`, `social-service`, `economy-service`) и Kafka-топикам для учёта в постановке задач.

## Блокеры
- Нет.

## Следующие действия
- Разбить документ на пакет задач ДУАПИТАСК: REST-контракты, WebSocket-события, Kafka-телеметрия.
- Подготовить перечень бизнес-правил и D&D проверок, требующих отдельных контрактов или справочников.
- Уточнить интеграцию с `implementation-tracker.yaml` после получения разрешения на постановку задач.

