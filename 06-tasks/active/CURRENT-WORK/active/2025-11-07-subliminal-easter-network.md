# Сублиминальная сеть пасхалок — Resonance Underlayer

---
**API Tasks Status:**
- Status: planned
- Tasks:
  - API-TASK-TBD: api/v1/social/subliminal-network.yaml (передать до 2025-11-10)
- Last Updated: 2025-11-08 16:51
---

---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-08 16:51  
**api-readiness-notes:** Описаны UX сигналы, анти-спам, REST/Kafka контуры, схемы данных и мониторинг для сублиминальной сети. Документ согласован с social/world/frontend командами и готов к постановке API задач.
---

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-08 16:51  
**Приоритет:** высокий  
**Ответственный:** AI Brain Manager  
**Связанные документы:** `../../ideas/2025-11-07-IDEA-subliminal-easter-network.md`, `../../../02-gameplay/social/reputation-formulas.md`, `../../../02-gameplay/world/events/world-events-framework.md`, `../../../05-technical/backend/chat/chat-moderation.md`  
**target-domain:** social-signals / ui-layer  
**target-microservice:** social-service (8084), world-service (8086), auth-service (8081), realtime-service (via gateway), audio-service (streaming)  
**target-frontend-module:** modules/ui/hud, modules/settings/ui, modules/social/mail  
**owner-guilds:** Social Systems, UI/UX, Audio, Security  
**integration-services:** notification-service, analytics-service, inventory-service, gameplay-service

---

## 1. Обзор и цели

- Ввести подпольную сеть сигналов (HUD, почта, билборды, подкасты, UI-пазлы, чат-команда `/knock`) без прямых IP-ссылок.
- Обеспечить управляемость: анти-спам, логирование, модерация, опциональный opt-in для чувствительных пользователей.
- Подготовить API и события для интеграции с social, world, audio, realtime и frontend.
- Сформировать награды, связанные косметические предметы и их выдачу через inventory-service.

---

## 2. Компоненты сети

| Компонент | Описание | Триггеры | Награды |
|-----------|----------|----------|---------|
| HUD «Подмигиватель» | Однокадровое уведомление с пиктограммой глаза | Ночные миссии, рейтинг стелса > 70 | Флаг `afterglow_counter`, прогресс к фильтру `Afterglow UI` |
| Почта «Сквозные письма» | Внутриигровые письма со скрытым кодом | Завершение сюжетных чекпоинтов | Предмет `Encrypted Bookmark` |
| Билборды «Сдвиг пикселей» | Глитч-анимация с текстом | События города, пассивный шанс 5% | Эмоция `Pixel Snap` при фиксации |
| Подкасты «Resonance Under» | Аудио-выпуски с маркерами | Расписание недели, API audio-service | Мини-квест `Follow the Resonance` |
| UI Мини-игра «Calibrate Echo» | Скрытый пункт меню, звуковой пазл | HUD сигналов ≥ 3, opt-in активен | Тема интерфейса `Afterglow UI` |
| `/knock` протокол | Кооперативное оповещение | Пиковые пинг-события, ручной ввод | Кооперативный бафф `Echo Sync` |

---

## 3. UX и доступность

- Toggle «Подпольные сигналы» в настройках (по умолчанию включён, предупреждение о визуальных эффектах).
- HUD анимация ≤ 1.5 секунды, вариант `low-impact` без вспышек.
- Подкаст-плеер выделяет маркеры визуально и аудио-пульсацией.
- Билборды и HUD используют компонент `shared/ui/HUDIndicator` с новым вариантом `variant="afterglow"`.
- Все тексты проходят локализацию через `08-references/localization-matrix.md`.

---

## 4. REST API контракты

| Метод | Путь | Сервис | Описание |
|-------|------|--------|----------|
| POST | `/social/subliminal/knock` | social-service | Активация `/knock`, проверка лимитов |
| GET | `/social/subliminal/knock/log` | social-service | История активаций (последние 50 записей) |
| POST | `/social/subliminal/mail/redeem` | social-service | Ввод кода из письма, выдача награды |
| GET | `/world/subliminal/billboards` | world-service | Активные сообщения и координаты |
| POST | `/world/subliminal/billboards/ack` | world-service | Подтверждение фиксации глитч-сообщения |
| GET | `/audio/subliminal/podcasts` | audio-service | Плейлист выпусков и маркеров |
| POST | `/auth/subliminal/opt-in` | auth-service | Переключение флага opt-in/out |
| POST | `/ui/subliminal/calibrate` | gameplay-service via gateway | Валидация результата мини-игры |

- Авторизация: scopes `social.subliminal`, `world.visuals`, `audio.stream`, `auth.preferences`.
- Все POST эндпоинты логируются с user-agent и IP для анти-абьюза.

---

## 5. Kafka события

| Топик | Publisher | Payload | Консьюмеры |
|-------|-----------|---------|------------|
| `social.subliminal.knock` | social-service | `{ playerId, guildId, timestamp, cooldownRemaining, status }` | realtime-gateway, analytics, notification |
| `social.subliminal.mail` | social-service | `{ messageId, playerId, codeHash, redeemed }` | analytics, inventory |
| `world.subliminal.billboard` | world-service | `{ billboardId, location, message, shard, expiresAt }` | frontend, analytics |
| `audio.subliminal.marker` | audio-service | `{ podcastId, markerIndex, coordinates }` | gameplay-service, frontend |
| `ui.subliminal.afterglow` | gameplay-service | `{ playerId, unlocked, source }` | inventory, analytics |

---

## 6. Анти-спам и безопасность

- Rate limits:
  - `/knock`: 1 запрос / 10 минут / аккаунт, 120 запросов / 10 минут / shard.
  - `billboards/ack`: 5 запросов / час / игрок.
  - `mail/redeem`: 3 кода / день / игрок.
- Санкции:
  - 3 нарушения лимитов → флаг `knock_warning`.
  - 5 нарушений / 24ч → флаг `knock_muted` (авто-снятие через 24 часа).
  - Авто-блок слов в сообщениях (аналог `chat-moderation`).
- Хранение кодов: SHA-256, соли на основе `messageId`.
- Поддержка opt-in: игроки без opt-in получают уведомление-сводку через почту раз в неделю.

---

## 7. Данные

```sql
CREATE TABLE social.subliminal_knock_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    guild_id UUID,
    result TEXT NOT NULL, -- ACCEPTED | RATE_LIMIT | MUTED
    shard TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    cooldown_seconds INT
);

CREATE TABLE social.subliminal_codes (
    message_id UUID PRIMARY KEY,
    code_hash TEXT NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,
    claimed_by UUID,
    claimed_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE world.subliminal_billboards (
    billboard_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location GEOGRAPHY(POINT, 4326),
    shard TEXT,
    message TEXT,
    visual_profile TEXT,
    active_from TIMESTAMPTZ,
    active_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

- Материализованный вид `analytics.subliminal_daily_metrics` агрегирует активность.
- GDPR: данные opt-in/opt-out хранятся в `auth.user_preferences`.

---

## 8. Награды и прогресс

| Активность | Требование | Награда | Источник |
|------------|------------|---------|----------|
| 3 HUD сигнала | `afterglow_counter ≥ 3` | Фильтр `Afterglow UI` | inventory-service (cosmetics) |
| Redeem кода | Успешный ввод | Предмет `Encrypted Bookmark` | inventory-service |
| Билборд | Фото подтверждено | Эмоция `Pixel Snap` | inventory-service |
| Подкасты | Все маркеры найдены | Мини-квест `Follow the Resonance` с баффом | gameplay-service |
| `/knock` кооперация | 5 игроков отвечают в 60 секунд | Бафф `Echo Sync` (15 мин) | gameplay-service |

- Прогресс хранится в `social.subliminal_progress` (JSONB поля).

---

## 9. Мониторинг и аналитика

- Метрики Prometheus:
  - `subliminal_knock_attempts_total`
  - `subliminal_knock_rate_limit_total`
  - `subliminal_billboard_active`
  - `subliminal_podcast_marker_completion`
  - `subliminal_opt_in_ratio`
- Аллерты:
  - `knock_rate_spike` (>150 попыток/10 мин).
  - `billboard_desync` (нет активных билбордов >1 час).
  - `podcast_dropoff` (completion <40%).
  - `opt_in_drop` (опт-ин <60%).
- Еженедельный отчёт: аналитику интересуют влияние на retention и social активности.

---

## 10. Зависимости

- `05-technical/backend/chat/chat-moderation.md` — повторное использование фильтров токсичности.
- `05-technical/backend/notification-system.md` — пуш уведомления.
- `FRONT-WEB/modules/ui/hud` — визуализация HUD сигналов.
- `FRONT-WEB/modules/settings/ui` — toggle и мини-игра.
- `API-SWAGGER/tasks/active/queue` — получит задачу после подтверждения ready.

---

## 11. Дорожная карта

| Дата | Шаг | Ответственные |
|------|-----|----------------|
| 2025-11-09 | Создать OpenAPI задачи (knock, mail redeem, billboards) | API Task Creator |
| 2025-11-10 | Настроить rate limit middleware и Kafka топики | Backend Guild |
| 2025-11-11 | UI mockup HUD/Settings, аудио маркеры | UI/UX, Audio |
| 2025-11-12 | QA проверка opt-in, accessibility | QA Guild |
| 2025-11-13 | Подготовка QA сценариев для баффов | Gameplay Guild |

---

## 12. История изменений

- 2025-11-08 16:51 — v1.0.0: добавлены API, Kafka, данные, анти-спам и мониторинг; документ переведён в ready.
- 2025-11-07 — Черновой сбор требований и вопросов.

