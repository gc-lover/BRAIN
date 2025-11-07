# Helios Countermesh Ops — ответные операции

**ID документа:** `helios-countermesh-ops`  
**Тип:** gameplay-spec  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:25  
**Приоритет:** высокий  
**Связанные документы:** `specter-hq.md`, `raids/specter-surge-loot.md`, `../../04-narrative/dialogues/npc-aisha-frost.md`, `../../04-narrative/quests/raid/2025-11-07-raid-specter-surge.md`  
**target-domain:** gameplay/world  
**target-мicroservices:** world-service, combat-service, economy-service, social-service  
**target-frontend-модули:** modules/world, modules/guild/raids, modules/events  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:25  
**api-readiness-notes:** Описаны контр-операции Helios: сценарии, боссы, экономика, API и телеметрия; готово к постановке задач.

---
## API Tasks Status

- **Status:** queued
- **Tasks:**
  - API-TASK-265: api/v1/gameplay/world/helios-ops.yaml (2025-11-08 00:32)
- **Last Updated:** 2025-11-08 00:32

---

## 1. Контекст и цели
- Helios запускает программу `Countermesh Ops`, пытаясь вернуть контроль над Underlink и нейтрализовать Ghosts.
- Эти эвенты выступают зеркалом `Specter Surge`: PvE/PvPvE задания, усиливающие `helios.alert` и `city.unrest`.
- Цель — создать антагонистичный контент, заполняющий мир и влияющий на экономику/социальные системы.

## 2. Типы операций

| Кодовое имя | Формат | Цель | Условия запуска | Эффекты |
|-------------|--------|------|-----------------|---------|
| `CM-Viper` | PvE Strike (4 чел.) | Сканер дронов Helios в районе Watson | `specter.overlay.alertLevel ≥ 2` | Повышает `helios.alert`. Успех нанёс бы урон Ghosts если провален. |
| `CM-Aegis` | Defensive Raid (6 чел.) | Защитить контейнеры countermesh-сплава | `city.unrest ≥ 35` | При провале Helios укрепляет позиции, цена на Ghost рынок растёт. |
| `CM-Phalanx` | PvPvE (8 чел.) | Отключить насосы Underlink; включается PvP между сторонниками Helios/Ghosts | Выбор гильдии поддержать Helios | Победа даёт Helios сет бонусов, поражение — усиливает Specter HQ. |
| `CM-Parallax` | Собрание данных (Solo/Co-op) | Взлом Helios-кластеров, чтобы предотвратить массовый реванш | `specter-hq upgrade Tier 2` активен | Проходит таймер event; успех снижает `helios.alert`. |

## 3. Фазы и механики операции `CM-Aegis`
- **Фаза 1: Deployment** — игроки доставляют `countermesh-alloy`. Проверка `Logistics` (DC 18) на ускоренную доставку.
- **Фаза 2: Defense Nodes** — волны дронов; combat-service спавнит `helios-warden`. Телеметрия `ops_wave_completed`.
- **Фаза 3: Counter-hack** — техно-операторы запускают мини-игру на выживание (`Hacking`, DC 20). При провале активируется `helios-overload` (дебафф Specter).
- **Фаза 4: Extraction** — выбор: эвакуировать ресурсы (economy-бонус) или оставаться и снизить `helios.alert`.
- Награды: `helios-cred`, `countermesh-alloy`, `helios-security-pass` (используется в сюжетах corp).

## 4. Зависимости и триггеры
- Триггер событий — world-service слушает `specter.overlay.alertLevel`, `raid_results`, `city.unrest`.
- Система расписаний: `POST /api/v1/world/helios-ops/schedule` обновляет следующие окна.
- При победе Helios влияет на `specter-hq` (бонусы магазина снижаются на 1 неделю).
- При поражении Helios — `specter-prestige` +20, Ghosts проводят дополнительный парад.

## 5. Экономика и награды

| Тип операции | Валюта | Материалы | Репутация | Особые награды |
|--------------|--------|-----------|-----------|----------------|
| `CM-Viper` | 1 500 `helios-cred` | `helios-alloy` | `rep.corp.helios` +4 | Шанс 10% `helios-drone-chip`. |
| `CM-Aegis` | 2 300 `helios-cred` | `countermesh-alloy` | `rep.corp.helios` +6, `rep.fixers.neon` -3 | `helios-security-pass` (ключ к raids-lite). |
| `CM-Phalanx` | 3 000 `helios-cred` | 50% `helios-mythic-core` | `rep.corp.helios` +8, `rep.guild.specter` -5 | PvP награды, уникальные окраски.
| `CM-Parallax` | 1 000 `helios-cred` | `encrypted-log` (конвертируется в ресурсы) | `rep.city.gov` +2 | Снижение `helios.alert` -5, шанс спец-лут.

- economy-service REST: `POST /api/v1/economy/helios-ops/rewards`, `GET /api/v1/economy/helios-ops/rewards/history`.
- SQL: `helios_ops_rewards`, `helios_ops_participants`, `helios_ops_lockouts`.

## 6. Репутации и социальные последствия
- Поддержка Helios => `rep.corp.helios` растёт, `rep.fixers.neon` падает.
- Победа Specter (провал Helios) => `rep.fixers.neon` +3, `rep.corp.helios` -4.
- `CM-Phalanx` запускает PvP рейтинг: `helios_vs_specter_rank`.
- social-service Events: `HELIOs_BROADCAST`, `WORLD_PROPAGANDA_UPDATE`, `CITY_UNREST_SURGE`.

## 7. API карта
- **World-service:**
  - `GET /api/v1/world/helios-ops/active`
  - `POST /api/v1/world/helios-ops/{opId}/join`
  - `POST /api/v1/world/helios-ops/{opId}/complete`
  - Events: `HELIOS_OP_STARTED`, `HELIOS_OP_OUTCOME`, `HELIOS_OP_SCHEDULE_CHANGED`.
- **Combat-service:** `POST /api/v1/combat/helios-ops/encounter`, `COMBAT_EVENT_HELIOS_OP`.
- **Economy-service:** см. раздел 5.
- **Social-service:** `POST /api/v1/social/helios/broadcast`.

## 8. Telemetry и SLA
- **KPIs:** `helios_op_completion_rate`, `pvp_participation_rate`, `city_unrest_mitigation`.
- **Latency:** `world_ops_join ≤ 180 мс`, `economy_rewards_dispatch ≤ 200 мс`.
- **Telemetry events:** `helios_op_phase`, `helios_op_pvp_outcome`, `helios_op_reward_claimed`.
- **Dashboard:** `helios-countermesh-overview`, `helios-pvp-balance`, `helios-alert-monitor`.
- PagerDuty: `HeliosOpsQueueLag`, `HeliosPvpMismatch`.

## 9. Сцепка с другими системами
- Результаты влияют на:
  - `specter-hq` магазин (цены/лимиты).
  - `specter-surge-loot` (в Apex режиме шанс легендарок снижается на 5% при победе Helios).
  - `city.unrest` модули UI.
  - `guild.contract.specter-ops` условие (нужно провалить ≥1 Helios операцию для спец-контракта).

## 10. История изменений
- 2025-11-07 22:25 — Создан документ Helios Countermesh Ops: сценарии, награды, API и телеметрия.

