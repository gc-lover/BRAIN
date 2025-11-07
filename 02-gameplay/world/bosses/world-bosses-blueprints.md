---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 20:37  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 20:37  
**api-readiness-notes:** Боевая матрица мировых боссов: шкалы сложности, уникальные навыки, сюжетные триггеры и связка с сервисами.
---

# World Bosses Blueprints — Матрица способностей

**target-domain:** gameplay-world/bosses  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/events  
**интеграции:** combat-session, analytics-service, social-service, economy-service

## 1. Оглавление
- Босс → сложности → уникальные навыки и проверки.
- Сюжетные триггеры и последствия.
- Таблицы уязвимостей и контр-стратегий.

## 2. Сводная матрица
| Босс | Локация | Уровень (Base) | Базовый навык | Лиговые модификаторы |
| --- | --- | --- | --- | --- |
| `wb-neon-titan` | "Neon Crown" | Diamond | `Spectral Audit` | Silver: `Corpo Barrage`, Gold: `Shield Collapse`, Mythic: `Quantum Lock` |
| `wb-blackwall-wraith` | Blackwall Rift | Mythic | `Neural Fracture` | Bronze: `Echo Drift`, Gold: `Mind Break`, Mythic: `Singularity Howl` |
| `wb-valentinos-saint` | Santo Domingo | Platinum | `Blazing Devotion` | Bronze: `Honor Duel`, Gold: `Familia Rally`, Diamond: `Luminal Reprisal` |
| `wb-nomad-leviathan` | Badlands Hydratrack | Gold | `Sandstorm Barrage` | Silver: `Nomad Harpoon`, Platinum: `Reactive Armor`, Mythic: `Desert Collapse` |
| `wb-netwatch-sphinx` | NetWatch Spire | Diamond | `Logic Bomb` | Bronze: `Firewall Volley`, Gold: `Puzzle Lock`, Mythic: `Paradox Loop` |
| `wb-eclipse-seraph` | Orbital Eclipse Array | Mythic | `Solar Lance` | Platinum: `Gravity Rift`, Mythic: `Ablation Protocol`, Mythic+: `Radiant Cascade` |
| `wb-hivemind-behemoth` | Pacifica Reclaim | Platinum | `Rust Flood` | Silver: `Drone Swell`, Gold: `Neuro Mesh`, Mythic: `Waste Cascade` |

## 3. Подробности навыков
### `wb-neon-titan`
- `Spectral Audit` — обнуляет импланты; WIS DC 20.
- `Quantum Lock` (Mythic) — замораживает время для 6 игроков; TECH DC 22.
- Контр-стратегии: `Shield Dome`, `Memory Wipe`, `EMP Grenade`.

### `wb-blackwall-wraith`
- `Neural Fracture` — mind-control; COOL DC 22.
- `Singularity Howl` (Mythic) — вызывает червоточину, притягивает игроков.
- Контр-стратегии: netrunner quickhacks, `Counter Ritual`, `Cognitive Firewall` имплант.

### `wb-valentinos-saint`
- `Honor Duel` — PvP вызов, отказ даёт `Familia Fury`.
- `Luminal Reprisal` (Diamond) — двойной световой взрыв; REF DC 21.
- Контр-стратегии: stealth flank, `Romance Bond` buff, `Crowd Shield` гаджет.

### `wb-nomad-leviathan`
- `Sandstorm Barrage` — конусный AoE, REF DC 17.
- `Desert Collapse` (Mythic) — разрушает укрытия, требует инженеров.
- Контр-стратегии: `Barrier Drone`, `Nomad Reinforcement`, `Vehicle Anchor`.

### `wb-netwatch-sphinx`
- `Logic Bomb` — последовательность загадок, WIS DC 19.
- `Paradox Loop` (Mythic) — телепортирует группу в логический лабиринт.
- Контр-стратегии: двоичная фаза (двое решают пазлы, двое держат adds), `Temporal Anchor` мод.

### `wb-eclipse-seraph`
- `Solar Lance` — линейный orbital strike; DEX DC 21.
- `Radiant Cascade` (Mythic+) — четыре луча по диагонали, инициирует `Gravity Rift`.
- Контр-стратегии: `Orbital Spoof` quickhack, синхронный `Shield Dome`, `Grav Boots` импланты.

### `wb-hivemind-behemoth`
- `Rust Flood` — DoT-туман, CON DC 18.
- `Waste Cascade` (Mythic) — глобальный DoT, требует активации очистителей.
- Контр-стратегии: `Hazard Seal` инженерный мод, `Drone Hijack`, `Biofilter` импланты.

## 4. Режимы сложности (подробно)
| Сложность | Слотов игроков | Ключевой вызов | Дополнительные требования |
| --- | --- | --- | --- |
| Bronze | 20 | Обучение механикам | Минимум 1 Tank, 1 Support |
| Silver | 30 | Адды и пазлы | +1 нетраннер для контроля |
| Gold | 40 | Усложнённые проверки | Dedicated инженер |
| Platinum | 50 | Адаптивные фазы | Комбо ролей, Social решает исход |
| Diamond | 50 | Комбинированные навыки | Вертикальная мобильность, двойные проверки |
| Mythic | 60 | Перманентные дебаффы | Обязательны артефакты и синхронные quickhacks |
| Mythic+ | 60 | Ротация двух боссов | Активация world flags перед боем |

## 5. Сюжетные триггеры и последствия
| Босс | Триггер | Победа | Поражение |
| --- | --- | --- | --- |
| `wb-neon-titan` | `Corporate Wars Finale` | `rep.corp.arasaka +20`, скидки на корп-товары | `corporate_balance -10`, рост Militech влияния |
| `wb-blackwall-wraith` | `world.flag.blackwall_integrity < 40%` | Открывает `The Truth Beyond Blackwall` фазу 3 | Blackwall instabilities → Random Net disasters |
| `wb-eclipse-seraph` | `Arcology Eclipse Failsafe` | Активирует орбитальные миссии `Aero Division` | `world.flag.orbital_shield = critical`, повышает сложность воздушных рейдов |
| `wb-hivemind-behemoth` | `Maelstrom Neuro Swarm` | Maelstrom дружелюбны, открывают черный рынок | `rep.law.ncpd +10`, усиливаются рейды NCPD |

## 6. API Requirements
- `GET /world/bosses/abilities` — возвращает уникальные навыки и DC.
- `GET /world/bosses/{id}/counters` — контр-стратегии и рекомендуемые импланты.
- `POST /world/bosses/{id}/aftermath/apply` — фиксирует последствия (world flags, репутация).
- `GET /world/bosses/rotation` — текущая ротация (Bronze → Mythic+).

## 7. Данные и модели
```sql
CREATE TABLE world_boss_abilities (
    boss_id VARCHAR(64) NOT NULL,
    difficulty VARCHAR(16) NOT NULL,
    ability_code VARCHAR(64) NOT NULL,
    description TEXT NOT NULL,
    dnd_check JSONB,
    counters JSONB,
    PRIMARY KEY (boss_id, difficulty, ability_code)
);

CREATE TABLE world_boss_rotation (
    cycle_week INTEGER NOT NULL,
    league VARCHAR(16) NOT NULL,
    boss_id VARCHAR(64) NOT NULL,
    modifiers JSONB,
    PRIMARY KEY (cycle_week, league)
);
```

## 8. Телеметрия
- Метрика `worldBossAbilityUsage` — отслеживает применённые навыки.
- Метрика `worldBossCounterRate` — % успешных контр-стратегий.
- Алёрты: `boss_enrage`, `dnd_fail_spike`, `rotation_miss`.

## 9. Готовность
- Матрица навыков заполнена, API и таблицы описаны.
- Документ готов для передачи в API Task Creator и синхронизирован с `world-bosses-catalog.md`.
