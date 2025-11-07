---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 21:25  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 21:25  
**api-readiness-notes:** Каталог культовых защитников фракций/банд: роли, навыки, триггеры появления, REST/WS контракты и схемы данных для world-service.
---

# Faction Cult Defenders — Культовые защитники фракций

**target-domain:** gameplay-world/factions  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/events  
**интеграции:** combat-session, social-service (репутация), analytics-service, economy-service (награды)

## 1. Назначение
- Дать каждой крупной фракции/банде своего культового защитника (legendary defender) для открытых событий, рейдов фракций и видимых точек обороны.
- Обеспечить уникальные механики, завязанные на лор Cyberpunk и прогрессию игрока.
- Поддержать API-запросы world-service: расписание спавнов, навыки, лут, последствие для world-state.

## 2. Сводная таблица защитников
| Фракция/Банда | Защитник | Роль | Уникальный навык | Триггер появления |
| --- | --- | --- | --- | --- |
| Arasaka Security | `Akari "Iron Lotus" Sato` | Tactical Controller | `Lotus Protocol` — массовая блокировка имплантов | Корпоративное вторжение в районах Corpo Plaza |
| Militech | `Commander Saul "Bastion" Mercer` | Heavy Tank | `Aegis Barricade` — развертывание энергетической крепи | Защита транспортных колонн Militech Convoy |
| NetWatch | `Agent Aya "Firewall" Quinn` | Netrunner Support | `Black ICE Singularity` — нейрошквал на вражеских хакеров | Атаки Rogue AI на узлы NetWatch |
| Valentinos | `Sister Marisol "La Santa" Cruz` | Faithful Guardian | `Divine Mark` — благословение союзников и кара изменников | Защита святынь Санто-Доминго, романтические цепочки |
| Maelstrom | `Chrome Prophet Kragg` | Berserk Bruiser | `Overdrive Frenzy` — ускорение всех киберимплантов в радиусе | Захват фабрик киберимплантов или рейды против NCPD |
| Voodoo Boys | `Loa Whisperer Etienne` | Spiritual Netrunner | `Loa Possession` — удержание вражеских дронов | Вторжения в дата-центры или Blackwall breaches |
| Nomad Coalition | `Rally Marshal Juniper` | Mobile Defender | `Duststorm Phalanx` — песчаная буря и броня транспортов | Оборона караванов в Badlands |
| Tiger Claws | `Kuniko "Ghostblade" Ito` | Agile Assassin | `Mirror Veil` — отражение снарядов и контратакующий дэш | Защита клубов Japantown |
| Moxes | `Doc Lyric` | Support/Medic | `Chrome Revival` — массовое восстановление имплантов | Нападения на клубы Lizzie's, ивенты романтических цепочек |

## 3. Детали по защитникам
### Arasaka — Akari "Iron Lotus" Sato
- **Роль:** Tactical Controller, уровни сложности Diamond/Mythic.
- **Лор:** бывший оперативник подразделения Arasaka Saburo Guard, оснащена Sandevistan Mk.IV и экспериментальным Lotus Protocol.
- **Навыки:**
  - `Lotus Protocol` — накладывает на врагов `implant_lock` (TECH DC 22). Успех даёт временную неуязвимость имплантам союзников.
  - `Serpent Blossom` — дроны-лотосы выпускают микродроны (INT DC 20 для нейтрализации).
- **Награды:** Arasaka loyalty bonds, планы корп-оружия, титул "Lotus Ally".
- **Последствия:** Победа укрепляет `rep.corp.arasaka`, провал снижает `corporate_balance` и вызывает контрнабег Militech.

### Militech — Commander Saul "Bastion" Mercer
- **Роль:** Heavy Tank, Bronze → Diamond.
- **Лор:** ветеран четвёртой корпорат. войны, напичкан армейскими экзокостюмами.
- **Навыки:**
  - `Aegis Barricade` — разворачивает мобильный щит (STR DC 21 для пробития).
  - `Linked Firegrid` — синхронизирует огонь турелей.
- **Награды:** Militech armor cores, армейский транспорт, репутация Militech.
- **Последствия:** Победа повышает безопасность городских транспортных линий.

### NetWatch — Agent Aya "Firewall" Quinn
- **Роль:** Support netrunner, Diamond.
- **Навыки:**
  - `Black ICE Singularity` — наносит нет-урон, заставляя врагов проходить COOL DC 22.
  - `Data Purge` — очищает союзные импланты от вирусов.
- **Награды:** NetWatch clearance, редкие cyberdeck modules.
- **Последствия:** Блокирует spawn Rogue AI на 24 часа.

### Valentinos — Sister Marisol "La Santa" Cruz
- **Роль:** Faithful Guardian, Silver → Diamond.
- **Навыки:**
  - `Divine Mark` — бафф союзникам (+20% resist), врагам — штраф (WIS DC 18).
  - `Familia Rally` — призыв NPC-сторонников.
- **Последствия:** Победа повышает `rep.street.valentinos`, открывает романтические ветки.

### Maelstrom — Chrome Prophet Kragg
- **Роль:** Berserk Bruiser, Gold → Mythic.
- **Навыки:**
  - `Overdrive Frenzy` — разгон имплантов (CON DC 19 против перегрева).
  - `Neural Overclock` — случайные эффекты (benefit/penalty) для игроков с высоким имплант процентом.
- **Последствия:** Победа приносит Maelstrom favor, провал усиливает рейды NCPD.

### Voodoo Boys — Loa Whisperer Etienne
- **Роль:** Spiritual Netrunner, Mythic.
- **Навыки:**
  - `Loa Possession` — захват дронов/турелей (TECH DC 20).
  - `Ghostwalk` — фазы, где игроки с низкой COOL получают хаос-эффекты.
- **Последствия:** Победа стабилизирует Blackwall events.

### Nomad Coalition — Rally Marshal Juniper
- **Роль:** Mobile Defender, Gold → Mythic.
- **Навыки:**
  - `Duststorm Phalanx` — песчаная буря (REF DC 18 для видимости).
  - `Convoy Sync` — бафф транспорта, требует координации инженеров.
- **Последствия:** Победа повышает `rep.nomad`, открывает скидки на модификации транспорта.

### Tiger Claws — Kuniko "Ghostblade" Ito
- **Роль:** Assassin Controller, Platinum.
- **Навыки:**
  - `Mirror Veil` — отражение снарядов (DEX DC 21 для попадания).
  - `Kaiken Blink` — телепортация и критическая атака.
- **Последствия:** Победа открывает катаны Ghostblade, провал снижает безопасность Japantown.

### Moxes — Doc Lyric
- **Роль:** Support Medic, Silver → Gold.
- **Навыки:**
  - `Chrome Revival` — массовое восстановление имплантов.
  - `Glitch Ward` — снятие дебаффов (TECH DC 17).
- **Последствия:** Победа повышает `rep.moxes`, разблокирует романтические сцены и косметику.

## 4. Механика столкновений
- **Сложность:** Bronze → Mythic+, аналогично мировым боссам, но на фракционных аренах.
- **Композиция:** Основной защитник + 2-3 уникальных элиты поддержки.
- **Влияние мира:** Победа/поражение меняют world flags (`faction_influence`, `district_security`, `blackwall_stability`).
- **Проявления:** случайные вторжения, запланированные события, ответные рейды.

## 5. REST/WS контуры (world-service)
| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/world/factions/defenders` | `GET` | Список защитников, фильтры по фракции/сложности |
| `/world/factions/defenders/{id}` | `GET` | Детали защитника, навыки, лут, требования |
| `/world/factions/defenders/{id}/schedule` | `GET` | Расписание появления, привязка к world-state |
| `/world/factions/defenders/{id}/spawn` | `POST` | Принудительный запуск события (гейм-мастер) |
| `/world/factions/defenders/{id}/outcome` | `POST` | Фиксация результата (победа/поражение), обновление world flags |

**WebSocket:** `wss://world-service/factions/{defenderId}` — события `Spawn`, `Phase`, `AbilityCast`, `PlayerDown`, `Outcome`, `AftermathApplied`.

## 6. Схемы данных
```sql
CREATE TABLE faction_defenders (
    defender_id VARCHAR(64) PRIMARY KEY,
    faction_code VARCHAR(64) NOT NULL,
    defender_name VARCHAR(120) NOT NULL,
    role VARCHAR(32) NOT NULL,
    base_difficulty VARCHAR(16) NOT NULL,
    lore_summary TEXT NOT NULL,
    spawn_triggers JSONB NOT NULL,
    rewards JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faction_defender_abilities (
    defender_id VARCHAR(64) REFERENCES faction_defenders(defender_id) ON DELETE CASCADE,
    ability_code VARCHAR(64) NOT NULL,
    description TEXT NOT NULL,
    difficulty_scaling JSONB NOT NULL,
    dnd_checks JSONB,
    counters JSONB,
    PRIMARY KEY (defender_id, ability_code)
);

CREATE TABLE faction_defender_outcomes (
    defender_id VARCHAR(64) REFERENCES faction_defenders(defender_id) ON DELETE CASCADE,
    outcome VARCHAR(16) NOT NULL,
    world_flag_updates JSONB NOT NULL,
    reputation_updates JSONB,
    rewards JSONB,
    PRIMARY KEY (defender_id, outcome)
);
```

## 7. Синергия с существующими системами
- **World Bosses:** защитники могут вызывать или останавливать мировых боссов соответствующих фракций.
- **Dungeon Bosses:** эвенты защитников открывают доступ к осадным версиям подземелий.
- **Progression:** победы дают фракционные перки/импланты, усиливающие PvP и кооперацию.
- **Social-service:** обновляет отношения игроков с фракциями, открывает ветки романтики, контрактов.

## 8. Готовность
- Фракционные защитники полностью описаны, есть механики, REST/WS контракты, схемы данных и последствия.
- Документ готов к API Task Creator и синхронизирован с `world-bosses-catalog.md`, `dungeon-bosses-catalog.md` и `combat-ai-enemies.md`.

