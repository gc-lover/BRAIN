---
**Статус:** draft  
**Версия:** 0.1.0  
**Дата:** 2025-11-07 20:45  
**Автор:** AI Brain Manager
---

# City Life API Task Package

## Цель

Подготовить входные данные для API Task Creator: финальные сущности, события и эндпоинты, необходимые для интеграции алгоритма оживления городов в API-SWAGGER (world-service, social-service, economy-service, gameplay-service).

## Контракты и эндпоинты

### World-service

1. `POST /world/cities/{cityId}/recompute`
   - scope: `city` | `district`
   - payload: `{ "scope": "district", "targets": ["watson"], "reason": "player_impact", "triggerId": "impact-123" }`
   - response: `202 Accepted` → `{ "jobId": "recompute-456", "eta": "PT3M" }`
   - kafka emit: `world.city.recompute.requested`
2. `GET /world/cities/{cityId}/snapshot`
   - query: `include=metrics,infrastructure,npcOverview`
   - response: агрегированное состояние города (см. payload ниже)
3. `GET /world/cities/{cityId}/districts/{districtId}`
   - возвращает `district_profile`, метрики, версии инфраструктуры

**Payload snapshot:**
```
{
  "cityId": "night-city",
  "version": 27,
  "generatedAt": "2025-11-07T19:55:00Z",
  "livingMetrics": {
    "npcDensity": { "target": 0.72, "current": 0.70 },
    "infrastructureLoad": 0.78,
    "diversityIndex": 1.92
  },
  "districts": [
    {
      "districtId": "watson",
      "profile": "industrial",
      "metrics": {"density": 0.72, "crime": 0.82},
      "infrastructureVersion": 14,
      "npcOverview": {"total": 450000, "dynamic": 0.31}
    }
  ]
}
```

### Social-service

1. `GET /social/npc/{npcId}` → `{ profile, schedule, relationships, currentState }`
2. `GET /social/npc` (query) → фильтрация по `districtId`, `rarity`, `status`
3. `PATCH /social/npc/{npcId}/schedule` → обновление расписания после пересчёта

**Kafka:**
- `social.npc.schedule.v1` (key `npcId`)
- `social.npc.relationship.updated`

**Schedule payload:**
```
{
  "npcId": "npc-8f1c",
  "scheduleVersion": 5,
  "mode": "normal_day",
  "stateMachine": {
    "states": ["home", "transit", "work", "leisure"],
    "transitions": ["home->transit", "transit->work"]
  },
  "slots": [
    {"from": "06:00", "to": "08:00", "location": "home", "activity": "wake_up"},
    {"from": "08:00", "to": "08:45", "location": "metro-12", "activity": "commute", "transport": "metro"}
  ]
}
```

### Economy-service

1. `GET /economy/districts/{districtId}/infrastructure`
2. `PATCH /economy/infrastructure/{instanceId}` — обновление статуса `planned|active|degraded|offline`
3. `POST /economy/infrastructure/{instanceId}/alerts` — регистрация событий перегрузки

**Kafka:** `economy.infrastructure.alerts` (key `districtId`, payload `{ objectId, loadFactor, forecastLoad, status }`)

### Gameplay-service

1. `POST /gameplay/player-impact`
   - payload: `{ "playerId": "p-31", "impactType": "quest", "delta": { "faction.maelstrom": 12 }, "affectedDistricts": ["watson"], "severity": "major" }`
2. `GET /gameplay/player-impact/{impactId}`
3. `GET /gameplay/city-activity/{cityId}` — агрегированные события игроков

**Kafka:** `gameplay.player.impact`

## ER-схемы (кратко)

- `city_districts`: ключевые поля `city_id`, `district_id`, `metrics`, `population_target`, `version`
- `infrastructure_instances`: `instance_id`, `district_id`, `category`, `capacity`, `state`, `owner_faction`
- `npc_profiles`: `npc_id`, `archetype_id`, `rarity`, `district_id`, `faction_id`, `priority_score`
- `npc_schedules`: `schedule_id`, `npc_id`, `mode`, `fsm`, `slots`, `version`
- `world_events_bindings`: `event_id`, `district_id`, `demand_modifiers`, `npc_modifiers`, `duration`
- `player_impact_log`: `impact_id`, `player_id`, `impact_type`, `delta`, `affected_districts`, `timestamp`, `processed`

## Зависимости и данные

- Baseline JSON: `content-generation/baseline/*.json`
- Лор: Night City (Watson, Westbrook), Tokyo (Shinjuku), Berlin (Kreuzberg)
- Телеметрия: `gameplay-service` события игрока, `economy-service` нагрузка инфраструктуры, `social-service` расписания

## Требования к API задачам

1. Определить схемы запросов/ответов (OpenAPI) для перечисленных эндпоинтов.
2. Описать kafka topics, ключи и payload.
3. Задокументировать схемы DTO для ER-сущностей.
4. Указать связи с существующими swagger API (world-state, social, economy, gameplay).
5. Подготовить тестовые примеры с использованием baseline JSON.

## Пакет для API Task Creator

- Документ: `city-life-api-task-package.md`
- Приложения: baseline файлы, алгоритм 0.3.0, ER-схемы, payload примеры.
- Следующий шаг: создать карточку в API-SWAGGER/tasks с ссылкой на этот пакет и указанием микросервисов world/social/economy/gameplay.

