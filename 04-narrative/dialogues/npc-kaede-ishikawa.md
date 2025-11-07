# Диалог — Каэдэ Исикава

**ID диалога:** `dialogue-npc-kaede-ishikawa`  
**Тип:** npc  
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-08  
**Последнее обновление:** 2025-11-08 00:25  
**Приоритет:** высокий  
**Связанные документы:** `../npc-lore/important/npc-kaede-ishikawa.md`, `../quests/raid/2025-11-07-quest-helios-countermesh-conspiracy.md`, `../../02-gameplay/world/specter-hq.md`, `../../02-gameplay/world/helios-countermesh-ops.md`  
**target-domain:** narrative  
**target-мicroservice:** narrative-service  
**target-frontend-module:** modules/narrative/raids  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-08 00:25  
**api-readiness-notes:** Диалог Kaede Ishikawa с ветками Specter/Helios готов к API постановке.

---

## 1. Контекст
- Каэдэ выступает посредником между Specter и Helios, реагирует на выбор игрока.
- Состояния зависят от `flag.kaede.loyalty` и результата квеста Helios Conspiracy.

## 2. Состояния и условия

| State | Описание | Условия |
|-------|----------|---------|
| `neutral` | Каэдэ осторожна, скрывает истинную лояльность | Базовое состояние |
| `specter` | Поддерживает Specter, раскрывает планы Helios | `flag.kaede.loyalty == specter` |
| `helios` | Продвигает Helios, требует доказательства двойной игры | `flag.kaede.loyalty == helios` |
| `balanced` | Исследует путь баланса | `flag.kaede.loyalty == balanced` |
| `family_crisis` | Просит вывести её семью из зоны риска | `flag.kaede.family-threatened == true` |

## 3. Диалоговые узлы (YAML)
```yaml
- state: neutral
  greetings:
    - "Баланс — это иллюзия. Но без него всё сгорит."
  options:
    - id: ask-loyalty
      text: "Кому ты служишь, Каэдэ?"
      response:
        text: "Сегодня Specter нужны мои данные. Завтра — Helios." 
        effect:
          - reveal_state: "balanced"
    - id: request-intel
      text: "Мне нужен доступ к Countermesh логам"
      requirements:
        - stat_check: { stat: Hacking, dc: 18 }
      on_success:
        response:
          text: "Здесь ключи. Не дай Lysander увидеть."
          effect:
            - add_item: "countermesh-log"
            - set_flag: flag.kaede.loyalty = specter
      on_failure:
        response:
          text: "Ты не готов."
          effect:
            - add_city_unrest: 3

- state: specter
  greetings:
    - "Specter держит город. Я помогу удержать Underlink."
  options:
    - id: trigger-contract
      text: "Запусти intel-contract"
      response:
        text: "Принято. Contract Board получит обновление."
        effect:
          - trigger_event: SPECTER_INTEL_CONTRACT

- state: helios
  greetings:
    - "Helios знает, что ты здесь. Покажи, что не предашь."
  options:
    - id: prove-helios
      text: "Как доказать лояльность?"
      response:
        text: "Выполни CM-Viper. Тогда я открою доступ."
        effect:
          - set_flag: flag.kaede.prove_helios

- state: balanced
  greetings:
    - "Specter и Helios ведут войну, а дети внизу тонут."
  options:
    - id: propose-balance
      text: "Предложить совместную операцию"
      on_select:
        response:
          text: "Смешанная миссия. Рискованно, но возможно."
          effect:
            - trigger_event: BALANCED_CONTRACT_AVAILABLE

- state: family_crisis
  greetings:
    - "Мой брат в Underlink. Helios закрыл шлюзы. Помощь нужна сейчас."
  options:
    - id: accept-rescue
      text: "Specter помогут"
      response:
        text: "Я в долгу. Передам Kaori твой вызов."
        effect:
          - trigger_event: FAMILY_RESCUE_MISSION
          - add_rep: { rep.fixers.neon: +3 }
    - id: refuse-help
      text: "Это твоё дело"
      response:
        text: "Тогда ты такой же, как Lysander."
        effect:
          - set_flag: flag.kaede.betrayal = true
          - add_rep: { rep.corp.helios: +2 }
```

## 4. Таблица проверок D&D

| Узел | Проверка | DC | Условие | Успех | Провал |
|------|----------|----|---------|-------|--------|
| `request-intel` | Hacking | 18 | `ghost-drone` активен (+1) | Получить `countermesh-log`, Kaede склоняется к Specter | +3 к unrest |
| `prove-helios` | Persuasion | 20 | `rep.corp.helios ≥ 20` (+2) | Kaede откроет Helios контракт | Каэде сомневается, `loyalty` остаётся neutral |
| `propose-balance` | Insight | 19 | `specter-prestige ≥ 150` (+1) | Balanced контракт активен | Контракт отклонён |
| `family_crisis` | Leadership | 21 | `rep.city.gov ≥ 30` (+1) | unlock rescue mission | Семья погибает, unrest +10 |

## 5. API и события
- narrative-service: `POST /api/v1/narrative/dialogues/kaede/start`, `PATCH /api/v1/narrative/dialogues/kaede/state`.
- Events: `SPECTER_INTEL_CONTRACT`, `BALANCED_CONTRACT_AVAILABLE`, `FAMILY_RESCUE_MISSION`, `NPC_KAEDE_LoyaltyChanged`.
- Telemetry: `kaede_dialogue_choice`, `kaede_loyalty_shift`.

## 6. История изменений
- 2025-11-08 00:25 — Создан диалог Kaede Ishikawa с ветками Specter/Helios и кризисной миссией.

