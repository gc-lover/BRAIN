---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:45  
**api-readiness-notes:** Guild Management микрофича. Creation, membership, invites, leave/kick. ~360 строк.
---

# Guild Management - Управление гильдиями

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:45  
**Приоритет:** средний (Tier 2)  
**Автор:** AI Brain Manager

**Микрофича:** Guild creation & membership  
**Размер:** ~360 строк ✅

---

## Краткое описание

**Guild Management** - создание гильдий, управление членством.

**Ключевые возможности:**
- ✅ Guild creation (cost: 10,000 credits)
- ✅ Invite system
- ✅ Accept/Decline invites
- ✅ Leave/Kick members
- ✅ Guild info (name, tag, description)

---

## Database Schema

```sql
CREATE TABLE guilds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Info
    name VARCHAR(100) UNIQUE NOT NULL,
    tag VARCHAR(10) UNIQUE NOT NULL,
    description TEXT,
    
    -- Leadership
    leader_id UUID NOT NULL,
    
    -- Stats
    member_count INTEGER DEFAULT 1,
    level INTEGER DEFAULT 1,
    experience BIGINT DEFAULT 0,
    
    -- Limits
    max_members INTEGER DEFAULT 50,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_guild_leader FOREIGN KEY (leader_id) 
        REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE guild_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guild_id UUID NOT NULL,
    player_id UUID NOT NULL,
    
    rank VARCHAR(50) DEFAULT 'MEMBER',
    -- LEADER, OFFICER, VETERAN, MEMBER, RECRUIT
    
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_member_guild FOREIGN KEY (guild_id) 
        REFERENCES guilds(id) ON DELETE CASCADE,
    CONSTRAINT fk_member_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id)
);

CREATE INDEX idx_guild_members ON guild_members(guild_id);
```

---

## Create Guild

```java
@PostMapping("/guilds/create")
@Transactional
public GuildResponse createGuild(
    @RequestHeader("Authorization") String token,
    @RequestBody CreateGuildRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Проверить, что не в гильдии
    if (guildMemberRepository.existsByPlayer(playerId)) {
        return error("Already in a guild");
    }
    
    // 2. Проверить баланс (10,000 credits)
    Player player = playerRepository.findById(playerId).orElseThrow();
    if (player.getCredits() < 10000) {
        return error("Insufficient credits");
    }
    
    // 3. Проверить уникальность name/tag
    if (guildRepository.existsByName(request.getName())) {
        return error("Guild name taken");
    }
    
    if (guildRepository.existsByTag(request.getTag())) {
        return error("Guild tag taken");
    }
    
    // 4. Создать гильдию
    Guild guild = new Guild();
    guild.setName(request.getName());
    guild.setTag(request.getTag());
    guild.setDescription(request.getDescription());
    guild.setLeaderId(playerId);
    
    guild = guildRepository.save(guild);
    
    // 5. Добавить создателя как LEADER
    GuildMember leader = new GuildMember();
    leader.setGuildId(guild.getId());
    leader.setPlayerId(playerId);
    leader.setRank(GuildRank.LEADER);
    
    guildMemberRepository.save(leader);
    
    // 6. Списать credits
    player.setCredits(player.getCredits() - 10000);
    playerRepository.save(player);
    
    return GuildResponse.success(guild);
}
```

---

## Invite Player

```java
@PostMapping("/guilds/invite")
public InviteResponse invitePlayer(
    @RequestHeader("Authorization") String token,
    @RequestBody InviteRequest request
) {
    UUID inviterId = extractPlayerId(token);
    
    // 1. Проверить permissions
    GuildMember inviter = guildMemberRepository.findByPlayer(inviterId).orElseThrow();
    if (!inviter.canInvite()) {
        return error("No permission to invite");
    }
    
    // 2. Проверить target
    Player target = playerRepository.findByUsername(request.getTargetUsername())
        .orElseThrow(() -> new PlayerNotFoundException());
    
    if (guildMemberRepository.existsByPlayer(target.getId())) {
        return error("Player already in a guild");
    }
    
    // 3. Проверить лимит
    Guild guild = guildRepository.findById(inviter.getGuildId()).orElseThrow();
    if (guild.getMemberCount() >= guild.getMaxMembers()) {
        return error("Guild full");
    }
    
    // 4. Создать invite
    GuildInvite invite = new GuildInvite();
    invite.setGuildId(guild.getId());
    invite.setInviterId(inviterId);
    invite.setTargetPlayerId(target.getId());
    invite.setExpiresAt(Instant.now().plus(Duration.ofDays(7)));
    
    guildInviteRepository.save(invite);
    
    // 5. Notify target
    wsService.sendToPlayer(target.getId(),
        new GuildInviteMessage(guild.getName(), guild.getTag()));
    
    return InviteResponse.success();
}
```

---

## Accept Invite

```java
@PostMapping("/guilds/invites/{inviteId}/accept")
@Transactional
public AcceptResponse acceptInvite(
    @RequestHeader("Authorization") String token,
    @PathVariable UUID inviteId
) {
    UUID playerId = extractPlayerId(token);
    
    // 1. Найти invite
    GuildInvite invite = guildInviteRepository.findById(inviteId).orElseThrow();
    
    if (!invite.getTargetPlayerId().equals(playerId)) {
        return error("Not your invite");
    }
    
    if (invite.isExpired()) {
        return error("Invite expired");
    }
    
    // 2. Добавить в гильдию
    GuildMember member = new GuildMember();
    member.setGuildId(invite.getGuildId());
    member.setPlayerId(playerId);
    member.setRank(GuildRank.RECRUIT);
    
    guildMemberRepository.save(member);
    
    // 3. Increment member_count
    Guild guild = guildRepository.findById(invite.getGuildId()).orElseThrow();
    guild.setMemberCount(guild.getMemberCount() + 1);
    guildRepository.save(guild);
    
    // 4. Delete invite
    guildInviteRepository.delete(invite);
    
    // 5. Notify guild
    wsService.broadcastToGuild(guild.getId(),
        new MemberJoinedMessage(playerId));
    
    return AcceptResponse.success(guild);
}
```

---

## Leave Guild

```java
@PostMapping("/guilds/leave")
@Transactional
public void leaveGuild(@RequestHeader("Authorization") String token) {
    UUID playerId = extractPlayerId(token);
    
    GuildMember member = guildMemberRepository.findByPlayer(playerId).orElseThrow();
    
    if (member.getRank() == GuildRank.LEADER) {
        throw new LeaderCannotLeaveException();
    }
    
    Guild guild = guildRepository.findById(member.getGuildId()).orElseThrow();
    
    // Remove
    guildMemberRepository.delete(member);
    
    // Decrement count
    guild.setMemberCount(guild.getMemberCount() - 1);
    guildRepository.save(guild);
    
    // Notify
    wsService.broadcastToGuild(guild.getId(),
        new MemberLeftMessage(playerId));
}
```

---

## API Endpoints

**POST `/api/v1/guilds/create`** - создать гильдию
**POST `/api/v1/guilds/invite`** - invite игрока
**POST `/api/v1/guilds/invites/{id}/accept`** - accept
**POST `/api/v1/guilds/leave`** - leave
**POST `/api/v1/guilds/kick`** - kick (officer+)

---

## Связанные документы

- `.BRAIN/05-technical/backend/guild/guild-ranks.md` - Ranks (микрофича 2/3)
- `.BRAIN/05-technical/backend/guild/guild-features.md` - Features (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:45)** - Микрофича 1/3: Guild Management (split from guild-system-backend.md)

