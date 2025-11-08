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
