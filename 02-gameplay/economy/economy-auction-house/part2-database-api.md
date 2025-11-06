# Auction House - Part 2: Database & API

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:41  
**Часть:** 2 из 3

[← Part 1](./part1-mechanics-bidding.md) | [Навигация](./README.md) | [Part 3 →](./part3-advanced-integration.md)

---

## Структура данных (БД)

### auction_listings

```sql
CREATE TABLE auction_listings (
  id UUID PRIMARY KEY,
  seller_id UUID NOT NULL,
  item_id UUID NOT NULL,
  starting_price BIGINT NOT NULL,
  reserve_price BIGINT, -- optional
  buy_it_now_price BIGINT, -- optional
  current_bid BIGINT,
  highest_bidder_id UUID,
  bid_count INTEGER DEFAULT 0,
  auction_type VARCHAR(20), -- standard, reserve, bin, blind
  status VARCHAR(20), -- active, completed, cancelled
  created_at TIMESTAMP NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  completed_at TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES characters(id)
);
```

### auction_bids

```sql
CREATE TABLE auction_bids (
  id UUID PRIMARY KEY,
  auction_id UUID NOT NULL,
  bidder_id UUID NOT NULL,
  bid_amount BIGINT NOT NULL,
  auto_bid_max BIGINT, -- for auto-bidding
  is_winning BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMP NOT NULL,
  FOREIGN KEY (auction_id) REFERENCES auction_listings(id)
);
```

---

## API Endpoints

### GET /api/v1/auctions
**Список аукционов**

**Query params:**
- category, minPrice, maxPrice, ending_soon, sortBy

**Response 200:**
```json
{
  "auctions": [
    {
      "id": "uuid",
      "item": {...},
      "currentBid": 1000,
      "bidCount": 15,
      "expiresAt": "2025-11-08T01:41:00Z",
      "buyItNowPrice": 2000
    }
  ]
}
```

---

### POST /api/v1/auctions
**Создать аукцион**

**Request:**
```json
{
  "itemId": "uuid",
  "startingPrice": 500,
  "reservePrice": 1000,
  "buyItNowPrice": 2000,
  "duration": 48
}
```

**Response 201:**
```json
{
  "auction": {
    "id": "uuid",
    "expiresAt": "2025-11-09T01:41:00Z"
  }
}
```

---

### POST /api/v1/auctions/{auctionId}/bid
**Сделать ставку**

**Request:**
```json
{
  "bidAmount": 1100,
  "autoBidMax": 1500
}
```

**Response 200:**
```json
{
  "bid": {
    "id": "uuid",
    "isWinning": true,
    "currentBid": 1100
  }
}
```

---

### POST /api/v1/auctions/{auctionId}/buyitnow
**Купить сразу (BIN)**

**Response 200:**
```json
{
  "transaction": {
    "id": "uuid",
    "price": 2000,
    "item": {...}
  }
}
```

---

## UI/UX концепция

**Auction Browser:**
- Search + filters
- "Ending soon" section
- "My bids" section
- Real-time updates (WebSocket)

**Auction Detail:**
- Item info
- Bid history
- Time remaining (countdown)
- Bid button / BIN button

---

[Part 3: Advanced & Integration →](./part3-advanced-integration.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:41) - Создан из economy-auction-house.md

