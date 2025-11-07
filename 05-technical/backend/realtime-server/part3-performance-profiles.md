# Realtime Server - Part 3: Performance Profiles

---
**API Tasks Status:**
- Status: not_created
- Tasks:
  - N/A
- Last Updated: 2025-11-07 11:13
---

**Статус:** draft  
**Версия:** 0.1.0  
**Дата:** 2025-11-07 11:13  
**api-readiness:** draft

[← Part 2](./part2-protocol-optimization.md) | [Навигация](./README.md)

---

## Назначение документа

Документ описывает кастомные профили производительности для realtime-серверов NECPGAME. Каждый профиль соответствует типу контента и определяет базовые значения тикрейта, сетевых и вычислительных бюджетов, требования к оборудованию и дополнительные параметры, влияющие на качество сервиса. Матрица профилей позволяет заранее планировать горизонтальное и вертикальное масштабирование, а также согласовывать ожидания команд PvP, PvE и инфраструктуры.

---

## Матрица профилей контента

| Профиль | Контент | Tick Rate (Hz) | Snapshot Interval (мс) | Input Buffer (мс) | Max Players / Instance | AI Budget / Tick (мс) | Примечания |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Esports Arena** | Ranked PvP 5v5, 3v3 Duels | 120 | 8 | 12 | 12 | 1 | Максимальный приоритет QoS, детальная телеметрия на каждое действие, повышенный античит (frame-by-frame).
| **Competitive Siege** | GvG 20v20, PvPvP King of the Hill | 90 | 11 | 18 | 50 | 2 | Упор на консистентность попаданий, адаптивная динамическая интерполяция, двуступенчатая валидация урона.
| **Extraction Ops** | PvPvE Extraction, Heist, Rogue Missions | 75 | 13 | 22 | 36 | 4 | Баланс real-time PvP и сложных AI; приоритет на репликацию целей и лута, гибридная система интересов (AOI + задачные группы).
| **Open World Conflict** | PvPvE на открытых картах, события 64+ игроков | 60 | 17 | 28 | 96 | 6 | Динамический тикрейт (60→45 при перегрузке), агрессивное AOI, зональный античит.
| **Narrative Raids** | PvE рейды 12-24 игроков, World Boss | 45 | 22 | 32 | 24 | 8 | Основной бюджет на AI и скрипты босса, расщепление рассылок по ролям (Tank/Heal/DPS), relaxed QoS.
| **Massive Warfront** | GvGvG и сезонные войны 100+ игроков | 40 | 25 | 35 | 120 | 5 | Tick decimation (каждый третий тик full state), делегированное моделирование отрядов, обязательный серверный предиктор траекторий.
| **Casual Coop** | PvE миссии, данджи 4-8 игроков | 30 | 33 | 40 | 16 | 10 | Низкий тикрейт, приоритет стабильности, batching событий и prefetching данных окружения.
| **Social Hub** | Городские зоны без боёв, мероприятия | 20 | 50 | 60 | 150 | 2 | Поддержка сотен игроков, упор на стриминг косметики и чата, отключение детальной физики.

### Дополнительные параметры по профилям

- **Tick Elasticity:** для профилей Open World Conflict и Massive Warfront используется ступенчатое снижение до 45/30 Hz при загрузке CPU > 75% в течение 3 секунд.
- **Snapshot Strategy:** Esports Arena и Competitive Siege отправляют полные снимки каждые 200 мс, остальные профили используют delta-компрессию с приоритетом критических сущностей.
- **Priority Channels:** отдельные очереди сообщений для боевых событий, команд управления и вторичных данных (анимации, косметика). В Esports Arena и Competitive Siege критические каналы ограничены максимум 2мс задержки на обработку.
- **Interest Management:** гибридная модель (квадродерево + task groups). Для Extraction Ops акцент на количестве активных задач, в Massive Warfront — на принадлежности к взводам.
- **Reliability Policies:** PvP-профили повторяют critical пакеты до 3 раз, PvE-профили ограничиваются 2 попытками и fallback на предикцию.

---

## Параметры и их назначение

| Параметр | Описание | Ответственный сервис |
| --- | --- | --- |
| Tick Rate | Частота обновления геймплейного цикла. Влияет на точность боевых взаимодействий и плавность движения. | gameplay-service / world-service |
| Snapshot Interval | Частота рассылки авторитетных снимков состояния. | realtime dispatcher в world-service |
| Input Buffer | Скользящее окно, допускающее задержку ввода для сглаживания скачков пинга. | gameplay-service (input reconciliation) |
| AI Budget | Максимальный бюджет вычислений AI на тик, предотвращает starvation сетевых задач. | gameplay-service (AI cluster) |
| Max Players / Instance | Жёсткий лимит соединений на инстанс. Используется впервые при матчмейкинге. | orchestrator (matchmaking + deployment) |
| Priority Channels | Количество и тип очередей сообщений с QoS. | api-gateway + world-service |
| Telemetry Density | Частота отправки метрик и логов (per tick, per second, per event). | monitoring-service |
| Anti-Cheat Level | Набор проверок (basic, advanced, forensic). | anti-cheat-service |

---

## Серверные профили оборудования

| Профиль | vCPU | RAM | Network (Gbps) | Storage | Примечания |
| --- | --- | --- | --- | --- | --- |
| Esports Arena | 16 | 32 GB | 10 | NVMe 1 TB | Один инстанс = один матч, CPU pinning, NUMA awareness.
| Competitive Siege | 24 | 48 GB | 10 | NVMe 1 TB | Поддержка горячей репликации состояния на standby-инстанс.
| Extraction Ops | 20 | 48 GB | 10 | NVMe 1 TB | GPU-ускорение pathfinding (опционально) через CUDA воркеры.
| Open World Conflict | 32 | 64 GB | 25 | NVMe 2 TB | Высокая пропускная способность сети, обязательный dedicated Redis shard.
| Massive Warfront | 48 | 128 GB | 40 | NVMe 2 TB | Шардирование по батальонам, требуется колокация с Kafka.
| PvE / Social | 12 | 24 GB | 5 | SSD 512 GB | Возможен мульти-инстанс на одном bare-metal хосте.

### Автоскейлинг

- **Горизонтальное масштабирование:** на основе метрик времени обработки тика (TargetTickDuration) и активных соединений. Порог масштабирования задаётся как 0.85 * Max Players.
- **Вертикальное масштабирование:** шаблоны Terraform готовят отдельные пуллы для профилей Esports Arena, Open World Conflict и Massive Warfront; переключение осуществляется через blue-green запуск.
- **Warm Pools:** поддерживаются прогретые инстансы (5 минут readiness) для Esports Arena и Extraction Ops, что обеспечивает время старта < 30 секунд.

---

## QoS и управление трафиком

- **API Gateway:** применяет приоритизацию на основе профиля матча; каналы PvP получают класс обслуживания `premium-low-latency`.
- **Network Shaping:** использование gRPC + WebSocket multiplexing с ограничением MTU 1200 байт; в PvP профилях включена FEC (Forward Error Correction) 5%.
- **Packet Batching:** в PvE профилях отправка пакетов происходит каждые 2 тика (для экономии пропускной способности).
- **Compression:** MessagePack + Zstd (уровень 3) для payload > 8 KB.

---

## Античит и целостность

- **Esports / Competitive:**
  - Серверные проверки every tick (позиция, скорость, частота действий).
  - Повторная симуляция сервером до 120 тиков в прошлое для выяснения коллизий.
  - Сбор геймплейных replay-файлов для арбитража.
- **Extraction / Open World:**
  - Проверка целостности лута, контроль teleport/clip.
  - Отложенная форензика с анализом heatmap передвижений.
- **PvE / Social:**
  - Базовые проверки, фокус на защите экономики (дубликаты, gold-dupe detection).

---

## Мониторинг и SLO

- **Основные метрики:** TickDuration p95, NetworkLatency p95, PacketLoss %, ActiveConnections, AOIEntities.
- **SLO по профилям:**
  - Esports Arena: TickDuration p95 ≤ 8.5 мс, NetworkLatency p95 ≤ 35 мс.
  - Competitive Siege: TickDuration p95 ≤ 11 мс, NetworkLatency p95 ≤ 45 мс.
  - Extraction Ops: TickDuration p95 ≤ 14 мс, PacketLoss ≤ 1.5%.
  - PvE Raids: TickDuration p95 ≤ 18 мс, AI Budget Utilization ≤ 85%.
- **Alerting:** PagerDuty инцидент при превышении SLO двух интервалов подряд; автоматическое масштабирование до диагностики.

---

## Связанные документы

- `./part1-architecture-zones.md` — зоны, инстансы, распределение игроков.
- `./part2-protocol-optimization.md` — сетевой протокол и оптимизации.
- `../realtime-server/README.md` — общая навигация по разделу.
- `../../infrastructure/caching-strategy.md` — уровни кэширования для realtime трафика.
- `../../infrastructure/anti-cheat-system.md` — уровни защиты и интеграция с профилями.


