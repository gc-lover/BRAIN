# API Data Models - Part 1: Core Models

**Версия:** 1.0.1  
**Дата:** 2025-11-07 01:57  
**Часть:** 1 из 2

[Навигация](./README.md) | [Part 2 →](./part2-gameplay-models.md)

---

## User Model

```typescript
interface User {
  id: string; // UUID
  email: string;
  username: string;
  createdAt: Date;
  lastLoginAt: Date;
  isPremium: boolean;
  settings: UserSettings;
}

interface UserSettings {
  notifications: boolean;
  autoSave: boolean;
  theme: "light" | "dark";
}
```

---

## Character Model

```typescript
interface Character {
  id: string; // UUID
  userId: string; // FK
  name: string;
  level: number;
  experience: number;
  origin: string; // Corpo, Nomad, Street Kid
  lifepath: string;
  
  attributes: {
    body: number;
    intelligence: number;
    reflex: number;
    technical: number;
    cool: number;
  };
  
  stats: {
    hp: number;
    maxHp: number;
    energy: number;
    maxEnergy: number;
  };
  
  location: string; // Current location ID
  inventory: Inventory;
  
  createdAt: Date;
  updatedAt: Date;
}
```

---

## Item Model

```typescript
interface Item {
  id: string; // UUID
  name: string;
  description: string;
  type: ItemType; // weapon, armor, consumable, quest, misc
  rarity: Rarity; // common, uncommon, rare, epic, legendary
  
  stats?: ItemStats;
  price: number; // in ED
  weight: number;
  maxStack: number;
  isTradeable: boolean;
  
  requirements?: {
    level?: number;
    attributes?: Record<string, number>;
  };
}

type ItemType = "weapon" | "armor" | "consumable" | "quest" | "misc";
type Rarity = "common" | "uncommon" | "rare" | "epic" | "legendary";

interface ItemStats {
  damage?: number;
  armor?: number;
  effect?: string; // for consumables
}
```

---

## Location Model

```typescript
interface Location {
  id: string; // UUID
  name: string;
  description: string;
  region: string; // Night City, Badlands, etc
  
  isUnlocked: boolean;
  unlockRequirements?: {
    questId?: string;
    level?: number;
  };
  
  npcs: string[]; // NPC IDs
  quests: string[]; // Quest IDs
  shops: string[]; // Shop IDs
  
  travelCost: number; // ED or time
  imageUrl?: string;
}
```

---

## Inventory Model

```typescript
interface Inventory {
  characterId: string;
  capacity: number;
  usedCapacity: number;
  items: InventoryItem[];
}

interface InventoryItem {
  itemId: string; // FK to Item
  quantity: number;
  isEquipped: boolean;
  slot?: EquipmentSlot; // if equipped
}

type EquipmentSlot = "head" | "chest" | "hands" | "legs" | "weapon" | "accessory";
```

---

[Part 2: Gameplay Models →](./part2-gameplay-models.md)

---

## История изменений

- v1.0.1 (2025-11-07 01:57) - Создан из api-data-models.md

