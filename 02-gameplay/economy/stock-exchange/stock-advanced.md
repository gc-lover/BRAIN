# Биржа акций - Продвинутые механики

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:45  
**Приоритет:** низкий (Expansion)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:45

---

## Краткое описание

Продвинутые механики торговли акциями (Post-MVP, для экспертов).

**Микрофича:** Short selling, margin trading, options, futures

---

## 📉 Short Selling (Короткая продажа)

### Концепция

**Short Selling** — продажа акций, которые не владеешь, в надежде на падение цены.

**Механика:**
```
1. Borrow shares (от брокера)
2. Sell borrowed shares (по текущей цене)
3. Wait for price drop
4. Buy back shares (по низкой цене)
5. Return borrowed shares
6. Profit = sell price - buy back price - fees
```

**Пример:**
```
ARSK current: 1,000 eddies

Player thinks: "ARSK will drop after scandal quest"

Action:
1. Short 100 ARSK @ 1,000 (borrow & sell)
   Proceeds: 100,000 eddies (held in escrow)
   
2. Quest happens: scandal exposed
   ARSK drops to 700 (-30%)
   
3. Buy back 100 ARSK @ 700
   Cost: 70,000 eddies
   
4. Return shares to broker

Profit: 100,000 - 70,000 - fees = ~29,000 eddies (29% profit!)
```

**Risks:**
```
If price RISES instead of falls:
ARSK: 1,000 → 1,300 (+30%)

Player must buy back @ 1,300:
Loss: -30,000 eddies (-30%)

UNLIMITED LOSS potential! (price can rise infinitely)
```

---

## 📈 Margin Trading (Торговля с плечом)

### Концепция

**Margin** — займ от брокера для увеличения покупательной способности.

**Leverage levels:**
```
2x leverage: Borrow 100% (купить в 2 раза больше)
5x leverage: Borrow 400% (купить в 5 раз больше)
10x leverage: Borrow 900% (HIGH RISK!)
```

**Пример с 2x leverage:**
```
Player capital: 100,000 eddies
Leverage: 2x
Buying power: 200,000 eddies

Buy 200 ARSK @ 1,000 = 200,000 eddies
Own: 50,000 eddies
Borrowed: 150,000 eddies (margin debt)

Interest rate: 5%/year on borrowed

If ARSK → 1,100 (+10%):
Portfolio: 220,000 eddies
Debt: 150,000 eddies
Equity: 70,000 eddies
Profit: 20,000 eddies (40% return on capital!)

If ARSK → 900 (-10%):
Portfolio: 180,000 eddies
Debt: 150,000 eddies
Equity: 30,000 eddies
Loss: -20,000 eddies (-40% on capital!)

AMPLIFIED gains AND losses!
```

**Margin Call:**
```
If equity falls below 30% of portfolio:
→ MARGIN CALL!
→ Must deposit more capital OR
→ Broker auto-sells stocks to cover debt

Example:
Portfolio: 180,000 eddies (ARSK @ 900)
Debt: 150,000 eddies
Equity: 30,000 eddies (16.7% of portfolio)

← MARGIN CALL! (below 30%)

Options:
1. Deposit 25,000 eddies (increase equity to 30%+)
2. Let broker sell 100 shares @ 900
   → Proceeds: 90,000 - debt 150,000 = -60,000
   → Wipe out, lose all capital
```

---

## 🎯 Requirements

**Short Selling:**
- Level 45+
- Trading volume 500k+ eddies/month
- Collateral: 150% of short value

**Margin Trading:**
- Level 40+
- Trading volume 250k+ eddies/month
- Credit check (no recent margin calls)

---

## 🔗 Связанные документы

- `stock-trading.md` - Базовая торговля

---

## История изменений

- v1.0.0 (2025-11-06 21:45) - Создание документа о продвинутых механиках

