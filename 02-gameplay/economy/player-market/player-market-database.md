---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:10  
**api-readiness-notes:** Player Market Database. БД schema (listings, trades, reviews), UI/UX концепция. ~320 строк.
---

# Player Market Database - База данных и UI

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Дата обновления:** 2025-11-07 06:10  
**Приоритет:** высокий  
**Автор:** AI Brain Manager

**Микрофича:** Database & UI  
**Размер:** ~320 строк ✅

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-173](../../../API-SWAGGER/tasks/active/queue/task-173-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: PLAYER_MARKET_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Database Schema

### market_listings

```sql
CREATE TABLE market_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL,
    item_id UUID NOT NULL,
    
    quantity INTEGER NOT NULL,
    price_per_unit INTEGER NOT NULL,
    total_price INTEGER NOT NULL,
    
    status VARCHAR(20) DEFAULT 'active',
    -- active, sold, cancelled, expired
    
    city VARCHAR(50),
    
    views_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    sold_at TIMESTAMP,
    
    CONSTRAINT fk_listing_seller FOREIGN KEY (seller_id) 
        REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_listings_status ON market_listings(status) WHERE status = 'active';
CREATE INDEX idx_listings_item ON market_listings(item_id, status);
CREATE INDEX idx_listings_price ON market_listings(price_per_unit);
CREATE INDEX idx_listings_created ON market_listings(created_at DESC);
```

---

### trade_history

```sql
CREATE TABLE trade_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    seller_id UUID NOT NULL,
    
    item_id UUID NOT NULL,
    quantity INTEGER NOT NULL,
    price_paid INTEGER NOT NULL,
    
    completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trade_buyer FOREIGN KEY (buyer_id) 
        REFERENCES players(id) ON DELETE SET NULL,
    CONSTRAINT fk_trade_seller FOREIGN KEY (seller_id) 
        REFERENCES players(id) ON DELETE SET NULL
);

CREATE INDEX idx_trades_buyer ON trade_history(buyer_id);
CREATE INDEX idx_trades_seller ON trade_history(seller_id);
CREATE INDEX idx_trades_item ON trade_history(item_id);
```

---

### seller_reviews

```sql
CREATE TABLE seller_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL,
    reviewer_id UUID NOT NULL,
    trade_id UUID NOT NULL,
    
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_review_seller FOREIGN KEY (seller_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_reviewer FOREIGN KEY (reviewer_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(trade_id, reviewer_id)
);
```

---

## UI/UX Концепция

### Market Browse Screen

```
┌──────────────────────────────────────────────────────┐
│ PLAYER MARKET                         [My Listings]  │
├──────────────────────────────────────────────────────┤
│                                                       │
│ Search: [___________]  [🔍]     Sort: [Price ▼]     │
│                                                       │
│ Filters:                                             │
│ Type:    [All Items ▼]                               │
│ Quality: [All ▼]                                     │
│ Price:   [Min] - [Max]                               │
│ City:    [All Cities ▼]                              │
│                                                       │
├──────────────────────────────────────────────────────┤
│                                                       │
│ ┌────────────────────────────────────────────────┐  │
│ │ [Icon] Mantis Blades (Epic)                    │  │
│ │        Seller: CyberNinja92 ⭐⭐⭐⭐⭐ (148)       │  │
│ │        Price: 6,500 ed  Qty: 1                 │  │
│ │        [Buy Now] [Contact Seller]              │  │
│ └────────────────────────────────────────────────┘  │
│                                                       │
│ ┌────────────────────────────────────────────────┐  │
│ │ [Icon] Trauma Team Implant (Rare)              │  │
│ │        Seller: DocMercy ⭐⭐⭐⭐ (67)              │  │
│ │        Price: 3,200 ed  Qty: 3                 │  │
│ │        [Buy Now] [Contact Seller]              │  │
│ └────────────────────────────────────────────────┘  │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

### Create Listing Screen

```
┌──────────────────────────────────────────────────────┐
│ CREATE LISTING                                       │
├──────────────────────────────────────────────────────┤
│                                                       │
│ Select Item: [Choose from inventory ▼]              │
│                                                       │
│ ┌────────────────────────────────────────────────┐  │
│ │ [Icon] Mantis Blades (Epic)                    │  │
│ │        Available: 1                             │  │
│ └────────────────────────────────────────────────┘  │
│                                                       │
│ Quantity: [1]  /  Available: 1                       │
│                                                       │
│ Price per unit: [6,500] ed                           │
│ Total price:    6,500 ed                             │
│                                                       │
│ Market fee (1%): 65 ed                               │
│ You will receive: 6,435 ed                           │
│                                                       │
│ Expires in: [7 days ▼]                               │
│                                                       │
│ [Cancel]               [Create Listing]              │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

## Связанные документы

- `.BRAIN/02-gameplay/economy/player-market/player-market-database.md` - Database (микрофича 2/4)
- `.BRAIN/02-gameplay/economy/player-market/player-market-api.md` - API (микрофича 3/4)
- `.BRAIN/02-gameplay/economy/player-market/player-market-analytics.md` - Analytics (микрофича 4/4)

---

## История изменений

- **v1.0.0 (2025-11-07 06:10)** - Микрофича 1/4: Player Market Core (split from economy-player-market.md)

