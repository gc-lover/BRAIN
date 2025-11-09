# Очередь документов — статус `needs-work`
---

**Статус:** active  
**Версия:** 1.0.0  
**Последнее обновление:** 2025-11-09 09:35  

---

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-09 09:35  
**api-readiness-notes:** Перепроверено 2025-11-09 09:35: очередь фиксирует документы, требующие доработки, и не формирует API задачи.

- Лимит файла: ≤ 500 строк. При превышении создайте `needs-work_0001.md`, `needs-work_0002.md` и свяжите файлы.
- Формат записи:

```markdown
- **Документ:** .BRAIN/05-technical/backend/player-character-mgmt/README.md (v1.0.1)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager  
  **Что доработать:** Восстановить компактный файл character-management.md перед задачей API.
```

- После устранения замечаний удалите запись отсюда и перенесите в файл нового статуса (например, `ready.md`).

- **Документ:** .BRAIN/02-gameplay/economy/player-market/player-market-analytics.md (v1.0.0)  
  **Проверено:** 2025-11-09 09:34 — Brain Manager  
  **Что доработать:** Добавить API контракты витрин, SQL/ETL схемы и матрицу KPI для аналитики игрокового рынка.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/mexico-city/2020-2029/quest-002-tacos-al-pastor.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:36 — Brain Manager  
  **Что доработать:** Уточнить ветки квеста, описать связи с прогрессией и экономикой, указать целевой микросервис и фронтенд-модуль.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/vancouver/2020-2029/quest-009-granville-island.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Описать ветвления, NPC, требования к сервисам quest-engine, KPI наград и связки с экономикой/социальными системами; сформировать целевые API каталоги.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-003-red-rocks-amphitheatre.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:36 — Brain Manager  
  **Что доработать:** Применить QUEST-TEMPLATE, детализировать этапы, выборы, награды и связи с системами перед передачей в API поток.
- **Документ:** .BRAIN/03-lore/_03-lore/timeline-author/quests/america/atlanta/2020-2029/quest-004-atlanta-airport.md (v0.1.0)  
  **Проверено:** 2025-11-09 09:35 — Brain Readiness Checker  
  **Что доработать:** Структурировать этапы, расписать зависимости с системами, награды и целевые API/микросервисы перед постановкой задачи.

