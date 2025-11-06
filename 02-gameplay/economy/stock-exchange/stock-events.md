# Биржа акций - Влияние событий на цены

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:45  
**Приоритет:** высокий (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:45

---

## Краткое описание

Влияние игровых событий на цены акций корпораций.

**Микрофича:** Events → Stock Prices (квесты, войны, скандалы)

---

## 🎮 Типы событий

### 1. Quest Events (Квестовые)

**Механика:** Завершение квестов влияет на акции

**Примеры:**
```
Quest: "Corpo Wars: Choose Arasaka"
Outcome: Arasaka wins territory
Impact: ARSK +15%, MLTC -10%

Quest: "Sabotage Militech Factory"
Outcome: Factory destroyed
Impact: MLTC -20%, KANG +8% (competitor benefits)

Quest: "Netrunner: Expose Arasaka Scandal"
Outcome: Scandal revealed
Impact: ARSK -25%, NTWT +5% (NetWatch investigates)
```

### 2. Faction Wars (Фракционные войны)

**Механика:** Исход войн влияет на цены

**Пример:**
```
Corporate War: Arasaka vs Militech

Stage 1 (Start):
ARSK: -5% (uncertainty)
MLTC: -5% (uncertainty)

Stage 2 (Arasaka winning):
ARSK: +10%
MLTC: -15%

Stage 3 (Arasaka victory):
ARSK: +30% (total from start)
MLTC: -35% (major loss)

Related stocks:
KANG: +5% (sells weapons to both sides)
TRMA: +8% (medical services demand up)
```

### 3. Territory Control (Территориальный контроль)

**Механика:** Контроль территорий влияет на акции

**Пример:**
```
Watson district captured by Arasaka:
→ ARSK: +5% (new territory)
→ Revenue increase expected

Pacifica becomes autonomous:
→ All corpo stocks: -2% (lost control)
→ Nomad-aligned stocks: +5%
```

### 4. Corporate Scandals (Корпоративные скандалы)

**Механика:** Скандалы обрушивают цены

**Примеры:**
```
Scandal: "Arasaka Data Breach" (quest outcome)
Severity: Major
Duration: 2 weeks

Impact:
Day 1: ARSK -15% (panic selling)
Week 1: ARSK -25% (investigation)
Week 2: ARSK -30% (lawsuits)
Recovery: +10% (crisis management)
Final: -20% net (lasting damage)

Opportunity:
Buy at -30% (bottom)
Sell when recovers to -10%
Profit: 20% swing
```

### 5. Technological Breakthroughs (Прорывы)

**Механика:** Новые технологии влияют на сектор

**Примеры:**
```
Event: "Zetatech announces new AI chip"
Impact:
ZETA: +40% (innovator)
IEC: -15% (competitor loses)
EUBM: -10% (competitor loses)

Event: "Raven Microcybernetics: new implant"
Impact:
RAVN: +25% (innovation)
ARSK: +5% (uses implants in products)
```

### 6. Economic Events (Экономические)

**Механика:** Глобальные экономические события

**Примеры:**
```
Event: "Economic Boom in Night City"
Impact: All stocks +5-10%

Event: "Recession"
Impact: All stocks -10-20%
Defensive stocks (TRMA, BIOT): -5% (less affected)
Cyclical stocks (PTRC, MLTC): -25% (more affected)

Event: "Energy Crisis"
Impact:
PTRC: +30% (oil demand up)
SVOL: +35%
TRMA: -5% (fuel costs up)
```

---

## 📉 Формулы влияния

### Базовая formula

```
new_price = current_price × (1 + event_impact_percent + modifiers)

event_impact_percent: от -50% до +100% (зависит от события)

modifiers:
- sector_alignment: если событие релевантно сектору
- size_modifier: крупные корпорации меньше волатильны
- player_actions: количество игроков, завершивших квест
```

### Примеры расчета

**Quest impact:**
```
Quest: "Destroy Militech Convoy"
Base impact: -10% для MLTC

Modifiers:
- Only 10 players completed: ×0.5 = -5%
- Militech controls 3 territories: ×0.8 = -4%

Final: MLTC price -4%

If 1,000 players completed:
- Mass impact: ×2.0 = -20%
```

**Faction War impact:**
```
Corporate War: Arasaka WINS

Arasaka:
Base impact: +30%
Won 5 territories: +10%
Killed enemy CEO: +15%
Total: +55%

Militech:
Base impact: -35%
Lost 5 territories: -10%
CEO killed: -20%
Total: -65% (massive crash!)
```

---

## ⏱️ Продолжительность влияния

### Immediate (Мгновенное)

**Trigger:** Quest completion, battle win  
**Duration:** Instant price change  
**Recovery:** May recover in days/weeks

**Пример:**
```
Quest completed: "Expose Arasaka"
→ ARSK drops 15% in 1 minute
→ Recovers 5% next day
→ Stabilizes at -10% after 1 week
```

### Short-term (Краткосрочное)

**Trigger:** Minor events  
**Duration:** 1-7 days  
**Recovery:** Full recovery expected

**Пример:**
```
Event: "Petrochem pipeline leak"
Impact: PTRC -8%
Recovery: 7 days back to normal
```

### Long-term (Долгосрочное)

**Trigger:** Major events (wars, CEO death)  
**Duration:** Weeks to months  
**Recovery:** May never fully recover

**Пример:**
```
Event: "Corporate War - Militech LOSES"
Impact: MLTC -50%
Duration: Permanent (lasting damage)
Recovery: Slow rebuild over years
```

### Permanent (Перманентное)

**Trigger:** Delisting, bankruptcy  
**Duration:** Forever  
**Recovery:** None

**Пример:**
```
Event: "Arasaka Bankrupt" (extreme quest outcome)
Impact: ARSK delisted, price → 0
Recovery: None (corporation destroyed)
Players lose all investment
```

---

## 🎯 Player Opportunities

### Buy the Dip

**Strategy:** Покупать после негативных событий

**Пример:**
```
Scandal: Arasaka data breach
ARSK: 1,000 → 700 (-30%)

Player analysis:
"Scandal is temporary, Arasaka will recover"

Action: Buy 100 ARSK @ 700 = 70,000 eddies

2 weeks later:
ARSK recovers to 900 (+29% from bottom)
Portfolio value: 90,000 eddies
Profit: 20,000 eddies (+29%)
```

### Sell Before Disaster

**Strategy:** Продавать перед плохими событиями

**Пример:**
```
Player doing quest: "Sabotage Militech"
Knows: Quest will hurt Militech stock

Action BEFORE quest completion:
Sell all MLTC shares @ 850

Quest completed:
MLTC drops to 680 (-20%)

Player avoided: 20% loss
Can buy back lower if wants
```

### Event Speculation

**Strategy:** Предсказывать события и покупать заранее

**Пример:**
```
Player notices:
- Corporate War starting (rumors)
- Arasaka likely to win (strong military)

Action: Buy ARSK @ 1,000 (before war starts)

War outcome: Arasaka wins
ARSK: +30% → 1,300

Profit: 300 per share (+30%)
Risk: If wrong, may lose
```

---

## 📊 Event Impact Table

| Event Type | Example | Impact Range | Duration |
|------------|---------|--------------|----------|
| **Quest (small)** | Minor mission | ±5% | 1-3 days |
| **Quest (major)** | Main questline | ±15% | 1-2 weeks |
| **Faction War** | Corporate war | ±30% | Weeks-Months |
| **Scandal** | Data breach | -25% to -40% | 2-4 weeks |
| **Tech Breakthrough** | New invention | +40% to +100% | Permanent |
| **CEO Death** | Assassination | -15% to -30% | 1-2 months |
| **Territory Gain** | Capture district | +5% to +10% | Permanent |
| **Economic Crisis** | Recession | -20% (all) | Months |
| **Delisting** | Bankruptcy | -100% | Permanent |

---

## 🔗 Связанные документы

- `stock-exchange-overview.md` - Обзор
- `stock-corporations.md` - Корпорации
- `stock-trading.md` - Торговля
- `stock-integration.md` - Детальная интеграция с квестами

---

## История изменений

- v1.0.0 (2025-11-06 21:45) - Создание документа о влиянии событий
  - Определены типы событий (quests, wars, scandals, tech, economic)
  - Описаны формулы влияния на цены
  - Определена продолжительность влияния
  - Описаны стратегии для игроков
  - Создана таблица event impact

