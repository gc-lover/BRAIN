# Экономика - Контракты между игроками (Player Contracts)

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:23  
**Приоритет:** средний (расширение)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 22:23  
**api-readiness-notes:** Документ готов к созданию API задач. Содержит детальные механики контрактов между игроками: типы контрактов, условия, гарантии, escrow system, арбитраж, штрафы, репутационная система, структуру БД, API endpoints. Все необходимые детали для создания API спецификации присутствуют.

---

## Краткое описание

Детальная проработка системы контрактов между игроками для NECPGAME - формализованных соглашений с гарантиями исполнения, системой escrow и арбитража для разрешения споров.

**Цель:** Создать надёжную систему контрактов, которая позволяет игрокам безопасно заключать сделки любой сложности с защитой от мошенничества.

---

## Источники вдохновения

### EVE Online - Contracts System
- Разнообразные типы контрактов
- Courier contracts с collateral
- Item exchange contracts
- Auction contracts

### Smart Contracts (Blockchain)
- Автоматическое исполнение при выполнении условий
- Escrow (депонирование средств)
- Неизменность условий

---

## 📋 Основные механики

### 1. Типы контрактов

**1.1. Item Exchange Contract (Обмен предметами):**

**Механика:**
- Player A предлагает: Item X
- Player B предлагает: Item Y
- Оба подтверждают обмен
- Система автоматически обменивает items

**Гарантии:**
- Items блокируются при создании контракта
- Обмен атомарный (или оба получают, или никто)
- Нельзя обмануть

**Пример:**
```
Contract #12345:
- Party A: offers Legendary Weapon "Mantis Blades"
- Party B: offers 50,000 eddies + Epic Armor "Corpo Suit"
- Escrow: items locked
- Status: pending acceptance
- Expiration: 24 hours
```

**1.2. Service Contract (Контракт на услуги):**

**Типы услуг:**
- Crafting: создать предмет
- Transport: доставить груз
- Combat: выполнить боевое задание
- Hacking: взломать систему
- Healing: вылечить персонажа

**Механика:**
```
Contract #12346:
- Client: Player A
- Contractor: Player B (Techie, level 30)
- Service: Craft Epic Weapon "Cyberdeck MK5"
- Payment: 10,000 eddies
- Materials: provided by client
- Deadline: 48 hours
- Penalty: 20% refund if late
- Collateral: 5,000 eddies from contractor
```

**1.3. Courier Contract (Курьерский контракт):**

**Механика:**
- Client создаёт контракт на доставку
- Courier принимает контракт
- Получает груз
- Доставляет по адресу
- Получает payment + collateral back

**Пример:**
```
Contract #12347:
- From: Night City Downtown
- To: Tokyo Shinjuku
- Cargo: 100 kg Cyberware Components
- Reward: 5,000 eddies
- Collateral: 50,000 eddies (from courier)
- Deadline: 12 hours
- Penalty: lose collateral if failed
```

**1.4. Auction Contract (Аукционный контракт):**

**Механика:**
- Seller выставляет item на аукцион
- Multiple buyers делают ставки
- Highest bidder получает item
- Automatic payment и transfer

**Пример:**
```
Contract #12348:
- Item: Legendary Implant "Sandevistan MK6"
- Starting Bid: 100,000 eddies
- Current Bid: 250,000 eddies
- Bidders: 15
- Time Remaining: 2 hours
- Buyout: 500,000 eddies
```

---

### 2. Escrow System (Депонирование)

**2.1. Механика Escrow:**

**Процесс:**
1. Contract создаётся
2. Средства/items блокируются (transferred to escrow)
3. Условия выполняются
4. Escrow автоматически releases средства/items
5. Contract completed

**Защита:**
- Средства не могут быть withdrawn до completion
- Items не могут быть sold или traded
- Automatic release при выполнении conditions

**2.2. Escrow Fees:**

**System Escrow (автоматический):**
- Fee: 1% от суммы контракта
- Максимальная защита
- Instant release при completion

**Third-Party Escrow (NPC/Player):**
- Fee: 0.5% - 2% (negotiable)
- Manual verification
- Slower release (1-24 hours)

---

### 3. Гарантии и защита

**3.1. Collateral (Залог):**

**Механика:**
- Contractor вносит залог (10-100% от contract value)
- Если fails → collateral goes to client
- Если completes → collateral returned

**Примеры:**
- Courier contract: 100% collateral
- Service contract: 50% collateral
- Item exchange: no collateral (escrow both sides)

**3.2. Reputation System:**

**Contract Completion Rating:**
```
Rating = (Completed Contracts / Total Contracts) × 100%

5-star contractor: 95%+ completion
4-star: 85-95%
3-star: 70-85%
2-star: 50-70%
1-star: <50%
```

**Benefits of high rating:**
- Priority visibility in contract listings
- Lower escrow fees (0.5% vs 1%)
- Access to premium contracts
- Higher collateral limits

---

### 4. Арбитраж и споры

**4.1. Dispute Resolution:**

**Автоматический арбитраж:**
- System проверяет completion conditions
- Если conditions met → auto-complete
- Если не met → auto-fail

**Manual арбитраж (для complex contracts):**
- Either party открывает dispute
- Evidence submitted (screenshots, logs)
- Arbiter (GM или trusted player) reviews
- Decision: complete, partial, or fail
- Decision fee: 5% от contract value (платит проигравшая сторона)

**Trusted Arbiters:**
- Game Masters (GMs): официальные
- High-reputation players: community arbiters
- NPC Fixers: платные (10% fee)

---

### 5. Структура БД

**5.1. Таблица: player_contracts**
```sql
CREATE TABLE player_contracts (
    id BIGSERIAL PRIMARY KEY,
    contract_type VARCHAR(50) NOT NULL,
    client_id BIGINT NOT NULL,
    contractor_id BIGINT,
    description TEXT NOT NULL,
    payment DECIMAL(18, 2) NOT NULL,
    collateral DECIMAL(18, 2),
    deadline TIMESTAMP,
    status VARCHAR(20) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);
```

**5.2. Таблица: contract_escrow**
```sql
CREATE TABLE contract_escrow (
    id BIGSERIAL PRIMARY KEY,
    contract_id BIGINT REFERENCES player_contracts(id),
    escrow_type VARCHAR(20) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    locked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP
);
```

---

### 6. API Endpoints

**6.1. REST API:**

**POST /api/v1/contracts/create**
- Создать контракт
- Body: type, description, payment, terms

**GET /api/v1/contracts/search**
- Поиск доступных контрактов
- Filters: type, min_payment, max_payment, region

**POST /api/v1/contracts/:contractId/accept**
- Принять контракт
- Body: contractor_id, collateral

**POST /api/v1/contracts/:contractId/complete**
- Завершить контракт
- Requires: conditions met

**POST /api/v1/contracts/:contractId/dispute**
- Открыть спор по контракту
- Body: reason, evidence

---

### 7. TODO для дальнейшей проработки

**Расширения:**
- [ ] Long-term contracts (месяцы)
- [ ] Subscription contracts (recurring)
- [ ] Multi-party contracts (3+ players)

---

## История изменений

- v1.0.0 (2025-11-06 22:23) - Создание документа с детальными механиками контрактов
  - 4 типа контрактов (exchange, service, courier, auction)
  - Escrow system с гарантиями
  - Collateral и репутационная система
  - Арбитраж и dispute resolution
  - Структура БД (2 таблицы)
  - API endpoints (5 REST)

