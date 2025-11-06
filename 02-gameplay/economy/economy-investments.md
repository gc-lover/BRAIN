# Экономика - Инвестиции (Investments & Speculation)

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:23  
**Приоритет:** средний (расширение)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 22:23  
**api-readiness-notes:** Документ готов к созданию API задач. Содержит детальные механики инвестиций: типы инвестиций (корпорации, фракции, регионы, недвижимость, production chains), ROI, риски, portfolio management, структуру БД, API endpoints. Все необходимые детали для создания API спецификации присутствуют.

---

## Краткое описание

Детальная проработка системы инвестиций для NECPGAME - механики вложения капитала в корпорации, фракции, регионы и производственные цепочки для получения долгосрочной прибыли.

**Цель:** Создать глубокую инвестиционную систему, где игроки могут зарабатывать пассивный доход и влиять на развитие игрового мира через инвестиции.

---

## 📋 Основные механики

### 1. Типы инвестиций

**1.1. Corporate Investments (Инвестиции в корпорации):**

**Механика:**
- Покупка акций корпораций (см. `economy-stock-exchange.md`)
- Корпоративные облигации (fixed income)
- Venture capital (инвестиции в startup корпорации)

**ROI:**
- Дивиденды: 1-4% годовых
- Capital gains: -50% to +200% (волатильность)

**1.2. Faction Investments (Инвестиции в фракции):**

**Типы:**
- Gang Territory Development: улучшение территории банды
- Nomad Clan Expansion: расширение клана
- Corporate R&D: исследования и разработки

**Механика:**
```
Investment in Valentinos Territory:
- Amount: 50,000 eddies
- Project: upgrade Heywood district safety
- Duration: 30 days
- Expected ROI: +15% (7,500 eddies profit)
- Risks: gang war (-50% to -100%), success (+10% to +30%)
```

**Benefits:**
- Reputation gain с фракцией
- Access к exclusive items/quests
- Share of faction profits

**1.3. Regional Investments (Инвестиции в регионы):**

**Механика:**
- Инвестиции в развитие региона/города
- Улучшение инфраструктуры
- Экономический рост региона

**Пример:**
```
Investment in Pacifica Reconstruction:
- Amount: 100,000 eddies
- Project: rebuild commercial district
- Duration: 60 days
- ROI: +20% (20,000 eddies) if successful
- Benefits: property value increase, новые vendor NPC
```

**1.4. Real Estate (Недвижимость):**

**Типы недвижимости:**
- Apartments: 50,000 - 500,000 eddies
- Warehouses: 200,000 - 2,000,000 eddies
- Commercial spaces: 500,000 - 5,000,000 eddies
- Corp buildings: 10,000,000+ eddies

**ROI:**
- Rental income: 2-5% годовых
- Capital appreciation: 0-20% годовых
- Использование в бизнесе: variable

**1.5. Production Chains (Производственные цепочки):**

**Механика:**
- Инвестиции в production facility
- Автоматическое производство товаров
- Продажа на рынке

**Пример:**
```
Investment in Cyberware Factory:
- Initial cost: 500,000 eddies
- Production: 100 cyberware per day
- Cost: 50 ed per unit
- Sell price: 80 ed per unit
- Daily profit: 3,000 eddies
- ROI: ~167 days breakeven, then 2190 ed/day profit
```

---

### 2. Portfolio Management

**2.1. Диверсификация:**

**Asset Allocation:**
```
Conservative Portfolio:
- Bonds: 60%
- Blue-chip stocks: 30%
- Cash: 10%
Expected return: 5-8% annually

Balanced Portfolio:
- Stocks: 50%
- Bonds: 30%
- Real Estate: 15%
- Cash: 5%
Expected return: 8-12% annually

Aggressive Portfolio:
- Stocks: 70%
- Startups: 20%
- Commodities: 5%
- Cash: 5%
Expected return: 15-30% annually (high volatility)
```

**2.2. Rebalancing:**
- Периодическая корректировка portfolio
- Продажа переоценённых активов
- Покупка недооценённых активов
- Target allocation maintenance

---

### 3. Риски инвестиций

**3.1. Market Risk:**
- Падение рынка → потеря стоимости
- Волатильность → непредсказуемость
- Корреляция активов

**3.2. Company-Specific Risk:**
- Банкротство корпорации → потеря 100%
- Скандалы → падение цены
- Poor management → underperformance

**3.3. Political Risk:**
- Корпоративные войны
- Санкции и эмбарго
- Изменение законов

**3.4. Cyberpunk-Specific Risks:**
- Blackwall breach → tech sector crash
- Cyberpsychosis outbreak → healthcare sector boost
- Corporate hostile takeover → резкие изменения

---

### 4. Структура БД

**4.1. Таблица: player_investments**
```sql
CREATE TABLE player_investments (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    investment_type VARCHAR(50) NOT NULL,
    target_id BIGINT NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    invested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_return DECIMAL(5, 2),
    maturity_date TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
);
```

**4.2. Таблица: investment_returns**
```sql
CREATE TABLE investment_returns (
    id BIGSERIAL PRIMARY KEY,
    investment_id BIGINT REFERENCES player_investments(id),
    return_amount DECIMAL(18, 2) NOT NULL,
    return_type VARCHAR(20) NOT NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 5. API Endpoints

**5.1. REST API:**

**POST /api/v1/investments/create**
- Создать инвестицию
- Body: type, target, amount

**GET /api/v1/investments/portfolio/:playerId**
- Получить портфель инвестиций
- Response: holdings, total_value, p/l, ROI

**GET /api/v1/investments/opportunities**
- Получить доступные инвестиционные возможности
- Filters: type, min_amount, min_roi, max_risk

**POST /api/v1/investments/:investmentId/withdraw**
- Вывести инвестицию (если возможно)

---

### 6. TODO для дальнейшей проработки

**Балансировка:**
- [ ] Балансировка ROI для каждого типа инвестиций
- [ ] Балансировка рисков

---

## История изменений

- v1.0.0 (2025-11-06 22:23) - Создание документа с детальными механиками инвестиций
  - 5 типов инвестиций
  - Portfolio management и диверсификация
  - Risks analysis
  - Структура БД (2 таблицы)
  - API endpoints (4 REST)

