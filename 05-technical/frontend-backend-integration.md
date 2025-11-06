---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Интеграция фронтенда и бекенда для веб-версии. API calls, WebSocket, state management, caching, asset delivery, authentication flow.
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-163: api/docs/frontend-integration.md (2025-11-07 11:30)
- Last Updated: 2025-11-07 00:18
---



# Frontend-Backend Integration - Интеграция веб-фронтенда с бекендом

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ (для веб-версии)  
**Автор:** AI Brain Manager

---

## Краткое описание

**Frontend-Backend Integration** - документ о том, как веб-фронтенд (React/Next.js) интегрируется с backend (Java Spring Boot) для текстовой версии игры NECPGAME.

**Ключевые аспекты:**
- ✅ API Communication (REST + WebSocket)
- ✅ Authentication flow (JWT tokens)
- ✅ State Management (Redux/Zustand)
- ✅ Caching Strategy (React Query)
- ✅ Real-Time Updates (WebSocket)
- ✅ Asset Delivery (CDN, static assets)
- ✅ Error Handling (client-side)

---

## Technology Stack

### Frontend
- **Framework:** React 18+ with Next.js 14+ (SSR + SSG)
- **Language:** TypeScript
- **State Management:** Zustand или Redux Toolkit
- **API Client:** Axios + React Query (для caching)
- **WebSocket:** Socket.IO client или native WebSocket
- **UI Library:** Tailwind CSS + shadcn/ui
- **Forms:** React Hook Form + Zod validation

### Backend
- **Framework:** Java Spring Boot 3.x
- **API:** REST (Spring Web) + WebSocket (Spring WebSocket/STOMP)
- **Security:** Spring Security + JWT
- **Database:** PostgreSQL + Redis

---

## Authentication Flow (Frontend)

### Login Process

```typescript
// frontend/src/services/authService.ts

import axios from 'axios';

const API_BASE = process.env.NEXT_PUBLIC_API_URL;

export interface LoginRequest {
  email: string;
  password: string;
  twoFactorCode?: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  sessionToken: string;
  account: {
    id: string;
    username: string;
    email: string;
    roles: string[];
  };
}

export async function login(credentials: LoginRequest): Promise<LoginResponse> {
  const response = await axios.post<LoginResponse>(
    `${API_BASE}/api/v1/auth/login`,
    credentials
  );
  
  // Сохранить tokens
  localStorage.setItem('accessToken', response.data.accessToken);
  localStorage.setItem('refreshToken', response.data.refreshToken);
  localStorage.setItem('sessionToken', response.data.sessionToken);
  
  // Установить default header для будущих запросов
  axios.defaults.headers.common['Authorization'] = 
    `Bearer ${response.data.accessToken}`;
  
  return response.data;
}

export async function logout(): Promise<void> {
  const sessionToken = localStorage.getItem('sessionToken');
  
  try {
    await axios.post(`${API_BASE}/api/v1/auth/logout`, {
      sessionToken
    });
  } finally {
    // Очистить tokens даже если запрос failed
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('sessionToken');
    delete axios.defaults.headers.common['Authorization'];
  }
}
```

### Token Refresh (автоматический)

```typescript
// frontend/src/utils/axiosInterceptor.ts

import axios from 'axios';

// Interceptor для автоматического refresh токена
axios.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    // Если 401 и не retry еще
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        // Получить новый access token
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await axios.post('/api/v1/auth/refresh', {
          refreshToken
        });
        
        const newAccessToken = response.data.accessToken;
        localStorage.setItem('accessToken', newAccessToken);
        
        // Обновить header
        axios.defaults.headers.common['Authorization'] = 
          `Bearer ${newAccessToken}`;
        originalRequest.headers['Authorization'] = `Bearer ${newAccessToken}`;
        
        // Повторить original request
        return axios(originalRequest);
        
      } catch (refreshError) {
        // Refresh failed, redirect to login
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);
```

---

## WebSocket Connection (Frontend)

### Connect to WebSocket

```typescript
// frontend/src/services/websocketService.ts

import { Client, StompSubscription } from '@stomp/stompjs';

class WebSocketService {
  private client: Client | null = null;
  private subscriptions: Map<string, StompSubscription> = new Map();
  
  connect(sessionToken: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.client = new Client({
        brokerURL: process.env.NEXT_PUBLIC_WS_URL,
        connectHeaders: {
          Authorization: `Bearer ${sessionToken}`
        },
        
        onConnect: () => {
          console.log('WebSocket connected');
          resolve();
        },
        
        onStompError: (frame) => {
          console.error('WebSocket error:', frame);
          reject(new Error(frame.headers['message']));
        },
        
        reconnectDelay: 5000,
        heartbeatIncoming: 10000,
        heartbeatOutgoing: 10000
      });
      
      this.client.activate();
    });
  }
  
  subscribe(topic: string, callback: (message: any) => void): () => void {
    if (!this.client) {
      throw new Error('WebSocket not connected');
    }
    
    const subscription = this.client.subscribe(topic, (message) => {
      const data = JSON.parse(message.body);
      callback(data);
    });
    
    this.subscriptions.set(topic, subscription);
    
    // Return unsubscribe function
    return () => {
      subscription.unsubscribe();
      this.subscriptions.delete(topic);
    };
  }
  
  send(destination: string, body: any): void {
    if (!this.client) {
      throw new Error('WebSocket not connected');
    }
    
    this.client.publish({
      destination,
      body: JSON.stringify(body)
    });
  }
  
  disconnect(): void {
    if (this.client) {
      this.client.deactivate();
      this.client = null;
      this.subscriptions.clear();
    }
  }
}

export const wsService = new WebSocketService();
```

### Use WebSocket in Components

```typescript
// frontend/src/components/GameChat.tsx

import { useEffect, useState } from 'react';
import { wsService } from '@/services/websocketService';

export function GameChat() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const accountId = useAuthStore(state => state.account?.id);
  
  useEffect(() => {
    if (!accountId) return;
    
    // Subscribe to chat messages
    const unsubscribe = wsService.subscribe(
      `/topic/player/${accountId}/chat`,
      (message: ChatMessage) => {
        setMessages(prev => [...prev, message]);
      }
    );
    
    // Cleanup on unmount
    return unsubscribe;
  }, [accountId]);
  
  const sendMessage = (text: string) => {
    wsService.send('/app/chat/send', {
      channelType: 'GLOBAL',
      message: text
    });
  };
  
  return (
    <div className="chat-container">
      {/* Chat UI */}
    </div>
  );
}
```

---

## State Management (Frontend)

### Zustand Store Example

```typescript
// frontend/src/stores/characterStore.ts

import create from 'zustand';
import { persist } from 'zustand/middleware';

interface CharacterState {
  character: Character | null;
  inventory: InventoryData | null;
  
  // Actions
  setCharacter: (character: Character) => void;
  updateInventory: (inventory: InventoryData) => void;
  addItem: (item: Item) => void;
  removeItem: (itemId: string) => void;
}

export const useCharacterStore = create<CharacterState>()(
  persist(
    (set) => ({
      character: null,
      inventory: null,
      
      setCharacter: (character) => set({ character }),
      
      updateInventory: (inventory) => set({ inventory }),
      
      addItem: (item) => set((state) => ({
        inventory: state.inventory 
          ? { ...state.inventory, items: [...state.inventory.items, item] }
          : null
      })),
      
      removeItem: (itemId) => set((state) => ({
        inventory: state.inventory
          ? { 
              ...state.inventory, 
              items: state.inventory.items.filter(i => i.id !== itemId) 
            }
          : null
      }))
    }),
    {
      name: 'character-storage',
      partialize: (state) => ({
        character: state.character // Persist only character, not inventory
      })
    }
  )
);
```

---

## API Client с React Query

### Setup React Query

```typescript
// frontend/src/utils/queryClient.ts

import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000, // 1 minute
      cacheTime: 5 * 60 * 1000, // 5 minutes
      retry: 1,
      refetchOnWindowFocus: false
    }
  }
});
```

### Use Query Hooks

```typescript
// frontend/src/hooks/useCharacter.ts

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { characterService } from '@/services/characterService';

export function useCharacter(characterId: string) {
  return useQuery({
    queryKey: ['character', characterId],
    queryFn: () => characterService.getCharacter(characterId),
    enabled: !!characterId
  });
}

export function useCharacters() {
  return useQuery({
    queryKey: ['characters'],
    queryFn: () => characterService.getCharacters()
  });
}

export function useCreateCharacter() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: characterService.createCharacter,
    onSuccess: () => {
      // Invalidate characters list
      queryClient.invalidateQueries({ queryKey: ['characters'] });
    }
  });
}

export function useInventory(characterId: string) {
  return useQuery({
    queryKey: ['inventory', characterId],
    queryFn: () => inventoryService.getInventory(characterId),
    enabled: !!characterId,
    refetchInterval: 5000 // Обновлять каждые 5 секунд
  });
}
```

---

## Asset Delivery (CDN)

### Static Assets Structure

```
/public/
  /assets/
    /images/
      /items/          - Иконки предметов
      /characters/     - Портреты персонажей
      /ui/             - UI элементы
    /sounds/
      /effects/        - Звуковые эффекты
      /music/          - Музыка
    /fonts/            - Шрифты
    /icons/            - Иконки
```

### CDN Configuration (CloudFlare/Vercel)

```typescript
// next.config.js

module.exports = {
  images: {
    domains: ['cdn.necpgame.com'],
    loader: 'cloudflare',
    path: 'https://cdn.necpgame.com/'
  },
  
  assetPrefix: process.env.NODE_ENV === 'production' 
    ? 'https://cdn.necpgame.com'
    : '',
    
  // Enable image optimization
  images: {
    deviceSizes: [640, 750, 828, 1080, 1200],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    formats: ['image/webp']
  }
};
```

### Load Assets

```typescript
// frontend/src/utils/assetLoader.ts

const CDN_URL = process.env.NEXT_PUBLIC_CDN_URL;

export function getItemIconUrl(itemTemplateId: string): string {
  return `${CDN_URL}/assets/images/items/${itemTemplateId}.webp`;
}

export function getCharacterPortraitUrl(characterId: string): string {
  return `${CDN_URL}/assets/images/characters/${characterId}.webp`;
}

// Preload critical assets
export function preloadCriticalAssets() {
  const criticalAssets = [
    '/assets/ui/loading.webp',
    '/assets/ui/background.webp',
    // ...
  ];
  
  criticalAssets.forEach(asset => {
    const link = document.createElement('link');
    link.rel = 'preload';
    link.as = 'image';
    link.href = CDN_URL + asset;
    document.head.appendChild(link);
  });
}
```

---

## Server-Side Rendering (SSR) для SEO

### Next.js Pages

```typescript
// frontend/src/pages/characters/[id].tsx

import { GetServerSideProps } from 'next';
import { characterService } from '@/services/characterService';

interface CharacterPageProps {
  character: Character;
}

export default function CharacterPage({ character }: CharacterPageProps) {
  return (
    <div>
      <h1>{character.name}</h1>
      <p>Level {character.level} {character.class}</p>
      {/* ... */}
    </div>
  );
}

export const getServerSideProps: GetServerSideProps = async (context) => {
  const { id } = context.params!;
  
  try {
    // Fetch character на сервере (SSR)
    const character = await characterService.getCharacter(id as string);
    
    return {
      props: {
        character
      }
    };
  } catch (error) {
    return {
      notFound: true
    };
  }
};
```

---

## Real-Time Data Sync

### Sync Inventory Changes

```typescript
// frontend/src/hooks/useInventorySync.ts

import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { wsService } from '@/services/websocketService';

export function useInventorySync(characterId: string) {
  const queryClient = useQueryClient();
  
  useEffect(() => {
    if (!characterId) return;
    
    // Subscribe to inventory updates
    const unsubscribe = wsService.subscribe(
      `/topic/character/${characterId}/inventory`,
      (update: InventoryUpdateEvent) => {
        // Обновить кэш React Query
        queryClient.setQueryData(
          ['inventory', characterId],
          (old: InventoryData | undefined) => {
            if (!old) return old;
            
            switch (update.type) {
              case 'ITEM_ADDED':
                return {
                  ...old,
                  items: [...old.items, update.item]
                };
                
              case 'ITEM_REMOVED':
                return {
                  ...old,
                  items: old.items.filter(i => i.id !== update.itemId)
                };
                
              case 'ITEM_UPDATED':
                return {
                  ...old,
                  items: old.items.map(i => 
                    i.id === update.itemId ? { ...i, ...update.changes } : i
                  )
                };
                
              default:
                return old;
            }
          }
        );
      }
    );
    
    return unsubscribe;
  }, [characterId, queryClient]);
}
```

---

## Error Handling (Frontend)

### Axios Error Interceptor

```typescript
// frontend/src/utils/errorHandler.ts

import axios from 'axios';
import { toast } from 'sonner';

axios.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      const status = error.response.status;
      const message = error.response.data?.message || 'An error occurred';
      
      switch (status) {
        case 400:
          toast.error(`Bad Request: ${message}`);
          break;
        case 401:
          toast.error('Unauthorized. Please login.');
          // Token refresh handled in другом interceptor
          break;
        case 403:
          toast.error('Forbidden. Insufficient permissions.');
          break;
        case 404:
          toast.error('Not found.');
          break;
        case 409:
          toast.error(`Conflict: ${message}`);
          break;
        case 500:
          toast.error('Server error. Please try again later.');
          break;
        default:
          toast.error(message);
      }
    } else if (error.request) {
      toast.error('Network error. Check your connection.');
    }
    
    return Promise.reject(error);
  }
);
```

---

## Optimistic Updates

### Example: Equip Item

```typescript
// frontend/src/hooks/useEquipItem.ts

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { inventoryService } from '@/services/inventoryService';

export function useEquipItem(characterId: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ itemId, slot }: EquipItemRequest) =>
      inventoryService.equipItem(characterId, itemId, slot),
      
    // Optimistic update (до ответа сервера)
    onMutate: async ({ itemId, slot }) => {
      // Cancel ongoing queries
      await queryClient.cancelQueries({ queryKey: ['inventory', characterId] });
      
      // Snapshot current state
      const previousInventory = queryClient.getQueryData(['inventory', characterId]);
      
      // Optimistically update
      queryClient.setQueryData(['inventory', characterId], (old: InventoryData) => {
        const item = old.items.find(i => i.id === itemId);
        if (!item) return old;
        
        return {
          ...old,
          items: old.items.map(i => 
            i.id === itemId 
              ? { ...i, storageType: 'EQUIPPED', equipmentSlot: slot }
              : i
          ),
          equipment: {
            ...old.equipment,
            [slot]: item
          }
        };
      });
      
      return { previousInventory };
    },
    
    // Rollback on error
    onError: (err, variables, context) => {
      queryClient.setQueryData(
        ['inventory', characterId],
        context.previousInventory
      );
      toast.error('Failed to equip item');
    },
    
    // Refetch on success (для server-side validation)
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['inventory', characterId] });
      toast.success('Item equipped');
    }
  });
}
```

---

## Performance Optimization (Frontend)

### Code Splitting

```typescript
// frontend/src/app/game/page.tsx

import dynamic from 'next/dynamic';

// Lazy load heavy components
const GameMap = dynamic(() => import('@/components/GameMap'), {
  loading: () => <div>Loading map...</div>,
  ssr: false // Don't render on server
});

const Inventory = dynamic(() => import('@/components/Inventory'), {
  loading: () => <div>Loading inventory...</div>
});

export default function GamePage() {
  return (
    <div>
      <GameMap />
      <Inventory />
    </div>
  );
}
```

### Image Optimization

```typescript
// frontend/src/components/ItemIcon.tsx

import Image from 'next/image';
import { getItemIconUrl } from '@/utils/assetLoader';

interface ItemIconProps {
  itemTemplateId: string;
  size?: number;
}

export function ItemIcon({ itemTemplateId, size = 64 }: ItemIconProps) {
  return (
    <Image
      src={getItemIconUrl(itemTemplateId)}
      alt={itemTemplateId}
      width={size}
      height={size}
      loading="lazy"
      quality={85}
    />
  );
}
```

---

## Связанные документы

### Backend
- `.BRAIN/05-technical/backend/authentication-authorization-system.md`
- `.BRAIN/05-technical/backend/session-management-system.md`
- `.BRAIN/05-technical/backend-architecture-overview.md`

### Frontend
- `.BRAIN/05-technical/ui-main-game.md`
- `.BRAIN/05-technical/ui-character-creation.md`

---

## TODO

- [ ] Service Worker для offline support
- [ ] Progressive Web App (PWA) manifest
- [ ] Push notifications (browser API)
- [ ] IndexedDB для offline data
- [ ] Bundle size optimization

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Frontend-Backend Integration

