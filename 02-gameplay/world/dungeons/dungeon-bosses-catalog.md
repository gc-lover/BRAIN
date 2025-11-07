---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 20:37  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 20:37  
**api-readiness-notes:** Каталог боссов подземелий: фазы, уникальные навыки по уровням сложности, таблицы данных и API world-service.
---

# Dungeon Bosses Catalog — Инстансовые лидеры

**target-domain:** gameplay-world/dungeons  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/dungeons  
**интеграции:** combat-session, economy-service (Blueprint Forge), progression-service (skill unlocks)

## 1. Структура инстанса
- Подземелья рассчитаны на 4–10 игроков (Normal), 8–16 (Hard), 10–20 (Apex).
- Каждый босс связан с сюжетной веткой и выдает ключи для Hard Mode.
- Механики комбинируют шутерные фазы, D&D проверки и взломы.

## 2. Каталог боссов
| ID | Подземелье | Тип | Сложность | Лор |
| --- | --- | --- | --- | --- |
| `db-echo-guardian` | Blackwall Echo | Ritual | Gold → Diamond | Guardian AI NetWatch |
| `db-void-maestro` | Neon Trials | Gauntlet | Platinum | Maestro арены Night City |
| `db-bio-harvester` | Substructure 77 | Overrun | Gold | Hydra Biotechnica |
| `db-specter-warden` | Data Reliquary | Heist | Platinum | Arasaka Shadow Ops |
| `db-rail-tyrant` | Ghost Freight | Escort | Gold | Nomad renegade |

## 3. Подробности боссов
### `db-echo-guardian`
- **Фаза 1 — Resonance Shield:** навык `Mirror Pulse` (WIS DC 18) — отражает урон на 50%.
- **Фаза 2 — Algorithm Shift:** нетраннеры выполняют мини-игры, иначе `Glitch Cascade` (INT DC 19).
- **Фаза 3 — Blackwall Surge:** уникальный навык `Singularity Anchor` — притягивает игроков (STR DC 20).
- **Hard Mode:** постоянный дебафф `Cognitive Static` (-15% энерго-реген).
- **Loot:** `Echo Resonator`, `NetWatch favor`, `Dungeon Token x10`.

### `db-void-maestro`
- **Фаза 1 — Performance Duel:** `Rhythm Strike` — чередование атак, требуется синхронные уклонения.
- **Фаза 2 — Crowd Control:** зрители активируют модификаторы (случайные бафы/дебаффы).
- **Фаза 3 — Final Symphony:** `Neon Crescendo` — шкала звука, WIS DC 19 для сопротивления псих-урону.
- **Apex Mode:** добавлен `Backstage Ambush` — скрытые элиты.
- **Loot:** `Maestro Visor`, `Arena Emote Pack`, `Reputation Underground +20`.

### `db-bio-harvester`
- **Фаза 1 — Spore Swarm:** навык `Biohazard Cloud` (CON DC 18) — отравление.
- **Фаза 2 — Adaptive Mutation:** босс меняет тип урона каждые 30 сек, требуется анализ инженеров.
- **Фаза 3 — Core Extraction:** таймер 120 сек, `Harvest Protocol` — уничтожение игроков без защит.
- **Hard Mode:** глобальный дебафф `Toxic Pressure` (минус 10% макс HP).
- **Loot:** `Biotech Catalyst`, `Crafting Blueprint`, `Battle Pass progress`.

### `db-specter-warden`
- **Фаза 1 — Security Layers:** `Specter Mark` — фиксирует игрока (DEX DC 18 для освобождения).
- **Фаза 2 — Shadow Execution:** навык `Zero Trace` — убивает цель с низким HP, требует активировать `Counter Protocol` (TECH DC 20).
- **Фаза 3 — Silent Collapse:** полностью затемнённая арена, игроки пользуются термальным зрением (импланты обязательны).
- **Apex Mode:** добавлен `Corporate Sanction` — вызов элитных охранников.
- **Loot:** `Specter Cloak`, `Arasaka Black Credit`, `Hard Mode Keycard`.

### `db-rail-tyrant`
- **Фаза 1 — Rail Assault:** `Electro Volley` (REF DC 17) — поражает конвой.
- **Фаза 2 — Hijack Maneuver:** игроки разделяются на две группы для защиты и атаки.
- **Фаза 3 — Reactor Meltdown:** `Overclock Crash` — таймер 60 сек, синхронное отключение четырёх модулей.
- **Hard Mode:** добавлена `Nomad Betrayal` — случайные NPC-дезертиры.
- **Loot:** `Nomad Railgun`, `Convoy Route Access`, `Legendary Vehicle Mod`.

## 4. Уровни сложности и уникальные навыки
| Mode | Особенности | Уникальные навыки |
| --- | --- | --- |
| Normal | Базовые механики, минимальные проверки | `Mirror Pulse`, `Rhythm Strike`, `Biohazard Cloud`, `Specter Mark`, `Electro Volley` |
| Hard | Усложнённые проверки, новые адды | `Glitch Cascade`, `Backstage Ambush`, `Adaptive Mutation`, `Zero Trace`, `Hijack Maneuver` |
| Apex | Постоянные дебаффы, таймеры | `Singularity Anchor`, `Neon Crescendo`, `Harvest Protocol`, `Silent Collapse`, `Overclock Crash` |

## 5. REST API (world-service)
| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/world/dungeons/{dungeonId}/bosses` | `GET` | Каталог боссов подземелья |
| `/world/dungeons/{dungeonId}/bosses/{bossId}` | `GET` | Детали босса, фазы, навыки |
| `/world/dungeons/bosses/{bossId}/checkpoint` | `POST` | Фиксация прогресса фазы |
| `/world/dungeons/bosses/{bossId}/difficulty` | `PUT` | Смена сложности (Normal/Hard/Apex) |
| `/world/dungeons/bosses/{bossId}/rewards` | `POST` | Распределение наград |

## 6. WebSocket и телеметрия
- `wss://world-service/dungeons/{instanceId}/boss` — события `PhaseStart`, `AbilityTrigger`, `DndCheck`, `Failure`, `Success`.
- Kafka: `dungeon.boss.telemetry`, `dungeon.boss.outcome`, `dungeon.boss.progress`.
- Analytics: отслеживание wipe rate, время убийства, эффективность контр-стратегий.

## 7. Схемы данных
```sql
CREATE TABLE dungeon_bosses (
    boss_id VARCHAR(64) PRIMARY KEY,
    dungeon_id VARCHAR(64) NOT NULL,
    boss_type VARCHAR(32) NOT NULL,
    base_difficulty VARCHAR(16) NOT NULL,
    lore_hook TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dungeon_boss_phases (
    boss_id VARCHAR(64) REFERENCES dungeon_bosses(boss_id) ON DELETE CASCADE,
    phase_index INTEGER NOT NULL,
    description TEXT NOT NULL,
    unique_ability VARCHAR(64) NOT NULL,
    dnd_checks JSONB,
    loot JSONB,
    PRIMARY KEY (boss_id, phase_index)
);

CREATE TABLE dungeon_boss_difficulties (
    boss_id VARCHAR(64) REFERENCES dungeon_bosses(boss_id) ON DELETE CASCADE,
    mode VARCHAR(16) NOT NULL,
    modifiers JSONB NOT NULL,
    rewards_multiplier NUMERIC(4,2) NOT NULL,
    PRIMARY KEY (boss_id, mode)
);
```

## 8. Награды и прогрессия
- Loot распределяется через economy-service, таблица `dungeon_boss_loot`.
- Прогрессия: progression-service выдаёт навыки/таланты (например, `Neon Crescendo Resist`).
- Battle Pass: каждая победа даёт `Dungeon Badge`.
- Reputation: social-service обновляет очки (`rep.underground`, `rep.corp.arasaka`, `rep.nomad`).

## 9. Связь с Dungeon Scenarios
- Соотнесён с `dungeon-scenarios-catalog.md` (идентификаторы совпадают).
- Готовые данные для API-SWAGGER: `api/v1/gameplay/world/dungeons.yaml` получает блок `bosses`.
- Контент синхронизирован с `combat-ai-enemies.md` (уникальные навыки и уровни сложности).

## 10. Готовность
- Каталог боссов завершён, навыки и фазы описаны.
- REST/WS контракты и таблицы данных готовы для генерации API.
- Документ можно передавать в API Task Creator.

