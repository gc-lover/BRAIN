---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:45  
**api-readiness-notes:** Guild Ranks микрофича. Ranks/permissions, promote/demote, custom ranks. ~330 строк.
---

# Guild Ranks - Ранги и права

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:45  
**Приоритет:** средний (Tier 2)  
**Автор:** AI Brain Manager

**Микрофича:** Guild ranks & permissions  
**Размер:** ~330 строк ✅

---

## Краткое описание

**Guild Ranks** - система рангов и прав в гильдии.

**Ключевые возможности:**
- ✅ Default ranks (Leader, Officer, Veteran, Member, Recruit)
- ✅ Permissions (invite, kick, manage bank)
- ✅ Promote/Demote
- ✅ Custom ranks (future)

---

## Guild Ranks

```java
public enum GuildRank {
    LEADER(5),      // Полный контроль
    OFFICER(4),     // Управление + kick
    VETERAN(3),     // Invite + bank withdraw
    MEMBER(2),      // Chat + bank deposit
    RECRUIT(1);     // Chat only
    
    private final int level;
    
    GuildRank(int level) {
        this.level = level;
    }
    
    public boolean canPromote(GuildRank targetRank) {
        return this.level > targetRank.level;
    }
}

public enum GuildPermission {
    CHAT,               // Писать в guild chat
    INVITE,             // Invite игроков
    KICK,               // Kick members
    PROMOTE,            // Promote/demote
    MANAGE_RANKS,       // Создавать/изменять ranks
    BANK_DEPOSIT,       // Положить в guild bank
    BANK_WITHDRAW,      // Взять из bank
    MANAGE_BANK,        // Управлять bank tabs
    EDIT_INFO,          // Изменить description
    DISBAND             // Расформировать гильдию
}
```

---

## Permission Matrix

```java
private static final Map<GuildRank, Set<GuildPermission>> RANK_PERMISSIONS = Map.of(
    GuildRank.LEADER, Set.of(
        GuildPermission.CHAT,
        GuildPermission.INVITE,
        GuildPermission.KICK,
        GuildPermission.PROMOTE,
        GuildPermission.MANAGE_RANKS,
        GuildPermission.BANK_DEPOSIT,
        GuildPermission.BANK_WITHDRAW,
        GuildPermission.MANAGE_BANK,
        GuildPermission.EDIT_INFO,
        GuildPermission.DISBAND
    ),
    
    GuildRank.OFFICER, Set.of(
        GuildPermission.CHAT,
        GuildPermission.INVITE,
        GuildPermission.KICK,
        GuildPermission.BANK_DEPOSIT,
        GuildPermission.BANK_WITHDRAW
    ),
    
    GuildRank.VETERAN, Set.of(
        GuildPermission.CHAT,
        GuildPermission.INVITE,
        GuildPermission.BANK_DEPOSIT,
        GuildPermission.BANK_WITHDRAW
    ),
    
    GuildRank.MEMBER, Set.of(
        GuildPermission.CHAT,
        GuildPermission.BANK_DEPOSIT
    ),
    
    GuildRank.RECRUIT, Set.of(
        GuildPermission.CHAT
    )
);

public boolean hasPermission(UUID playerId, GuildPermission permission) {
    GuildMember member = guildMemberRepository.findByPlayer(playerId).orElse(null);
    if (member == null) return false;
    
    Set<GuildPermission> permissions = RANK_PERMISSIONS.get(member.getRank());
    return permissions != null && permissions.contains(permission);
}
```

---

## Promote/Demote

```java
@PostMapping("/guilds/promote")
@Transactional
public PromoteResponse promote(
    @RequestHeader("Authorization") String token,
    @RequestBody PromoteRequest request
) {
    UUID promoterId = extractPlayerId(token);
    
    // 1. Проверить permission
    if (!hasPermission(promoterId, GuildPermission.PROMOTE)) {
        return error("No permission");
    }
    
    // 2. Найти target
    GuildMember target = guildMemberRepository.findByPlayer(request.getTargetPlayerId())
        .orElseThrow();
    
    GuildMember promoter = guildMemberRepository.findByPlayer(promoterId).orElseThrow();
    
    if (!target.getGuildId().equals(promoter.getGuildId())) {
        return error("Not in same guild");
    }
    
    // 3. Проверить rank level
    GuildRank newRank = request.getNewRank();
    
    if (!promoter.getRank().canPromote(newRank)) {
        return error("Cannot promote to this rank");
    }
    
    if (newRank == GuildRank.LEADER) {
        return error("Cannot promote to Leader");
    }
    
    // 4. Promote
    target.setRank(newRank);
    guildMemberRepository.save(target);
    
    // 5. Notify
    wsService.broadcastToGuild(promoter.getGuildId(),
        new MemberPromotedMessage(target.getPlayerId(), newRank));
    
    return PromoteResponse.success();
}
```

---

## API Endpoints

**POST `/api/v1/guilds/promote`** - promote
**POST `/api/v1/guilds/demote`** - demote
**GET `/api/v1/guilds/permissions`** - мои права

---

## Связанные документы

- `.BRAIN/05-technical/backend/guild/guild-management.md` - Management (микрофича 1/3)
- `.BRAIN/05-technical/backend/guild/guild-features.md` - Features (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:45)** - Микрофича 2/3: Guild Ranks (split from guild-system-backend.md)

