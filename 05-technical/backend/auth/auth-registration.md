---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Auth Registration микрофича. Регистрация email/password, OAuth, email verification. ~380 строк.
---

# Auth Registration - Регистрация аккаунтов

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:30  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Account registration  
**Размер:** ~380 строк ✅

---


**API Tasks Status:**
- 🚫 Документ отмечен как OBSOLETE (устаревшая split версия)
- 📝 Причина: Consolidated into unified document
- 🔄 Статус: not-applicable
- ⚠️ Этот документ является split версией, которая была объединена в consolidated документ

---

## Краткое описание

**Auth Registration** - регистрация новых аккаунтов (email/password + OAuth).

**Ключевые возможности:**
- ✅ Email/Password registration
- ✅ OAuth registration (Steam, Google, Discord)
- ✅ Email verification
- ✅ Username uniqueness check
- ✅ Password strength validation

---

## Database Schema

```sql
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Credentials
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255) NOT NULL,
    
    -- OAuth
    oauth_provider VARCHAR(50),
    oauth_id VARCHAR(255),
    oauth_data JSONB,
    
    -- Profile
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE',
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registration_ip VARCHAR(45),
    
    CONSTRAINT fk_account_banned_by FOREIGN KEY (banned_by) 
        REFERENCES accounts(id) ON DELETE SET NULL
);

CREATE INDEX idx_accounts_email ON accounts(email);
CREATE INDEX idx_accounts_username ON accounts(username);
```

### Таблица `email_verification_tokens`

```sql
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_verify_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);
```

---

## Email/Password Registration

```java
@Transactional
public RegisterResponse register(RegisterRequest request) {
    // 1. Валидация
    validateRegistration(request);
    
    // 2. Проверить уникальность
    if (accountRepository.existsByEmail(request.getEmail())) {
        throw new EmailAlreadyExistsException();
    }
    
    if (accountRepository.existsByUsername(request.getUsername())) {
        throw new UsernameAlreadyTakenException();
    }
    
    // 3. Хэшировать пароль
    String passwordHash = passwordEncoder.encode(request.getPassword());
    
    // 4. Создать аккаунт
    Account account = new Account();
    account.setEmail(request.getEmail());
    account.setPasswordHash(passwordHash);
    account.setUsername(request.getUsername());
    account.setRegistrationIp(getClientIp());
    
    account = accountRepository.save(account);
    
    // 5. Роль PLAYER
    assignRole(account.getId(), Role.PLAYER);
    
    // 6. Email verification
    String token = generateVerificationToken();
    saveVerificationToken(account.getId(), token);
    emailService.sendVerificationEmail(account.getEmail(), token);
    
    return new RegisterResponse(account.getId(), "Check your email");
}
```

---

## OAuth Registration

```java
public LoginResponse loginWithOAuth(OAuthProvider provider, String oauthCode) {
    // 1. Обменять code на token
    OAuthTokenResponse tokenResponse = provider.exchangeCodeForToken(oauthCode);
    
    // 2. Получить user info
    OAuthUserInfo userInfo = provider.getUserInfo(tokenResponse.getAccessToken());
    
    // 3. Найти или создать аккаунт
    Account account = accountRepository
        .findByOAuthProviderAndId(provider.name(), userInfo.getId())
        .orElseGet(() => createOAuthAccount(provider, userInfo));
    
    // 4. Создать JWT tokens
    String accessToken = jwtService.generateAccessToken(account);
    String refreshToken = jwtService.generateRefreshToken(account);
    
    return new LoginResponse(accessToken, refreshToken, account.toDTO());
}
```

---

## API Endpoints

**POST `/api/v1/auth/register`** - регистрация
**POST `/api/v1/auth/verify-email`** - подтвердить email
**POST `/api/v1/auth/resend-verification`** - переотправить письмо
**GET `/api/v1/auth/oauth/{provider}`** - OAuth flow
**GET `/api/v1/auth/oauth/{provider}/callback`** - OAuth callback

---

## Связанные документы

- `.BRAIN/05-technical/backend/auth/auth-login.md` - Login (микрофича 2/3)
- `.BRAIN/05-technical/backend/auth/auth-security.md` - Security (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Микрофича 1/3: Auth Registration (split from authentication-authorization-system.md)





