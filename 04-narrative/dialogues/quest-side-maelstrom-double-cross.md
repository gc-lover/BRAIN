# Диалоги — Side Quest «Maelstrom Double-Cross»

**ID диалога:** `dialogue-quest-side-maelstrom-double-cross`  
**Тип:** quest  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 17:04  
**Приоритет:** высокий  
**Связанные документы:** `../quests/side/SQ-maelstrom-double-cross.md`, `../dialogues/npc-royce.md`, `../dialogues/npc-james-iron-reed.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/quests  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 17:04  
**api-readiness-notes:** Сцены квеста фиксируют варианты лояльности Maelstrom, двойную игру и сотрудничество с Militech/NCPD.

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

## 5. Реакции и последствия

- **Maelstrom Loyalty:** `flag.sqmdl.success` → `rep.gang.maelstrom +15`, доступ к рейду `maelstrom-underlink-raid`.
- **Militech Deal:** `flag.sqmdl.corp_win` → `rep.corp.militech +15`, Maelstrom blacklist.
- **Triple Agent:** `flag.sqmdl.triple` открывает цепочки NCPD и Militech, удерживая доступ к Maelstrom через скрытый канал.
- **Санкции:** `flag.sqmdl.exiled` блокирует Maelstrom квесты до выполнения особого задания искупления.

## 6. Связанные материалы

- `../quests/side/SQ-maelstrom-double-cross.md`
- `../dialogues/npc-royce.md`
- `../dialogues/npc-james-iron-reed.md`
- `../../02-gameplay/social/reputation-formulas.md`
- `../../02-gameplay/world/events/world-events-framework.md`

## 7. История изменений

- 2025-11-07 17:04 — Добавлены диалоги квеста «Maelstrom Double-Cross» с ветвями лояльности, корпоратов и тройного агента.

