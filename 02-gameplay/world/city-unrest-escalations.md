# City Unrest Escalations — сценарии беспорядков

**ID документа:** `city-unrest-escalations`  
**Тип:** gameplay-spec  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:45  
**Приоритет:** высокий  
**Связанные документы:** `specter-hq.md`, `helios-countermesh-ops.md`, `raids/specter-surge-loot.md`, `../../06-tasks/active/CURRENT-WORK/active/2025-11-07-world-interaction-ui.md`  
**target-domain:** gameplay/world  
**target-мicroservices:** world-service, social-service, economy-service, narrative-service  
**target-frontend-модули:** modules/world, modules/events, modules/social  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:45  
**api-readiness-notes:** Подготовлены сценарии эскалации City Unrest с триггерами, фазами, API и телеметрией; готово к постановке задач.

---

## 1. Контекст и цели
- City Unrest отражает реакцию города на успех/провал Specter и Helios операций.
- Эскалации создают динамический мир: PvE/PvP события, социальные последствия, экономические потери.
- Цель — определить ступени, триггеры и API для world/social/economy сервисов.

## 2. Уровни беспорядков

| Уровень | Диапазон `city.unrest.level` | Название | Эффекты |
|---------|------------------------------|----------|---------|
| 0 | 0–19 | Stable | Мирные события, скидки на рынке.
| 1 | 20–39 | Tension | Участившиеся патрули, редкие стычки.
| 2 | 40–59 | Unrest | Уличные бои, повышенная стоимость транспорта.
| 3 | 60–79 | Crisis | Блокпосты, PvPvE миссии, отключения инфраструктуры.
| 4 | 80–100 | Cataclysm | Полномасштабные беспорядки, эвакуация, Soft Lock некоторых сервисов.

## 3. Сценарии по уровням

| Уровень | Сценарий | Тип | Описание | Условия | Награды / последствия |
|---------|----------|-----|----------|---------|-----------------------|
| Tension | `street-protest` | PvE (3 чел.) | Удержать протест от эскалации | `specter.overlay.alertLevel ≥ 1` | `rep.city.gov +2`, снижение unrest -5. |
| Unrest | `logistics-sabotage` | PvPvE | Helios/Ghosts борются за конвои | Провал рейда Specter | Валюта + материалы; победитель снижает / повышает unrest на 8. |
| Crisis | `neon-riot` | PvE (масштаб) | Отразить волну беспорядков, эвакуировать граждан | `helios.alert ≥ 5` или `city.unrest ≥ 60` | `specter-prestige +30`, `rep.city.gov +5`; провал — `economy.loss`. |
| Cataclysm | `blackwall-breach` | PvPvE с Narrative | Helios запускает Blackwall контр-меры, Specter пытаются стабилизировать | `city.unrest ≥ 80`, провал Helios Ops | Кат-сцена + глобальный модификатор; выбор влияет на сюжет. |

## 4. Фазы события `neon-riot`
- **Фаза 1:** Оценка (переговоры, проверка `Diplomacy` DC 18; успех — меньшая волна).
- **Фаза 2:** Улицы (wave defense, combat-service `riot-wave` spawn).
- **Фаза 3:** Эвакуация (transport mini-game; economy-service учитывает спасённых граждан).
- **Фаза 4:** Стабилизация (social-service `community-support` action; снижает unrest дополнительно).

## 5. Триггеры и вычисление показателя
- world-service обновляет `city.unrest.level` при каждом событии:
  - Провал Specter рейда: +12.
  - Победа Helios в Ops: +10.
  - Успех Specter HQ контрактов: -8.
  - Недельные ротации (`City Uprising`): +15.
- Скрипты: `POST /api/v1/world/city-unrest/update` с параметрами `source`, `delta`.
- Автоэскалация: если `city.unrest.level ≥ threshold` > 10 мин, запускается событие соответствующего уровня.

## 6. Экономика и последствия
- **Рынки:** при Crisis +10% цены, при Cataclysm некоторые магазины закрыты.
- **Транспорт:** увеличиваются расходы на путешествия (`economy-service` событие `transport_surcharge`).
- **Репутации:** игроки, участвующие в подавлении, получают `rep.city.gov`; игроки, поддерживающие беспорядки, — `rep.corp.helios`.
- **Сервисы:** Specter HQ снижает лимиты магазина при высоком unrest; Helios Ops дешевеют при Crisis.

## 7. API карта
- **World-service:**
  - `GET /api/v1/world/city-unrest/state`
  - `POST /api/v1/world/city-unrest/scenario/trigger`
  - Events: `CITY_UNREST_LEVEL_CHANGED`, `CITY_UNREST_SCENARIO_STARTED`, `CITY_UNREST_SCENARIO_RESOLVED`.
- **Economy-service:** `POST /api/v1/economy/city-unrest/apply`, события `economy.unrest.surcharge`.
- **Social-service:** `POST /api/v1/social/city-unrest/broadcast`, событие `SOCIAL_ALERT_CITY_UNREST`.
- **Narrative-service:** `POST /api/v1/narrative/city-unrest/branch` для кат-сцен.

## 8. Telemetry и SLA
- **KPIs:** `unrest_response_rate ≥ 75%`, `average_unrest_duration ≤ 72h`, `player_participation ≥ 60%`.
- **Latency:** `city_unrest_update ≤ 150 мс`, `scenario_trigger ≤ 200 мс`.
- **Telemetry events:** `city_unrest_delta`, `city_unrest_scenario_phase`, `city_unrest_reward_claimed`.
- Grafana: `city-unrest-overview`, `city-unrest-economy`, `city-unrest-participation`.
- PagerDuty: `CityUnrestQueueLag`, `CityUnrestScenarioTimeout`.

## 9. Связь с UI
- World Interaction UI (раздел Crisis Hub) использует `CITY_UNREST_UPDATE` и показывает прогресс сценариев.
- Specter overlay метрики (`specter.overlay.unrestMitigated`) воротятся в реальном времени.
- Требуется обновление ASCII-мокапа Crisis Control Hub для отображения сценариев.

## 10. История изменений
- 2025-11-07 22:45 — Создан документ City Unrest Escalations, определяющий уровни, сценарии, API и телеметрию.

