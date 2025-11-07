# Рейд — Specter Surge (лут и прогрессия)

**ID документа:** `raid-specter-surge-loot`  
**Тип:** gameplay-spec  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 21:45  
**Приоритет:** высокий  
**Связанные документы:** `../../04-narrative/quests/raid/2025-11-07-raid-specter-surge.md`, `../events/world-events-framework.md`, `../world-state/player-impact-mechanics.md`  
**target-domain:** gameplay/world  
**target-мicroservices:** world-service, economy-service, social-service  
**target-frontend-модули:** modules/world, modules/guild/raids, modules/economy  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 21:45  
**api-readiness-notes:** Подготовлены лут-таблицы, недельные модификаторы и экономические контуры рейда Specter Surge; REST/WS и SQL схемы готовы к постановке API задач.

---

## 1. Контекст и цели
- **Цель:** зафиксировать правила выдачи наград, экономику и прогрессию рейда `Specter Surge` для world/economy-service.
- **Область:** PvE-рейд 6 игроков (пилоты + техно-операторы), влияющий на `underlink.stability` и `city.unrest`.
- **Результат:** единый источник для генерации API (`/world/raids`, `/economy/rewards`, `/social/reputation`) и настройки бэкэнда/фронтенда.

## 2. Таблица наград по фазам

| Фаза | Категория наград | Предметы / ресурсы | Шанс / количество | Примечания |
|------|------------------|--------------------|-------------------|------------|
| I — Ghost Link Calibration | Баффы / расходники | `sync-injector`, `ghost-buffer`, 600 ед. `specter-data` | 100% | Даёт +10% скорость синхронизации; хранится в economy-service (`raid_reward_buffers`). |
| II — Countermesh Breach | Материалы | `countermesh-alloy`, `helios-keyshard` (эпик) | 80% / 20% | Используется для крафта `specter-shield`. |
| III — Dual-Core Assault | Основной лут | `specter-core-fragment`, `mech-overclock`, 5% `legendary-catalyst` | 100% / 65% / 5% | Гарантирован минимум 1 `specter-core-fragment` на группу. |
| IV — Data Extraction Run | Ресурсы экономики | 2 500 `ghost-credits`, `underlink-bonds` (до 3 шт.) | 100% / 40% | Бонусы зависят от сохранённых пакетов данных. |
| V — Specter Evacuation | Метатрофеи | `specter-crest` (раз в неделю), 1–2 `specter-favor` | 100% | `specter-favor` — валюта гильдии, используется в магазине Specter HQ. |

## 3. Лут-таблицы сложности

| Сложность | Базовые награды | Доп. шанс легендарок | Модификатор валют | Примечания |
|-----------|-----------------|----------------------|-------------------|------------|
| Normal | Фазы I–V без изменений | 5% `legendary-catalyst` | ×1.0 | Стартовый режим. |
| Elite | +1 `helios-keyshard`, `specter-favor` +1 | 12% `legendary-catalyst`, 3% `specter-mythic-core` | ×1.35 | Требует `specter.overlay.alertLevel ≥ 2`. |
| Apex | +1 `specter-core-fragment`, 10% `ghost-squad-ticket` | 22% `legendary-catalyst`, 8% `specter-mythic-core` | ×1.75 | Запускается по расписанию (см. раздел 4). |

## 4. Недельные ротации и модификаторы

| Неделя | Модификатор | Эффект | Награда за завершение | API события |
|--------|-------------|--------|-----------------------|-------------|
| W1 — Countermesh Flux | `helios.countermesh+` | Усиленные щиты фазы II, время на взлом +60 сек. | `countermesh-alloy` ×2 | `WORLD_RAID_ROTATION(countermesh_flux)` |
| W2 — Specter Storm | `specter.sync-boost` | Бафф `sync-flow` дольше, но появляется риск `overload`. | `specter-core-fragment` +1 | `WORLD_RAID_ROTATION(specter_storm)` |
| W3 — City Uprising | `city.unrest+25` | Волны в фазах IV–V чаще, повышение `rep.fixers.neon`. | `specter-favor` ×2 | `WORLD_RAID_ROTATION(city_uprising)` |
| W4 — Economizer | `economy.reward×0.85` | Валюта снижена, шанс `specter-mythic-core` +5%. | Шанс 3% `mythic-core` | `WORLD_RAID_ROTATION(economizer)` |
| W5 — Celebration | `specter-parade` | Доп. кат-сцена и бонус `social.trust +4`. | `specter-crest` гарантирован | `WORLD_RAID_ROTATION(celebration)` |

- Ротации повторяются каждые 5 недель; обновление — понедельник 04:00 UTC.
- REST: `GET /api/v1/world/raids/rotations/current`, `GET /api/v1/world/raids/rotations/schedule` (world-service).

## 5. Прогрессия игроков и гильдий
- **Еженедельный лимит:** 3 завершения с полным лутом; далее 30% наград без `specter-crest`.
- **Гильдии:** очки `specter-guild-reputation`; каждые 500 очков открывают `guild.contract.specter-ops`.
- **Достижения:**
  - `Specter Surge: Perfect Sync` — завершить без провалов фаз (титул + HUD-аура).
  - `Countermesh Breaker` — уничтожить ≥5 `helios-sentinel` за один заход.
  - `City Guardian` — снизить `city.unrest` ≥ 12 за рейд (бонус `rep.city.gov +6`).
- **Хранилище:** economy-service: `player_raid_rewards`, `guild_raid_progress`; world-service: `raid_completion_log`.

## 6. Экономика и магазины
- **Валюты:** `specter-favor`, `ghost-credits`, `underlink-bonds`.
- **Магазин Specter HQ:**
  - `specter-core-fragment` — цена 2 `specter-favor`.
  - `specter-legendary-implant` — 8 `specter-favor`, лимит 1/нед.
  - `ghost-squad-ticket` — 5 `specter-favor`, лимит 2/нед.
- **API economy-service:** `POST /api/v1/economy/raid/rewards/claim`, `POST /api/v1/economy/raid/store/purchase`, `GET /api/v1/economy/raid/store/catalog`.
- **SQL:** `raid_rewards`, `raid_weekly_limits`, `raid_store_catalog`, `raid_store_purchases`.

## 7. Репутации и социальные эффекты
- **Репутации:** `rep.fixers.neon`, `rep.corp.helios`, `rep.city.gov`, `rep.guild.specter`.
- **Формулы:**
  - Успех рейда: `rep.fixers.neon += 3`, `rep.city.gov += 2`, `rep.corp.helios -= 4`.
  - Провал фазы V: `rep.city.gov -= 5`, `rep.corp.helios += 6`.
- **События:** при `specter.overlay.activePlayers ≥ 500` активируется `SOCIAL_EVENT_specter_parade` (social-service + narrative-service).

## 8. API, события и схемы данных
- **World-service:**
  - REST: `POST /api/v1/world/raids/{raidId}/complete`, `PATCH /api/v1/world/raids/{raidId}/rotation`.
  - Events: `WORLD_RAID_COMPLETED`, `WORLD_RAID_FAILED`, `WORLD_RAID_ROTATION_CHANGED`.
- **Economy-service:**
  - REST: `POST /api/v1/economy/raid/rewards/distribute`, `GET /api/v1/economy/raid/rewards/history`.
  - Kafka: `economy.raid.rewards`, `economy.raid.store`.
- **Social-service:**
  - REST: `POST /api/v1/social/reputation/raid`, `POST /api/v1/social/events/trigger`.
  - Events: `SOCIAL_REP_CHANGE`, `SOCIAL_EVENT_BROADCAST`.
- **DB:** `raid_rotations`, `raid_rewards_log`, `raid_weekly_limits`, `guild_raid_progress`.

## 9. Telemetry и SLA
- **KPIs:** `avg_raid_duration ≤ 27 мин`, `loot_claim_success_rate ≥ 99%`, `economy_store_latency ≤ 200 мс`.
- **Grafana:** `specter-raid-loot`, `economy-raid-store`, `social-rep-drift`.
- **PagerDuty:** `RaidRewardsQueueLag` (>120 сек), `RaidRotationMismatch` (несовпадение расписания).
- **Telemetry:** `raid_phase_completed`, `raid_reward_claimed`, `raid_rotation_started`, `raid_store_purchase`.

## 10. Гейтинг и ограничения
- **Lockout:** общий сброс — четверг 03:00 UTC.
- **Catch-up:** игроки с `underlink.stability_contrib < 30` получают +10% валюты до достижения порога.
- **Anti-abuse:** economy-service проверяет `account_id` + `device_hash`; флаг `economy.flag.raid_abuse` при подозрении.

## 11. История изменений
- 2025-11-07 21:45 — Создан документ лута и прогрессии рейда Specter Surge, подготовлены данные для API задач.

