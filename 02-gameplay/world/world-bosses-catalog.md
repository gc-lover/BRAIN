---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 20:37  
**Приоритет:** highest  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 20:37  
**api-readiness-notes:** Каталог мировых боссов с фазами, уникальными навыками, сюжетными событями и REST/WebSocket контрактами для world-service.
---

# World Bosses Catalog — Открытые столкновения

**target-domain:** gameplay-world  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/events  
**интеграции:** combat-session, social-service (репутация), economy-service (награды)

## 1. Краткое описание
- Мировые боссы — глобальные события на 20–60 игроков в открытых зонах Night City и Badlands.
- Активируются циклами лиги (Bronze → Diamond) и сюжетными флагами global-state.
- Используют гибрид D&D проверок + real-time боёвки, поддерживают фазовые WebSocket события.

## 2. Каталог боссов
| ID | Локация | Эпоха | Базовая сложность | Сюжетный триггер |
| --- | --- | --- | --- | --- |
| `wb-neon-titan` | Мега-башня "Neon Crown" | 2089 | Diamond | Завершение арки `Corporate Wars: Finale` |
| `wb-blackwall-wraith` | Разлом за Blackwall | 2091 | Mythic | Флаг `world.flag.blackwall_integrity < 40%` |
| `wb-valentinos-saint` | Собор Санто-Доминго | 2078 | Platinum | Ветка `Valentinos Blood Oath` |
| `wb-nomad-leviathan` | Badlands, зона гидротрассы | 2082 | Gold | Миссия `Nomad Convoy Crisis` |
| `wb-netwatch-sphinx` | Небоскрёб NetWatch | 2087 | Diamond | Выполнение `quest-main-042-black-barrier-heist` |

## 3. Фазовые сценарии
### `wb-neon-titan`
- **Фаза 1 — Corporate Siege:** уничтожить четыре щита, D&D checks TECH DC 18.
- **Фаза 2 — Drone Overlord:** Titan разделяется на три дрона, требует координации DPS/Tank.
- **Фаза 3 — Reality Sync:** уникальный навык `Spectral Audit` — обнуляет импланты игроков (WIS DC 20, иначе потеря навыков на 15 сек).
- **Лут:** `Legendary Smart Cannon`, `Arasaka Dividends`, `League Token x50`.
- **Сюжет:** исход меняет `corporate_balance` и репутацию Arasaka/Militech.

### `wb-blackwall-wraith`
- **Фаза 1 — Shattered Gate:** массовый DoT `Entropy Leak`, STR DC 21 для стабилизации зарядов.
- **Фаза 2 — Echo Storm:** навык `Neural Fracture` — случайный игрок управляется врагом (COOL DC 22 для сопротивления).
- **Фаза 3 — True Wraith:** чередует физические и цифровые формы, требует нетраннеров.
- **Лут:** `Primordial AI Core`, `Blackwall Shards`, `NetWatch Reputation +40`.
- **Сюжет:** исход влияет на ветку `The Truth Beyond Blackwall`.

### `wb-valentinos-saint`
- **Фаза 1 — Procession Ambush:** защита NPC, использование `Honor Duel` (COOL DC 18).
- **Фаза 2 — Martyr's Rage:** навык `Blazing Devotion` — усиливает боссов в радиусе, требует точечного фокуса.
- **Фаза 3 — Santo Judgment:** массовый AoE, игроки выбирают пощадить или казнить босса, влияет на репутацию Valentinos/NCPD.
- **Лут:** `Saint Relic Cyberarm`, `Valentinos Contacts`, `Romance Unlock Flag`.

### `wb-nomad-leviathan`
- **Фаза 1 — Convoy Defense:** защита колонны, навык босса `Sandstorm Barrage` (REF DC 17 для уклонения).
- **Фаза 2 — Adaptive Armor:** требует инженерного взаимодействия (TECH DC 20) для снятия щитов.
- **Фаза 3 — Reactor Overload:** таймер 90 сек, навык `Reactor Implosion` — провал = wipe.
- **Лут:** `Nomad Supercharger`, `Convoy Access`, `Legendary Vehicle Skin`.

### `wb-netwatch-sphinx`
- **Фаза 1 — Firewall Gauntlet:** D&D INT DC 19 для отключения ICE.
- **Фаза 2 — Logic Puzzles:** мини-игры, навык `Logic Bomb` (WIS DC 19).
- **Фаза 3 — Sphinx Core:** чередует вопросы/ответы (диалоговые проверки) и боевые арены.
- **Лут:** `Sphinx Cyberdeck`, `NetWatch Clearance`, `Global Event Trigger`.

## 4. Уникальные навыки по лигам
| Лига | Модификатор | Пример способности |
| --- | --- | --- |
| Bronze | Вводные механики | `Shield Pulse` (простое снятие щита) |
| Silver | +Добавочные адды | `Corpo Reinforcements` (вызов волн) |
| Gold | Усложнённые D&D проверки | `Network Spike` (INT DC +2) |
| Platinum | Адаптивные фазы | `Behavior Shift` (меняет паттерн после 50%) |
| Diamond | Комбинированные навыки | `Reality Sync` + `Logic Bomb` |
| Mythic | Постоянные дебаффы | `Existential Overwrite` (перманентный -10% стат) |

## 5. Телеметрия и динамика
- WebSocket канал `wss://world-service/world-boss/{eventId}` публикует `PhaseStart`, `AbilityCast`, `DndCheck`, `PlayerDown`, `LootRoll`.
- Kafka topics: `world.boss.spawn`, `world.boss.telemetry`, `world.boss.outcome`.
- Автотюнинг: analytics-service корректирует HP и урон на основе среднего времени убийства.

## 6. REST API (world-service)
| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/world/bosses` | `GET` | Каталог боссов, фильтр по лиге/эпохе/фракции |
| `/world/bosses/{id}` | `GET` | Детали босса, фазы, лут, D&D проверки |
| `/world/bosses/{id}/schedule` | `GET` | Таймслоты появления, привязка к world-state |
| `/world/bosses/{id}/signup` | `POST` | Запись отряда на событие (до начала) |
| `/world/bosses/{id}/outcome` | `POST` | Финальный результат, выдача наград |

## 7. Схемы данных
```sql
CREATE TABLE world_bosses (
    boss_id VARCHAR(64) PRIMARY KEY,
    title VARCHAR(120) NOT NULL,
    location VARCHAR(120) NOT NULL,
    timeline VARCHAR(32) NOT NULL,
    base_difficulty VARCHAR(16) NOT NULL,
    narrative_trigger JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE world_boss_phases (
    boss_id VARCHAR(64) REFERENCES world_bosses(boss_id) ON DELETE CASCADE,
    phase_index INTEGER NOT NULL,
    description TEXT NOT NULL,
    unique_ability VARCHAR(64) NOT NULL,
    dnd_checks JSONB,
    rewards JSONB,
    PRIMARY KEY (boss_id, phase_index)
);

CREATE TABLE world_boss_schedules (
    boss_id VARCHAR(64) REFERENCES world_bosses(boss_id) ON DELETE CASCADE,
    league VARCHAR(16) NOT NULL,
    window_start TIMESTAMP NOT NULL,
    window_end TIMESTAMP NOT NULL,
    spawned BOOLEAN DEFAULT FALSE,
    world_flags JSONB,
    PRIMARY KEY (boss_id, league, window_start)
);
```

## 8. Награды и экономика
- Награды масштабируются от Bronze до Mythic (x1.0 → x2.5).
- Привязка к economy-service: таблица `world_boss_loot` синхронизируется с аукционом и крафтом.
- Репутация: social-service обновляет фракционные очки (`rep.corp.arasaka`, `rep.street.valentinos`).
- Battle Pass: world-service публикует `battle-pass.progress` события.

## 9. Лор и NPC
- `Operator Lynx` — координатор NetWatch, запускает `wb-blackwall-wraith`.
- `Fixer Alma "Spark"` — даёт оповещения о `wb-neon-titan`.
- `Padre Alvarez` — решает исход `wb-valentinos-saint` (влияет на диалоги романсов).
- `Nomad Charon` — связывает `wb-nomad-leviathan` с кланами Badlands.

## 10. Готовность
- Боссы описаны, фазовые навыки и D&D проверки определены.
- REST/WS контракты и таблицы данных готовы к передаче в API Task Creator.
- Документ синхронизирован с `combat-ai-enemies.md` (уровни сложности и навыки).

