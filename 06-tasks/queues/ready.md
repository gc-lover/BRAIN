# Очередь документов — статус `ready`

- Лимит файла: ≤ 500 строк. При превышении создайте `ready_0001.md`, `ready_0002.md`, указывая ссылку на продолжение.
- Формат записи:

```markdown
- **Документ:** .BRAIN/05-technical/backend/auth/README.md (v1.0.1)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager  
  **Следующий шаг:** Создать API задачу для auth-service (ДУАПИТАСК).
```

- При изменении статуса переместите запись в соответствующий файл (`needs-work.md`, `blocked.md`, и т.д.) и обновите дату.


- **Документ:** .BRAIN/05-technical/backend/auth/README.md (v1.0.1)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager | Следующий шаг: дождаться одобрения на постановку задач для auth-service.
- **Документ:** .BRAIN/05-technical/backend/player-character-mgmt/character-management.md (v1.1.0)  
  **Проверено:** 2025-11-09 00:14 — Brain Manager | Следующий шаг: подготовить задачу для character-service после подтверждения.

- **Документ:** .BRAIN/05-technical/backend/progression-backend.md (v1.0.0)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager | Следующий шаг: подготовить API задачу для progression core.

- **Документ:** .BRAIN/05-technical/backend/inventory-system/part1-core-system.md (v1.0.1)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager | Следующий шаг: завести новое API задание по инвентарю.

- **Документ:** .BRAIN/05-technical/backend/combat-session-backend.md (v1.0.0)  
  **Проверено:** 2025-11-08 23:56 — Brain Manager | Следующий шаг: подготовить свежую задачу для combat session lifecycle.


- **Документ:** .BRAIN/05-technical/backend/trade-system.md (v1.0.0)  
  **Проверено:** 2025-11-09 00:18 — Brain Manager | Следующий шаг: подготовить новое API задание для трейдинга (economy-service).
- **Документ:** .BRAIN/02-gameplay/combat/combat-implants-types.md (v1.1.0)  
  **Проверено:** 2025-11-09 00:47 — Brain Manager | Следующий шаг: сформировать API задачи по боевым имплантам (gameplay-service).
- **Документ:** .BRAIN/02-gameplay/combat/combat-combos-synergies.md (v1.0.0)  
  **Проверено:** 2025-11-09 00:45 — Brain Manager | Следующий шаг: запланировать API задачи на систему комбо/синергий (gameplay-service, волна 2).

