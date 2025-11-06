---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-152: api/v1/economy/contracts.yaml (2025-11-07 11:06)
- Last Updated: 2025-11-07 00:18
---


# Экономика - Контракты и сделки

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:00  
**Приоритет:** средний (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 22:00

**target-domain:** economy  
**target-microservice:** economy-service (port 8085)  
**target-frontend-module:** modules/economy/contracts

---

## Краткое описание

Система контрактов между игроками для безопасных сделок.

**Микрофича:** Contracts (P2P, escrow, collateral, arbitration)

---

## 📝 Типы контрактов

### 1. Item Exchange Contract
**Обмен предметами**

```
Player A offers: Mantis Blades
Player B offers: 10,000 eddies

Contract terms:
- A gives Mantis Blades
- B gives 10,000 eddies
- Escrow: Both deposit
- Auto-execute on accept
```

### 2. Delivery Contract
**Доставка груза**

```
Client: Player A
Courier: Player B

Terms:
- Deliver 100 Health Boosters from NC to Tokyo
- Payment: 1,000 eddies
- Deadline: 24 hours
- Penalty: 50% if late
- Collateral: 500 eddies from courier
```

### 3. Crafting Contract
**Заказ на крафт**

```
Client: Player A
Crafter: Player B

Terms:
- Craft Legendary Rifle
- Materials: provided by client
- Payment: 5,000 eddies
- Deadline: 3 days
- Quality guaranteed
```

### 4. Service Contract
**Оказание услуг**

```
Client: Player A
Mercenary: Player B

Terms:
- Escort through Badlands (dangerous zone)
- Payment: 2,000 eddies
- Success bonus: +1,000 eddies
- Collateral: 1,000 eddies
```

---

## 🔒 Escrow System

**Механика:**
```
1. Contract created
2. Both parties deposit (escrow)
3. Terms fulfilled
4. Escrow released automatically
```

**Пример:**
```
Item Exchange:
Player A deposits: Mantis Blades (in escrow)
Player B deposits: 10,000 eddies (in escrow)

Both accept contract:
→ Auto-execute
→ A receives 10,000 eddies
→ B receives Mantis Blades

Escrow guarantees safety!
```

---

## 💰 Collateral (Залог)

**Зачем:**
- Guarantee исполнения
- Penalty за нарушение

**Пример:**
```
Delivery contract:
Collateral: 500 eddies (from courier)

Success: collateral returned
Failure: collateral lost
Late: partial collateral lost
```

---

## ⚖️ Dispute Resolution (Арбитраж)

**Если спор:**
```
1. Player raises dispute
2. Both sides present evidence
3. AI moderator reviews
4. Decision made (3-5 days)
5. Escrow distributed per decision
```

---

## 📊 Структура БД

```sql
CREATE TABLE player_contracts (
    id UUID PRIMARY KEY,
    
    contract_type VARCHAR(20) NOT NULL,
    
    creator_id UUID NOT NULL,
    contractor_id UUID NOT NULL,
    
    terms JSONB NOT NULL,
    
    escrow_creator JSONB,
    escrow_contractor JSONB,
    collateral DECIMAL(12,2) DEFAULT 0,
    
    status VARCHAR(20) DEFAULT 'PENDING',
    
    deadline TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    disputed BOOLEAN DEFAULT FALSE
);
```

---

## 🔗 Связанные документы

- `economy-overview.md`

---

## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа о контрактах
