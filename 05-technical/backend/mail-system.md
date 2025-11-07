---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:20  
**api-readiness-notes:** Почтовая система. Send mail, receive, inbox pagination, item/gold attachments, COD, system mail, expiration.
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-232: api/v1/mail/mail-system.yaml (2025-11-08 05:40)
- Last Updated: 2025-11-08 05:40
---



# Mail System - Почтовая система

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** высокий  
**Автор:** AI Brain Manager

---

## Краткое описание

**Mail System** - внутриигровая почтовая система для отправки сообщений, предметов и валюты между игроками. Также используется системой для отправки наград и уведомлений.

**Ключевые возможности:**
- ✅ Send mail (text + attachments)
- ✅ Receive mail (inbox)
- ✅ Item attachments (до 10 предметов)
- ✅ Gold attachments
- ✅ COD (Cash on Delivery) - получатель платит за предметы
- ✅ System mail (автоматические награды, события)
- ✅ Mail expiration (30 дней)
- ✅ Return to sender (если не забрали)

---

## Микросервисная архитектура

**Ответственный микросервис:** social-service  
**Порт:** 8084  
**API Gateway маршрут:** `/api/v1/social/mail/*`  
**Статус:** 📋 В планах (Фаза 3)

**Взаимодействие с другими сервисами:**
- character-service: проверка существования получателя
- economy-service: transfer items/gold через mail
- notification-service (social): уведомление о новом письме

**Event Bus события:**
- Публикует: `mail:sent`, `mail:received`, `mail:attachment-claimed`, `mail:expired`
- Подписывается: `quest:completed` (отправка rewards), `auction:won` (отправка items)

---

## Database Schema

```sql
CREATE TABLE mail_messages (
    id BIGSERIAL PRIMARY KEY,
    
    -- Sender/Recipient
    sender_character_id UUID,  -- NULL for system mail
    recipient_character_id UUID NOT NULL,
    
    -- Mail type
    mail_type VARCHAR(20) DEFAULT 'PLAYER',
    -- PLAYER, SYSTEM, QUEST_REWARD, ACHIEVEMENT_REWARD, AUCTION_RESULT
    
    -- Content
    subject VARCHAR(200) NOT NULL,
    body TEXT,
    
    -- Attachments
    attached_items JSONB DEFAULT '[]',
    -- [{itemTemplateId: "weapon_pistol", quantity: 1}]
    
    attached_gold BIGINT DEFAULT 0,
    
    -- COD
    cod_amount BIGINT DEFAULT 0, -- Получатель должен заплатить
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_claimed BOOLEAN DEFAULT FALSE, -- Attachments забраны
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    claimed_at TIMESTAMP,
    expires_at TIMESTAMP NOT NULL, -- 30 days
    deleted_at TIMESTAMP,
    
    -- Return to sender (если не забрали за 30 дней)
    returned BOOLEAN DEFAULT FALSE,
    returned_at TIMESTAMP,
    
    CONSTRAINT fk_mail_sender FOREIGN KEY (sender_character_id) 
        REFERENCES characters(id) ON DELETE SET NULL,
    CONSTRAINT fk_mail_recipient FOREIGN KEY (recipient_character_id) 
        REFERENCES characters(id) ON DELETE CASCADE
);

CREATE INDEX idx_mail_recipient ON mail_messages(recipient_character_id, is_deleted, sent_at DESC);
CREATE INDEX idx_mail_expires ON mail_messages(expires_at) WHERE is_deleted = FALSE AND is_claimed = FALSE;
```

---

## Send Mail

```java
@Transactional
public void sendMail(
    UUID senderId,
    String recipientName,
    String subject,
    String body,
    List<MailAttachment> attachments,
    long codAmount
) {
    // 1. Найти получателя
    Character recipient = characterRepository.findByName(recipientName)
        .orElseThrow(() -> new CharacterNotFoundException());
    
    // 2. Проверить attachments
    long totalGold = 0;
    for (MailAttachment att : attachments) {
        if (att.isGold()) {
            totalGold += att.getAmount();
        } else {
            // Проверить ownership предмета
            CharacterItem item = itemRepository.findById(att.getItemId()).get();
            if (!item.getCharacterId().equals(senderId)) {
                throw new UnauthorizedItemAccessException();
            }
        }
    }
    
    // 3. Проверить баланс (если отправляет gold)
    if (totalGold > 0) {
        Character sender = characterRepository.findById(senderId).get();
        if (sender.getEddies() < totalGold) {
            throw new InsufficientFundsException();
        }
    }
    
    // 4. Создать mail
    MailMessage mail = new MailMessage();
    mail.setSenderCharacterId(senderId);
    mail.setRecipientCharacterId(recipient.getId());
    mail.setMailType(MailType.PLAYER);
    mail.setSubject(subject);
    mail.setBody(body);
    mail.setAttachedItems(attachments);
    mail.setAttachedGold(totalGold);
    mail.setCodAmount(codAmount);
    mail.setExpiresAt(Instant.now().plus(Duration.ofDays(30)));
    
    mailRepository.save(mail);
    
    // 5. Забрать items у отправителя
    for (MailAttachment att : attachments) {
        if (!att.isGold()) {
            inventoryService.removeItem(senderId, att.getItemId(), att.getQuantity());
        }
    }
    
    // 6. Забрать gold
    if (totalGold > 0) {
        characterService.deductGold(senderId, totalGold);
    }
    
    // 7. Уведомить получателя
    notificationService.send(getAccountId(recipient.getId()), 
        new NewMailNotification(getCharacterName(senderId), subject));
    
    log.info("Mail sent from {} to {}", senderId, recipient.getId());
}
```

---

## Связанные документы

- `.BRAIN/05-technical/backend/inventory-system.md`
- `.BRAIN/05-technical/backend/notification-system.md` (будет создан)

---

## История изменений

- **v1.0.0 (2025-11-07 05:20)** - Создан документ Mail System

