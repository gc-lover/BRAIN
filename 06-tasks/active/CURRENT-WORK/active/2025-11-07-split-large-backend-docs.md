# План разбиения больших backend документов

**Дата:** 2025-11-07 05:20  
**Статус:** in-progress  
**Приоритет:** критический

---

## Проблема

8 backend документов превышают лимит 400-500 строк. Нарушают правило "один документ == одна минифича".

---

## План разбиения

### 1. Chat System (1135 → 3 документа × ~380 строк)

**Разбить на:**
- `chat-channels.md` (~380 строк) - типы каналов, permissions, settings
- `chat-moderation.md` (~380 строк) - фильтры, spam detection, bans
- `chat-features.md` (~370 строк) - commands, formatting, voice chat, translation

### 2. Matchmaking System (1124 → 3 документа)

**Разбить на:**
- `matchmaking-queue.md` (~400 строк) - queue system, wait time, priority
- `matchmaking-algorithm.md` (~380 строк) - алгоритмы подбора, балансировка
- `matchmaking-rating.md` (~340 строк) - MMR/ELO, tiers, anti-smurf

### 3. Authentication (1113 → 3 документа)

**Разбить на:**
- `auth-registration.md` (~380 строк) - регистрация, email/password, OAuth
- `auth-login.md` (~380 строк) - login flow, JWT tokens, refresh
- `auth-security.md` (~350 строк) - 2FA, password recovery, brute force protection

### 4. Session Management (1099 → 3 документа)

**Разбить на:**
- `session-lifecycle.md` (~380 строк) - создание, heartbeat, закрытие
- `session-afk-reconnect.md` (~380 строк) - AFK detection, reconnection
- `session-security.md` (~340 строк) - concurrent sessions, timeout, monitoring

### 5. Real-Time Server (1071 → 3 документа)

**Разбить на:**
- `realtime-zones-instances.md` (~380 строк) - zone management, instances, AOI
- `realtime-synchronization.md` (~380 строк) - position sync, network protocol
- `realtime-lag-compensation.md` (~310 строк) - client prediction, server reconciliation

### 6. Inventory System (980 → 2-3 документа)

**Разбить на:**
- `inventory-storage.md` (~400 строк) - slots, stacking, weight, pickup/drop
- `inventory-equipment.md` (~400 строк) - equipment slots, equip/unequip, durability
- `inventory-bank.md` (~180 строк) - bank/stash storage, transfer

### 7. Loot System (965 → 2 документа)

**Разбить на:**
- `loot-generation.md` (~480 строк) - loot tables, generation, context, boss loot
- `loot-distribution.md` (~485 строк) - modes, rolls, auto-loot, history

### 8. Player & Character Management (918 → 2 документа)

**Разбить на:**
- `player-profiles.md` (~420 строк) - player accounts, settings, premium currency
- `character-management.md` (~498 строк) - creation, deletion, switching, slots, data

---

## Итого

**Было:** 8 больших документов (~8900 строк)  
**Станет:** 22 микрофичи (~8900 строк, но правильно структурировано)

**Преимущества:**
- ✅ Соблюдение правила 400-500 строк
- ✅ Каждый документ == одна четкая микрофича
- ✅ Легче для восприятия
- ✅ Легче для создания API tasks
- ✅ Лучше для navigation

---

## Статус выполнения

- [ ] Chat System → 3 микрофичи
- [ ] Matchmaking → 3 микрофичи
- [ ] Authentication → 3 микрофичи
- [ ] Session Management → 3 микрофичи
- [ ] Real-Time Server → 3 микрофичи
- [ ] Inventory → 3 микрофичи
- [ ] Loot → 2 микрофичи
- [ ] Player/Character → 2 микрофичи

---

## История

- **2025-11-07 05:20** - Создан план разбиения

