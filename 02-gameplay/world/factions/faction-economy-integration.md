---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:05  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:05  
**api-readiness-notes:** Экономическая экосистема фракций: награды, рынки, аукционы, крафт и интеграция с economy-service.
---

# Faction Economy Integration — Рынки и награды

**target-domain:** gameplay-economy/factions  
**target-microservice:** economy-service (8085), world-service (8086)  
**target-frontend-module:** modules/economy/trade  
**интеграции:** auctions, crafting, logistics, social reputation

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-276: api/v1/gameplay/economy/factions/assets.yaml (2025-11-08 02:05)
- Last Updated: 2025-11-08 02:05
---

## 1. Цели
- Связать фракционные награды с экономическими подсистемами.
- Описать новые активы (облигации, моды, ресурсы) и их поток между аукционами и крафтом.
- Настроить обмен репутации на скидки, налоги и доступ к перевозкам.

## 2. Новые экономические объекты
| Фракция | Актив | Тип | Влияние |
| --- | --- | --- | --- |
| Aeon Dynasty | orbital-bond | Финансовый инструмент | Даёт % скидку на орбитальные поставки, торгуется на аукционе |
| Crescent Energy | solar-catalyst | Ресурс | Ускоряет крафт энергетических имплантов |
| Mnemosyne Archives | memory-fragment | Легендарный лут | Используется для моддинга companion ИИ |
| Ember Saints | pyre-mod | Имплант модуль | Усиляет огненный урон, повышает риск киберпсихоза |
| Basilisk Sons | mech-armor-plate | Компонент | Улучшения для Nomad транспорта |
| Quantum Fable | 
arrative-token | Коллекционный предмет | Открывает альтернативные концовки квестов |
| Echo Dominion | metanet-license | Доступ | Снижает комиссию на сетевых рынках |

## 3. Потоки экономики
1. Завершение контрактов → выдача активов → POST /economy/rewards.
2. Игроки продают активы на аукционе (/economy/auction/listing).
3. Крафт использует активы (например, solar-catalyst) через /economy/crafting/session.
4. Перевозки Nomad используют mech-armor-plate, обновляя логистику (/world/logistics/routes).

## 4. Налоги и скидки
- Репутация фракций изменяет налог на сделки (	ax_modifiers).
- 
ep.corp.aeon >= 40 → 	rade_tax.orbital = base - 5%.
- 
ep.street.ember < -10 → вводится штраф за продажу pyre-mod.

## 5. REST/WS Контуры
| Endpoint | Метод | Назначение |
| --- | --- | --- |
| /economy/factions/assets | GET | Список активов, источники и цены |
| /economy/factions/assets/{id} | GET | Детали актива, использование |
| /economy/factions/assets/{id}/redeem | POST | Обмен актива на бонусы |
| /economy/factions/trade-modifiers | GET | Таблица налогов и скидок по репутациям |

**WebSocket:** wss://economy-service/factions — AssetIssued, AuctionFilled, TaxUpdated.

## 6. Схемы данных
`sql
CREATE TABLE faction_assets (
    asset_id VARCHAR(64) PRIMARY KEY,
    faction_id VARCHAR(64) NOT NULL,
    asset_type VARCHAR(32) NOT NULL,
    description TEXT NOT NULL,
    base_value NUMERIC(12,2) NOT NULL,
    usage_hooks JSONB NOT NULL,
    reputation_requirements JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faction_trade_modifiers (
    faction_id VARCHAR(64) NOT NULL,
    reputation_threshold INTEGER NOT NULL,
    discount_percent NUMERIC(5,2),
    tax_percent NUMERIC(5,2),
    logistics_bonus JSONB,
    PRIMARY KEY (faction_id, reputation_threshold)
);
`

## 7. Готовность
- Экономические потоки связаны с контрактами, рейдами и социальными линиями.
- Документ готов к реализации в economy-service и world-service.
