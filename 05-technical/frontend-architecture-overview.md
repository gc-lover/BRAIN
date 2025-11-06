# Frontend Architecture Overview - Обзор фронтенд архитектуры

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-07  
**api-readiness-notes:** Техническая документация, описывает фронтенд архитектуру, не для создания API

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07  
**Приоритет:** критический

---

## Описание

Централизованный обзор фронтенд архитектуры NECPGAME. Описывает текущую feature-based структуру (MVP), планируемую модульную архитектуру (Production), управление состоянием, роутинг и интеграцию с бэкендом.

---

## Технологический стек

### Core
- **React 18** - UI библиотека
- **TypeScript** - типизация
- **Vite** - сборка и dev server

### Роутинг
- **React Router v6** - client-side routing

### Управление состоянием
- **Zustand** - глобальное состояние (auth, character, UI)
- **React Query** - серверное состояние (API кэширование)
- **useState** - локальное состояние компонентов

### UI/Стилизация
- **Material UI (MUI)** - базовая библиотека компонентов
- **Tailwind CSS** - utility-first CSS
- **CSS Modules** - scoped styles

### API Integration
- **Orval** - генерация API клиентов из OpenAPI
- **Axios** - HTTP client
- **WebSocket** - real-time коммуникация

### Формы
- **React Hook Form** - управление формами
- **Yup** - валидация

### Тестирование
- **Vitest** - unit тесты
- **React Testing Library** - component тесты
- **Playwright** - E2E тесты

---

## Архитектура: MVP vs Production

### Текущая архитектура (MVP) - Feature-based

**Статус:** ✅ Активно используется

**Принцип:** Организация по features (аутентификация, персонажи, геймплей)

**Преимущества:**
- Проще для начальной разработки
- Меньше boilerplate
- Быстрый старт
- Легко понять структуру

**Когда использовать:**
- MVP и начальная разработка
- Команда <5 разработчиков
- <50 features в приложении

---

### Планируемая архитектура (Production) - Модульная

**Статус:** 📋 Планируется

**Принцип:** Организация по доменным модулям (social, economy, combat, world)

**Преимущества:**
- Изоляция модулей
- Lazy loading
- Параллельная разработка
- Module Federation (опционально)

**Когда переходить:**
- >50 features
- Команда >10 разработчиков
- Нужен lazy loading для производительности
- Разные команды работают над разными доменами

---

## Текущая структура (Feature-based)

```
FRONT-WEB/src/
├── app/                         # Конфигурация приложения
│   ├── router.tsx              # React Router конфигурация
│   ├── providers.tsx           # React Query, Theme провайдеры
│   └── store.ts                # Zustand store configuration
│
├── features/                    # Feature-based модули
│   ├── auth/                   # Аутентификация
│   │   ├── components/         # LoginForm, RegisterForm
│   │   ├── hooks/              # useAuth, useLogin
│   │   ├── pages/              # LoginPage, RegisterPage
│   │   ├── services/           # authService (API calls)
│   │   └── index.ts            # Public API
│   │
│   ├── characters/             # Управление персонажами
│   │   ├── components/         # CharacterList, CharacterCard
│   │   ├── hooks/              # useCharacters, useCharacterCreation
│   │   ├── pages/              # CharactersPage, CreateCharacterPage
│   │   ├── services/           # characterService
│   │   └── index.ts
│   │
│   ├── gameplay/               # Игровой процесс
│   │   ├── components/         # GameInterface, ActionPanel
│   │   ├── hooks/              # useGameplay, useCombat
│   │   ├── pages/              # GameplayPage
│   │   └── services/           # gameplayService
│   │
│   └── inventory/              # Инвентарь
│       ├── components/         # InventoryGrid, ItemCard
│       ├── hooks/              # useInventory
│       ├── pages/              # InventoryPage
│       └── services/           # inventoryService
│
├── shared/                      # Общие компоненты и утилиты
│   ├── ui/                     # UI Kit компоненты
│   │   ├── Button/             # CyberpunkButton, NeonButton
│   │   ├── Card/               # CharacterCard, ItemCard
│   │   ├── Stats/              # HealthBar, ProgressBar
│   │   └── Combat/             # AbilityButton, DamageNumber
│   │
│   ├── hooks/                  # Переиспользуемые хуки
│   │   ├── useDebounce.ts
│   │   ├── useLocalStorage.ts
│   │   └── useRealtime.ts
│   │
│   ├── utils/                  # Утилиты
│   │   ├── validation.ts
│   │   ├── formatters.ts
│   │   └── constants.ts
│   │
│   ├── types/                  # Общие типы
│   │   └── index.ts
│   │
│   └── config/                 # Конфигурация
│       ├── api.ts
│       └── routes.ts
│
├── api/                         # Генерируемые API клиенты
│   └── generated/              # Orval генерирует сюда
│       ├── auth.ts
│       ├── characters.ts
│       ├── gameplay.ts
│       └── ...
│
├── theme/                       # Тема и стили
│   ├── cyberpunkTheme.ts
│   └── index.ts
│
├── styles/                      # Глобальные стили
│   └── index.css
│
├── App.tsx                      # Главный компонент
└── main.tsx                     # Точка входа
```

---

## Feature Module Structure

Каждый feature модуль следует единой структуре:

```
features/[feature-name]/
├── components/           # UI компоненты feature
│   ├── ComponentName/
│   │   ├── ComponentName.tsx
│   │   ├── ComponentName.test.tsx
│   │   └── index.ts
│   └── ...
│
├── hooks/               # Business logic хуки
│   ├── useFeature.ts
│   ├── useFeature.test.ts
│   └── ...
│
├── pages/               # Страницы (роуты)
│   ├── PageName.tsx
│   └── ...
│
├── services/            # API calls
│   ├── featureService.ts
│   └── ...
│
├── types/               # Feature-specific types
│   └── index.ts
│
└── index.ts             # Public API экспорт
```

**Принцип:** Каждый feature - это self-contained модуль, который экспортирует только необходимый public API.

---

## Планируемая модульная структура (Production)

```
FRONT-WEB/src/
├── core/                        # Ядро приложения
│   ├── module-loader/          # Dynamic module loading
│   ├── event-bus/              # Inter-module communication
│   ├── api-gateway/            # API client wrapper
│   └── state-management/       # Global state setup
│
├── modules/                     # Доменные модули
│   ├── social/                 # Социальный модуль
│   │   ├── features/           # Social features
│   │   │   ├── chat/
│   │   │   ├── guilds/
│   │   │   ├── friends/
│   │   │   └── npcs/
│   │   ├── store/              # Module state
│   │   ├── api/                # Module API client
│   │   └── module.config.ts    # Module configuration
│   │
│   ├── economy/                # Экономический модуль
│   │   ├── features/
│   │   │   ├── trading/
│   │   │   ├── auction/
│   │   │   ├── crafting/
│   │   │   └── market/
│   │   ├── store/
│   │   └── module.config.ts
│   │
│   ├── combat/                 # Боевой модуль
│   │   ├── features/
│   │   │   ├── abilities/
│   │   │   ├── weapons/
│   │   │   └── combos/
│   │   └── module.config.ts
│   │
│   └── world/                  # Мировой модуль
│       ├── features/
│       │   ├── locations/
│       │   ├── events/
│       │   └── extraction/
│       └── module.config.ts
│
└── shared/                      # Shared resources
```

**Модули по доменам:**

| Модуль | Features | API маршруты | Lazy Load |
|--------|----------|--------------|-----------|
| **social** | Чат, гильдии, друзья, NPC | `/api/v1/social/*` | ✅ Да |
| **economy** | Торговля, аукцион, биржа | `/api/v1/economy/*` | ✅ Да |
| **combat** | Бой, способности, комбо | `/api/v1/gameplay/combat/*` | ✅ Да |
| **world** | Локации, события, экстракция | `/api/v1/world/*` | ✅ Да |

---

## Управление состоянием

### 1. Глобальное состояние (Zustand)

**Назначение:** Состояние, нужное всему приложению

```typescript
// app/store.ts
import create from 'zustand';

// Auth Store
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: null,
  login: (user, token) => set({ user, token }),
  logout: () => set({ user: null, token: null }),
}));

// Character Store
export const useCharacterStore = create<CharacterState>((set) => ({
  selectedCharacter: null,
  selectCharacter: (character) => set({ selectedCharacter: character }),
}));

// UI Store
export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
}));
```

**Использование:**
```typescript
function GameHeader() {
  const user = useAuthStore((state) => state.user);
  const selectedCharacter = useCharacterStore((state) => state.selectedCharacter);
  
  return (
    <header>
      <span>{user?.username}</span>
      <span>{selectedCharacter?.name}</span>
    </header>
  );
}
```

---

### 2. Серверное состояние (React Query)

**Назначение:** Кэширование и синхронизация API данных

```typescript
// hooks/useCharacters.ts
import { useQuery, useMutation } from '@tanstack/react-query';
import { characterService } from '../services/characterService';

export function useCharacters() {
  return useQuery({
    queryKey: ['characters'],
    queryFn: characterService.getAll,
    staleTime: 5 * 60 * 1000, // 5 минут
  });
}

export function useCreateCharacter() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: characterService.create,
    onSuccess: () => {
      // Invalidate и refetch
      queryClient.invalidateQueries({ queryKey: ['characters'] });
    },
  });
}
```

**Использование:**
```typescript
function CharacterList() {
  const { data: characters, isLoading, error } = useCharacters();
  const createCharacter = useCreateCharacter();
  
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  
  return (
    <>
      {characters.map(char => <CharacterCard key={char.id} character={char} />)}
      <CreateButton onClick={() => createCharacter.mutate(newCharData)} />
    </>
  );
}
```

---

### 3. Локальное состояние (useState)

**Назначение:** Состояние компонента

```typescript
function SearchBar() {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);
  
  return (
    <input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      placeholder="Search..."
    />
  );
}
```

---

## Роутинг (React Router)

### Структура роутов

```typescript
// app/router.tsx
import { createBrowserRouter } from 'react-router-dom';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    children: [
      {
        index: true,
        element: <Navigate to="/characters" />,
      },
      {
        path: 'login',
        element: <LoginPage />,
      },
      {
        path: 'register',
        element: <RegisterPage />,
      },
      {
        path: 'characters',
        element: <ProtectedRoute><CharactersLayout /></ProtectedRoute>,
        children: [
          {
            index: true,
            element: <CharacterListPage />,
          },
          {
            path: 'create',
            element: <CharacterCreationPage />,
          },
          {
            path: ':id',
            element: <CharacterDetailsPage />,
          },
        ],
      },
      {
        path: 'gameplay/:characterId',
        element: <ProtectedRoute><GameplayPage /></ProtectedRoute>,
      },
      {
        path: 'inventory',
        element: <ProtectedRoute><InventoryPage /></ProtectedRoute>,
      },
    ],
  },
]);
```

### Защищенные роуты

```typescript
function ProtectedRoute({ children }: { children: ReactNode }) {
  const token = useAuthStore((state) => state.token);
  
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
}
```

---

## API Integration

### 1. Генерация клиентов (Orval)

**Конфигурация:**
```typescript
// orval.config.ts
export default {
  necpgame: {
    input: '../API-SWAGGER/api/v1/openapi.yaml',
    output: {
      target: './src/api/generated/api.ts',
      client: 'react-query',
      mode: 'tags-split',
    },
  },
};
```

**Генерация:**
```bash
npm run generate:api
```

**Результат:**
```typescript
// src/api/generated/auth.ts (автогенерировано)
export function useAuthLogin(options) {
  return useMutation({
    mutationFn: (data) => axios.post('/api/v1/auth/login', data),
    ...options,
  });
}
```

---

### 2. API Client Setup

```typescript
// shared/config/api.ts
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL, // http://localhost:8080
  timeout: 10000,
});

// Interceptor для токена
apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor для ошибок
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Logout при 401
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

---

### 3. Подключение к микросервисам через API Gateway

**Все запросы идут через API Gateway:**

```
Frontend (localhost:3000)
    │
    │ HTTP/REST
    ▼
API Gateway (localhost:8080)
    │
    ├─→ auth-service (8081)       /api/v1/auth/*
    ├─→ character-service (8082)  /api/v1/characters/*
    ├─→ gameplay-service (8083)   /api/v1/gameplay/*
    ├─→ social-service (8084)     /api/v1/social/*
    ├─→ economy-service (8085)    /api/v1/economy/*
    └─→ world-service (8086)      /api/v1/world/*
```

**Пример:**
```typescript
// Frontend делает запрос
const response = await axios.post('http://localhost:8080/api/v1/auth/login', {
  username: 'player1',
  password: 'pass123',
});

// API Gateway маршрутизирует на auth-service (8081)
// auth-service обрабатывает и возвращает результат
// API Gateway возвращает результат фронтенду
```

---

## WebSocket для Real-Time

### Подключение

```typescript
// shared/hooks/useRealtime.ts
import { useEffect } from 'react';
import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';

export function useRealtime(topic: string, onMessage: (msg: any) => void) {
  useEffect(() => {
    const client = new Client({
      webSocketFactory: () => new SockJS('http://localhost:8080/ws'),
      onConnect: () => {
        client.subscribe(topic, (message) => {
          onMessage(JSON.parse(message.body));
        });
      },
    });
    
    client.activate();
    
    return () => client.deactivate();
  }, [topic, onMessage]);
}
```

### Использование

```typescript
function GameplayComponent() {
  const characterId = useCharacterStore((state) => state.selectedCharacter?.id);
  
  useRealtime(`/topic/character/${characterId}/combat`, (event) => {
    // Обновить UI при combat событиях
    console.log('Combat event:', event);
  });
  
  return <div>Gameplay...</div>;
}
```

---

## Event Bus (для модулей)

### Реализация

```typescript
// core/event-bus/EventBus.ts
type EventCallback = (data: any) => void;

class EventBus {
  private events = new Map<string, EventCallback[]>();
  
  subscribe(event: string, callback: EventCallback) {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }
    this.events.get(event)!.push(callback);
    
    // Return unsubscribe function
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
}

export const eventBus = new EventBus();
```

### Использование между модулями

```typescript
// modules/combat/hooks/useCombat.ts
import { eventBus } from '@/core/event-bus';

export function useCombat() {
  const killEnemy = (enemyId: string, experience: number) => {
    // Combat logic...
    
    // Publish event для других модулей
    eventBus.publish('combat:enemy-killed', {
      enemyId,
      experience,
      timestamp: Date.now(),
    });
  };
  
  return { killEnemy };
}

// modules/progression/hooks/useProgression.ts
export function useProgression() {
  useEffect(() => {
    // Subscribe to combat events
    const unsubscribe = eventBus.subscribe('combat:enemy-killed', (data) => {
      // Add experience to character
      addExperience(data.experience);
    });
    
    return unsubscribe;
  }, []);
}
```

---

## Lazy Loading (для Production)

### Dynamic Import

```typescript
// app/router.tsx
const AuctionModule = lazy(() => import('@/modules/economy/auction'));
const ChatModule = lazy(() => import('@/modules/social/chat'));

<Route
  path="auction"
  element={
    <Suspense fallback={<ModuleLoading />}>
      <AuctionModule />
    </Suspense>
  }
/>
```

### Code Splitting

```typescript
// Автоматический code splitting по роутам
// Каждый роут = отдельный chunk

// вместо одного bundle.js (~5MB)
// получаем:
// - main.js (100KB) - ядро
// - auth.js (50KB) - auth feature
// - characters.js (200KB) - characters feature
// - gameplay.js (1MB) - gameplay feature (загружается только при входе в игру)
```

---

## Связанные документы

- [FRONT-WEB/ARCHITECTURE.md](../../FRONT-WEB/ARCHITECTURE.md) - детальная архитектура из репозитория
- [ФРОНТТАСК-MODULES.md](../../FRONT-WEB/docs/ФРОНТТАСК-MODULES.md) - модульная архитектура
- [frontend-modules-overview.md](./frontend-modules-overview.md) - детали модулей (будет создан)
- [ui-kit-overview.md](./ui-kit-overview.md) - UI компоненты (будет создан)

---

## История изменений

- v1.0.0 (2025-11-07) - Создан обзор фронтенд архитектуры

