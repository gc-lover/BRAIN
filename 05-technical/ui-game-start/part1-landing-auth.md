# UI Game Start - Part 1: Landing & Auth

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:00  
**Часть:** 1 из 2

[Навигация](./README.md) | [Part 2 →](./part2-server-character.md)

---

## Landing Page

**Layout:**
```
┌─────────────────────────────────────────┐
│                                         │
│         NECPGAME                        │
│    Cyberpunk MMORPG                     │
│                                         │
│     [Login] [Register] [About]          │
│                                         │
│  • MMORPG + Shooter                     │
│  • Deep narrative                       │
│  • Player-driven world                  │
│                                         │
│     [Play Now]                          │
│                                         │
└─────────────────────────────────────────┘
```

**Компоненты:**
- Hero section (лого + tagline)
- CTA buttons (Login, Register, Play Now)
- Features preview
- News/Updates section
- Footer (links, social media)

---

## Login Screen

```
┌─────────────────────────────────────────┐
│         Login                           │
├─────────────────────────────────────────┤
│                                         │
│  Username: [__________________]         │
│  Password: [__________________]         │
│                                         │
│  [ ] Remember me                        │
│                                         │
│  [Login]    [Forgot Password?]          │
│                                         │
│  Don't have account? [Register]         │
│                                         │
└─────────────────────────────────────────┘
```

**Validation:**
- Username: required, 3-20 chars
- Password: required, min 8 chars
- Error messages (invalid credentials, etc)

**Процесс:**
1. Enter username + password
2. Click Login
3. API call `/api/v1/auth/login`
4. Receive JWT token
5. Redirect to Server Selection

---

## Registration Screen

```
┌─────────────────────────────────────────┐
│         Register                        │
├─────────────────────────────────────────┤
│                                         │
│  Email:    [__________________]         │
│  Username: [__________________]         │
│  Password: [__________________]         │
│  Confirm:  [__________________]         │
│                                         │
│  [x] I agree to Terms of Service        │
│                                         │
│  [Register]                             │
│                                         │
│  Have account? [Login]                  │
│                                         │
└─────────────────────────────────────────┘
```

**Validation:**
- Email: valid format, unique
- Username: 3-20 chars, alphanumeric + underscore, unique
- Password: min 8 chars, must contain letters + numbers
- Confirm: must match password
- ToS checkbox: required

**Процесс:**
1. Fill form
2. Click Register
3. API call `/api/v1/auth/register`
4. Email verification (optional)
5. Auto-login + redirect to Server Selection

---

[Part 2: Server & Character →](./part2-server-character.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:00) - Создан из ui-game-start.md

