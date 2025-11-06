---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Chat Moderation микрофича. Profanity filter, spam detection, auto-ban, chat bans, moderation tools. ~380 строк.
---

# Chat Moderation - Модерация чата

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:30  
**Приоритет:** критический  
**Автор:** AI Brain Manager

**Микрофича:** Chat moderation  
**Размер:** ~380 строк ✅

---


**API Tasks Status:**
- 🚫 Документ отмечен как OBSOLETE (устаревшая split версия)
- 📝 Причина: Consolidated into unified document
- 🔄 Статус: not-applicable
- ⚠️ Этот документ является split версией, которая была объединена в consolidated документ

---

## Краткое описание

**Chat Moderation** - система модерации чата для защиты от спама, оскорблений и нарушений.

**Ключевые возможности:**
- ✅ Profanity filter (фильтр запрещенных слов)
- ✅ Spam detection (обнаружение спама)
- ✅ Auto-ban system (автоматические баны)
- ✅ Chat bans (временные и permanent)
- ✅ Admin moderation tools

---

## Database Schema

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

## Profanity Filter

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
            Pattern pattern = Pattern.compile(bannedWord, Pattern.CASE_INSENSITIVE);
            filtered = pattern.matcher(filtered).replaceAll("***");
        }
        
        // 2. Фильтр URL (только whitelist)
        Matcher urlMatcher = URL_PATTERN.matcher(filtered);
        while (urlMatcher.find()) {
            String url = urlMatcher.group();
            if (!isWhitelistedUrl(url)) {
                filtered = filtered.replace(url, "[LINK REMOVED]");
            }
        }
        
        // 3. Фильтр повторяющихся символов
        filtered = filtered.replaceAll("(.)\\1{3,}", "$1$1$1");
        
        // 4. Фильтр CAPS (если >70% uppercase)
        if (isExcessiveCaps(filtered)) {
            filtered = filtered.toLowerCase();
        }
        
        return filtered;
    }
    
    public boolean containsSevereViolation(String message) {
        for (String severeWord : SEVERE_VIOLATIONS) {
            if (message.toLowerCase().contains(severeWord)) {
                return true;
            }
        }
        return false;
    }
}
```

---

## Spam Detection

```java
@Service
public class SpamDetector {
    
    public boolean isSpam(UUID playerId, String message) {
        // 1. Rate limit (>10 сообщений в минуту)
        String rateLimitKey = "chat_rate:" + playerId;
        Long messageCount = redis.opsForValue().increment(rateLimitKey);
        
        if (messageCount == 1) {
            redis.expire(rateLimitKey, 60, TimeUnit.SECONDS);
        }
        
        if (messageCount > 10) {
            return true; // Spam!
        }
        
        // 2. Дублирование сообщений
        String lastMessagesKey = "chat_last:" + playerId;
        List<String> lastMessages = redis.opsForList()
            .range(lastMessagesKey, 0, 4);
        
        if (lastMessages != null && lastMessages.contains(message)) {
            return true; // Duplicate = spam
        }
        
        redis.opsForList().leftPush(lastMessagesKey, message);
        redis.opsForList().trim(lastMessagesKey, 0, 4);
        redis.expire(lastMessagesKey, 300, TimeUnit.SECONDS);
        
        return false;
    }
}
```

---

## Auto-Ban System

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
    
    log.warn("Player {} auto-banned for: {}", playerId, reason);
}
```

---

## API Endpoints

**POST `/api/v1/chat/report`** - пожаловаться на сообщение
**POST `/api/v1/chat/ban`** - забанить игрока (admin)
**GET `/api/v1/chat/bans`** - список банов (admin)
**DELETE `/api/v1/chat/bans/{id}`** - разбанить (admin)

---

## Связанные документы

- `.BRAIN/05-technical/backend/chat/chat-channels.md` - Channels (микрофича 1/3)
- `.BRAIN/05-technical/backend/chat/chat-features.md` - Features (микрофича 3/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Микрофича 2/3: Chat Moderation (split from chat-system.md)




