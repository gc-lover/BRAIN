# Диалоги — Айша Фрост

**ID диалога:** `dialogue-npc-aisha-frost`  
**Тип:** npc  
**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 18:05  
**Приоритет:** высокий  
**Связанные документы:** `../npc-lore/important/aisha-frost.md`, `../quests/side/2025-11-07-quest-neon-ghosts.md`, `../../02-gameplay/social/reputation-formulas.md`  
**target-domain:** narrative  
**target-microservice:** narrative-service (port 8087)  
**target-frontend-module:** modules/narrative/side-quests  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 18:05  
**api-readiness-notes:** Диалог обновлён: добавлен уровень Specter, элитные поручения и реакция на городские беспорядки.

---

## 1. Контекст и цели
- **NPC:** Айша Фрост — координатор сети курьеров Neon Ghosts, оперирует из неоновой изнанки Underlink.
- **Роль:** устанавливает условия сотрудничества, реагирует на корпоративное давление, запускает события побочного квеста `Neon Ghosts`.
- **Цели:** определить, станет ли игрок союзником Ghosts, посредником Helios Throne или двойным агентом для Maelstrom.

## 2. Состояния и условия

| Состояние | Описание | Триггеры | Используемые флаги |
|-----------|----------|----------|---------------------|
| scout | Первичный контакт, Айша проверяет мотивы | `rep.fixers.neon` < 20 | `rep.fixers.neon` |
| trusted | Игрок доказал лояльность Ghosts | `rep.fixers.neon` ≥ 20 и `flag.neon.support == true` | `rep.fixers.neon`, `flag.neon.support` |
| corporate | Игрок сотрудничает с Helios Throne | `flag.helios.deal == true` | `flag.helios.deal`, `rep.corp.helios` |
| exposed | Айша узнала о связях с Maelstrom | `flag.maelstrom.double_agent == true` | `flag.maelstrom.double_agent` |
| crisis | Underlink в режиме блокировки | `world.event.neon_lockdown == true` | `world.event.neon_lockdown` |

- **Репутации:** `rep.fixers.neon`, `rep.corp.helios`, `rep.gang.maelstrom`.
- **Связанные проверки:** узлы `intel-briefing`, `ghost-confrontation`, `resolution` из квеста `Neon Ghosts`.
- **Мировые события:** `world.event.neon_lockdown`, `world.event.maelstrom_underlink_raid`.

## 3. Структура диалога

### 3.1 Приветствия

| Состояние | Реплика NPC | Условия | Ответы игрока |
|-----------|-------------|---------|---------------|
| scout | «Ты новый контакт? Прежде чем доверять, я хочу знать, на чьей ты стороне.» | default | `["Мне нужны координаты", "Я пришёл с миром", "Уходя"]` |
| trusted | «Ghosts видят в тебе союзника. Готов к следующей поставке?» | `rep.fixers.neon` ≥ 20, `flag.neon.support` | `["Перевоз вечером", "Нужна аналитика", "Передохнуть"]` |
| corporate | «Helios купил твою тишину? Тогда обоснуй, почему я должна говорить с тобой.» | `flag.helios.deal == true` | `["Я посредник", "Это временно", "Контракт разорван"]` |
| exposed | «Маельстрому не место в наших туннелях. У тебя есть три секунды, чтобы объясниться.» | `flag.maelstrom.double_agent == true` | `["Это был блеф", "Маельстром платит лучше", "Молчать"]` |
| crisis | «Lockdown. Любое лишнее движение — и Underlink зальёт ICE пожаром.» | `world.event.neon_lockdown == true` | `["Покажи эвакуацию", "Мы удержим шлюз", "Ухожу"]` |

### 3.2 Узлы (YAML)

```yaml
- node-id: scout-evaluation
  label: Проверка намерений
  entry-condition: state == "scout"
  player-options:
    - option-id: pay-route
      text: "Заплатить за маршрут"
      requirements:
        - type: resource
          resource: eddies
          amount: 4000
      npc-response: "Кредиты не пахнут. Слушай внимательно."
      outcomes:
        success: { effect: "unlock_node", node: "underlink-brief" }
    - option-id: persuade-trust
      text: "Убедить доверять"
      requirements:
        - type: stat-check
          stat: Persuasion
          dc: 18
      npc-response: "Вижу в глазах искренность. Держи частоту."
      outcomes:
        success: { effect: "unlock_node", node: "underlink-brief", reputation: { "rep.fixers.neon": +4 } }
        failure: { effect: "reduce_trust", reputation: { "rep.fixers.neon": -3 }, cooldown: 900 }

- node-id: underlink-brief
  label: Брифинг по Underlink
  entry-condition: node == "underlink-brief"
  player-options:
    - option-id: accept-job
      text: "Принять задание"
      requirements:
        - type: flag
          flag: "quest.neon_ghosts.active"
      npc-response: "Маршрут залит на твой имплант. Держи канал в тени."
      outcomes:
        success: { effect: "grant_buff", buff: "underlink-ghost", duration: 600 }
    - option-id: request-support
      text: "Запросить поддержку"
      requirements:
        - type: stat-check
          stat: Strategy
          dc: 19
      npc-response: "Могу выделить дрона-наблюдателя. С тебя чистый возврат."
      outcomes:
        success: { effect: "spawn_companion", companion: "ghost-drone" }
        failure: { effect: "deny_support", reputation: { "rep.fixers.neon": -2 } }

- node-id: trusted-routing
  label: Планирование операций
  entry-condition: state == "trusted"
  player-options:
    - option-id: schedule-drop
      text: "Назначить ночную доставку"
      requirements:
        - type: stat-check
          stat: Logistics
          dc: 20
      npc-response: "Окей. Выдвигаемся через тридцать. Призрак ведёт колонну."
      outcomes:
        success: { effect: "trigger_event", event: "neon_ghosts_night_run", reputation: { "rep.fixers.neon": +6 } }
        failure: { effect: "event_delay", delay: 1800 }
    - option-id: exchange-data
      text: "Обменять украденные пакеты"
      requirements:
        - type: resource
          resource: data_shard
          amount: 1
      npc-response: "Хороший улов. Эти данные взорвут корпоративные аналитики."
      outcomes:
        success: { effect: "unlock_reward", reward: "ghost-cache", reputation: { "rep.fixers.neon": +4 } }

- node-id: corporate-ultimatum
  label: Корпоративное давление
  entry-condition: state == "corporate"
  player-options:
    - option-id: mediate
      text: "Предложить сделку Helios"
      requirements:
        - type: stat-check
          stat: Negotiation
          dc: 21
      npc-response: "Helios обожгёт нас при первом же сбое. Давай цифры."
      outcomes:
        success: { effect: "convert_state", new-state: "scout", reputation: { "rep.corp.helios": +6, "rep.fixers.neon": +3 } }
        failure: { effect: "call_off", flag: "flag.helios.deal_failed", reputation: { "rep.corp.helios": -5 } }
    - option-id: resist
      text: "Сорвать соглашение"
      requirements:
        - type: stat-check
          stat: Resolve
          dc: 19
      npc-response: "Хорошо. Тогда ломаем их шлюзы сами."
      outcomes:
        success: { effect: "trigger_event", event: "neon_ghosts_resistance", reputation: { "rep.fixers.neon": +5 } }
        failure: { effect: "increase_alert", alert: "helios", amount: 2 }

- node-id: crisis-directives
  label: Приказы во время Lockdown
  entry-condition: state == "crisis"
  player-options:
    - option-id: evacuation
      text: "Организовать эвакуацию курьеров"
      requirements:
        - type: stat-check
          stat: Leadership
          dc: 20
      npc-response: "Ghosts слушают твой приказ. Ведёшь колонну до выхода Sigma."
      outcomes:
        success: { effect: "grant_modifier", modifier: "underlink.stability", value: +8 }
        failure: { effect: "casualty_report", penalty: { reputation: { "rep.fixers.neon": -8 } } }
    - option-id: hold-line
      text: "Удерживать транспортный шлюз"
      requirements:
        - type: stat-check
          stat: Combat
          dc: 21
      npc-response: "Значит, ты прикрываешь нас, пока мы выгружаем пакет."
      outcomes:
        success: { effect: "spawn_encounter", encounter: "neon-ice-squad", reward: { item: "ghost-countermeasure" } }
        failure: { effect: "lockdown_extend", duration: 600 }
```

### 3.3 Таблица проверок

| Узел | Тип проверки | DC | Модификаторы | Успех | Провал | Крит. успех | Крит. провал |
|------|--------------|----|--------------|-------|--------|-------------|--------------|
| scout-evaluation.persuade-trust | Persuasion | 18 | `+2` за `rep.fixers.neon ≥ 10` | доступ к брифингу, +4 репутации | -3 к репутации, перезапрос через 900 c | +6 репутации, бафф `ghost-intel` | -6 репутации, ICE-погоня |
| underlink-brief.request-support | Strategy | 19 | `+1` за активный дрон | Компаньон-дрон поддерживает миссию | Отказ в поддержке | Бафф `system-map` | — |
| trusted-routing.schedule-drop | Logistics | 20 | `+1` за `flag.neon.support` | Событие `night_run` | Задержка события | Доп. награда `ghost-safehouse` | — |
| corporate-ultimatum.mediate | Negotiation | 21 | `+2` за `rep.corp.helios ≥ 25` | Уменьшает напряжение, повышает репутации | Провал сделки, падение репутации | Получение протокола `helios-shadow` | Блокировка доступа (`flag.neon.blacklist`) |
| corporate-ultimatum.resist | Resolve | 19 | `+1` за активный мод `anti-ice` | Запускает событие сопротивления | Повышает тревогу Helios | Массовая поддержка (+10 репутации) | Корпоративный рейд (событие `helios-crackdown`) |
| crisis-directives.evacuation | Leadership | 20 | `+2` за `world.event.neon_lockdown` progress < 50% | Повышение стабильности Underlink | Отчёт о потерях | Сокращает кризис на 300 сек | Тяжёлые потери, падение репутации -12 |
| crisis-directives.hold-line | Combat | 21 | `+1` за активный бафф `ghost-intel` | Спавн encounter с лутом | Увеличение времени локдауна | Доп. лут `ghost-prototype` | — |

### 3.4 Реакции на события
- **Событие:** `world.event.neon_lockdown`
  - **Условие:** уровень кризиса ≥ 2, игрок союзник Ghosts.
  - **Реплика:** «У нас пять минут, чтобы вывести курьеров. Ты ведёшь северный туннель.»
  - **Последствия:** активируется узел `crisis-directives`, повышается `underlink.stability` при успехе.
- **Событие:** `world.event.maelstrom_underlink_raid`
  - **Условие:** игрок сотрудничал с Maelstrom.
  - **Реплика:** «Маельстром жжёт наш маршрут. Надеюсь, это стоило тебе доверия.»
  - **Последствия:** снижение `rep.fixers.neon`, открытие ветки `exposed`. 
- **Событие:** `contract.helios-shadow-ops`
  - **Условие:** игрок заключил корпоративное соглашение.
  - **Реплика:** «Helios думает, что купил тебя. Давай посмотрим, кого ты выберешь, когда загорятся реальные туннели.»
  - **Последствия:** доступ к ветке `corporate-ultimatum`.

## 4. Награды и последствия
- **Репутации:** `rep.fixers.neon` ±15, `rep.corp.helios` ±10, `rep.gang.maelstrom` ±12.
- **Флаги:** `flag.neon.support`, `flag.helios.deal`, `flag.maelstrom.double_agent`, `flag.neon.blacklist`.
- **Предметы:** `ghost-drone`, `ghost-cache`, `ghost-countermeasure`, `ghost-prototype`.
- **World-state:** модификатор `underlink.stability`, триггер событий `neon_ghosts_night_run`, `helios-crackdown`.
- **События API:** `POST /api/v1/world/events` (запуск), `POST /api/v1/social/reputation/batch`, `POST /api/v1/economy/contracts/activate` (корпоративная ветка).

## 5. Связанные материалы
- `../npc-lore/important/aisha-frost.md`
- `../quests/side/2025-11-07-quest-neon-ghosts.md`
- `../../02-gameplay/world/events/world-events-framework.md`
- `../../05-technical/global-state/global-state-management.md`
- `../../05-technical/ui/main-game/ui-system.md`

## 6. История изменений
- 2025-11-07 17:55 — Первичная версия диалога, статусы ready.

