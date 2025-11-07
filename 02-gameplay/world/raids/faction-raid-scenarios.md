---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:04  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:04  
**api-readiness-notes:** Рейдовые и осадные сценарии фракций: эскалация от защитников к рейдам, фазы, сигнальные миссии, экономика наград.
---

# Faction Raid Scenarios — Эскалация и осады

**target-domain:** gameplay-world/raids  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/raids  
**интеграции:** combat-session, economy-service, analytics-service

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-277: api/v1/gameplay/world/factions/raid-scenarios.yaml (2025-11-08 02:15)
- Last Updated: 2025-11-08 02:15
---

## 1. Концепция
- Культовые защитники являются триггерами для рейдов/осад фракций.
- Эскалация строится на сигнальных миссиях, собранных ресурсах и репутации.
- Каждый рейд имеет 3 фазы, уникальные механики, экономику и последствия world flags.

## 2. Таблица рейдов
| Фракция | Рейд | Триггер | Сигнальные миссии | Фазы |
| --- | --- | --- | --- | --- |
| Aeon Dynasty | orbital-lockdown | Победа в Aeon контракте | Escort Drones, Sabotage Rival Dock | Orbital Entry → Dock Clash → Core Stabilization |
| Crescent Energy | solar-surge | Завершён Desert Grid | Grid Repair, Nomad Alliance | Sandstorm Screen → Reactor Sync → Covenant Negotiation |
| Ember Saints | purge-litany | Выполнен Inferno Covenant | Firebrand Supply, Civic Evac | District Siege → Pyre Trials → Redemption Vote |
| Basilisk Sons | mech-rampart | Пройден Basilisk Hunt | Armor Fabrication, Nomad Rally | Convoy Ambush → Hangar Breach → Basilisk Duel |
| Echo Dominion | metanet-dominion | Tribunal ветка | AI Candidate Review, Firewall Prep | Node Infiltration → Metanet Arbitration → Sovereignty Decision |

## 3. Пример рейда: orbital-lockdown
- **Фаза 1 Orbital Entry:** пилотирование дроп-подов, DEX/TECH проверки, StageStart событие.
- **Фаза 2 Dock Clash:** бой с защитными дронами, усиления через Lotus Protocol Aeon защитника.
- **Фаза 3 Core Stabilization:** командный таймер, игроки решают оставить/захватить ядро → влияет на corporate_balance.
- **Награды:** орбитальные модули, аккредитации Aeon, лут с коэффициентом по сложности (Bronze → Mythic+).

## 4. Сигнальные миссии
- Escort Drones: кооперативная миссия по доставке ресурсов (overworld event).
- Sabotage Rival Dock: stealth-инфильтрация, INT/COOL проверки.
- Каждая успешная миссия добавляет 
aid_charge в world_state.faction.aeon.

## 5. Экономика наград
- BaseLoot: фракционный лут, onusLoot: редкие чертежи.
- Кредиты распределяются через economy-service (POST /economy/rewards), учитывают выбранную ветку outcome.
- Raid Bonds: фракционные облигации, торгуемые на аукционе; влияют на цены имплантов/транспорта.

## 6. REST/WS
| Endpoint | Метод | Назначение |
| --- | --- | --- |
| /world/raids | GET | Список фракционных рейдов, состояние зарядки |
| /world/raids/{raidId} | GET | Фазы, требования, награды |
| /world/raids/{raidId}/signal | POST | Регистрация сигнальной миссии |
| /world/raids/{raidId}/start | POST | Запуск рейда (GM или auto-trigger) |
| /world/raids/{raidId}/outcome | POST | Результат фазы/рейда, награды, world flags |

**WebSocket:** wss://world-service/raids/{raidId} — PhaseStart, MechanicTrigger, OutcomeApplied, LootDistributed.

## 7. Схемы данных
`sql
CREATE TABLE faction_raids (
    raid_id VARCHAR(64) PRIMARY KEY,
    faction_id VARCHAR(64) NOT NULL,
    trigger_conditions JSONB NOT NULL,
    phases JSONB NOT NULL,
    signal_missions JSONB NOT NULL,
    reward_matrix JSONB NOT NULL,
    world_effects JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faction_raid_signals (
    raid_id VARCHAR(64) REFERENCES faction_raids(raid_id) ON DELETE CASCADE,
    signal_code VARCHAR(64) NOT NULL,
    description TEXT NOT NULL,
    success_effect JSONB NOT NULL,
    failure_effect JSONB,
    PRIMARY KEY (raid_id, signal_code)
);
`

## 8. Готовность
- Рейдовые сценарии описаны, сигнальные миссии и экономика наград связаны с существующими системами.
- Готово для API Task Creator и world-service реализации.
