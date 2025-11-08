# Аномальные пасхальные сценарии — календарь 2077–2093

---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-364: api/v1/world/events/anomalies.yaml (2025-11-08 17:26)
  - API-TASK-365: api/v1/social/anomalies/participants.yaml (2025-11-08 17:26)
- Last Updated: 2025-11-08 17:26
---

---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-08 16:51  
**api-readiness-notes:** Зафиксирован календарь аномалий, расписания, REST и Kafka контракты, таблицы данных и показатели мониторинга. Документ согласован с world/social/gameplay командами и готов к постановке API задач.
---

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-08 16:51  
**Приоритет:** высокий  
**Ответственный:** AI Brain Manager  
**Связанные документы:** `../../ideas/2025-11-07-IDEA-anomalous-easter-scenarios.md`, `../../config/readiness-check-guide.md`, `../../../02-gameplay/world/events/world-events-framework.md`, `../../../02-gameplay/social/reputation-formulas.md`  
**target-domain:** world-events  
**target-microservice:** world-service (8086)  
**target-frontend-module:** modules/world/events  
**owner-guilds:** World Simulation, Narrative, Economy  
**integration-services:** social-service, gameplay-service, inventory-service, auth-service, notification-service, analytics-service

---

## 1. Обзор и цели

- Создать редкие «аномальные» события, поддерживающие атмосферу киберпанк- города и расширяющие social/world метагейм.
- Определить расписания, ручные триггеры и fallback сценарии для шести аномалий (спектры, река, башня, архив, шторм, станция).
- Сформировать API, Kafka события, модели данных, правила наград и мониторинга, достаточные для кодогенерации world/social/economy сервисов.
- Обеспечить анти-абьюз, опциональные визуальные эффекты и UX-поддержку для игроков с чувствительностью к вспышкам.

---

## 2. Календарь аномалий

| Аномалия | Тип триггера | Расписание (UTC) | Длительность | Условия доступа | GM override |
|----------|--------------|------------------|--------------|-----------------|-------------|
| Сбойная площадь спектров | CRON | Вторник 21:00 | 15 минут | Репутация `city.culture ≥ 10` | `POST /world/anomalies/spectrum/override` |
| Река обратного течения | Астрономический | Каждое полнолуние 20:30 | 20 минут | Завершён квест `river-memories` | `POST /world/anomalies/river/override` |
| Башня резонансных часов | Нагрузка сервера | Онлайн игроков > 45 000 | 10 минут | Гильдии ≥ 6 членов онлайн | `POST /world/anomalies/tower/override` |
| Подземный архив «Эхо-письма» | Прогресс игроков | 50+ писем активировано за неделю | 30 минут | Выполнен тур `noise-journey` | `POST /world/anomalies/archive/override` |
| Голографический шторм «Двоение сцены» | Погодный RNG | 2% шанс при дождях | 8 минут | Опция визуальных эффектов включена | `POST /world/anomalies/storm/override` |
| Станция синхронизации «Третий ракурс» | Кооператив | 12 игроков активировали терминал | 12 минут | Пати ≥ 3 человек | `POST /world/anomalies/station/override` |

- Fallback: при пропущенной аномалии планируется повтор через 72 часа.
- GM override доступен только аккаунтам с ролью `world.supervisor`, действия логируются.

---

## 3. Описание аномалий и награды

### 3.1 Сбойная площадь спектров
- Временная смена визуального слоя, тени прошлых сезонов и фраза «Мы всё ещё на связи».
- Награды: фильтр `Glitch Veil`, 50 репутации `city.culture`, шанс на эмоцию `Ghost Handshake`.
- Взаимодействие: `interact` событие на локации `NC_SQUARE_SPECTRUM`.

### 3.2 Река обратного течения
- Reverse-flow shader, зеркальные NPC двойники, сбор отражений.
- Награды: предмет `Reverse Token`, сезонная валюта `anomaly-essence`.
- Условия: игрок должен находиться на локации `NC_RIVER_BACKFLOW` и иметь активность в последние 72 часа.

### 3.3 Башня резонансных часов
- Видимый на глобальной карте таймер, синхронное ударение колоколов, бафф `Echo Loop` (+5% скорость перезарядки).
- Командное действие: панели синхронизации, требует координации 10 секунд.

### 3.4 Подземный архив «Эхо-письма»
- Скрытая станция метро, письма прошлых итераций. Завершение выдаёт эмоцию `Looped Wave`.
- Дополнительно: флаг `world.archive_unlocked` открывает новые диалоговые ветви в `04-narrative/dialogues`.

### 3.5 Голографический шторм «Двоение сцены»
- Двойной фотонный дождь, NPC фразы «Дежавю — это просто лаг».
- Игрок, поделившийся скриншотом через `social-service`, получает титул `Storm Witness`.
- Безопасность: при выключенном `visual-effects` игроки получают уведомление, но эффекты упрощены.

### 3.6 Станция синхронизации «Третий ракурс»
- Мини-сцена с тремя камерами, мини-игра тайминга.
- Награды: косметика `Tri-Frame Lens`, увеличение репутации `city.cooperation`.
- Позволяет запускать AR-проекции на городских экранах в течение 24 часов.

---

## 4. REST API контракты (world-service, social-service)

| Метод | Путь | Сервис | Описание |
|-------|------|--------|----------|
| GET | `/world/anomalies/schedule` | world-service | Список расписаний и ближайших окон |
| GET | `/world/anomalies/{anomalyId}/state` | world-service | Текущее состояние, таймер, участники |
| POST | `/world/anomalies/{anomalyId}/activate` | world-service | Ручной запуск (роль `world.supervisor`) |
| POST | `/world/anomalies/{anomalyId}/complete` | world-service | Завершение события, выдача наград |
| POST | `/social/anomalies/{anomalyId}/participants` | social-service | Регистрация участия (передача `playerId`, `action`) |
| GET | `/social/anomalies/{anomalyId}/rewards` | social-service | История наград игрока |
| POST | `/world/anomalies/{anomalyId}/sightings` | world-service | Отметка проявления (глитчи, визуальные эффекты) |
| GET | `/world/anomalies/insight-metrics` | analytics-service proxy | Агрегированные показатели для UI |

- Авторизация: JWT от `auth-service`, scope `world.events.read`, `world.events.write`.
- Rate limits: `POST activate` — максимум 3 запроса в сутки, `participants` — 3 в минуту с captcha fallback.

---

## 5. Kafka события

| Топик | Publisher | Payload | Консьюмеры |
|-------|-----------|---------|------------|
| `world.anomalies.lifecycle` | world-service | `{ anomalyId, phase, startedAt, expiresAt, triggerSource, overlap }` | analytics, notification, ui-gateway |
| `world.anomalies.rewards` | world-service | `{ anomalyId, playerId, rewards[], reputation }` | inventory, mail, achievement |
| `social.anomalies.participants` | social-service | `{ anomalyId, playerId, guildId, action, timestamp }` | analytics, world-service |
| `world.anomalies.visual-state` | world-service | `{ anomalyId, shaderProfile, intensity, fallbackProfile }` | frontend-gateway, ux-monitor |

- Все события дублируются в `analytics` с ретеншеном 30 дней.

---

## 6. Структура данных

```sql
CREATE TABLE world.anomaly_schedule (
    anomaly_id TEXT PRIMARY KEY,
    cron_expression TEXT,
    trigger_type TEXT,
    last_run TIMESTAMPTZ,
    next_run TIMESTAMPTZ,
    gm_override_enabled BOOLEAN DEFAULT TRUE,
    manual_cooldown_minutes INT DEFAULT 4320,
    metadata JSONB
);

CREATE TABLE world.anomaly_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    anomaly_id TEXT NOT NULL,
    phase TEXT NOT NULL, -- PLANNED | ACTIVE | COOLDOWN | CANCELLED
    trigger_source TEXT NOT NULL, -- CRON | ASTRONOMY | LOAD | RNG | COOP | GM
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    metrics JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE social.anomaly_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    anomaly_event_id UUID NOT NULL REFERENCES world.anomaly_events(id) ON DELETE CASCADE,
    player_id UUID NOT NULL,
    guild_id UUID,
    action TEXT NOT NULL,
    reward_package JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

- Индексы: `idx_schedule_next_run`, `idx_events_anomaly`, `idx_participants_player`.
- Денормализованный `world.anomaly_metrics_daily` (materialized view) для аналитики.

---

## 7. Награды и экономические параметры

| Аномалия | Базовые награды | Уникальные предметы | Ограничения |
|----------|-----------------|---------------------|-------------|
| Спектры | 500 eddies, 50 репутации | `filter.glitch_veil` | Раз в неделю на игрока |
| Река | 400 eddies, 30 репутации | `token.reverse_flow` | Максимум 3 жетона/месяц |
| Башня | 300 eddies, бафф `echo_loop` | `buff.echo_loop` (20 мин) | Бафф не стакается |
| Архив | 450 eddies, эмоция | `emote.looped_wave` | Эмоция уникальна |
| Шторм | 350 eddies, титул | `title.storm_witness` | Титул уникален |
| Станция | 380 eddies, косметика | `cosmetic.tri_frame_lens` | Косметика account-bound |

- Все награды синхронизируются с `inventory-service` через `world.anomalies.rewards`.

---

## 8. Мониторинг и анти-абьюз

- Метрики Prometheus: `world_anomaly_active_total`, `world_anomaly_participants_total`, `world_anomaly_latency_ms`, `world_anomaly_override_total`.
- Аллерты:
  - `override_spike` — >5 ручных запусков в 12 часов.
  - `participants_drop` — <10 участников в двух подряд событиях.
  - `latency_high` — задержка > 1200 мс при активации визуальных эффектов.
- Анти-спам: игроки с флагом `world.anomaly_violation` лишаются наград на 24 часа, флаг выставляет аналитика при обнаружении ботов.
- Опция `visual_safety_mode` отключает вспышки, заменяя shader на `AFTERGLOW_LOW`.

---

## 9. UX и коммуникация

- HUD оповещения через виджет `shared/ui/HUDIndicator` (режим `glitch`).
- Почтовые рассылки (`social-service`) перед событиями с персонализированными подсказками.
- Кат-сцены для браслетов и архивов передаются в `04-narrative/dialogues`.
- UI toggle «Аномальные события» по умолчанию включен, но доступен opt-out.

---

## 10. Зависимости и интеграции

- `02-gameplay/world/events/world-events-framework.md` — шкалы сложности и фракционные эффекты.
- `02-gameplay/social/reputation-formulas.md` — изменение репутации.
- `05-technical/backend/notification-system.md` — рассылка push и почты.
- `05-technical/backend/voice-lobby/voice-lobby-system.md` — организация кооперативных событий (станция, башня).
- `FRONT-WEB/modules/world/events` — отображение расписаний, карты, таймеров.
- Блокеры отсутствуют, все зависимые документы имеют статус ready.

---

## 11. Roadmap и задачи

| Дата | Действие | Ответственные |
|------|----------|----------------|
| 2025-11-09 | Подготовить OpenAPI задачи по расписаниям и участникам | API Task Creator |
| 2025-11-10 | Генерация DTO/клиентов в BACK-JAVA | Backend Guild |
| 2025-11-11 | Внедрение UI таймеров и фильтров | Frontend Guild |
| 2025-11-12 | Прогон нагрузочных тестов 50k concurrents | Tech Ops |

---

## 12. История изменений

- 2025-11-08 16:51 — v1.0.0: зафиксирован календарь аномалий, API, Kafka и модели данных, статус переведён в ready.
- 2025-11-07 — Создан рабочий черновик, собраны задачи и открытые вопросы.

