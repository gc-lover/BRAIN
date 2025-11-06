---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-151: api/v1/economy/logistics.yaml (2025-11-07 11:04)
- Last Updated: 2025-11-07 00:18
---


# Экономика - Логистика и перевозка

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:00  
**Приоритет:** средний (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 22:00

**target-domain:** economy  
**target-microservice:** economy-service (port 8085)  
**target-frontend-module:** modules/economy/logistics

---

## Краткое описание

Система логистики и перевозки товаров между регионами.

**Микрофича:** Транспорт, риски, страхование, конвои

---

## 🚚 Типы транспорта

### 1. Ground Transport (Наземный)
**Speed:** Slow (2-4 hours)  
**Capacity:** High (1,000 kg)  
**Cost:** Low (100 eddies)  
**Risk:** High (бандиты на дорогах)

### 2. Air Transport (Воздушный)
**Speed:** Fast (30 minutes)  
**Capacity:** Medium (500 kg)  
**Cost:** High (500 eddies)  
**Risk:** Low

### 3. Rail (Железная дорога)
**Speed:** Medium (1-2 hours)  
**Capacity:** Very High (5,000 kg)  
**Cost:** Medium (250 eddies)  
**Risk:** Medium

### 4. Courier (Курьер)
**Speed:** Very Fast (15 minutes)  
**Capacity:** Low (50 kg)  
**Cost:** Very High (1,000 eddies)  
**Risk:** Very Low

### 5. Self-Transport (Сам везет)
**Speed:** Depends on player  
**Capacity:** Inventory limit  
**Cost:** Free  
**Risk:** Very High (может быть ограблен)

---

## ⚠️ Риски перевозки

### 4 типа рисков

**1. Bandit Attack (Бандиты):**
- Probability: 15-30% (зависит от региона)
- Loss: 20-100% груза
- Defense: Hire escorts, use armored transport

**2. Accident (Авария):**
- Probability: 5%
- Loss: 10-30% груза
- Prevention: Better transport

**3. Customs/Inspection (Таможня):**
- Probability: 10%
- Loss: Delay (2-6 hours) + штраф
- Prevention: Legal goods only

**4. Weather (Погода):**
- Probability: 5%
- Loss: Delay (1-4 hours)
- Prevention: Check weather forecast

---

## 🛡️ Страхование

### 3 плана страхования

**Basic Insurance:**
- Cost: 5% от cargo value
- Coverage: 50% loss
- Deductible: 10%

**Premium Insurance:**
- Cost: 10% от cargo value
- Coverage: 90% loss
- Deductible: 5%

**Full Coverage:**
- Cost: 15% от cargo value
- Coverage: 100% loss
- No deductible

---

## 🚛 Конвои и эскорт

**Hire escorts:**
```
Solo escort: 500 eddies
- Reduces bandit risk by 50%

Full convoy (3 escorts): 1,500 eddies
- Reduces bandit risk by 80%
- Armored transport: 2,000 eddies
- Reduces bandit risk by 90%
```

---

## 🗺️ Маршруты

**Локальные (в городе):**
- Distance: < 10 km
- Time: 15 minutes
- Cost: Free
- Risk: None

**Региональные (между городами):**
- Distance: 50-200 km
- Time: 1-4 hours
- Cost: 100-500 eddies
- Risk: Medium (15%)

**Глобальные (между континентами):**
- Distance: 1,000+ km
- Time: 4-24 hours
- Cost: 1,000-5,000 eddies
- Risk: Low (air transport)

---

## 📊 Структура БД

```sql
CREATE TABLE transport_shipments (
    id UUID PRIMARY KEY,
    player_id UUID NOT NULL,
    
    from_region VARCHAR(100) NOT NULL,
    to_region VARCHAR(100) NOT NULL,
    
    cargo JSONB NOT NULL, -- Items being transported
    cargo_value DECIMAL(12,2) NOT NULL,
    
    transport_type VARCHAR(20) NOT NULL,
    transport_cost DECIMAL(12,2) NOT NULL,
    
    insurance_type VARCHAR(20),
    insurance_cost DECIMAL(12,2) DEFAULT 0,
    
    escort_hired BOOLEAN DEFAULT FALSE,
    escort_cost DECIMAL(12,2) DEFAULT 0,
    
    status VARCHAR(20) NOT NULL, -- "IN_TRANSIT", "DELIVERED", "LOST", "DELAYED"
    
    departure_at TIMESTAMP NOT NULL,
    arrival_at TIMESTAMP NOT NULL,
    delivered_at TIMESTAMP,
    
    risk_events JSONB, -- Events during transport
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔗 Связанные документы

- `economy-overview.md`
- `trading-routes-global.md`

---

## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа о логистике
