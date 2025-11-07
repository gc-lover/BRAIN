# Романтическая сцена — Judy Alvarez (Этап 1)

**ID диалога:** `dialogue-romance-judy-stage1`  
**Тип:** romance  
**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 18:32  
**Приоритет:** высокий  
**Связанные документы:** `../npc-lore/important/judy-alvarez.md`, `../dialogues/npc-viktor-vektor.md`, `../../02-gameplay/social/romance-system.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/romance  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 18:32  
**api-readiness-notes:** «Сцена Judy расширена: экспорт, REST/GraphQL контракт, валидация романтических флагов и метрики. Готово к API задачам.»

---

## 1. Контекст и цели

- **Сцена:** ночь в студии брейндансов Lizzie's Bar после совместного задания по защите Мокси.
- **Цель:** укрепить эмоциональную связь через честность и уязвимость, запустить романтический путь.
- **Интеграции:** `rep.romance.judy`, `flag.romance.judy.date1`, флаги поддержки Мокси (`flag.moxx.support`), советы Виктора (`item.romance-judy-tip`).

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Флаги |
|-----------|----------|----------|-------|
| studio-intro | Приглашение в студию | `rep.moxx ≥ 15`, `flag.moxx.support == true` | `flag.romance.judy.stage0` |
| trust-share | Разговор о справедливости | После `studio-intro` | `flag.romance.judy.stage0` |
| bd-demo | Совместный брейнданс | После `trust-share` | `flag.romance.judy.bd` |
| branch-decision | Решение игрока | Завершение сцены | `flag.romance.judy.choice1` |

- **Проверки:** Empathy, Deception, Technical, Insight.
- **События:** `world.event.maelstrom_underlink_raid`, `world.event.corporate_war_escalation` меняют тему разговора и DC.

## 3. Сцена (YAML)

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
        text: "Знаешь… бывает, что ночи меняют жизнь. Что для тебя эта ночь?"
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
            text: "Нам лучше работать, чем мечтать"
            response:
              outcomes:
                default: { set-flag: "flag.romance.judy.path_slow", reputation: { romance_judy: +3 } }
```

## 4. Таблица проверок

| Узел | Тип проверки | DC | Модификаторы | Успех | Провал |
|------|--------------|----|--------------|-------|--------|
| trust-share.honest | Empathy | 18 | `+2` при `item.romance-judy-tip` | Флаг truth, +6 | −3 |
| trust-share.deflect | Deception | 20 | — | Флаг hide, +2 | −6 |
| bd-demo.bd-experience | Technical | 17 | `+1` Netrunner | +5, флаг BD | −2 |

## 5. Реакции и последствия

- **Флаги пути:** `flag.romance.judy.path_trust`, `flag.romance.judy.path_comfort`, `flag.romance.judy.path_slow` определяют ветвление следующего этапа.
- **Репутация:** `rep.romance.judy` растёт до +18 за сцену.
- **Следующая сцена:** разблокирует `romance-judy-stage2` при `rep.romance.judy ≥ 10`.
- **Провал:** две ошибки подряд → требуется миссия поддержки Мокси для восстановления доверия.

## 6. Экспорт (API)

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

## 7. REST / GraphQL API

| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/romance/dialogues/judy/stage1` | `GET` | Вернуть сцену с активными ветками и модификаторами |
| `/romance/dialogues/judy/stage1/state` | `POST` | Сохранить прогресс (`flag.romance.judy.*`, репутация, советы Виктора) |
| `/romance/dialogues/judy/stage1/run-check` | `POST` | Выполнить проверку (Empathy/Deception/Technical) |
| `/romance/dialogues/judy/stage1/telemetry` | `POST` | Отправить телеметрию выборов и распределение путей |

GraphQL-поле `romanceDialogue(id: ID!)` возвращает тип `RomanceDialogueNode` и `romanceContext` с текущими флагами, репутацией, бонусами. При `world.event.maelstrom_underlink_raid=true` API повышает DC и добавляет реплики о рейде.

---

## 8. Валидация и телеметрия

- `validate-romance-flags.ps1` сверяет `flag.romance.judy.*`, `flag.moxx.*`, советы Виктора с `romance-system.md`, `npc-viktor-vektor.md` и Moxxi-линейкой.
- `dialogue-simulator.ps1` (режим romance) прогоняет ветки `path_trust`, `path_comfort`, `path_slow`, проверяя репутацию и условия.
- Метрики: `romance-judy-success-rate` (цель ≥70%) и `romance-judy-branch-distribution` (контроль перекоса). При провалах двух проверок подряд автоматически ставится миссия поддержки Мокси.

## 9. Связанные материалы

- `../npc-lore/important/judy-alvarez.md`
- `../dialogues/npc-viktor-vektor.md`
- `../../02-gameplay/social/romance-system.md`

## 10. История изменений

- 2025-11-07 18:32 — Расширен экспорт, REST/GraphQL блок и метрики. Статус `ready`, версия 1.1.0.
- 2025-11-07 17:13 — Добавлена романтическая сцена Judy (этап 1).
# Романтическая сцена — Judy Alvarez (Этап 1)

**ID диалога:** `dialogue-romance-judy-stage1`  
**Тип:** romance  
**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 18:32  
**Приоритет:** высокий  
**Связанные документы:** `../npc-lore/important/judy-alvarez.md`, `../dialogues/npc-viktor-vektor.md`, `../../02-gameplay/social/romance-system.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/romance  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 18:32  
**api-readiness-notes:** «Сцена Judy расширена: экспорт, REST/GraphQL контракт, валидация романтических флагов и метрики. Готово к API задачам.»

---

## 1. Контекст и цели

- **Сцена:** ночь в студии брейндансов Lizzie's Bar после совместного задания по защите Мокси.
- **Цель:** установить эмоциональную связь через честность и уязвимость, запустить романтический путь.
- **Интеграции:** `rep.romance.judy`, `flag.romance.judy.date1`, флаги справедливости (`flag.moxx.support`), советы Виктора (`item.romance-judy-tip`).

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Флаги |
|-----------|----------|----------|-------|
| studio-intro | Приглашение в студию | `rep.moxx ≥ 15`, `flag.moxx.support == true` | `flag.romance.judy.stage0` |
| trust-share | Разговор о справедливости | После intro | `flag.romance.judy.stage0` |
| bd-demo | Общий просмотр брейнданса | После trust-share | `flag.romance.judy.bd` |
| branch-decision | Решение игрока | Завершение сцены | `flag.romance.judy.choice1` |

- **Проверки:** Empathy, Deception (если прятать правду), Technical (понимание BD), Insight (эмоциональное считывание).
- **События:** `world.event.maelstrom_underlink_raid`/`corporate_war_escalation` могут менять тему разговора.

## 3. Сцена (YAML)

```yaml
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
        text: "Знаешь… бывает, что ночи меняют жизнь. Что для тебя эта ночь?"
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
            text: "Нам лучше работать, чем мечтать"
            response:
              outcomes:
                default: { set-flag: "flag.romance.judy.path_slow", reputation: { romance_judy: +3 } }
```

## 4. Таблица проверок

| Узел | Тип проверки | DC | Модификаторы | Успех | Провал |
|------|--------------|----|--------------|-------|--------|
| trust-share.honest | Empathy | 18 | `+2` при `item.romance-judy-tip` | Флаг truth, +6 | −3 |
| trust-share.deflect | Deception | 20 | — | Скрытая правда, +2 | −6 |
| bd-demo.bd-experience | Technical | 17 | `+1` при классе Netrunner | +5, флаг BD | −2 |

## 5. Реакции и последствия

- **Флаги:** `path_trust`, `path_comfort`, `path_slow` определяют ветвление следующего этапа романтики.
- **Репутация:** `rep.romance.judy` растёт до +18 за сцену.
- **Следующая сцена:** разблокирует `romance-judy-stage2` при `rep.romance.judy ≥ 10`.
- **Провал:** две ошибки подряд → требуется миссия поддержки Мокси для восстановления доверия.

## 6. Экспорт (API)

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

## 7. REST / GraphQL API

| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/romance/dialogues/judy/stage1` | `GET` | Вернуть сцену с активными ветками и модификаторами |
| `/romance/dialogues/judy/stage1/state` | `POST` | Сохранить прогресс (флаги `flag.romance.judy.*`, репутация, советы Виктора) |
| `/romance/dialogues/judy/stage1/run-check` | `POST` | Выполнить проверку (Empathy/Deception/Technical) и вернуть исход |
| `/romance/dialogues/judy/stage1/telemetry` | `POST` | Отправить телеметрию выборов, отслеживать распределение путей |

GraphQL-поле `romanceDialogue(id: ID!)` возвращает тип `RomanceDialogueNode` и `romanceContext` с текущими флагами, репутацией, бонусами. При `world.event.maelstrom_underlink_raid=true` API повышает DC проверок и добавляет дополнительные реплики.

---

## 8. Валидация и телеметрия

- `validate-romance-flags.ps1` сверяет `flag.romance.judy.*`, `flag.moxx.*`, советы Виктора с `romance-system.md`, `npc-viktor-vektor.md` и Moxxi-линейкой.
- `dialogue-simulator.ps1` (режим romance) прогоняет ветки `path_trust`, `path_comfort`, `path_slow`, проверяя репутацию и условия.
- Метрики: `romance-judy-success-rate` (целевой успех ≥70%) и `romance-judy-branch-distribution` (контроль перекоса). При провалах двух проверок подряд автоматически ставится миссия поддержки Мокси.

## 9. Связанные материалы

- `../npc-lore/important/judy-alvarez.md`
- `../dialogues/npc-viktor-vektor.md`
- `../../02-gameplay/social/romance-system.md`

## 10. История изменений

- 2025-11-07 18:32 — Расширен экспорт, REST/GraphQL блок и метрики. Статус `ready`, версия 1.1.0.
- 2025-11-07 17:13 — Добавлена романтическая сцена Judy (этап 1).

