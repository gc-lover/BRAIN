# Экономика - Экономические события (Economic Events)

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:23  
**Приоритет:** средний (расширение)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 22:23  
**api-readiness-notes:** Документ готов к созданию API задач. Содержит детальные механики экономических событий: кризисы, инфляция, рецессии, торговые эмбарго, санкции, корпоративные скандалы, технологические прорывы, влияние на экономику, структуру БД, API endpoints. Все необходимые детали для создания API спецификации присутствуют.

---

## Краткое описание

Детальная проработка экономических событий для NECPGAME - динамические события, влияющие на экономику мира: кризисы, инфляция, торговые войны, санкции и корпоративные скандалы.

**Цель:** Создать живую экономику, которая реагирует на мировые события, действия игроков и корпораций, создавая возможности для спекуляции и адаптации.

---

## 📋 Основные механики

### 1. Типы экономических событий

**1.1. Economic Crisis (Экономический кризис):**

**Trigger:**
- Случайное событие (chance: 5% per quarter)
- Корпоративная война
- Политический кризис

**Effects:**
- Все цены падают на 20-40%
- Unemployment увеличивается
- Consumer spending падает
- Stock market crash (-30% to -50%)

**Duration:** 30-90 дней

**Recovery:**
- Постепенное восстановление (1-2% per day)
- Stimulus programs от корпораций/правительства
- Player investments помогают ускорить recovery

**1.2. Inflation (Инфляция):**

**Trigger:**
- Избыточная эмиссия валюты
- Дефицит товаров
- War-time economy

**Effects:**
- Все цены растут на 0.5-2% per week
- Purchasing power падает
- Salaries/quest rewards отстают от inflation

**Types:**
- **Moderate inflation:** 2-5% annually (нормально)
- **High inflation:** 10-20% annually (проблема)
- **Hyperinflation:** 50%+ annually (кризис)

**Player actions:**
- Invest в real assets (недвижимость, товары)
- Hedge через commodities
- Avoid holding cash

**1.3. Recession (Рецессия):**

**Trigger:**
- Economic crisis + prolonged downturn
- Major war
- Technological disruption

**Effects:**
- GDP падает
- Unemployment высокий
- Prices падают (deflation)
- Fewer quests available

**Duration:** 60-180 дней

**1.4. Boom (Экономический рост):**

**Trigger:**
- Technological breakthrough
- Peace после войны
- Discovery новых ресурсов

**Effects:**
- GDP растёт
- Employment высокий
- Prices растут (умеренно)
- More quests available
- Stock market bull run (+20% to +100%)

---

### 2. Торговые войны и санкции

**2.1. Trade Embargo (Торговое эмбарго):**

**Trigger:**
- Political conflict
- Corporate war
- Player actions (квесты)

**Механика:**
```
Arasaka imposes embargo on Militech goods:
→ Militech items banned in Arasaka territories
→ Smuggling opportunity (sell at 2x price)
→ Penalties if caught: confiscation + fine
→ Duration: until peace treaty
```

**Effects:**
- Товары дефицитны в blocked region
- Цены растут (2x - 5x)
- Smuggling routes открываются
- Alternative suppliers gain market share

**2.2. Sanctions (Санкции):**

**Economic Sanctions:**
- Ограничение торговли с корпорацией/регионом
- Asset freeze (заморозка активов)
- Ban на определённые товары

**Пример:**
```
NetWatch sanctions Data Jackals gang:
→ All Data Jackals members blacklisted
→ Cannot use NetWatch services
→ Bank accounts frozen
→ Asset seizure: 50% holdings
```

**2.3. Tariffs (Пошлины):**

**Import Tariffs:**
- Налог на импорт товаров
- Different rates для разных товаров
- Can be 0% to 100%

**Пример:**
```
Night City импортирует Cyberware из Tokyo:
- Base price: 1,000 eddies
- Import tariff: 20%
- Final price: 1,200 eddies
```

---

### 3. Корпоративные события

**3.1. Corporate Scandals:**

**Типы:**
- Data breach (утечка данных)
- Product recall (отзыв продукта)
- Accounting fraud (бухгалтерское мошенничество)
- Executive scandal (скандал с топ-менеджментом)

**Effects on stock:**
- -10% to -50% сразу после скандала
- Long-term recovery (depends on response)

**3.2. Mergers & Acquisitions:**

**Merger:**
- Две корпорации объединяются
- Акции конвертируются в новую корпорацию
- Synergies → рост capitalization

**Acquisition:**
- Крупная корпорация покупает меньшую
- Acquired company акции выкупаются (premium 20-50%)
- Acquirer акции могут упасть (если overpaid)

**3.3. Technological Breakthroughs:**

**Примеры:**
- Biotechnica изобретает anti-aging implant → BIOT +50%
- Kang Tao создаёт smart weapons 2.0 → KANG +30%
- ZetaTech прорыв в AI → ZETA +100%

---

### 4. Commodity Events

**4.1. Resource Shortage:**

**Trigger:**
- War disrupts supply chains
- Natural disaster
- Hoarding by players/guilds

**Effects:**
- Commodity price skyrockets (2x - 10x)
- Substitutes gain popularity
- Black market emerges

**Пример:**
```
Chromium shortage 2075:
→ Cyberware production halted
→ Chromium price: 100 ed → 500 ed (+400%)
→ Cyberware price: 1,000 ed → 2,500 ed
→ Alternative materials researched
→ Duration: 3 months
```

**4.2. Resource Discovery:**

**Trigger:**
- Exploration quest completed
- Technological advancement
- Nomad clans find new source

**Effects:**
- Commodity price crashes (-50% to -90%)
- Previous suppliers lose market share
- New trade routes established

---

### 5. Структура БД

**5.1. Таблица: economic_events**
```sql
CREATE TABLE economic_events (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    event_name VARCHAR(200) NOT NULL,
    description TEXT,
    affected_region VARCHAR(100),
    affected_sector VARCHAR(50),
    severity VARCHAR(20),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ends_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
);
```

**5.2. Таблица: event_effects**
```sql
CREATE TABLE event_effects (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT REFERENCES economic_events(id),
    effect_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id VARCHAR(100),
    modifier DECIMAL(10, 2) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 6. API Endpoints

**6.1. REST API:**

**GET /api/v1/economy/events/active**
- Получить активные экономические события
- Filters: region, type, severity

**GET /api/v1/economy/events/:eventId**
- Детали события
- Response: description, effects, duration

**GET /api/v1/economy/events/history**
- История экономических событий
- Params: timeframe, region

---

### 7. TODO для дальнейшей проработки

**Балансировка:**
- [ ] Частота событий
- [ ] Magnitude воздействия
- [ ] Duration событий

---

## История изменений

- v1.0.0 (2025-11-06 22:23) - Создание документа с детальными механиками экономических событий
  - 4 основных типа событий (crisis, inflation, recession, boom)
  - Торговые войны и санкции
  - Корпоративные события (scandals, M&A, breakthroughs)
  - Commodity events (shortage, discovery)
  - Структура БД (2 таблицы)
  - API endpoints (3 REST)

