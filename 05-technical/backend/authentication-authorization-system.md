---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Полная система аутентификации и авторизации. Регистрация, login, JWT tokens, OAuth, password recovery, 2FA, roles/permissions, account linking.
---

# Authentication & Authorization System - Система аутентификации и авторизации

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:20  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

---

## Краткое описание

**Authentication & Authorization System** - критически важная система для управления доступом игроков к игре. Без этой системы игра не может запуститься. Обеспечивает регистрацию, вход, управление токенами, восстановление паролей и контроль прав доступа.

**Ключевые возможности:**
- ✅ Регистрация аккаунтов (email/password, OAuth)
- ✅ Login/Logout flow
- ✅ JWT Token management (access + refresh tokens)
- ✅ Password recovery (email)
- ✅ Two-Factor Authentication (опционально)
- ✅ Roles & Permissions (player, moderator, admin)
- ✅ Account linking (Steam, Google, Discord, etc)
- ✅ Session management integration

---

## Архитектура системы

### High-Level Flow

```
┌─────────────┐
│   CLIENT    │
└──────┬──────┘
       │
       │ 1. Register/Login
       ▼
┌──────────────────┐
│  Auth Service    │
│  - Validate      │
│  - Hash password │
│  - Generate JWT  │
└──────┬───────────┘
       │
       ├─→ PostgreSQL (accounts)
       ├─→ Redis (refresh tokens, blacklist)
       └─→ Session Manager (create session)
       
       │ 2. Access protected resources
       ▼
┌──────────────────┐
│  API Gateway     │
│  - Verify JWT    │
│  - Check roles   │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Game Services   │
└──────────────────┘
```

---

## Database Schema

### Таблица `accounts`

```sql
CREATE TABLE accounts (
    -- Идентификация
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Credentials
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255) NOT NULL, -- bcrypt hash
    
    -- OAuth (опционально)
    oauth_provider VARCHAR(50), -- google, steam, discord, twitch
    oauth_id VARCHAR(255), -- ID от провайдера
    oauth_data JSONB, -- Дополнительные данные от OAuth
    
    -- Профиль
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    
    -- 2FA
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(100), -- TOTP secret
    backup_codes TEXT[], -- Резервные коды
    
    -- Security
    last_password_change TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP, -- Временная блокировка после попыток
    
    -- Статус
    status VARCHAR(20) DEFAULT 'ACTIVE', 
    -- ACTIVE, SUSPENDED, BANNED, DELETED
    
    ban_reason TEXT,
    banned_until TIMESTAMP, -- NULL = permanent
    banned_by UUID, -- Admin who banned
    banned_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    
    -- IP tracking (для security)
    registration_ip VARCHAR(45),
    last_login_ip VARCHAR(45),
    
    CONSTRAINT fk_account_banned_by FOREIGN KEY (banned_by) 
        REFERENCES accounts(id) ON DELETE SET NULL
);

CREATE INDEX idx_accounts_email ON accounts(email);
CREATE INDEX idx_accounts_username ON accounts(username);
CREATE INDEX idx_accounts_oauth ON accounts(oauth_provider, oauth_id);
CREATE INDEX idx_accounts_status ON accounts(status);
```

### Таблица `account_roles`

```sql
CREATE TABLE account_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    
    -- Роль
    role VARCHAR(50) NOT NULL,
    -- PLAYER, MODERATOR, ADMIN, SUPER_ADMIN, CONTENT_CREATOR, TESTER
    
    -- Permissions (JSON array)
    permissions JSONB DEFAULT '[]',
    -- ["chat.moderate", "player.ban", "event.create", etc]
    
    -- Временные роли
    granted_until TIMESTAMP, -- NULL = permanent
    
    -- Аудит
    granted_by UUID,
    granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_role_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE,
    CONSTRAINT fk_role_granted_by FOREIGN KEY (granted_by) 
        REFERENCES accounts(id) ON DELETE SET NULL,
    UNIQUE(account_id, role)
);

CREATE INDEX idx_roles_account ON account_roles(account_id);
CREATE INDEX idx_roles_role ON account_roles(role);
```

### Таблица `password_reset_tokens`

```sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    
    token VARCHAR(255) UNIQUE NOT NULL, -- Random secure token
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    
    -- IP tracking
    requested_ip VARCHAR(45),
    used_ip VARCHAR(45),
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP,
    
    CONSTRAINT fk_reset_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE INDEX idx_reset_token ON password_reset_tokens(token) 
    WHERE used = FALSE;
CREATE INDEX idx_reset_account ON password_reset_tokens(account_id);
CREATE INDEX idx_reset_expires ON password_reset_tokens(expires_at) 
    WHERE used = FALSE;
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
    verified_at TIMESTAMP,
    
    CONSTRAINT fk_verify_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE INDEX idx_verify_token ON email_verification_tokens(token) 
    WHERE verified = FALSE;
```

### Таблица `login_history`

```sql
CREATE TABLE login_history (
    id BIGSERIAL PRIMARY KEY,
    account_id UUID NOT NULL,
    
    -- Event
    event_type VARCHAR(20) NOT NULL, 
    -- LOGIN_SUCCESS, LOGIN_FAILED, LOGOUT, PASSWORD_RESET
    
    -- Details
    ip_address VARCHAR(45),
    user_agent TEXT,
    location JSONB, -- {country, city, ...}
    
    -- Timestamp
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_login_history_account FOREIGN KEY (account_id) 
        REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE INDEX idx_login_history_account ON login_history(account_id, created_at DESC);
CREATE INDEX idx_login_history_created ON login_history(created_at DESC);
```

---

## Registration Flow

### Email/Password Registration

```java
@Service
public class AuthService {
    
    @Autowired
    private AccountRepository accountRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder; // BCrypt
    
    @Autowired
    private EmailService emailService;
    
    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        // 1. Валидация
        validateRegistration(request);
        
        // 2. Проверить, что email/username свободны
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
        account.setDisplayName(request.getDisplayName());
        account.setRegistrationIp(getClientIp());
        account.setStatus(AccountStatus.ACTIVE);
        account.setEmailVerified(false);
        
        account = accountRepository.save(account);
        
        // 5. Назначить роль PLAYER
        AccountRole playerRole = new AccountRole();
        playerRole.setAccountId(account.getId());
        playerRole.setRole(Role.PLAYER);
        playerRole.setPermissions(Role.PLAYER.getDefaultPermissions());
        roleRepository.save(playerRole);
        
        // 6. Отправить email verification
        String verificationToken = generateVerificationToken();
        EmailVerificationToken token = new EmailVerificationToken();
        token.setAccountId(account.getId());
        token.setToken(verificationToken);
        token.setExpiresAt(Instant.now().plus(Duration.ofHours(24)));
        verificationTokenRepository.save(token);
        
        emailService.sendVerificationEmail(
            account.getEmail(),
            account.getUsername(),
            verificationToken
        );
        
        // 7. Логировать
        log.info("New account registered: {}", account.getId());
        
        return new RegisterResponse(
            account.getId(),
            "Account created! Please check your email to verify."
        );
    }
    
    private void validateRegistration(RegisterRequest request) {
        // Email
        if (!isValidEmail(request.getEmail())) {
            throw new InvalidEmailException();
        }
        
        // Password strength
        if (request.getPassword().length() < 8) {
            throw new WeakPasswordException("Password must be at least 8 characters");
        }
        
        if (!hasUpperCase(request.getPassword()) || 
            !hasLowerCase(request.getPassword()) || 
            !hasDigit(request.getPassword())) {
            throw new WeakPasswordException(
                "Password must contain uppercase, lowercase, and digit"
            );
        }
        
        // Username
        if (request.getUsername().length() < 3 || request.getUsername().length() > 20) {
            throw new InvalidUsernameException("Username must be 3-20 characters");
        }
        
        if (!isAlphanumeric(request.getUsername())) {
            throw new InvalidUsernameException("Username must be alphanumeric");
        }
    }
}
```

### OAuth Registration/Login

```java
@Service
public class OAuthService {
    
    public LoginResponse loginWithOAuth(OAuthProvider provider, String oauthCode) {
        // 1. Обменять code на access token у провайдера
        OAuthTokenResponse tokenResponse = provider.exchangeCodeForToken(oauthCode);
        
        // 2. Получить user info от провайдера
        OAuthUserInfo userInfo = provider.getUserInfo(tokenResponse.getAccessToken());
        
        // 3. Найти или создать аккаунт
        Account account = accountRepository
            .findByOAuthProviderAndId(provider.name(), userInfo.getId())
            .orElseGet(() -> createOAuthAccount(provider, userInfo));
        
        // 4. Проверить статус
        if (account.getStatus() == AccountStatus.BANNED) {
            throw new AccountBannedException(account.getBanReason());
        }
        
        // 5. Создать JWT tokens
        String accessToken = jwtService.generateAccessToken(account);
        String refreshToken = jwtService.generateRefreshToken(account);
        
        // 6. Создать session
        SessionResponse session = sessionManager.createSession(
            account.getId(),
            null, // Character ID will be set later
            getClientIp(),
            getUserAgent()
        );
        
        // 7. Логировать
        logLoginEvent(account.getId(), LoginEventType.LOGIN_SUCCESS);
        
        return new LoginResponse(
            accessToken,
            refreshToken,
            session.getSessionToken(),
            account.toDTO()
        );
    }
    
    private Account createOAuthAccount(OAuthProvider provider, OAuthUserInfo userInfo) {
        Account account = new Account();
        account.setOauthProvider(provider.name());
        account.setOauthId(userInfo.getId());
        account.setEmail(userInfo.getEmail());
        account.setEmailVerified(true); // OAuth provider verified it
        account.setUsername(generateUniqueUsername(userInfo.getUsername()));
        account.setDisplayName(userInfo.getDisplayName());
        account.setPasswordHash(generateRandomPassword()); // Placeholder
        account.setRegistrationIp(getClientIp());
        
        account = accountRepository.save(account);
        
        // Назначить роль
        assignRole(account.getId(), Role.PLAYER);
        
        return account;
    }
}
```

---

## Login Flow

### Email/Password Login

```java
public LoginResponse login(LoginRequest request) {
    // 1. Найти аккаунт по email
    Account account = accountRepository.findByEmail(request.getEmail())
        .orElseThrow(() -> new InvalidCredentialsException());
    
    // 2. Проверить lockout (после failed attempts)
    if (account.getLockedUntil() != null && 
        Instant.now().isBefore(account.getLockedUntil())) {
        long minutesLeft = Duration.between(
            Instant.now(), account.getLockedUntil()
        ).toMinutes();
        throw new AccountLockedException(
            "Account locked. Try again in " + minutesLeft + " minutes"
        );
    }
    
    // 3. Проверить пароль
    if (!passwordEncoder.matches(request.getPassword(), account.getPasswordHash())) {
        // Increment failed attempts
        account.setFailedLoginAttempts(account.getFailedLoginAttempts() + 1);
        
        if (account.getFailedLoginAttempts() >= 5) {
            // Lock account for 15 minutes
            account.setLockedUntil(Instant.now().plus(Duration.ofMinutes(15)));
            accountRepository.save(account);
            
            logLoginEvent(account.getId(), LoginEventType.LOGIN_FAILED);
            
            throw new AccountLockedException(
                "Too many failed attempts. Account locked for 15 minutes"
            );
        }
        
        accountRepository.save(account);
        logLoginEvent(account.getId(), LoginEventType.LOGIN_FAILED);
        
        throw new InvalidCredentialsException();
    }
    
    // 4. Проверить статус
    if (account.getStatus() == AccountStatus.BANNED) {
        if (account.getBannedUntil() != null && 
            Instant.now().isAfter(account.getBannedUntil())) {
            // Ban expired, unban
            account.setStatus(AccountStatus.ACTIVE);
            account.setBannedUntil(null);
            accountRepository.save(account);
        } else {
            throw new AccountBannedException(
                account.getBanReason(),
                account.getBannedUntil()
            );
        }
    }
    
    // 5. 2FA check (если включен)
    if (account.isTwoFactorEnabled()) {
        if (request.getTwoFactorCode() == null) {
            return new LoginResponse(
                null, null, null, null,
                true, // requiresTwoFactor = true
                "Two-factor authentication required"
            );
        }
        
        if (!verifyTwoFactorCode(account, request.getTwoFactorCode())) {
            throw new InvalidTwoFactorCodeException();
        }
    }
    
    // 6. Reset failed attempts
    account.setFailedLoginAttempts(0);
    account.setLockedUntil(null);
    account.setLastLoginAt(Instant.now());
    account.setLastLoginIp(getClientIp());
    accountRepository.save(account);
    
    // 7. Создать JWT tokens
    String accessToken = jwtService.generateAccessToken(account);
    String refreshToken = jwtService.generateRefreshToken(account);
    
    // 8. Сохранить refresh token в Redis
    redis.opsForValue().set(
        "refresh_token:" + account.getId(),
        refreshToken,
        7, TimeUnit.DAYS
    );
    
    // 9. Создать session
    SessionResponse session = sessionManager.createSession(
        account.getId(),
        null, // Character ID
        getClientIp(),
        getUserAgent(),
        getClientVersion()
    );
    
    // 10. Логировать
    logLoginEvent(account.getId(), LoginEventType.LOGIN_SUCCESS);
    
    return new LoginResponse(
        accessToken,
        refreshToken,
        session.getSessionToken(),
        account.toDTO()
    );
}
```

---

## JWT Token Management

### Token Structure

**Access Token (15 минут TTL):**
```json
{
  "sub": "account-uuid",
  "type": "access",
  "roles": ["PLAYER"],
  "permissions": ["game.play", "chat.send"],
  "iat": 1699296000,
  "exp": 1699296900
}
```

**Refresh Token (7 дней TTL):**
```json
{
  "sub": "account-uuid",
  "type": "refresh",
  "iat": 1699296000,
  "exp": 1699900800
}
```

### Token Generation

```java
@Service
public class JwtService {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.access.expiration}")
    private long accessTokenExpiration = 900; // 15 minutes
    
    @Value("${jwt.refresh.expiration}")
    private long refreshTokenExpiration = 604800; // 7 days
    
    public String generateAccessToken(Account account) {
        List<String> roles = getRoles(account.getId());
        List<String> permissions = getPermissions(account.getId());
        
        return Jwts.builder()
            .setSubject(account.getId().toString())
            .claim("type", "access")
            .claim("roles", roles)
            .claim("permissions", permissions)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + accessTokenExpiration * 1000))
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }
    
    public String generateRefreshToken(Account account) {
        return Jwts.builder()
            .setSubject(account.getId().toString())
            .claim("type", "refresh")
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + refreshTokenExpiration * 1000))
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }
    
    public Claims validateToken(String token) {
        try {
            return Jwts.parser()
                .setSigningKey(jwtSecret)
                .parseClaimsJws(token)
                .getBody();
        } catch (ExpiredJwtException e) {
            throw new TokenExpiredException();
        } catch (JwtException e) {
            throw new InvalidTokenException();
        }
    }
}
```

### Token Refresh

```java
@PostMapping("/auth/refresh")
public LoginResponse refreshToken(@RequestBody RefreshTokenRequest request) {
    // 1. Валидировать refresh token
    Claims claims = jwtService.validateToken(request.getRefreshToken());
    
    if (!claims.get("type").equals("refresh")) {
        throw new InvalidTokenException("Not a refresh token");
    }
    
    UUID accountId = UUID.fromString(claims.getSubject());
    
    // 2. Проверить, что refresh token exists в Redis
    String storedToken = (String) redis.opsForValue().get(
        "refresh_token:" + accountId
    );
    
    if (storedToken == null || !storedToken.equals(request.getRefreshToken())) {
        throw new InvalidTokenException("Refresh token revoked or not found");
    }
    
    // 3. Проверить, что аккаунт активен
    Account account = accountRepository.findById(accountId)
        .orElseThrow(() -> new AccountNotFoundException());
    
    if (account.getStatus() != AccountStatus.ACTIVE) {
        throw new AccountNotActiveException();
    }
    
    // 4. Создать новый access token
    String newAccessToken = jwtService.generateAccessToken(account);
    
    return new LoginResponse(
        newAccessToken,
        request.getRefreshToken(), // Refresh token остается тот же
        null, // Session token не меняется
        null
    );
}
```

---

## Password Recovery

### Request Password Reset

```java
@PostMapping("/auth/forgot-password")
public MessageResponse requestPasswordReset(@RequestBody EmailRequest request) {
    // 1. Найти аккаунт
    Account account = accountRepository.findByEmail(request.getEmail())
        .orElse(null);
    
    if (account == null) {
        // Не раскрываем, существует ли email (security)
        return new MessageResponse(
            "If this email exists, you will receive a password reset link"
        );
    }
    
    // 2. Создать reset token
    String resetToken = generateSecureRandomToken();
    
    PasswordResetToken token = new PasswordResetToken();
    token.setAccountId(account.getId());
    token.setToken(resetToken);
    token.setExpiresAt(Instant.now().plus(Duration.ofHours(1)));
    token.setRequestedIp(getClientIp());
    
    resetTokenRepository.save(token);
    
    // 3. Отправить email
    emailService.sendPasswordResetEmail(
        account.getEmail(),
        account.getUsername(),
        resetToken
    );
    
    return new MessageResponse(
        "If this email exists, you will receive a password reset link"
    );
}
```

### Reset Password

```java
@PostMapping("/auth/reset-password")
public MessageResponse resetPassword(@RequestBody ResetPasswordRequest request) {
    // 1. Найти token
    PasswordResetToken token = resetTokenRepository.findByToken(request.getToken())
        .orElseThrow(() -> new InvalidTokenException("Invalid or expired token"));
    
    // 2. Проверить expiration
    if (Instant.now().isAfter(token.getExpiresAt())) {
        throw new TokenExpiredException();
    }
    
    // 3. Проверить, что не использован
    if (token.isUsed()) {
        throw new TokenAlreadyUsedException();
    }
    
    // 4. Получить аккаунт
    Account account = accountRepository.findById(token.getAccountId())
        .orElseThrow(() -> new AccountNotFoundException());
    
    // 5. Обновить пароль
    String newPasswordHash = passwordEncoder.encode(request.getNewPassword());
    account.setPasswordHash(newPasswordHash);
    account.setLastPasswordChange(Instant.now());
    accountRepository.save(account);
    
    // 6. Пометить token как использованный
    token.setUsed(true);
    token.setUsedAt(Instant.now());
    token.setUsedIp(getClientIp());
    resetTokenRepository.save(token);
    
    // 7. Invalidate все refresh tokens (force re-login)
    redis.delete("refresh_token:" + account.getId());
    
    return new MessageResponse("Password reset successful");
}
```

---

## Two-Factor Authentication (2FA)

### Enable 2FA

```java
@PostMapping("/auth/2fa/enable")
public TwoFactorResponse enable2FA(@AuthenticatedUser Account account) {
    // 1. Создать TOTP secret
    String secret = generateTOTPSecret();
    
    // 2. Создать backup codes
    List<String> backupCodes = generateBackupCodes(10);
    
    // 3. Временно сохранить (не активируем пока)
    redis.opsForValue().set(
        "2fa_setup:" + account.getId(),
        new TwoFactorSetup(secret, backupCodes),
        10, TimeUnit.MINUTES
    );
    
    // 4. Создать QR code data
    String issuer = "NECPGAME";
    String qrCodeData = "otpauth://totp/" + issuer + ":" + account.getEmail() + 
                        "?secret=" + secret + 
                        "&issuer=" + issuer;
    
    return new TwoFactorResponse(
        secret,
        qrCodeData,
        backupCodes,
        "Scan QR code and enter verification code"
    );
}
```

### Verify and Activate 2FA

```java
@PostMapping("/auth/2fa/verify")
public MessageResponse verify2FA(
    @AuthenticatedUser Account account,
    @RequestBody VerifyTwoFactorRequest request
) {
    // 1. Получить setup data
    TwoFactorSetup setup = (TwoFactorSetup) redis.opsForValue().get(
        "2fa_setup:" + account.getId()
    );
    
    if (setup == null) {
        throw new TwoFactorSetupNotFoundException();
    }
    
    // 2. Проверить код
    if (!verifyTOTPCode(setup.getSecret(), request.getCode())) {
        throw new InvalidTwoFactorCodeException();
    }
    
    // 3. Активировать 2FA
    account.setTwoFactorEnabled(true);
    account.setTwoFactorSecret(setup.getSecret());
    account.setBackupCodes(setup.getBackupCodes().toArray(new String[0]));
    accountRepository.save(account);
    
    // 4. Удалить setup data
    redis.delete("2fa_setup:" + account.getId());
    
    return new MessageResponse("Two-factor authentication enabled successfully");
}
```

---

## Authorization (Roles & Permissions)

### Role Definitions

```java
public enum Role {
    PLAYER(List.of(
        "game.play",
        "chat.send",
        "trade.execute",
        "guild.join"
    )),
    
    MODERATOR(List.of(
        "game.play",
        "chat.send",
        "chat.moderate",
        "player.mute",
        "player.kick"
    )),
    
    ADMIN(List.of(
        "game.play",
        "chat.moderate",
        "player.ban",
        "player.unban",
        "event.create",
        "world.manage",
        "economy.adjust"
    )),
    
    SUPER_ADMIN(List.of(
        "*" // All permissions
    ));
    
    private final List<String> defaultPermissions;
    
    Role(List<String> defaultPermissions) {
        this.defaultPermissions = defaultPermissions;
    }
    
    public List<String> getDefaultPermissions() {
        return defaultPermissions;
    }
}
```

### Check Permission

```java
@Service
public class PermissionService {
    
    public boolean hasPermission(UUID accountId, String permission) {
        List<AccountRole> roles = roleRepository.findByAccountId(accountId);
        
        for (AccountRole role : roles) {
            // Проверить expiration
            if (role.getGrantedUntil() != null && 
                Instant.now().isAfter(role.getGrantedUntil())) {
                continue;
            }
            
            // SUPER_ADMIN has all permissions
            if (role.getRole().equals("SUPER_ADMIN")) {
                return true;
            }
            
            // Check permissions list
            if (role.getPermissions().contains(permission)) {
                return true;
            }
        }
        
        return false;
    }
}
```

### @RequiresPermission Annotation

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresPermission {
    String value();
}

@Aspect
@Component
public class PermissionAspect {
    
    @Autowired
    private PermissionService permissionService;
    
    @Around("@annotation(requiresPermission)")
    public Object checkPermission(
        ProceedingJoinPoint joinPoint,
        RequiresPermission requiresPermission
    ) throws Throwable {
        // Получить текущего пользователя
        Account account = SecurityContextHolder.getAccount();
        
        // Проверить permission
        if (!permissionService.hasPermission(
            account.getId(),
            requiresPermission.value()
        )) {
            throw new InsufficientPermissionsException(
                "Required permission: " + requiresPermission.value()
            );
        }
        
        return joinPoint.proceed();
    }
}

// Usage:
@PostMapping("/admin/player/ban")
@RequiresPermission("player.ban")
public void banPlayer(@RequestBody BanRequest request) {
    // ...
}
```

---

## API Endpoints

### Authentication

**POST `/api/v1/auth/register`** - регистрация
```json
Request:
{
  "email": "player@example.com",
  "password": "SecurePass123!",
  "username": "V",
  "displayName": "V (Streetkid)"
}

Response:
{
  "accountId": "uuid",
  "message": "Account created! Please check your email to verify."
}
```

**POST `/api/v1/auth/login`** - вход
```json
Request:
{
  "email": "player@example.com",
  "password": "SecurePass123!",
  "twoFactorCode": "123456" // optional
}

Response:
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "sessionToken": "session-token",
  "account": {
    "id": "uuid",
    "username": "V",
    "email": "player@example.com",
    "roles": ["PLAYER"]
  }
}
```

**POST `/api/v1/auth/logout`** - выход
**POST `/api/v1/auth/refresh`** - обновить access token

### Password Management

**POST `/api/v1/auth/forgot-password`** - запросить reset
**POST `/api/v1/auth/reset-password`** - сбросить пароль
**POST `/api/v1/auth/change-password`** - изменить пароль

### Email Verification

**POST `/api/v1/auth/verify-email`** - подтвердить email
**POST `/api/v1/auth/resend-verification`** - переотправить письмо

### Two-Factor Authentication

**POST `/api/v1/auth/2fa/enable`** - включить 2FA
**POST `/api/v1/auth/2fa/verify`** - подтвердить 2FA
**POST `/api/v1/auth/2fa/disable`** - выключить 2FA

### OAuth

**GET `/api/v1/auth/oauth/{provider}`** - начать OAuth flow
**GET `/api/v1/auth/oauth/{provider}/callback`** - callback от провайдера

### Account Management

**GET `/api/v1/auth/account`** - получить информацию об аккаунте
**PUT `/api/v1/auth/account`** - обновить профиль
**DELETE `/api/v1/auth/account`** - удалить аккаунт

---

## Security Best Practices

### Password Security
- **Хэширование:** BCrypt (cost factor 12+)
- **Минимальная длина:** 8 символов
- **Требования:** uppercase + lowercase + digit + special char
- **Password history:** Не разрешать повторное использование последних 3 паролей

### Token Security
- **Access Token TTL:** 15 минут (короткий)
- **Refresh Token TTL:** 7 дней (ротация при использовании)
- **Token Storage:** Redis (для быстрого revoke)
- **Token Blacklist:** При logout добавлять в blacklist

### Rate Limiting
```
/auth/register:       5 requests / hour per IP
/auth/login:          10 requests / 15 min per IP
/auth/forgot-password: 3 requests / hour per IP
```

### Brute Force Protection
```
5 failed attempts → account lock 15 minutes
10 failed attempts → account lock 1 hour
20 failed attempts → account lock 24 hours + alert admin
```

---

## Интеграция с другими системами

### При регистрации

```
AuthService.register()
  ↓
→ EmailService: send verification email
→ EventBus: publish ACCOUNT_CREATED
→ AnalyticsService: record new user
```

### При login

```
AuthService.login()
  ↓
→ SessionManager: create session
→ EventBus: publish LOGIN_SUCCESS
→ AnalyticsService: record login
→ NotificationService: send "Welcome back!"
```

### При смене пароля

```
AuthService.changePassword()
  ↓
→ EmailService: send "Password changed" notification
→ SessionManager: revoke all sessions (force re-login)
→ EventBus: publish PASSWORD_CHANGED
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/session-management-system.md` - Session management
- `.BRAIN/05-technical/backend/player-character-management.md` - Player & Character management (будет создан)

---

## TODO

- [ ] OAuth integration (Steam, Google, Discord)
- [ ] Email service integration (SendGrid, Mailgun)
- [ ] Rate limiting implementation
- [ ] Login attempt monitoring/alerting
- [ ] Password breach detection (HaveIBeenPwned API)

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Authentication & Authorization System

