# Экономика - Логистика и перевозка товаров (Logistics & Transport)

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:23  
**Приоритет:** средний (расширение)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 22:23  
**api-readiness-notes:** Документ готов к созданию API задач. Содержит детальные механики логистики и перевозки: транспортные средства, маршруты, риски, страхование, конвои, скорость доставки, безопасность, структуру БД, API endpoints. Все необходимые детали для создания API спецификации присутствуют.

---

## Краткое описание

Детальная проработка системы логистики и перевозки товаров для NECPGAME - механики транспортировки предметов между локациями с рисками ограбления, страхованием и конвоями.

**Цель:** Создать реалистичную систему логистики в стиле EVE Online, Albion Online и TARKOV, где транспортировка ценных товаров - рискованное, но прибыльное занятие.

---

## Источники вдохновения

### EVE Online - Hauling
- Cargo ships разной вместимости
- Риски при транспортировке
- Courier contracts
- Jump freighters и logistics

### Albion Online - Transport
- Риск PvP при транспортировке
- Караваны и escorting
- Regional price differences
- Profit от арбитража

### Elite Dangerous - Trading Routes
- Торговые маршруты между станциями
- Cargo capacity
- Piracy risks
- Trade data и route planning

---

## 📋 Основные механики

### 1. Транспортные средства

**1.1. Типы транспорта:**

**Ground Vehicles (Наземные):**
- **Cargo Van** - 500 kg capacity, speed: medium, cost: 50,000 ed
- **Cargo Truck** - 2,000 kg capacity, speed: slow, cost: 200,000 ed
- **Armored Truck** - 1,000 kg capacity, armor: high, cost: 500,000 ed

**Air Vehicles (Воздушные):**
- **AV-4 Cargo** - 1,500 kg capacity, speed: fast, cost: 1,000,000 ed
- **Heavy Lifter** - 5,000 kg capacity, speed: medium, cost: 5,000,000 ed

**Hired Transport (Наёмный):**
- **Courier NPC** - 100 kg capacity, fee: 10% of value
- **Nomad Convoy** - 10,000 kg capacity, fee: 5% + protection

**1.2. Характеристики транспорта:**
```json
{
  "vehicle_id": "cargo_truck_mk2",
  "capacity_kg": 2000,
  "speed": "slow",
  "armor": "medium",
  "fuel_consumption": "high",
  "maintenance_cost": 500,
  "insurance_cost": 1000
}
```

---

### 2. Маршруты и расстояния

**2.1. Локальные маршруты (Night City):**

**Внутригородские (5-15 минут):**
- Downtown → Watson: 10 min, risk: low
- Watson → Santo Domingo: 8 min, risk: medium
- Heywood → Pacifica: 15 min, risk: high

**2.2. Региональные маршруты (30 min - 2 hours):**

**Intercity routes:**
- Night City → Free State: 1 hour, risk: high (badlands)
- Night City → Heywood: 30 min, risk: medium
- Night City → Pacifica: 45 min, risk: high

**2.3. Глобальные маршруты (2-24 hours):**

**Continental routes:**
- Night City → Los Angeles: 4 hours, risk: medium
- Night City → Mexico City: 6 hours, risk: high
- Night City → New York: 8 hours, risk: low (air)

**Intercontinental routes:**
- Night City → Tokyo: 12 hours, risk: medium
- Night City → London: 16 hours, risk: low
- Night City → Moscow: 18 hours, risk: medium

---

### 3. Риски транспортировки

**3.1. Типы рисков:**

**Piracy/Banditry (Пираты/Бандиты):**
- Вероятность: зависит от маршрута (5% - 30%)
- Потери: 0% - 100% груза
- Защита: вооружение, конвои, route reputation

**Accidents (Аварии):**
- Вероятность: 1% - 5%
- Потери: 10% - 50% груза
- Защита: maintenance, driver skill

**Confiscation (Конфискация):**
- Вероятность: 2% - 10% (для нелегальных товаров)
- Потери: 100% груза + штраф
- Защита: stealth routes, bribery

**Weather/Environment:**
- Вероятность: 5% (в опасных зонах)
- Потери: задержка доставки
- Защита: route planning

**3.2. Расчёт риска:**

**Formula:**
```
Risk Score = Base Route Risk 
             + Cargo Value Factor 
             - Vehicle Armor Factor
             - Convoy Size Factor
             - Route Reputation Factor

Base Route Risk:
- Safe routes: 5%
- Medium routes: 15%
- Dangerous routes: 30%
- Extreme routes: 50%

Cargo Value Factor:
- < 10,000 ed: +0%
- 10,000 - 100,000 ed: +5%
- 100,000 - 1,000,000 ed: +10%
- > 1,000,000 ed: +20%
```

---

### 4. Страхование груза

**4.1. Insurance Plans:**

**Basic Insurance (70% coverage):**
- Cost: 2% от стоимости груза
- Coverage: 70% от потерь
- Deductible: 1,000 eddies

**Premium Insurance (90% coverage):**
- Cost: 5% от стоимости груза
- Coverage: 90% от потерь
- Deductible: 500 eddies

**Full Coverage Insurance (100% coverage):**
- Cost: 10% от стоимости груза
- Coverage: 100% от потерь
- No deductible
- Требует: reputation с insurance company

**4.2. Страховые компании:**

**Trauma Team Logistics:**
- Высокие тарифы
- Быстрая выплата
- Armed response при атаке

**Independent Insurance:**
- Средние тарифы
- Стандартная выплата
- No armed response

**Guild Insurance:**
- Внутреннее страхование гильдии
- Низкие тарифы для членов
- Выплаты из guild treasury

---

### 5. Конвои и эскорт

**5.1. Convoy System:**

**Solo Hauler:**
- 1 транспортное средство
- Высокий риск
- Максимальная прибыль

**Small Convoy (2-3 vehicles):**
- 1 hauler + 1-2 escorts
- Средний риск
- Стоимость escort: 10% от груза
- Profit sharing: 60% hauler, 40% escorts

**Large Convoy (4-10 vehicles):**
- Multiple haulers + armed escorts
- Низкий риск
- Стоимость: 5% от груза per escort
- Guild operation (торговая гильдия)

**5.2. Hiring Escorts:**

**NPC Escorts:**
- Solo mercenary: 1,000 ed/hour, effectiveness: medium
- Nomad guard: 2,000 ed/hour, effectiveness: high
- Corporate security: 5,000 ed/hour, effectiveness: very high

**Player Escorts:**
- Negotiate payment (typically 5-15% от груза)
- Reputation requirement
- Rating system для escort players

---

### 6. Скорость доставки

**6.1. Delivery Tiers:**

**Standard Delivery:**
- Time: normal (base time)
- Cost: base price
- Risk: normal

**Express Delivery:**
- Time: 50% faster
- Cost: +50% fee
- Risk: +10% (rush = less caution)

**Overnight Delivery:**
- Time: 75% faster
- Cost: +100% fee
- Risk: +20%

**Safe Delivery:**
- Time: +50% slower (careful routes)
- Cost: +25% fee
- Risk: -50% (safest routes)

---

### 7. Cargo Management

**7.1. Типы груза:**

**Standard Cargo:**
- Weight: normal
- Volume: normal
- Special requirements: none

**Fragile Cargo:**
- Breakage risk: 10% при accidents
- Packaging required: +10% cost
- Insurance premium: +5%

**Perishable Cargo:**
- Time limit: 24 hours
- Spoilage rate: 5% per hour after deadline
- Temperature control: +15% cost

**Illegal Cargo:**
- Confiscation risk: high
- Penalties: severe
- Profit margin: very high (risk premium)

**Hazardous Cargo:**
- Explosion risk: 1%
- Special license required
- Insurance: mandatory (15% cost)

---

### 8. Структура БД

**8.1. Таблица: transport_contracts**
```sql
CREATE TABLE transport_contracts (
    id BIGSERIAL PRIMARY KEY,
    hauler_id BIGINT NOT NULL,
    client_id BIGINT NOT NULL,
    from_location VARCHAR(100) NOT NULL,
    to_location VARCHAR(100) NOT NULL,
    cargo_type VARCHAR(50) NOT NULL,
    cargo_weight DECIMAL(10, 2) NOT NULL,
    cargo_value DECIMAL(18, 2) NOT NULL,
    delivery_fee DECIMAL(18, 2) NOT NULL,
    insurance_cost DECIMAL(18, 2),
    delivery_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**8.2. Таблица: transport_routes**
```sql
CREATE TABLE transport_routes (
    id BIGSERIAL PRIMARY KEY,
    from_location VARCHAR(100) NOT NULL,
    to_location VARCHAR(100) NOT NULL,
    distance_km INT NOT NULL,
    base_time_minutes INT NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    base_cost DECIMAL(18, 2) NOT NULL,
    INDEX idx_route (from_location, to_location)
);
```

---

### 9. API Endpoints

**10.1. REST API:**

**POST /api/v1/logistics/contract/create**
- Создать контракт на доставку
- Body: from, to, cargo, value, deadline

**GET /api/v1/logistics/routes**
- Получить доступные маршруты
- Params: from, to, vehicle_type

**POST /api/v1/logistics/hire-escort**
- Нанять эскорт
- Body: escort_type, route_id

**GET /api/v1/logistics/my-contracts/:playerId**
- Получить контракты игрока (hauler или client)

---

### 10. TODO для дальнейшей проработки

**Балансировка:**
- [ ] Точные времена доставки для всех маршрутов
- [ ] Балансировка рисков по регионам
- [ ] Балансировка costs для insurance

---

## История изменений

- v1.0.0 (2025-11-06 22:23) - Создание документа с детальными механиками логистики
  - Транспортные средства (5 типов)
  - Маршруты (локальные, региональные, глобальные)
  - Риски транспортировки (4 типа)
  - Страхование груза (3 плана)
  - Конвои и эскорт
  - Скорость доставки (4 tier)
  - Cargo management
  - Структура БД (2 таблицы)
  - API endpoints (4 REST)

