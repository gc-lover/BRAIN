# Очередь документов — статус `needs-work`
---

**Статус:** active  
**Версия:** 1.0.0  
**Последнее обновление:** 2025-11-09 09:43  

---

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-09 09:43  
**api-readiness-notes:** Перепроверено 2025-11-09 09:43: очередь фиксирует документы, требующие доработки, и не формирует API задачи.

- Лимит файла: ≤ 500 строк. При превышении создайте `needs-work_0001.md`, `needs-work_0002.md` и свяжите файлы.
- Формат записи:

```markdown
- **Документ:** .BRAIN/05-technical/backend/player-character-mgmt/README.md (v1.0.1)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager  
  **Что доработать:** Восстановить компактный файл character-management.md перед задачей API.
```

- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/cis/saint-petersburg/2061-2077/quest-034-nicholas-ii-ghost.md (v0.0.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Добавить версию, статус и приоритет, расширить этапы и ветвления, описать награды, зависимости и целевые API пакета quest-engine перед постановкой задачи.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/cis/kiev/2020-2029/quest-006-golden-gate.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:37 — Brain Manager  
  **Что доработать:** Оформить квест по QUEST-TEMPLATE: расписать зависимости (локации, NPC, цепочки), определить целевой микросервис, каталог OpenAPI и фронтенд-модуль, связать этапы и награды с системами прогрессии и экономики.
- **Документ:** .BRAIN/02-gameplay/social/npc-hiring-types.md (v1.0.0)  
  **Проверено:** 2025-11-09 09:43 — Brain Manager  
  **Что доработать:** Сбалансировать стоимость и эффективность ролей найма, оформить API контракты social-service и фронтенд витрины.

- После устранения замечаний удалите запись отсюда и перенесите в файл нового статуса (например, `ready.md`).

- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/asia/tokyo/2061-2077/quest-037-love-hotel.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:36 — Brain Readiness Checker  
  **Что доработать:** Добавить статус, версию и приоритет, расширить этапы с ветвлениями, уточнить награды и определить целевые сервисы/модули для подготовки API пакета.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/cis/moscow/2061-2077/quest-035-implant-addiction.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:37 — Brain Manager  
  **Что доработать:** Применить QUEST-TEMPLATE, расписать ветвления лечения, связать с системами имплантов и указать целевые API/микросервисы и экономику наград.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/cis/yerevan/2020-2029/quest-003-armenian-cognac.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:38 — Brain Manager  
  **Что доработать:** Структурировать дегустационный квест по QUEST-TEMPLATE, добавить ветвления и зависимости, определить микросервисы narrative/gameplay, каталоги API и фронтенд модуль.
- **Документ:** .BRAIN/03-lore/_03-lore/locations/world-cities/chicago-detailed-2020-2093.md (v1.0.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Manager  
  **Что доработать:** Добавить модели данных, REST/Events контракты и связь с фронтендом `modules/world/atlas` для world-service.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/phoenix/2020-2029/quest-010-urban-sprawl.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:36 — Brain Manager  
  **Что доработать:** Расширить сценарную структуру, добавить ветвления, KPI, зависимости с quest-engine и narrative-service, определить целевые каталоги API и фронтенд модуль.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/europe/london/2040-2060/quest-025-wembley-arena.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:37 — Brain Manager  
  **Что доработать:** Применить QUEST-TEMPLATE, оформить YAML-метаданные, этапы с проверками и ветвлениями, связать награды с прогрессией и экономикой и указать целевой пакет quest-engine (`gameplay-service`, modules/quests).
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/europe/berlin/2061-2077/quest-036-berlin-tech-conference.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:36 — Brain Manager  
  **Что доработать:** Применить QUEST-TEMPLATE: структурировать этапы с развилками, добавить зависимости (quest-engine, economy, social), определить микросервис, каталог API и фронтенд-модуль для Berlin Tech Summit.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/europe/rome/2020-2029/quest-004-pasta-master.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:36 — Brain Manager  
  **Что доработать:** Применить QUEST-TEMPLATE: добавить версию и статус сценария, расписать зависимости с системами, проверки этапов, ветвления, а также определить целевые микросервисы, каталоги API и фронтенд-модуль перед передачей в API поток.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-009-granville-island.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Описать ветвления, NPC, требования к quest-engine, KPI наград и интеграции с экономикой/социальными системами; определить целевые API каталоги.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-010-most-livable-city.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Зафиксировать сценарные развилки, KPI livability, экономические и социальные зависимости, определить REST/WS каталоги для quest-engine.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-001-white-house.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Расписать контроль доступа, NPC Secret Service, исходы туров и интеграции с дипломатическими/безопасными системами quest-engine, определить целевые каталоги API.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-002-capitol-building.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Разработать ветвления (тур, заседание, тревога), NPC и события Jan 6, интеграции с системами безопасности/политики и указать каталоги API quest-engine.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-003-lincoln-memorial.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Привести к QUEST-TEMPLATE, добавить ветвления, NPC и социальные эффекты (MLK), определить KPI и каталоги API для интеграции с quest-engine.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-004-smithsonian-museums.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Сформировать маршруты, расписания, ветвления и KPI посещений Smithsonian, добавить NPC и определить интеграции с образовательными/экономическими системами и каталогами API quest-engine.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/asia/shanghai/2020-2029/quest-008-chinese-opera.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:38 — Brain Manager  
  **Что доработать:** Привести квест к QUEST-TEMPLATE, добавить ветвления, интеграции с системами и целевые API, детализировать награды перед постановкой задач.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-004-craft-beer-scene.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:42 — Brain Manager  
  **Что доработать:** Добавить YAML-метаданные, версию, статус, ветвления и интеграции по шаблону QUEST-TEMPLATE; расширить этапы, выборы и награды перед подготовкой API задач.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-005-skiing-resorts.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:44 — Brain Manager  
  **Что доработать:** Применить QUEST-TEMPLATE: добавить YAML-метаданные, версию, статус, ветвления, зависимости с системами (economy/progression) и детализировать награды.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-004-craft-beer-scene.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:42 — Brain Manager  
  **Что доработать:** Добавить YAML-метаданные, версию, статус, ветвления и интеграции по шаблону QUEST-TEMPLATE; расширить этапы, выборы и награды перед подготовкой API задач.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/atlanta/2020-2029/quest-004-atlanta-airport.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Структурировать этапы, расписать зависимости с системами, награды и целевые API/микросервисы перед постановкой задачи.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/atlanta/2020-2029/quest-005-civil-war-history.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:43 — Brain Readiness Checker  
  **Что доработать:** Привести к QUEST-TEMPLATE, добавить NPC, ветвления и интеграции с quest-engine, progression и economy; определить микросервис, каталоги API и связанные документы.

