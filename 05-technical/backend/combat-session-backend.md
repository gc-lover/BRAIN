---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 05:30  
**api-readiness-notes:** Combat Session backend - инстансы боя, turn order, damage calculation. Микрофича (~400 строк). MVP блокер!
---
---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-139: api/v1/combat/combat-session.yaml (2025-11-07 10:38)
- Last Updated: 2025-11-07 00:18
---



# Combat Session Backend - Backend боевых сессий

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 (обновлено для микросервисов)  
**Приоритет:** КРИТИЧЕСКИЙ (MVP блокер!)  
**Автор:** AI Brain Manager

---

## Краткое описание

**Combat Session Backend** - backend для управления боевыми сессиями. **БЕЗ ЭТОГО НЕТ БОЕВОГО ГЕЙМПЛЕЯ!**

**Микрофича:** Combat session management  
**Размер:** ~400 строк (соблюдает лимит!)

**Ключевые возможности:**
- ✅ Combat instance creation
- ✅ Turn order (для turn-based элементов)
- ✅ Damage calculation  
- ✅ Death handling
- ✅ Combat rewards (experience, loot)

---

## Микросервисная архитектура

**Ответственный микросервис:** gameplay-service  
**Порт:** 8083  
**API Gateway маршрут:** `/api/v1/gameplay/combat/*`  
**Статус:** 📋 В планах (Фаза 2)

**Взаимодействие с другими сервисами:**
- character-service: получение stats, abilities для боя
- economy-service: loot generation при победе
- quest-service (gameplay): обновление quest objectives

**Event Bus события:**
- Публикует: `combat:started`, `combat:ended`, `combat:enemy-killed`, `combat:player-died`, `combat:damage-dealt`
- Подписывается: `character:ability-used`, `item:equipped`

---

## Database Schema

```sql
CREATE TABLE combat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Type
    combat_type VARCHAR(50) NOT NULL,
    -- PVE, PVP_DUEL, PVP_ARENA, RAID_BOSS
    
    -- Participants
    participants JSONB NOT NULL,
    -- [
    --   {type: "PLAYER", id: "uuid", team: "A"},
    --   {type: "NPC", id: "npc_123", team: "B"},
    --   ...
    -- ]
    
    -- Turn order (для turn-based)
    turn_order UUID[] DEFAULT '{}',
    current_turn_index INTEGER DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE',
    -- ACTIVE, COMPLETED, FLED
    
    -- Zone
    zone_id VARCHAR(100) NOT NULL,
    instance_id VARCHAR(100), -- Для dungeons/raids
    
    -- Timestamps
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    
    CONSTRAINT fk_combat_instance FOREIGN KEY (instance_id) 
        REFERENCES game_instances(id) ON DELETE SET NULL
);

CREATE INDEX idx_combat_participants ON combat_sessions USING gin(participants);
CREATE INDEX idx_combat_status ON combat_sessions(status);
```

### Таблица `combat_logs`

```sql
CREATE TABLE combat_logs (
    id BIGSERIAL PRIMARY KEY,
    combat_session_id UUID NOT NULL,
    
    -- Action
    action_type VARCHAR(50) NOT NULL,
    -- ATTACK, USE_SKILL, USE_ITEM, MOVE, FLEE
    
    actor_type VARCHAR(10) NOT NULL, -- PLAYER or NPC
    actor_id UUID NOT NULL,
    
    target_type VARCHAR(10),
    target_id UUID,
    
    -- Result
    damage_dealt INTEGER DEFAULT 0,
    healing_done INTEGER DEFAULT 0,
    
    -- Details
    details JSONB,
    
    -- Timestamp
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_log_combat FOREIGN KEY (combat_session_id) 
        REFERENCES combat_sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_combat_logs_session ON combat_logs(combat_session_id, created_at);
```

---

## Start Combat

```java
@Service
public class CombatService {
    
    @Transactional
    public CombatSession startCombat(
        UUID initiatorId,
        List<UUID> enemies,
        CombatType type
    ) {
        // 1. Create session
        CombatSession session = new CombatSession();
        session.setCombatType(type);
        
        // 2. Add participants
        List<CombatParticipant> participants = new ArrayList<>();
        participants.add(new CombatParticipant("PLAYER", initiatorId, "A"));
        
        for (UUID enemyId : enemies) {
            participants.add(new CombatParticipant("NPC", enemyId, "B"));
        }
        
        session.setParticipants(participants);
        session.setZoneId(getZone(initiatorId));
        
        // 3. Determine turn order (по Initiative)
        List<UUID> turnOrder = calculateTurnOrder(participants);
        session.setTurnOrder(turnOrder);
        
        session = combatSessionRepository.save(session);
        
        // 4. Publish event
        eventBus.publish(new CombatStartedEvent(session.getId(), initiatorId));
        
        return session;
    }
    
    private List<UUID> calculateTurnOrder(List<CombatParticipant> participants) {
        // Initiative = Reflexes + d20
        return participants.stream()
            .map(p -> {
                int reflexes = getReflexes(p.getId(), p.getType());
                int roll = rollDice(20);
                int initiative = reflexes + roll;
                return new InitiativeRoll(p.getId(), initiative);
            })
            .sorted(Comparator.comparing(InitiativeRoll::getInitiative).reversed())
            .map(InitiativeRoll::getParticipantId)
            .collect(Collectors.toList());
    }
}
```

---

## Process Attack

```java
@Transactional
public AttackResult processAttack(
    UUID sessionId,
    UUID attackerId,
    UUID targetId
) {
    // 1. Get session
    CombatSession session = combatSessionRepository.findById(sessionId).get();
    
    // 2. Validate turn (если turn-based)
    if (!isActorTurn(session, attackerId)) {
        throw new NotYourTurnException();
    }
    
    // 3. Calculate damage
    int baseDamage = getWeaponDamage(attackerId);
    int damageModifier = getAttributeModifier(attackerId, "body");
    int totalDamage = baseDamage + damageModifier;
    
    // 4. Apply armor reduction
    int targetArmor = getArmor(targetId);
    int finalDamage = Math.max(1, totalDamage - targetArmor);
    
    // 5. Apply damage to target
    applyDamage(targetId, finalDamage);
    
    // 6. Log action
    logCombatAction(session.getId(), attackerId, targetId, "ATTACK", finalDamage);
    
    // 7. Check death
    if (getHealth(targetId) <= 0) {
        handleDeath(session, targetId);
    }
    
    // 8. Next turn
    advanceTurn(session);
    
    return new AttackResult(finalDamage, getHealth(targetId) <= 0);
}
```

---

## API Endpoints

**POST `/api/v1/combat/start`** - начать бой
**POST `/api/v1/combat/{id}/attack`** - атаковать
**POST `/api/v1/combat/{id}/use-skill`** - использовать скилл
**POST `/api/v1/combat/{id}/use-item`** - использовать предмет
**POST `/api/v1/combat/{id}/flee`** - сбежать
**GET `/api/v1/combat/{id}/state`** - состояние боя

---

## Связанные документы

- `.BRAIN/02-gameplay/combat/combat-pvp-pve.md` - Gameplay механики
- `.BRAIN/05-technical/backend/combat-actions-backend.md` - Actions processing (будет создан)

---

## История изменений

- **v1.0.0 (2025-11-07 05:30)** - Создан Combat Session Backend (микрофича)

