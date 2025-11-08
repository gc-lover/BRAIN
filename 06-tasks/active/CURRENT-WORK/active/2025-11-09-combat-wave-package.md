# Combat Systems Wave 1 Package

**Приоритет:** high  
**Статус:** in_progress  
**Ответственный:** Brain Manager  
**Старт:** 2025-11-09 01:15  
**Связанные документы:**  
- `.BRAIN/05-technical/backend/combat-session-backend.md`  
- `.BRAIN/02-gameplay/combat/combat-ai-enemies.md`  
- `.BRAIN/02-gameplay/combat/combat-implants-types.md`  
- `.BRAIN/02-gameplay/combat/combat-dnd-core.md`  
- `.BRAIN/02-gameplay/combat/combat-dnd-integration-shooter.md`  
- `.BRAIN/02-gameplay/combat/combat-abilities.md`  
- `.BRAIN/02-gameplay/combat/combat-shooting.md`  
- `.BRAIN/02-gameplay/combat/combat-combos-synergies.md`  
- `.BRAIN/02-gameplay/combat/combat-extract.md`  
- `.BRAIN/02-gameplay/combat/combat-freerun.md`  
- `.BRAIN/02-gameplay/combat/combat-hacking-networks.md`  
- `.BRAIN/02-gameplay/combat/combat-hacking-combat-integration.md`  
- `.BRAIN/02-gameplay/combat/combat-cyberspace.md`  
- `.BRAIN/02-gameplay/combat/combat-stealth.md`  
- `.BRAIN/02-gameplay/combat/arena-system.md`

---

## 1. Сводка готовности

| Документ | Версия | Статус | API каталог | Фронтенд модуль | Ключевые акценты |
| --- | --- | --- | --- | --- | --- |
| combat-session-backend.md | 1.0.0 | ready | `api/v1/gameplay/combat/combat-session.yaml` | `modules/combat` | lifecycle, damage loop, event bus |
| combat-ai-enemies.md | 1.0.0 | ready | `api/v1/gameplay/combat/ai-enemies.yaml` | `modules/combat/ai` | AI матрица, WS рейдов, античит |
| combat-implants-types.md | 1.1.0 | ready | `api/v1/gameplay/combat/implants.yaml` | `modules/combat/implants` | типы имплантов, ограничения, синергии |
| combat-dnd-core.md | 1.0.0 | ready | `api/v1/gameplay/combat/dnd-core.yaml` | `modules/combat/mechanics` | DC, модификаторы, преимуществ/помеха |
| combat-dnd-integration-shooter.md | 1.0.0 | ready | `api/v1/gameplay/combat/dnd-integration-shooter.yaml` | `modules/combat/mechanics` | микро-проверки, импланты, stealth synergy |
| combat-abilities.md | 1.2.0 | ready | `api/v1/gameplay/combat/abilities.yaml` | `modules/combat/abilities` | источники, ранги, киберпсихоз |
| combat-shooting.md | 1.1.0 | ready | `api/v1/gameplay/combat/shooting.yaml` | `modules/combat/shooting` | TTK, отдача, имплант-модификаторы |
| combat-combos-synergies.md | 1.0.0 | ready | `api/v1/gameplay/combat/combos-synergies.yaml` | `modules/combat/combos` | цепочки умений, эффект синергий |
| combat-extract.md | 1.3.0 | ready | `api/v1/gameplay/combat/extraction.yaml` | `modules/combat/extraction` | уровни риска, эвакуация, динамика лута |
| combat-freerun.md | 1.1.0 | ready | `api/v1/gameplay/combat/freerun.yaml` | `modules/combat/movement` | паркур, боевые манёвры, импланты |
| combat-hacking-networks.md | 1.0.0 | ready | `api/v1/gameplay/combat/hacking/networks.yaml` | `modules/combat/hacking` | уровни сетей, защита, перехват |
| combat-hacking-combat-integration.md | 1.0.0 | ready | `api/v1/gameplay/combat/hacking/combat-integration.yaml` | `modules/combat/hacking` | боевое хакерство, защитные протоколы |
| combat-cyberspace.md | 1.0.0 | ready | `api/v1/gameplay/combat/hacking/cyberspace.yaml` | `modules/combat/cyberspace` | режимы киберпространства, события |
| combat-stealth.md | 1.1.0 | ready | `api/v1/gameplay/combat/stealth.yaml` | `modules/combat/stealth` | каналы обнаружения, импланты, социалка |
| arena-system.md | 1.0.0 | ready | `api/v1/gameplay/combat/arena-system.yaml` | `modules/combat/arenas` | арены, рейтинги, voice-lobby |

Все документы проверены 2025-11-09 01:13–01:15, статусы и каталоги синхронизированы в `ready.md` и `readiness-tracker.yaml`.

---

## 2. Общие зависимости и интеграции

- **Микросервисы:** базовый `gameplay-service (8083)`, дополнительно `economy-service` (награждения), `social-service` (репутация), `world-service` (события зон), `analytics-service` (телеметрия), `auth-service` (валидация WebSocket).
- **Event Bus:** `combat.ai.state`, `raid.telemetry`, `combat.session.events`, `combat.freerun.movement`, `combat.hacking.alert`. Продюсеры/консьюмеры описаны в исходных документах.
- **WebSocket:** основной канал `wss://api.necp.game/v1/gameplay/raid/{raidId}`, дополнительные каналы для арен (`/arenas/{arenaId}/stream`) и киберпространства (`/cyberspace/{instanceId}`) — отразить в постановке задач.
- **Базы данных:** `enemy_ai_profiles`, `combat_sessions`, `combat_loadouts`, `cyberspace_instances`, `arena_matches` — схемы указаны в соответствующих документах.
- **D&D слой:** базовые проверки из `combat-dnd-core` используются во всех документах (abilities, stealth, freerun, hacking). Необходимо планировать повторное использование контрактов/справочников.

---

## 3. План для ДУАПИТАСК (без создания задач)

1. **REST**  
   - `/combat/sessions/*` — lifecycle, события, результаты;  
   - `/combat/ai/*` — профили врагов, телеметрия;  
   - `/combat/abilities/*` — CRUD по активным способностям, синергия;  
   - `/combat/hacking/*` — сетевые уровни, интеграция в бою, cyberspace;  
   - `/combat/stealth/*`, `/combat/freerun/*`, `/combat/extraction/*`, `/combat/arenas/*`;  
   - вспомогательные `/combat/dnd/checks`, `/combat/combos`.

2. **WebSocket**  
   - `raid/{raidId}` — события AI, механики, проверки;  
   - `arenas/{arenaId}/match` — рейтинговые события и голосовые приглашения;  
   - `cyberspace/{instanceId}` — VR-события, уровни доступа;  
   - мониторинг `freerun` и `stealth` (опционально через session stream).

3. **Kafka/Event Bus**  
   - подтвердить payload из документов (Combat AI, sessions, hacking, extract).  
   - подготовить схемы telemetry topics для analytics-service.

4. **Cross-cutting**  
   - единый reference по D&D проверкам (`combat-dnd-core`) и синхронизация с quest-engine.  
   - согласование security (anti-cheat, rate-limits) с `combat-session-backend`.

### 3.1 REST backlog (черновая декомпозиция)
| Приоритет | Endpoint | Источник документа | Краткое описание |
| --- | --- | --- | --- |
| P0 | `POST /combat/sessions` | combat-session-backend | запуск сессии, регистрация участников, выдача sessionId |
| P0 | `POST /combat/sessions/{id}/events` | combat-session-backend | публикация событий (damage, revive, state change) |
| P0 | `POST /combat/ai/profiles` | combat-ai-enemies | регистрация AI профиля врага (behaviour tree, skill deck) |
| P0 | `PUT /combat/ai/profiles/{enemyId}/phase` | combat-ai-enemies | обновление фазы рейда, механики, телеметрия |
| P1 | `GET /combat/abilities` | combat-abilities | перечень активных способностей и связанной синергии |
| P1 | `POST /combat/abilities/{abilityId}/sync` | combat-abilities + combat-combos-synergies | синхронизация способностей с комбо и D&D модификаторами |
| P1 | `POST /combat/dnd/checks` | combat-dnd-core | расчёт проверки (атрибуты, бонусы, модификаторы) |
| P1 | `POST /combat/dnd/micro-events` | combat-dnd-integration-shooter | логирование микро-проверок в бою |
| P1 | `POST /combat/hacking/networks/{networkId}/breach` | combat-hacking-networks | запуск взлома, уровни доступа, время |
| P1 | `POST /combat/hacking/combat/{sessionId}` | combat-hacking-combat-integration | интеграция боевого хакерства (offensive/defensive) |
| P1 | `POST /combat/cyberspace/instances` | combat-cyberspace | создание VR-сессии, уровни доступа |
| P1 | `POST /combat/stealth/events` | combat-stealth | фиксация обнаружения/стелс событий, модификаторы |
| P1 | `POST /combat/freerun/actions` | combat-freerun | паркур/манёвры, проверка ограничений |
| P2 | `POST /combat/extraction/zones/{zoneId}/extract` | combat-extract | старт/результат экстракции |
| P2 | `POST /combat/arenas/{arenaId}/match` | arena-system | старт арены, рейтинги, награды |
| P2 | `POST /combat/combos/apply` | combat-combos-synergies | применение комбо, проверка требований |

### 3.2 WebSocket backlog
| Приоритет | Канал | Источник | Описание payload |
| --- | --- | --- | --- |
| P0 | `wss://.../combat/raid/{raidId}` | combat-ai-enemies, combat-session-backend | `phase`, `mechanic`, `target`, `dndCheck` |
| P0 | `wss://.../combat/sessions/{sessionId}` | combat-session-backend | события damage/heal, состояние участников |
| P1 | `wss://.../combat/stealth/{sessionId}` | combat-stealth | `threatLevel`, `channel`, `detectedBy`, `timestamp` |
| P1 | `wss://.../combat/freerun/{sessionId}` | combat-freerun | `action`, `success`, `buffs`, `dndCheckId` |
| P1 | `wss://.../combat/cyberspace/{instanceId}` | combat-cyberspace | `layer`, `eventType`, `accessLevel`, `reward` |
| P2 | `wss://.../combat/arenas/{arenaId}/match` | arena-system | `score`, `phase`, `voiceInvite`, `rewardPreview` |

### 3.3 Event Bus backlog
| Topic | Producer | Consumer | Поля |
| --- | --- | --- | --- |
| `combat.ai.state` | gameplay-service (AI) | analytics-service, quest-engine | `enemyId`, `phase`, `threat`, `timestamp` |
| `combat.session.events` | gameplay-service (session) | analytics-service, economy-service | `sessionId`, `eventType`, `payload` |
| `combat.freerun.movement` | gameplay-service (movement) | analytics-service | `characterId`, `action`, `success`, `position` |
| `combat.hacking.alert` | gameplay-service (hacking) | security-service, quest-engine | `networkId`, `severity`, `source`, `actionRequired` |
| `combat.extraction.result` | gameplay-service (extract) | economy-service, inventory-service | `zoneId`, `outcome`, `loot`, `squad` |
| `combat.arena.match` | gameplay-service (arenas) | social-service, leaderboard-service | `arenaId`, `result`, `ratingDelta`, `reward` |

### 3.4 Зависимости и этапы
- **Этап 1 (P0):** combat sessions + raid AI (REST + WS + Kafka) — блокирует остальные подсистемы.
- **Этап 2 (P1):** D&D ядро, abilities, hacking, stealth/freerun — требует Stage 1 и готовности D&D контрактов.
- **Этап 3 (P2):** extraction, arenas, combos — можно запускать после стабилизации предыдущих этапов.
- **Shared requirements:** security (rate limits, anti-cheat), telemetry (analytics-service), economy (награждения).

---

## 4. Следующие действия

1. Сформировать резюме по каждому REST/WS endpoint с указанием источника документа и приоритета (внутри этой заметки или отдельным приложением).
2. Подготовить сетку зависимостей (какие задачи блокируют другие), чтобы этапировать создание API задач.
3. Проверить, нужно ли дополнительно обновить `implementation-tracker.yaml` (сейчас awaiting slot для всех боевых задач).
4. После снятия запрета на API-SWAGGER — передать пакет в ДУАПИТАСК одной волной либо несколькими подпакетами (AI, Hacking, Movement, Stealth/Abilities).
5. Продолжить синхронизацию с Quest Engine, чтобы D&D проверки и боевые события были согласованы до постановки задач.

---

## 5. История

- 2025-11-09 01:15 — собрана сводка Wave 1, подтверждена готовность документов, зафиксированы зависимости и план передачи.

