# UI Character Creation - Part 2: Appearance & Finalization

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:14  
**Часть:** 2 из 2

[← Part 1](./part1-origin-attributes.md) | [Навигация](./README.md)

---

## Step 4: Customize Appearance (Optional для MVP)

```
┌─────────────────────────────────────────┐
│ Customize Appearance                    │
├─────────────────────────────────────────┤
│                                         │
│ Gender:  [Male] [Female] [Non-binary]   │
│                                         │
│ Body Type: [Slider: Slim ----●-- Strong│
│                                         │
│ Hair Style: [Dropdown: Mohawk ▾]        │
│                                         │
│ Hair Color: [Color Picker: ⬛️]         │
│                                         │
│ Skin Tone:  [Slider: ●---------]        │
│                                         │
│ [Use Default] [Randomize]               │
│                                         │
│ [Back] [Next: Name]                     │
└─────────────────────────────────────────┘
```

**Для MVP:** Можно пропустить и использовать дефолтный вид

---

## Step 5: Enter Name

```
┌─────────────────────────────────────────┐
│ Name Your Character                     │
├─────────────────────────────────────────┤
│                                         │
│ Character Name:                         │
│ [___________________________]           │
│                                         │
│ Validation:                             │
│ • 3-20 characters                       │
│ • Letters, numbers, spaces allowed      │
│ • Must be unique                        │
│                                         │
│ [Back] [Next: Review]                   │
└─────────────────────────────────────────┘
```

**Name Validation (Frontend):**

```javascript
function validateName(name) {
  if (name.length < 3 || name.length > 20) {
    return "Name must be 3-20 characters";
  }
  if (!/^[a-zA-Z0-9 ]+$/.test(name)) {
    return "Only letters, numbers, and spaces allowed";
  }
  // Check uniqueness via API
  const exists = await checkNameExists(name);
  if (exists) {
    return "Name already taken";
  }
  return null; // Valid
}
```

---

## Step 6: Review & Confirm

```
┌─────────────────────────────────────────┐
│ Review Your Character                   │
├─────────────────────────────────────────┤
│                                         │
│ Name: V                                 │
│ Origin: Corpo                           │
│ Lifepath: Corporate Rat                 │
│                                         │
│ Attributes:                             │
│ • Body: 5                               │
│ • Intelligence: 7 (+2 Corpo)            │
│ • Reflex: 6                             │
│ • Technical: 5 (+1 Lifepath)            │
│ • Cool: 4                               │
│                                         │
│ Derived Stats:                          │
│ • HP: 100                               │
│ • Energy: 55                            │
│ • Carry: 50                             │
│                                         │
│ [Back to Edit] [Create Character]       │
└─────────────────────────────────────────┘
```

---

## Create Character (API Call)

```javascript
async function createCharacter() {
  const characterData = {
    name: "V",
    origin: "Corpo",
    lifepath: "Corporate Rat",
    attributes: {
      body: 5,
      intelligence: 7,
      reflex: 6,
      technical: 5,
      cool: 4
    },
    appearance: {
      gender: "male",
      // ... other appearance data
    }
  };
  
  try {
    const response = await fetch('/api/v1/characters', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(characterData)
    });
    
    if (response.ok) {
      const character = await response.json();
      // Redirect to game
      window.location.href = '/game';
    } else {
      const error = await response.json();
      showError(error.message);
    }
  } catch (error) {
    showError("Failed to create character");
  }
}
```

---

## Validation Summary

**Client-side:**
- Name length (3-20)
- Name format (alphanumeric + spaces)
- Attributes sum (must equal 27)
- Attributes range (3-10 each)

**Server-side:**
- Name uniqueness
- Valid origin/lifepath combo
- Attribute values within bounds
- User has slot available (max 3-5 characters)

---

## Success Flow

```
1. Create Character button clicked
2. Show loading spinner
3. API call POST /api/v1/characters
4. Response 201 Created
5. Store character ID
6. Redirect to /game
7. Show welcome message: "Welcome to Night City, V!"
```

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:14) - Создан из ui-character-creation.md

