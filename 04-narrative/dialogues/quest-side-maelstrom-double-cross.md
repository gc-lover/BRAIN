# Диалоги — Side Quest «Maelstrom Double-Cross»

**ID диалога:** `dialogue-quest-side-maelstrom-double-cross`  
**Тип:** quest  
**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 19:46  
**Приоритет:** высокий  
**Связанные документы:** `../quests/side/SQ-maelstrom-double-cross.md`, `../dialogues/npc-royce.md`, `../dialogues/npc-james-iron-reed.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/quests  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 19:46  
**api-readiness-notes:** «Квест синхронизирован с фракционными сервисами, добавлены экспорт, REST/GraphQL и валидация двойной игры. Готов для API.»

---

## 1. Контекст и цели

- **Сюжет:** игрок должен провести сделку с корпоратами от лица Maelstrom, решая, предать ли банду, сыграть двойную игру или укрепить доверие Ройса.
- **Цель:** добыть чертёж имплантов и определить, кому он достанется (Maelstrom, Militech или игрок/НПД).
- **Интеграции:** репутация `rep.gang.maelstrom`, `rep.corp.militech`, флаги двуличности (`flag.maelstrom.double_agent`), события `maelstrom-underlink-raid`.

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Флаги |
|-----------|----------|----------|-------|
| briefing | Ройс поручает операцию | Начало квеста | `flag.sqmdl.briefing` |
| meet-corp | Встреча с контактами Militech | После брифинга | `flag.sqmdl.meet_corp` |
| betrayal | Решение о предательстве | Игрок принимает предложение корпораций | `flag.sqmdl.betrayal` |
| double-agent | Двойная игра | Игрок информирует Maelstrom о сделке | `flag.sqmdl.double_agent` |
| fallout | Развязка | Возврат к Ройсу/NCPD | `flag.sqmdl.fallout` |

- **Проверки:** Intimidation, Deception, Hacking, Technical, Insight.
- **События:** `world.event.corporate_war_escalation` повышает DC корпоративных сцен; `world.event.maelstrom_underlink_raid` добавляет опции для усиления банды.

## 3. Сцены и узлы

### 3.1. YAML-структура

```yaml
nodes:
  - id: briefing
    label: «Поручение Ройса»
    speaker-order: ["Royce", "Player"]
    dialogue:
      - speaker: Royce
        text: "Корпы хотят чип. Мы хотим их деньги и их головы. Ты идёшь." 
      - speaker: Player
        options:
          - id: brief-accept
            text: "Давай детали"
            response:
              trigger-check: { node: "N-2", stat: "Intimidation", dc: 17 }
              outcomes:
                success: { set-flag: "flag.sqmdl.briefing", reward: "credchip.400", reputation: { gang_maelstrom: +5 } }
                failure: { effect: "implant_surge", penalty: "hp_damage", reputation: { gang_maelstrom: -3 } }
          - id: brief-question
            text: "Что за чип?"
            response:
              speaker: Royce
              text: "Импульсный протез. Станет нашим, если не свернёшь."

  - id: meet-corp
    label: «Встреча в грузовом ангаре»
    entry-condition: flag.sqmdl.briefing == true
    speaker-order: ["Militech Broker", "Player"]
    dialogue:
      - speaker: Militech Broker
        text: "Мы заплатим двойную цену. Maelstrom не узнает."
      - speaker: Player
        options:
          - id: corp-intimidate
            text: "Вы платите тройную"
            response:
              trigger-check: { node: "N-11", stat: "Negotiation", dc: 19 }
              outcomes:
                success: { set-flag: "flag.sqmdl.meet_corp", reward: "eddies.1200", reputation: { corp_militech: +8 } }
                failure: { effect: "raise_alert", reputation: { corp_militech: -5 } }
          - id: corp-double
            text: "Я работаю и на Маэлстрём"
            response:
              speaker: Militech Broker
              text: "Тогда сделай вид, что нас не видел."
              outcomes: { default: { set-flag: "flag.sqmdl.double_agent" } }

  - id: temptation
    label: «Рассмотреть чертёж»
    condition: { flag: "flag.sqmdl.meet_corp" }
    speaker-order: ["Inner Voice", "Player"]
    dialogue:
      - speaker: Inner Voice
        text: "Продай и себе, и им. Никто не узнает."
      - speaker: Player
        options:
          - id: temp-open
            text: "Копировать данные"
            response:
              trigger-check: { node: "N-5", stat: "Hacking", dc: 20 }
              outcomes:
                success: { set-flag: "flag.sqmdl.steal", reward: "blueprint.copy", reputation: { corp_militech: +5 } }
                failure: { effect: "data_spike", penalty: "stun", reputation: { corp_militech: -6 } }
          - id: temp-resist
            text: "Не трогать"
            response:
              outcomes: { default: { reputation: { gang_maelstrom: +5 } } }

  - id: betrayal
    label: «Решение о предательстве»
    condition: { flag: "flag.sqmdl.meet_corp" }
    speaker-order: ["Player", "Royce"]
    dialogue:
      - speaker: Player
        options:
          - id: betray-corp
            text: "Сдать Militech»"
            response:
              trigger-check: { node: "N-3", stat: "Deception", dc: 21 }
              outcomes:
                success: { set-flag: "flag.sqmdl.betrayal", reputation: { gang_maelstrom: +10, corp_militech: -20 } }
                failure: { effect: "double_cross_fail", flag: "flag.sqmdl.blacklist", reputation: { gang_maelstrom: -15 } }
          - id: betray-maelstrom
            text: "Отдать чип Militech"
            response:
              trigger-check: { node: "N-3", stat: "Deception", dc: 20 }
              outcomes:
                success: { set-flag: "flag.sqmdl.corp_win", reputation: { corp_militech: +12, gang_maelstrom: -20 } }
                failure: { effect: "caught", reputation: { gang_maelstrom: -12 } }

  - id: fallout
    label: «Последствия»
    speaker-order: ["Royce", "Player", "NCPD Officer"]
    dialogue:
      - speaker: Royce
        text: "Итак, где наш чип?"
      - speaker: Player
        options:
          - id: fallout-loyal
            text: "Чип у Maelstrom"
            response:
              condition: { flag: "flag.sqmdl.betrayal" }
              outcomes:
                default: { reward: "maelstrom-ripper-chip", reputation: { gang_maelstrom: +15 }, set-flag: "flag.sqmdl.success" }
          - id: fallout-corp
            text: "Militech доволен"
            response:
              condition: { flag: "flag.sqmdl.corp_win" }
              outcomes:
                default: { reward: "eddies.2000", reputation: { corp_militech: +15, gang_maelstrom: -25 }, set-flag: "flag.sqmdl.exiled" }
          - id: fallout-double
            text: "Есть кое-что для NCPD"
            response:
              condition: { flag: "flag.sqmdl.double_agent" }
              trigger-check: { node: "N-10", stat: "Insight", dc: 20 }
              outcomes:
                success: { set-flag: "flag.sqmdl.triple", reputation: { law_ncpd: +10, gang_maelstrom: +5, corp_militech: +5 } }
                failure: { effect: "ncpd_investigation", reputation: { law_ncpd: -8 } }
```

### 3.2. Примечания

- Ветка `fallout` требует хотя бы одного флага результатов (`betrayal`, `corp_win`, `double_agent`).
- При активном `world.event.corporate_war_escalation` DC в `meet-corp` и `betrayal` увеличивается на +2.
- `flag.sqmdl.steal` открывает дополнительные опционы в последующих квестах Militech/NCPD.

## 4. Таблица проверок

| Узел | Тип проверки | DC | Модификаторы | Успех | Провал | Крит. успех | Крит. провал |
|------|--------------|----|--------------|-------|--------|-------------|--------------|
| briefing.brief-accept | Intimidation | 17 | `+1` при `flag.maelstrom.implant_sync` | Принятие задания, +5 репутация | Урон от импланта | — | — |
| meet-corp.corp-intimidate | Negotiation | 19 | `+2` при `flag.maelstrom.double_agent` | Бонус деньги, +8 к Милитеху | Подозрение | — | — |
| temptation.temp-open | Hacking | 20 | `+2` Netrunner | Копия чертежа | Оглушение | — | — |
| betrayal.betray-corp | Deception | 21 | `+1` при `rep.gang.maelstrom ≥ 40` | Лояльность Maelstrom | Blacklist | — | — |
| betrayal.betray-maelstrom | Deception | 20 | `+2` при `flag.marco.corp` | Победа Militech | Пойман | — | — |
| fallout.fallout-double | Insight | 20 | `+1` при `flag.sqmdl.steal` | Тройной агент | Расследование NCPD | — | — |

---

## 5. Экспорт данных

```yaml
conversation:
  id: dialogue-quest-side-maelstrom-double-cross
  entryNodes: [briefing]
  states:
    briefing:
      requirements:
        quest.side.maelstrom.double: "started"
    meet-corp:
      requirements:
        flag.sqmdl.briefing: true
    temptation:
      requirements:
        flag.sqmdl.meet_corp: true
    betrayal:
      requirements:
        flag.sqmdl.meet_corp: true
    fallout:
      requirements:
        anyOf:
          - { flag.sqmdl.betrayal: true }
          - { flag.sqmdl.corp_win: true }
          - { flag.sqmdl.double_agent: true }
  nodes:
    briefing:
      options:
        - id: brief-accept
          checks:
            - stat: Intimidation
              dc: 17
          success:
            setFlags: [flag.sqmdl.briefing]
            rewards: [credchip.400]
            reputation:
              rep.gang.maelstrom: 5
          failure:
            penalties: [hp_damage]
            reputation:
              rep.gang.maelstrom: -3
    meet-corp:
      options:
        - id: corp-intimidate
          checks:
            - stat: Negotiation
              dc: 19
          success:
            setFlags: [flag.sqmdl.meet_corp]
            rewards: [eddies.1200]
            reputation:
              rep.corp.militech: 8
          failure:
            reputation:
              rep.corp.militech: -5
        - id: corp-double
          success:
            setFlags: [flag.sqmdl.double_agent]
    temptation:
      options:
        - id: temp-open
          checks:
            - stat: Hacking
              dc: 20
          success:
            setFlags: [flag.sqmdl.steal]
            rewards: [blueprint.copy]
            reputation:
              rep.corp.militech: 5
          failure:
            penalties: [stun]
            reputation:
              rep.corp.militech: -6
        - id: temp-resist
          success:
            reputation:
              rep.gang.maelstrom: 5
    betrayal:
      options:
        - id: betray-corp
          checks:
            - stat: Deception
              dc: 21
          success:
            setFlags: [flag.sqmdl.betrayal]
            reputation:
              rep.gang.maelstrom: 10
              rep.corp.militech: -20
          failure:
            setFlags: [flag.sqmdl.blacklist]
            reputation:
              rep.gang.maelstrom: -15
        - id: betray-maelstrom
          checks:
            - stat: Deception
              dc: 20
          success:
            setFlags: [flag.sqmdl.corp_win]
            reputation:
              rep.corp.militech: 12
              rep.gang.maelstrom: -20
          failure:
            reputation:
              rep.gang.maelstrom: -12
    fallout:
      options:
        - id: fallout-loyal
          conditions:
            - flag.sqmdl.betrayal: true
          success:
            setFlags: [flag.sqmdl.success]
            rewards: [maelstrom-ripper-chip]
            reputation:
              rep.gang.maelstrom: 15
        - id: fallout-corp
          conditions:
            - flag.sqmdl.corp_win: true
          success:
            setFlags: [flag.sqmdl.exiled]
            rewards: [eddies.2000]
            reputation:
              rep.corp.militech: 15
              rep.gang.maelstrom: -25
        - id: fallout-double
          conditions:
            - flag.sqmdl.double_agent: true
          checks:
            - stat: Insight
              dc: 20
          success:
            setFlags: [flag.sqmdl.triple]
            reputation:
              rep.law.ncpd: 10
              rep.gang.maelstrom: 5
              rep.corp.militech: 5
          failure:
            triggers: [ncpd.investigation]
            reputation:
              rep.law.ncpd: -8
```

> Экспорт генерируется `scripts/export-dialogues.ps1` в `api/v1/narrative/dialogues/quest-side-maelstrom-double-cross.yaml`.

---

## 6. REST / GraphQL API

| Endpoint | Метод | Назначение |
| --- | --- | --- |
| `/narrative/dialogues/quest-side-maelstrom-double-cross` | `GET` | Получить ветки лояльности/предательства и активные проверки |
| `/narrative/dialogues/quest-side-maelstrom-double-cross/state` | `POST` | Сохранить флаги (`flag.sqmdl.*`), выданные награды, репутации |
| `/narrative/dialogues/quest-side-maelstrom-double-cross/run-check` | `POST` | Выполнить проверку (Intimidation/Negotiation/Hacking/Deception/Insight) |
| `/narrative/dialogues/quest-side-maelstrom-double-cross/telemetry` | `POST` | Передать телеметрию решений (loyal/corp/double/triple) |

GraphQL-поле `questDialogue(id: ID!)` возвращает `QuestDialogueNode` c `maelstromContext` (reputation, blacklist, double-agent) и подсказывает последующие миссии по выбранному пути.

---

## 7. Валидация и телеметрия

- `validate-maelstrom-double.ps1` сверяет флаги `flag.sqmdl.*`, репутацию и контракты с `npc-royce.md`, `npc-james-iron-reed.md` и social-сервисом.
- `dialogue-simulator.ps1` прогоняет сценарии лояльности, корпораций и тройного агента, сравнивая ожидания по наградам и штрафам.
- Метрики: `maelstrom-loyalty-rate`, `militech-deal-rate`, `maelstrom-triple-agent-rate`, `maelstrom-blacklist-rate`. При росте blacklist >20% создаётся тикет на балансировку Maelstrom.

---

## 8. Реакции и последствия

- **Maelstrom Loyalty:** `flag.sqmdl.success` → `rep.gang.maelstrom +15`, доступ к `maelstrom-underlink-raid`.
- **Militech Deal:** `flag.sqmdl.corp_win` → `rep.corp.militech +15`, Maelstrom blacklist.
- **Triple Agent:** `flag.sqmdl.triple` открывает цепочки NCPD и Militech, сохраняя канал с Maelstrom.
- **Санкции:** `flag.sqmdl.exiled` блокирует Maelstrom-квесты до прохождения искупительной миссии.

## 9. Связанные материалы

- `../quests/side/SQ-maelstrom-double-cross.md`
- `../dialogues/npc-royce.md`
- `../dialogues/npc-james-iron-reed.md`
- `../../02-gameplay/social/reputation-formulas.md`
- `../../02-gameplay/world/events/world-events-framework.md`

## 10. История изменений

- 2025-11-07 19:46 — Добавлены экспорт, REST/GraphQL и метрики. Статус `ready`, версия 1.1.0.
- 2025-11-07 17:04 — Добавлены диалоги квеста «Maelstrom Double-Cross» с ветвями лояльности, корпоратов и тройного агента.

