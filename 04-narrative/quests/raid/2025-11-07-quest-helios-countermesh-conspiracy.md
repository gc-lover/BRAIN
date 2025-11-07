# Квест — Helios Countermesh Conspiracy

**ID квеста:** `quest-helios-countermesh-conspiracy`  
**Тип:** raid-chain  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 23:25  
**Приоритет:** высокий  
**Связанные документы:** `../../../02-gameplay/world/helios-countermesh-ops.md`, `../../../02-gameplay/world/specter-hq.md`, `../../../02-gameplay/world/city-unrest-escalations.md`, `../raid/2025-11-07-raid-specter-surge.md`  
**target-domain:** narrative/raid  
**target-мicroservices:** narrative-service, world-service, combat-service, economy-service  
**target-frontend-модули:** modules/narrative/raids, modules/world, modules/social  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 23:25  
**api-readiness-notes:** Сюжетная цепочка Helios Countermesh Conspiracy: узлы, D&D проверки, API точки и последствия готовы для постановки задач.

---

## 1. Контекст
- Helios запускает операцию `Countermesh Conspiracy`, стремясь перехватить контроль над Underlink через двойных агентов.
- Specter HQ пытается разоблачить заговор, сохранив сети Ghosts и снизив City Unrest.
- Квест цепляется к рейду `Specter Surge`, Helios Ops и эскалациям города.

## 2. Структура квеста

| Узел | Название | Описание | Условия | Ключевые проверки |
|------|----------|----------|---------|--------------------|
| Q0 | `Signal Echo` | Kaori «Signal» перехватывает аномалии в сети Helios | Доступно после рейда Specter Surge | Insight (DC 16) — понять источник. |
| Q1 | `Deep Cover` | Инfilтрация гильдии Helios, сбор данных о Countermesh | Требует `countermesh-alloy` ×2 | Stealth (DC 18), Hacking (DC 20). |
| Q2 | `Split Allegiance` | Игрок делает выбор: поддержать Helios или раскрыть Specter HQ | City Unrest ≥ 40 | Persuasion (DC 21) или Intimidation (DC 19). |
| Q3 | `Underlink Siege` | PvE/PvPvE битва на насосах Underlink | Активирован `CM-Phalanx` | Combat (DC 22) + тактические решения. |
| Q4 | `Conspiracy Finale` | Финальная конфронтация с Helios стратегом `Dr. Lysander` | Победа в Q3 | Narrative выбор + рейдовая механика. |

## 3. Узлы (YAML фрагменты)
```yaml
- id: Q0-SignalEcho
  type: narrative
  npc: "Kaori Watanabe"
  dialogue: "Kaori перехватывает аномальные пакеты Helios."
  checks:
    - skill: Insight
      dc: 16
      success:
        effects:
          - set_flag: flag.helios.suspected
          - journal_update: "Helios пакеты идут через Underlink-Delta"
      failure:
        effects:
          - set_flag: flag.helios.confused
          - add_city_unrest: 3

- id: Q2-SplitAllegiance
  type: branch
  options:
    - id: support-helios
      requirements:
        - stat: Persuasion
          dc: 21
      effects:
        - set_flag: flag.player.helios_support
        - add_rep:
            rep.corp.helios: 6
            rep.fixers.neon: -8
        - trigger_event: HELIOS_CONSPIRACY_ALLY
    - id: expose-conspiracy
      requirements:
        - stat: Intimidation
          dc: 19
      effects:
        - set_flag: flag.player.specter_loyal
        - add_rep:
            rep.fixers.neon: 5
            rep.city.gov: 3
        - trigger_event: SPECTER_CONSPIRACY_EXPOSED
```

## 4. D&D проверки

| Узел | Проверка | DC | Модификаторы | Успех | Провал |
|------|----------|----|--------------|-------|--------|
| Q1 `Deep Cover` | Stealth | 18 | +2 при модуле `ghost-cloak` | Получены ключи доступа Helios | alarm -> +8 unrest |
| Q1 `Deep Cover` | Hacking | 20 | +1 за `ghost-drone` | Расшифровка Countermesh логов | Helios патч (опция пропадает) |
| Q2 `Split Allegiance` | Persuasion | 21 | +2 при `rep.corp.helios ≥ 20` | Helios доверяет, даёт агента | Появляется адаптивный охотник |
| Q3 `Underlink Siege` | Tactics | 22 | +1 при `specter-prestige ≥ 100` | Доп. отряд Specter | Потери, Specter HQ лимиты -1 |
| Q4 `Conspiracy Finale` | Insight | 20 | +2 при `flag.player.specter_loyal` | Раскрыт план, unlock финал | Lysander запускает Blackwall fallback |

## 5. Награды и последствия
- Ветка Helios поддержки: `helios-cred`, `helios-mythic-core`, доступ к Helios сюжетам, но `Specter HQ` магазин -2 слота на неделю.
- Ветка Specter лояльности: `specter-prestige +40`, `specter-legendary-implant`, снижение `city.unrest` на 15.
- Финал: кат-сцена `Blackwall Barrier` (narrative-service), выбор влияет на следующие ротации (`City Uprising`).

## 6. API и события
- narrative-service: `POST /api/v1/narrative/quests/helios-conspiracy/start`, `PATCH /api/v1/narrative/quests/helios-conspiracy/state`.
- world-service: `POST /api/v1/world/helios-conspiracy/update` (обновление флагов, влияния).
- Events: `HELIOS_CONSPIRACY_PROGRESS`, `HELIOS_CONSPIRACY_OUTCOME`.
- economy-service: `POST /api/v1/economy/helios-conspiracy/rewards`.

## 7. Telemetry и SLA
- Telemetry: `helios_conspiracy_choice`, `helios_conspiracy_phase`, `helios_conspiracy_reward`.
- KPIs: доля игроков, прошедших Q3 ≥ 60%; `city_unrest_reduction` ≥ 10 при ветке Specter.
- Latency: `quest_state_update ≤ 200 мс`.
- Grafana: `helios-conspiracy-overview`, `helios-conspiracy-reputation`.

## 8. История изменений
- 2025-11-07 23:25 — Создана сюжетная цепочка Helios Countermesh Conspiracy, описаны ветки, проверки и API.

