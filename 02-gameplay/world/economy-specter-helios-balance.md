# Экономический баланс — Specter & Helios контрактов

**ID документа:** `economy-specter-helios-balance`  
**Тип:** economy-spec  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-08 00:05  
**Приоритет:** высокий  
**Связанные документы:** `specter-hq.md`, `helios-countermesh-ops.md`, `city-unrest-escalations.md`, `guild-contract-board.md`  
**target-domain:** economy/world  
**target-мicroservices:** economy-service, world-service, social-service  
**target-frontend-модули:** modules/economy, modules/world, modules/social  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-08 00:05  
**api-readiness-notes:** Определены формулы и API для баланса Specter/Helios контрактов и беспорядков; готово к реализации.

---
## API Tasks Status

- **Status:** queued
- **Tasks:**
  - API-TASK-266: api/v1/gameplay/economy/specter-helios-balance.yaml (2025-11-08 00:40)
- **Last Updated:** 2025-11-08 00:40

---

## 1. Цель
- Регламентировать денежные потоки и влияние контрактов Specter/Helios и City Unrest на экономику.
- Обеспечить баланс между PvE/PvPvE активностями, гильдейскими валютами и глобальными ресурсами.
- Подготовить данные для economy-service и world-service.

## 2. Валюты и коэффициенты

| Валюта | Источник | Базовый коэффициент | Диапазон модификатора |
|--------|----------|---------------------|-----------------------|
| `specter-favor` | Specter HQ контракты / рейды | 1.0 | 0.8–1.5 (зависит от `city.unrest` и Helios побед) |
| `helios-cred` | Helios Ops | 1.2 | 0.9–1.6 (зависит от `specter-prestige`) |
| `ghost-credits` | Общие события | 1.0 | 0.7–1.3 |
| `underlink-bonds` | Экономические контракты | 1.5 | 1.0–1.8 |

- Формула итогового дохода: `reward = base * modifier_unrest * modifier_faction`.
- При Crisis (`city.unrest 60–79`): `modifier_unrest = 0.85` для Specter, `1.2` для Helios.
- При Cataclysm (`≥ 80`): `modifier_unrest = 0.7` (Specter), `1.4` (Helios), `transport_costs +20%`.

## 3. Контракты Specter — экономика

| Контракт | Базовое вознаграждение | Модификатор (Prestige) | Стоимость запуска | Доп. эффект |
|----------|------------------------|------------------------|-------------------|-------------|
| `intel-countermesh` | 2 `specter-favor`, 500 `ghost-credits` | +0.1 при `specter-prestige` > 200 | 200 `ghost-credits` (орг) | Снижение `helios.alert` -3 |
| `neon-riot response` | 3 `specter-favor`, `underlink-bonds` ×2 | +0.2 при успехе подряд | Нет | Снижение `city.unrest` -12 |
| `specter-parade` | 2 `specter-favor`, `social-trust +4` | ×1.3 при `rep.city.gov ≥ 50` | 1 `specter-crest` (материалы) | Поднимает `specter-prestige` +15 |

- Расходы фиксируются в `economy_contract_costs`.
- Недельный лимит `specter-favor` выдачи — 30 на гильдию; превышение снижает модификатор до 0.4.

## 4. Helios Ops — экономика

| Операция | Награды | Стоимость | Модификатор (`specter-prestige`) | Последствия |
|----------|---------|-----------|---------------------------------|-------------|
| `CM-Viper` | 1 500 `helios-cred`, `helios-alloy` | 500 `helios-cred` (логистика) | ×1.1 при `specter-prestige < 80` | `city.unrest +6` при успехе |
| `CM-Aegis` | 2 300 `helios-cred`, `countermesh-alloy` | 800 `helios-cred` | ×1.0 | Снижает стоимость Helios магазинов на 10% |
| `CM-Phalanx` | 3 000 `helios-cred`, шанс `helios-mythic-core` | 1 200 `helios-cred` | ×0.8 при высоком Specter prestige | Победа → `specter-hq store slots -1` |

- Helios расходы учитываются в `helios_ops_expenses`; при провале операции возмещается 40% затрат.

## 5. City Unrest → экономика
- При `unrest ≥ 40`: `transport_cost` = `base * 1.1`; `market_tax` = `base * 1.05`.
- При Crisis: `market_tax` = `base * 1.15`; `social_service_cost` = `base * 1.2`.
- При Cataclysm: `some vendors closed`, время доставки +50%.
- Успешная стабилизация (неон- riot) снижает налоги на 3% на 48 часов.

## 6. API задачи
- Economy-service:
  - `GET /api/v1/economy/contracts/balance` — возвращает текущие коэффициенты.
  - `POST /api/v1/economy/contracts/apply-reward` — учитывает модификаторы.
  - `POST /api/v1/economy/contracts/cost` — списывает ресурсы.
- World-service:
  - `GET /api/v1/world/city-unrest/modifiers`.
  - `POST /api/v1/world/faction-modifiers/update`.
- Events: `ECONOMY_CONTRACT_REWARD`, `ECONOMY_CONTRACT_COST`, `MARKET_TAX_UPDATE`.

## 7. SQL и хранение
- `contract_balance(guild_id, contract_id, issued_at, reward, modifier_unrest, modifier_faction)`.
- `faction_modifiers(faction, market_tax, transport_cost, store_discount, updated_at)`.
- `economy_unrest_history(level, delta, applied_at)`.

## 8. Телеметрия
- Metrics: `total_specter_favor_spent`, `helios_cred_earned`, `unrest_tax_impact`.
- Events: `economy_balance_applied`, `economy_modifier_updated`.
- Grafana: `specter-helios-economy`, `city-unrest-tax`, `contract-earnings`.

## 9. История изменений
- 2025-11-08 00:05 — Определён экономический баланс Specter/Helios контрактов и городских беспорядков.

