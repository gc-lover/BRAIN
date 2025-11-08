# Подготовка пакета для quest engine backend

**Приоритет:** critical  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:05  
**Связанные документы:** .BRAIN/05-technical/backend/quest-engine-backend.md, .BRAIN/02-gameplay/combat/combat-dnd-core.md, .BRAIN/04-narrative/quest-system.md

---

## Прогресс
- Перепроверен `.BRAIN/05-technical/backend/quest-engine-backend.md`: статус `approved`, `api-readiness: ready`, целевой каталог `api/v1/gameplay/quests/quest-engine.yaml`, фронтенд `modules/quests`.
- Связаны опорные материалы по D&D проверкам (`combat-dnd-core.md`) и структуре квестов (`quest-system.md`) для ссылок в задачах.
- Сформирована матрица зависимостей: character-service (статы и флаги), economy-service (награды), social-service (репутация), combat-service (килл-триггеры), analytics-service (телеметрия skill checks).
- Зафиксирован набор событий Event Bus: `quest:started`, `quest:objective-completed`, `quest:completed`, `quest:failed`; входящие `combat:enemy-killed`, `item:collected`, `npc:talked`.
- Выписаны REST точки для постановки задач: `POST /api/v1/quests/start`, `GET /api/v1/quests/active`, `POST /api/v1/quests/{id}/dialogue/choice`, `GET /api/v1/quests/{id}/dialogue/current`, `POST /api/v1/quests/{id}/complete`, `POST /api/v1/quests/{id}/abandon`.
- Зафиксированы основные сущности хранения: `quest_instances`, `dialogue_state`, `skill_check_results` (связь с персонажем, состояние диалога, результаты проверок).
- Обновлена очередь `ready.md`: карточка с путём `.BRAIN/05-technical/backend/quest-engine-backend.md` содержит таргет `api/v1/gameplay/quests/quest-engine.yaml` и задание на подготовку пакета для ДУАПИТАСК.

## Резюме для передачи
- **Каталог OpenAPI:** `api/v1/gameplay/quests/quest-engine.yaml` (микросервис `gameplay-service`, порт 8083).
- **Фронтенд:** `modules/quests`.
- **Статус:** `ready`, проверка 2025-11-09 01:03, блокирующих TODO нет.
- **Контекст:** REST, WebSocket, Event Bus, хранилище и зависимости перечислены выше; опорные документы `combat-dnd-core.md`, `quest-system.md`, `quest-engine-backend.md` синхронизированы.
- **Следующий шаг:** подготовить бриф для ДУАПИТАСК (без запуска в API-SWAGGER) и по готовности обновить `ready.md`, `readiness-tracker.yaml`, `current-status.md`.

## Блокеры
- Нет.

## Следующие действия
- Подготовить для ДУАПИТАСК сводку REST/WS/Events + хранение (таблицы, JSON поля) в формате брифа.
- Свести зависимости в отдельный блок (character/economy/social/combat/analytics) и обозначить требования к API контрактам для каждой связки.
- Подготовить приложение с перечнем готовых документов (`combat-dnd-core`, `quest-system`, `quest-engine-backend`) и их версиями.
- Отметить прогресс в `implementation-tracker.yaml` после получения окна на постановку задач.

