# Подготовка пакета для Economy Core

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:35  
**Связанные документы:**  
- `.BRAIN/05-technical/backend/trade-system.md`  
- `.BRAIN/05-technical/backend/inventory-system/part1-core-system.md`

---

## Прогресс
- Перепроверены `trade-system.md` и `inventory-system/part1-core-system.md` — подтверждён статус `ready`, указаны каталоги `api/v1/economy/trade/trade-system.yaml` и `api/v1/inventory/inventory-core.yaml`, фронтенд модули `modules/economy/trade` и `modules/economy/inventory`.
- Уточнены зависимости: взаимодействие economy-service с inventory-service, character-service, world-service и аналитикой; события `trade:started/completed/cancelled`, интеграция с transfer предметов.
- Сверены записи в `ready.md` и `readiness-tracker.yaml` — приоритет high, актуализирована дата проверки 2025-11-09 01:30.

## Задачи для брифа
- REST-контракты P2P трейда: создание/обновление trade session, подтверждение, отмена, аудит.
- REST-контракты инвентаря: CRUD по слотам, перенос предметов, проверка веса/лимитов, банк/стэш.
- Event Bus контракты и antifraud: события трейда, проверки расстояния, блокировка предметов.
- Справочники ограничений (bind rules, категории предметов) и связь с имплантами/квестами.

## Блокеры
- Требуется согласование окна для economy-service перед передачей ДУАПИТАСК; до подтверждения API-SWAGGER не трогаем.

## Следующие действия
1. Сформировать бриф ДУАПИТАСК: оценка трудозатрат, разбиение задач (trade REST, inventory REST, events/antifraud, справочники).
2. Подготовить список связанных документов (Part 2 inventory, mail/auction зависимости) и отметить их статус (при необходимости — `needs-work`).
3. Обновить `current-status.md` и `TODO.md`, синхронизировать `readiness-tracker.yaml` при появлении новых зависимостей.
# Подготовка пакета для economy core (inventory + trade)

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:30  
**Связанные документы:** `.BRAIN/05-technical/backend/inventory-system/part1-core-system.md`, `.BRAIN/05-technical/backend/trade-system.md`

---

## Прогресс
- Инвентарь (`inventory-system/part1-core-system.md`) перепроверен 2025-11-09 01:30: подтверждены CRUD, equipment, weight, stash; каталог `api/v1/inventory/inventory-core.yaml`, фронтенд `modules/economy/inventory`.
- Торговля (`trade-system.md`) перепроверена 2025-11-09 01:30: подтверждены double-confirmation flow, антифрод, события; каталог `api/v1/trade/trade-system.yaml`, фронтенд `modules/economy/trade`.
- Уточнены зависимости: inventory-service (economy), character-service, world-service (distance), analytics-service (trade telemetry), mail/auction интеграции.

## Требования к пакетам задач (черновик)
- **Inventory REST:** `/inventory/slots`, `/inventory/items`, `/inventory/equipment`, `/inventory/stash`, `/inventory/transfer`.
- **Inventory Events:** `inventory:item-added`, `inventory:item-removed`, `inventory:weight-updated`.
- **Trade REST:** `/trade/sessions`, `/trade/sessions/{sessionId}/offers`, `/trade/sessions/{sessionId}/confirm`, `/trade/history`.
- **Trade Events:** `trade:started`, `trade:confirmation-requested`, `trade:completed`, `trade:cancelled`, `trade:fraud-flagged`.
- **Storage:** таблицы `inventories`, `inventory_items`, `equipment_slots`, `trade_sessions`, `trade_audit`.

## Следующие действия
1. Разложить inventory/trade на отдельные задачи для ДУАПИТАСК (REST, events, схемы БД).
2. Зафиксировать зависимости с economy-service (порт 8085) и фронтендом (`modules/economy/*`) в итоговом брифе.
3. Обновить `TODO.md` и `current-status.md` после подготовки пакета; ожидать разрешения на передачу в API-SWAGGER.
