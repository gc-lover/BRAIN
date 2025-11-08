# Кросс-культурный атлас пасхалок — сезон Metropolis Threads

---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-366: api/v1/world/events/crossculture-atlas.yaml (2025-11-08 17:26)
  - API-TASK-367: api/v1/economy/crossculture/capsules.yaml (2025-11-08 17:26)
  - API-TASK-368: api/v1/social/crossculture/museum.yaml (2025-11-08 17:26)
- Last Updated: 2025-11-08 17:26
---

---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-08 16:51  
**api-readiness-notes:** Проработаны расписания, операции экономики, REST/Kafka контракты и UX требования для сезона Metropolis Threads. Документ готов к ДУАПИТАСК и синхронизирован с world/social/economy командами.
---

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07
**Последнее обновление:** 2025-11-08 16:51  
**Приоритет:** высокий  
**Ответственный:** AI Brain Manager  
**Связанные документы:** `../../ideas/2025-11-07-IDEA-crossculture-easter-atlas.md`, `../../../02-gameplay/world/events/world-events-framework.md`, `../../../02-gameplay/social/reputation-formulas.md`, `../../../03-lore/activities/activities-lore-compendium.md`  
**target-domain:** world-events / social-seasonal  
**target-microservice:** world-service (8086), economy-service (8085), social-service (8084)  
**target-frontend-module:** modules/world/events, modules/social/seasons  
**owner-guilds:** World Simulation, Social Systems, Economy, Audio  
**integration-services:** inventory-service, auth-service, notification-service, analytics-service, audio-service

---

## 1. Обзор и цели

- Организовать 90-дневный сезон «Metropolis Threads» с мультикультурными пасхалками, не нарушающими лицензионные ограничения.
- Обеспечить ротацию контента (граффити, павильоны, рынок, экскурсии, фестивали, музеи) и синхронизировать награды.
- Зафиксировать API, события, данные и мониторинг для world/economy/social сервисов, а также UI/UX требования.
- Поддержать социальную активность игроков и рост репутации `city.culture`, `city.community`.

---

## 2. Сезонный календарь

| Неделя | Активные элементы | Ключевые события | Примечания |
|--------|-------------------|------------------|------------|
| 1–4 | Аллея граффити, музыкальный павильон | Открытие сезона, daily photo челлендж | Фильтр `Dual Frame` разблокируется |
| 5–8 | Рынок капсул, экскурсии | Курируемый маршрут «Путешествие по шуму» | Титул `Cartographer of Noise` |
| 9–12 | Фестиваль «Слияние ветров» | AR сцены, сбор браслетов | Кат-сцена благодарности |
| 13–14 | Музей «Коды дружбы» | Пользовательские экспозиции | Награда `Сеть соединённых рук` |

- Каждая неделя имеет региональные временные окна (Asia, EU, Americas).
- Сезонная валюта: `thread-token` (лимит 150 за сезон).

---

## 3. Контентные хабы

### 3.1 Аллея граффити
- Ротация четырёх граффити профилей: `electro-sakura`, `andes-beat`, `glitch-calligraphy`, `noir-skyline`.
- Игроки активируют фотозоны, делятся снимками через `social-service`.
- Награда: фильтр фото-режима `Dual Frame` после 4 уникальных снимков, репутация `city.culture +20`.

### 3.2 Музыкальный павильон «Fusion Echo»
- Три плейлиста (`Metropolis`, `Tropical`, `Nordic`) + скрытый `Wave Residency`.
- Синхронизация панелей (мини-игра) активирует скрытый трек, выдаёт аудио-сувенир `soundchip.wave`.
- Audio-сервис публикует события `audio.fusion.sync`.

### 3.3 Рынок «Коллаб-капсулы»
- Точки продаж с аксессуарами, блюдами и эмоциями.
- Награда за сбор всех капсул: эмоция `World Pulse`, сезонный титул `Global Drifter`.
- Экономика: цены динамически регулируются, ограничение 3 покупки/день/игрока.

### 3.4 Экскурсии «Путешествие по шуму»
- NPC-гид запускает тур по скрытым сценам, выдаёт титул `Cartographer of Noise`.
- Логируется прохождение, предоставляются подсказки через диалоги.

### 3.5 Фестиваль «Слияние ветров»
- AR-сцены `Nordic Neon`, `Desert Pulse`, `Skyline Tide`.
- Сбор браслетов активирует кат-сцену и предмет `bracelet.harmony-link`.
- Voice Lobby интеграция для создания групповых комнат.

### 3.6 Музей «Коды дружбы»
- Пользовательские экспозиции (до 5 залов на гильдию). Стандарт: 20 объектов, лимит 128 МБ ассетов.
- Награда за посещение всех залов: предмет `network.woven-hands`.
- Модерация через `social-service` (auto-flag + ручная проверка).

---

## 4. REST API контракты

| Метод | Путь | Сервис | Описание |
|-------|------|--------|----------|
| GET | `/world/seasons/crossculture/schedule` | world-service | Расписание недель, активных хабов |
| GET | `/world/seasons/crossculture/hubs` | world-service | Сводка состояний (граффити, павильон, музей) |
| POST | `/world/seasons/crossculture/hubs/{hubId}/activate` | world-service | Форсированная активация (для GM) |
| GET | `/economy/crossculture/capsules` | economy-service | Каталог капсул, цены, лимиты |
| POST | `/economy/crossculture/capsules/purchase` | economy-service | Покупка капсулы (передача `playerId`, `capsuleId`) |
| POST | `/social/crossculture/photos` | social-service | Регистрация фото, проверка уникальности |
| POST | `/social/crossculture/tour/progress` | social-service | Логирование экскурсии |
| POST | `/world/seasons/crossculture/festival/bracelet` | world-service | Обмен набора браслетов на кат-сцену |
| GET | `/social/crossculture/museum/exhibits` | social-service | Каталог экспозиций |
| POST | `/social/crossculture/museum/exhibits` | social-service | Создание/обновление экспозиции (moderation queue) |

- Авторизация: scopes `world.seasons`, `economy.market`, `social.media`.
- Валидация капсул: economy проверяет лимиты и баланс, inventory выдаёт предметы.

---

## 5. Kafka события

| Топик | Publisher | Payload | Консьюмеры |
|-------|-----------|---------|------------|
| `world.season.crossculture.lifecycle` | world-service | `{ week, activeHubs[], state, timestamp }` | frontend, analytics, notification |
| `economy.crossculture.purchase` | economy-service | `{ playerId, capsuleId, price, currency }` | analytics, inventory, achievement |
| `social.crossculture.photolog` | social-service | `{ photoId, playerId, hubId, filters[], validated }` | moderation, analytics |
| `social.crossculture.exhibit` | social-service | `{ exhibitId, guildId, status, curatorId }` | moderation-dashboard, notification |
| `audio.fusion.sync` | audio-service | `{ sessionId, panelState, trackUnlocked }` | analytics, ui-gateway |

---

## 6. Данные и лимиты

```sql
CREATE TABLE world.crossculture_hubs (
    hub_id TEXT PRIMARY KEY,
    hub_type TEXT NOT NULL,
    region TEXT NOT NULL,
    schedule JSONB NOT NULL,
    active BOOLEAN DEFAULT FALSE,
    last_activated TIMESTAMPTZ,
    metadata JSONB
);

CREATE TABLE economy.crossculture_capsules (
    capsule_id TEXT PRIMARY KEY,
    price_amount NUMERIC(10,2),
    price_currency TEXT,
    purchase_limit_daily INT,
    rewards JSONB,
    active_from TIMESTAMPTZ,
    active_to TIMESTAMPTZ
);

CREATE TABLE social.crossculture_exhibits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guild_id UUID NOT NULL,
    curator_id UUID NOT NULL,
    status TEXT NOT NULL, -- DRAFT | PENDING | APPROVED | REJECTED
    assets JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    moderation_notes JSONB
);
```

- Ограничения: максимальный размер ассетов 128 МБ (S3 storage).
- Модерация: SLA 24 часа, авто-удаление при 3 отклонениях подряд.

---

## 7. Экономика и награды

| Активность | Валюта | Базовая награда | Уникальная награда | Лимит |
|------------|--------|-----------------|-------------------|-------|
| Граффити | thread-token | 50 token | Фильтр `Dual Frame` | 1 раз/сезон |
| Музыкальный павильон | thread-token | 40 token | `soundchip.wave` | 1 раз/неделю |
| Рынок капсул | eddies + token | Косметика, блюда | Эмоция `World Pulse` (комплект капсул) | 3 покупки/день |
| Экскурсия | token | 30 token | Титул `Cartographer of Noise` | 1 раз/сезон |
| Фестиваль | token | 60 token | Кат-сцена + `bracelet.harmony-link` | 1 раз/сезон |
| Музей | token | 20 token | `network.woven-hands` | 1 раз/сезон |

- Токены конвертируются в косметику у вендора `city-cultural-broker`.

---

## 8. UX и визуал

- HUD уведомления используют `shared/ui/EventTicker`.
- Фото-режим интегрирован с `shared/ui/PhotoOverlay`, новый фильтр `Dual Frame`.
- Экскурсии используют `modules/world/tours` с мини-картой и голосовым сопровождением.
- AR эффекты имеют режим `low-spec` (упрощённые шейдеры, отключение HDR вспышек).
- UI toggle: «Кросс-культурный сезон» (включает уведомления, AR эффекты).

---

## 9. Мониторинг и аналитика

- Метрики: `season_crossculture_participation_total`, `capsule_sales_total`, `exhibit_active_total`, `photo_unique_total`, `audio_panel_sync_success_rate`.
- Дашборд:
  - Конверсия участников по регионам.
  - Средний чек капсулы.
  - Нагрузка на moderation queue.
  - Sentiment анализ (подключение к social listening).
- Аллерты: 
  - `capsule_stockout` — 0 доступных капсул > 2 часа.
  - `exhibit_moderation_sla` — заявки старше 24 часов.
  - `audio_sync_fail` — <70% успешных синхронизаций.

---

## 10. Зависимости и интеграции

- `02-gameplay/world/events/live-events-system.md` — расписания событий.
- `05-technical/backend/announcement/announcement-system.md` — уведомления и рекламные баннеры.
- `05-technical/backend/voice-lobby/voice-lobby-system.md` — групповые комнаты фестиваля.
- `05-technical/backend/support/support-ticket-system.md` — эскалации по модерации.
- `FRONT-WEB/modules/world/events` и `modules/social/seasons` — UI имплементация.
- Локализация: все названия хабов и предметов через `08-references/localization-matrix.md`.

---

## 11. Дорожная карта

| Дата | Шаг | Ответственные |
|------|-----|----------------|
| 2025-11-09 | Создать API задачи (schedule, hubs, economy) | API Task Creator |
| 2025-11-10 | Запустить кодогенерацию в BACK-JAVA/FRONT-WEB | Backend, Frontend |
| 2025-11-11 | Завершить UX мокапы и аудио миксы | UI Guild, Audio Guild |
| 2025-11-12 | Настроить аналитические отчёты | Analytics Guild |
| 2025-11-13 | Финальное ревью культурного контента | Narrative Guild |

---

## 12. История изменений

- 2025-11-08 16:51 — v1.0.0: завершена спецификация сезона, добавлены API, данные, мониторинг, статус ready.
- 2025-11-07 — Создан черновик, собраны цели и вопросы.

