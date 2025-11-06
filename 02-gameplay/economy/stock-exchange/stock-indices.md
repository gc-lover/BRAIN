# Биржа акций - Фондовые индексы

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:45  
**Приоритет:** средний (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:45

---

## Краткое описание

Фондовые индексы для отслеживания общей динамики рынка.

**Микрофича:** Stock market indices (Corporate Index, Regional Indices)

---

## 📊 Индексы в NECPGAME

### 1. Corporate Index (CORP100)

**Описание:** Главный индекс рынка (топ-100 корпораций)

**Состав:**
- 100 крупнейших корпораций по market cap
- Weighted by market cap
- Rebalanced quarterly

**Calculation:**
```
CORP100 = Σ(price_i × shares_i × weight_i) / divisor

weight_i = market_cap_i / total_market_cap

Пример:
Arasaka: market cap 2.5T / total 10T = 25% weight
Militech: market cap 1.8T / total 10T = 18% weight
Etc.
```

**Current value:**
```
CORP100: 15,234.56 points
24h: +1.2% (↗)
YTD: +18.5%
All-time high: 16,500 (last month)
```

### 2. NC50 (Night City 50)

**Описание:** Индекс корпораций Night City

**Состав:**
- 50 корпораций с HQ в Night City
- Weighted by market cap
- Фокус на локальную экономику

**Value:**
```
NC50: 8,456.23 points
24h: +0.8%
YTD: +22.3% (outperforming CORP100!)
```

### 3. ASIA25 (Asian Corporations)

**Описание:** Азиатские корпорации

**Состав:**
- Arasaka, Kang Tao, и другие азиатские
- 25 корпораций

**Value:**
```
ASIA25: 12,345.67 points
24h: +1.5%
YTD: +16.2%
```

### 4. EURO30 (European Corporations)

**Описание:** Европейские корпорации

**Состав:**
- EBM, Biotechnica, и другие европейские
- 30 корпораций

**Value:**
```
EURO30: 9,876.54 points
24h: +0.3%
YTD: +12.8%
```

### 5. Sector Indices (Секторальные)

**DEFENSE** - оборонные корпорации  
**TECH** - технологические  
**ENERGY** - энергетические  
**MEDICAL** - медицинские  
**CYBER** - cybernetics  

---

## 📈 Использование индексов

### Tracking Market Sentiment

**Bull Market (Растущий):**
```
CORP100: +20% YTD
Sentiment: BULLISH 🟢
Most stocks rising
```

**Bear Market (Падающий):**
```
CORP100: -15% YTD
Sentiment: BEARISH 🔴
Most stocks falling
```

### Index Funds (опционально, Post-MVP)

**Концепция:** Покупать весь индекс одним кликом

**Механика:**
```
Buy CORP100 Index Fund:
- Automatically buys all 100 stocks in proportion
- Instant diversification
- Lower fee (0.5% vs 1%)
- Tracks index performance

Example:
Invest 100,000 eddies in CORP100 Fund
→ Owns small portions of all 100 stocks
→ Returns match CORP100 performance (+18.5% YTD)
```

---

## 🔗 Связанные документы

- `stock-exchange-overview.md`
- `stock-corporations.md`

---

## История изменений

- v1.0.0 (2025-11-06 21:45) - Создание документа об индексах

