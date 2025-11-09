---

**Статус:** approved  
**Версия:** 1.0.0  
**Последнее обновление:** 2025-11-09 03:59  

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-09 03:59  
**api-readiness-notes:** Примеры Brain Manager служат справочным материалом и не требуют постановки API задач; статус not-applicable подтверждён 2025-11-09 03:59.

---

# Примеры Brain Manager Agent

## Ссылки
- `../GLOBAL-RULES.md` — главные правила и микросервисная карта.
- `.BRAIN/CORE.md` — структура и трекеры.
- `МЕНЕДЖЕР.MD` — сценарий, режимы работы.

--

## Пример A — Планирование следующего шага
_Запрос:_ «Что делаем дальше?»  
_Ответ Manager:_
```
## План на текущую сессию

### Выполнено
- gameplay/combat/core.md — approved, api-readiness: ready
- social/guilds/concept.md — review, в работе у narrative команды

### В работе
- progression/skill-trees.md — api-readiness: needs-work

### Следующие действия
1. Завершить skill-trees (уточнить прокачку по archetype) — выс. приоритет
2. Подготовить идею economy/crafting (оформить через IDEA-TEMPLATE) — сред. приоритет
3. Собрать открытые вопросы по social mail — низкий приоритет

> Проверь TODO.md и readiness-tracker.yaml после завершения каждого шага. Все файлы ≤ 500 строк.
```

--

## Пример B — Запись новой идеи
_Запрос:_ «Запиши идею по системе рейдов.»  
_Действия:_ создать файл `06-tasks/ideas/2025-11-09-IDEA-world-raids.md`, заполнить шаблон, указать `world-service`, `api/v1/world/raids/`, `modules/world/raids`.  
_Ответ:_
```
✅ Идея сохранена: 06-tasks/ideas/2025-11-09-IDEA-world-raids.md
- Статус: recorded, приоритет: high, тема: world
- Целевой микросервис: world-service, API каталог: api/v1/world/raids/
- Связанный фронтенд модуль: modules/world/raids
- Обновлён README каталога идей.
Коммит выполнен через scripts/autocommit.ps1.
```

--

## Пример C — Отчёт по готовности
_Запрос:_ «Какие документы готовы к API?»  
_Действия:_ проверить `readiness-tracker.yaml`, свериться с ограничениями `GLOBAL-RULES.md`.  
_Ответ:_
```
## Отчёт о готовности

### ✅ Готовы (api-readiness: ready)
- 02-gameplay/combat/shooter-mechanics.md — версия 1.2.0, проверено 2025-11-09 09:05 (реальное время)
- 02-social/relationships/romance-system.md — версия 1.1.0, проверено 2025-11-09 08:45
> Для каждой фичи оформлен entry в brain-mapping.yaml, готовы для ДУАПИТАСК.

### ⏳ Требуют доработки (needs-work)
- 02-progression/skill-trees.md — уточнить зависимости классов, заполнить шаблон ограничений.

### Рекомендации
- Создать API задания для готовых документов (указать микросервис `gameplay-service` и `social-service`).
- Для skill-trees собрать недостающие данные и повторить проверку.
```