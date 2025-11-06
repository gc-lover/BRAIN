# Quest Branching DB - Part 1: Analysis & Core Tables

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:16  
**Часть:** 1 из 2

[Навигация](./README.md) | [Part 2 →](./part2-advanced-examples.md)

---

## Анализ текущего состояния

### ✅ Что есть
- 113+ квестов в JSON
- Таблицы quests, quest_progress (базовые)
- JSON схемы с dialogue trees, skill checks

### ❌ Чего нет
- Player choices history
- Dialogue trees storage
- Flags system
- Consequences tracking
- World state per quest
- NPC states tracking

---

## 1. Расширенная таблица quests

```sql
CREATE TABLE quests (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    type VARCHAR(20) NOT NULL, -- MAIN, SIDE, FACTION, EVENT
    category VARCHAR(50), -- COMBAT, SOCIAL, STEALTH, HACKING
    difficulty VARCHAR(20), -- EASY, MEDIUM, HARD, EXTREME
    
    -- Requirements
    min_level INTEGER DEFAULT 1,
    required_quests JSONB, -- ["quest1", "quest2"]
    required_flags JSONB, -- ["flag1", "flag2"]
    required_reputation JSONB, -- {"Arasaka": 50}
    required_class VARCHAR(50),
    required_origin VARCHAR(50),
    
    -- Structure
    has_branches BOOLEAN DEFAULT FALSE,
    dialogue_tree_root INTEGER, -- FK to dialogue_nodes
    objectives JSONB NOT NULL, -- [{id, text, complete}]
    
    -- Rewards
    reward_experience INTEGER,
    reward_money INTEGER,
    reward_items JSONB,
    reward_reputation JSONB,
    
    -- Metadata
    era VARCHAR(20) NOT NULL,
    region VARCHAR(100),
    giver_npc_id VARCHAR(100),
    estimated_duration INTEGER, -- minutes
    is_repeatable BOOLEAN DEFAULT FALSE,
    cooldown_hours INTEGER,
    max_concurrent_players INTEGER, -- for world events
    
    tags JSONB, -- ["corpo", "netrunning"]
    is_active BOOLEAN DEFAULT TRUE,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quests_type ON quests(type);
CREATE INDEX idx_quests_level ON quests(min_level);
CREATE INDEX idx_quests_era ON quests(era);
CREATE INDEX idx_quests_tags ON quests USING GIN(tags);
```

---

## 2. quest_branches (Пути квеста)

```sql
CREATE TABLE quest_branches (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    branch_id VARCHAR(50) NOT NULL, -- "pathA", "pathB"
    branch_name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Activation conditions
    conditions JSONB, -- {flags: [], reputation: {}}
    
    -- Modifiers
    reward_modifiers JSONB, -- {experience: 1.5, money: 1.2}
    reputation_changes JSONB, -- {"NetWatch": 15}
    branch_rewards JSONB,
    
    -- Consequences
    sets_flags JSONB,
    unsets_flags JSONB,
    unlocks_quests JSONB,
    locks_quests JSONB,
    world_state_changes JSONB,
    
    difficulty_modifier DECIMAL(3,2) DEFAULT 1.0,
    moral_weight VARCHAR(20), -- GOOD, EVIL, NEUTRAL
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE,
    UNIQUE(quest_id, branch_id)
);

CREATE INDEX idx_quest_branches_quest ON quest_branches(quest_id);
```

---

## 3. dialogue_nodes (Узлы диалогов)

```sql
CREATE TABLE dialogue_nodes (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    node_id INTEGER NOT NULL,
    
    npc_id VARCHAR(100) NOT NULL,
    npc_name VARCHAR(200) NOT NULL,
    location_id VARCHAR(100),
    
    dialogue_text TEXT NOT NULL,
    emotion VARCHAR(50), -- angry, happy, sad
    voice_line_id VARCHAR(100),
    
    required_flags JSONB,
    required_reputation JSONB,
    blocked_flags JSONB,
    
    node_type VARCHAR(20) NOT NULL, -- dialogue, choice, skill_check, combat, end
    
    triggers_combat BOOLEAN DEFAULT FALSE,
    combat_encounter_id VARCHAR(100),
    
    is_critical_path BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE,
    UNIQUE(quest_id, node_id)
);

CREATE INDEX idx_dialogue_nodes_quest ON dialogue_nodes(quest_id);
```

---

## 4. dialogue_choices (Выборы)

```sql
CREATE TABLE dialogue_choices (
    id SERIAL PRIMARY KEY,
    node_id INTEGER NOT NULL,
    choice_id VARCHAR(50) NOT NULL,
    choice_text TEXT NOT NULL,
    
    next_node_id INTEGER, -- NULL = end
    
    -- Requirements
    required_class VARCHAR(50),
    required_origin VARCHAR(50),
    required_flags JSONB,
    required_reputation JSONB,
    required_items JSONB,
    
    skill_check_id INTEGER, -- FK to skill_checks
    
    -- Consequences
    reputation_changes JSONB,
    sets_flags JSONB,
    unsets_flags JSONB,
    gives_items JSONB,
    removes_items JSONB,
    
    is_timed BOOLEAN DEFAULT FALSE,
    time_limit_seconds INTEGER,
    
    moral_alignment VARCHAR(20), -- GOOD, EVIL, NEUTRAL
    personality_trait VARCHAR(50),
    
    FOREIGN KEY (node_id) REFERENCES dialogue_nodes(id) ON DELETE CASCADE,
    UNIQUE(node_id, choice_id)
);

CREATE INDEX idx_dialogue_choices_node ON dialogue_choices(node_id);
```

---

## 5. skill_checks (Проверки навыков)

```sql
CREATE TABLE skill_checks (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    check_type VARCHAR(50) NOT NULL, -- BODY, INTELLIGENCE, COOL, HACKING
    dc INTEGER NOT NULL, -- Difficulty Class (8-24)
    
    success_node_id INTEGER, -- Next node on success
    failure_node_id INTEGER, -- Next node on failure
    critical_success_node_id INTEGER, -- DC+10
    critical_failure_node_id INTEGER, -- Roll=1
    
    modifiers JSONB, -- [{type: "reputation", faction: "Arasaka", bonus: 2}]
    
    description TEXT,
    flavor_text TEXT, -- "[BODY 15] Kick down the door"
    
    FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE
);

CREATE INDEX idx_skill_checks_quest ON skill_checks(quest_id);
```

---

[Part 2: Advanced Tables →](./part2-advanced-examples.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:16) - Создан из quest-branching-database-design.md (полные SQL)

