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

## Блокеры
- Нет.

## Следующие действия
- Подготовить для ДУАПИТАСК сводку REST/WS/Events + хранение (таблицы, JSON поля) в формате брифа.
- Свести зависимости в отдельный блок (character/economy/social/combat/analytics) и обозначить требования к API контрактам для каждой связки.
- Отметить прогресс в `implementation-tracker.yaml` после получения окна на постановку задач.

