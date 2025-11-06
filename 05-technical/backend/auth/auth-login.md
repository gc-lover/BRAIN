---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:35  
**api-readiness-notes:** Auth Login микрофича. Login/logout, JWT tokens, refresh tokens, session tracking. ~370 строк.
---

# Auth Login - Вход и сессии

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:35  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

**Микрофича:** Login/logout & JWT tokens  
**Размер:** ~370 строк ✅

---

## Краткое описание

**Auth Login** - система входа, выхода и управления JWT токенами.

**Ключевые возможности:**
- ✅ Login (email/password)
- ✅ JWT access tokens (15 min)
- ✅ JWT refresh tokens (30 days)
- ✅ Logout (revoke tokens)
- ✅ Session tracking

---

## Login Flow

```java
@PostMapping("/auth/login")
public LoginResponse login(@RequestBody LoginRequest request) {
    // 1. Найти аккаунт
    Account account = accountRepository.findByEmail(request.getEmail())
        .orElseThrow(() -> new InvalidCredentialsException());
    
    // 2. Проверить пароль
    if (!passwordEncoder.matches(request.getPassword(), account.getPasswordHash())) {
        throw new InvalidCredentialsException();
    }
    
    // 3. Проверить статус
    if (account.getStatus() == AccountStatus.BANNED) {
        throw new AccountBannedException(account.getBanReason());
    }
    
    if (!account.isEmailVerified()) {
        throw new EmailNotVerifiedException();
    }
    
    // 4. Создать JWT tokens
    String accessToken = jwtService.generateAccessToken(account);
    String refreshToken = jwtService.generateRefreshToken(account);
    
    // 5. Сохранить refresh token
    saveRefreshToken(account.getId(), refreshToken, request.getDeviceInfo());
    
    // 6. Обновить last login
    account.setLastLoginAt(Instant.now());
    account.setLastLoginIp(getClientIp());
    accountRepository.save(account);
    
    return new LoginResponse(accessToken, refreshToken, account.toDTO());
}
```

---

## JWT Tokens

### Access Token (15 minutes)

```json
{
  "sub": "account-uuid",
  "username": "player123",
  "roles": ["PLAYER"],
  "iat": 1699300000,
  "exp": 1699300900
}
```

### Refresh Token (30 days)

```json
{
  "sub": "account-uuid",
  "type": "refresh",
  "iat": 1699300000,
  "exp": 1701892000
}
```

### Token Generation

```java
public String generateAccessToken(Account account) {
    return Jwts.builder()
        .setSubject(account.getId().toString())
        .claim("username", account.getUsername())
        .claim("roles", account.getRoles())
        .setIssuedAt(new Date())
        .setExpiration(new Date(System.currentTimeMillis() + 900000)) // 15 min
        .signWith(SignatureAlgorithm.HS512, jwtSecret)
        .compact();
}

public String generateRefreshToken(Account account) {
    String tokenValue = UUID.randomUUID().toString();
    
    return Jwts.builder()
        .setSubject(account.getId().toString())
        .claim("type", "refresh")
        .claim("tokenId", tokenValue)
        .setIssuedAt(new Date())
        .setExpiration(new Date(System.currentTimeMillis() + 2592000000L)) // 30 days
        .signWith(SignatureAlgorithm.HS512, jwtSecret)
        .compact();
}
```

---

## Refresh Token Storage

```sql
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    device_info JSONB,
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_refresh_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);
```

---

## Refresh Access Token

```java
@PostMapping("/auth/refresh")
public RefreshResponse refresh(@RequestBody RefreshRequest request) {
    // 1. Валидировать refresh token
    Claims claims = jwtService.validateToken(request.getRefreshToken());
    UUID accountId = UUID.fromString(claims.getSubject());
    
    // 2. Проверить в DB
    String tokenHash = hashToken(request.getRefreshToken());
    RefreshToken tokenRecord = refreshTokenRepository
        .findByTokenHash(tokenHash)
        .orElseThrow(() -> new InvalidTokenException());
    
    if (tokenRecord.isRevoked() || tokenRecord.isExpired()) {
        throw new InvalidTokenException();
    }
    
    // 3. Создать новый access token
    Account account = accountRepository.findById(accountId).orElseThrow();
    String newAccessToken = jwtService.generateAccessToken(account);
    
    return new RefreshResponse(newAccessToken);
}
```

---

## Logout

```java
@PostMapping("/auth/logout")
public void logout(
    @RequestHeader("Authorization") String authHeader,
    @RequestBody LogoutRequest request
) {
    // 1. Revoke refresh token
    String tokenHash = hashToken(request.getRefreshToken());
    refreshTokenRepository.revokeToken(tokenHash);
    
    // 2. Добавить access token в blacklist (Redis)
    String accessToken = extractToken(authHeader);
    long ttl = jwtService.getExpiration(accessToken) - System.currentTimeMillis();
    redis.opsForValue().set("blacklist:" + accessToken, "true", ttl, TimeUnit.MILLISECONDS);
}
```

---

## API Endpoints

**POST `/api/v1/auth/login`** - вход
**POST `/api/v1/auth/logout`** - выход
**POST `/api/v1/auth/refresh`** - обновить токен
**GET `/api/v1/auth/me`** - текущий пользователь

---

## Связанные документы

- `.BRAIN/05-technical/backend/auth/auth-registration.md` - Registration (микрофича 1/3)
- `.BRAIN/05-technical/backend/auth/auth-security.md` - Security (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:35)** - Микрофича 2/3: Auth Login (split from authentication-authorization-system.md)

