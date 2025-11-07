---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 20:37  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 20:37  
**api-readiness-notes:** Матрица способностей боссов подземелий: режимы сложности, уникальные навыки, проверки и контр-стратегии.
---

# Dungeon Boss Abilities Matrix

**target-domain:** gameplay-world/dungeons  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/dungeons  
**интеграции:** combat-session, analytics-service, progression-service

## 1. Сводная таблица
| Босс | Подземелье | Режим | Навык | Проверка | Контр-стратегии |
| --- | --- | --- | --- | --- | --- |
| `db-echo-guardian` | Blackwall Echo | Apex | `Singularity Anchor` | TECH DC 21 | `Counter Ritual`, `Cognitive Firewall` |
| `db-void-maestro` | Neon Trials | Platinum | `Neon Crescendo` | WIS DC 19 | `Audio Dampener`, `Reflect Shield` |
| `db-bio-harvester` | Substructure 77 | Hard | `Harvest Protocol` | CON DC 19 | `Hazard Seal`, `Antidote Injector` |
| `db-specter-warden` | Data Reliquary | Apex | `Zero Trace` | TECH DC 20 | `Specter Snare`, `Infrared Goggles` |
| `db-rail-tyrant` | Ghost Freight | Hard | `Overclock Crash` | STR+TECH DC 19 | `Power Relay Hack`, `Nomad Shield` |
| `db-glass-reaper` | Aurora Vault | Apex | `Aurora Collapse` | INT DC 20 | `Prism Redirector`, `Hard Light Barrier` |
| `db-cinder-archon` | Reactor Depths | Mythic | `Inferno Protocol` | STR DC 21 | `Thermal Dampener`, `Energy Drain` |

## 2. Детализация навыков
### `db-echo-guardian`
- `Mirror Pulse` — отражает урон, WIS DC 18.
- `Glitch Cascade` — периодические всплески цифрового урона.
- Контры: `EMP Burst`, `Shield Dome`, `Memory Wipe`.

### `db-void-maestro`
- `Rhythm Strike` — серийные атаки под музыку.
- `Neon Crescendo` — финальный взрыв, WIS DC 19.
- Контры: `Audio Dampener`, `Sandevistan`, `Blink Dash`.

### `db-bio-harvester`
- `Biohazard Cloud` — ядовитый туман.
- `Harvest Protocol` — сбор игроков в контейнеры, CON DC 19.
- Контры: `Hazard Seal`, `Biofilter Implant`, `Chemical Purge`.

### `db-specter-warden`
- `Specter Mark` — фиксирует цель, DEX DC 18.
- `Zero Trace` — мгновенное убийство, TECH DC 20.
- Контры: `Specter Snare`, `Infrared Goggles`, синхронные quickhacks.

### `db-rail-tyrant`
- `Electro Volley` — поражает линию вагона.
- `Overclock Crash` — инициирует meltdown, STR/TECH DC 19.
- Контры: `Nomad Shield`, `Breaker Switch`, `Deploy Turret`.

### `db-glass-reaper`
- `Light Fracture` — отражённые лучи, INT DC 19.
- `Aurora Collapse` — взрыв кристаллов, TECH DC 21.
- Контры: `Prism Redirector`, `Hard Light Barrier`, `Shadow Step`.

### `db-cinder-archon`
- `Thermal Lance` — прожигает платформы.
- `Inferno Protocol` — финальный взрыв, STR DC 21.
- Контры: `Thermal Dampener`, `Energy Drain`, `Gravity Tether`.

## 3. Режимы
| Mode | Модификатор | Новые механики |
| --- | --- | --- |
| Normal | Обучающие фазы | Минимум 1 контрольная механика |
| Hard | Дополнительные адды | Таймеры и ресурсы |
| Apex | Постоянные дебаффы | Double DC + комбинированные проверки |
| Mythic | Двойные таймеры | Многосегментные боссы, Overkill урон |

## 4. Контр-стратегии (таблица)
| Тип | Пример | Источник |
| --- | --- | --- |
| Quickhack | `Counter Ritual`, `Logic Jam` | netrunner ability tree |
| Gadget | `EMP Burst`, `Prism Redirector`, `Audio Dampener` | crafting/loot |
| Implant | `Cognitive Firewall`, `Biofilter`, `Thermal Dampener` | progression/implants |

## 5. API контуры
- `GET /world/dungeons/bosses/abilities` — матрица навыков.
- `GET /world/dungeons/bosses/{bossId}/counters` — рекомендованные контр-стратегии.
- `POST /world/dungeons/bosses/{bossId}/analytics` — отправка телеметрии ability/counter.

## 6. Схемы данных
```sql
CREATE TABLE dungeon_boss_abilities (
    boss_id VARCHAR(64) NOT NULL,
    mode VARCHAR(16) NOT NULL,
    ability_code VARCHAR(64) NOT NULL,
    description TEXT NOT NULL,
    dnd_check JSONB,
    counters JSONB,
    PRIMARY KEY (boss_id, mode, ability_code)
);

CREATE TABLE dungeon_boss_counters (
    boss_id VARCHAR(64) NOT NULL,
    counter_type VARCHAR(16) NOT NULL,
    item_code VARCHAR(64) NOT NULL,
    source VARCHAR(64) NOT NULL,
    effect TEXT NOT NULL,
    PRIMARY KEY (boss_id, counter_type, item_code)
);
```

## 7. Телеметрия
- Метрика `dungeonAbilityUsage` — частота навыков.
- Метрика `dungeonCounterSuccess` — % успешных контр-мер.
- Алёрты: `counter_fail_spike`, `ability_overlap`, `timer_breach`.

## 8. Готовность
- Матрица способностей сформирована, API и таблицы определены.
- Документ готов для API Task Creator и синхронизируется с `dungeon-bosses-catalog.md`.
