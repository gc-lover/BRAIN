# Диалоги — Квест 1.1 «Первые шаги»

**ID диалога:** `dialogue-quest-main-001-first-steps`  
**Тип:** quest  
**Статус:** draft  
**Версия:** 0.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 16:42  
**Приоритет:** высокий  
**Связанные документы:** `../quests/main/001-first-steps-dnd-nodes.md`, `../dialogues/npc-marco-fix-sanchez.md`, `../npc-lore/important/marco-fix-sanchez.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/quests  
**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-07 16:42  
**api-readiness-notes:** Требуется синхронизация с обучающими подсказками и логом бросков.

---

## 1. Контекст и цели

- **Сцена:** игрок прибывает в Watson и проходит обучение с Марко Санчесом.
- **Цель:** познакомить игрока с базовыми механиками (Perception, Parkour, Social, Stealth, Tech) и задать тон миру.
- **Участники:** Игрок, Марко Санчес, охранный дрон, торговец Джейк Арчер (камео), учебный патруль NCPD.

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Флаги |
|-----------|----------|----------|-------|
| arrival | Вступительное взаимодействие с Марко | Начало квеста | `flag.main001.arrival` |
| market-run | Обучение паркуру и восприятию | После сцены arrival | `flag.main001.market_run` |
| fixer-brief | Социальная проверка у Марко | После market-run | `flag.main001.fixer_brief` |
| stealth-route | Опциональная стелс-сцена | Игрок согласился попробовать скрытность | `flag.main001.stealth` |
| tech-door | Вскрытие двери и завершение | После общения с торговцем | `flag.main001.tech_door` |

- **Проверки:** Используются узлы N-1…N-5 из `001-first-steps-dnd-nodes.md`.
- **Репутация:** базовое влияние на `rep.fixers.marco` и `rep.law.ncpd`.

## 3. Сцены и узлы диалога

### 3.1. YAML-структура сцен

```
nodes:
  - id: arrival
    label: «Час города»
    speaker-order: ["Marco", "Player"]
    dialogue:
      - speaker: Marco
        text: "Привет, чомбата. Здесь Watson. Если хочешь дожить до рассвета — смотри и слушай."
      - speaker: Player
        options:
          - id: arrival-curious
            text: "Что здесь происходит?"
            response:
              speaker: Marco
              text: "Город кипит. Корпы толкают сталь, банды нюхают кровь. Сначала — глаза."
              trigger-check: { node: "N-1", stat: "Perception", dc: 10 }
              outcomes:
                success: { set-flag: "flag.main001.target_marked", reward: "xp.micro" }
                failure: { log: "Player misses hidden stash" }
                critical-success: { reward: "loot.cache01" }
                critical-failure: { debuff: "perception_noise", duration: 120 }
          - id: arrival-ready
            text: "Готов учиться."
            response:
              speaker: Marco
              text: "Тогда беги за мной. Прыгай, слушай, не умирай."
              set-flag: "flag.main001.market_run"

  - id: market-run
    label: «Паркур через баррикаду»
    speaker-order: ["Marco", "Player"]
    dialogue:
      - speaker: Marco
        text: "Баррикада впереди. Используй импланты, если есть."
      - speaker: Player
        options:
          - id: parkour-commit
            text: "Прыгаю"
            response:
              system-check: { node: "N-2", stat: "Parkour", dc: 10 }
              success-line: "Ты перепрыгиваешь и ловишь баланс, чувствуешь поток города."
              failure-line: "Сбиваешь колено, но Марко вытягивает."
              critical-success-line: "Делаешь кувырок и ловишь взгляд толпы: «Legend in the making»."
              critical-failure-line: "Падаешь в мусор, получаешь легкий урон." 
              set-flag: "flag.main001.parkour_done"
          - id: parkour-skip
            text: "Ищу обход"
            response:
              speaker: Marco
              text: "Нет обходов. Только вперёд."
              outcomes: { repeat: true }

  - id: fixer-brief
    label: «Первый контракт»
    speaker-order: ["Marco", "Player"]
    dialogue:
      - speaker: Marco
        text: "Слушай, у каждого новичка есть выбор. Хочешь быстрые креды — разговаривай честно."
      - speaker: Player
        options:
          - id: talk-job
            text: "Какие варианты?"
            response:
              speaker: Marco
              text: "Есть магазинчик, нужен курьер. Скидка, если понравишься." 
              trigger-check: { node: "N-3", stat: "Communication", dc: 10 }
              outcomes:
                success: { grant: "discount.2", reputation: { fixer: +5 } }
                failure: { note: "No discount" }
                critical-success: { grant: "poi.hidden-cache", reputation: { fixer: +7 } }
                critical-failure: { reputation: { fixer: -3 } }
          - id: talk-self
            text: "Расскажи о себе"
            response:
              speaker: Marco
              text: "Фиксер, связываю людей. Твоя задача — не облажаться."

  - id: stealth-route
    label: «Тень рынка»
    condition: { flag: "flag.main001.stealth" }
    speaker-order: ["Marco", "Player", "NCPD Drone"]
    dialogue:
      - speaker: Marco
        text: "Хочешь сократить путь? Будь тенью."
      - speaker: Player
        options:
          - id: stealth-accept
            text: "Пробую"
            response:
              system-check: { node: "N-4", stat: "Stealth", dc: 10 }
              success-line: "Ты проскальзываешь мимо дрона, тот даже не моргнул."
              failure-line: "Дрон замечает движение и подсвечивает тебя."
              critical-failure-line: "Учебный патруль включает сирену, но Марко быстро гасит ситуацию."
              outcomes:
                success: { set-flag: "flag.main001.stealth_clear", reputation: { fixer: +3 } }
                failure: { spawn: "ncpd.patrol", reputation: { law: -1 } }

  - id: tech-door
    label: «Вскрытие и финал»
    speaker-order: ["Jake", "Player", "Marco"]
    dialogue:
      - speaker: Jake
        text: "Эй, новичок! Нужно открыть эту дверь. Срочная поставка."
      - speaker: Player
        options:
          - id: tech-attempt
            text: "Попробую вскрыть"
            response:
              system-check: { node: "N-5", stat: "Tech", dc: 12, timer: 30 }
              success-line: "Контакты щёлкают, дверь открывается, Джейк кивает."
              failure-line: "Контакты искрят, один предохранитель сгорает."
              critical-failure-line: "Система поднимает учебную тревогу."
              outcomes:
                success: { reward: "loot.micro", reputation: { fixer: +5, law: +2 } }
                failure: { consume: "battery-pack", reputation: { fixer: -1 } }
                critical-failure: { trigger: "ncpd.training-alert", debuff: "lockpick_cooldown" }
          - id: tech-decline
            text: "Это не моё"
            response:
              speaker: Marco
              text: "Учись, чомбата. Следующий контракт не подождёт."

  - id: wrap-up
    label: «Новый путь»
    speaker-order: ["Marco", "Player"]
    dialogue:
      - speaker: Marco
        text: "Неплохо для свежей крови. Завтра поговорим о настоящей работе."
      - speaker: Player
        options:
          - id: wrap-corp
            text: "Хочу в корпорации"
            response:
              speaker: Marco
              text: "Тогда готовь костюм. Познакомлю с Хироши, если выдержишь."
              set-flag: "flag.main001.choice_corp"
          - id: wrap-gang
            text: "Улицы зовут"
            response:
              speaker: Marco
              text: "Тогда отправлю тебя к Тигру. Не опозорь меня."
              set-flag: "flag.main001.choice_gang"
          - id: wrap-freelance
            text: "Останусь свободным"
            response:
              speaker: Marco
              text: "Свобода стоит дорого. Но ты уже сделал первый шаг."
              set-flag: "flag.main001.choice_free"
```

### 3.2. Примечания к сценам

- Узлы `arrival`, `market-run`, `fixer-brief`, `tech-door` обязательны.
- `stealth-route` активируется, если игрок выбрал вариант «Будь тенью» в сцене `market-run`.
- `wrap-up` передаёт выбор в квест 1.2 through флаги `choice_*`.

## 4. Награды и последствия

- **Репутация:** `rep.fixers.marco +5`, `rep.law.ncpd +2` при успешном взломе; штрафы при провале стелса.
- **Предметы:** Малый лут `loot.micro`, скидка торговца (при успехе N-3).
- **Флаги:** `flag.main001.choice_corp|gang|free`, `flag.main001.stealth_clear`, `flag.main001.target_marked`.
- **World-state:** Подготавливает ветки `main/002-choose-path` и фракционные цепочки.

## 5. Связанные материалы

- `../quests/main/001-first-steps-dnd-nodes.md`
- `../dialogues/npc-marco-fix-sanchez.md`
- `../npc-lore/important/marco-fix-sanchez.md`
- `../../02-gameplay/combat/combat-dnd-core.md`

## 6. История изменений

- 2025-11-07 16:42 — добавлен диалоговый сценарий для квеста 1.1.

