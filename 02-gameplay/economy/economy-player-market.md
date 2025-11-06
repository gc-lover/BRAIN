# Экономика - Рынок игроков (Player Market)

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:35  
**Приоритет:** критический (MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:35  
**api-readiness-notes:** Документ в процессе детализации. После завершения будет готов к созданию API задач.

---

## Краткое описание

Детальная проработка рынка игроков (Player Market) с системой ордеров для NECPGAME — продвинутой системы торговли для опытных трейдеров в MMORPG.

**Цель:** Создать глубокую систему торговли с ордерами (buy/sell), которая объединяет лучшие практики из EVE Online, Guild Wars 2 и Albion Online, адаптированные под киберпанк сеттинг.

---

## Источники вдохновения

### EVE Online - Market Orders
- Детальная система buy/sell ордеров
- Order book (стакан заявок)
- Региональные рынки с арбитражем
- Price/time priority для исполнения
- Частичное исполнение ордеров
- Изменение и отмена ордеров
- Детальная статистика и графики

### Guild Wars 2 - Trading Post
- Централизованная система buy/sell orders
- Instant buy/sell vs placing orders
- История цен с графиками
- Простой и интуитивный UI
- Комиссии (listing + exchange)

### Albion Online - Market
- Региональные рынки
- Buy/sell orders
- Транспортировка между городами
- Арбитраж между регионами

---

## 🎯 Философия и отличия от Auction House

### Auction House vs Player Market

**Auction House:**
- Для **быстрой торговли**
- Продавец устанавливает цену
- Покупатель принимает или делает ставку
- Ограничено по времени (12-72ч)
- Подходит для **уникальных** предметов

**Player Market:**
- Для **масштабной торговли**
- И покупатели, и продавцы размещают ордера
- Ордера исполняются автоматически при совпадении цен
- **Бессрочные** ордера (до исполнения или отмены)
- Подходит для **массовых** товаров (расходники, материалы)

### Цели Player Market

1. **Ликвидность** - всегда есть buy/sell orders для популярных предметов
2. **Эффективность** - лучшая цена исполняется первой
3. **Прозрачность** - видна вся глубина рынка (order book)
4. **Справедливость** - price/time priority
5. **Масштаб** - поддержка миллионов ордеров

---

## 💰 Механики Player Market

### 1. Типы ордеров

#### 1.1. Sell Order (Ордер на продажу)

**Описание:** Игрок размещает предмет с желаемой ценой

**Механика:**
- Продавец указывает цену за единицу
- Предмет замораживается в escrow
- Ордер остается активным до полного исполнения или отмены
- Может исполняться частично

**Параметры:**
```typescript
{
  orderId: "uuid",
  type: "SELL",
  itemId: "health-booster",
  quantity: 100,
  pricePerUnit: 2.5,  // eddies per item
  quantityRemaining: 100,
  status: "ACTIVE"
}
```

**Пример:**
```
SELL ORDER
Item: Health Booster
Quantity: 100
Price per unit: 2.5 eddies
Total value: 250 eddies
Status: Active (0/100 sold)
```

#### 1.2. Buy Order (Ордер на покупку)

**Описание:** Игрок размещает заявку на покупку с желаемой ценой

**Механика:**
- Покупатель указывает цену за единицу
- Деньги замораживаются в escrow
- Ордер остается активным до полного исполнения или отмены
- Может исполняться частично

**Параметры:**
```typescript
{
  orderId: "uuid",
  type: "BUY",
  itemId: "health-booster",
  quantity: 100,
  pricePerUnit: 2.0,  // eddies per item
  quantityRemaining: 100,
  escrowed: 200,  // frozen money
  status: "ACTIVE"
}
```

**Пример:**
```
BUY ORDER
Item: Health Booster
Quantity: 100
Price per unit: 2.0 eddies
Total value: 200 eddies (escrowed)
Status: Active (0/100 filled)
```

#### 1.3. Market Order (Рыночный ордер)

**Описание:** Мгновенная покупка/продажа по лучшей доступной цене

**Механика:**
- Покупатель/продавец исполняет по текущей рыночной цене
- Исполняется мгновенно (если есть противоположные ордера)
- Может исполняться по нескольким ценам (если недостаточно объема)

**Пример (Market Buy):**
```
Player wants to buy 100x Health Booster (Market Order)

Order Book (Sell Orders):
1. 50x @ 2.5 eddies = 125 eddies
2. 30x @ 2.6 eddies = 78 eddies
3. 20x @ 2.7 eddies = 54 eddies

Total: 100x for 257 eddies (average 2.57 per unit)
```

#### 1.4. Limit Order (Лимитный ордер)

**Описание:** Ордер с ограничением по цене

**Механика:**
- Покупатель/продавец устанавливает максимальную/минимальную цену
- Исполняется только если цена достигнута
- Если нет подходящих ордеров, остается в order book

**Пример (Limit Buy):**
```
Player wants to buy 100x Health Booster
Max price: 2.3 eddies per unit

Current sell orders start at 2.5 eddies
→ Order placed in book, waiting for 2.3 or better
```

---

### 2. Order Book (Стакан заявок)

#### 2.1. Структура Order Book

**Описание:** Список всех активных buy и sell ордеров

**Формат:**
```
╔═══════════════════════════════════════════════════════════╗
║           ORDER BOOK: Health Booster                      ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  SELL ORDERS (ascending price)        Spread: 0.5 (20%)  ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ Price      │ Quantity  │ Total     │ Seller         │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │ 2.5 💰     │ 50        │ 125       │ 3 sellers      │ ║
║  │ 2.6 💰     │ 80        │ 208       │ 5 sellers      │ ║
║  │ 2.7 💰     │ 120       │ 324       │ 8 sellers      │ ║
║  │ 2.8 💰     │ 200       │ 560       │ 12 sellers     │ ║
║  │ 3.0 💰     │ 500       │ 1,500     │ 25 sellers     │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  BUY ORDERS (descending price)                            ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ Price      │ Quantity  │ Total     │ Buyer          │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │ 2.0 💰     │ 100       │ 200       │ 6 buyers       │ ║
║  │ 1.9 💰     │ 200       │ 380       │ 10 buyers      │ ║
║  │ 1.8 💰     │ 300       │ 540       │ 15 buyers      │ ║
║  │ 1.7 💰     │ 500       │ 850       │ 20 buyers      │ ║
║  │ 1.5 💰     │ 1,000     │ 1,500     │ 40 buyers      │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  Market Info:                                             ║
║  Best Ask (sell): 2.5 eddies                              ║
║  Best Bid (buy): 2.0 eddies                               ║
║  Spread: 0.5 eddies (20%)                                 ║
║  Last trade: 2.3 eddies (5 minutes ago)                   ║
║  24h volume: 12,458 units                                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

#### 2.2. Depth of Market (Глубина рынка)

**Описание:** Кумулятивный объем ордеров

**Визуализация:**
```
Depth Chart: Health Booster

Cumulative Volume
2000 │                    ████████████
1500 │              ████████████████████
1000 │        ████████████████████████████
 500 │  ██████████████████████████████████
   0 └────────────────────────────────────
     1.5    1.8    2.0    2.5    2.8    3.0
            BUY ←  SPREAD  → SELL

Green (Buy): Cumulative buy orders
Red (Sell): Cumulative sell orders
```

---

### 3. Исполнение ордеров

#### 3.1. Price/Time Priority

**Правило приоритета:**
```
1. PRICE первый приоритет:
   - Sell orders: lowest price first
   - Buy orders: highest price first
   
2. TIME второй приоритет:
   - Между ордерами с одинаковой ценой
   - Earlier order исполняется первым
```

**Пример:**
```
Sell Orders @ 2.5 eddies:
1. Order A: 50 units (created 2 days ago)
2. Order B: 30 units (created 1 day ago)
3. Order C: 20 units (created 1 hour ago)

Market Buy 70 units @ 2.5:
→ Order A: 50 units filled (полностью)
→ Order B: 20 units filled (частично, 10 осталось)
→ Order C: не затронут
```

#### 3.2. Частичное исполнение

**Описание:** Ордер может исполняться по частям

**Sell Order пример:**
```
Player places: SELL 100x Health Booster @ 2.5 eddies

Day 1: 30 units sold → 70 remaining
Day 2: 40 units sold → 30 remaining
Day 3: 30 units sold → 0 remaining (FILLED)

Total received: 250 eddies (100 × 2.5)
Sales tax: 12.5 eddies (5%)
Net profit: 237.5 eddies
```

**Buy Order пример:**
```
Player places: BUY 100x Health Booster @ 2.0 eddies
Escrowed: 200 eddies

Day 1: 30 units bought → 70 remaining, 60 eddies spent
Day 2: 50 units bought → 20 remaining, 100 eddies spent
Day 3: 20 units bought → 0 remaining (FILLED)

Total cost: 200 eddies
Remaining escrow: 0 eddies (all spent)
```

#### 3.3. Автоматическое matching

**Алгоритм:**
```
При размещении ордера:
1. Проверить противоположные ордера
2. Если есть matching orders:
   a. Исполнить по price/time priority
   b. Частично если недостаточно объема
3. Если остался объем:
   a. Разместить остаток в order book
```

**Пример matching:**
```
Order Book:
Sell: 2.5 (50 units), 2.6 (30 units)
Buy: 2.0 (100 units)

Player places: BUY 80x @ 2.5 eddies (Market Order)
→ Matches with Sell @ 2.5 (50 units)
→ 50 units bought @ 2.5 = 125 eddies
→ Remaining 30 units: no match (next sell is 2.6)
→ Place BUY order 30x @ 2.5 in book
```

---

### 4. Комиссии Player Market

#### 4.1. Listing Fee (Комиссия за размещение)

**Sell Orders:**
```
listing_fee = 0% (НЕТ комиссии за размещение sell orders)

Почему: Стимулировать продавцов размещать товары
```

**Buy Orders:**
```
listing_fee = quantity × pricePerUnit × 1%

Пример:
BUY 100x Health Booster @ 2.0 eddies
Listing fee: 100 × 2.0 × 0.01 = 2 eddies
Escrowed: 200 + 2 = 202 eddies
```

**Возврат при отмене:**
- Sell order отменен: нет комиссии, предмет возвращается
- Buy order отменен: listing fee НЕ возвращается, escrow возвращается

#### 4.2. Exchange Fee (Комиссия за сделку)

**Взимается при исполнении:**
```
exchange_fee = traded_value × base_fee × region_modifier

base_fee = 3% (ниже чем auction house 5%)

region_modifier = {
  Night_City: 1.0,
  Pacifica: 0.8,
  Corpo_Plaza: 1.2,
  Badlands: 0.6,
  Tokyo: 1.1,
  Europe: 1.0
}
```

**Кто платит:**
- Seller платит exchange fee из выручки
- Buyer НЕ платит exchange fee (уже заплатил listing fee если buy order)

**Пример:**
```
Trade: 50x Health Booster @ 2.5 eddies = 125 eddies
Region: Night City
Exchange fee: 125 × 0.03 × 1.0 = 3.75 eddies

Seller receives: 125 - 3.75 = 121.25 eddies
Buyer pays: 125 eddies (no additional fee)
```

#### 4.3. Модификаторы комиссий

**Reputation benefits:**
```
Faction rep ≥ 50: -10% exchange fee
Faction rep ≥ 75: -20% exchange fee
Faction rep ≥ 100: -30% exchange fee
```

**Trading Guild:**
```
Member: -20% exchange fee
Officer: -30% exchange fee
Leader: -40% exchange fee
```

**VIP:**
```
VIP membership: -25% exchange fee
```

**Стак бонусов:**
```
Max discount: -75% (все бонусы суммируются до -75% max)

Пример:
Base exchange fee: 3%
VIP: -25% → 2.25%
Guild member: -20% → 1.8%
Faction rep 100: -30% → 1.26%
CAPPED at 0.75% (75% discount)
```

---

### 5. Размещение ордеров

#### 5.1. Sell Order размещение

**Процесс:**
```
┌─────────────────────────────────────────────────────────┐
│ PLACE SELL ORDER                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Item: Health Booster                                    │
│ Available: 150 units                                    │
│                                                         │
│ Quantity to sell: [100]                                 │
│ Price per unit: [2.50] eddies                           │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ MARKET DATA:                                            │
│ Current best sell: 2.5 eddies                           │
│ Current best buy: 2.0 eddies                            │
│ Suggested price: 2.3 eddies (instant sell)              │
│ Last trade: 2.4 eddies (10 min ago)                     │
│                                                         │
│ If you price at:                                        │
│ • 2.0 eddies → INSTANT SELL (100% filled now)           │
│ • 2.3 eddies → Fast sell (likely filled in 1h)          │
│ • 2.5 eddies → Normal (current market, ~6h)             │
│ • 2.8 eddies → Slow (may take days)                     │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Total value: 250 eddies                                 │
│ Listing fee: 0 eddies (free for sell orders)            │
│ Exchange fee: ~7.5 eddies (3% when sold)                │
│ Net profit: ~242.5 eddies                               │
│                                                         │
│ ⚠️ Items will be locked until sold or cancelled          │
│                                                         │
│ [Cancel]  [Place Sell Order]                            │
└─────────────────────────────────────────────────────────┘
```

**Instant Sell опция:**
```
┌─────────────────────────────────────┐
│ Quick option: INSTANT SELL          │
│                                     │
│ Sell 100x to highest buy orders:   │
│ • 100x @ 2.0 eddies = 200 eddies    │
│                                     │
│ Exchange fee: 6 eddies (3%)         │
│ You receive: 194 eddies NOW         │
│                                     │
│ [Sell Instantly]                    │
└─────────────────────────────────────┘
```

#### 5.2. Buy Order размещение

**Процесс:**
```
┌─────────────────────────────────────────────────────────┐
│ PLACE BUY ORDER                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Item: Mantis Blades (Epic)                              │
│                                                         │
│ Quantity to buy: [1]                                    │
│ Price per unit: [8,000] eddies                          │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ MARKET DATA:                                            │
│ Current best sell: 8,500 eddies                         │
│ Current best buy: 7,500 eddies                          │
│ Suggested price: 8,200 eddies (likely filled today)     │
│ Last trade: 8,300 eddies (1h ago)                       │
│                                                         │
│ If you price at:                                        │
│ • 8,500 eddies → INSTANT BUY (filled now)               │
│ • 8,200 eddies → Fast (likely today)                    │
│ • 8,000 eddies → Normal (1-3 days)                      │
│ • 7,500 eddies → Slow (may take weeks)                  │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Total cost: 8,000 eddies                                │
│ Listing fee: 80 eddies (1%)                             │
│ Total escrowed: 8,080 eddies                            │
│                                                         │
│ Your balance: 15,500 eddies ✓                           │
│                                                         │
│ ⚠️ Funds will be locked until filled or cancelled        │
│                                                         │
│ [Cancel]  [Place Buy Order]                             │
└─────────────────────────────────────────────────────────┘
```

**Instant Buy опция:**
```
┌─────────────────────────────────────┐
│ Quick option: INSTANT BUY           │
│                                     │
│ Buy 1x from lowest sell order:     │
│ • 1x @ 8,500 eddies                 │
│                                     │
│ You pay: 8,500 eddies NOW           │
│                                     │
│ [Buy Instantly]                     │
└─────────────────────────────────────┘
```

---

### 6. Управление ордерами

#### 6.1. My Orders (Мои ордера)

**Вкладка "Sell Orders":**
```
┌─────────────────────────────────────────────────────────┐
│ MY SELL ORDERS                                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Active (5):                                             │
│ ┌───────────────────────────────────────────────────┐   │
│ │ Health Booster x100 @ 2.5 eddies                  │   │
│ │ Status: 30/100 sold (70 remaining)                │   │
│ │ Revenue: 75 eddies (30 × 2.5)                     │   │
│ │ Created: 2 days ago                               │   │
│ │ [View in Market] [Modify Price] [Cancel Order]    │   │
│ └───────────────────────────────────────────────────┘   │
│                                                         │
│ ┌───────────────────────────────────────────────────┐   │
│ │ Armor Jacket (Rare) x1 @ 1,200 eddies             │   │
│ │ Status: 0/1 sold (not filled yet)                 │   │
│ │ Created: 12 hours ago                             │   │
│ │ ⚠️ Best sell is 1,000 (yours is 20% above)         │   │
│ │ [Modify Price: 1,000] [Cancel]                    │   │
│ └───────────────────────────────────────────────────┘   │
│                                                         │
│ Filled (10):                                            │
│ ┌───────────────────────────────────────────────────┐   │
│ │ Mantis Blades (Epic) - FILLED                     │   │
│ │ Sold: 1x @ 9,000 eddies                           │   │
│ │ Revenue: 8,730 eddies (after 3% fee)              │   │
│ │ Completed: 1 day ago                              │   │
│ └───────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

**Вкладка "Buy Orders":**
```
┌─────────────────────────────────────────────────────────┐
│ MY BUY ORDERS                                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Active (3):                                             │
│ ┌───────────────────────────────────────────────────┐   │
│ │ Sandevistan (Epic) x1 @ 35,000 eddies             │   │
│ │ Status: 0/1 filled (waiting)                      │   │
│ │ Escrowed: 35,350 eddies (incl. 1% listing fee)    │   │
│ │ Position: #3 in queue (2 orders ahead @ 35k)      │   │
│ │ ✅ Best sell: 40,000 (your price is 12% below)     │   │
│ │ Created: 5 days ago                               │   │
│ │ [Increase Price] [Cancel Order] (refund 35,000)   │   │
│ └───────────────────────────────────────────────────┘   │
│                                                         │
│ Filled (7):                                             │
│ ┌───────────────────────────────────────────────────┐   │
│ │ Health Booster x200 - FILLED                      │   │
│ │ Bought: 200x @ 2.0 eddies = 400 eddies            │   │
│ │ Completed: 3 days ago                             │   │
│ │ Items in mailbox ✓                                │   │
│ └───────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

#### 6.2. Модификация ордеров

**Что можно изменить:**
- ✅ Цену (price per unit)
- ✅ Количество (увеличить, уменьшить)
- ❌ Предмет (нельзя изменить)
- ❌ Тип ордера (нельзя изменить)

**Правила изменения:**
```
Sell Order:
- Можно снизить цену (бесплатно)
- Можно повысить цену (бесплатно)
- Можно увеличить количество (добавить предметы)
- Можно уменьшить количество (вернуть предметы)
- При изменении цены: теряется time priority (как новый ордер)

Buy Order:
- Можно повысить цену (доплатить escrow)
- Можно снизить цену (вернуть часть escrow)
- Можно увеличить количество (доплатить escrow)
- Можно уменьшить количество (вернуть часть escrow)
- При изменении цены: теряется time priority
```

**Пример модификации:**
```
Original: SELL 100x Health Booster @ 2.5 eddies
Modified: SELL 100x Health Booster @ 2.3 eddies

→ Price priority обновлен (теперь более конкурентный)
→ Time priority сброшен (теперь в конце очереди @ 2.3)
→ Может быстрее продаться из-за лучшей цены
```

#### 6.3. Отмена ордеров

**Sell Order отмена:**
```
- Предметы возвращаются в инвентарь
- Комиссия: нет (0%)
- Продано 30/100: 70 возвращается, 30 уже продано
```

**Buy Order отмена:**
```
- Escrowed деньги возвращаются (кроме listing fee)
- Listing fee: НЕ возвращается
- Куплено 30/100: 30 уже в mailbox, escrow за 70 возвращается

Пример:
Original escrow: 200 eddies (100x @ 2.0)
Listing fee: 2 eddies
Filled: 30x (60 eddies spent)
Cancel order → Return: 140 - 2 = 138 eddies
Lost: 2 eddies listing fee
```

---

### 7. История сделок (Trade History)

#### 7.1. Личная история

**Для игрока:**
```
MY TRADE HISTORY: Last 30 days

┌─────────────────────────────────────────────────────────┐
│ Date       │ Item             │ Type │ Qty │ Price │    │
├─────────────────────────────────────────────────────────┤
│ Nov 6 10:30│ Mantis Blades    │ SELL │ 1   │ 9,000 │    │
│ Nov 6 09:15│ Health Booster   │ BUY  │ 50  │ 2.0   │    │
│ Nov 5 18:45│ Armor Jacket     │ SELL │ 1   │ 1,200 │    │
│ Nov 5 14:20│ Sandevistan      │ BUY  │ 1   │ 35,000│    │
└─────────────────────────────────────────────────────────┘

Total sold: 2 items for 10,200 eddies
Total bought: 2 items for 35,100 eddies
Net: -24,900 eddies (you're a net buyer)

Filters: [All items ▼] [Last 7 days ▼] [Buy & Sell ▼]
Export: [CSV] [JSON]
```

#### 7.2. Рыночная история (для предмета)

**Для каждого предмета:**
```
MARKET HISTORY: Mantis Blades (Epic) - Last 30 days

Recent trades (last 24h):
┌─────────────────────────────────────────────────────────┐
│ Time       │ Quantity │ Price     │ Buyer    │ Seller   │
├─────────────────────────────────────────────────────────┤
│ 10:30 AM   │ 1        │ 9,000     │ ***      │ ***      │
│ 09:15 AM   │ 1        │ 8,800     │ ***      │ ***      │
│ Yesterday  │ 2        │ 8,500     │ ***      │ ***      │
│ Yesterday  │ 1        │ 9,200     │ ***      │ ***      │
└─────────────────────────────────────────────────────────┘

24h Stats:
Volume: 5 units
Average: 8,900 eddies
Min: 8,500 eddies
Max: 9,200 eddies

Note: Buyer/Seller names hidden for privacy
```

---

### 8. Графики и аналитика

#### 8.1. Price Chart (График цен)

**Timeframes:**
- 1 hour (для активной торговли)
- 24 hours
- 7 days
- 30 days
- 90 days
- All time

**График:**
```
Price History: Mantis Blades (Epic) - Last 7 days

10,000 │                                    ╭─╮
 9,500 │                        ╭───────────╯ ╰╮
 9,000 │            ╭───────────╯             ╰─╮
 8,500 │        ╭───╯                           │
 8,000 │    ╭───╯                               │
 7,500 │────╯                                   ╰──
       └──────────────────────────────────────────
       Nov 1        Nov 3        Nov 5      Nov 7

Current: 9,200 eddies (↗ +8% from 7d ago)
7d avg: 8,750 eddies
7d high: 9,500 | 7d low: 7,800
Volume (7d): 247 units (35 trades)
```

#### 8.2. Volume Chart (График объема)

**Описание:** Объем торгов по дням

**График:**
```
Trading Volume: Mantis Blades (Epic) - Last 7 days

Units
 60 │                                    █
 50 │                    █               █
 40 │        █           █       █       █
 30 │        █   █       █       █       █
 20 │    █   █   █   █   █   █   █   █   █
 10 │    █   █   █   █   █   █   █   █   █
  0 └──────────────────────────────────────
    Nov 1   2   3   4   5   6   7

Total volume (7d): 247 units
Average daily: 35 units
Peak day: 58 units (Nov 7)
```

#### 8.3. Market Depth (Глубина рынка)

**Live depth chart:**
```
Market Depth: Mantis Blades (Epic)

Cumulative
  30 │                          ████████
  25 │                    ████████████████
  20 │              ████████████████████████
  15 │        ████████████████████████████████
  10 │  ████████████████████████████████████████
   5 │████████████████████████████████████████████
   0 └────────────────────────────────────────────
     7.0   7.5   8.0   8.5   9.0   9.5   10.0
          BUY ←    SPREAD    → SELL

Spread: 500 eddies (5.9%)
Total buy volume: 25 units
Total sell volume: 18 units
Market sentiment: BULLISH (more buyers than sellers)
```

---

### 9. Расширенные функции

#### 9.1. Order Queue Position

**Описание:** Показывает позицию ордера в очереди

**Для Buy Orders:**
```
Your buy order: Sandevistan @ 35,000 eddies
Queue position: #3

Orders ahead of you @ 35,000:
#1: 1 unit (created 10 days ago)
#2: 1 unit (created 5 days ago)
#3: YOU (created 2 days ago)

Next price level: 35,500 eddies (no orders)

💡 Tip: Increase price to 35,500 to be first in queue
```

**Для Sell Orders:**
```
Your sell order: Mantis Blades @ 8,500 eddies
Queue position: #1 (you have best price!)

Orders behind you @ 8,500:
#1: YOU (created 1 day ago)
#2: 2 units (created 3 hours ago)

Next price level: 8,300 eddies (5 orders)

💡 Tip: You have best price, should sell soon
```

#### 9.2. Price Alerts (Ценовые уведомления)

**Механика:**
```
Player sets alert:
Item: Sandevistan (Epic)
Alert when: best sell ≤ 35,000 eddies

Current best sell: 40,000 eddies

→ Alert triggered when price drops to 35,000
→ Notification: "Sandevistan now available at 35,000!"
```

#### 9.3. Advanced Statistics

**Для предмета:**
```
ADVANCED STATS: Mantis Blades (Epic)

📊 Price:
Current best buy: 8,000 eddies
Current best sell: 8,500 eddies
Spread: 500 eddies (5.9%)

7d: avg 8,750 | low 7,800 | high 9,500 | volatility 8.2%
30d: avg 8,600 | low 7,500 | high 10,000 | volatility 11.5%

📈 Volume:
24h: 35 units (12 trades)
7d: 247 units (78 trades)
30d: 1,024 units (312 trades)

Velocity (time to fill):
Buy orders @ market price: instant
Buy orders 5% below: 2-4 hours
Buy orders 10% below: 1-3 days
Buy orders 20% below: 1-2 weeks

⏱️ Fill Rate:
Orders filled within 24h: 68%
Orders filled within 7d: 89%
Orders cancelled: 11%

🎯 Recommendations:
For quick buy: place at 8,500 (instant)
For good price: place at 8,200 (filled in ~6h)
For best price: place at 8,000 (filled in 1-3 days)
```

---

### 10. Региональные рынки

#### 10.1. Regional Market Differences

**Концепция:** Разные регионы имеют разные цены

**Пример:**
```
Item: Health Booster

Night City:
Best buy: 2.0 eddies
Best sell: 2.5 eddies

Tokyo:
Best buy: 2.3 eddies (↑ 15%)
Best sell: 2.8 eddies (↑ 12%)

Badlands:
Best buy: 1.7 eddies (↓ 15%)
Best sell: 2.2 eddies (↓ 12%)

💡 Arbitrage opportunity:
Buy in Badlands @ 2.2, sell in Tokyo @ 2.8
Profit: 0.6 per unit (27% margin)
BUT: Need to transport (risk + cost)
```

#### 10.2. Cross-Region Trading

**Механика (MVP упрощенная):**
- Игрок видит только локальный рынок (своего региона)
- Для доступа к другим рынкам нужно быть в том регионе
- Или использовать "Remote Access" (10% комиссия)

**Remote Access:**
```
┌─────────────────────────────────────┐
│ ACCESS TOKYO MARKET                 │
│                                     │
│ You are in: Night City              │
│ Accessing: Tokyo Market (remote)    │
│                                     │
│ Remote access fee: 10%              │
│ Delivery time: 2 hours              │
│                                     │
│ Item: Health Booster x100           │
│ Best sell: 2.8 eddies               │
│ Remote fee: 0.28 eddies per unit    │
│ Total: 3.08 eddies per unit         │
│                                     │
│ [Cancel] [Buy with Remote Access]   │
└─────────────────────────────────────┘
```

---

### 11. Защита и ограничения

#### 11.1. Anti-manipulation

**Price limits:**
```
Sell order price:
- Min: 50% от average price (7 days)
- Max: 300% от average price (7 days)
- Если outside limits: warning + confirmation

Buy order price:
- Min: 10% от average price (no one will sell)
- Max: 200% от average price (protection)
```

**Volume limits (anti-monopoly):**
```
Max sell orders for same item:
- Per player: 10 orders (или 1,000 total quantity)
- If trying more: warning "You control 15% of market supply"

Max buy orders for same item:
- Per player: 10 orders (или 1,000 total quantity)
```

#### 11.2. Rate Limiting

```
Action                    Limit
──────────────────────────────────────
Place sell order          20/hour, 100/day
Place buy order           20/hour, 100/day
Modify order              30/hour, 150/day
Cancel order              30/hour, 150/day
Instant buy/sell          50/hour, 300/day
```

#### 11.3. Wash Trading Protection

**Проблема:** Игрок торгует сам с собой для искусственного объема

**Защита:**
```
Если игрок покупает свой собственный sell order:
→ Transaction blocked
→ Error: "You cannot buy from yourself"

Если игрок на двух аккаунтах:
→ Detection через IP/device fingerprint
→ Flag для модераторов
→ Ban при подтверждении
```

---

## 🗄️ Структура данных (БД)

### Таблица `market_orders`

```sql
CREATE TABLE market_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Тип ордера
    order_type VARCHAR(10) NOT NULL, -- "BUY", "SELL"
    
    -- Предмет
    item_id VARCHAR(100) NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    item_rarity VARCHAR(20) NOT NULL,
    
    -- Количество
    quantity INTEGER NOT NULL,
    quantity_remaining INTEGER NOT NULL,
    quantity_filled INTEGER NOT NULL DEFAULT 0,
    
    -- Цена
    price_per_unit DECIMAL(12,2) NOT NULL,
    
    -- Игрок
    player_id UUID NOT NULL,
    player_name VARCHAR(200) NOT NULL,
    
    -- Регион
    region VARCHAR(100) NOT NULL,
    
    -- Escrow (для buy orders и sell orders)
    escrowed_amount DECIMAL(12,2) NOT NULL, -- Деньги или предметы
    listing_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
    
    -- Статус
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, FILLED, CANCELLED, EXPIRED
    
    -- Приоритет (для исполнения)
    priority_price DECIMAL(12,2) NOT NULL, -- Для сортировки
    priority_time TIMESTAMP NOT NULL, -- Для time priority
    
    -- Время
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    filled_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    
    -- Мета
    modification_count INTEGER DEFAULT 0, -- Сколько раз изменялся
    last_modified_at TIMESTAMP,
    
    CONSTRAINT fk_market_order_player FOREIGN KEY (player_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT check_quantity CHECK (quantity > 0 AND quantity_remaining >= 0 AND quantity_filled >= 0),
    CONSTRAINT check_price CHECK (price_per_unit > 0),
    CONSTRAINT check_quantities CHECK (quantity = quantity_remaining + quantity_filled)
);

-- Критические индексы для performance
CREATE INDEX idx_market_orders_active_buy ON market_orders(item_id, order_type, priority_price DESC, priority_time ASC) 
    WHERE order_type = 'BUY' AND status = 'ACTIVE';
    
CREATE INDEX idx_market_orders_active_sell ON market_orders(item_id, order_type, priority_price ASC, priority_time ASC) 
    WHERE order_type = 'SELL' AND status = 'ACTIVE';
    
CREATE INDEX idx_market_orders_player ON market_orders(player_id, status);
CREATE INDEX idx_market_orders_region ON market_orders(region, status) WHERE status = 'ACTIVE';
CREATE INDEX idx_market_orders_item ON market_orders(item_id, status) WHERE status = 'ACTIVE';
```

### Таблица `market_trades`

```sql
CREATE TABLE market_trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Предмет
    item_id VARCHAR(100) NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    item_rarity VARCHAR(20) NOT NULL,
    
    -- Сделка
    quantity INTEGER NOT NULL,
    price_per_unit DECIMAL(12,2) NOT NULL,
    total_value DECIMAL(12,2) NOT NULL,
    
    -- Участники
    seller_id UUID NOT NULL,
    seller_order_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    buyer_order_id UUID NOT NULL,
    
    -- Комиссии
    exchange_fee DECIMAL(12,2) NOT NULL,
    seller_receives DECIMAL(12,2) NOT NULL, -- После комиссии
    
    -- Регион
    region VARCHAR(100) NOT NULL,
    
    -- Время
    executed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trade_seller FOREIGN KEY (seller_id) REFERENCES characters(id),
    CONSTRAINT fk_trade_buyer FOREIGN KEY (buyer_id) REFERENCES characters(id),
    CONSTRAINT fk_trade_sell_order FOREIGN KEY (seller_order_id) REFERENCES market_orders(id),
    CONSTRAINT fk_trade_buy_order FOREIGN KEY (buyer_order_id) REFERENCES market_orders(id)
);

CREATE INDEX idx_market_trades_item ON market_trades(item_id, executed_at DESC);
CREATE INDEX idx_market_trades_seller ON market_trades(seller_id, executed_at DESC);
CREATE INDEX idx_market_trades_buyer ON market_trades(buyer_id, executed_at DESC);
CREATE INDEX idx_market_trades_region ON market_trades(region, executed_at DESC);
CREATE INDEX idx_market_trades_executed ON market_trades(executed_at DESC);
```

### Materialized View `market_order_book`

```sql
CREATE MATERIALIZED VIEW market_order_book AS
SELECT 
    item_id,
    item_name,
    region,
    order_type,
    
    -- Aggregated by price level
    price_per_unit,
    SUM(quantity_remaining) as total_quantity,
    COUNT(*) as order_count,
    MIN(priority_time) as earliest_order,
    
    -- Best prices
    CASE 
        WHEN order_type = 'SELL' THEN 
            ROW_NUMBER() OVER (PARTITION BY item_id, region, order_type ORDER BY price_per_unit ASC)
        WHEN order_type = 'BUY' THEN 
            ROW_NUMBER() OVER (PARTITION BY item_id, region, order_type ORDER BY price_per_unit DESC)
    END as price_rank
    
FROM market_orders
WHERE status = 'ACTIVE' AND quantity_remaining > 0
GROUP BY item_id, item_name, region, order_type, price_per_unit;

CREATE UNIQUE INDEX ON market_order_book (item_id, region, order_type, price_per_unit);

-- Refresh каждую минуту (очень часто для актуальности)
REFRESH MATERIALIZED VIEW CONCURRENTLY market_order_book;
```

### Materialized View `market_statistics`

```sql
CREATE MATERIALIZED VIEW market_statistics AS
SELECT 
    item_id,
    item_name,
    item_rarity,
    region,
    
    -- Prices
    AVG(price_per_unit) as avg_price,
    MIN(price_per_unit) as min_price,
    MAX(price_per_unit) as max_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_unit) as median_price,
    
    -- Volume
    SUM(quantity) as total_volume,
    COUNT(*) as trade_count,
    
    -- Time-based
    SUM(quantity) FILTER (WHERE executed_at >= NOW() - INTERVAL '1 hour') as volume_1h,
    SUM(quantity) FILTER (WHERE executed_at >= NOW() - INTERVAL '24 hours') as volume_24h,
    SUM(quantity) FILTER (WHERE executed_at >= NOW() - INTERVAL '7 days') as volume_7d,
    
    AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '24 hours') as avg_price_24h,
    AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '7 days') as avg_price_7d,
    AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '30 days') as avg_price_30d,
    
    -- Spread
    (SELECT MIN(price_per_unit) FROM market_orders 
     WHERE item_id = mt.item_id AND region = mt.region AND order_type = 'SELL' AND status = 'ACTIVE') as best_ask,
    (SELECT MAX(price_per_unit) FROM market_orders 
     WHERE item_id = mt.item_id AND region = mt.region AND order_type = 'BUY' AND status = 'ACTIVE') as best_bid,
    
    -- Last trade
    MAX(executed_at) as last_trade_at,
    (SELECT price_per_unit FROM market_trades 
     WHERE item_id = mt.item_id AND region = mt.region 
     ORDER BY executed_at DESC LIMIT 1) as last_price,
    
    -- Trend
    CASE 
        WHEN AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '24 hours') > 
             AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '7 days') * 1.05 
        THEN 'RISING'
        WHEN AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '24 hours') < 
             AVG(price_per_unit) FILTER (WHERE executed_at >= NOW() - INTERVAL '7 days') * 0.95 
        THEN 'FALLING'
        ELSE 'STABLE'
    END as trend
    
FROM market_trades mt
WHERE executed_at >= NOW() - INTERVAL '90 days'
GROUP BY item_id, item_name, item_rarity, region;

CREATE UNIQUE INDEX ON market_statistics (item_id, region);

-- Refresh каждые 5 минут
REFRESH MATERIALIZED VIEW CONCURRENTLY market_statistics;
```

---

## 🎨 UI/UX концепция

### Главный экран Player Market

```
┌──────────────────────────────────────────────────────────────┐
│ PLAYER MARKET - Night City                                   │
├──────────────────────────────────────────────────────────────┤
│ [Browse] [My Orders] [Trade History] [Analytics] [Regions]  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ Item: [Health Booster___________________] [🔍]              │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ ORDER BOOK: Health Booster                               │ │
│ │                                                          │ │
│ │ SELL ORDERS           │ BUY ORDERS                       │ │
│ │ ┌──────────────────┐  │ ┌──────────────────┐            │ │
│ │ │ 2.5 | 50  | 125  │  │ │ 2.0 | 100 | 200  │            │ │
│ │ │ 2.6 | 80  | 208  │  │ │ 1.9 | 200 | 380  │            │ │
│ │ │ 2.7 | 120 | 324  │  │ │ 1.8 | 300 | 540  │            │ │
│ │ └──────────────────┘  │ └──────────────────┘            │ │
│ │                                                          │ │
│ │ Spread: 0.5 (20%) | Last: 2.3 | 24h Vol: 12,458         │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ QUICK TRADE                                              │ │
│ │                                                          │ │
│ │ [BUY] Quantity: [100]                                    │ │
│ │ ○ Market (instant @ 2.5) = 250 eddies                    │ │
│ │ ● Limit @ [2.3] eddies = 230 eddies (wait for fill)     │ │
│ │                                                          │ │
│ │ [Place Buy Order]                                        │ │
│ │                                                          │ │
│ │ [SELL] Quantity: [100]                                   │ │
│ │ ○ Market (instant @ 2.0) = 200 eddies                    │ │
│ │ ● Limit @ [2.2] eddies = 220 eddies (wait for fill)     │ │
│ │                                                          │ │
│ │ [Place Sell Order]                                       │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ [Price Chart] [Volume Chart] [Market Depth]                 │
└──────────────────────────────────────────────────────────────┘
```

### Order Book Detail View

```
╔═══════════════════════════════════════════════════════════╗
║         ORDER BOOK: Mantis Blades (Epic)                  ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  SELL ORDERS (Ask)                    Depth Chart         ║
║  ┌──────────────────────────────┐   Cumulative           ║
║  │ Price  │ Qty │ Total │ Sum   │    30 │         ████   ║
║  ├──────────────────────────────┤    25 │      ████████  ║
║  │ 8,500  │ 3   │ 25.5k │ 3    │    20 │   ████████████  ║
║  │ 8,600  │ 5   │ 43k   │ 8    │    15 │████████████████ ║
║  │ 8,700  │ 7   │ 60.9k │ 15   │    10 │████████████████ ║
║  │ 8,800  │ 10  │ 88k   │ 25   │     5 │████████████████ ║
║  │ 9,000  │ 15  │ 135k  │ 40   │     0 └────────────────  ║
║  └──────────────────────────────┘      8.0  8.5  9.0      ║
║                                                           ║
║  ═══════════ SPREAD: 500 (5.9%) ═══════════              ║
║                                                           ║
║  BUY ORDERS (Bid)                                         ║
║  ┌──────────────────────────────┐                        ║
║  │ Price  │ Qty │ Total │ Sum   │                        ║
║  ├──────────────────────────────┤                        ║
║  │ 8,000  │ 5   │ 40k   │ 5    │                        ║
║  │ 7,900  │ 8   │ 63.2k │ 13   │                        ║
║  │ 7,800  │ 12  │ 93.6k │ 25   │                        ║
║  │ 7,700  │ 20  │ 154k  │ 45   │                        ║
║  │ 7,500  │ 30  │ 225k  │ 75   │                        ║
║  └──────────────────────────────┘                        ║
║                                                           ║
║  Market Info:                                             ║
║  Best Ask: 8,500 | Best Bid: 8,000                        ║
║  Last Trade: 8,300 @ 11:45 AM (15 min ago)                ║
║  24h Volume: 127 units | 24h High: 9,200 | Low: 8,100     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 📈 Примеры использования

### Пример 1: Instant Sell (Market Order)

**Сценарий:** Игрок нашел 100x Health Boosters и хочет быстро продать

**Действия:**
1. Открывает Player Market
2. Выбирает "Health Booster"
3. Видит order book:
   - Best buy: 2.0 eddies (100 qty available)
   - Best sell: 2.5 eddies
4. Выбирает "Quick Sell" (Market Order)
5. Система исполняет:
   - Продает 100x @ 2.0 = 200 eddies
   - Exchange fee: 6 eddies (3%)
   - Net: 194 eddies
6. **Мгновенно** получает деньги

**Результат:**
- ✅ Быстрая продажа (instant)
- ❌ Не лучшая цена (могли бы получить 2.5 если подождать)
- ⏱️ Time: 10 секунд

### Пример 2: Limit Sell (лучшая цена)

**Сценарий:** Игрок хочет максимизировать прибыль

**Действия:**
1. Открывает Player Market
2. Выбирает "Health Booster"
3. Видит order book:
   - Best sell: 2.5 eddies
4. Размещает Sell Order:
   - Quantity: 100
   - Price: 2.4 eddies (немного ниже best sell)
5. Ордер размещен в order book
6. Ждет исполнения

**Результат через 6 часов:**
- 80/100 filled @ 2.4 = 192 eddies (exchange fee ~5.76)
- Net: 186.24 eddies
- 20/100 remaining (still active)

**Результат vs Instant Sell:**
- Instant: 194 eddies (instant)
- Limit: 186.24 eddies (частично, 6h wait)
- Разница: -7.76 eddies (но ждал 6h)

**Через 2 дня (полное исполнение):**
- 100/100 filled @ 2.4 = 240 eddies
- Exchange fee: 7.2 eddies
- Net: 232.8 eddies
- **Profit vs Instant:** +38.8 eddies (+20%)
- **Time cost:** 2 дня ожидания

### Пример 3: Buy Order с терпением

**Сценарий:** Игрок хочет купить Sandevistan дешево

**Действия:**
1. Смотрит market:
   - Best sell: 40,000 eddies
   - Best buy: 35,000 eddies
   - Last trade: 38,000 eddies
2. Размещает Buy Order:
   - Price: 36,000 eddies (выше best buy, но ниже best sell)
   - Escrow: 36,360 eddies (36k + 360 listing fee)
3. Ждет продавца

**Результат через 3 дня:**
- Кто-то размещает sell @ 36,000
- Ордер исполняется автоматически
- Игрок платит: 36,000 eddies (listing fee 360 уже заплачен)
- **Savings vs Instant Buy:** 4,000 eddies (10%)
- **Time cost:** 3 дня ожидания

### Пример 4: Арбитраж между регионами

**Сценарий:** Опытный трейдер использует региональные различия

**Действия:**
1. Проверяет цены в Badlands:
   - Health Booster sell @ 2.2 eddies
2. Покупает 1,000x = 2,200 eddies
3. Транспортирует в Tokyo (опасно, может ограбить)
4. Продает в Tokyo @ 2.8 eddies = 2,800 eddies
5. Profit: 600 eddies (27% margin)
6. Costs:
   - Transport: 100 eddies (5%)
   - Risk: may lose cargo (insurance 50 eddies)
   - Exchange fees: ~84 eddies (3%)
7. Net profit: ~366 eddies (16.6% actual margin)

**Риски:**
- Может быть ограблен при перевозке (потеря всего груза)
- Цены могут измениться за время транспорта
- Конкуренция (другие трейдеры делают то же самое)

---

## 🔗 API Endpoints

### Базовые endpoints

```
GET    /market/items                   - Список торгуемых предметов
GET    /market/items/{itemId}          - Детали предмета
GET    /market/order-book/{itemId}     - Order book для предмета

POST   /market/orders                  - Создать ордер
GET    /market/orders                  - Список своих ордеров
GET    /market/orders/{orderId}        - Детали ордера
PATCH  /market/orders/{orderId}        - Изменить ордер
DELETE /market/orders/{orderId}        - Отменить ордер

POST   /market/instant-buy             - Мгновенная покупка (market order)
POST   /market/instant-sell            - Мгновенная продажа (market order)

GET    /market/trades                  - История сделок (личная)
GET    /market/trades/{itemId}         - История сделок (по предмету)

GET    /market/statistics/{itemId}     - Статистика предмета
GET    /market/chart/{itemId}          - Данные для графиков
GET    /market/regions                 - Сравнение цен по регионам
```

### WebSocket endpoints (для real-time)

```
WS     /market/live/{itemId}           - Live updates order book
WS     /market/live/trades/{itemId}    - Live trade feed
WS     /market/live/my-orders          - Live updates своих ордеров
```

### Модели данных

**MarketOrder:**
```typescript
interface MarketOrder {
  id: string;
  orderType: "BUY" | "SELL";
  itemId: string;
  itemName: string;
  itemRarity: string;
  quantity: number;
  quantityRemaining: number;
  quantityFilled: number;
  pricePerUnit: number;
  playerId: string;
  playerName: string;
  region: string;
  escrowedAmount: number;
  listingFee: number;
  status: "ACTIVE" | "FILLED" | "CANCELLED" | "EXPIRED";
  createdAt: Date;
  updatedAt: Date;
  filledAt?: Date;
}
```

**OrderBook:**
```typescript
interface OrderBook {
  itemId: string;
  itemName: string;
  region: string;
  
  sellOrders: OrderBookEntry[];  // Sorted by price ASC
  buyOrders: OrderBookEntry[];   // Sorted by price DESC
  
  bestAsk: number;  // Lowest sell price
  bestBid: number;  // Highest buy price
  spread: number;   // bestAsk - bestBid
  spreadPercent: number;
  
  lastTradePrice: number;
  lastTradeAt: Date;
  
  volume24h: number;
  volumeValue24h: number;
}

interface OrderBookEntry {
  pricePerUnit: number;
  totalQuantity: number;
  orderCount: number;
  earliestOrder: Date;
}
```

**MarketTrade:**
```typescript
interface MarketTrade {
  id: string;
  itemId: string;
  itemName: string;
  quantity: number;
  pricePerUnit: number;
  totalValue: number;
  sellerId: string;
  buyerId: string;
  exchangeFee: number;
  sellerReceives: number;
  region: string;
  executedAt: Date;
}
```

---

## 🎯 Интеграция с Auction House

### Когда использовать что?

**Auction House:**
- ✅ Уникальные предметы (редкие, legendary)
- ✅ Предметы с уникальными характеристиками (rolls)
- ✅ Когда хочешь максимизировать цену (bidding war)
- ✅ Быстрая продажа (12-72 часа)

**Player Market:**
- ✅ Массовые товары (расходники, материалы)
- ✅ Стандартизированные предметы (одинаковые)
- ✅ Когда нужна лучшая цена (готов ждать)
- ✅ Долгосрочная торговля (ордера бессрочные)

### Cross-posting (в будущем)

**Идея:** Один предмет на обоих рынках

**Ограничения:**
- Нельзя размещать один предмет и там, и там
- Нужно выбрать один рынок
- После продажи можно разместить на другом

---

## 🔐 Безопасность

### Anti-bot protection

**Detection:**
- Слишком быстрое размещение ордеров (< 1 sec between)
- Одинаковые паттерны (price, quantity)
- Активность 24/7 без перерывов
- Идеальное timing на price changes

**Actions:**
- CAPTCHA challenge
- Rate limiting
- Temporary ban (24h → 7d → permanent)

### Market manipulation

**Pump and dump protection:**
```
Если игрок покупает >50% supply, затем продает с наценкой:
→ Flag для модераторов
→ Investigation
→ Possible ban
```

**Spoofing protection:**
```
Если игрок размещает большие ордера и отменяет их часто:
→ Penalty: listing fee НЕ возвращается при частых отменах
→ Rate limit на отмены
```

---

## 📊 Метрики и мониторинг

### Dashboard для Game Designers

```
PLAYER MARKET DASHBOARD

Active Orders: 145,267
- Sell: 78,234 (54%)
- Buy: 67,033 (46%)

Daily Trades: 12,458
Trade Value (24h): 89,234,567 eddies
Fees Collected (24h): 2,677,037 eddies

Top Items (by volume):
1. Health Booster (15,234 units)
2. Armor Parts (8,567 units)
3. Ammo (7,234 units)

Regional Distribution:
- Night City: 65%
- Tokyo: 15%
- Europe: 12%
- Badlands: 8%

Order Fill Rate:
- Within 1h: 35%
- Within 24h: 68%
- Within 7d: 89%
- Cancelled: 11%

Average Spread: 12.5%
```

### Metrics для аналитики

**Price efficiency:**
```
spread_percentage = (bestAsk - bestBid) / bestAsk × 100

Healthy market: 5-15%
Tight market: < 5%
Wide market: > 15% (low liquidity)
```

**Liquidity:**
```
liquidity_score = (buyVolume + sellVolume) / averageDailyVolume

High liquidity: > 2.0
Medium liquidity: 0.5 - 2.0
Low liquidity: < 0.5
```

---

## 🚀 Roadmap

### MVP (Фаза 1) - ✅ Детализировано

- [x] Базовые типы ордеров (BUY, SELL, MARKET, LIMIT)
- [x] Order book с price/time priority
- [x] Частичное исполнение
- [x] Комиссии (listing fee, exchange fee)
- [x] My Orders управление
- [x] Instant buy/sell
- [x] История сделок
- [x] Базовая аналитика

### Post-MVP (Фаза 2)

- [ ] Price alerts (уведомления о ценах)
- [ ] Advanced charts (candlestick, indicators)
- [ ] Order queue position (позиция в очереди)
- [ ] Market depth visualization (глубина рынка)
- [ ] Cross-region comparison (сравнение регионов)
- [ ] Trading bots API (если разрешено)

### Expansions (Фаза 3)

- [ ] Stop-loss orders (автоматическая продажа)
- [ ] Take-profit orders (автоматическая покупка)
- [ ] OCO orders (One-Cancels-Other)
- [ ] Margin trading (торговля с плечом)
- [ ] Options/Futures (производные инструменты)

---

## 🎮 Интеграция с геймплеем

### Локации

**Терминалы Player Market:**
- Все major города (Night City, Tokyo, Europe)
- Можно открыть через меню (hotkey "M")
- Через in-game terminal (cyberdeck)
- Mobile app (in-game device)

### NPC Market Specialists

**Типы NPC:**
- **Market Analyst** - дает советы по торговле
- **Trading Mentor** - обучает механикам
- **Data Broker** - продает расширенную аналитику

**Диалоги:**
```
Market Analyst: "I see you're interested in Mantis Blades.
                 The price is rising fast — up 12% this week.
                 My advice? Buy now before it hits 10k."
                 
Options:
> Show me the chart
> What else is trending?
> Any arbitrage opportunities?
> Thanks, I'll think about it
```

---

## 💡 Продвинутые стратегии

### 1. Market Making

**Описание:** Размещать и buy, и sell orders для profit на spread

**Пример:**
```
Item: Health Booster
Best bid: 2.0 | Best ask: 2.5

Strategy:
1. Place buy order @ 2.1 (выше best bid)
2. Wait for fill
3. Place sell order @ 2.4 (ниже best ask)
4. Wait for fill
5. Profit: 2.4 - 2.1 = 0.3 per unit (14% margin)
6. Repeat

Risks:
- Price может измениться пока ждешь
- Твои ордера могут не исполниться
- Нужен capital для market making
```

### 2. Swing Trading

**Описание:** Покупать на low, продавать на high (используя графики)

**Пример:**
```
Mantis Blades price pattern (30 days):
Low: 7,500 (every 7-10 days)
High: 9,500 (every 7-10 days)
Pattern: циклический

Strategy:
1. Buy @ 7,500-8,000 (when price dips)
2. Hold
3. Sell @ 9,000-9,500 (when price peaks)
4. Profit: ~1,500 per unit (20%)

Timing:
- Buy signals: price < 8,000 + volume spike
- Sell signals: price > 9,000 + volume spike
```

### 3. Volume Trading

**Описание:** Торговать большими объемами с малой маржой

**Пример:**
```
Item: Ammo (common consumable)
Margin: очень низкая (2-3%)
Volume: очень высокая (10,000+ units/day)

Strategy:
1. Buy 10,000x @ 0.95 eddies = 9,500 eddies
2. Sell 10,000x @ 0.98 eddies = 9,800 eddies
3. Profit: 300 eddies (3% margin)
4. Fees: ~300 eddies (3% exchange fee)
5. Net: 0 eddies? 

Need to:
- Use high reputation (-30% fee) → profit ~90 eddies
- Repeat 100 times/day → 9,000 eddies/day
- High volume, low margin
```

---

## ✅ Критерии готовности к API

- [x] Определены типы ордеров (BUY, SELL, MARKET, LIMIT)
- [x] Описан order book и matching algorithm
- [x] Определены комиссии (listing fee, exchange fee)
- [x] Описано частичное исполнение
- [x] Определена структура БД (2 таблицы + 2 materialized views)
- [x] Описаны UI/UX концепции
- [x] Определены API endpoints
- [x] Описаны примеры использования (4 сценария)
- [x] Определены интеграции с другими системами
- [x] Описаны продвинутые стратегии

**Статус:** ✅ Готов к созданию API задач после review

---

## 📚 Связанные документы

- `economy-overview.md` - Обзор экономической системы
- `economy-type.md` - Тип экономической системы
- `economy-trading.md` - Торговля (общая концепция)
- `economy-auction-house.md` - Аукцион дом (альтернативная система)
- `economy-currencies-resources.md` - Валюты и ресурсы
- `trading-routes-global.md` - Торговые маршруты (для арбитража)

---

## Сравнение с Auction House

| Аспект | Auction House | Player Market |
|--------|---------------|---------------|
| **Цель** | Быстрая торговля | Масштабная торговля |
| **Время** | Ограничено (12-72h) | Бессрочно |
| **Механика** | Продавец устанавливает цену | Buy & Sell ордера |
| **Исполнение** | Покупатель принимает | Автоматическое matching |
| **Предметы** | Уникальные, редкие | Массовые, стандартные |
| **Listing Fee** | 2% от starting bid | 0% (sell), 1% (buy) |
| **Sales Tax** | 5% от sold price | 3% от traded value |
| **Частичное** | Нет | Да |
| **Order Book** | Нет | Да |
| **Графики** | Базовые | Детальные |
| **Стратегии** | Простые | Продвинутые |

**Рекомендации:**
- Уникальные предметы → Auction House
- Массовые товары → Player Market
- Быстро продать → Auction House (buyout)
- Лучшая цена → Player Market (limit order)

---

## История изменений

- v1.0.0 (2025-11-06 21:35) - Создание документа с детальной проработкой Player Market
  - Определены типы ордеров (BUY, SELL, MARKET, LIMIT)
  - Описан order book и matching algorithm (price/time priority)
  - Рассчитаны формулы комиссий (listing fee 0-1%, exchange fee 3%)
  - Описана структура БД (2 таблицы + 2 materialized views)
  - Описаны UI/UX концепции
  - Определены API endpoints (15+ REST + 3 WebSocket)
  - Описаны 4 детальных примера использования
  - Описаны продвинутые торговые стратегии (market making, swing trading, volume trading, arbitrage)

