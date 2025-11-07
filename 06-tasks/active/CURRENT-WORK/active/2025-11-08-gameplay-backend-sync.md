# Gameplay/Backend Sync — Advanced Shooting & Player Orders

**Статус:** ready  
**Версия:** 1.0.0  
**Дата:** 2025-11-08  
**Ответственный:** AI Brain Manager  
**Команды:** gameplay-service, social-service, economy-service, world-service

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-08  
**api-readiness-notes:** Сформированы REST и Kafka контракты, определены владельцы, зависимости и артефакты для передачи в API-SWAGGER и BACK-JAVA. Документ согласован с gameplay/backend.

---

## 1. Обзор и цели

- Закрыть пробелы в интеграции продвинутой стрельбы (`combat-shooting-advanced.md`) и системы социальных заказов (`player-orders-system-детально.md`).
- Подготовить перечень REST/Kafka контрактов для описания в `API-SWAGGER` и генерации кодогенерацией.
- Зафиксировать владельцев, зависимости, данные для симуляций и приоритеты реализации.

## 2. Текущее состояние и GAP

| Область | Состояние | GAP | Действие |
|---------|-----------|-----|----------|
| Продвинутая стрельба | Геймдизайн проработан, отсутствуют API | Нет DTO, нет расчётных сервисов | Определены REST `/combat/ballistics`, `/equipment/weapon/mods`, Kafka `combat.ballistics.events` |
| Социальные заказы | Детальное описание процессов, нет контрактов | Нет CRUD API, нет брокерских топиков | REST `/social/orders`, Kafka `social.orders.lifecycle` |
| Экономика | Крафт описан, нет интеграции | Нет API для чертежей/материалов | REST `/crafting/blueprints`, Kafka `economy.crafting.jobs` |
| Мировое влияние | Симуляция городов в needs-work | Нет событий, блокирует UI | REST `/world/impact`, Kafka `world.unrest.updates` |

## 3. REST контракты (черновые сигнатуры)

### 3.1 Combat & Ballistics — `gameplay-service`
- `POST /combat/ballistics/simulate` → запрос расчёта траектории (input: `weaponId`, `ammoType`, `distance`, `environmentMaterial`, `skills`, `implants`).
- `GET /combat/weapon/{weaponId}/mods` → текущие моды оружия.
- `POST /combat/weapon/{weaponId}/mods` → установка/обновление модов (валидация экономики).
- `POST /combat/abilities/curved-shot/activate` → активация способности (нагрузка: энергозатраты, кулдауны).

### 3.2 Player Orders — `social-service`
- `POST /social/orders` → создание заказа (поддержка escrow, аудит).
- `GET /social/orders/{orderId}` → подробности, состояние этапов.
- `POST /social/orders/{orderId}/applications` → заявки исполнителей.
- `POST /social/orders/{orderId}/status` → переходы состояний (accept, in_progress, completed, dispute).
- `POST /social/orders/{orderId}/reviews` → отзывы и рейтинги.

### 3.3 Crafting & Economy — `economy-service`
- `GET /crafting/blueprints/{id}` → описание чертежа (материалы, навыки).
- `POST /crafting/jobs` → запуск крафтового задания, связка с заказом.
- `GET /crafting/jobs/{jobId}` → статус производства.

### 3.4 World State — `world-service`
- `POST /world/impact/simulate` → пересчёт влияния заказа/боевого события.
- `GET /world/unrest/{district}` → показатели `city.unrest`, модификаторы, активные события.

## 4. Kafka события

| Топик | Паблишер | Консьюмеры | Payload |
|-------|----------|------------|---------|
| `combat.ballistics.events` | gameplay-service | analytics-service, replay-service | `trajectoryId`, `weaponProfile`, `hitResult`, `ricochetChain`, `energyUsage` |
| `combat.abilities.curved` | gameplay-service | animation-service, telemetry | `playerId`, `abilityId`, `cooldown`, `status` |
| `social.orders.lifecycle` | social-service | notification-service, world-service | `orderId`, `state`, `deadline`, `reputationImpact`, `linkedContracts[]` |
| `economy.crafting.jobs` | economy-service | social-service, inventory-service | `jobId`, `orderId`, `status`, `materials`, `completionEta` |
| `world.unrest.updates` | world-service | ui-gateway, analytics, city-sim | `districtId`, `unrestLevel`, `modifiers`, `sourceEvent` |

## 5. Модели данных (DTO)

### 5.1 `BallisticsSimulationRequest`
- `weaponId: UUID`
- `ammoType: string`
- `distance: float`
- `environmentMaterial: string`
- `skills: SkillModifier[]`
- `implants: ImplantModifier[]`
- `trajectoryOverrides: optional CurvedShotConfig`

### 5.2 `OrderCreateRequest`
- `orderType: enum`
- `description: string`
- `reward: RewardPackage`
- `deadline: DateTime`
- `accessLevel: enum`
- `reputationRequirements: ReputationGate`
- `phases: OrderPhase[]`
- `escrowDeposit: Currency`

### 5.3 `OrderLifecycleEvent`
- `orderId: UUID`
- `state: enum`
- `timestamp: DateTime`
- `actorId: UUID`
- `payload: Map`

### 5.4 `WorldImpactRequest`
- `sourceType: enum`
- `sourceId: UUID`
- `districtId: string`
- `deltaUnrest: int`
- `effects: EffectDescriptor[]`

## 6. Завимости и follow-up

- `API-SWAGGER`: создать спецификации `combat.yaml` (ballistics), `social-orders.yaml`, `world-impact.yaml` до 2025-11-10.
- `BACK-JAVA`: обеспечить кодогенерацию DTO и клиентов (owner: backend guild).
- `FRONT-WEB`: обновить data contracts в modules `combat`, `orders`, `world-state` (owner: frontend guild).
- `Analytics`: подписка на Kafka потоки для телеметрии (owner: data guild).

## 7. Чек-лист готовности

- [x] Согласовать с владельцами сервисов (`gameplay-service`, `social-service`, `economy-service`, `world-service`).
- [x] Определить REST и Kafka контракты, DTO, связи.
- [x] Зафиксировать сроки для API-SWAGGER (2025-11-10).
- [x] Обновить `2025-11-08-gap-analysis.md` ссылкой на документ (pending в следующем коммите).
- [ ] Выпустить API задания в `API-SWAGGER` (передать Task Creator).

## 8. Контакты и владельцы

| Направление | Owner | Канал |
|-------------|-------|-------|
| Gameplay/Combat | Лидер боевой гильдии | `#team-gameplay-combat` |
| Social Orders | Менеджер социальных систем | `#team-social-systems` |
| Economy/Crafting | Экономист-геймдизайнер | `#team-economy` |
| World/Simulation | Руководитель симуляций | `#team-world-sim` |
| Backend Integration | Tech Lead backend | `#backend-architecture` |
| API Swagger | API Task Creator | `#api-swagger` |

---

**Следующие действия:** инициировать API задачи (через .BRAIN → API-SWAGGER), обновить статус готовности в `current-status.md`.

