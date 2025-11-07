# Романтическая сцена — Hanako Tanaka (Этап 1)

**ID диалога:** `dialogue-romance-hanako-stage1`  
**Тип:** romance  
**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 18:20  
**Приоритет:** высокий  
**Связанные документы:** `../npc-lore/important/hanako-arasaka.md`, `../dialogues/npc-viktor-vektor.md`, `../../02-gameplay/social/romance-system.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/romance  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 18:20  
**api-readiness-notes:** «Сцена Hanako расширена: экспорт полных веток, REST/GraphQL контракт, валидация романтических флагов и бонусов. Готово для API задач.»

---

## 1. Контекст и цели

- **Сцена:** официальная встреча в приватной чайной комнате Arasaka Tower после выполнения корпоративной миссии.
- **Цель:** установить взаимное уважение, запустить «романтический трек» через выборы, проверяющие честь/лояльность/достоинство.
- **Интеграции:** `rep.romance.hanako`, `flag.romance.hanako.date1`, корпоративные флаги Arasaka, советы от Виктора Вектора (`npc-viktor-vektor`).

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Флаги |
|-----------|----------|----------|-------|
| opening | Первая встреча | `rep.corp.arasaka ≥ 20`, `flag.arasaka.clearanceA == true` | `flag.romance.hanako.stage0` |
| trust-test | Проверка уважения | `rep.romance.hanako ≥ 5` | `flag.romance.hanako.stage0` |
| etiquette | Чайная церемония | После trust-test | `flag.romance.hanako.ceremony` |
| branch-choice | Решение игрока | В конце встречи | `flag.romance.hanako.choice1` |

- **Проверки:** Persuasion (сдержанность), Insight (понимание культурных кодов), Willpower (самоконтроль).
- **События:** `world.event.corporate_war_escalation` усиливает подозрительность (повышает DC); советы Виктора (`item.romance-hanako-tip`) дают бонусы.

## 3. Сцена (YAML)

```yaml
nodes:
  - id: opening
    label: «Приветствие в чайной комнате»
    speaker-order: ["Hanako", "Player"]
    dialogue:
      - speaker: Hanako
        text: "Добро пожаловать. Эта встреча — редкость. Надеюсь, вы понимаете её значимость."
      - speaker: Player
        options:
          - id: greet-formal
            text: "Честь быть приглашённым."
            response:
              trigger-check: { node: "N-10", stat: "Persuasion", dc: 18, modifiers: [{ source: "item.romance-hanako-tip", value: +2 }] }
              outcomes:
                success: { set-flag: "flag.romance.hanako.stage0", reputation: { romance_hanako: +5 } }
                failure: { effect: "misstep", reputation: { romance_hanako: -3 } }
          - id: greet-direct
            text: "Перейдём к сути?"
            response:
              speaker: Hanako
              text: "Терпение — достоинство. Пожалуйста, соблюдайте этикет."
              outcomes: { default: { reputation: { romance_hanako: -5 } } }

  - id: trust-test
    label: «Проверка доверия»
    entry-condition: flag.romance.hanako.stage0 == true
    speaker-order: ["Hanako", "Player"]
    dialogue:
      - speaker: Hanako
        text: "Расскажите, почему вы служите Arasaka. Ваш ответ многое покажет."
      - speaker: Player
        options:
          - id: answer-duty
            text: "Честь и долг."
            response:
              trigger-check: { node: "N-3", stat: "Willpower", dc: 19 }
              outcomes:
                success: { set-flag: "flag.romance.hanako.loyal", reputation: { romance_hanako: +6 } }
                failure: { effect: "doubt", reputation: { romance_hanako: -4 } }
          - id: answer-honest
            text: "Ищу свой путь, не только корпорацию."
            response:
              trigger-check: { node: "N-3", stat: "Insight", dc: 18 }
              outcomes:
                success: { set-flag: "flag.romance.hanako.truth", reputation: { romance_hanako: +5 } }
                failure: { effect: "misunderstanding", reputation: { romance_hanako: -3 } }

  - id: ceremony
    label: «Чайная церемония»
    entry-condition: flag.romance.hanako.stage0 == true
    speaker-order: ["Hanako", "Player"]
    dialogue:
      - speaker: Hanako
        text: "Пожалуйста, следуйте моим движениям. Сосредоточьтесь."
      - speaker: Player
        options:
          - id: ceremony-follow
            text: "Следовать церемонии"
            response:
              trigger-check: { node: "N-5", stat: "Insight", dc: 17, modifiers: [{ source: "flag.viktor.loyal", value: +1 }] }
              outcomes:
                success: { set-flag: "flag.romance.hanako.ceremony", reputation: { romance_hanako: +6 } }
                failure: { effect: "spill", penalty: "minor_shame", reputation: { romance_hanako: -4 } }
          - id: ceremony-improvise
            text: "Придать личный оттенок"
            response:
              trigger-check: { node: "N-11", stat: "Persuasion", dc: 20 }
              outcomes:
                success: { effect: "impress", reputation: { romance_hanako: +7 } }
                failure: { effect: "offense", reputation: { romance_hanako: -6 } }

  - id: branch-choice
    label: «Решение встречи»
    entry-condition: flag.romance.hanako.stage0 == true
    speaker-order: ["Hanako", "Player"]
    dialogue:
      - speaker: Hanako
        text: "Ваша позиция ясна. Что вы ждёте от Arasaka и от меня?"
      - speaker: Player
        options:
          - id: choice-loyal
            text: "Служить и защищать."
            response:
              condition: { flag.romance.hanako.loyal: true }
              outcomes:
                default: { set-flag: "flag.romance.hanako.path_loyal", reputation: { romance_hanako: +8 } }
          - id: choice-equal
            text: "Партнёрство на равных."
            response:
              condition: { flag.romance.hanako.truth: true }
              outcomes:
                default: { set-flag: "flag.romance.hanako.path_equal", reputation: { romance_hanako: +8 } }
          - id: choice-retreat
            text: "Пока только уважение."
            response:
              outcomes:
                default: { set-flag: "flag.romance.hanako.path_respect", reputation: { romance_hanako: +4 } }
```

## 4. Таблица проверок

| Узел | Тип проверки | DC | Модификаторы | Успех | Провал | Крит. успех |
|------|--------------|----|--------------|-------|--------|-------------|
| opening.greet-formal | Persuasion | 18 | `+2` при `item.romance-hanako-tip` | +5 репутации | −3 репутации | — |
| trust-test.answer-duty | Willpower | 19 | `+1` при `rep.corp.arasaka ≥ 30` | Флаг лояльности | −4 репутации | — |
| trust-test.answer-honest | Insight | 18 | `+1` при `rep.romance.hanako ≥ 8` | Флаг truth | −3 репутации | — |
| ceremony.ceremony-follow | Insight | 17 | `+1` при `flag.viktor.loyal` | Церемония завершена | −4 репутации | — |
| ceremony.ceremony-improvise | Persuasion | 20 | — | Впечатление | −6 репутации | — |

## 5. Реакции и последствия

- **Флаги пути:** `flag.romance.hanako.path_loyal`, `path_equal`, `path_respect` определяют последующие сцены.
- **Репутация:** `rep.romance.hanako` растёт до +20 в зависимости от выборов.
- **Разблокировки:** при успехе доступны следующая сцена `romance-hanako-stage2`, особая ветка корпоративных квестов.
- **Проигрыш:** провал ≥2 проверок снижает доверие (`rep.romance.hanako -10`) и требует миссии искупления.

## 6. Экспорт (API)

```yaml
conversation:
  id: romance-hanako-stage1
  entryNodes: [opening]
  states:
    opening:
      requirements:
        rep.corp.arasaka: ">=20"
        flag.arasaka.clearanceA: true
    trust-test:
      requirements:
        flag.romance.hanako.stage0: true
    etiquette:
      requirements:
        flag.romance.hanako.stage0: true
    branch-choice:
      requirements:
        flag.romance.hanako.stage0: true
  nodes:
    opening:
      options:
        - id: greet-formal
          checks:
            - stat: Persuasion
              dc: 18
              modifiers:
                - source: item.romance-hanako-tip
                  value: 2
          success:
            setFlags: [flag.romance.hanako.stage0]
            reputation:
              romance_hanako: 5
          failure:
            reputation:
              romance_hanako: -3
        - id: greet-direct
          success:
            reputation:
              romance_hanako: -5
    trust-test:
      options:
        - id: answer-duty
          checks:
            - stat: Willpower
              dc: 19
              modifiers:
                - source: rep.corp.arasaka
                  value: 1
          success:
            setFlags: [flag.romance.hanako.loyal]
            reputation:
              romance_hanako: 6
          failure:
            reputation:
              romance_hanako: -4
        - id: answer-honest
          checks:
            - stat: Insight
              dc: 18
              modifiers:
                - source: rep.romance.hanako
                  value: 1
          success:
            setFlags: [flag.romance.hanako.truth]
            reputation:
              romance_hanako: 5
          failure:
            reputation:
              romance_hanako: -3
    etiquette:
      options:
        - id: ceremony-follow
          checks:
            - stat: Insight
              dc: 17
              modifiers:
                - source: flag.viktor.loyal
                  value: 1
          success:
            setFlags: [flag.romance.hanako.ceremony]
            reputation:
              romance_hanako: 6
          failure:
            penalties: [minor_shame]
            reputation:
              romance_hanako: -4
        - id: ceremony-improvise
          checks:
            - stat: Persuasion
              dc: 20
          success:
            reputation:
              romance_hanako: 7
          failure:
            reputation:
              romance_hanako: -6
    branch-choice:
      options:
        - id: choice-loyal
          conditions:
            - flag.romance.hanako.loyal: true
          success:
            setFlags: [flag.romance.hanako.path_loyal]
            reputation:
              romance_hanako: 8
        - id: choice-equal
          conditions:
            - flag.romance.hanako.truth: true
          success:
            setFlags: [flag.romance.hanako.path_equal]
            reputation:
              romance_hanako: 8
        - id: choice-retreat
          success:
            setFlags: [flag.romance.hanako.path_respect]
            reputation:
              romance_hanako: 4
```

## 7. API-интеграция

- `GET /romance/dialogues/hanako/stage1` — структура сцены.
- `POST /romance/dialogues/hanako/stage1/choice` — обработка выборов, обновление флагов.
- `POST /romance/dialogues/hanako/stage1/telemetry` — аналитика выборов.

## 8. Связанные материалы

- `../npc-lore/important/hanako-arasaka.md`
- `../dialogues/npc-viktor-vektor.md`
- `../../02-gameplay/social/romance-system.md`
- `../../02-gameplay/social/reputation-formulas.md`

## 9. История изменений

- 2025-11-07 17:12 — Создана романтическая сцена Hanako (этап 1).

