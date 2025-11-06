# Экономика - Торговые гильдии (Trading Guilds)

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 22:00  
**Приоритет:** высокий (Post-MVP)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 22:00

---

## Краткое описание

Торговые гильдии (Trading Guilds) — организации игроков для совместной торговли.

**Микрофича:** Trading guilds (создание, управление, бонусы)

---

## 🏢 Концепция

**Trading Guild** — гильдия игроков для торговли

**Цели:**
- Объединение капитала
- Торговые бонусы
- Эксклюзивные маршруты
- Совместная прибыль

---

## 💼 Создание гильдии

**Требования:**
```
- Level 30+
- 50,000 eddies (регистрационный взнос)
- 5 founding members
- Guild name (unique)
```

**Процесс:**
```
1. Создать guild (founder)
2. Пригласить 4+ members
3. Заплатить 50,000 eddies
4. Guild активна
```

---

## 🎯 Бонусы гильдии

**Членам:**
- -30% listing fee (auction)
- -20% exchange fee (market)
- +5 auction slots
- Доступ к guild warehouse
- Shared market analytics

**Гильдии:**
- Общий капитал (guild bank)
- Эксклюзивные торговые маршруты
- Guild contracts
- Reputation bonuses

---

## 📊 Управление капиталом

**Guild Bank:**
```
Total capital: 1,000,000 eddies
Contributed by members
Used for:
- Bulk purchases (better prices)
- Guild investments
- Member loans
```

**Profit distribution:**
```
Guild makes 100,000 profit
Distribution:
- 40% to members (by contribution)
- 30% reinvested
- 20% for operations
- 10% to guild leader
```

---

## 🗄️ Структура БД

```sql
CREATE TABLE trading_guilds (
    id UUID PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    
    founder_id UUID NOT NULL,
    leader_id UUID NOT NULL,
    
    total_capital DECIMAL(12,2) DEFAULT 0,
    member_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE trading_guild_members (
    guild_id UUID NOT NULL,
    player_id UUID NOT NULL,
    
    role VARCHAR(20) NOT NULL, -- "LEADER", "OFFICER", "MEMBER"
    contribution DECIMAL(12,2) DEFAULT 0,
    
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (guild_id, player_id)
);
```

---

## 🔗 Связанные документы

- `economy-overview.md`

---

## История изменений

- v1.0.0 (2025-11-06 22:00) - Создание документа о торговых гильдиях
