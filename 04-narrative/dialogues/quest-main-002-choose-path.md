# Диалоги — Квест 1.2 «Выбор пути»

**ID диалога:** `dialogue-quest-main-002-choose-path`  
**Тип:** quest  
**Статус:** draft  
**Версия:** 0.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 16:42  
**Приоритет:** высокий  
**Связанные документы:** `../quests/main/002-choose-path-dnd-nodes.md`, `../dialogues/npc-hiroshi-tanaka.md`, `../dialogues/npc-jose-tiger-ramirez.md`, `../dialogues/npc-sara-miller.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/quests  
**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-07 16:42  
**api-readiness-notes:** Проверить синхронизацию репутационных модификаторов и доступов фракций.

---

## 1. Контекст и цели

- **Сцена:** игрок выбирает направление развития: корпорации, бандитские улицы или независимый путь.
- **Цель:** через диалоговые сцены с ключевыми NPC закрепить выбор и активировать соответствующие ветки.
- **Участники:** Марко Санчес (модератор), Хироши Танака (Arasaka), Хосе «Тигр» Рамирес (Valentinos), Сара Миллер (NCPD, независимый гарант), а также представители независимых (диспетчер Nomad Convoy по коммлинку).

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Флаги |
|-----------|----------|----------|-------|
| council-setup | Предварительный круглый стол у Марко | Начало квеста | `flag.main002.council` |
| corp-track | Переговоры с Хироши | Игрок выбирает корпорацию | `flag.main002.corp` |
| gang-track | Встреча с Хосе | Игрок выбирает улицы | `flag.main002.gang` |
| law-track | Проверка с Сарой (для независимых и NCPD) | Игрок выбирает закон/независимость | `flag.main002.law` |
| freelance-brief | Коммлинк с Nomad диспетчером | Игрок подтверждает независимость | `flag.main002.freelance` |

- **Проверки:** Узлы N-10, N-11, N-12 из `002-choose-path-dnd-nodes.md`.
- **Репутация:** `rep.corp.arasaka`, `rep.gang.valentinos`, `rep.law.ncpd`, `rep.freelance.global`.

## 3. Сцены и узлы

### 3.1. YAML-структура

```
nodes:
  - id: council
    label: «Стол Марко»
    speaker-order: ["Marco", "Player"]
    dialogue:
      - speaker: Marco
        text: "Ты сделал первые шаги. Теперь решай, кто ты в Night City."
      - speaker: Player
        options:
          - id: choose-corp
            text: "Хочу в корпорацию"
            response:
              speaker: Marco
              text: "Тогда пройдёмся в Arasaka Tower."
              set-flag: "flag.main002.corp"
          - id: choose-gang
            text: "Иду к Валентинос"
            response:
              speaker: Marco
              text: "Тигр ждёт в Heywood."
              set-flag: "flag.main002.gang"
          - id: choose-law
            text: "Мне нужен официальный статус"
            response:
              speaker: Marco
              text: "NCPD ищет людей с совестью."
              set-flag: "flag.main002.law"
          - id: choose-freelance
            text: "Я останусь независимым"
            response:
              speaker: Marco
              text: "Свобода — тяжёлый путь. Nomad диспетчер на линии."
              set-flag: "flag.main002.freelance"

  - id: corp-track
    condition: { flag: "flag.main002.corp" }
    label: «Переговоры с Arasaka»
    speaker-order: ["Hiroshi", "Player"]
    dialogue:
      - speaker: Hiroshi
        text: "Arasaka приветствует амбициозных. Давайте к делу."
      - speaker: Player
        options:
          - id: corp-persuade
            text: "Я приносил результаты."
            response:
              system-check: { node: "N-10", stat: "Persuasion", dc: 18, modifiers: [{ source: "credential.corporate", value: +2 }] }
              success-line: "Ваш профиль впечатляет. Clearance A одобрен."
              failure-line: "Ваши данные недостаточны."
              critical-success-line: "Совет назначил вас на пилотный проект."
              critical-failure-line: "Вы внесены в список наблюдения."
              outcomes:
                success: { set-flag: "flag.arasaka.clearanceA", reputation: { corp: +10 } }
                failure: { grant: "contract.corp-basic", reputation: { corp: +2 } }
                critical-success: { grant: "contract.arasaka-serenity", reputation: { corp: +14 } }
                critical-failure: { set-flag: "flag.arasaka.watchlist", reputation: { corp: -8 } }
          - id: corp-ask
            text: "Что ожидает меня?"
            response:
              speaker: Hiroshi
              text: "Ожидаем результат, дисциплину и ноль компромиссов."

  - id: gang-track
    condition: { flag: "flag.main002.gang" }
    label: «Клятва Valentinos»
    speaker-order: ["Jose", "Player"]
    dialogue:
      - speaker: Jose
        text: "Семья прежде всего. Докажи свою честь."
      - speaker: Player
        options:
          - id: gang-intimidate
            text: "Я уже пролил кровь за улицы."
            response:
              system-check: { node: "N-11", stat: "Intimidation", dc: 17, modifiers: [{ source: "tattoo.valentinos", value: +1 }] }
              success-line: "Понимаю. Ты свой."
              failure-line: "Слова дешевы."
              critical-success-line: "Семья принимает тебя без вопросов."
              critical-failure-line: "Ты привёл с собой хвост?"
              outcomes:
                success: { set-flag: "flag.valentinos.oath", reputation: { gang: +10 } }
                failure: { grant: "contract.valentinos-trial", reputation: { gang: +3 } }
                critical-success: { grant: "item.valentinos-medallion", reputation: { gang: +14 } }
                critical-failure: { set-flag: "flag.valentinos.suspect", reputation: { gang: -8 } }
          - id: gang-family
            text: "Я ищу семью, не прибыль."
            response:
              speaker: Jose
              text: "Тогда семья даст тебе имя, но помни — предателей у нас нет."

  - id: law-track
    condition: { flag: "flag.main002.law" }
    label: «Комиссия NCPD»
    speaker-order: ["Sara", "Player"]
    dialogue:
      - speaker: Sara
        text: "NCPD принимает тех, кто держит слово."
      - speaker: Player
        options:
          - id: law-honesty
            text: "Я хочу защищать город."
            response:
              system-check: { node: "N-10", stat: "Persuasion", dc: 18 }
              success-line: "Добро пожаловать. Badge к выдаче."
              failure-line: "Ваши мотивы туманны."
              critical-success-line: "Вы сразу получаете ускоренное расследование."
              critical-failure-line: "Мы фиксируем несостыковки."
              outcomes:
                success: { set-flag: "flag.ncpd.badge", reputation: { law: +10 } }
                failure: { grant: "contract.ncpd-patrol", reputation: { law: +3 } }
                critical-success: { grant: "contract.ncpd-cybercrime-taskforce", reputation: { law: +14 } }
                critical-failure: { set-flag: "flag.ncpd.review", reputation: { law: -6 } }
          - id: law-ask
            text: "Каковы правила?"
            response:
              speaker: Sara
              text: "Правила просты: отчёты вовремя, сила — только по протоколу."

  - id: freelance-track
    condition: { flag: "flag.main002.freelance" }
    label: «Связь с Nomad Convoy»
    speaker-order: ["Nomad Dispatcher", "Player"]
    dialogue:
      - speaker: Nomad Dispatcher
        text: "Говорит Convoy 77. Ищешь свободу — держись дороги."
      - speaker: Player
        options:
          - id: freelance-commit
            text: "Мне не нужны цепи"
            response:
              system-check: { node: "N-12", stat: "ClassChoice", dc: 0, class-bonus: { netrunner: +2, techie: +2 } }
              success-line: "Тогда получай маршрут и частоты."
              failure-line: "Без сертификации не выпустим."
              outcomes:
                success: { set-flag: "flag.freelance.contract", reputation: { freelance: +8 } }
                failure: { grant: "contract.freelance-training", reputation: { freelance: +2 } }
          - id: freelance-ask
            text: "Какие риски?"
            response:
              speaker: Nomad Dispatcher
              text: "Риски — всё. Но дорога помнит своих."

  - id: wrap
    label: «Итог совета»
    speaker-order: ["Marco", "Player"]
    dialogue:
      - speaker: Marco
        text: "Решение принято. Теперь живи с ним, чомбата."
      - speaker: Player
        options:
          - id: wrap-affirm
            text: "Я готов"
            response:
              speaker: Marco
              text: "Добро пожаловать в новую жизнь."
              outcomes: { finalize: "main002", update-world: true }
```

### 3.2. Логика переходов

- Активируется только одна основная ветка (corp/gang/law/freelance) согласно выбору.
- После завершения выбранной ветки устанавливается соответствующий флаг и квест завершает сценой `wrap`.
- Репутационные изменения передаются в системы социального сервиса.

## 4. Награды и последствия

- **Репутация:** +10 к выбранной фракции (убывает у конкурирующих: Arasaka vs Militech, Valentinos vs NCPD). Независимый путь увеличивает `rep.freelance.global` и слегка снижает `rep.corp.arasaka` и `rep.gang.valentinos`.
- **Предметы:** Зависит от ветки (корпоративный пропуск, медальон Valentinos, значок NCPD, маршруты Nomad).
- **Флаги:** `flag.main002.corp|gang|law|freelance`, плюс ветвевые флаги (`flag.arasaka.clearanceA`, `flag.valentinos.oath`, `flag.ncpd.badge`, `flag.freelance.contract`).
- **World-state:** Активируются соответствующие квестовые цепочки (`arasaka-world-quests`, `heywood-valentinos-chain`, `ncpd-patrol-chain`, `freelance-network`).

## 5. Связанные материалы

- `../quests/main/002-choose-path-dnd-nodes.md`
- `../dialogues/npc-hiroshi-tanaka.md`
- `../dialogues/npc-jose-tiger-ramirez.md`
- `../dialogues/npc-sara-miller.md`
- `../../02-gameplay/social/reputation-formulas.md`

## 6. История изменений

- 2025-11-07 16:42 — добавлен диалоговый сценарий для квеста 1.2.

