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
  **Проверено:** 2025-11-09 01:30 — Brain Manager | Следующий шаг: подготовить пакет REST/Events по инвентарю (`api/v1/inventory/inventory-core.yaml`, economy-service).
- **Документ:** .BRAIN/05-technical/backend/combat-session-backend.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:24 — Brain Manager | Следующий шаг: использовать конспект `2025-11-09-combat-wave-package.md` для разбивки combat session API.
- **Документ:** .BRAIN/05-technical/backend/trade-system.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:30 — Brain Manager | Следующий шаг: подготовить задание по P2P трейду (economy-service, `api/v1/trade/trade-system.yaml`) с антифродом и очередью подтверждений.
- **Документ:** .BRAIN/05-technical/backend/quest-engine-backend.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:19 — Brain Manager | Следующий шаг: оформить REST/WS/EventBus задачи по конспекту `2025-11-09-quest-engine-package.md` и подготовить передачу в ДУАПИТАСК (`api/v1/gameplay/quests/quest-engine.yaml`).
- **Документ:** .BRAIN/02-gameplay/combat/combat-implants-types.md (v1.1.0)  
  **Проверено:** 2025-11-09 00:47 — Brain Manager | Следующий шаг: сформировать API задачи по боевым имплантам (gameplay-service).
- **Документ:** .BRAIN/02-gameplay/combat/combat-combos-synergies.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:15 — Brain Manager | Следующий шаг: запланировать API задачи на систему комбо/синергий (gameplay-service, волна 2, api/v1/gameplay/combat/combos-synergies.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-ai-enemies.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:22 — Brain Manager | Следующий шаг: подготовить пакет API задач по AI и WebSocket потокам (gameplay-service, `api/v1/gameplay/combat/ai-enemies.yaml`).
- **Документ:** .BRAIN/02-gameplay/combat/arena-system.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:22 — Brain Manager | Следующий шаг: синхронизировать постановку задач по аренам и рейтингам (gameplay-service, api/v1/gameplay/combat/arena-system.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-dnd-integration-shooter.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:24 — Brain Manager | Следующий шаг: применять backlog `2025-11-09-combat-wave-package.md` (api/v1/gameplay/combat/dnd-integration-shooter.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-shooting.md (v1.1.0)  
  **Проверено:** 2025-11-09 01:37 — Brain Manager | Следующий шаг: подготовить REST/WS пакет по TTK, отдаче и имплант-модификаторам (gameplay-service, `api/v1/gameplay/combat/shooting.yaml`).
- **Документ:** .BRAIN/02-gameplay/combat/combat-extract.md (v1.3.0)  
  **Проверено:** 2025-11-09 01:28 — Brain Manager | Следующий шаг: сформировать задачи для экстрактшутер механик (gameplay-service, api/v1/gameplay/combat/extraction.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-hacking-networks.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:28 — Brain Manager | Следующий шаг: сформировать задания на сетевой хакерский слой (gameplay-service, api/v1/gameplay/combat/hacking/networks.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-hacking-combat-integration.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:28 — Brain Manager | Следующий шаг: подготовить задачи по интеграции хакерства в бою (gameplay-service, api/v1/gameplay/combat/hacking/combat-integration.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-cyberspace.md (v1.0.0)  
  **Проверено:** 2025-11-09 00:54 — Brain Manager | Следующий шаг: подготовить задания для киберпространства и связанных режимов (gameplay-service).
- **Документ:** .BRAIN/02-gameplay/combat/combat-abilities.md (v1.2.0)  
  **Проверено:** 2025-11-09 01:22 — Brain Manager | Следующий шаг: подготовить API задачи по системе боевых способностей (gameplay-service, api/v1/gameplay/combat/abilities.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-dnd-core.md (v1.0.0)  
  **Проверено:** 2025-11-09 01:22 — Brain Manager | Следующий шаг: сформировать задачи по ядру D&D проверок (gameplay-service, api/v1/gameplay/combat/dnd-core.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-stealth.md (v1.1.0)  
  **Проверено:** 2025-11-09 01:22 — Brain Manager | Следующий шаг: подготовить задания по системе скрытности и обнаружения (gameplay-service, api/v1/gameplay/combat/stealth.yaml).
- **Документ:** .BRAIN/02-gameplay/combat/combat-freerun.md (v1.1.0)  
  **Проверено:** 2025-11-09 01:22 — Brain Manager | Следующий шаг: сформировать задачи по паркур-системе и боевым манёврам (gameplay-service, api/v1/gameplay/combat/freerun.yaml).
