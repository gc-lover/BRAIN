---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:15  
**api-readiness-notes:** Auction House Operations. API endpoints, безопасность, метрики, roadmap. ~220 строк.
---

# Auction House Operations - Операции

**Статус:** approved  
**Версия:** 1.0.0  
**Дата:** 2025-11-07 06:15  
**Приоритет:** высокий  
**Автор:** AI Brain Manager

**Микрофича:** Operations & API  
**Размер:** ~220 строк ✅

---

## API Endpoints

### POST /api/v1/auctions

**Request:**
```json
{
  "characterId": "uuid",
  "itemId": "uuid",
  "quantity": 1,
  "startingBid": 10000,
  "buyoutPrice": 25000,
  "durationHours": 48
}
```

**Response 201:**
```json
{
  "success": true,
  "auctionId": "uuid",
  "expiresAt": "datetime"
}
```

---

### GET /api/v1/auctions

**Query:**
```
?search=cyberarm
&minBid=5000
&maxBid=50000
&sortBy=endingSoon
&page=1
```

**Response 200:**
```json
{
  "auctions": [
    {
      "id": "uuid",
      "item": {},
      "currentBid": 15000,
      "buyoutPrice": 25000,
      "bidCount": 12,
      "expiresAt": "datetime"
    }
  ]
}
```

---

### POST /api/v1/auctions/{id}/bid

**Request:**
```json
{
  "characterId": "uuid",
  "bidAmount": 16000
}
```

**Response 200:**
```json
{
  "success": true,
  "currentBid": 16000,
  "leading": true
}
```

---

### POST /api/v1/auctions/{id}/buyout

**Request:**
```json
{
  "characterId": "uuid"
}
```

**Response 200:**
```json
{
  "success": true,
  "paidAmount": 25000,
  "item": {}
}
```

---

## Безопасность

**Anti-Fraud:**
- Bid validation
- Sniping protection (auto-extend)
- Shill bidding detection
- Price manipulation alerts

**Limits:**
- Max 10 active auctions per player
- Min bid increment: 5%
- Max duration: 7 days

---

## Метрики

```
auctions.active - активные аукционы
auctions.bids.daily - ставок за день
auctions.sold.daily - продано за день
auctions.buyout.rate - % buyout vs bidding
```

---

## Roadmap

**MVP:**
- ✅ Create auction
- ✅ Place bid
- ✅ Buyout
- ✅ Auto-complete

**Phase 2:**
- 🔜 Reserve price
- 🔜 Bid history
- 🔜 Watch list
- 🔜 Bid notifications

---

## Связанные документы

- `.BRAIN/02-gameplay/economy/auction-house/auction-mechanics.md` - Mechanics (1/3)
- `.BRAIN/02-gameplay/economy/auction-house/auction-database.md` - Database (2/3)
- `.BRAIN/02-gameplay/economy/player-market/` - Player Market

---

## История изменений

- **v1.0.0 (2025-11-07 06:15)** - Микрофича 3/3 (split from economy-auction-house.md)

