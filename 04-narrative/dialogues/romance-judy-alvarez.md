# Романтические сцены — Judy Alvarez (Этапы 1-2)

**ID диалога:** `dialogue-romance-judy`  
**Тип:** romance  
**Статус:** approved  
**Версия:** 1.2.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07  
**Приоритет:** высокий  
**Связанные документы:** `../npc-lore/important/judy-alvarez.md`, `../dialogues/npc-viktor-vektor.md`, `../../02-gameplay/social/romance-system.md`, `../../02-gameplay/social/reputation-formulas.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/romance  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07  
**api-readiness-notes:** «Этапы 1-2 романса с Джуди оформлены: новые сцены, проверки, экспорт в YAML и обновлённые метрики. Готово к API задачам.»

---

## 1. Контекст и цели

- **Этап 1:** Ночная студия брейндансов Lizzie's Bar после совместной защиты Мокси.
- **Этап 2:** AR-прогулка по затопленной Laguna Bend с живым аудиомиксом от Джуди и трансляцией через social-service.
- **Цели:** Укрепить доверие, показать уязвимость Джуди, дать игроку выбор между личными чувствами и активизмом Мокси.
- **Интеграции:** `rep.romance.judy`, `flag.romance.judy.stage*`, `flag.moxx.support`, `world.event.maelstrom_underlink_raid`, `world.event.corporate_war_escalation`.

## 2. Состояния и условия

| Этап | Состояние | Описание | Триггеры | Флаги |
|------|-----------|----------|----------|-------|
| Stage1 | studio-intro | Приглашение в студию | `rep.moxx ≥ 15`, `flag.moxx.support == true` | `flag.romance.judy.stage0` |
| Stage1 | trust-share | Разговор о справедливости | После `studio-intro` | `flag.romance.judy.stage0` |
| Stage1 | bd-demo | Совместный брейнданс | После `trust-share` | `flag.romance.judy.bd` |
| Stage1 | branch-decision | Выбор пути | Завершение сцены | `flag.romance.judy.choice1` |
| Stage2 | town-entry | Подготовка к погружению | `flag.romance.judy.path_*` | `flag.romance.judy.stage1-complete` |
| Stage2 | memory-sync | Синхронизация воспоминаний | После `town-entry` | `flag.romance.judy.sync` |
| Stage2 | rooftop-epilogue | Решение после погружения | После `memory-sync` | `flag.romance.judy.choice2` |

- **Проверки:** Stage1 — Empathy, Deception, Technical; Stage2 — Empathy, Performance, Hacking, Insight.
- **Пасхалки:** Отсылки к Laguna Bend из 2020-х, мем про «Hyperloop karaoke 2072», архив BrainDance Idol.

## 3. Структура диалога

### 3.1 Этап 1 — Студия Lizzie's Bar

```
nodes:
  - id: studio-intro
    label: «Ночная студия»
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Раз уж мы спасли девчонок — у меня есть запись, которую никто не видел. Хочешь?"
      - speaker: Player
        options:
          - id: accept
            text: "Я с тобой"
            response:
              set-flag: "flag.romance.judy.stage0"
              outcomes: { default: { reputation: { romance_judy: +4 } } }
          - id: refuse
            text: "Не сейчас"
            response:
              speaker: Judy
              text: "Ладно. Но ночи такие редкие."
              outcomes: { default: { reputation: { romance_judy: -4 } } }

  - id: trust-share
    label: «Правда о справедливости»
    entry-condition: flag.romance.judy.stage0 == true
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Скажи честно: зачем ты защищаешь тех, кого никто не слушает?"
      - speaker: Player
        options:
          - id: honest
            text: "Потому что так правильно"
            response:
              trigger-check: { node: "N-3", stat: "Empathy", dc: 18, modifiers: [{ source: "item.romance-judy-tip", value: +2 }] }
              outcomes:
                success: { set-flag: "flag.romance.judy.truth", reputation: { romance_judy: +6 } }
                failure: { effect: "doubt", reputation: { romance_judy: -3 } }
          - id: deflect
            text: "Это выгодно"
            response:
              trigger-check: { node: "N-3", stat: "Deception", dc: 20 }
              outcomes:
                success: { set-flag: "flag.romance.judy.hide", reputation: { romance_judy: +2 } }
                failure: { effect: "trust_drop", reputation: { romance_judy: -6 } }

  - id: bd-demo
    label: «Совместный брейнданс»
    entry-condition: flag.romance.judy.stage0 == true
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Это старые воспоминания. Они могут задеть."
      - speaker: Player
        options:
          - id: bd-experience
            text: "Я готов"
            response:
              trigger-check: { node: "N-2", stat: "Technical", dc: 17 }
              outcomes:
                success: { set-flag: "flag.romance.judy.bd", reputation: { romance_judy: +5 } }
                failure: { effect: "motion_sickness", penalty: "stun", reputation: { romance_judy: -2 } }
          - id: bd-skip
            text: "Лучше словами"
            response:
              speaker: Judy
              text: "Слова — тоже правда."
              outcomes: { default: { reputation: { romance_judy: +3 } } }

  - id: branch-decision
    label: «Что дальше?»
    entry-condition: flag.romance.judy.stage0 == true
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Ночи меняют жизнь. Что для тебя эта ночь?"
      - speaker: Player
        options:
          - id: stay
            text: "Остаться и помочь"
            response:
              condition: { flag.romance.judy.truth: true }
              outcomes:
                default: { set-flag: "flag.romance.judy.path_trust", reputation: { romance_judy: +7 } }
          - id: comfort
            text: "Просто быть рядом"
            response:
              condition: { flag.romance.judy.bd: true }
              outcomes:
                default: { set-flag: "flag.romance.judy.path_comfort", reputation: { romance_judy: +6 } }
          - id: retreat
            text: "Работа громче чувств"
            response:
              outcomes:
                default: { set-flag: "flag.romance.judy.path_slow", reputation: { romance_judy: +3 } }
```

### 3.2 Этап 2 — Laguna Bend AR

```
nodes:
  - id: town-entry
    label: «Переезд в Laguna Bend»
    entry-condition: flag.romance.judy.path_trust or flag.romance.judy.path_comfort or flag.romance.judy.path_slow
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Я собрала AR-слой. Laguna Bend снова 2023-й, пока мы держим сигнал."
      - speaker: Player
        options:
          - id: promise-support
            text: "Я здесь, чтобы удержать тебя в настоящем"
            response:
              trigger-check: { node: "N-7", stat: "Empathy", dc: 19, modifiers: [{ source: "flag.romance.judy.path_trust", value: +1 }] }
              outcomes:
                success: { set-flag: "flag.romance.judy.stage1-complete", reputation: { romance_judy: +5 } }
                failure: { effect: "emotional_distance", reputation: { romance_judy: -4 } }
          - id: lighten-mood
            text: "А Hyperloop караоке ещё играет под водой?"
            response:
              trigger-check: { node: "N-7", stat: "Performance", dc: 17 }
              outcomes:
                success: { set-flag: "flag.romance.judy.humor", reputation: { romance_judy: +4 } }
                failure: { effect: "awkward", reputation: { romance_judy: -2 } }

  - id: memory-sync
    label: «Синхронизация воспоминаний»
    entry-condition: flag.romance.judy.stage1-complete == true
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Хочу, чтобы ты увидел лагуну моими глазами."
      - speaker: Player
        options:
          - id: dive-deep
            text: "Веди. Я держу канал"
            response:
              trigger-check: { node: "N-8", stat: "Hacking", dc: 20, modifiers: [{ source: "class.netrunner", value: +1 }, { source: "flag.romance.judy.humor", value: +1 }] }
              outcomes:
                success: { set-flag: "flag.romance.judy.sync", reputation: { romance_judy: +7 }, rewards: { buff: "sync-awareness", duration: 600 } }
                failure: { effect: "blackwall_noise", reputation: { romance_judy: -5 } }
          - id: focus-emotions
            text: "Расскажи голосом, без сети"
            response:
              trigger-check: { node: "N-8", stat: "Insight", dc: 18 }
              outcomes:
                success: { set-flag: "flag.romance.judy.sync", reputation: { romance_judy: +6 } }
                failure: { effect: "miss_connection", reputation: { romance_judy: -3 } }

  - id: rooftop-epilogue
    label: «Крыша Lizzie’s»
    entry-condition: flag.romance.judy.sync == true
    speaker-order: ["Judy", "Player"]
    dialogue:
      - speaker: Judy
        text: "Стоит ли делиться лагуной с Мокси или оставить только нам?"
      - speaker: Player
        options:
          - id: share-with-moxx
            text: "Пусть у Мокси будет надежда"
            response:
              outcomes:
                default: { set-flag: "flag.romance.judy.path_public", reputation: { romance_judy: +8 }, reputationBonus: { rep.moxx: +6 } }
          - id: keep-private
            text: "Это наш секрет"
            response:
              outcomes:
                default: { set-flag: "flag.romance.judy.path_private", reputation: { romance_judy: +7 } }
          - id: plan-future
            text: "Построим новый safehouse"
            response:
              outcomes:
                default: { set-flag: "flag.romance.judy.path_future", reputation: { romance_judy: +9 }, grant_contract: "moxx-safehouse-upgrade" }
```

### 3.3 Таблица проверок

| Этап | Узел | Тип проверки | DC | Модификаторы | Успех | Провал | Крит. успех | Крит. провал |
|------|------|--------------|----|--------------|-------|--------|-------------|--------------|
| Stage1 | trust-share.honest | Empathy | 18 | `+2` при `item.romance-judy-tip` | +6 реп., флаг truth | −3 реп. | Флаг `flag.romance.judy.deep_truth` | Доп. миссия искупления |
| Stage1 | trust-share.deflect | Deception | 20 | — | Флаг hide, +2 | −6 | Ветка «Undercover» | Кулдаун 12 ч |
| Stage1 | bd-demo.bd-experience | Technical | 17 | `+1` при классе Netrunner | +5 реп., флаг BD | −2 | Баф «clear signal» | Тошнота, блок BD |
| Stage2 | town-entry.promise-support | Empathy | 19 | `+1` при `path_trust` | Флаг stage1-complete | −4 | Автофлаг `path_public` | Досрочное окончание сцены |
| Stage2 | town-entry.lighten-mood | Performance | 17 | `+1` при `flag.romance.judy.path_comfort` | Флаг humor | −2 | Пасхалка «Hyperloop karaoke» | Потеря 2 репутации |
| Stage2 | memory-sync.dive-deep | Hacking | 20 | `+1` Netrunner, `+1` humor | Флаг sync, баф | −5 | Баф «laguna-overdrive» | Прорыв Blackwall |
| Stage2 | memory-sync.focus-emotions | Insight | 18 | `+1` при `path_slow` | Флаг sync | −3 | Сцена «Laguna sunrise» | Эмоциональный откат |

### 3.4 Реакции на события

- **`world.event.maelstrom_underlink_raid`:** +1 DC к проверкам Stage2, реплика Джуди «Maelstrom снова тестит наши границы».
- **`world.event.corporate_war_escalation`:** включает дополнительную реплику о давлении корпораций и даёт бонусные награды для выбора `plan-future`.

## 4. Экспорт (YAML)

```yaml
conversation:
  id: romance-judy-stage1
  entryNodes: [studio-intro]
  states:
    studio-intro:
      requirements:
        rep.moxx: ">=15"
        flag.moxx.support: true
    trust-share:
      requirements:
        flag.romance.judy.stage0: true
    bd-demo:
      requirements:
        flag.romance.judy.stage0: true
    branch-decision:
      requirements:
        flag.romance.judy.stage0: true
  nodes:
    studio-intro:
      options:
        - id: accept
          success:
            setFlags: [flag.romance.judy.stage0]
            reputation:
              romance_judy: 4
        - id: refuse
          success:
            reputation:
              romance_judy: -4
    trust-share:
      options:
        - id: honest
          checks:
            - stat: Empathy
              dc: 18
              modifiers:
                - source: item.romance-judy-tip
                  value: 2
          success:
            setFlags: [flag.romance.judy.truth]
            reputation:
              romance_judy: 6
          failure:
            reputation:
              romance_judy: -3
        - id: deflect
          checks:
            - stat: Deception
              dc: 20
          success:
            setFlags: [flag.romance.judy.hide]
            reputation:
              romance_judy: 2
          failure:
            reputation:
              romance_judy: -6
    bd-demo:
      options:
        - id: bd-experience
          checks:
            - stat: Technical
              dc: 17
              modifiers:
                - source: class.netrunner
                  value: 1
          success:
            setFlags: [flag.romance.judy.bd]
            reputation:
              romance_judy: 5
          failure:
            penalties: [stun]
            reputation:
              romance_judy: -2
        - id: bd-skip
          success:
            reputation:
              romance_judy: 3
    branch-decision:
      options:
        - id: stay
          conditions:
            - flag.romance.judy.truth: true
          success:
            setFlags: [flag.romance.judy.path_trust]
            reputation:
              romance_judy: 7
        - id: comfort
          conditions:
            - flag.romance.judy.bd: true
          success:
            setFlags: [flag.romance.judy.path_comfort]
            reputation:
              romance_judy: 6
        - id: retreat
          success:
            setFlags: [flag.romance.judy.path_slow]
            reputation:
              romance_judy: 3
```

```yaml
conversation:
  id: romance-judy-stage2
  entryNodes: [town-entry]
  states:
    town-entry:
      requirements:
        flag.romance.judy.path_trust: true
      fallbackRequirements:
        flag.romance.judy.path_comfort: true
      secondaryFallbackRequirements:
        flag.romance.judy.path_slow: true
    memory-sync:
      requirements:
        flag.romance.judy.stage1-complete: true
    rooftop-epilogue:
      requirements:
        flag.romance.judy.sync: true
  nodes:
    town-entry:
      options:
        - id: promise-support
          checks:
            - stat: Empathy
              dc: 19
          success:
            setFlags: [flag.romance.judy.stage1-complete]
            reputation:
              romance_judy: 5
          failure:
            reputation:
              romance_judy: -4
        - id: lighten-mood
          checks:
            - stat: Performance
              dc: 17
          success:
            setFlags: [flag.romance.judy.humor]
            reputation:
              romance_judy: 4
          failure:
            reputation:
              romance_judy: -2
    memory-sync:
      options:
        - id: dive-deep
          checks:
            - stat: Hacking
              dc: 20
          success:
            setFlags: [flag.romance.judy.sync]
            rewards:
              - buff: sync-awareness
                duration: 600
            reputation:
              romance_judy: 7
          failure:
            penalties:
              - blackwall_noise
            reputation:
              romance_judy: -5
        - id: focus-emotions
          checks:
            - stat: Insight
              dc: 18
          success:
            setFlags: [flag.romance.judy.sync]
            reputation:
              romance_judy: 6
          failure:
            reputation:
              romance_judy: -3
    rooftop-epilogue:
      options:
        - id: share-with-moxx
          success:
            setFlags: [flag.romance.judy.path_public]
            reputation:
              romance_judy: 8
            reputationBonus:
              rep.moxx: 6
        - id: keep-private
          success:
            setFlags: [flag.romance.judy.path_private]
            reputation:
              romance_judy: 7
        - id: plan-future
          success:
            setFlags: [flag.romance.judy.path_future]
            grantContract: moxx-safehouse-upgrade
            reputation:
              romance_judy: 9
```

## 5. REST / GraphQL API

| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/romance/dialogues/judy/stage1` | `GET` | Вернуть сценарий студии с активными ветками |
| `/romance/dialogues/judy/stage1/run-check` | `POST` | Прогнать проверки Empathy/Deception/Technical |
| `/romance/dialogues/judy/stage1/state` | `POST` | Сохранить флаги `stage0`, `path_*`, репутацию |
| `/romance/dialogues/judy/stage2` | `GET` | Вернуть AR-сцену Laguna Bend |
| `/romance/dialogues/judy/stage2/run-check` | `POST` | Обработать проверки Empathy/Performance/Hacking/Insight |
| `/romance/dialogues/judy/stage2/state` | `POST` | Сохранить флаги `stage1-complete`, `sync`, `path_*`, контракты |
| `/romance/dialogues/judy/telemetry` | `POST` | Сводная телеметрия по обоим этапам |

GraphQL поле `romanceDialogue(id: ID!, stage: Int)` возвращает `RomanceDialogueNode` с `romanceContext`, `stageMetrics` и активными бафами.

## 6. Валидация и телеметрия

- `scripts/validate-romance-flags.ps1` сверяет `flag.romance.judy.*`, `flag.moxx.*`, контракты и события.
- `scripts/dialogue-simulator.ps1 -Scenario romance-judy` прогоняет пути `path_trust`, `path_comfort`, `path_slow`, а также финальные варианты `path_public`, `path_private`, `path_future`.
- Метрики: `romance-judy-stage1-success-rate` (цель ≥70%), `romance-judy-stage2-sync-rate` (цель ≥60%), `romance-judy-public-vs-private` (баланс решений). Два провала Stage2 подряд → старт миссии `support-moxx-2078`.

## 7. Награды и последствия

- **Репутация:** `rep.romance.judy` до +35 за два этапа, бонус к `rep.moxx` при выборе `share-with-moxx`.
- **Бафы:** `sync-awareness`, `laguna-overdrive` (крит. успех `dive-deep`).
- **Контракты:** `moxx-safehouse-upgrade` для social-service.
- **Флаги:** `flag.romance.judy.stage0`, `flag.romance.judy.path_*`, `flag.romance.judy.stage1-complete`, `flag.romance.judy.sync`, `flag.romance.judy.path_public`, `flag.romance.judy.path_private`, `flag.romance.judy.path_future`.

## 8. Связанные материалы

- `../npc-lore/important/judy-alvarez.md`
- `../dialogues/npc-viktor-vektor.md`
- `../../02-gameplay/social/romance-system.md`
- `../../02-gameplay/social/reputation-formulas.md`
- `../../02-gameplay/world/events/world-events-2060-2077.md`

## 9. История изменений

- 2025-11-07 19:26 — Добавлен этап 2, обновлены API и метрики.
- 2025-11-07 18:32 — Расширен экспорт, REST/GraphQL блок и метрики этапа 1.
- 2025-11-07 17:13 — Создана романтическая сцена Judy (этап 1).

