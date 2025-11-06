---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Chat Features микрофича. Slash commands, rich formatting, voice chat, translation, message history. ~370 строк.
---

# Chat Features - Возможности чата

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 05:30  
**Приоритет:** критический  
**Автор:** AI Brain Manager

**Микрофича:** Chat features  
**Размер:** ~370 строк ✅

---

## Краткое описание

**Chat Features** - дополнительные возможности чата (команды, форматирование, voice chat, переводы).

**Ключевые возможности:**
- ✅ Slash commands (/whisper, /party, /help)
- ✅ Rich formatting (bold, italic, links)
- ✅ Mentions (@player)
- ✅ Voice chat integration (WebRTC)
- ✅ Translation support (автоперевод)
- ✅ Message history (pagination)

---

## Slash Commands

### Общие команды

```
/help                     - Список команд
/whisper <player> <msg>   - Личное сообщение (/w)
/reply <msg>              - Ответ на whisper (/r)
/ignore <player>          - Игнорировать
/unignore <player>        - Разигнорировать
/block <player>           - Заблокировать
/report <player> <reason> - Пожаловаться
```

### Party/Raid команды

```
/party <msg>     - Сообщение в party
/raid <msg>      - Сообщение в raid
/say <msg>       - Local chat
/yell <msg>      - Zone chat
```

### Emotes

```
/wave     - Помахать
/dance    - Танцевать
/laugh    - Смеяться
/sit      - Сесть
/salute   - Отдать честь
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
                    return error("Usage: /w <player> <message>");
                }
                return handleWhisper(playerId, parts[1], parts[2]);
                
            case "/reply":
            case "/r":
                if (parts.length < 2) {
                    return error("Usage: /r <message>");
                }
                return handleReply(playerId, parts[1]);
                
            case "/ignore":
                return handleIgnore(playerId, parts[1]);
                
            case "/wave":
                return handleEmote(playerId, "waves");
                
            default:
                return error("Unknown command: " + cmd);
        }
    }
}
```

---

## Rich Formatting

### Supported Formats

```
**bold text**          → <strong>bold text</strong>
*italic text*          → <em>italic text</em>
[link](http://...)     → <a href="...">link</a>
:emoji:                → 😀
@PlayerName            → <mention>PlayerName</mention>
```

### Implementation

```java
private String formatMessage(String text) {
    String html = text;
    
    // Bold
    html = html.replaceAll("\\*\\*(.+?)\\*\\*", "<strong>$1</strong>");
    
    // Italic
    html = html.replaceAll("\\*(.+?)\\*", "<em>$1</em>");
    
    // Links (whitelisted only)
    html = formatLinks(html);
    
    // Emoji codes
    html = replaceEmojis(html);
    
    // Mentions
    html = formatMentions(html);
    
    // Escape HTML (XSS protection)
    html = escapeHtml(html);
    
    return html;
}
```

---

## Voice Chat (WebRTC)

### Channels

- Party Voice (auto при создании party)
- Raid Voice (для координации)
- Guild Voice (для guild events)

### API

**POST `/api/v1/chat/voice/join`** - присоединиться
**POST `/api/v1/chat/voice/leave`** - покинуть
**GET `/api/v1/chat/voice/participants`** - участники
**POST `/api/v1/chat/voice/mute`** - mute себя
**POST `/api/v1/chat/voice/unmute`** - unmute

---

## Translation Support

### Auto-Translation

```java
@Service
public class TranslationService {
    
    public Map<String, String> translateMessage(String text, List<String> targetLanguages) {
        String sourceLanguage = detectLanguage(text);
        Map<String, String> translations = new HashMap<>();
        
        for (String targetLang : targetLanguages) {
            if (targetLang.equals(sourceLanguage)) {
                translations.put(targetLang, text);
            } else {
                String translated = translateClient.translate(
                    text, sourceLanguage, targetLang
                );
                translations.put(targetLang, translated);
            }
        }
        
        return translations;
    }
}
```

---

## Message History

```java
@GetMapping("/chat/history/{channelType}")
public ChatHistoryResponse getHistory(
    @PathVariable ChannelType channelType,
    @RequestParam String channelId,
    @RequestParam(defaultValue = "50") int limit,
    @RequestParam(required = false) Long beforeMessageId
) {
    // 1. Try Redis cache
    String cacheKey = "chat_history:" + channelType + ":" + channelId;
    List<ChatMessage> cached = redis.opsForList().range(cacheKey, 0, limit - 1);
    
    if (cached != null && !cached.isEmpty()) {
        return new ChatHistoryResponse(cached);
    }
    
    // 2. From DB
    List<ChatMessage> messages = chatRepository.findByChannelLatest(
        channelType, channelId, limit
    );
    
    // 3. Cache
    redis.opsForList().rightPushAll(cacheKey, messages);
    redis.expire(cacheKey, 1, TimeUnit.HOURS);
    
    return new ChatHistoryResponse(messages);
}
```

---

## API Endpoints

**GET `/api/v1/chat/history/{channelType}`** - история
**POST `/api/v1/chat/voice/join`** - voice chat
**PUT `/api/v1/chat/settings`** - настройки перевода

---

## Связанные документы

- `.BRAIN/05-technical/backend/chat/chat-channels.md` - Channels (микрофича 1/3)
- `.BRAIN/05-technical/backend/chat/chat-moderation.md` - Moderation (микрофича 2/3)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Микрофича 3/3: Chat Features (split from chat-system.md)




