# Specter HQ — координатор гильдии

**ID документа:** `specter-hq`  
**Тип:** gameplay-spec  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:05  
**Приоритет:** высокий  
**Связанные документы:** `raids/specter-surge-loot.md`, `../../04-narrative/dialogues/npc-aisha-frost.md`, `../../04-narrative/quests/raid/2025-11-07-raid-specter-surge.md`, `world-state/player-impact-mechanics.md`  
**target-domain:** gameplay/world  
**target-мicroservices:** world-service, economy-service, social-service, narrative-service  
**target-frontend-модули:** modules/guild/raids, modules/economy, modules/social  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:05  
**api-readiness-notes:** Описаны NPC Specter HQ, магазин, апгрейды и связка с рейдовыми валютами; готово для постановки API задач.

---
## API Tasks Status

- **Status:** queued
- **Tasks:**
  - API-TASK-267: api/v1/gameplay/world/specter-hq.yaml (2025-11-08 00:48)
- **Last Updated:** 2025-11-08 00:48

---

## 1. Контекст и цели
- **Specter HQ** — подземный командный центр Ghosts, где игроки тратят `specter-favor`, берут поручения и апгрейды.
- **Роль:** закрепить прогрессию рейда `Specter Surge`, раздать менеджмент гильдиям и социальные активности.
- **Результат:** единый дизайн для NPC, UI, экономических механизмов и API (world/economy/social/narrative).

## 2. NPC и зоны
- **NPC:** `Kaori “Signal” Watanabe` — координатор Specter HQ.
  - Диалоговые ветки: приветствие (`state: neutral`), `raid-briefing`, `store`, `upgrade`, `intel-missions`.
  - Проверки: `Insight`, `Leadership`, `Hacking` (доступ к скрытым опциям).
- **Зоны HQ:**
  1. **Command Deck** — панели синхронизации рейда, очередь поручений.
  2. **Armory Bay** — магазин/апгрейды.
  3. **Ops Table** — гильдейские контракты и weekly ротации.
  4. **Specter Lounge** — социальные бонусы, репутационные обмены.

## 3. Валюты и ресурсы
- `specter-favor` — рейдовая валюта, потребляется магазином/апгрейдами.
- `countermesh-alloy`, `helios-keyshard` — материалы с рейда, требуются для модов.
- `underlink-bonds`, `ghost-credits` — экономические компенсации.
- `specter-prestige` — гильдейская метрика (накапливается за эвенты HQ).

## 4. Магазин и ассортимент

| Категория | Предмет | Стоимость | Ограничение | Эффект |
|-----------|---------|-----------|-------------|--------|
| Gear | `specter-legendary-implant` | 8 `specter-favor` + 1 `helios-keyshard` | 1/нед. | Активирует пассивку `sync-feedback` (+5% крит у мехов).
| Gear | `ghost-squad-ticket` | 5 `specter-favor` | 2/нед. | Призывает поддержку в рейде.
| Mods | `countermesh-shield` | 6 `specter-favor` + 2 `countermesh-alloy` | 1/нед. | Снижает урон по пилотам в фазе II на 8%.
| Cosmetics | `specter-holo-cloak` | 4 `specter-favor` | Нет | Соц. престиж +1.
| Resources | `underlink-bonds` ×5 | 3 `specter-favor` | 4/нед. | Инвестиции в экономику города.

- API economy-service: `GET /api/v1/economy/specter-hq/store`, `POST /api/v1/economy/specter-hq/purchase`.
- Проверка лимитов: `raid_store_limits` (player_id, item_id, week, remaining).

## 5. Апгрейды HQ

| Уровень | Требования | Стоимость | Эффект |
|---------|------------|-----------|--------|
| Tier 1 (тоннель связи) | Гильдейский уровень ≥ 10 | 50 `specter-prestige` + 20 `specter-favor` | Разблокирует Intel Board (доступ к контрактам).
| Tier 2 (доп. сеть) | Завершение рейда Apex ×3 | 120 `specter-prestige` + 30 `specter-favor` | Увеличивает лимит weekly лута до 4 завершений.
| Tier 3 (Specter Analytics) | Выполнить `intel-missions` ×10 | 200 `specter-prestige` + 50 `specter-favor` + 5 `specter-mythic-core` | Открывает аналитические панельки, +5% шанс легендарок.

- Storage: `specter_hq_upgrades(guild_id, tier, activated_at)`.
- World-service API: `POST /api/v1/world/specter-hq/upgrades/apply`.

## 6. Intel Board (контракты)
| Контракт | Описание | Требования | Награды |
|----------|----------|------------|---------|
| `intel-countermesh` | Уничтожить сеть Helios дронов | `specter.overlay.alertLevel ≥ 2` | 2 `specter-favor`, `countermesh-alloy`.
| `intel-shieldbreak` | Сопроводить колонну Ghosts в Underlink | Гильдия ≥ lvl 12 | 3 `specter-favor`, +2 `rep.city.gov`.
| `intel-specter-parade` | Провести парад в городе | `city.unrest < 40` | Социальные бонусы, +`specter-prestige` 25.

- REST: `GET /api/v1/world/specter-hq/contracts`, `POST /api/v1/world/specter-hq/contracts/accept`, `POST /api/v1/world/specter-hq/contracts/complete`.
- Events: `SPECTER_CONTRACT_ACCEPTED`, `SPECTER_CONTRACT_COMPLETED`.

## 7. Диалоговые состояния NPC
- `neutral` — базовое приветствие; открытые опции: магазин, краткий брифинг.
- `briefing` — после рейда; выдаётся бонус `intel-report`.
- `upgrade` — доступ при наличии `specter-prestige` и материалов.
- `intel` — запускает контрактные ветки (YAML-описание для narrative-service). Проверки `Hacking` (DC 20), `Leadership` (DC 18).
- Narrative-service API: `POST /api/v1/narrative/dialogues/specter-hq/start`, `PATCH /api/v1/narrative/dialogues/specter-hq/state`.

## 8. Социальные эффекты и репутации
- Выполнение контрактов => `rep.fixers.neon +2`, `rep.city.gov +1`.
- Провал контракта => `rep.fixers.neon -3`, `rep.corp.helios +2`.
- Парады (`specter-parade`) => событие `SOCIAL_EVENT_specter_parade`; UI обновляет `social-resonance`.

## 9. Telemetry и SLA
- **KPIs:** `specter_hq_visit_rate ≥ 65%` активных рейдеров; `contract_completion_rate ≥ 80%`.
- **Latency:** `economy_hq_purchase ≤ 200 мс`, `world_hq_contract_action ≤ 180 мс`.
- **Telemetry events:** `specter_hq_visit`, `specter_hq_purchase`, `specter_hq_upgrade`, `specter_contract_progress`.
- Grafana: `specter-hq-overview`, `specter-contracts`, `specter-store-latency`.
- PagerDuty: `SpecterHQStoreLag`, `SpecterContractQueueBacklog`.

## 10. API задачи (рекомендуемые)
- `API-TASK-251` — `api/v1/world/specter-hq.yaml` (зоны, контракты, апгрейды).
- `API-TASK-252` — `api/v1/economy/specter-hq-store.yaml`.
- `API-TASK-253` — `api/v1/social/specter-events.yaml` (парады, репутации).
- `API-TASK-254` — `api/v1/narrative/dialogues/specter-hq.yaml` (Kaori Watanabe).

## 11. История изменений
- 2025-11-07 22:05 — Создан дизайн Specter HQ: NPC, магазин, апгрейды, контракты и API карта.
