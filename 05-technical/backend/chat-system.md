---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-06 21:55  
**api-readiness-notes:** Полная система чата. Chat channels (global, local, party, guild, whisper), message persistence, moderation, timestamps, mentions, commands.
---

---
**API Tasks Status:**
- Status: created
- Tasks:
  - API-TASK-107: api/v1/technical/chat-system.yaml (2025-11-07)
- Last Updated: 2025-11-07 05:25
---

# Chat System - Система внутриигрового чата

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 21:55  
**Приоритет:** критический  
**Автор:** AI Brain Manager

---

## Краткое описание

**Chat System** - система внутриигрового чата для коммуникации между игроками. Поддерживает различные каналы, модерацию, историю сообщений, mentions, commands и интеграцию с другими системами игры.

**Ключевые возможности:**
- ✅ Multiple channels (global, local, party, guild, whisper, trade, combat)
- ✅ Message persistence (история сообщений)
- ✅ Moderation (фильтры, бан слов, spam protection)
- ✅ Mentions (@player) и emojis
- ✅ Slash commands (/commands)
- ✅ Rich formatting (bold, italic, links)
- ✅ Voice chat integration (WebRTC)
- ✅ Translation support (автоперевод)

---

## Chat Channels (Типы каналов)

### 1. Global Channels

**GLOBAL (Глобальный):**
- Scope: Весь сервер
- Cooldown: 5 секунд между сообщениями
- Max message length: 200 символов
- Moderation: Строгая (фильтр + admins)

**TRADE (Торговля):**
- Scope: Весь сервер
- Cooldown: 30 секунд (anti-spam)
- Max message length: 300 символов
- Only for: Торговые объявления, WTS/WTB

**NEWBIE (Новички):**
- Scope: Игроки level 1-20
- Cooldown: 2 секунды
- Max message length: 200 символов
- Helpers: Опытные игроки могут помогать

### 2. Local Channels

**LOCAL (Локальный):**
- Scope: Текущая зона (radius 100m)
- Cooldown: Нет
- Max message length: 300 символов
- Real-time (видят только рядом стоящие игроки)

**ZONE (Зона):**
- Scope: Текущая зона/район (Watson, Westbrook)
- Cooldown: 3 секунды
- Max message length: 250 символов

**INSTANCE (Инстанс):**
- Scope: Текущий инстанс (dungeon, raid)
- Cooldown: Нет
- Max message length: 500 символов
- Автоматически active в dungeons/raids

### 3. Group Channels

**PARTY (Группа):**
- Scope: Члены party (max 5 players)
- Cooldown: Нет
- Max message length: 500 символов
- Поддержка тактических команд

**RAID (Рейд):**
- Scope: Члены raid (max 15 players)
- Cooldown: Нет
- Max message length: 500 символов
- Поддержка raid leader commands

**GUILD (Гильдия):**
- Scope: Члены гильдии
- Cooldown: 1 секунда
- Max message length: 500 символов
- Поддержка guild events notifications

**GUILD_OFFICER (Офицеры):**
- Scope: Офицеры гильдии
- Cooldown: Нет
- Max message length: 1000 символов
- Private для обсуждения стратегии

### 4. Private Channels

**WHISPER (Личное):**
- Scope: 1-на-1 сообщения
- Cooldown: Нет
- Max message length: 1000 символов
- История сохраняется 30 дней

**SYSTEM (Системные):**
- Scope: Уведомления от системы
- Только read-only (игроки не могут писать)
- Квест updates, rewards, achievements

### 5. Combat Channels

**COMBAT_LOG (Боевой лог):**
- Scope: Текущий бой
- Только read-only
- Авто-генерируемые сообщения: урон, хилы, смерти

**EMOTE (Эмоции):**
- Scope: Local (radius 100m)
- Cooldown: Нет
- Max message length: 100 символов
- Для RP (roleplay) сообщений: "/wave", "/dance"

---

## Database Schema

### Таблица `chat_messages`

```sql
CREATE TABLE chat_messages (
    id BIGSERIAL PRIMARY KEY,
    
    -- Отправитель
    sender_id UUID NOT NULL,
    sender_name VARCHAR(100) NOT NULL, -- Кэшируем для быстрого доступа
    sender_title VARCHAR(200), -- Титул игрока (если есть)
    
    -- Получатель (для WHISPER)
    recipient_id UUID, -- Для WHISPER, NULL для остальных
    recipient_name VARCHAR(100),
    
    -- Канал
    channel_type VARCHAR(50) NOT NULL,
    -- GLOBAL, LOCAL, ZONE, PARTY, RAID, GUILD, WHISPER, TRADE, SYSTEM, etc
    
    channel_id VARCHAR(100), -- ID channel (party_id, guild_id, zone_id)
    
    -- Сообщение
    message_text TEXT NOT NULL,
    message_html TEXT, -- Formatted version (bold, links, etc)
    
    -- Метаданные
    message_type VARCHAR(20) DEFAULT 'TEXT',
    -- TEXT, EMOTE, SYSTEM, COMMAND_RESULT, LINK, IMAGE
    
    language VARCHAR(10) DEFAULT 'en', -- Язык сообщения
    
    -- Mentions
    mentions JSONB, -- Array of mentioned player IDs
    
    -- Модерация
    is_flagged BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_by UUID, -- Admin who deleted
    deleted_reason VARCHAR(200),
    
    -- Timestamp
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edited_at TIMESTAMP,
    
    -- Сервер (для cross-server chat)
    server_id VARCHAR(100) NOT NULL,
    
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_message_recipient FOREIGN KEY (recipient_id) 
        REFERENCES players(id) ON DELETE SET NULL,
    CONSTRAINT fk_message_deleted_by FOREIGN KEY (deleted_by) 
        REFERENCES players(id) ON DELETE SET NULL
);

CREATE INDEX idx_messages_channel ON chat_messages(channel_type, channel_id, created_at DESC);
CREATE INDEX idx_messages_sender ON chat_messages(sender_id, created_at DESC);
CREATE INDEX idx_messages_recipient ON chat_messages(recipient_id, created_at DESC) 
    WHERE recipient_id IS NOT NULL;
CREATE INDEX idx_messages_created ON chat_messages(created_at DESC);
CREATE INDEX idx_messages_flagged ON chat_messages(is_flagged) 
    WHERE is_flagged = TRUE;

-- Partition by month (для больших объемов)
-- CREATE TABLE chat_messages_2025_11 PARTITION OF chat_messages
-- FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
```

### Таблица `chat_channels`

```sql
CREATE TABLE chat_channels (
    id VARCHAR(100) PRIMARY KEY,
    
    -- Тип канала
    channel_type VARCHAR(50) NOT NULL,
    
    -- Название (для custom channels)
    channel_name VARCHAR(100),
    
    -- Владелец (для custom/private channels)
    owner_id UUID,
    
    -- Члены (для private group chats)
    members JSONB, -- Array of player IDs
    
    -- Настройки
    max_members INTEGER,
    is_public BOOLEAN DEFAULT TRUE,
    is_moderated BOOLEAN DEFAULT FALSE,
    
    -- Permissions
    can_read JSONB, -- Array of roles/player IDs who can read
    can_write JSONB, -- Array of roles/player IDs who can write
    can_moderate JSONB, -- Array of moderator IDs
    
    -- Cooldowns
    message_cooldown INTEGER DEFAULT 0, -- Seconds
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_channel_owner FOREIGN KEY (owner_id) 
        REFERENCES players(id) ON DELETE SET NULL
);

CREATE INDEX idx_channels_type ON chat_channels(channel_type);
CREATE INDEX idx_channels_owner ON chat_channels(owner_id);
```

### Таблица `chat_bans`

```sql
CREATE TABLE chat_bans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Забаненный игрок
    player_id UUID NOT NULL,
    
    -- Канал (NULL = global ban)
    channel_type VARCHAR(50),
    channel_id VARCHAR(100),
    
    -- Причина и админ
    reason VARCHAR(500) NOT NULL,
    banned_by UUID NOT NULL,
    
    -- Длительность
    banned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- NULL = permanent
    
    -- Статус
    is_active BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT fk_ban_player FOREIGN KEY (player_id) 
        REFERENCES players(id) ON DELETE CASCADE,
    CONSTRAINT fk_ban_admin FOREIGN KEY (banned_by) 
        REFERENCES players(id) ON DELETE SET NULL
);

CREATE INDEX idx_bans_player ON chat_bans(player_id, is_active);
CREATE INDEX idx_bans_expires ON chat_bans(expires_at) 
    WHERE expires_at IS NOT NULL AND is_active = TRUE;
```

---

## Message Flow

### Отправка сообщения

```
Client → WebSocket → Chat Service
                          ↓
                    Validate (spam, banned, cooldown)
                          ↓
                    Process (mentions, commands, links)
                          ↓
                    Moderate (filter bad words)
                          ↓
                    Save to DB
                          ↓
                    Publish to Redis
                          ↓
                    WebSocket → Recipients
```

### Реализация

```java
@Service
public class ChatService {
    
    @Autowired
    private ChatRepository chatRepository;
    
    @Autowired
    private ModerationService moderationService;
    
    @Autowired
    private RedisTemplate<String, Object> redis;
    
    @Autowired
    private WebSocketService wsService;
    
    public ChatMessageResponse sendMessage(
        UUID senderId,
        ChatMessageRequest request
    ) {
        // 1. Валидация
        validateMessage(senderId, request);
        
        // 2. Проверить бан
        if (isBanned(senderId, request.getChannelType())) {
            throw new ChatBannedException("You are banned from this channel");
        }
        
        // 3. Проверить cooldown
        if (!checkCooldown(senderId, request.getChannelType())) {
            throw new CooldownException("Please wait before sending next message");
        }
        
        // 4. Обработать slash commands
        if (request.getMessage().startsWith("/")) {
            return handleCommand(senderId, request.getMessage());
        }
        
        // 5. Модерация
        String filteredMessage = moderationService.filterMessage(request.getMessage());
        
        if (moderationService.containsSevereViolation(filteredMessage)) {
            // Auto-ban за серьезные нарушения
            autoBan(senderId, "Severe chat violation", Duration.ofHours(24));
            throw new ChatViolationException("Message blocked due to violation");
        }
        
        // 6. Обработать mentions
        List<UUID> mentions = extractMentions(filteredMessage);
        
        // 7. Создать сообщение
        ChatMessage message = new ChatMessage();
        message.setSenderId(senderId);
        message.setSenderName(getPlayerName(senderId));
        message.setChannelType(request.getChannelType());
        message.setChannelId(request.getChannelId());
        message.setRecipientId(request.getRecipientId());
        message.setMessageText(filteredMessage);
        message.setMessageHtml(formatMessage(filteredMessage));
        message.setMentions(mentions);
        message.setServerId(getServerId(senderId));
        
        // 8. Сохранить в БД (асинхронно)
        chatRepository.saveAsync(message);
        
        // 9. Кэшировать в Redis (для history)
        String cacheKey = "chat_history:" + request.getChannelType() + ":" + 
                          request.getChannelId();
        redis.opsForList().leftPush(cacheKey, message);
        redis.opsForList().trim(cacheKey, 0, 99); // Последние 100 сообщений
        redis.expire(cacheKey, 1, TimeUnit.HOURS);
        
        // 10. Отправить получателям
        List<UUID> recipients = getRecipients(request.getChannelType(), request.getChannelId());
        
        for (UUID recipientId : recipients) {
            wsService.sendToPlayer(recipientId, new ChatMessageEvent(
                message.getId(),
                message.getSenderId(),
                message.getSenderName(),
                message.getChannelType(),
                filteredMessage,
                message.getCreatedAt()
            ));
        }
        
        // 11. Уведомить упомянутых игроков
        for (UUID mentionedId : mentions) {
            notificationService.send(mentionedId, new MentionNotification(
                senderId,
                request.getChannelType(),
                filteredMessage
            ));
        }
        
        // 12. Обновить cooldown
        updateCooldown(senderId, request.getChannelType());
        
        return new ChatMessageResponse(message.getId(), "Message sent");
    }
}
```

---

## Channel Recipients

### Определение получателей

```java
private List<UUID> getRecipients(ChannelType channelType, String channelId) {
    switch (channelType) {
        case GLOBAL:
            // Все онлайн игроки на сервере
            return sessionService.getAllActivePlayers(getServerId());
            
        case LOCAL:
            // Игроки в радиусе 100m
            return locationService.getPlayersNearby(getSenderId(), 100);
            
        case ZONE:
            // Игроки в зоне
            return locationService.getPlayersInZone(channelId);
            
        case PARTY:
            // Члены party
            return partyService.getMembers(UUID.fromString(channelId));
            
        case RAID:
            // Члены raid
            return raidService.getMembers(UUID.fromString(channelId));
            
        case GUILD:
            // Онлайн члены гильдии
            return guildService.getOnlineMembers(UUID.fromString(channelId));
            
        case WHISPER:
            // Только получатель
            return List.of(getRecipientId());
            
        case TRADE:
            // Все онлайн игроки на сервере
            return sessionService.getAllActivePlayers(getServerId());
            
        default:
            return List.of();
    }
}
```

---

## Message Moderation (Модерация)

### Profanity Filter

```java
@Service
public class ModerationService {
    
    private static final List<String> BANNED_WORDS = loadBannedWords();
    private static final Pattern URL_PATTERN = Pattern.compile(
        "https?://[\\w./\\-?=#]+"
    );
    
    public String filterMessage(String message) {
        String filtered = message;
        
        // 1. Фильтр запрещенных слов
        for (String bannedWord : BANNED_WORDS) {
            // Case-insensitive replacement
            Pattern pattern = Pattern.compile(
                bannedWord, 
                Pattern.CASE_INSENSITIVE
            );
            filtered = pattern.matcher(filtered).replaceAll("***");
        }
        
        // 2. Фильтр URL (разрешены только whitelist)
        Matcher urlMatcher = URL_PATTERN.matcher(filtered);
        while (urlMatcher.find()) {
            String url = urlMatcher.group();
            if (!isWhitelistedUrl(url)) {
                filtered = filtered.replace(url, "[LINK REMOVED]");
            }
        }
        
        // 3. Фильтр повторяющихся символов
        // "AAAAAAAA" → "AAA"
        filtered = filtered.replaceAll("(.)\\1{3,}", "$1$1$1");
        
        // 4. Фильтр CAPS (если >70% в верхнем регистре)
        if (isExcessiveCaps(filtered)) {
            filtered = filtered.toLowerCase();
        }
        
        return filtered;
    }
    
    public boolean containsSevereViolation(String message) {
        // Проверка на серьезные нарушения
        // (hate speech, threats, doxxing, etc)
        for (String severeWord : SEVERE_VIOLATIONS) {
            if (message.toLowerCase().contains(severeWord)) {
                return true;
            }
        }
        return false;
    }
    
    private boolean isExcessiveCaps(String message) {
        if (message.length() < 10) return false;
        
        long upperCount = message.chars()
            .filter(Character::isUpperCase)
            .count();
        
        return (double) upperCount / message.length() > 0.7;
    }
}
```

### Spam Detection

```java
@Service
public class SpamDetector {
    
    public boolean isSpam(UUID playerId, String message) {
        // 1. Проверить количество сообщений за последнюю минуту
        String rateLimitKey = "chat_rate:" + playerId;
        Long messageCount = redis.opsForValue().increment(rateLimitKey);
        
        if (messageCount == 1) {
            redis.expire(rateLimitKey, 60, TimeUnit.SECONDS);
        }
        
        if (messageCount > 10) {
            // >10 сообщений в минуту = spam
            return true;
        }
        
        // 2. Проверить дублирование сообщений
        String lastMessagesKey = "chat_last:" + playerId;
        List<String> lastMessages = redis.opsForList()
            .range(lastMessagesKey, 0, 4); // Последние 5 сообщений
        
        if (lastMessages != null && lastMessages.contains(message)) {
            // Дублирование сообщения = spam
            return true;
        }
        
        // Сохранить сообщение
        redis.opsForList().leftPush(lastMessagesKey, message);
        redis.opsForList().trim(lastMessagesKey, 0, 4);
        redis.expire(lastMessagesKey, 300, TimeUnit.SECONDS); // 5 минут
        
        return false;
    }
}
```

### Auto-Ban System

```java
private void autoBan(UUID playerId, String reason, Duration duration) {
    ChatBan ban = new ChatBan();
    ban.setPlayerId(playerId);
    ban.setChannelType(null); // Global ban
    ban.setReason(reason);
    ban.setBannedBy(SYSTEM_USER_ID);
    ban.setExpiresAt(Instant.now().plus(duration));
    
    chatBanRepository.save(ban);
    
    // Уведомить игрока
    wsService.sendToPlayer(playerId, new ChatBanNotification(
        reason,
        duration.toHours() + " hours"
    ));
    
    // Логировать
    log.warn("Player {} auto-banned for: {}", playerId, reason);
}
```

---

## Slash Commands (Команды)

### Общие команды

```
/help                     - Список команд
/whisper <player> <msg>   - Личное сообщение (/w)
/reply <msg>              - Ответ на whisper (/r)
/ignore <player>          - Игнорировать игрока
/unignore <player>        - Разигнорировать
/block <player>           - Заблокировать (+ ignore)
/report <player> <reason> - Пожаловаться на игрока
/mute <player>            - Временно mute (если модератор)
```

### Party/Raid команды

```
/party <msg>     - Сообщение в party
/raid <msg>      - Сообщение в raid
/say <msg>       - Local chat
/yell <msg>      - Zone chat (громко)
```

### Emotes

```
/wave            - Помахать рукой
/dance           - Танцевать
/laugh           - Смеяться
/sit             - Сесть
/salute          - Отдать честь
```

### Admin команды

```
/ban <player> <duration> <reason>    - Забанить игрока
/unban <player>                      - Разбанить
/kick <player> <reason>              - Кикнуть из channel
/clear                               - Очистить chat (для всех)
/announce <msg>                      - Announcement (для всех)
```

### Реализация

```java
@Service
public class ChatCommandHandler {
    
    public ChatMessageResponse handleCommand(UUID playerId, String command) {
        String[] parts = command.split(" ", 3);
        String cmd = parts[0].toLowerCase();
        
        switch (cmd) {
            case "/whisper":
            case "/w":
                if (parts.length < 3) {
                    return new ChatMessageResponse(null, "Usage: /w <player> <message>");
                }
                return handleWhisper(playerId, parts[1], parts[2]);
                
            case "/reply":
            case "/r":
                if (parts.length < 2) {
                    return new ChatMessageResponse(null, "Usage: /r <message>");
                }
                return handleReply(playerId, parts[1]);
                
            case "/ignore":
                return handleIgnore(playerId, parts[1]);
                
            case "/report":
                if (parts.length < 3) {
                    return new ChatMessageResponse(null, "Usage: /report <player> <reason>");
                }
                return handleReport(playerId, parts[1], parts[2]);
                
            case "/wave":
                return handleEmote(playerId, "waves");
                
            // Admin commands
            case "/ban":
                if (!isAdmin(playerId)) {
                    return new ChatMessageResponse(null, "Insufficient permissions");
                }
                return handleBan(playerId, parts);
                
            default:
                return new ChatMessageResponse(null, "Unknown command: " + cmd);
        }
    }
    
    private ChatMessageResponse handleWhisper(
        UUID senderId, 
        String recipientName, 
        String message
    ) {
        // Найти получателя
        Player recipient = playerRepository.findByName(recipientName);
        
        if (recipient == null) {
            return new ChatMessageResponse(null, "Player not found");
        }
        
        if (!sessionService.isOnline(recipient.getId())) {
            return new ChatMessageResponse(null, "Player is offline");
        }
        
        // Отправить whisper
        return sendMessage(senderId, new ChatMessageRequest(
            ChannelType.WHISPER,
            null,
            recipient.getId(),
            message
        ));
    }
}
```

---

## Message Formatting

### Rich Text Support

```
**bold text**          → <strong>bold text</strong>
*italic text*          → <em>italic text</em>
[link](http://...)     → <a href="...">link</a>
:emoji:                → 😀 (emoji replacement)
@PlayerName            → <mention>PlayerName</mention>
```

### Формирование HTML

```java
private String formatMessage(String text) {
    String html = text;
    
    // 1. Bold
    html = html.replaceAll("\\*\\*(.+?)\\*\\*", "<strong>$1</strong>");
    
    // 2. Italic
    html = html.replaceAll("\\*(.+?)\\*", "<em>$1</em>");
    
    // 3. Links (whitelisted only)
    html = html.replaceAll(
        "\\[(.+?)\\]\\((https?://[^\\)]+)\\)",
        "<a href=\"$2\" target=\"_blank\">$1</a>"
    );
    
    // 4. Emoji codes
    html = replaceEmojis(html);
    
    // 5. Mentions
    html = formatMentions(html);
    
    // 6. Escape HTML (защита от XSS)
    html = escapeHtml(html);
    
    return html;
}

private String formatMentions(String text) {
    Pattern pattern = Pattern.compile("@(\\w+)");
    Matcher matcher = pattern.matcher(text);
    
    StringBuffer sb = new StringBuffer();
    while (matcher.find()) {
        String playerName = matcher.group(1);
        UUID playerId = findPlayerIdByName(playerName);
        
        if (playerId != null) {
            matcher.appendReplacement(sb, 
                "<mention data-player-id=\"" + playerId + "\">@" + playerName + "</mention>");
        }
    }
    matcher.appendTail(sb);
    
    return sb.toString();
}
```

---

## Message History (История сообщений)

### Get History

```java
@GetMapping("/chat/history/{channelType}")
public ResponseEntity<ChatHistoryResponse> getHistory(
    @PathVariable ChannelType channelType,
    @RequestParam(required = false) String channelId,
    @RequestParam(defaultValue = "50") int limit,
    @RequestParam(required = false) Long beforeMessageId
) {
    // 1. Попробовать из Redis cache
    String cacheKey = "chat_history:" + channelType + ":" + channelId;
    List<ChatMessage> cached = redis.opsForList().range(cacheKey, 0, limit - 1);
    
    if (cached != null && !cached.isEmpty()) {
        return ResponseEntity.ok(new ChatHistoryResponse(cached));
    }
    
    // 2. Из БД
    List<ChatMessage> messages;
    
    if (beforeMessageId != null) {
        // Pagination
        messages = chatRepository.findByChannelBefore(
            channelType,
            channelId,
            beforeMessageId,
            limit
        );
    } else {
        messages = chatRepository.findByChannelLatest(
            channelType,
            channelId,
            limit
        );
    }
    
    // 3. Кэшировать
    if (beforeMessageId == null) {
        redis.opsForList().rightPushAll(cacheKey, messages);
        redis.expire(cacheKey, 1, TimeUnit.HOURS);
    }
    
    return ResponseEntity.ok(new ChatHistoryResponse(messages));
}
```

### Message Retention

```
WHISPER: 30 days
PARTY: 7 days
RAID: 7 days
GUILD: 90 days
GLOBAL/LOCAL/ZONE: 3 days
SYSTEM: 7 days
```

**Cleanup Job:**
```java
@Scheduled(cron = "0 0 2 * * *") // Каждый день в 2 AM
public void cleanupOldMessages() {
    Instant now = Instant.now();
    
    chatRepository.deleteWhere(
        ChannelType.WHISPER,
        now.minus(Duration.ofDays(30))
    );
    
    chatRepository.deleteWhere(
        ChannelType.PARTY,
        now.minus(Duration.ofDays(7))
    );
    
    // ... и т.д.
    
    log.info("Cleaned up old chat messages");
}
```

---

## Voice Chat Integration

### WebRTC для голосового чата

**Channels:**
- Party Voice (автоматически при создании party)
- Raid Voice (для raid coordination)
- Guild Voice (для guild events)

**Технология:**
- WebRTC для peer-to-peer connections
- TURN/STUN servers для NAT traversal
- Opus codec для audio

**API:**

```
POST /api/v1/chat/voice/join
POST /api/v1/chat/voice/leave
GET /api/v1/chat/voice/participants
POST /api/v1/chat/voice/mute
POST /api/v1/chat/voice/unmute
```

**Signaling через WebSocket:**
```json
{
  "type": "VOICE_OFFER",
  "sdp": "...",
  "channelId": "party-uuid"
}
```

---

## Translation Support

### Auto-Translation

**Концепция:** Игроки могут писать на родном языке, другие видят перевод

**Настройки игрока:**
```json
{
  "preferredLanguage": "en",
  "autoTranslate": true,
  "translateChannels": ["GLOBAL", "TRADE", "ZONE"]
}
```

**Flow:**
```
Player writes in Russian: "Привет!"
  ↓
Server detects language: RU
  ↓
For each recipient:
  - If recipient.preferredLanguage == "ru" → send "Привет!"
  - If recipient.preferredLanguage == "en" → translate → send "Hello!"
```

**API Integration:**
```java
@Service
public class TranslationService {
    
    @Autowired
    private GoogleTranslateClient translateClient;
    
    public Map<String, String> translateMessage(String text, List<String> targetLanguages) {
        Map<String, String> translations = new HashMap<>();
        
        // Определить исходный язык
        String sourceLanguage = detectLanguage(text);
        
        // Перевести на целевые языки
        for (String targetLang : targetLanguages) {
            if (targetLang.equals(sourceLanguage)) {
                translations.put(targetLang, text); // Оригинал
            } else {
                String translated = translateClient.translate(
                    text,
                    sourceLanguage,
                    targetLang
                );
                translations.put(targetLang, translated);
            }
        }
        
        return translations;
    }
}
```

---

## API Endpoints

### Message Management

**POST `/api/v1/chat/send`** - отправить сообщение
```json
Request:
{
  "channelType": "PARTY",
  "channelId": "party-uuid",
  "message": "Let's go to raid!",
  "recipientId": null
}

Response:
{
  "messageId": 12345,
  "status": "SENT",
  "timestamp": "2025-11-06T21:30:00Z"
}
```

**GET `/api/v1/chat/history/{channelType}`** - история сообщений

**DELETE `/api/v1/chat/messages/{id}`** - удалить сообщение (свое или admin)

**PUT `/api/v1/chat/messages/{id}/edit`** - редактировать сообщение
```json
{
  "newMessage": "Updated text"
}
```

### Channel Management

**GET `/api/v1/chat/channels`** - список доступных каналов
**POST `/api/v1/chat/channels/join`** - присоединиться к каналу
**POST `/api/v1/chat/channels/leave`** - покинуть канал

### Moderation

**POST `/api/v1/chat/report`** - пожаловаться на сообщение
```json
{
  "messageId": 12345,
  "reason": "SPAM | HARASSMENT | INAPPROPRIATE"
}
```

**POST `/api/v1/chat/ban`** - забанить игрока (admin)
**GET `/api/v1/chat/bans`** - список банов (admin)

### Preferences

**GET `/api/v1/chat/settings`** - настройки чата игрока
**PUT `/api/v1/chat/settings`** - обновить настройки
```json
{
  "autoTranslate": true,
  "preferredLanguage": "en",
  "profanityFilter": true,
  "showTimestamps": true,
  "fontSize": "medium",
  "notifications": {
    "whispers": true,
    "mentions": true,
    "guildChat": false
  }
}
```

---

## WebSocket Events

### Chat Messages

**Topic:** `/topic/chat/{channelType}/{channelId}`

**Event:**
```json
{
  "type": "CHAT_MESSAGE",
  "messageId": 12345,
  "senderId": "uuid",
  "senderName": "PlayerName",
  "senderTitle": "Guild Master",
  "channelType": "GUILD",
  "message": "Hello everyone!",
  "messageHtml": "<p>Hello everyone!</p>",
  "mentions": ["player-uuid-1"],
  "timestamp": "2025-11-06T21:30:00Z"
}
```

### Typing Indicator

```json
{
  "type": "PLAYER_TYPING",
  "playerId": "uuid",
  "playerName": "PlayerName",
  "channelType": "PARTY"
}
```

### Player Online/Offline

```json
{
  "type": "PLAYER_STATUS",
  "playerId": "uuid",
  "status": "ONLINE | OFFLINE",
  "channelType": "GUILD"
}
```

---

## Интеграция с другими системами

### При создании Party

```
PartyService.createParty()
  ↓
ChatService.createChannel(PARTY, partyId)
  ↓
Notify all members: "Party chat created"
```

### При получении Whisper

```
ChatService.sendMessage(WHISPER)
  ↓
NotificationService.send(recipient, "New whisper from PlayerName")
```

### При Guild Event

```
GuildService.triggerEvent()
  ↓
ChatService.sendSystemMessage(GUILD, "Guild raid starts in 10 minutes!")
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/session-management-system.md` - Session management
- `.BRAIN/02-gameplay/social/guilds-overview.md` - Guild system
- `.BRAIN/02-gameplay/social/party-system.md` - Party system
- `.BRAIN/05-technical/global-state-system.md` - Global state

---

## TODO

- [ ] Voice chat WebRTC implementation details
- [ ] Translation service integration (Google Translate API)
- [ ] Chat analytics (популярные каналы, активность)
- [ ] Rich media support (images, gifs)

---

## История изменений

- **v1.0.0 (2025-11-06 21:55)** - Создан документ Chat System

