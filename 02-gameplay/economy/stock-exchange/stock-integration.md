# Биржа акций - Интеграция с геймплеем

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:45  
**Приоритет:** высокий (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 21:45

---

## Краткое описание

Интеграция биржи акций с другими игровыми системами.

**Микрофича:** Квесты → Акции, Фракции → Акции, События → Акции

---

## 🎮 Квестовая интеграция

### Quest Outcomes → Stock Prices

**Примеры квестов:**

**1. "Corporate Espionage"**
```
Quest chain: Steal Militech secrets for Arasaka

Outcomes:
Success (Arasaka gets secrets):
→ ARSK: +10% (advantage gained)
→ MLTC: -8% (secrets stolen)

Failure (caught):
→ ARSK: -5% (scandal)
→ MLTC: +3% (defended)

Betray both (sell to Kang Tao):
→ ARSK: -12%
→ MLTC: -12%
→ KANG: +15%
```

**2. "Biotechnica Sabotage"**
```
Quest: Destroy Biotechnica lab

Before quest:
BIOT: 480 eddies

After quest:
BIOT: 336 eddies (-30%)

Recovery:
Week 1: 360 (+7% recovery)
Week 2: 384 (+7%)
Week 3: 410 (+7%)
Final: 432 eddies (-10% permanent)
```

### Investment Quests

**"Stock Market Tutorial"**
- Buy first stock
- Receive first dividend
- Sell for profit
- Reward: 1,000 eddies + broker fee discount

**"Insider Information"** (grey quest)
- NPC gives tip about upcoming event
- Player can act on info
- Risk: Insider trading detection
- Reward: Potential huge profit OR ban

---

## 🏢 Фракционная интеграция

### Faction Wars → Stocks

```
Corporate War: Arasaka vs Militech

Player chooses: Arasaka

Arasaka wins:
→ ARSK: +30%
→ Player's ARSK holdings: profit!

Militech wins:
→ MLTC: +30%
→ Player's choice was wrong, missed profit
```

### Reputation Benefits

```
High reputation with Arasaka:
- Access to preferred stock (ARSK-P)
- Insider tips (legal info)
- Broker fee discount (-10%)
```

---

## 🌍 World Events → Stocks

```
Global Event: "Energy Crisis"
→ PTRC: +30%
→ SVOL: +35%
→ All others: -5%

Global Event: "AI Breakthrough"
→ All tech stocks: +15%

Global Event: "War"
→ Defense stocks: +20%
→ Others: -10%
```

---

## 🔗 Связанные документы

- `stock-events.md` - Детали влияния событий
- `../../../04-narrative/quest-system.md` - Квесты

---

## История изменений

- v1.0.0 (2025-11-06 21:45) - Создание документа об интеграции

