# Регулярные и уникальные события лиги 2020–2093

**ID документа:** `world-seasonal-events-2020-2093`  
**Тип:** world-event-schedule  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:17  
**Приоритет:** высокий  
**Связанные документы:** `faction-wars-2020-2093.md`, `global-research-2020-2093.md`, `specter-helios-proxy-war.md`, `city-unrest-escalations.md`, `economy-specter-helios-balance.md`  
**target-domain:** world/events  
**target-мicroservices:** world-service, social-service, economy-service, gameplay-service  
**target-frontend-модули:** modules/world/events, modules/social/feeds, modules/economy/markets  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:17  
**api-readiness-notes:** Регулярный и уникальный календарь событий 2020–2093 с условиями, наградами, API и телеметрией.

---

## 1. Типы событий
- **Регулярные (цикличные)** — сезонные, ежемесячные, еженедельные события, поддерживающие экономику и активность игроков.
- **Уникальные (эпохальные)** — запускаются в конкретные годы, связаны с войнами и исследованиями.
- События влияют на `city_unrest`, `war_meter`, экономику и социальный слой (NightHub, мемы, рейтинги).

## 2. Регулярный календарь (пример)

| Частота | Название | Период | Участники | Проверки | Награды | Пасхалки |
|---------|----------|--------|-----------|----------|---------|----------|
| Еженедельно | `Neon Bazaar` | каждую пятницу | Trader NPCs, Specter | Negotiation DC 14 | `ghost-credits`, скидки | Мем «Night Market 2077» |
| Еженедельно | `Proxy War Ranked Scrims` | каждую субботу | Specter/Helios PvP | Tactics contest | War рейтинг, `war_meter` ±2 | NightHub «Ghost in the Wires Live» |
| Ежемесячно | `Underlink Maintenance Dive` | 1-е число | Netwatch, Specter | Hacking DC 16 | `underlink-data`, `specter-favor` | Отсылка к NotPetya журналы |
| Ежеквартально | `City Unrest Summit` | март/июнь/сентябрь/декабрь | City Gov, Fixers | Negotiation DC 18, Empathy DC 17 | `city.unrest -10`, `social-trust` | AR подкаст «Urban Diplomacy» |
| Сезонно | `Blackwall Harmony Festival` | весна | Specter Oracle | Willpower DC 19 | `blackwall-fragments`, романтика | Симфония Blackwall, мемы «AI Choir 2090» |
| Сезонно | `Zero-G Championship` | лето | Space Libertad, корпорации | Combat contest Zero-G | `orbital-tokens`, `helios-cred` | Hyperloop Karaoke 2085 |
| Сезонно | `Dia de los Muertos Net Parade` | осень | Valentinos, Maelstrom | Performance DC 17 | `streetwise rep`, косметика | TikTok 2075, Ever Given алтарь |
| Сезонно | `Winter Ghost Protocol` | зима | Specter, Netwatch | Insight DC 18 | `specter-prestige`, `ghost-keys` | Мем «Ghost Claus 2088» |

## 3. Уникальные события по периоду

| Годы | Название | Тип | Условия | Эффекты | Пасхалки |
|------|----------|-----|---------|---------|----------|
| 2020–2024 | `Anonymous Echo Week` | AR-хакатон | Global Net Skirmishes активны | Unlock старые hacks, `city_unrest +5` | Kevin Mitnick, Reddit WSB |
| 2025 | `Suez Redux Commemoration` | Экономика | Anniversary Ever Given 2.0 | `transport_cost -10%` на неделю | Ever Given VR музей |
| 2033 | `Helios-Indra Tribunal` | Social trial | После Helios-Indra Feud | Репутационные ветки, `countermesh` скидки | SolarWinds Redux сериал |
| 2045 | `Neo-Tokyo Uprising Day` | Narrative parade | Neo-Tokyo Data Purge завершён | `specter-prestige +20`, AR шоу | Ghost in the Wires сезон 6 |
| 2051 | `Memorial of MEME ETF Crash` | Economy | Libertad Low Orbit War финал | Контракты с «STONKS ZERO-G» | Пародийные токены |
| 2066 | `Gaia Accord Jubilee` | Diplomacy | Gaia Seed Initiative завершена | Eco buffs, `city_unrest -15` | Terraform Tears документалка |
| 2075 | `Proxy War Finale Week` | PvPvE | Night City Proxy Siege завершён | Massive raid, `war_meter reset` | NotPetya 2077 Remix |
| 2083 | `Shardfall Reunion` | Exploration | Shardfall Insurrection прошёл | Unlock stations, `ghost-tribe rep` | Boston Dynamics Choir |
| 2093 | `Blackwall Symphony Finale` | Grand finale | Blackwall Renaissance завершена | Финальный рейд, концовка | Blackwall Symphony концерт |

## 4. Модель расписания

```yaml
event-schedule:
  recurring:
    - id: neon-bazaar
      frequency: weekly
      weekday: friday
      duration: 4h
      effects:
        - economy_discount: 0.05
        - social_feed: "Night Market 2077 мемы"
    - id: proxy-war-ranked
      frequency: weekly
      weekday: saturday
      effects:
        - war_meter_delta: [-2, 2]
        - leaderboard_update: proxy-war

  seasonal:
    - id: zero-g-championship
      season: summer
      activities:
        - zero-g-tournament
        - orbital-trade-expo
      rewards:
        - helios_cred: 1500
        - orbital_token: 3

  unique:
    - id: proxy-war-finale-week
      year: 2075
      triggers:
        - war_state: "Night City Proxy Siege completed"
      effects:
        - unlock_raid: neon-uprising
        - reset_war_meter: true
```

## 5. Связи с системами
- `city_unrest` — регулярные события уменьшают или увеличивают unrest.
- `war_meter` — PvPvE и уникальные события корректируют фазу войны.
- `global_research` — некоторые события открывают исследования (Underlink Genesis, Proxy War Matrix).
- `economy` — ярмарки, мемориалы, фестивали меняют цены и доступность товаров.
- `social` — NightHub, Ghost in the Wires Live, мемы.

## 6. API для расписания
- world-service: `GET /api/v1/world/events/schedule`, `POST /api/v1/world/events/trigger`.
- economy-service: `POST /api/v1/economy/events/apply-modifier`.
- social-service: `POST /api/v1/social/events/broadcast`.
- gameplay-service: `POST /api/v1/gameplay/events/register-activity`.

## 7. Телеметрия
- Метрики: `event_participation_rate`, `event_retention`, `unique_event_completion`.
- События: `EVENT_TRIGGERED`, `EVENT_COMPLETED`, `EVENT_MEME_SHARED`.
- Dashboards: `seasonal-events-overview`, `unique-events-impact`, `event-participation-heatmap`.

## 8. Пасхалки
- NightHub: «Ghost Claus», «SolarWinds Redux», «NotPetya 2077 Remix».
- VR музей Ever Given 2.0, Hyperloop Karaoke 2085.
- AR парад Dia de los Muertos с hologram Ever Given.

## 9. История изменений
- 2025-11-07 22:17 — Создан календарь регулярных и уникальных событий лиги 2020–2093.


