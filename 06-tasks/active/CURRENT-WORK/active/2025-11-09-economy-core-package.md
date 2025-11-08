# Economy Core Package — Trade & Inventory

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:24  
**Связанные документы:** `.BRAIN/05-technical/backend/trade-system.md`, `.BRAIN/05-technical/backend/inventory-system/part1-core-system.md`

---

## Прогресс
- Перепроверены `trade-system.md` и `inventory-system/part1-core-system.md`: статус `approved`, `api-readiness: ready`, каталоги `api/v1/trade/trade-system.yaml` и `api/v1/inventory/inventory-core.yaml`, фронтенд `modules/economy/trade` и `modules/economy/inventory`.
- Подтверждены зависимости: `authentication-service` (подтверждение сессии), `character-service` (данные персонажа), `inventory-service` (обработчик предметов), `economy-service` (финансовые операции), `analytics-service` (аудит сделок), `anti-cheat-service` (мониторинг подозрительных операций).
- Актуализированы события Event Bus: `trade:started`, `trade:confirmed`, `trade:completed`, `trade:cancelled`, `inventory:item-added`, `inventory:item-removed`, подписки на `character:moved`, `session:ended`, `item:locked`.
- Подготовлена матрица таблиц/хранилищ: `trade_sessions`, `trade_audit_log`, `trade_disputes`, `character_inventory`, `inventory_equipment`, `inventory_transactions`.

---

## Сводка готовности

| Документ | Версия | Статус | API каталог | Фронтенд модуль | Ключевые моменты |
| --- | --- | --- | --- | --- | --- |
| trade-system.md | 1.0.0 | ready | `api/v1/trade/trade-system.yaml` | `modules/economy/trade` | P2P трейд, антифрод, аудит |
| inventory-system/part1-core-system.md | 1.0.1 | ready | `api/v1/inventory/inventory-core.yaml` | `modules/economy/inventory` | слоты, вес, перенос, equipment |

---

## REST задачи (черновик)
- `/trade/sessions/*` — создание, обновление, отмена трейда, подтверждения, журнал.
- `/trade/quotes/*` — предложение/принятие/изменение офферов (items, currency).
- `/trade/history/*` — аудит, фильтры по игрокам, поиски подозрительных сделок.
- `/inventory/items/*` — CRUD предметов в инвентаре, перемещения между контейнерами.
- `/inventory/equipment/*` — экипировка/снятие, проверка ограничений.
- `/inventory/transfer/*` — операции между инвентарём и другими системами (trade, mail, stash).

## WebSocket / Streaming
- `wss://api.necp.game/v1/economy/trade/{sessionId}` — обновление статуса трейда в реальном времени.
- `wss://api.necp.game/v1/economy/inventory/{characterId}` — поток изменений инвентаря (опционально, приоритет ниже).

## Event Bus
- **Публикует:** `trade:started`, `trade:offer-updated`, `trade:completed`, `trade:cancelled`, `inventory:item-added`, `inventory:item-removed`.
- **Подписывается:** `character:moved`, `session:ended`, `item:locked`, `anti-cheat:flagged`, `economy:currency-updated`.

## БД и Migration Notes
- `trade_sessions` — состояние обмена, офферы, подтверждения.
- `trade_audit_log` — история операций с метаданными, IP, device fingerprint.
- `inventory_transactions` — записи перемещений предметов и валюты (для откатов).
- Требуются миграции со ссылками на `characters`, `items`, `currencies`.

---

## Следующие действия
1. Сформировать набор REST/WS эндпоинтов для брифа ДУАПИТАСК (по приоритету: trade sessions → inventory core → аудит).
2. Определить проверки антифрода (лимиты, rate limits, suspicious patterns) и описать требования к API.
3. Подготовить план обновления `implementation-tracker.yaml` после получения слота на задачи.
4. После снятия запрета на API-SWAGGER передать экономический пакет организованной волной (trade + inventory).

---

## История
- 2025-11-09 01:24 — создана заметка, оформлена сводка и план действий.
