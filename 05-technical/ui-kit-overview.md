# UI Kit Overview - Обзор библиотеки UI компонентов

**api-readiness:** not-applicable  
**api-readiness-check-date:** 2025-11-07  
**api-readiness-notes:** Техническая документация, описывает UI Kit, не для создания API

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07  
**Приоритет:** средний

---

## Описание

Обзор системы переиспользуемых UI компонентов (Design System) для NECPGAME. Описывает структуру UI Kit, базовые и игровые компоненты, киберпанк тему и использование.

---

## Текущая реализация

**Статус:** ✅ MVP - Material UI + кастомные компоненты в `shared/ui/`

**Подход:**
- Используем Material UI как базу
- Кастомные компоненты поверх MUI
- Киберпанк тема
- Переиспользуемые игровые компоненты

---

## Структура UI Kit

```
FRONT-WEB/src/shared/ui/
├── Button/                      # Кнопки
│   ├── Button.tsx              # Базовая кнопка (MUI)
│   ├── CyberpunkButton.tsx     # Киберпанк стиль
│   ├── NeonButton.tsx          # Неоновый эффект
│   └── GlitchButton.tsx        # Глитч эффект
│
├── Card/                        # Карточки
│   ├── Card.tsx                # Базовая карточка (MUI)
│   ├── CharacterCard.tsx       # Карточка персонажа
│   ├── ItemCard.tsx            # Карточка предмета
│   └── NPCCard.tsx             # Карточка NPC
│
├── Input/                       # Ввод
│   ├── TextField.tsx           # Текстовое поле
│   ├── SearchField.tsx         # Поле поиска
│   └── NumberInput.tsx         # Числовой ввод
│
├── Stats/                       # Игровые статы
│   ├── HealthBar.tsx           # Полоса здоровья
│   ├── ProgressBar.tsx         # Полоса прогресса
│   ├── StatBlock.tsx           # Блок со статами
│   ├── LevelIndicator.tsx      # Индикатор уровня
│   └── ExperienceBar.tsx       # Полоса опыта
│
├── Combat/                      # Боевые компоненты
│   ├── AbilityButton.tsx       # Кнопка способности
│   ├── CooldownTimer.tsx       # Таймер перезарядки
│   ├── DamageNumber.tsx        # Всплывающий урон
│   └── CombatLog.tsx           # Лог боя
│
├── Inventory/                   # Инвентарь компоненты
│   ├── InventoryGrid.tsx       # Сетка инвентаря
│   ├── InventorySlot.tsx       # Слот в инвентаре
│   └── ItemTooltip.tsx         # Тултип предмета
│
├── Navigation/                  # Навигация
│   ├── Sidebar.tsx             # Боковая панель
│   ├── Header.tsx              # Шапка
│   ├── Footer.tsx              # Подвал
│   └── TabNavigation.tsx       # Табы
│
├── Feedback/                    # Обратная связь
│   ├── LoadingSpinner.tsx      # Спиннер загрузки
│   ├── Notification.tsx        # Уведомление
│   ├── Toast.tsx               # Тост
│   └── ErrorBoundary.tsx       # Ошибка boundary
│
└── Layout/                      # Layouts
    ├── GameLayout.tsx          # Layout игры
    ├── AuthLayout.tsx          # Layout авторизации
    └── CenteredLayout.tsx      # Centered layout
```

---

## Design System - Cyberpunk тема

### Цветовая палитра

```typescript
// theme/cyberpunkTheme.ts
export const cyberpunkColors = {
  // Primary (Neon Blue)
  neonBlue: '#00F0FF',
  neonBlueDark: '#00A8B5',
  neonBlueLight: '#66F6FF',
  
  // Secondary (Neon Pink)
  neonPink: '#FF006E',
  neonPinkDark: '#B3004D',
  neonPinkLight: '#FF5CA8',
  
  // Accent (Neon Green)
  neonGreen: '#39FF14',
  neonGreenDark: '#28B30F',
  neonGreenLight: '#7AFF5C',
  
  // Neutrals
  darkGray: '#1F2937',
  mediumGray: '#374151',
  lightGray: '#9CA3AF',
  
  // Backgrounds
  backgroundDark: '#0F1419',
  backgroundMedium: '#1A202C',
  backgroundLight: '#2D3748',
  
  // Status
  success: '#39FF14',
  error: '#FF006E',
  warning: '#FFB800',
  info: '#00F0FF',
};
```

### Типография

```typescript
export const typography = {
  // Заголовки
  headingFont: '"Rajdhani", sans-serif',
  headingWeight: 700,
  
  // Основной текст
  bodyFont: '"Share Tech Mono", monospace',
  bodyWeight: 400,
  
  // UI элементы
  uiFont: '"Orbitron", sans-serif',
  uiWeight: 500,
  
  // Размеры
  sizes: {
    h1: '3rem',      // 48px
    h2: '2.25rem',   // 36px
    h3: '1.875rem',  // 30px
    h4: '1.5rem',    // 24px
    body: '1rem',    // 16px
    small: '0.875rem', // 14px
  },
};
```

### Эффекты

**Neon Glow:**
```css
.neon-glow {
  box-shadow: 
    0 0 5px var(--neon-color),
    0 0 10px var(--neon-color),
    0 0 20px var(--neon-color);
  
  transition: box-shadow 0.3s ease;
}

.neon-glow:hover {
  box-shadow: 
    0 0 10px var(--neon-color),
    0 0 20px var(--neon-color),
    0 0 30px var(--neon-color);
}
```

**Glitch Effect:**
```css
@keyframes glitch {
  0% { transform: translate(0); }
  20% { transform: translate(-2px, 2px); }
  40% { transform: translate(-2px, -2px); }
  60% { transform: translate(2px, 2px); }
  80% { transform: translate(2px, -2px); }
  100% { transform: translate(0); }
}

.glitch-effect {
  animation: glitch 0.3s infinite;
}
```

**Scanlines:**
```css
.scanlines::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: repeating-linear-gradient(
    0deg,
    rgba(0, 0, 0, 0.15),
    rgba(0, 0, 0, 0.15) 1px,
    transparent 1px,
    transparent 2px
  );
  pointer-events: none;
}
```

---

## Базовые компоненты

### CyberpunkButton

```typescript
// shared/ui/Button/CyberpunkButton.tsx
import { Button, ButtonProps } from '@mui/material';
import { cyberpunkColors } from '@/theme/cyberpunkTheme';

interface CyberpunkButtonProps extends ButtonProps {
  variant?: 'neon' | 'glitch' | 'primary';
  glowColor?: string;
}

export function CyberpunkButton({
  variant = 'neon',
  glowColor = cyberpunkColors.neonBlue,
  children,
  ...props
}: CyberpunkButtonProps) {
  return (
    <Button
      className={`cyberpunk-btn ${variant}`}
      sx={{
        backgroundColor: 'transparent',
        border: `2px solid ${glowColor}`,
        color: glowColor,
        padding: '12px 24px',
        fontSize: '1rem',
        fontFamily: 'Orbitron',
        fontWeight: 600,
        textTransform: 'uppercase',
        transition: 'all 0.3s ease',
        boxShadow: `0 0 10px ${glowColor}`,
        
        '&:hover': {
          backgroundColor: `${glowColor}22`,
          boxShadow: `0 0 20px ${glowColor}, 0 0 30px ${glowColor}`,
          transform: 'translateY(-2px)',
        },
      }}
      {...props}
    >
      {children}
      
      {variant === 'glitch' && (
        <>
          <span className="glitch-layer" aria-hidden="true">
            {children}
          </span>
          <span className="glitch-layer" aria-hidden="true">
            {children}
          </span>
        </>
      )}
    </Button>
  );
}
```

**Использование:**
```typescript
<CyberpunkButton variant="neon" glowColor="#00F0FF">
  Войти
</CyberpunkButton>

<CyberpunkButton variant="glitch" onClick={handleAttack}>
  Атаковать
</CyberpunkButton>
```

---

## Игровые компоненты

### HealthBar

```typescript
// shared/ui/Stats/HealthBar.tsx
import { Box, LinearProgress, Typography } from '@mui/material';
import { cyberpunkColors } from '@/theme/cyberpunkTheme';

interface HealthBarProps {
  current: number;
  max: number;
  showNumbers?: boolean;
  size?: 'small' | 'medium' | 'large';
}

export function HealthBar({
  current,
  max,
  showNumbers = true,
  size = 'medium',
}: HealthBarProps) {
  const percent = (current / max) * 100;
  const height = size === 'small' ? 8 : size === 'medium' ? 12 : 20;
  
  return (
    <Box sx={{ width: '100%' }}>
      <LinearProgress
        variant="determinate"
        value={percent}
        sx={{
          height,
          backgroundColor: cyberpunkColors.backgroundDark,
          borderRadius: '4px',
          border: `1px solid ${cyberpunkColors.neonPink}`,
          
          '& .MuiLinearProgress-bar': {
            background: `linear-gradient(90deg, ${cyberpunkColors.neonPink}, ${cyberpunkColors.neonBlue})`,
            boxShadow: `0 0 10px ${cyberpunkColors.neonBlue}`,
            transition: 'transform 0.3s ease',
          },
        }}
      />
      
      {showNumbers && (
        <Typography
          variant="caption"
          sx={{
            color: cyberpunkColors.lightGray,
            fontFamily: 'Share Tech Mono',
            marginTop: '4px',
            display: 'block',
          }}
        >
          {current} / {max} HP
        </Typography>
      )}
    </Box>
  );
}
```

**Использование:**
```typescript
<HealthBar current={75} max={100} />
<HealthBar current={250} max={500} size="large" showNumbers />
```

---

### CharacterCard

```typescript
// shared/ui/Card/CharacterCard.tsx
import { Card, CardContent, CardActions, Typography, Button } from '@mui/material';
import { Character } from '@/api/generated/characters';
import { HealthBar } from '../Stats/HealthBar';
import { LevelIndicator } from '../Stats/LevelIndicator';

interface CharacterCardProps {
  character: Character;
  onSelect?: (character: Character) => void;
  onDelete?: (character: Character) => void;
}

export function CharacterCard({
  character,
  onSelect,
  onDelete,
}: CharacterCardProps) {
  return (
    <Card
      className="character-card"
      sx={{
        backgroundColor: cyberpunkColors.backgroundMedium,
        border: `1px solid ${cyberpunkColors.neonBlue}`,
        borderRadius: '8px',
        padding: '16px',
        transition: 'all 0.3s ease',
        
        '&:hover': {
          boxShadow: `0 0 20px ${cyberpunkColors.neonBlue}`,
          transform: 'translateY(-4px)',
        },
      }}
    >
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
          <Typography variant="h5" sx={{ color: cyberpunkColors.neonBlue }}>
            {character.name}
          </Typography>
          <LevelIndicator level={character.level} />
        </Box>
        
        <Typography variant="body2" sx={{ color: cyberpunkColors.lightGray, mb: 1 }}>
          {character.origin} - {character.lifepath}
        </Typography>
        
        <HealthBar
          current={character.currentHealth}
          max={character.maxHealth}
          size="small"
        />
        
        <Box sx={{ mt: 2 }}>
          <Typography variant="caption" sx={{ color: cyberpunkColors.lightGray }}>
            Location: {character.location}
          </Typography>
        </Box>
      </CardContent>
      
      <CardActions>
        {onSelect && (
          <CyberpunkButton
            size="small"
            variant="neon"
            onClick={() => onSelect(character)}
          >
            Select
          </CyberpunkButton>
        )}
        {onDelete && (
          <CyberpunkButton
            size="small"
            variant="neon"
            glowColor={cyberpunkColors.neonPink}
            onClick={() => onDelete(character)}
          >
            Delete
          </CyberpunkButton>
        )}
      </CardActions>
    </Card>
  );
}
```

**Использование:**
```typescript
<CharacterCard
  character={character}
  onSelect={handleSelect}
  onDelete={handleDelete}
/>
```

---

### AbilityButton

```typescript
// shared/ui/Combat/AbilityButton.tsx
import { IconButton, Tooltip, Box } from '@mui/material';
import { Ability } from '@/api/generated/gameplay';
import { CooldownTimer } from './CooldownTimer';

interface AbilityButtonProps {
  ability: Ability;
  cooldownRemaining?: number;
  disabled?: boolean;
  onClick?: () => void;
}

export function AbilityButton({
  ability,
  cooldownRemaining = 0,
  disabled = false,
  onClick,
}: AbilityButtonProps) {
  const isOnCooldown = cooldownRemaining > 0;
  
  return (
    <Tooltip title={ability.description}>
      <Box sx={{ position: 'relative', display: 'inline-block' }}>
        <IconButton
          disabled={disabled || isOnCooldown}
          onClick={onClick}
          sx={{
            width: 60,
            height: 60,
            border: `2px solid ${cyberpunkColors.neonGreen}`,
            backgroundColor: cyberpunkColors.backgroundDark,
            backgroundImage: `url(${ability.iconUrl})`,
            backgroundSize: 'cover',
            opacity: isOnCooldown ? 0.5 : 1,
            
            '&:hover': {
              boxShadow: `0 0 15px ${cyberpunkColors.neonGreen}`,
            },
          }}
        />
        
        {isOnCooldown && (
          <CooldownTimer
            totalSeconds={ability.cooldownSeconds}
            remainingSeconds={cooldownRemaining}
          />
        )}
        
        <Typography
          sx={{
            position: 'absolute',
            bottom: -20,
            left: 0,
            right: 0,
            textAlign: 'center',
            fontSize: '0.75rem',
            color: cyberpunkColors.lightGray,
          }}
        >
          {ability.hotkey}
        </Typography>
      </Box>
    </Tooltip>
  );
}
```

---

## Game Forms (готовые формы)

### CharacterCreationForm

```typescript
// shared/ui/Forms/CharacterCreationForm.tsx
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { TextField, Select, MenuItem } from '@mui/material';
import { CyberpunkButton } from '../Button/CyberpunkButton';

const schema = yup.object({
  name: yup.string().required('Name is required').min(3).max(20),
  origin: yup.string().required('Origin is required'),
  lifepath: yup.string().required('Lifepath is required'),
  attributes: yup.object({
    body: yup.number().min(1).max(10).required(),
    intelligence: yup.number().min(1).max(10).required(),
    reflex: yup.number().min(1).max(10).required(),
    technical: yup.number().min(1).max(10).required(),
    cool: yup.number().min(1).max(10).required(),
  }),
});

interface CharacterCreationFormProps {
  onSubmit: (data: CharacterFormData) => void;
  onCancel: () => void;
}

export function CharacterCreationForm({
  onSubmit,
  onCancel,
}: CharacterCreationFormProps) {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: yupResolver(schema),
  });
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <TextField
        {...register('name')}
        label="Character Name"
        error={!!errors.name}
        helperText={errors.name?.message}
        fullWidth
        margin="normal"
      />
      
      <Select
        {...register('origin')}
        label="Origin"
        fullWidth
        margin="dense"
      >
        <MenuItem value="Corpo">Corpo</MenuItem>
        <MenuItem value="Nomad">Nomad</MenuItem>
        <MenuItem value="Street Kid">Street Kid</MenuItem>
      </Select>
      
      {/* Attributes... */}
      
      <Box sx={{ mt: 3, display: 'flex', gap: 2 }}>
        <CyberpunkButton type="submit" variant="neon">
          Create Character
        </CyberpunkButton>
        <CyberpunkButton
          variant="neon"
          glowColor={cyberpunkColors.neonPink}
          onClick={onCancel}
        >
          Cancel
        </CyberpunkButton>
      </Box>
    </form>
  );
}
```

---

## Переиспользуемые хуки

### useDebounce

```typescript
// shared/hooks/useDebounce.ts
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delay: number = 300): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    
    return () => clearTimeout(timer);
  }, [value, delay]);
  
  return debouncedValue;
}
```

### useLocalStorage

```typescript
// shared/hooks/useLocalStorage.ts
import { useState } from 'react';

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });
  
  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };
  
  return [storedValue, setValue] as const;
}
```

---

## Планируемая Production структура

### Monorepo с пакетами

```
packages/
├── @necpgame/ui-kit/               # Базовые компоненты
│   ├── Button/
│   ├── Card/
│   ├── Input/
│   └── ...
│
├── @necpgame/theme-cyberpunk/      # Киберпанк тема
│   ├── colors.ts
│   ├── typography.ts
│   ├── effects.ts
│   └── theme.ts
│
├── @necpgame/game-components/      # Игровые компоненты
│   ├── Stats/
│   ├── Combat/
│   ├── Inventory/
│   └── ...
│
├── @necpgame/game-forms/           # Готовые формы
│   ├── CharacterCreationForm/
│   ├── TradeForm/
│   ├── AuctionBidForm/
│   └── ...
│
└── @necpgame/game-hooks/           # Переиспользуемые хуки
    ├── useDebounce.ts
    ├── useLocalStorage.ts
    ├── useCharacter.ts
    └── ...
```

### Использование из пакетов

```typescript
// Из разных приложений можем использовать одинаковые компоненты
import { CyberpunkButton } from '@necpgame/ui-kit';
import { cyberpunkTheme } from '@necpgame/theme-cyberpunk';
import { HealthBar, AbilityButton } from '@necpgame/game-components';
import { CharacterCreationForm } from '@necpgame/game-forms';
import { useCharacter } from '@necpgame/game-hooks';
```

---

## Storybook для документации

### Настройка Storybook

```bash
npm install --save-dev @storybook/react @storybook/addon-essentials
```

### Пример Story

```typescript
// shared/ui/Button/CyberpunkButton.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { CyberpunkButton } from './CyberpunkButton';

const meta: Meta<typeof CyberpunkButton> = {
  title: 'UI/Button/CyberpunkButton',
  component: CyberpunkButton,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof CyberpunkButton>;

export const Neon: Story = {
  args: {
    variant: 'neon',
    children: 'Neon Button',
  },
};

export const Glitch: Story = {
  args: {
    variant: 'glitch',
    children: 'Glitch Button',
  },
};
```

---

## Связанные документы

- [frontend-architecture-overview.md](./frontend-architecture-overview.md) - общая архитектура фронтенда
- [ФРОНТТАСК-LIBRARIES.md](../../FRONT-WEB/docs/ФРОНТТАСК-LIBRARIES.md) - библиотеки из FRONT-WEB
- [UI-KIT.md](../../FRONT-WEB/docs/libraries/UI-KIT.md) - детали UI Kit из FRONT-WEB
- [DESIGN-SYSTEM.md](../../FRONT-WEB/docs/libraries/DESIGN-SYSTEM.md) - Design System

---

## История изменений

- v1.0.0 (2025-11-07) - Создан обзор UI Kit и Design System

