# Биржа акций - Торговля акциями

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:45  
**Приоритет:** высокий (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:45

---

## Краткое описание

Механики торговли акциями на бирже NECPGAME.

**Микрофича:** Торговля акциями (buy/sell, orders, execution)

---

## 💰 Типы ордеров

### Market Order (Рыночный)

**Описание:** Покупка/продажа по текущей рыночной цене

**Механика:**
```
Player places: BUY 100 ARSK (Market Order)
Current best ask: 1,000 eddies

→ Instant execution @ 1,000
→ Total cost: 100,000 eddies + broker fee (1%) = 101,000 eddies
→ Shares добавляются в portfolio instantly
```

**Когда использовать:**
- Нужна срочная покупка/продажа
- Готов принять текущую цену
- Ликвидный stock (low spread)

### Limit Order (Лимитный)

**Описание:** Покупка/продажа по указанной цене или лучше

**Механика:**
```
Player places: BUY 100 ARSK @ 950 eddies (Limit)
Current best ask: 1,000 eddies

→ Order placed in book (waiting)
→ Funds escrowed: 100 × 950 + broker fee = 95,950 eddies
→ Executes when price drops to 950 or below
```

**Когда использовать:**
- Хочешь определенную цену
- Готов ждать
- Защита от проскальзывания (slippage)

---

## 📊 Исполнение ордеров

### Order Matching

**Алгоритм:**
```
Priority:
1. Price (best price first)
2. Time (earlier order first)
3. Quantity (large orders may split)
```

**Пример:**
```
Order Book для ARSK:

SELL:
1,020 | 50 shares (Player A, 2 days ago)
1,020 | 30 shares (Player B, 1 day ago)
1,010 | 100 shares (Player C, 1 hour ago)
1,000 | 200 shares (Player D, just now)

BUY:
 980 | 100 shares (Player E)
 970 | 200 shares (Player F)

Player G places: MARKET BUY 150 shares
→ Matches with best sell (1,000)
→ Buys 150 from Player D @ 1,000
→ Player D has 50 shares left @ 1,000
```

### Partial Fill

**Механика:**
```
SELL 100 ARSK @ 1,050 (Limit)

Day 1: 30 shares sold @ 1,050 → 70 remaining
Day 2: 40 shares sold @ 1,050 → 30 remaining
Day 3: 30 shares sold @ 1,050 → FILLED

Total proceeds: 105,000 eddies
Broker fee (1%): 1,050 eddies
Net: 103,950 eddies
```

---

## 💳 Комиссии

### Broker Fee (Комиссия брокера)

**Для всех сделок:**
```
broker_fee = trade_value × 1%

Пример:
Buy 100 ARSK @ 1,000 = 100,000 eddies
Broker fee: 1,000 eddies
Total: 101,000 eddies
```

**Модификаторы:**
```
VIP membership: -25% (0.75%)
High trading volume (1M+/month): -30% (0.7%)
Trading guild member: -20% (0.8%)

Max discount: -50% (0.5% min fee)
```

### Exchange Fee (Комиссия биржи)

**Для листинга (платит корпорация, не игрок):**
```
Annual listing fee: 0.1% of market cap
```

### No Additional Fees

**Что НЕ платят игроки:**
- ❌ Listing fee (только broker fee)
- ❌ Sales tax (акции не облагаются)
- ❌ Withdrawal fee (нет комиссии за вывод)

**Почему дешевле:**
- Stock trading комиссия: 1% (только broker fee)
- Auction House: 2% listing + 5% sales = 7%
- Player Market: 0-1% listing + 3% exchange = 3-4%

**Итог:** Stock trading САМЫЙ ДЕШЕВЫЙ (1%)

---

## 📈 Размещение ордера

### Buy Order UI

```
┌─────────────────────────────────────────────────────────┐
│ BUY STOCKS: Arasaka Corporation (ARSK)                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Current Price: 1,000 eddies (↗ +2.5%)                  │
│ Best Ask: 1,000 | Best Bid: 995                         │
│                                                         │
│ Order Type:                                             │
│ ● Market (instant @ 1,000)                              │
│ ○ Limit  @ [_____] eddies                               │
│                                                         │
│ Quantity: [100] shares                                  │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ COST BREAKDOWN:                                         │
│ Shares: 100 × 1,000 = 100,000 eddies                    │
│ Broker fee (1%): 1,000 eddies                           │
│ ─────────────────────────────────────────────────────── │
│ Total: 101,000 eddies                                   │
│                                                         │
│ Your balance: 250,000 eddies ✓                          │
│ After purchase: 149,000 eddies                          │
│                                                         │
│ INVESTMENT INFO:                                        │
│ Annual dividend: ~4,000 eddies (4.0% yield)             │
│ Payback period: ~25 years (from dividends only)         │
│                                                         │
│ [Cancel]  [Confirm Purchase]                            │
└─────────────────────────────────────────────────────────┘
```

### Sell Order UI

```
┌─────────────────────────────────────────────────────────┐
│ SELL STOCKS: Arasaka Corporation (ARSK)                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Your holdings: 100 shares                               │
│ Avg buy price: 1,010 eddies                             │
│ Current price: 1,050 eddies (↗ +4.0%)                   │
│ Unrealized profit: 4,000 eddies (+4.0%)                 │
│                                                         │
│ Order Type:                                             │
│ ● Market (instant @ 1,050)                              │
│ ○ Limit  @ [_____] eddies                               │
│                                                         │
│ Quantity: [100] shares (max: 100)                       │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ PROCEEDS:                                               │
│ Shares: 100 × 1,050 = 105,000 eddies                    │
│ Broker fee (1%): 1,050 eddies                           │
│ ─────────────────────────────────────────────────────── │
│ Net proceeds: 103,950 eddies                            │
│                                                         │
│ PROFIT/LOSS:                                            │
│ Cost basis: 101,000 eddies                              │
│ Sale proceeds: 103,950 eddies                           │
│ Realized profit: 2,950 eddies (+2.9%)                   │
│ Dividends received: 4,000 eddies (held 1 year)          │
│ ─────────────────────────────────────────────────────── │
│ Total return: 6,950 eddies (+6.9%)                      │
│                                                         │
│ [Cancel]  [Confirm Sale]                                │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Portfolio Management

### My Portfolio

```
┌──────────────────────────────────────────────────────────────┐
│ MY STOCK PORTFOLIO                                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ Total Value: 215,500 eddies (↗ +7.8% all time)              │
│ Cost Basis: 200,000 eddies                                   │
│ Unrealized Profit: 15,500 eddies (+7.8%)                     │
│ Annual Dividends: ~8,200 eddies (4.1% yield)                 │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐   │
│ │ Ticker │ Shares │ Avg Price │ Current │ Profit │ %    │   │
│ ├────────────────────────────────────────────────────────┤   │
│ │ ARSK   │ 100    │ 1,010     │ 1,050   │ +4,000 │ +4%  │   │
│ │ MLTC   │ 80     │ 860       │ 900     │ +3,200 │ +4.7%│   │
│ │ TRMA   │ 50     │ 640       │ 680     │ +2,000 │ +6.3%│   │
│ │ TSUN   │ 100    │ 105       │ 150     │ +4,500 │ +43% │   │
│ │ BIOT   │ 40     │ 490       │ 480     │ -400   │ -2%  │   │
│ └────────────────────────────────────────────────────────┘   │
│                                                              │
│ Diversification: 5 stocks ✓                                  │
│ Risk Level: Medium                                           │
│                                                              │
│ [Buy More] [Sell] [Rebalance] [Analytics]                    │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔒 Ограничения торговли

### Лимиты для игроков

**По уровню:**
```
Level 1-20:  Can trade Tier 3 & Growth only
Level 21-30: Can trade Tier 2, 3, Growth
Level 31-40: Can trade Tier 1, 2, 3, Growth
Level 41+:   Can trade all + access to advanced (short, margin)
```

**По репутации:**
```
Preferred Stock requirements:
- Arasaka Preferred: Arasaka rep ≥ 50
- Militech Preferred: Militech rep ≥ 50
Etc.
```

**Quantity limits:**
```
Max ownership per corporation:
- Tier 1: 10% of public float (whale protection)
- Tier 2: 15% of public float
- Tier 3: 20% of public float
- Growth: 30% of public float

If exceed: warning + block further purchases
```

### Trading Hours

**Stock Exchange hours:**
```
Open: 09:00 AM (игровое время)
Close: 05:00 PM (игровое время)

Mon-Fri: Trading active
Sat-Sun: Closed (накапливаются ордера, исполняются в понедельник)

Holidays: Closed (game events may trigger holidays)
```

**Pre-market / After-hours:**
```
Pre-market: 07:00-09:00 (ограниченная ликвидность)
After-hours: 05:00-08:00 (ограниченная ликвидность)

Spreads шире в pre/after hours
```

---

## 📊 Структура данных

### Stock Orders

```sql
CREATE TABLE stock_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Order info
    order_type VARCHAR(10) NOT NULL, -- "BUY", "SELL"
    execution_type VARCHAR(10) NOT NULL, -- "MARKET", "LIMIT"
    
    -- Stock
    corporation_id VARCHAR(100) NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    
    -- Quantity
    quantity INTEGER NOT NULL,
    quantity_filled INTEGER DEFAULT 0,
    quantity_remaining INTEGER NOT NULL,
    
    -- Price
    limit_price DECIMAL(12,2), -- For limit orders
    average_fill_price DECIMAL(12,2), -- Avg price of filled portions
    
    -- Player
    player_id UUID NOT NULL,
    
    -- Escrow
    escrowed_amount DECIMAL(12,2) NOT NULL, -- Money (buy) or shares (sell)
    broker_fee DECIMAL(12,2) NOT NULL,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, ACTIVE, FILLED, CANCELLED, EXPIRED
    
    -- Time
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activated_at TIMESTAMP, -- When market opens (if placed outside hours)
    filled_at TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_stock_order_player FOREIGN KEY (player_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_order_corporation FOREIGN KEY (corporation_id) REFERENCES stock_corporations(id),
    CONSTRAINT check_stock_quantities CHECK (quantity = quantity_filled + quantity_remaining)
);

CREATE INDEX idx_stock_orders_active ON stock_orders(corporation_id, order_type, status) 
    WHERE status IN ('PENDING', 'ACTIVE');
CREATE INDEX idx_stock_orders_player ON stock_orders(player_id, status);
CREATE INDEX idx_stock_orders_execution ON stock_orders(execution_type, status);
```

### Stock Trades

```sql
CREATE TABLE stock_trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Stock
    corporation_id VARCHAR(100) NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    
    -- Trade
    quantity INTEGER NOT NULL,
    price_per_share DECIMAL(12,2) NOT NULL,
    total_value DECIMAL(12,2) NOT NULL,
    
    -- Participants
    seller_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    seller_order_id UUID NOT NULL,
    buyer_order_id UUID NOT NULL,
    
    -- Fees
    seller_broker_fee DECIMAL(12,2) NOT NULL,
    buyer_broker_fee DECIMAL(12,2) NOT NULL,
    
    -- Time
    executed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_stock_trade_seller FOREIGN KEY (seller_id) REFERENCES characters(id),
    CONSTRAINT fk_stock_trade_buyer FOREIGN KEY (buyer_id) REFERENCES characters(id),
    CONSTRAINT fk_stock_trade_corporation FOREIGN KEY (corporation_id) REFERENCES stock_corporations(id)
);

CREATE INDEX idx_stock_trades_corporation ON stock_trades(corporation_id, executed_at DESC);
CREATE INDEX idx_stock_trades_player_sell ON stock_trades(seller_id, executed_at DESC);
CREATE INDEX idx_stock_trades_player_buy ON stock_trades(buyer_id, executed_at DESC);
CREATE INDEX idx_stock_trades_time ON stock_trades(executed_at DESC);
```

---

## 🎯 Примеры сделок

### Пример 1: Simple Market Buy

```
Player Action: BUY 50 ARSK (Market Order)

Market State:
Best ask: 1,000 eddies (200 shares available)

Execution:
→ Buy 50 @ 1,000 = 50,000 eddies
→ Broker fee: 500 eddies (1%)
→ Total cost: 50,500 eddies
→ Shares added to portfolio: 50 ARSK

Result:
✅ Instant execution
✅ Owns 50 Arasaka shares
✅ Can receive dividends
```

### Пример 2: Limit Buy (wait for price)

```
Player Action: BUY 100 ARSK @ 950 (Limit Order)

Market State:
Current price: 1,000 eddies
Best ask: 1,000 eddies

Execution:
→ Order placed in book (PENDING)
→ Escrow: 95,000 + 950 broker fee = 95,950 eddies
→ Waiting for price to drop to 950

3 days later:
Market drops to 945 eddies
→ Order executes @ 945 (better than limit!)
→ Buy 100 @ 945 = 94,500 eddies
→ Broker fee: 950 eddies (already paid)
→ Unused escrow: 95,950 - 94,500 - 950 = 450 eddies (returned)

Result:
✅ Bought at better price (945 vs 1,000)
✅ Saved: 5,500 eddies (5.5%)
⏱️ Time cost: 3 days wait
```

### Пример 3: Sell for Profit

```
Player Holdings:
100 ARSK bought @ 1,010 eddies
Cost basis: 101,000 eddies (incl. broker fee)
Held for: 6 months
Dividends received: 2,000 eddies (2 quarters)

Current price: 1,150 eddies (+14%)

Player Action: SELL 100 ARSK (Market)

Execution:
→ Sell 100 @ 1,150 = 115,000 eddies
→ Broker fee: 1,150 eddies (1%)
→ Net proceeds: 113,850 eddies

Profit calculation:
Sale proceeds: 113,850 eddies
Cost basis: 101,000 eddies
Capital gain: 12,850 eddies (+12.7%)
Dividends: 2,000 eddies
Total return: 14,850 eddies (+14.7%)

Result:
✅ Realized profit: 14,850 eddies
✅ Total return: 14.7% (in 6 months)
✅ Annualized: ~29.4%
```

---

## 🔗 Связанные документы

- `stock-exchange-overview.md` - Обзор биржи
- `stock-corporations.md` - Корпорации
- `stock-dividends.md` - Дивиденды
- `stock-analytics.md` - Аналитика

---

## История изменений

- v1.0.0 (2025-11-06 21:45) - Создание документа о торговле акциями
  - Определены типы ордеров (Market, Limit)
  - Описан алгоритм matching
  - Рассчитаны комиссии (broker fee 1%)
  - Описана структура БД (2 таблицы)
  - Приведены примеры сделок

