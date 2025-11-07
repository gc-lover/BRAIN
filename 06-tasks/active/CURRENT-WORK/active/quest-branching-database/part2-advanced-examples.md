---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 16:14  
**api-readiness-notes:** Advanced слой квестовой БД: прогресс, флаги, world-state, последствия и SQL-примеры.
---

# Quest Branching DB - Part 2: Advanced Tables & Examples

**Версия:** 1.1.0  
**Дата обновления:** 2025-11-07 16:14  
**Дата создания:** 2025-11-07 02:17  
**Часть:** 2 из 2

[← Part 1](./part1-analysis-core.md) | [Навигация](./README.md)

---

## 6. quest_progress (Расширенная)

```sql
CREATE TABLE quest_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id UUID NOT NULL,
    quest_id VARCHAR(100) NOT NULL,
    
    status VARCHAR(20) NOT NULL, -- ACTIVE, COMPLETED, FAILED, ABANDONED
    current_branch VARCHAR(50), -- Текущая ветвь
    current_dialogue_node INTEGER, -- Текущий узел диалога
    progress INTEGER DEFAULT 0, -- 0-100
    
    objectives_state JSONB, -- [{id, status}]
    
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    
    FOREIGN KEY (quest_id) REFERENCES quests(id),
    UNIQUE(character_id, quest_id)
);

CREATE INDEX idx_quest_progress_character ON quest_progress(character_id);
CREATE INDEX idx_quest_progress_status ON quest_progress(status);
```

---

## 7. player_quest_choices (История выборов)

```sql
CREATE TABLE player_quest_choices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id UUID NOT NULL,
    quest_id VARCHAR(100) NOT NULL,
    node_id INTEGER NOT NULL,
    choice_id VARCHAR(50) NOT NULL,
    
    skill_check_rolled INTEGER, -- D20 result
    skill_check_total INTEGER, -- Roll + mods
    skill_check_success BOOLEAN,
    
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (quest_id) REFERENCES quests(id)
);

CREATE INDEX idx_player_choices_character ON player_quest_choices(character_id);
CREATE INDEX idx_player_choices_quest ON player_quest_choices(quest_id);
```

---

## 8. player_flags (Флаги игрока)

```sql
CREATE TABLE player_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id UUID NOT NULL,
    flag_key VARCHAR(200) NOT NULL,
    flag_value JSONB NOT NULL, -- true, false, number, string, object
    
    set_by_quest VARCHAR(100), -- Quest that set this flag
    set_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- NULL = permanent
    
    UNIQUE(character_id, flag_key)
);

CREATE INDEX idx_player_flags_character ON player_flags(character_id);
CREATE INDEX idx_player_flags_key ON player_flags(flag_key);
```

---

## 9. world_state (Глобальное состояние)

```sql
CREATE TABLE world_state (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(50) NOT NULL,
    state_key VARCHAR(200) NOT NULL,
    state_value JSONB NOT NULL,
    
    updated_by_quest VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(server_id, state_key)
);

CREATE INDEX idx_world_state_server ON world_state(server_id);
```

---

## 10. quest_consequences (Последствия)

```sql
CREATE TABLE quest_consequences (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    branch_id VARCHAR(50),
    
    consequence_type VARCHAR(50) NOT NULL, -- FLAG, REPUTATION, UNLOCK_QUEST, NPC_STATE
    
    target_id VARCHAR(200), -- quest_id, npc_id, flag_key
    consequence_data JSONB NOT NULL,
    
    applies_to VARCHAR(20) DEFAULT 'PLAYER', -- PLAYER, SERVER, FACTION
    
    FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE
);

CREATE INDEX idx_quest_consequences_quest ON quest_consequences(quest_id);
```

---

## Пример 1: Создание квеста с ветвлением

```sql
-- Quest
INSERT INTO quests (id, name, type, has_branches, era) 
VALUES ('morgan-brink', 'Captain Morgan: The Brink', 'MAIN', TRUE, '2077-2093');

-- Branches
INSERT INTO quest_branches (quest_id, branch_id, branch_name, reputation_changes, sets_flags)
VALUES 
  ('morgan-brink', 'pathA', 'Path of Justice', '{"NCPD": 20}', '["morgan_alive", "justice"]'),
  ('morgan-brink', 'pathB', 'Path of Corruption', '{"Corpo": 15}', '["morgan_corrupt"]');

-- Dialogue
INSERT INTO dialogue_nodes (quest_id, node_id, npc_id, npc_name, dialogue_text, node_type)
VALUES 
  ('morgan-brink', 1, 'npc_morgan', 'Captain Morgan', 'I need your help...', 'dialogue'),
  ('morgan-brink', 2, 'npc_morgan', 'Captain Morgan', 'Will you help me?', 'choice');

-- Choices
INSERT INTO dialogue_choices (node_id, choice_id, choice_text, next_node_id, sets_flags)
VALUES 
  (2, 'A1', '[Accept] I will help you', 3, '["morgan_quest_accepted"]'),
  (2, 'A2', '[Refuse] Not my problem', NULL, '["morgan_quest_refused"]');
```

---

## Пример 2: Проверка условий квеста

```sql
-- Can player start quest?
SELECT 
  q.*
FROM quests q
WHERE q.id = 'some-quest'
  AND NOT EXISTS (
    SELECT 1 FROM quest_progress qp
    WHERE qp.character_id = :playerId
      AND qp.quest_id = q.id
  )
  AND (q.required_quests IS NULL OR EXISTS (
    SELECT 1 FROM quest_progress qp2
    WHERE qp2.character_id = :playerId
      AND qp2.quest_id = ANY(q.required_quests::text[])
      AND qp2.status = 'COMPLETED'
  ))
  AND (q.required_flags IS NULL OR EXISTS (
    SELECT 1 FROM player_flags pf
    WHERE pf.character_id = :playerId
      AND pf.flag_key = ANY(q.required_flags::text[])
  ));
```

---

## Пример 3: Получить доступные выборы

```sql
SELECT 
  dc.*
FROM dialogue_choices dc
WHERE dc.node_id = :currentNodeId
  AND (dc.required_class IS NULL OR dc.required_class = :playerClass)
  AND (dc.required_origin IS NULL OR dc.required_origin = :playerOrigin)
  AND (dc.required_flags IS NULL OR EXISTS (
    SELECT 1 FROM player_flags pf
    WHERE pf.character_id = :playerId
      AND pf.flag_key = ANY(dc.required_flags::text[])
  ));
```

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:17) - Создан из quest-branching-database-design.md (SQL + примеры)

