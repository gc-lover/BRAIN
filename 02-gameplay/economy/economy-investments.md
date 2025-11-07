---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-153: api/v1/economy/investments.yaml (2025-11-07 11:08)
- Last Updated: 2025-11-07 00:18
---


# Экономика - Инвестиции

**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-07 16:19  
**Приоритет:** средний (Post-MVP)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 16:19  
**api-readiness-notes:** «Добавлены lifecycle, портфель, API, отчётность и интеграции. Инвестиционный модуль готов к API.»

**target-domain:** economy  
**target-microservice:** economy-service (port 8085)  
**target-frontend-module:** modules/economy/investments

---

## Краткое описание

Система инвестиций в корпорации, фракции, регионы, недвижимость.

**Микрофича:** Investments (diversification, portfolio, ROI)

---

## 💼 Типы инвестиций

### 1. Corporate Stocks
**См:** `stock-exchange/`
- Акции корпораций
- Дивиденды 4-7%
- Capital appreciation

### 2. Faction Bonds
**Облигации фракций**

```
Arasaka 5-year Bond
- Investment: 10,000 eddies
- Interest: 6% annual
- Maturity: 5 years
- Total return: 13,000 eddies (30% over 5y)

Risk: If faction loses war, bond defaults
```

### 3. Real Estate
**Недвижимость**

```
Buy apartment in Night City:
Price: 100,000 eddies
Rental income: 500 eddies/month (6%/year)
Appreciation: +5% per year (avg)

Total return: 11%/year
```

### 4. Production Chains
**Инвестиции в производство**

```
Invest in weapon factory:
Capital: 50,000 eddies
Profit share: 10% of production
Expected: 500-1,000 eddies/month

ROI: 12-24% per year
Risk: Factory can be destroyed (quest)
```

### 5. Commodity Speculation
**Спекуляция товарами**

```
Buy 1,000 Health Boosters @ 2.0 = 2,000 eddies
Wait for price increase
Sell @ 2.5 = 2,500 eddies
Profit: 500 eddies (25%)

Risk: Price may drop instead
```

---

## 📊 Portfolio Management

**Diversification:**
```
Total portfolio: 100,000 eddies

Allocation:
- Stocks: 40,000 (40%) - growth
- Bonds: 20,000 (20%) - stability
- Real Estate: 30,000 (30%) - passive income
- Commodities: 10,000 (10%) - speculation

Risk level: Medium
Expected return: 8-12%/year
```

---

## 📈 Risk Analysis

**Low Risk:**
- Faction bonds (if strong faction)
- Real estate
- Blue chip stocks
- Return: 4-6%/year

**Medium Risk:**
- Mixed portfolio
- Mid-cap stocks
- Production chains
- Return: 8-12%/year

**High Risk:**
- Growth stocks
- Commodity speculation
- Margin trading
- Return: 15-30%/year (or loss!)

---

## 🗄️ Структура БД

```sql
CREATE TABLE investment_products (
    id UUID PRIMARY KEY,
    product_type VARCHAR(32) NOT NULL, -- STOCK | BOND | REAL_ESTATE | PRODUCTION | COMMODITY_FUND
    reference_id UUID, -- ссылка на корпорацию, регион, недвижимость
    name VARCHAR(200) NOT NULL,
    risk_level VARCHAR(16) NOT NULL,
    base_return_percent DECIMAL(5,2) NOT NULL,
    currency VARCHAR(8) DEFAULT 'EDDY',
    metadata JSONB -- индивидуальные параметры (капитализация, collateral и т.д.)
);

CREATE TABLE player_investment_positions (
    id UUID PRIMARY KEY,
    player_id UUID NOT NULL,
    product_id UUID NOT NULL REFERENCES investment_products(id),
    purchase_amount DECIMAL(14,2) NOT NULL,
    quantity DECIMAL(12,4) NOT NULL,
    avg_price DECIMAL(12,4) NOT NULL,
    leverage_ratio DECIMAL(4,2) DEFAULT 1.0,
    opened_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closes_at TIMESTAMP,
    status VARCHAR(16) NOT NULL DEFAULT 'OPEN'
);

CREATE TABLE investment_transactions (
    id UUID PRIMARY KEY,
    position_id UUID NOT NULL REFERENCES player_investment_positions(id),
    transaction_type VARCHAR(16) NOT NULL, -- BUY | SELL | DIVIDEND | INTEREST | RENTAL
    amount DECIMAL(14,2) NOT NULL,
    currency VARCHAR(8) DEFAULT 'EDDY',
    occurred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

CREATE TABLE investment_portfolio_snapshots (
    id UUID PRIMARY KEY,
    player_id UUID NOT NULL,
    total_value DECIMAL(16,2) NOT NULL,
    cash_balance DECIMAL(14,2) NOT NULL,
    risk_score DECIMAL(5,2) NOT NULL,
    diversification_index DECIMAL(5,2) NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔗 Связанные документы

- `stock-exchange/` - Акции
- `economy-overview.md`

---

## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа об инвестициях
