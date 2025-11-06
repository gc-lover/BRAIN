---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 06:30  
**api-readiness-notes:** API Gameplay Models. Quest, Inventory, Combat, Item models. ~390 строк.
---

# API Gameplay Models - Игровые модели

**Статус:** approved  
**Версия:** 1.0.0  
**Дата:** 2025-11-07 06:30  
**Приоритет:** КРИТИЧЕСКИЙ  
**Автор:** AI Brain Manager

**Микрофича:** Gameplay models  
**Размер:** ~390 строк ✅

---


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-173](../../../API-SWAGGER/tasks/active/queue/task-173-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Категория: DATA_MODELS_SPLIT
- 🔗 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Quest Models

```typescript
interface Quest {
  id: string;
  title: string;
  description: string;
  type: "main" | "side" | "extract" | "romance";
  level: number;
  rewards: {
    experience: number;
    eurodollars: number;
    items?: string[];
    reputation?: Record<string, number>;
  };
}

interface QuestProgress {
  questId: string;
  playerId: string;
  status: "available" | "active" | "completed" | "failed";
  currentNode: number;
  currentBranch?: string;
  choices: Array<{nodeId: number, choiceId: string, timestamp: Date}>;
  flags: string[];
}
```

---

## Inventory Models

```typescript
interface InventoryItem {
  id: string;
  characterId: string;
  itemId: string;
  quantity: number;
  equipped: boolean;
  durability?: number;
  customData?: any;
}

interface ItemTemplate {
  id: string;
  name: string;
  type: "weapon" | "armor" | "consumable" | "material" | "implant";
  quality: "common" | "rare" | "epic" | "legendary";
  level: number;
  stats?: {
    damage?: number;
    armor?: number;
    weight?: number;
  };
  price: number;
}
```

---

## Combat Models

```typescript
interface CombatSession {
  id: string;
  characterId: string;
  enemyId: string;
  turn: number;
  
  playerHp: {current: number, max: number};
  enemySp: {current: number, max: number};
  
  status: "active" | "won" | "lost" | "fled";
  log: CombatAction[];
}

interface CombatAction {
  turn: number;
  actor: "player" | "enemy";
  action: "attack" | "defend" | "ability";
  damage?: number;
  effect?: string;
}
```

---

## Связанные документы

- `.BRAIN/05-technical/api-specs/data-models/core-models.md` - Core (микрофича 1/3)
- `.BRAIN/05-technical/api-specs/data-models/social-models.md` - Social (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 06:30)** - Микрофича 2/3 (split from api-data-models.md)

