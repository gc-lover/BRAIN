---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-150: api/v1/economy/trading-guilds.yaml (2025-11-07 11:02)
- Last Updated: 2025-11-07 00:18
---


# Экономика - Торговые гильдии (Trading Guilds)

**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-07 16:19  
**Приоритет:** высокий (Post-MVP)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 16:19  
**api-readiness-notes:** «Гильдии описаны: создание, капитал, lifecycle, управление, API, аудит, интеграции. Документ готов.»

**target-domain:** economy  
**target-microservice:** economy-service (port 8085)  
**target-frontend-module:** modules/economy/trading-guilds

---

## Краткое описание

Торговые гильдии (Trading Guilds) — организации игроков для совместной торговли.

**Микрофича:** Trading guilds (создание, управление, бонусы)

---

## 🏢 Концепция

**Trading Guild** — гильдия игроков для торговли

**Цели:**
- Объединение капитала
- Торговые бонусы
- Эксклюзивные маршруты
- Совместная прибыль

---

## 💼 Создание гильдии

**Требования:**
```
- Level 30+
- 50,000 eddies (регистрационный взнос)
- 5 founding members
- Guild name (unique)
```

**Процесс:**
```
1. Создать guild (founder)
2. Пригласить 4+ members
3. Заплатить 50,000 eddies
4. Guild активна
```

---

## 🎯 Бонусы гильдии

**Членам:**
- -30% listing fee (auction)
- -20% exchange fee (market)
- +5 auction slots
- Доступ к guild warehouse
- Shared market analytics

**Гильдии:**
- Общий капитал (guild bank)
- Эксклюзивные торговые маршруты
- Guild contracts
- Reputation bonuses

---

## 📊 Управление капиталом

**Guild Bank:**
```
Total capital: 1,000,000 eddies
Contributed by members
Used for:
- Bulk purchases (better prices)
- Guild investments
- Member loans
```

**Profit distribution:**
```
Guild makes 100,000 profit
Distribution:
- 40% to members (by contribution)
- 30% reinvested
- 20% for operations
- 10% to guild leader
```

---

## 🗄️ Структура БД

```sql
CREATE TABLE trading_guilds (
    id UUID PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    
    founder_id UUID NOT NULL,
    leader_id UUID NOT NULL,
    
    total_capital DECIMAL(14,2) DEFAULT 0,
    member_count INTEGER DEFAULT 0,
    reputation_score INTEGER DEFAULT 0,
    headquarters_region VARCHAR(100),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE trading_guild_members (
    guild_id UUID NOT NULL,
    player_id UUID NOT NULL,
    
    role VARCHAR(20) NOT NULL, -- "LEADER", "OFFICER", "MEMBER"
    contribution DECIMAL(12,2) DEFAULT 0,
    voting_power DECIMAL(8,2) DEFAULT 1.0,
    
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (guild_id, player_id)
);

CREATE TABLE trading_guild_bank_transactions (
    id UUID PRIMARY KEY,
    guild_id UUID NOT NULL,
    performed_by UUID NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- DEPOSIT | WITHDRAW | INVEST | PAYROLL
    amount DECIMAL(14,2) NOT NULL,
    currency VARCHAR(8) DEFAULT 'EDDY',
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE trading_guild_routes (
    id UUID PRIMARY KEY,
    guild_id UUID NOT NULL,
    route_id UUID NOT NULL,
    permission_level VARCHAR(16) NOT NULL, -- EXCLUSIVE | PRIORITY | SHARED
    obtained_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE TABLE trading_guild_policies (
    id UUID PRIMARY KEY,
    guild_id UUID NOT NULL,
    policy_key VARCHAR(64) NOT NULL,
    policy_value JSONB NOT NULL,
    updated_by UUID NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔗 Связанные документы

- `economy-overview.md`

---

## 🧭 Lifecycle гильдии

| Фаза | Описание | Ключевые действия |
| --- | --- | --- |
| `FOUNDATION` | Создание, сбор взносов, утверждение хартии | `/guilds/trading` `POST` + капитальные депозиты |
| `ACTIVE` | Торговля, управление капиталом, получение бонусов | регулярные операции и распределение прибыли |
| `ELECTIONS` | Переизбрание лидера/офицеров | `/guilds/trading/{id}/votes` |
| `EXPANSION` | Открытие филиалов, эксклюзивных маршрутов | `routes` API, интеграция с логистикой |
| `DISSOLUTION` | Распуск, распределение активов | `/guilds/trading/{id}/dissolve` |

---

## 🌐 API (economy-service + social-service)

| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/guilds/trading` | `POST` | Создать гильдию (economy-service) |
| `/guilds/trading/{id}` | `GET` | Детали (капитал, бонусы, статус) |
| `/guilds/trading/{id}/members` | `GET/POST/DELETE` | Управление составом |
| `/guilds/trading/{id}/bank/deposit` | `POST` | Взнос в банк гильдии |
| `/guilds/trading/{id}/bank/withdraw` | `POST` | Снятие средств (требует кворум) |
| `/guilds/trading/{id}/policies` | `GET/PATCH` | Настройки комиссий, распределения |
| `/guilds/trading/{id}/votes` | `POST` | Создание голосования (лидер, политика) |
| `/guilds/trading/{id}/routes` | `GET/POST` | Назначение эксклюзивных маршрутов |
| `/guilds/trading/{id}/analytics` | `GET` | Отчёты по обороту и прибыли |

**Event bus (`economy.trading_guilds.*`):** `created`, `member_joined`, `capital_deposited`, `policy_changed`, `profit_distributed`, `election_started`, `election_completed`, `dissolved`.

---

## ⚖️ Управление и аудит

- **Кворум:** вывод средств > 10,000 EDDY требует голосования ≥ 60% voting power.
- **Роли:** `LEADER` (управление политикой), `OFFICER` (операции, маршруты), `TREASURER` (банковские действия), `MEMBER` (ограниченный доступ).
- **Audit log:** каждое действие (банковская операция, изменение политики) фиксируется и доступно регуляторам.
- **Fraud detection:** мониторинг быстрого вывода капитала, автопауза при подозрении.

---

## 📈 Бонусы и лимиты

- Скидки на комиссии зависят от `reputation_score`: base -15%, elite -30%.
- Guild warehouse уровень растёт при обороте > 500k EDDY в месяц.
- Лимит эксклюзивных маршрутов: 3 глобальных, 5 региональных; обновляется через `logistics-service`.

---

## 🔄 Интеграции

- `auction-house`: объединённые слоты и скидки.
- `logistics-service`: управление маршрутами и эскортами для гильдий.
- `economy-contracts`: гильдейские контракты с коллективным эскроу.
- `guild-system` (social-service): общая структура гильдий, репутация.
- `analytics-service`: дашборды оборота, распределение прибыли.

---

## История изменений

- v1.1.0 (2025-11-07 16:19) - Добавлены расширенные таблицы, lifecycle, API, управление и интеграции
- v1.0.0 (2025-11-06 22:00) - Создание документа о торговых гильдиях
## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа о торговых гильдиях
