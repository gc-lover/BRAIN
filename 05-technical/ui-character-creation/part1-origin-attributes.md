# UI Character Creation - Part 1: Origin & Attributes

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:13  
**Часть:** 1 из 2

[Навигация](./README.md) | [Part 2 →](./part2-appearance-finalization.md)

---

## Step 1: Choose Origin

```
┌─────────────────────────────────────────┐
│ Choose Your Origin                      │
├─────────────────────────────────────────┤
│                                         │
│ ┌──────────────┐  ┌──────────────┐    │
│ │   Corpo      │  │   Nomad      │    │
│ │  [Image]     │  │  [Image]     │    │
│ │              │  │              │    │
│ │ Corporate    │  │ Desert       │    │
│ │ Agent        │  │ Wanderer     │    │
│ └──────────────┘  └──────────────┘    │
│                                         │
│ ┌──────────────┐                       │
│ │ Street Kid   │                       │
│ │  [Image]     │                       │
│ │              │                       │
│ │ Street       │                       │
│ │ Survivor     │                       │
│ └──────────────┘                       │
│                                         │
│ Selected: [Corpo]                       │
│                                         │
│ [Next: Lifepath]                        │
└─────────────────────────────────────────┘
```

**Origin Descriptions:**

- **Corpo:** Corporate agent. Start with business connections, high-tech equipment. Dialogue options for corpo situations.
- **Nomad:** Desert nomad. Start with vehicle, survival skills. Dialogue options for nomad situations.
- **Street Kid:** Street survivor. Start with street contacts, street smarts. Dialogue options for street situations.

---

## Step 2: Choose Lifepath

```
┌─────────────────────────────────────────┐
│ Choose Your Lifepath (Corpo)            │
├─────────────────────────────────────────┤
│                                         │
│ 🔹 Corporate Rat                        │
│    Started as low-level employee        │
│    Bonus: +2 Business, +1 Tech          │
│    [Select]                             │
│                                         │
│ 🔹 Security Specialist                  │
│    Corp security background             │
│    Bonus: +2 Combat, +1 Cool            │
│    [Select]                             │
│                                         │
│ 🔹 R&D Engineer                         │
│    Research & Development               │
│    Bonus: +2 Tech, +1 Intelligence      │
│    [Select]                             │
│                                         │
│ [Back] [Next: Attributes]               │
└─────────────────────────────────────────┘
```

**Each Origin has 3 unique Lifepaths**

---

## Step 3: Allocate Attributes

```
┌─────────────────────────────────────────┐
│ Allocate Attributes (27 points)         │
├─────────────────────────────────────────┤
│                                         │
│ Body:          [5] [-] [+]              │
│ Intelligence:  [7] [-] [+]  Corpo+2     │
│ Reflex:        [6] [-] [+]              │
│ Technical:     [5] [-] [+]  Lifepath+1  │
│ Cool:          [4] [-] [+]              │
│                                         │
│ Points remaining: 0 / 27                │
│                                         │
│ Min: 3, Max: 10 per attribute           │
│                                         │
│ [Back] [Next: Appearance]               │
└─────────────────────────────────────────┘
```

**Attribute Effects:**

- **Body:** HP, melee damage, carry capacity
- **Intelligence:** Hacking, quest options, XP gain
- **Reflex:** Dodge, ranged accuracy, initiative
- **Technical:** Crafting, tech options, item quality
- **Cool:** Stealth, charisma, romance options

---

## Derived Stats

```javascript
// Auto-calculated from attributes
const derivedStats = {
  maxHP: body * 10 + 50,
  maxEnergy: (intelligence + cool) * 5,
  carryCapacity: body * 10,
  critChance: reflex * 0.5 + "%",
  hackingSkill: intelligence + technical
};
```

---

[Part 2: Appearance & Finalization →](./part2-appearance-finalization.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:13) - Создан из ui-character-creation.md

