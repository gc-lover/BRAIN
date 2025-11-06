# World State Player Impact - Part 1: Systems & Mechanics

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:54  
**Часть:** 1 из 2

[Навигация](./README.md) | [Part 2 →](./part2-database-integration.md)

---

## Краткое описание

3-уровневая система влияния игроков на world state:
1. **Personal** - личные решения (квесты, диалоги)
2. **Collective** - коллективные действия (голосования, события)
3. **Factional** - влияние фракций (территории, репутация)

---

## Personal Impact (Личное влияние)

**Что влияет:**
- Quest choices (выбор в квестах)
- Dialogue options (диалоги с NPC)
- Character actions (убийство, помощь, торговля)

**Примеры:**
- Спас NPC → он жив в личном world state
- Убил босса фракции → фракция ослаблена (для игрока)
- Выбрал сторону в конфликте → последствия в сюжете

**Persistence:** Только для конкретного игрока

---

## Collective Impact (Коллективное влияние)

**Механики:**
- **Server Events** - глобальные события на сервере
- **Voting Systems** - голосования игроков
- **Threshold Actions** - действия при достижении порога

**Примеры:**
1. **Event:** "Defend Night City from gang attack"
   - Участвуют: 1000+ игроков
   - Результат: Если защитили → город безопасен (server-wide)

2. **Voting:** "Should we rebuild the bridge?"
   - Голосуют: Все игроки сервера
   - Результат: Большинство решает (применяется ко всем)

3. **Threshold:** "Collect 10,000 supplies"
   - Вклад: Каждый игрок приносит ресурсы
   - Результат: При достижении → новая локация открывается

---

## Factional Impact (Влияние фракций)

**Territory Control:**
- Фракции контролируют территории
- Игроки влияют через reputation + actions
- Territory bonuses для членов фракции

**Reputation System:**
- Actions → Reputation points
- High reputation → Territory influence
- Faction wars → Territory changes

**Примеры:**
- Arasaka контролирует Corpo Plaza
- Valentinos захватывают Watson (через player actions)
- Nomads расширяют влияние в Badlands

---

## Conflict Resolution

**Если конфликт между уровнями:**
1. Personal > Collective (для single-player quests)
2. Collective > Factional (для server events)
3. Factional > Personal (для territory bonuses)

**Пример:**
- Personal: игрок спас NPC X
- Collective: сервер решил уничтожить локацию где NPC X
- Результат: NPC X умер (collective wins)
- Компенсация: игрок получает unique item "Memory of X"

---

[Part 2: Database & Integration →](./part2-database-integration.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:54) - Создан из world-state-player-impact.md

