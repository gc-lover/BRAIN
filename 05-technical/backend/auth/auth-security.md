---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:35  
**api-readiness-notes:** Auth Security микрофича. Password recovery, 2FA, roles/permissions, rate limiting. ~360 строк.
---

# Auth Security - Безопасность авторизации

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:35  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Security & permissions  
**Размер:** ~360 строк ✅

---

## Краткое описание

**Auth Security** - безопасность: password recovery, 2FA, roles, rate limiting.

**Ключевые возможности:**
- ✅ Password recovery (email reset)
- ✅ 2FA (TOTP)
- ✅ Roles & Permissions (RBAC)
- ✅ Rate limiting (login attempts)
- ✅ Account linking (Steam, Discord)

---

## Password Recovery

```sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_reset_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);
```

```java
@PostMapping("/auth/forgot-password")
public void forgotPassword(@RequestBody ForgotPasswordRequest request) {
    Account account = accountRepository.findByEmail(request.getEmail())
        .orElse(null);
    
    // Не раскрывать существование email (security)
    if (account == null) {
        return; // Молча игнорировать
    }
    
    // Создать reset token
    String token = UUID.randomUUID().toString();
    PasswordResetToken resetToken = new PasswordResetToken();
    resetToken.setAccountId(account.getId());
    resetToken.setToken(token);
    resetToken.setExpiresAt(Instant.now().plus(Duration.ofHours(1)));
    
    passwordResetRepository.save(resetToken);
    
    // Отправить email
    emailService.sendPasswordResetEmail(account.getEmail(), token);
}

@PostMapping("/auth/reset-password")
public void resetPassword(@RequestBody ResetPasswordRequest request) {
    PasswordResetToken resetToken = passwordResetRepository
        .findByToken(request.getToken())
        .orElseThrow(() -> new InvalidTokenException());
    
    if (resetToken.isUsed() || resetToken.isExpired()) {
        throw new InvalidTokenException();
    }
    
    // Обновить пароль
    Account account = accountRepository.findById(resetToken.getAccountId()).orElseThrow();
    account.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
    accountRepository.save(account);
    
    // Пометить token как использованный
    resetToken.setUsed(true);
    passwordResetRepository.save(resetToken);
    
    // Revoke все refresh tokens (force re-login)
    refreshTokenRepository.revokeAllForAccount(account.getId());
}
```

---

## Two-Factor Authentication (2FA)

```sql
CREATE TABLE two_factor_auth (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID UNIQUE NOT NULL,
    secret VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT FALSE,
    backup_codes JSONB, -- Array of backup codes
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_2fa_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);
```

```java
@PostMapping("/auth/2fa/enable")
public Enable2FAResponse enable2FA(@RequestHeader("Authorization") String token) {
    UUID accountId = extractAccountId(token);
    
    // Создать TOTP secret
    String secret = generateTOTPSecret();
    
    TwoFactorAuth tfa = new TwoFactorAuth();
    tfa.setAccountId(accountId);
    tfa.setSecret(secret);
    tfa.setEnabled(false); // Подтвердить сначала
    
    twoFactorRepository.save(tfa);
    
    // Вернуть QR code URL
    String qrCodeUrl = generateQRCodeUrl(accountId, secret);
    
    return new Enable2FAResponse(qrCodeUrl, secret);
}

@PostMapping("/auth/2fa/verify")
public void verify2FA(
    @RequestHeader("Authorization") String token,
    @RequestBody Verify2FARequest request
) {
    UUID accountId = extractAccountId(token);
    TwoFactorAuth tfa = twoFactorRepository.findByAccountId(accountId).orElseThrow();
    
    // Проверить TOTP code
    if (!totpService.verifyCode(tfa.getSecret(), request.getCode())) {
        throw new Invalid2FACodeException();
    }
    
    // Активировать 2FA
    tfa.setEnabled(true);
    twoFactorRepository.save(tfa);
}
```

---

## Roles & Permissions (RBAC)

```java
public enum Role {
    PLAYER,
    MODERATOR,
    ADMIN,
    DEVELOPER
}

public enum Permission {
    // Player
    PLAY_GAME,
    USE_CHAT,
    TRADE,
    
    // Moderator
    MODERATE_CHAT,
    BAN_PLAYER,
    KICK_PLAYER,
    
    // Admin
    MANAGE_ACCOUNTS,
    MANAGE_SERVERS,
    VIEW_LOGS,
    
    // Developer
    DEBUG_MODE,
    SPAWN_ITEMS
}

private static final Map<Role, Set<Permission>> ROLE_PERMISSIONS = Map.of(
    Role.PLAYER, Set.of(Permission.PLAY_GAME, Permission.USE_CHAT, Permission.TRADE),
    Role.MODERATOR, Set.of(Permission.MODERATE_CHAT, Permission.BAN_PLAYER),
    Role.ADMIN, Set.of(Permission.MANAGE_ACCOUNTS, Permission.MANAGE_SERVERS),
    Role.DEVELOPER, Set.of(Permission.DEBUG_MODE, Permission.SPAWN_ITEMS)
);
```

---

## Rate Limiting

```java
@Component
public class LoginRateLimiter {
    
    @Value("${auth.max-login-attempts:5}")
    private int maxAttempts;
    
    @Value("${auth.lockout-duration-minutes:15}")
    private int lockoutMinutes;
    
    public void recordFailedAttempt(String email) {
        String key = "login_attempts:" + email;
        Long attempts = redis.opsForValue().increment(key);
        
        if (attempts == 1) {
            redis.expire(key, lockoutMinutes, TimeUnit.MINUTES);
        }
        
        if (attempts >= maxAttempts) {
            // Блокировать на 15 минут
            String lockKey = "login_locked:" + email;
            redis.opsForValue().set(lockKey, "true", lockoutMinutes, TimeUnit.MINUTES);
        }
    }
    
    public boolean isLocked(String email) {
        return redis.hasKey("login_locked:" + email);
    }
}
```

---

## API Endpoints

**POST `/api/v1/auth/forgot-password`** - восстановить пароль
**POST `/api/v1/auth/reset-password`** - установить новый пароль
**POST `/api/v1/auth/2fa/enable`** - включить 2FA
**POST `/api/v1/auth/2fa/verify`** - подтвердить 2FA

---

## Связанные документы

- `.BRAIN/05-technical/backend/auth/auth-registration.md` - Registration (микрофича 1/3)
- `.BRAIN/05-technical/backend/auth/auth-login.md` - Login (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:35)** - Микрофича 3/3: Auth Security (split from authentication-authorization-system.md)

