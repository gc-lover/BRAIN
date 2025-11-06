---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:45  
**api-readiness-notes:** Guild Features микрофича. Guild bank, events, progression, chat. ~350 строк.
---

# Guild Features - Функционал гильдий

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:45  
**Приоритет:** средний (Tier 2)  
**Автор:** AI Brain Manager

**Микрофича:** Guild bank, events, progression  
**Размер:** ~350 строк ✅

---

## Краткое описание

**Guild Features** - дополнительные возможности гильдий (bank, events, progression).

**Ключевые возможности:**
- ✅ Guild bank (shared storage)
- ✅ Guild events
- ✅ Guild progression (levels, perks)
- ✅ Guild chat

---

## Guild Bank

```sql
CREATE TABLE guild_bank_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guild_id UUID NOT NULL,
    
    tab_index INTEGER NOT NULL, -- 0-4 (5 tabs)
    slot_index INTEGER NOT NULL,
    
    item_template_id VARCHAR(100) NOT NULL,
    stack_size INTEGER DEFAULT 1,
    
    deposited_by UUID,
    deposited_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_bank_guild FOREIGN KEY (guild_id) 
        REFERENCES guilds(id) ON DELETE CASCADE,
    UNIQUE(guild_id, tab_index, slot_index)
);
```

```java
@PostMapping("/guilds/bank/deposit")
@Transactional
public BankResponse depositToGuildBank(
    @RequestHeader("Authorization") String token,
    @RequestBody GuildBankDepositRequest request
) {
    UUID playerId = extractPlayerId(token);
    
    // Check permission
    if (!hasPermission(playerId, GuildPermission.BANK_DEPOSIT)) {
        return error("No permission");
    }
    
    GuildMember member = guildMemberRepository.findByPlayer(playerId).orElseThrow();
    Character character = getActiveCharacter(playerId);
    
    // Remove from inventory
    InventoryItem item = inventoryRepository
        .findByCharacterAndSlot(character.getId(), request.getSlotIndex())
        .orElseThrow();
    
    // Add to guild bank
    int slot = findEmptyGuildBankSlot(member.getGuildId(), request.getTabIndex());
    
    GuildBankItem bankItem = new GuildBankItem();
    bankItem.setGuildId(member.getGuildId());
    bankItem.setTabIndex(request.getTabIndex());
    bankItem.setSlotIndex(slot);
    bankItem.setItemTemplateId(item.getItemTemplateId());
    bankItem.setStackSize(item.getStackSize());
    bankItem.setDepositedBy(playerId);
    
    guildBankItemRepository.save(bankItem);
    inventoryRepository.delete(item);
    
    return BankResponse.success();
}
```

---

## Guild Progression

```java
public class GuildProgression {
    
    public void addExperience(UUID guildId, long exp) {
        Guild guild = guildRepository.findById(guildId).orElseThrow();
        
        guild.setExperience(guild.getExperience() + exp);
        
        // Check level up
        while (guild.getExperience() >= getRequiredExp(guild.getLevel())) {
            guild.setExperience(guild.getExperience() - getRequiredExp(guild.getLevel()));
            guild.setLevel(guild.getLevel() + 1);
            
            // Unlock perks
            unlockGuildPerks(guild);
            
            // Notify
            wsService.broadcastToGuild(guildId,
                new GuildLevelUpMessage(guild.getLevel()));
        }
        
        guildRepository.save(guild);
    }
    
    private long getRequiredExp(int level) {
        return 1000L * level * level;
    }
}

// Guild Perks
public enum GuildPerk {
    INCREASED_BANK_SLOTS,     // +50 slots per level
    INCREASED_MAX_MEMBERS,    // +10 members per level
    GUILD_TELEPORT,           // Level 5
    GUILD_BONUS_EXP,          // +5% exp (level 10)
    GUILD_RAID_BUFFS          // Raid buffs (level 15)
}
```

---

## Guild Events

```sql
CREATE TABLE guild_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guild_id UUID NOT NULL,
    
    event_type VARCHAR(50) NOT NULL,
    -- RAID, PVP_TOURNAMENT, GUILD_WAR, MEETING
    
    title VARCHAR(200) NOT NULL,
    description TEXT,
    
    scheduled_at TIMESTAMP NOT NULL,
    duration_minutes INTEGER,
    
    created_by UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_event_guild FOREIGN KEY (guild_id) 
        REFERENCES guilds(id) ON DELETE CASCADE
);
```

---

## Guild Chat

```java
@MessageMapping("/guild/chat")
@SendTo("/topic/guild/{guildId}/chat")
public GuildChatMessage sendGuildMessage(
    @Payload ChatMessageRequest request,
    @DestinationVariable UUID guildId,
    Principal principal
) {
    UUID playerId = UUID.fromString(principal.getName());
    
    // Check permission
    if (!hasPermission(playerId, GuildPermission.CHAT)) {
        throw new NoPermissionException();
    }
    
    // Save to DB
    GuildChatMessage message = new GuildChatMessage();
    message.setGuildId(guildId);
    message.setSenderId(playerId);
    message.setContent(request.getContent());
    
    guildChatRepository.save(message);
    
    return message;
}
```

---

## API Endpoints

**POST `/api/v1/guilds/bank/deposit`** - guild bank deposit
**POST `/api/v1/guilds/bank/withdraw`** - withdraw
**GET `/api/v1/guilds/events`** - guild events
**POST `/api/v1/guilds/events`** - create event
**WS `/app/guild/chat`** - guild chat

---

## Связанные документы

- `.BRAIN/05-technical/backend/guild/guild-management.md` - Management (микрофича 1/3)
- `.BRAIN/05-technical/backend/guild/guild-ranks.md` - Ranks (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:45)** - Микрофича 3/3: Guild Features (split from guild-system-backend.md)

