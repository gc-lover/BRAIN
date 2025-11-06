# UI Game Start - Part 2: Server & Character Selection

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:01  
**Часть:** 2 из 2

[← Part 1](./part1-landing-auth.md) | [Навигация](./README.md)

---

## Server Selection

```
┌──────────────────────────────────────────┐
│         Select Server                     │
├──────────────────────────────────────────┤
│                                          │
│  [Server 1]  Night City Main             │
│  Players: 5432/10000  ●●●●○ (High)       │
│  Region: US East                         │
│  [Play]                                  │
│                                          │
│  [Server 2]  Badlands RP                 │
│  Players: 1200/5000   ●●○○○ (Medium)     │
│  Region: US West                         │
│  [Play]                                  │
│                                          │
└──────────────────────────────────────────┘
```

**Info displayed:**
- Server name
- Population (current/max)
- Load indicator
- Region
- Server type (PvE, PvP, RP)

**Selection:**
- Click [Play] → Go to Character Selection

---

## Character Selection

```
┌──────────────────────────────────────────┐
│         Select Character                  │
├──────────────────────────────────────────┤
│                                          │
│  ┌────────┐  ┌────────┐  ┌────────┐     │
│  │   V    │  │ Johnny │  │  [+]   │     │
│  │ Lvl 5  │  │ Lvl 3  │  │ Create │     │
│  │ Corpo  │  │ Street │  │  New   │     │
│  └────────┘  └────────┘  └────────┘     │
│   [Play]     [Play]      [Create]       │
│   [Delete]   [Delete]                    │
│                                          │
└──────────────────────────────────────────┘
```

**Display:**
- Character cards (portrait, name, level, origin)
- [Play] button for existing characters
- [Delete] button (confirmation dialog)
- [+ Create New] slot (если есть место)

**Max characters:** 3-5 per server

**Actions:**
- Click [Play] → Enter game
- Click [Delete] → Confirm → Delete character
- Click [Create New] → Go to Character Creation

---

## Character Creation (Brief)

**Linked to:**
- See [UI Character Creation](../ui-character-creation.md) for full details

**Flow:**
1. Choose Origin (Corpo, Nomad, Street Kid)
2. Customize appearance (optional for MVP)
3. Allocate attribute points
4. Enter name
5. Create → Enter game

---

## Связанные документы

- [UI Character Creation](../ui-character-creation.md)
- [UI Main Game](../ui-main-game/README.md)
- [Authentication System](../backend/authentication-authorization-system.md)

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:01) - Создан из ui-game-start.md

