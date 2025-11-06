---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-153: api/v1/economy/investments.yaml (2025-11-07 11:08)
- Last Updated: 2025-11-07 00:18
---


# Экономика - Инвестиции

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:00  
**Приоритет:** средний (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 22:00

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
CREATE TABLE player_investments (
    id UUID PRIMARY KEY,
    player_id UUID NOT NULL,
    
    investment_type VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    
    expected_return_percent DECIMAL(5,2),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    matures_at TIMESTAMP
);
```

---

## 🔗 Связанные документы

- `stock-exchange/` - Акции
- `economy-overview.md`

---

## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа об инвестициях
