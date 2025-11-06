# Player Market - Part 2: Database & API

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:37  
**Часть:** 2 из 3

[← Part 1](./part1-philosophy-mechanics.md) | [Навигация](./README.md) | [Part 3 →](./part3-integration-advanced.md)

---

## Структура данных (БД)

### player_market_listings

```sql
CREATE TABLE player_market_listings (
  id UUID PRIMARY KEY,
  seller_id UUID NOT NULL,
  item_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  price_per_unit BIGINT NOT NULL,
  total_price BIGINT NOT NULL,
  listing_fee BIGINT NOT NULL,
  status VARCHAR(20) NOT NULL, -- active, sold, cancelled, expired
  created_at TIMESTAMP NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  sold_at TIMESTAMP,
  buyer_id UUID,
  FOREIGN KEY (seller_id) REFERENCES characters(id),
  FOREIGN KEY (item_id) REFERENCES items(id)
);
```

### player_market_transactions

```sql
CREATE TABLE player_market_transactions (
  id UUID PRIMARY KEY,
  listing_id UUID NOT NULL,
  buyer_id UUID NOT NULL,
  seller_id UUID NOT NULL,
  item_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  price BIGINT NOT NULL,
  commission BIGINT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  FOREIGN KEY (listing_id) REFERENCES player_market_listings(id)
);
```

---

## API Endpoints

### GET /api/v1/market/listings
**Поиск листингов**

**Query params:**
- itemName, minPrice, maxPrice, seller, sortBy

**Response 200:**
```json
{
  "listings": [
    {
      "id": "uuid",
      "item": {...},
      "price": 1000,
      "seller": "username",
      "rating": 4.8
    }
  ],
  "total": 150
}
```

---

### POST /api/v1/market/listings
**Создать листинг**

**Request:**
```json
{
  "itemId": "uuid",
  "quantity": 10,
  "pricePerUnit": 100
}
```

**Response 201:**
```json
{
  "listing": {
    "id": "uuid",
    "expiresAt": "2025-11-14T01:37:00Z",
    "listingFee": 10
  }
}
```

---

### POST /api/v1/market/listings/{listingId}/buy
**Купить предмет**

**Response 200:**
```json
{
  "transaction": {
    "id": "uuid",
    "item": {...},
    "price": 1000,
    "timestamp": "2025-11-07T01:37:00Z"
  }
}
```

---

### DELETE /api/v1/market/listings/{listingId}
**Отменить листинг**

**Response 200:**
```json
{
  "message": "Listing cancelled",
  "refund": 10
}
```

---

## UI/UX концепция

**Market Browser:**
- Search bar + filters
- Grid/List view toggle
- Sorting (price, date, rating)
- Instant buy button

**My Listings:**
- Active listings
- Sales history
- Statistics

---

[Part 3: Integration & Advanced →](./part3-integration-advanced.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:37) - Создан из economy-player-market.md

