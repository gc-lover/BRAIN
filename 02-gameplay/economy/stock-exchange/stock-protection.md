# Биржа акций - Защита от манипуляций

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:45  
**Приоритет:** высокий (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:45

---

## Краткое описание

Защита биржи от манипуляций и мошенничества.

**Микрофича:** Anti-manipulation, circuit breakers, insider trading detection

---

## 🛡️ Механизмы защиты

### 1. Circuit Breakers (Остановка торгов)

**Trigger:** Падение/рост ≥ 15% за 1 час

**Действия:**
```
ARSK: 1,000 → 850 (-15%) in 30 minutes
→ CIRCUIT BREAKER TRIGGERED!
→ Trading HALTED for 15 minutes
→ Cooldown period
→ Trading resumes

Purpose: Prevent panic selling/buying
```

### 2. Price Limits (Ценовые лимиты)

**Daily limits:**
```
Max change per day: ±20%

If ARSK opens @ 1,000:
Max price: 1,200 (+20%)
Min price: 800 (-20%)

If price hits limit: trading paused до next day
```

### 3. Insider Trading Detection

**Flags:**
- Buying before positive quest outcomes
- Selling before negative quest outcomes
- Unusual timing patterns

**Penalty:**
- Investigation
- Profit confiscation
- Ban from stock exchange

---

## 🔗 Связанные документы

- `stock-trading.md`

---

## История изменений

- v1.0.0 (2025-11-06 21:45) - Создание документа о защите

