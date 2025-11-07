# Глобальные исследования и технологии 2020–2093

**ID документа:** `world-global-research-2020-2093`  
**Тип:** world-progression  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:15  
**Приоритет:** высокий  
**Связанные документы:** `faction-wars-2020-2093.md`, `economy-specter-helios-balance.md`, `specter-helios-proxy-war.md`, `quests/raid/2025-11-07-quest-helios-countermesh-conspiracy.md`, `city-unrest-escalations.md`, `faction-quest-chains.md`  
**target-domain:** world/gameplay  
**target-мicroservices:** world-service, gameplay-service, economy-service, social-service, analytics-service  
**target-frontend-модули:** modules/world/research, modules/gameplay/progression, modules/economy/markets  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:15  
**api-readiness-notes:** Хронология глобальных исследований 2020–2093: ветки технологий, условия, эффекты, API и телеметрия.

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-275: api/v1/gameplay/world/research/global-research.yaml (2025-11-08 01:55)
- Last Updated: 2025-11-08 01:55
---

---

## 1. Концепция
- Глобальные исследования — долгосрочные мировые проекты, открывающие технологии, модификаторы и активности.
- Развитие зависит от `war_history`, `city_unrest`, `faction_prestige` и успехов рейдов/квестов.
- Игроки участвуют через вклад ресурсов, выполнение контрактов, PvPvE операций.
- Исследования дают экономические, боевые, социальные и лорные бонусы, создают новые пасхалки.

## 2. Структура веток исследований

| Период | Исследование | Ключевые фракции | Требования | Разблокируемые технологии | Пасхалки |
|--------|--------------|------------------|------------|---------------------------|----------|
| 2020–2026 | `Underlink Genesis` | Netwatch, Specter Cells | Завершить `Global Net Skirmishes`, вложить 1 000 `ghost-credits` | Underlink сеть, базовые кибердеки, PvE миссии «Genesis Dive» | Отсылки к NotPetya, SolarWinds аналитике |
| 2027–2034 | `Countermesh Engineering` | Helios, Militech Advisors | Победа в `Helios-Indra Feud`, собрать `countermesh-alloy` ×10 | Countermesh защиты, рейд `CM-Viper`, модульные щиты | Подкаст «SolarWinds Redux», мемы «Anonymous comeback» |
| 2035–2042 | `NeuroWeave Diplomacy` | Specter, Neo-Tokyo Gov | Поддержать `Neo-Tokyo Data Purge`, выполнить social-квесты | Импланты Empathy Sync, дипломатические мини-игры | AR сериал «Ghost in the Wires Season 4» |
| 2043–2051 | `Orbital Harness` | Space Libertad, NUSA Orbital | Успешно завершить `Libertad Low Orbit War`, инвестировать `underlink-bonds` ×30 | Zero-G рейды, космо лифты, торговые сети | Мем ETF «STONKS ZERO-G», Ever Given 2.0 VR |
| 2052–2061 | `Gaia Seed Initiative` | Gaia EcoCells, Specter Mediators | Стабилизировать `Gaia Terraform Rebellion`, выполнить eco-контракты | Биомодульные импланты, eco-радар, зелёные поселения | Докфильм «Terraform Tears», AR сады |
| 2062–2070 | `Proxy War Matrix` | Specter, Helios | Развить `Night City Proxy Siege`, собрать War Data ×100 | Proxy War Leaderboard, мирные медиаторы, war analytics | Midnight News «Proxy War Stories», мемы «NotPetya 2077 Remix» |
| 2071–2078 | `Shardfall Archives` | Ghost Tribes, Helios Splinters | Пройти `Shardfall Insurrection`, захватить станцию | Архивы знаний, новые классы рейдов, data relics | AR хорал «Boston Dynamics Choir» |
| 2079–2086 | `Stellar Commerce Grid` | Specter Alliance, EVE SynCorp | Успех в `Stellar Trade Wars`, 50 контрактов | Автоматизация торгов, Hyperloop Logistics, NFT cargo | Hyperloop Karaoke 2085, Cargo DAO мемы |
| 2087–2093 | `Blackwall Renaissance` | Specter Oracle, Helios Blackwall Division | Завершить `Blackwall Renaissance Conflict`, удерживать city unrest < 60 | Blackwall синергии, финальные рейды, AI дипломаты | «Blackwall Symphony», Ghost in the Wires Live S15 |

## 3. Узлы исследований (псевдо-YAML)

```yaml
research-tree:
  - id: underlink-genesis
    years: 2020-2026
    requirements:
      - war_flag: flag.netwatch.vigilance
      - resource: ghost-credits >= 1000
    effects:
      - unlock_activity: underlink-genesis-dive
      - add_modifier:
          world.hacking_dc: -1
      - trigger_event: UNDERLINK_GENESIS_COMPLETED
    telemetry:
      metric: research_underlink_contribution
      reward: title.underlink-pioneer

  - id: countermesh-engineering
    years: 2027-2034
    requirements:
      - research_completed: underlink-genesis
      - item: countermesh-alloy >= 10
    effects:
      - unlock_raid: cm-viper
      - grant_item: countermesh-shield-blueprint
      - add_modifier:
          economy.helio_store_discount: 0.1
    easter_egg: "Музей SolarWinds Redux — экскурсия в AR."

  - id: proxy-war-matrix
    years: 2062-2070
    requirements:
      - war_meter: >= 40
      - activity: proxy-war-participation >= 200 players
    effects:
      - unlock_leaderboard: proxy-war
      - set_flag: flag.proxy_war.matrix_enabled
      - add_modifier:
          city_unrest_decay: +5
    events:
      - PROXY_WAR_MATRIX_ONLINE
      - NIGHTHUB_MEME_DROP
```

## 4. Технологические эффекты и модификаторы
- **Экономика:** скидки в магазинах Helios/Specter, новые товары (`countermesh-shield`, `eco-harvester`).
- **Бой:** импланты `Empathy Sync`, `Blackwall Overclock`, новые боевые стили.
- **Социальные:** дипломатические мини-игры, AR шоу, подкасты, романтические ветки (Kaori/Kaede).
- **Мир:** изменение `city_unrest` decay, открытие новых локаций (Orbital Lifts, Eco Zones).
- **Пасхалки:** VR экскурсия по Ever Given 2.0, AR музей Anonymous 2020s, «Blackwall Symphony».

## 5. API и интеграции
- world-service: `GET /api/v1/world/research/state`, `POST /api/v1/world/research/progress`, `POST /api/v1/world/research/event`.
- gameplay-service: `POST /api/v1/gameplay/research/unlock-tech`.
- economy-service: `POST /api/v1/economy/research/apply-modifier`.
- social-service: `POST /api/v1/social/research/broadcast`.
- analytics-service: `POST /api/v1/analytics/research/track`.

## 6. Телеметрия и метрики
- Метрики: `research_contribution_total`, `tech_unlock_count`, `war_research_sync`, `research_event_engagement`.
- События: `RESEARCH_NODE_COMPLETE`, `TECH_UNLOCKED`, `RESEARCH_MEME_SHARED`.
- Dashboards: `global-research-overview`, `research-vs-war-meter`, `research-contribution-top`.

## 7. Активности и контракты

| Активность | Тип | Связь с исследованием | Проверки | Награды |
|------------|-----|-----------------------|----------|---------|
| `underlink-genesis-dive` | PvE | `Underlink Genesis` | Hacking DC 16, Insight DC 15 | `underlink-data core`, `specter-favor +5` |
| `cm-viper-upgrade` | Raid augment | `Countermesh Engineering` | Tactics DC 22, Combat contest | `helios-cred +2000`, `countermesh-core` |
| `eco-ranger-patrol` | Coop mission | `Gaia Seed Initiative` | Survival DC 18, Empathy DC 17 | `eco-biomods`, `city_unrest -5` |
| `blackwall-symphony` | Narrative event | `Blackwall Renaissance` | Willpower DC 21, Tech DC 20 | `blackwall-legacy implant`, unlock finale |

## 8. Пасхалки и медиа
- Подкаст «SolarWinds Redux» (2027), спецвыпуск о Countermesh.
- AR сериал «Ghost in the Wires Live» (каждая ветка даёт сезон).
- VR музей Ever Given 2.0, Hyperloop Karaoke 2085.
- NightHub мемы: «Anonymous 2020s возвращаются», «STONKS ZERO-G».

## 9. История изменений
- 2025-11-07 22:15 — Создана хронология глобальных исследований и технологий 2020–2093.


