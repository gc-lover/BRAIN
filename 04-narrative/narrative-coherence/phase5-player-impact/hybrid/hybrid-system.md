# Гибридная система влияния игроков на мир

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 23:32

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 23:32

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-171](../../../API-SWAGGER/tasks/active/queue/task-171-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Краткое описание

Гибридная система влияния: личное + коллективное + фракционное. Три уровня работают вместе, определяя состояние мира.

---

## Три уровня влияния

### 1. Personal Impact (Личное)
- **Scope:** Только для игрока
- **Examples:** 
  - Personal quest choices
  - Personal NPC relationships
  - Personal reputation
- **Storage:** `player_world_state` table
- **Visibility:** Only player sees

### 2. Server Impact (Коллективное)
- **Scope:** Весь сервер
- **Mechanism:** Голосование игроков
- **Threshold:** 60% игроков для изменения
- **Examples:**
  - Major world events
  - Faction wars outcomes
  - Territory control
- **Storage:** `server_world_state` table
- **Visibility:** All players see

### 3. Faction Impact (Фракционное)
- **Scope:** Члены фракции
- **Mechanism:** Коллективные действия фракции
- **Examples:**
  - Faction territory gains
  - Faction reputation
  - Faction wars
- **Storage:** `faction_world_state` table
- **Visibility:** Faction members + affected players

---

## Приоритеты (конфликты)

**Если конфликт между уровнями:**
1. **Server > Faction > Personal** (для major events)
2. **Personal > Server** (для personal quests)
3. **Faction > Personal** (для territory control)

**Examples:**
- Server voted "Arasaka wins war" → все видят это
- Player personally helped Militech → personal quests отражают это
- Faction controls Watson → faction members видят benefits

---

## Integration

**Quest System:**
- Checks all 3 levels for availability
- Personal choices → personal state
- Collective quests → server votes
- Faction quests → faction state

**World State:**
- Combined from 3 levels
- Priority resolution automatic
- Conflicts logged for review

---

## Linked Documents

- [Personal System](../personal/personal-system.md)
- [Server System](../server/server-system.md)
- [Faction System](../faction/faction-system.md)
- [World State Tables](../../phase4-database/tables/world-state-tables.sql)

---

## История изменений

- v1.0.0 (2025-11-06 23:32) - Создание гибридной системы

