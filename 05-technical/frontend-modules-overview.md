# Frontend Modules Overview - Обзор модульной архитектуры

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-07  
**api-readiness-notes:** Техническая документация, описывает модульную архитектуру фронтенда

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07  
**Приоритет:** средний

---

## Описание

Детальное описание модульной архитектуры фронтенда для Production. Описывает концепцию модулей, их структуру, взаимодействие через Event Bus, lazy loading и Module Federation.

**Текущий статус:** 📋 Планируется для Production (сейчас используется feature-based)

---

## Концепция модулей

### Что такое модуль?

**Модуль** - это самодостаточная часть приложения, организованная по доменному принципу (social, economy, combat, world).

**Аналогия с бэкендом:**
- Backend: микросервисы (auth-service, character-service, etc.)
- Frontend: модули (social, economy, combat, world)

### Преимущества модульной архитектуры

✅ **Изоляция:** Баг в модуле не ломает другие модули  
✅ **Lazy loading:** Загружаются только нужные модули  
✅ **Параллельная разработка:** Разные команды работают над разными модулями  
✅ **Переиспользование:** Модули можно использовать в разных приложениях  
✅ **Масштабируемость:** Легко добавлять новые модули

---

## Когда переходить на модули?

### ❌ НЕ для MVP (текущее состояние)

**Используем:** Feature-based архитектура
- Проще для начальной разработки
- Меньше boilerplate
- Быстрый старт

### ✅ Переходить когда:

- Приложение выросло >50 features
- Нужна параллельная разработка (команда >10 человек)
- Требуется lazy loading для производительности
- Разные команды работают над разными доменами
- Нужна изоляция для уменьшения рисков

---

## Структура модулей

### Общая структура

```
FRONT-WEB/src/
├── core/                        # Ядро приложения
│   ├── module-loader/          # Загрузка модулей
│   ├── event-bus/              # Связь модулей
│   ├── api-gateway/            # API wrapper
│   └── state-management/       # Global state
│
├── modules/                     # Доменные модули
│   ├── social/
│   ├── economy/
│   ├── combat/
│   └── world/
│
└── shared/                      # Shared resources
    ├── ui/                     # UI Kit
    ├── hooks/
    └── utils/
```

---

## Доменные модули

### 1. Social Module (Социальный)

**Домен:** Социальные взаимодействия

**Features:**
- Чат (chat)
- Гильдии (guilds)
- Друзья (friends)
- NPC взаимодействия
- Romantic relationships
- Reputation system

**API routes:** `/api/v1/social/*`

**Структура:**
```
modules/social/
├── features/               # Features модуля
│   ├── chat/
│   │   ├── components/    # ChatWindow, MessageList
│   │   ├── hooks/         # useChat, useChatMessages
│   │   └── services/      # chatService
│   │
│   ├── guilds/
│   │   ├── components/    # GuildList, GuildCard
│   │   ├── hooks/         # useGuilds, useGuildManagement
│   │   └── services/      # guildService
│   │
│   ├── friends/
│   │   ├── components/    # FriendsList, FriendRequest
│   │   ├── hooks/         # useFriends, useFriendRequests
│   │   └── services/      # friendService
│   │
│   └── npcs/
│       ├── components/    # NPCCard, NPCDialog
│       ├── hooks/         # useNPCs, useNPCInteraction
│       └── services/      # npcService
│
├── store/                  # Module state
│   ├── chatStore.ts
│   ├── guildStore.ts
│   └── friendStore.ts
│
├── api/                    # Module API client
│   └── socialApi.ts        # Orval generated
│
├── routes/                 # Module routes
│   └── SocialRoutes.tsx
│
└── module.config.ts        # Module configuration
```

**Event Bus события:**
- Публикует: `social:message-received`, `social:friend-request`, `social:guild-invite`
- Подписывается: `character:level-up`, `combat:achievement-unlocked`

---

### 2. Economy Module (Экономический)

**Домен:** Экономика и торговля

**Features:**
- Торговля (trading)
- Аукцион (auction)
- Биржа (stock exchange)
- Крафт (crafting)
- Инвентарь (inventory)

**API routes:** `/api/v1/economy/*`

**Структура:**
```
modules/economy/
├── features/
│   ├── trading/
│   │   ├── components/    # TradeWindow, TradeOffer
│   │   ├── hooks/         # useTrade, useTradeHistory
│   │   └── services/      # tradeService
│   │
│   ├── auction/
│   │   ├── components/    # AuctionList, BidForm
│   │   ├── hooks/         # useAuction, useBids
│   │   └── services/      # auctionService
│   │
│   ├── crafting/
│   │   ├── components/    # CraftingTable, RecipeList
│   │   ├── hooks/         # useCrafting, useRecipes
│   │   └── services/      # craftingService
│   │
│   └── inventory/
│       ├── components/    # InventoryGrid, ItemCard
│       ├── hooks/         # useInventory, useEquipment
│       └── services/      # inventoryService
│
├── store/
│   ├── inventoryStore.ts
│   ├── tradeStore.ts
│   └── auctionStore.ts
│
├── api/
│   └── economyApi.ts
│
└── module.config.ts
```

**Event Bus события:**
- Публикует: `economy:trade-completed`, `economy:auction-won`, `economy:item-crafted`
- Подписывается: `combat:enemy-killed` (generate loot), `social:quest-completed` (rewards)

---

### 3. Combat Module (Боевой)

**Домен:** Боевая система

**Features:**
- Бой (combat)
- Способности (abilities)
- Оружие (weapons)
- Комбо (combos)
- Импланты (implants)

**API routes:** `/api/v1/gameplay/combat/*`

**Структура:**
```
modules/combat/
├── features/
│   ├── combat-session/
│   │   ├── components/    # CombatInterface, ActionBar
│   │   ├── hooks/         # useCombat, useCombatState
│   │   └── services/      # combatService
│   │
│   ├── abilities/
│   │   ├── components/    # AbilityButton, CooldownTimer
│   │   ├── hooks/         # useAbilities, useAbilityCast
│   │   └── services/      # abilityService
│   │
│   ├── weapons/
│   │   ├── components/    # WeaponSelector, WeaponStats
│   │   ├── hooks/         # useWeapons, useWeaponSwitch
│   │   └── services/      # weaponService
│   │
│   └── combos/
│       ├── components/    # ComboIndicator, ComboList
│       ├── hooks/         # useCombos, useComboTracker
│       └── services/      # comboService
│
├── store/
│   ├── combatStore.ts
│   ├── abilityStore.ts
│   └── weaponStore.ts
│
├── api/
│   └── combatApi.ts
│
└── module.config.ts
```

**Event Bus события:**
- Публикует: `combat:enemy-killed`, `combat:damage-dealt`, `combat:ability-used`
- Подписывается: `character:stat-changed`, `economy:item-equipped`

---

### 4. World Module (Мировой)

**Домен:** Игровой мир

**Features:**
- Локации (locations)
- Экстракция (extraction)
- Мировые события (events)
- Рейды (raids)

**API routes:** `/api/v1/world/*`

**Структура:**
```
modules/world/
├── features/
│   ├── locations/
│   │   ├── components/    # LocationMap, LocationCard
│   │   ├── hooks/         # useLocations, useNavigation
│   │   └── services/      # locationService
│   │
│   ├── extraction/
│   │   ├── components/    # ExtractionTimer, ExtractionPoint
│   │   ├── hooks/         # useExtraction, useExtractionTimer
│   │   └── services/      # extractionService
│   │
│   ├── events/
│   │   ├── components/    # EventNotification, EventList
│   │   ├── hooks/         # useWorldEvents, useEventParticipation
│   │   └── services/      # eventService
│   │
│   └── raids/
│       ├── components/    # RaidLobby, RaidStatus
│       ├── hooks/         # useRaids, useRaidParty
│       └── services/      # raidService
│
├── store/
│   ├── locationStore.ts
│   ├── eventStore.ts
│   └── raidStore.ts
│
├── api/
│   └── worldApi.ts
│
└── module.config.ts
```

**Event Bus события:**
- Публикует: `world:location-changed`, `world:event-started`, `world:extraction-completed`
- Подписывается: `combat:enemy-killed`, `social:party-formed`

---

## Module Configuration

### module.config.ts

```typescript
// modules/social/module.config.ts
export const socialModuleConfig = {
  id: 'social',
  name: 'Social Module',
  version: '1.0.0',
  
  // Lazy loading
  lazy: true,
  
  // Dependencies (другие модули)
  dependencies: [],
  
  // Routes
  routes: [
    {
      path: '/social/chat',
      component: () => import('./features/chat/pages/ChatPage'),
    },
    {
      path: '/social/guilds',
      component: () => import('./features/guilds/pages/GuildsPage'),
    },
  ],
  
  // Event Bus subscriptions
  events: {
    subscribes: ['character:level-up', 'combat:achievement-unlocked'],
    publishes: ['social:message-received', 'social:friend-request'],
  },
  
  // Permissions
  permissions: ['chat.send', 'guild.manage', 'friends.invite'],
};
```

---

## Event Bus для связи модулей

### Реализация Event Bus

```typescript
// core/event-bus/EventBus.ts
type EventCallback = (data: any) => void;

export class EventBus {
  private events = new Map<string, EventCallback[]>();
  
  subscribe(event: string, callback: EventCallback) {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }
    this.events.get(event)!.push(callback);
    
    return () => {
      const callbacks = this.events.get(event);
      if (callbacks) {
        const index = callbacks.indexOf(callback);
        if (index > -1) callbacks.splice(index, 1);
      }
    };
  }
  
  publish(event: string, data: any) {
    const callbacks = this.events.get(event) || [];
    callbacks.forEach(callback => callback(data));
  }
  
  clear() {
    this.events.clear();
  }
}

export const eventBus = new EventBus();
```

---

### Примеры использования Event Bus

#### Combat Module публикует событие

```typescript
// modules/combat/hooks/useCombat.ts
import { eventBus } from '@/core/event-bus';

export function useCombat() {
  const killEnemy = (enemyId: string, experience: number, loot: Loot) => {
    // Combat logic...
    
    // Publish event для других модулей
    eventBus.publish('combat:enemy-killed', {
      enemyId,
      experience,
      loot,
      timestamp: Date.now(),
    });
  };
  
  return { killEnemy };
}
```

#### Economy Module подписывается на событие

```typescript
// modules/economy/hooks/useLootGeneration.ts
import { eventBus } from '@/core/event-bus';
import { useEffect } from 'react';

export function useLootGeneration() {
  useEffect(() => {
    // Subscribe to combat events
    const unsubscribe = eventBus.subscribe('combat:enemy-killed', (data) => {
      // Generate loot для игрока
      generateLoot(data.loot);
      
      // Show notification
      showNotification(`Loot generated: ${data.loot.items.length} items`);
    });
    
    return unsubscribe; // Cleanup
  }, []);
}
```

#### Character Module подписывается на то же событие

```typescript
// modules/character/hooks/useProgression.ts
export function useProgression() {
  useEffect(() => {
    const unsubscribe = eventBus.subscribe('combat:enemy-killed', (data) => {
      // Add experience to character
      addExperience(data.experience);
      
      // Check level up
      checkLevelUp();
    });
    
    return unsubscribe;
  }, []);
}
```

---

## Lazy Loading модулей

### Dynamic Import

```typescript
// app/router.tsx
import { lazy, Suspense } from 'react';

// Lazy load модулей
const SocialModule = lazy(() => import('@/modules/social'));
const EconomyModule = lazy(() => import('@/modules/economy'));
const CombatModule = lazy(() => import('@/modules/combat'));

export const router = createBrowserRouter([
  {
    path: '/social/*',
    element: (
      <Suspense fallback={<ModuleLoading moduleName="Social" />}>
        <SocialModule />
      </Suspense>
    ),
  },
  {
    path: '/economy/*',
    element: (
      <Suspense fallback={<ModuleLoading moduleName="Economy" />}>
        <EconomyModule />
      </Suspense>
    ),
  },
  // ...
]);
```

---

### Code Splitting Strategy

**Без модулей:**
```
bundle.js (5MB) - все загружается сразу
```

**С модулями:**
```
main.js (100KB) - ядро приложения
shared.js (200KB) - shared компоненты
social-module.js (500KB) - загружается при входе в соц. фичи
economy-module.js (800KB) - загружается при открытии торговли
combat-module.js (1.2MB) - загружается при входе в бой
world-module.js (600KB) - загружается при навигации по миру
```

**Преимущества:**
- Начальная загрузка: 300KB вместо 5MB
- Время до интерактивности: ~1 сек вместо ~5 сек
- Загружаются только нужные модули

---

## Module Federation (опционально)

### Концепция

**Module Federation** позволяет загружать модули из разных build'ов/серверов.

**Когда использовать:**
- Независимый деплой модулей
- Разные команды владеют разными модулями
- Модули используются в разных приложениях

### Конфигурация (Vite)

```javascript
// vite.config.ts
import federation from '@originjs/vite-plugin-federation';

export default defineConfig({
  plugins: [
    federation({
      name: 'host_app',
      remotes: {
        social: 'http://localhost:3001/assets/remoteEntry.js',
        economy: 'http://localhost:3002/assets/remoteEntry.js',
      },
      shared: ['react', 'react-dom', '@mui/material'],
    }),
  ],
});
```

### Использование

```typescript
// Загрузка удаленного модуля
const SocialModule = lazy(() => import('social/SocialApp'));

<Suspense fallback={<Loading />}>
  <SocialModule />
</Suspense>
```

**Примечание:** Module Federation - advanced техника, нужна только для очень больших проектов.

---

## Module Loader

### Динамическая загрузка модулей

```typescript
// core/module-loader/ModuleLoader.ts
import { ModuleConfig } from './types';

export class ModuleLoader {
  private loadedModules = new Map<string, any>();
  
  async loadModule(config: ModuleConfig) {
    if (this.loadedModules.has(config.id)) {
      return this.loadedModules.get(config.id);
    }
    
    const module = await import(`../../modules/${config.id}`);
    
    // Initialize module
    if (module.initialize) {
      await module.initialize();
    }
    
    // Register routes
    if (config.routes) {
      this.registerRoutes(config.routes);
    }
    
    // Subscribe to events
    if (config.events?.subscribes) {
      config.events.subscribes.forEach(event => {
        eventBus.subscribe(event, module.handleEvent);
      });
    }
    
    this.loadedModules.set(config.id, module);
    return module;
  }
  
  unloadModule(moduleId: string) {
    const module = this.loadedModules.get(moduleId);
    if (module?.cleanup) {
      module.cleanup();
    }
    this.loadedModules.delete(moduleId);
  }
}
```

---

## Преимущества модулей для MMORPG

### 1. Изоляция багов

Баг в чате не ломает боевую систему:
```
Bug in Social Module → Chat broken
Combat Module → Still works ✅
Economy Module → Still works ✅
```

### 2. Производительность

Загружаются только нужные модули:
```
Player в городе → Social + Economy загружены
Player в бою → Combat загружен, Social/Economy выгружены
Player в рейде → Combat + World загружены
```

### 3. Параллельная разработка

```
Team A → Social Module (независимо)
Team B → Economy Module (независимо)
Team C → Combat Module (независимо)

Merge conflicts минимальны!
```

### 4. Легкость тестирования

Модули тестируются изолированно:
```typescript
// Тест Social Module
import { socialModule } from '@/modules/social';

test('chat sends message', () => {
  // Тестируем только Social Module
  // Не нужны Combat, Economy, World
});
```

---

## Миграция с Feature-based на Модули

### Этап 1: Подготовка

1. Создать структуру `modules/`
2. Создать Event Bus
3. Создать Module Loader

### Этап 2: Миграция по модулям

**Порядок миграции:**
1. Social Module (проще, меньше зависимостей)
2. Economy Module
3. Combat Module
4. World Module

### Этап 3: Оптимизация

1. Настроить lazy loading
2. Оптимизировать code splitting
3. Настроить Module Federation (опционально)

**Оценка времени:** 2-3 недели

---

## Связанные документы

- [frontend-architecture-overview.md](./frontend-architecture-overview.md) - общая архитектура фронтенда
- [ФРОНТТАСК-MODULES.md](../../FRONT-WEB/docs/ФРОНТТАСК-MODULES.md) - детали из FRONT-WEB
- [MODULE-STRUCTURE.md](../../FRONT-WEB/docs/modules/MODULE-STRUCTURE.md) - структура модулей
- [EVENT-BUS.md](../../FRONT-WEB/docs/modules/EVENT-BUS.md) - Event Bus
- [LAZY-LOADING.md](../../FRONT-WEB/docs/modules/LAZY-LOADING.md) - Lazy loading

---

## История изменений

- v1.0.0 (2025-11-07) - Создан обзор модульной архитектуры фронтенда

