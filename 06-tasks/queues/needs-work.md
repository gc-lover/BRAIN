# Очередь документов — статус `needs-work`
---

**Статус:** active  
**Версия:** 1.0.0  
**Последнее обновление:** 2025-11-09 09:38  

---

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-09 09:38  
**api-readiness-notes:** Перепроверено 2025-11-09 09:37: очередь фиксирует документы, требующие доработки, и не формирует API задачи.

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
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-009-granville-island.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Описать ветвления, NPC, требования к quest-engine, KPI наград и интеграции с экономикой/социальными системами; определить целевые API каталоги.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-010-most-livable-city.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Зафиксировать сценарные развилки, KPI livability, экономические и социальные зависимости, определить REST/WS каталоги для quest-engine.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/washington-dc/2020-2029/quest-001-white-house.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Расписать контроль доступа, NPC Secret Service, исходы туров и интеграции с дипломатическими/безопасными системами quest-engine, определить целевые каталоги API.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/asia/shanghai/2020-2029/quest-008-chinese-opera.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:38 — Brain Manager  
  **Что доработать:** Привести квест к QUEST-TEMPLATE, добавить ветвления, интеграции с системами и целевые API, детализировать награды перед постановкой задач.

