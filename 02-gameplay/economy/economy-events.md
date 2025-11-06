---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-154: api/v1/economy/economy-events.yaml (2025-11-07 11:10)
- Last Updated: 2025-11-07 00:18
---


# Экономика - Экономические события

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:00  
**Приоритет:** средний (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 22:00

---

## Краткое описание

Экономические события, влияющие на цены, валюты, рынки.

**Микрофича:** Economic events (кризисы, бум, инфляция, эмбарго)

---

## 📉 Типы событий

### 1. Economic Crisis (Кризис)

**Trigger:** Quest outcome, random event  
**Effect:** Все цены -10-20%

```
Event: "Night City Economic Crisis"
Duration: 2 weeks

Effects:
- All item prices: -15%
- Stock market: -20%
- Currency: EDDY weakens -10%
- Unemployment: +15%

Player impact:
- Goods cheaper (good for buying!)
- Stocks cheaper (buy opportunity!)
- Salary/income lower
```

### 2. Economic Boom (Бум)

**Trigger:** Victory in war, tech breakthrough  
**Effect:** Все цены +10-20%

```
Event: "Corporate War Victory Boom"
Duration: 1 month

Effects:
- All item prices: +15%
- Stock market: +25%
- Currency: EDDY strengthens +10%
- Employment: +20%
```

### 3. Inflation (Инфляция)

**Trigger:** Too much money in economy  
**Effect:** Цены растут постепенно

```
Event: "High Inflation Period"
Duration: 3 months

Effects:
- Prices increase 1% per week
- Total: +12% over 3 months
- Salaries increase slower (+8%)
- Real purchasing power decreases
```

### 4. Trade Embargo (Торговое эмбарго)

**Trigger:** Faction war, political event  
**Effect:** Ограничение торговли

```
Event: "Embargo on Soviet Goods"
Duration: Until war ends

Effects:
- No trade with Soviet regions
- Soviet goods price +50% (scarcity)
- Alternative suppliers +20% (demand)
```

### 5. Sanctions (Санкции)

**Trigger:** Political events  
**Effect:** Ограничения на корпорации

```
Event: "Sanctions on Arasaka"

Effects:
- ARSK stock: -30%
- Arasaka goods +25% (harder to get)
- Competitor stocks +10%
```

### 6. Tariffs (Тарифы)

**Trigger:** Political decisions  
**Effect:** Импортные налоги

```
Event: "Import Tariffs on Asian Goods"

Effects:
- Asian goods +15% (tariff added)
- Local alternatives +5% (demand shift)
- Asian stocks -8%
```

### 7. Corporate Scandals

**См:** `stock-exchange/stock-events.md`

### 8. Technological Breakthroughs

**См:** `stock-exchange/stock-events.md`

---

## 📊 Структура данных

```sql
CREATE TABLE economic_events (
    id UUID PRIMARY KEY,
    
    event_type VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    
    effects JSONB NOT NULL, -- Price modifiers, restrictions
    affected_regions JSONB,
    affected_sectors JSONB,
    
    severity VARCHAR(20), -- "MINOR", "MAJOR", "SEVERE"
    
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔗 Связанные документы

- `stock-exchange/stock-events.md` - События акций
- `economy-world-impact.md` - Влияние на мир

---

## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа об экономических событиях
