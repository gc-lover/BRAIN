# Структура БД для Ветвления Квестов в MMORPG

**Статус:** in-progress  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 20:31  
**Приоритет:** высокий  
**Автор:** AI Manager

---

## Краткое описание

Детальный анализ текущего состояния систе квестов и разработка структуры БД для поддержки глубокого ветвления квестов в MMORPG NECPGAME с влиянием на мировое состояние (по аналогии с Baldur's Gate 3).

---

## 📊 Анализ текущего состояния

### ✅ Что уже есть

#### 1. **Документация квестовой системы**
- `.BRAIN/04-narrative/quest-system.md` - философия и требования системы квестов
- `.BRAIN/04-narrative/quests/BRANCHING-QUESTS-SUMMARY.md` - 7 детальных квестов с ветвлениями
  - 39 уникальных концовок
  - 20 критических выборов
  - 28 детальных NPC
- `.BRAIN/05-technical/api-structures/quests-json-schema.md` - JSON-схемы для квестов
- 113+ квестов в различных JSON файлах

#### 2. **Текущая структура БД (BACK-GO)**

**Таблица `quests`:**
```sql
CREATE TABLE quests (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(2000) NOT NULL,
    type VARCHAR(20) NOT NULL, -- MAIN, SIDE, CONTRACT
    level INTEGER NOT NULL,
    giver_npc_id VARCHAR(100) NOT NULL,
    reward_experience INTEGER,
    reward_money INTEGER,
    reward_items VARCHAR(1000), -- JSON array
    reward_reputation_faction VARCHAR(100),
    reward_reputation_amount INTEGER,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

**Таблица `quest_progress`:**
```sql
CREATE TABLE quest_progress (
    id UUID PRIMARY KEY,
    character_id UUID NOT NULL,
    quest_id VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL, -- ACTIVE, COMPLETED, FAILED, ABANDONED
    progress INTEGER NOT NULL DEFAULT 0, -- 0-100
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(character_id, quest_id)
);
```

#### 3. **Концептуальная структура из JSON-схем**
- Dialogue trees с узлами и выборами
- Skill checks с модификаторами
- Consequences (последствия) для следующих квестов и эпох
- World events
- Reputation changes по путям
- Loot по путям

### ❌ Что отсутствует для полноценного ветвления

1. **Хранение выборов игрока** - нет таблицы для отслеживания решений
2. **Диалоговые деревья** - нет структуры для хранения прогресса по диалогам
3. **Флаги состояния** - нет системы флагов для условий и триггеров
4. **Последствия** - нет структуры для хранения влияния на будущие квесты
5. **Мировое состояние** - нет отдельной таблицы для world state
6. **История выборов** - нет аудита решений игрока
7. **Ветви квестов** - нет отдельной таблицы для путей/ветвей
8. **Skill checks** - нет хранения результатов проверок навыков
9. **NPC состояние** - нет отслеживания состояния NPC (жив/мертв/изгнан и т.д.)
10. **Территориальный контроль** - нет таблицы для контроля территорий фракциями

---

## 🗄️ Предлагаемая структура БД

### Принципы проектирования

1. **Нормализация** - избегаем дублирования данных
2. **Масштабируемость** - структура должна поддерживать тысячи квестов и миллионы игроков
3. **Производительность** - индексы для частых запросов
4. **Гибкость** - возможность добавлять новые типы ветвлений
5. **Аудит** - отслеживание истории всех изменений
6. **MMORPG специфика** - учет множества игроков и их влияния на мир

---

### 1. Расширение таблицы `quests` (Quest Definition)

**Цель:** Хранение базовой информации о квесте + ссылки на сложные структуры

```sql
CREATE TABLE quests (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    type VARCHAR(20) NOT NULL, -- MAIN, SIDE, FACTION, DAILY, WEEKLY, EVENT, PLAYER_CREATED, DYNAMIC
    category VARCHAR(50), -- COMBAT, SOCIAL, STEALTH, HACKING, EXPLORATION
    difficulty VARCHAR(20), -- EASY, MEDIUM, HARD, EXTREME, LEGENDARY
    
    -- Требования
    min_level INTEGER NOT NULL DEFAULT 1,
    max_level INTEGER,
    required_quests JSONB, -- Array of quest IDs
    required_flags JSONB, -- Array of required world/player flags
    required_reputation JSONB, -- {faction: minValue}
    required_class VARCHAR(50), -- Для класс-специфичных квестов
    required_origin VARCHAR(50), -- Для origin-специфичных квестов
    
    -- Структура квеста
    has_branches BOOLEAN DEFAULT FALSE,
    dialogue_tree_root INTEGER, -- FK to dialogue_nodes.id
    objectives JSONB NOT NULL, -- Basic objectives structure
    
    -- Награды (базовые)
    reward_experience INTEGER,
    reward_money INTEGER,
    reward_items JSONB, -- Array of item IDs
    reward_reputation JSONB, -- {faction: amount}
    
    -- Метаданные
    era VARCHAR(20) NOT NULL, -- 2020-2030, 2030-2045, etc
    region VARCHAR(100), -- Night_City, Tokyo, etc
    giver_npc_id VARCHAR(100),
    estimated_duration INTEGER, -- В минутах
    is_repeatable BOOLEAN DEFAULT FALSE,
    cooldown_hours INTEGER, -- Для repeatable квестов
    max_concurrent_players INTEGER, -- Для world events (NULL = unlimited)
    
    -- Сеттинг и лор
    tags JSONB, -- ["corpo", "netrunning", "romance", etc]
    related_quests JSONB, -- Quest IDs, которые связаны с этим
    
    -- Служебные
    is_active BOOLEAN DEFAULT TRUE, -- Для временного отключения квестов
    version INTEGER DEFAULT 1, -- Версионирование квеста
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100), -- Для player-created квестов
    
    CONSTRAINT fk_giver_npc FOREIGN KEY (giver_npc_id) REFERENCES npcs(id)
);

CREATE INDEX idx_quests_type ON quests(type);
CREATE INDEX idx_quests_level ON quests(min_level, max_level);
CREATE INDEX idx_quests_era ON quests(era);
CREATE INDEX idx_quests_region ON quests(region);
CREATE INDEX idx_quests_tags ON quests USING GIN(tags);
CREATE INDEX idx_quests_active ON quests(is_active) WHERE is_active = TRUE;
```

---

### 2. Таблица `quest_branches` (Ветви/Пути квеста)

**Цель:** Определение различных путей прохождения квеста

```sql
CREATE TABLE quest_branches (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    branch_id VARCHAR(50) NOT NULL, -- "pathA", "pathB", "pathC", etc
    branch_name VARCHAR(200) NOT NULL, -- "Путь Правды", "Путь Коррупции"
    description TEXT,
    
    -- Условия активации ветви
    conditions JSONB, -- {flags: [], reputation: {}, choices: []}
    
    -- Модификаторы для этой ветви
    reward_modifiers JSONB, -- {experience: +50%, money: 1.5, etc}
    
    -- Репутация изменения для этой ветви
    reputation_changes JSONB, -- {NetWatch: 15, VoodooBoys: -5}
    
    -- Награды специфичные для ветви
    branch_rewards JSONB, -- {eddy: 500, items: [...]}
    
    -- Последствия ветви
    sets_flags JSONB, -- Флаги, которые устанавливает эта ветвь
    unsets_flags JSONB, -- Флаги, которые снимает эта ветвь
    unlocks_quests JSONB, -- Квесты, которые разблокируются
    locks_quests JSONB, -- Квесты, которые блокируются
    
    -- Влияние на мир
    world_state_changes JSONB, -- {territoryControl: {Watson: "NCPD"}, npcFates: {...}}
    
    -- Мета
    difficulty_modifier DECIMAL(3,2) DEFAULT 1.0, -- 0.8 = easier, 1.2 = harder
    moral_weight VARCHAR(20), -- "GOOD", "EVIL", "NEUTRAL", "GREY"
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_branch_quest FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE,
    UNIQUE(quest_id, branch_id)
);

CREATE INDEX idx_quest_branches_quest ON quest_branches(quest_id);
```

---

### 3. Таблица `dialogue_nodes` (Узлы диалогов)

**Цель:** Хранение диалогового дерева квеста

```sql
CREATE TABLE dialogue_nodes (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    node_id INTEGER NOT NULL, -- Уникальный в рамках квеста
    
    -- NPC и локация
    npc_id VARCHAR(100) NOT NULL,
    npc_name VARCHAR(200) NOT NULL,
    location_id VARCHAR(100),
    
    -- Текст диалога
    dialogue_text TEXT NOT NULL,
    emotion VARCHAR(50), -- "angry", "happy", "sad", "neutral", etc
    voice_line_id VARCHAR(100), -- Для озвучки
    
    -- Условия для отображения узла
    required_flags JSONB, -- Флаги, необходимые для этого узла
    required_reputation JSONB, -- {faction: minValue}
    blocked_flags JSONB, -- Флаги, которые блокируют узел
    
    -- Тип узла
    node_type VARCHAR(20) NOT NULL, -- "dialogue", "choice", "skill_check", "combat", "end"
    
    -- Для combat узлов
    triggers_combat BOOLEAN DEFAULT FALSE,
    combat_encounter_id VARCHAR(100),
    
    -- Служебное
    is_critical_path BOOLEAN DEFAULT FALSE, -- Узел на критическом пути
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_dialogue_quest FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE,
    CONSTRAINT fk_dialogue_npc FOREIGN KEY (npc_id) REFERENCES npcs(id),
    UNIQUE(quest_id, node_id)
);

CREATE INDEX idx_dialogue_nodes_quest ON dialogue_nodes(quest_id);
CREATE INDEX idx_dialogue_nodes_type ON dialogue_nodes(node_type);
```

---

### 4. Таблица `dialogue_choices` (Выборы в диалогах)

**Цель:** Хранение вариантов выбора в узлах диалога

```sql
CREATE TABLE dialogue_choices (
    id SERIAL PRIMARY KEY,
    node_id INTEGER NOT NULL,
    choice_id VARCHAR(50) NOT NULL, -- "A1", "A2", "B1", etc
    choice_text TEXT NOT NULL,
    
    -- След узел
    next_node_id INTEGER, -- NULL если конец квеста/ветви
    
    -- Условия доступности выбора
    required_class VARCHAR(50),
    required_origin VARCHAR(50),
    required_flags JSONB,
    required_reputation JSONB,
    required_items JSONB, -- Item IDs
    
    -- Skill check для выбора
    skill_check_id INTEGER, -- FK to skill_checks.id
    
    -- Последствия выбора
    reputation_changes JSONB, -- {faction: amount}
    sets_flags JSONB,
    unsets_flags JSONB,
    gives_items JSONB,
    removes_items JSONB,
    
    -- Мета
    is_timed BOOLEAN DEFAULT FALSE, -- Ограничен ли выбор по времени
    time_limit_seconds INTEGER,
    moral_weight VARCHAR(20), -- "GOOD", "EVIL", "NEUTRAL", "GREY"
    
    -- Визуализация
    icon VARCHAR(100), -- Иконка для UI
    color VARCHAR(20), -- Цвет для UI (red, blue, green, etc)
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_choice_node FOREIGN KEY (node_id) REFERENCES dialogue_nodes(id) ON DELETE CASCADE,
    CONSTRAINT fk_choice_next_node FOREIGN KEY (next_node_id) REFERENCES dialogue_nodes(id),
    CONSTRAINT fk_choice_skill_check FOREIGN KEY (skill_check_id) REFERENCES skill_checks(id),
    UNIQUE(node_id, choice_id)
);

CREATE INDEX idx_dialogue_choices_node ON dialogue_choices(node_id);
CREATE INDEX idx_dialogue_choices_next ON dialogue_choices(next_node_id);
```

---

### 5. Таблица `skill_checks` (Проверки навыков)

**Цель:** Хранение всех skill checks в квестах и диалогах

```sql
CREATE TABLE skill_checks (
    id SERIAL PRIMARY KEY,
    quest_id VARCHAR(100) NOT NULL,
    check_id VARCHAR(50) NOT NULL, -- "SC-001", "SC-002", etc
    check_name VARCHAR(200) NOT NULL,
    
    -- Параметры проверки
    check_type VARCHAR(20) NOT NULL, -- "Social", "Combat", "Hacking", "Tech", "Stealth"
    skill VARCHAR(50) NOT NULL, -- "Persuasion", "Intimidation", "Hacking", etc
    attribute VARCHAR(10) NOT NULL, -- "EMP", "INT", "REF", "TECH", "COOL", "BODY"
    dc INTEGER NOT NULL, -- Difficulty Class (10-30)
    
    -- Формула
    formula TEXT NOT NULL, -- "d20 + floor((EMP-10)/2) + Persuasion + modifiers"
    
    -- Модификаторы
    base_modifiers JSONB, -- {reputation: {...}, items: {...}, class: {...}, origin: {...}}
    
    -- Преимущество/помеха
    advantage_conditions JSONB, -- Array of conditions
    disadvantage_conditions JSONB,
    
    -- Результаты
    success_node_id INTEGER, -- След узел при успехе
    failure_node_id INTEGER, -- След узел при провале
    critical_success_node_id INTEGER, -- Крит успех (nat 20 или DC+10)
    critical_failure_node_id INTEGER, -- Крит провал (nat 1 или DC-10)
    
    -- Последствия успеха
    success_reputation JSONB,
    success_flags JSONB,
    success_loot JSONB,
    
    -- Последствия провала
    failure_reputation JSONB,
    failure_flags JSONB,
    failure_triggers_combat BOOLEAN DEFAULT FALSE,
    
    -- Последствия крит успеха
    crit_success_reputation JSONB,
    crit_success_flags JSONB,
    crit_success_loot JSONB,
    
    -- Последствия крит провала
    crit_failure_reputation JSONB,
    crit_failure_flags JSONB,
    crit_failure_triggers_combat BOOLEAN DEFAULT FALSE,
    
    -- Кооперативная проверка (для MMORPG)
    allows_cooperation BOOLEAN DEFAULT FALSE,
    allowed_helper_classes JSONB, -- ["Netrunner", "Techie"]
    cooperation_bonus INTEGER DEFAULT 0, -- +2 за помощника
    
    -- Групповая проверка
    is_group_check BOOLEAN DEFAULT FALSE,
    group_check_type VARCHAR(20), -- "cooperative", "team", "roleBased"
    group_roles JSONB, -- ["tank", "dps", "support"]
    success_threshold INTEGER, -- Сколько должны пройти
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_skill_check_quest FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE,
    CONSTRAINT fk_success_node FOREIGN KEY (success_node_id) REFERENCES dialogue_nodes(id),
    CONSTRAINT fk_failure_node FOREIGN KEY (failure_node_id) REFERENCES dialogue_nodes(id),
    CONSTRAINT fk_crit_success_node FOREIGN KEY (critical_success_node_id) REFERENCES dialogue_nodes(id),
    CONSTRAINT fk_crit_failure_node FOREIGN KEY (critical_failure_node_id) REFERENCES dialogue_nodes(id),
    UNIQUE(quest_id, check_id)
);

CREATE INDEX idx_skill_checks_quest ON skill_checks(quest_id);
CREATE INDEX idx_skill_checks_type ON skill_checks(check_type);
```

---

### 6. Расширение таблицы `quest_progress` (Player Quest Progress)

**Цель:** Отслеживание прогресса игрока с поддержкой ветвлений

```sql
CREATE TABLE quest_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL,
    quest_id VARCHAR(100) NOT NULL,
    
    -- Статус
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, COMPLETED, FAILED, ABANDONED
    
    -- Прогресс
    progress INTEGER NOT NULL DEFAULT 0, -- 0-100
    current_branch_id VARCHAR(50), -- Текущая ветвь (FK to quest_branches)
    current_node_id INTEGER, -- Текущий узел диалога (FK to dialogue_nodes)
    
    -- Выбранный путь
    chosen_path VARCHAR(50), -- "pathA", "pathB", etc (финальный путь при завершении)
    
    -- Objectives progress
    objectives_progress JSONB, -- {objective1: 50%, objective2: 100%, etc}
    
    -- Временные метки
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    last_interaction_at TIMESTAMP, -- Последнее взаимодействие с квестом
    
    -- Служебное
    version INTEGER DEFAULT 1, -- Версия квеста при старте (для миграций)
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_progress_character FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_progress_quest FOREIGN KEY (quest_id) REFERENCES quests(id),
    CONSTRAINT fk_progress_branch FOREIGN KEY (quest_id, current_branch_id) 
        REFERENCES quest_branches(quest_id, branch_id),
    CONSTRAINT fk_progress_node FOREIGN KEY (current_node_id) REFERENCES dialogue_nodes(id),
    UNIQUE(character_id, quest_id)
);

CREATE INDEX idx_quest_progress_character ON quest_progress(character_id);
CREATE INDEX idx_quest_progress_quest ON quest_progress(quest_id);
CREATE INDEX idx_quest_progress_status ON quest_progress(status);
CREATE INDEX idx_quest_progress_branch ON quest_progress(current_branch_id);
CREATE INDEX idx_quest_progress_last_interaction ON quest_progress(last_interaction_at);
```

---

### 7. Таблица `player_quest_choices` (История выборов игрока)

**Цель:** Аудит всех выборов игрока для анализа и влияния на будущие квесты

```sql
CREATE TABLE player_quest_choices (
    id SERIAL PRIMARY KEY,
    character_id UUID NOT NULL,
    quest_id VARCHAR(100) NOT NULL,
    
    -- Выбор
    node_id INTEGER NOT NULL,
    choice_id VARCHAR(50) NOT NULL,
    choice_text TEXT NOT NULL, -- Копия текста выбора
    
    -- Контекст
    branch_id VARCHAR(50), -- В какой ветви сделан выбор
    
    -- Skill check (если был)
    skill_check_id INTEGER,
    skill_check_roll INTEGER, -- Результат броска d20
    skill_check_total INTEGER, -- Итоговый результат с модификаторами
    skill_check_result VARCHAR(20), -- "SUCCESS", "FAILURE", "CRITICAL_SUCCESS", "CRITICAL_FAILURE"
    
    -- Последствия, примененные к игроку
    applied_reputation JSONB,
    applied_flags JSONB,
    applied_loot JSONB,
    
    -- Мета
    decision_time_seconds INTEGER, -- Время на принятие решения
    was_timed BOOLEAN DEFAULT FALSE,
    moral_weight VARCHAR(20),
    
    -- Временная метка
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_choice_character FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_choice_quest FOREIGN KEY (quest_id) REFERENCES quests(id),
    CONSTRAINT fk_choice_node FOREIGN KEY (node_id) REFERENCES dialogue_nodes(id),
    CONSTRAINT fk_choice_skill_check FOREIGN KEY (skill_check_id) REFERENCES skill_checks(id)
);

CREATE INDEX idx_player_choices_character ON player_quest_choices(character_id);
CREATE INDEX idx_player_choices_quest ON player_quest_choices(quest_id);
CREATE INDEX idx_player_choices_branch ON player_quest_choices(branch_id);
CREATE INDEX idx_player_choices_created ON player_quest_choices(created_at);
```

---

### 8. Таблица `player_flags` (Флаги состояния игрока)

**Цель:** Хранение всех флагов/состояний игрока для условий и триггеров

```sql
CREATE TABLE player_flags (
    id SERIAL PRIMARY KEY,
    character_id UUID NOT NULL,
    flag_name VARCHAR(200) NOT NULL,
    flag_value VARCHAR(500), -- Для флагов со значениями
    flag_type VARCHAR(20) NOT NULL DEFAULT 'BOOLEAN', -- BOOLEAN, STRING, INTEGER
    
    -- Мета
    set_by_quest_id VARCHAR(100), -- Какой квест установил флаг
    set_by_choice_id VARCHAR(50), -- Какой выбор установил флаг
    description TEXT, -- Описание для дебага
    
    -- Экспирация
    expires_at TIMESTAMP, -- Флаг истекает (для временных эффектов)
    is_permanent BOOLEAN DEFAULT TRUE,
    
    -- Категории для фильтрации
    category VARCHAR(50), -- "QUEST", "WORLD", "REPUTATION", "NPC", "FACTION"
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_flag_character FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_flag_quest FOREIGN KEY (set_by_quest_id) REFERENCES quests(id),
    UNIQUE(character_id, flag_name)
);

CREATE INDEX idx_player_flags_character ON player_flags(character_id);
CREATE INDEX idx_player_flags_name ON player_flags(flag_name);
CREATE INDEX idx_player_flags_category ON player_flags(category);
CREATE INDEX idx_player_flags_expires ON player_flags(expires_at) WHERE expires_at IS NOT NULL;
```

---

### 9. Таблица `world_state` (Глобальное состояние мира)

**Цель:** Отслеживание состояния мира, которое влияет на всех игроков

```sql
CREATE TABLE world_state (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL, -- Для multi-server setup
    state_key VARCHAR(200) NOT NULL,
    state_value TEXT NOT NULL,
    state_type VARCHAR(20) NOT NULL DEFAULT 'STRING', -- STRING, INTEGER, BOOLEAN, JSON
    
    -- Категории
    category VARCHAR(50) NOT NULL, -- "FACTION_WAR", "TERRITORY_CONTROL", "GLOBAL_EVENT", "ECONOMY", "NPC_FATE"
    region VARCHAR(100), -- Регион, к которому относится состояние
    
    -- Мета
    description TEXT,
    set_by_quest_id VARCHAR(100), -- Какой квест изменил состояние
    set_by_event_id VARCHAR(100), -- Какое событие изменило состояние
    affected_players_count INTEGER DEFAULT 0, -- Сколько игроков повлияло на это
    
    -- История изменений
    previous_value TEXT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Экспирация
    expires_at TIMESTAMP, -- Для временных состояний
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_world_state_quest FOREIGN KEY (set_by_quest_id) REFERENCES quests(id),
    UNIQUE(server_id, state_key)
);

CREATE INDEX idx_world_state_server ON world_state(server_id);
CREATE INDEX idx_world_state_category ON world_state(category);
CREATE INDEX idx_world_state_region ON world_state(region);
CREATE INDEX idx_world_state_changed ON world_state(changed_at);
```

---

### 10. Таблица `world_state_history` (История изменений мира)

**Цель:** Аудит всех изменений мирового состояния

```sql
CREATE TABLE world_state_history (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL,
    state_key VARCHAR(200) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    
    -- Контекст изменения
    changed_by_quest_id VARCHAR(100),
    changed_by_event_id VARCHAR(100),
    changed_by_character_id UUID, -- Игрок, который спровоцировал изменение
    
    -- Описание
    change_reason TEXT,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_history_quest FOREIGN KEY (changed_by_quest_id) REFERENCES quests(id),
    CONSTRAINT fk_history_character FOREIGN KEY (changed_by_character_id) REFERENCES characters(id)
);

CREATE INDEX idx_world_history_server ON world_state_history(server_id);
CREATE INDEX idx_world_history_key ON world_state_history(state_key);
CREATE INDEX idx_world_history_quest ON world_state_history(changed_by_quest_id);
CREATE INDEX idx_world_history_created ON world_state_history(created_at);
```

---

### 11. Таблица `territory_control` (Контроль территорий)

**Цель:** Отслеживание контроля территорий фракциями

```sql
CREATE TABLE territory_control (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    
    -- Контроллирующая фракция
    controlling_faction VARCHAR(100) NOT NULL,
    control_strength INTEGER NOT NULL DEFAULT 100, -- 0-100
    
    -- Конфликты
    is_contested BOOLEAN DEFAULT FALSE,
    challenging_faction VARCHAR(100), -- Фракция, которая оспаривает контроль
    contest_started_at TIMESTAMP,
    
    -- Влияние на геймплей
    faction_patrols JSONB, -- {patrol_frequency: "high", patrol_type: "aggressive"}
    npc_vendors JSONB, -- Список NPC vendors для этой фракции
    quest_givers JSONB, -- Список NPC quest givers
    price_modifiers JSONB, -- {weapons: 0.9, implants: 1.1}
    
    -- История
    previous_controller VARCHAR(100),
    control_changed_at TIMESTAMP,
    control_changed_by_quest VARCHAR(100),
    
    -- Мета
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_territory_faction FOREIGN KEY (controlling_faction) REFERENCES factions(id),
    CONSTRAINT fk_territory_challenger FOREIGN KEY (challenging_faction) REFERENCES factions(id),
    CONSTRAINT fk_territory_quest FOREIGN KEY (control_changed_by_quest) REFERENCES quests(id),
    UNIQUE(server_id, region, district)
);

CREATE INDEX idx_territory_server ON territory_control(server_id);
CREATE INDEX idx_territory_faction ON territory_control(controlling_faction);
CREATE INDEX idx_territory_contested ON territory_control(is_contested) WHERE is_contested = TRUE;
CREATE INDEX idx_territory_region ON territory_control(region);
```

---

### 12. Таблица `npc_states` (Состояние NPC)

**Цель:** Отслеживание состояния NPC (жив/мертв/изгнан и т.д.)

```sql
CREATE TABLE npc_states (
    id SERIAL PRIMARY KEY,
    server_id VARCHAR(100) NOT NULL,
    npc_id VARCHAR(100) NOT NULL,
    
    -- Состояние
    state VARCHAR(50) NOT NULL, -- "ALIVE", "DEAD", "EXILED", "IMPRISONED", "REFORMED", "HOSTILE", "FRIENDLY"
    location VARCHAR(100), -- Текущая локация NPC
    
    -- Репутация с NPC (индивидуальная, отдельно от фракции)
    reputation_value INTEGER DEFAULT 0, -- -100 to +100
    
    -- Отношения
    is_hostile BOOLEAN DEFAULT FALSE,
    is_romanceable BOOLEAN DEFAULT FALSE,
    romance_stage INTEGER DEFAULT 0, -- 0-5
    
    -- Судьба NPC
    fate VARCHAR(100), -- "hero", "villain", "martyr", "exiled", "reformed", "dead"
    fate_set_by_quest VARCHAR(100),
    fate_set_by_character UUID, -- Игрок, который определил судьбу
    
    -- История
    previous_state VARCHAR(50),
    state_changed_at TIMESTAMP,
    
    -- Мета
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_npc_state_npc FOREIGN KEY (npc_id) REFERENCES npcs(id),
    CONSTRAINT fk_npc_fate_quest FOREIGN KEY (fate_set_by_quest) REFERENCES quests(id),
    CONSTRAINT fk_npc_fate_character FOREIGN KEY (fate_set_by_character) REFERENCES characters(id) ON DELETE SET NULL,
    UNIQUE(server_id, npc_id)
);

CREATE INDEX idx_npc_states_server ON npc_states(server_id);
CREATE INDEX idx_npc_states_npc ON npc_states(npc_id);
CREATE INDEX idx_npc_states_state ON npc_states(state);
CREATE INDEX idx_npc_states_fate ON npc_states(fate);
CREATE INDEX idx_npc_states_hostile ON npc_states(is_hostile) WHERE is_hostile = TRUE;
```

---

### 13. Таблица `quest_consequences` (Последствия квестов)

**Цель:** Хранение влияния квестов на будущие квесты и мир

```sql
CREATE TABLE quest_consequences (
    id SERIAL PRIMARY KEY,
    source_quest_id VARCHAR(100) NOT NULL, -- Квест-источник
    source_branch_id VARCHAR(50), -- Ветвь квеста (если применимо)
    
    -- Влияние на квесты
    affects_quest_id VARCHAR(100), -- Квест, на который влияет
    affects_era VARCHAR(20), -- Эпоха, на которую влияет (для долгосрочных последствий)
    
    -- Тип последствия
    consequence_type VARCHAR(50) NOT NULL, -- "UNLOCK_QUEST", "LOCK_QUEST", "MODIFY_QUEST", "WORLD_STATE", "NPC_FATE"
    
    -- Условия применения
    required_path VARCHAR(50), -- Путь, который нужен для применения последствия
    required_flags JSONB,
    
    -- Модификаторы
    modifiers JSONB, -- {hackingDC: -2, reputation: {...}, flags: [...]}
    
    -- World state изменения
    world_state_changes JSONB, -- {territoryControl: {...}, npcFates: {...}}
    
    -- Описание
    description TEXT,
    is_permanent BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_consequence_source FOREIGN KEY (source_quest_id) REFERENCES quests(id) ON DELETE CASCADE,
    CONSTRAINT fk_consequence_target FOREIGN KEY (affects_quest_id) REFERENCES quests(id)
);

CREATE INDEX idx_consequences_source ON quest_consequences(source_quest_id);
CREATE INDEX idx_consequences_target ON quest_consequences(affects_quest_id);
CREATE INDEX idx_consequences_type ON quest_consequences(consequence_type);
CREATE INDEX idx_consequences_era ON quest_consequences(affects_era);
```

---

### 14. Таблица `player_quest_consequences` (Примененные последствия к игроку)

**Цель:** Отслеживание примененных последствий для каждого игрока

```sql
CREATE TABLE player_quest_consequences (
    id SERIAL PRIMARY KEY,
    character_id UUID NOT NULL,
    consequence_id INTEGER NOT NULL, -- FK to quest_consequences
    
    -- Контекст
    applied_from_quest VARCHAR(100) NOT NULL,
    applied_from_branch VARCHAR(50),
    
    -- Статус
    is_active BOOLEAN DEFAULT TRUE,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- Для временных последствий
    
    -- Мета
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_player_consequence_character FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_consequence FOREIGN KEY (consequence_id) REFERENCES quest_consequences(id),
    CONSTRAINT fk_player_consequence_quest FOREIGN KEY (applied_from_quest) REFERENCES quests(id),
    UNIQUE(character_id, consequence_id)
);

CREATE INDEX idx_player_consequences_character ON player_quest_consequences(character_id);
CREATE INDEX idx_player_consequences_consequence ON player_quest_consequences(consequence_id);
CREATE INDEX idx_player_consequences_active ON player_quest_consequences(is_active) WHERE is_active = TRUE;
```

---

## 🔄 Примеры использования структуры

### Пример 1: Создание квеста "Капитан Моргана: Грань"

```sql
-- 1. Создать квест
INSERT INTO quests (id, name, description, type, difficulty, min_level, has_branches, era, region)
VALUES ('NCPD-MORGANA-001', 'Капитан Моргана: Грань', 'Детектив на грани...', 'FACTION', 'EXTREME', 20, true, '2020-2030', 'Night_City');

-- 2. Создать ветви
INSERT INTO quest_branches (quest_id, branch_id, branch_name, reputation_changes, sets_flags)
VALUES 
('NCPD-MORGANA-001', 'pathCorruption', 'Путь Коррупции', '{"NCPD": -20, "Arasaka": 10}', '["morgana_corrupt"]'),
('NCPD-MORGANA-001', 'pathTruth', 'Путь Правды', '{"NCPD": 30, "Arasaka": -15}', '["morgana_hero"]'),
('NCPD-MORGANA-001', 'pathLoner', 'Путь Одиночки', '{"NCPD": 5}', '["morgana_vigilante"]');

-- 3. Создать диалоговые узлы
INSERT INTO dialogue_nodes (quest_id, node_id, npc_id, npc_name, dialogue_text, node_type)
VALUES 
('NCPD-MORGANA-001', 1, 'npc-morgana', 'Капитан Моргана', 'Мой напарник убит...', 'dialogue'),
('NCPD-MORGANA-001', 2, 'npc-morgana', 'Капитан Моргана', 'Я нашла два подозреваемых...', 'choice');

-- 4. Создать выборы
INSERT INTO dialogue_choices (node_id, choice_id, choice_text, next_node_id, reputation_changes, sets_flags)
VALUES
(2, 'A1', 'Скрыть улики', 3, '{"NCPD": -10}', '["morgana_corrupt_start"]'),
(2, 'A2', 'Доложить IA', 4, '{"NCPD": 10}', '["morgana_truth_start"]'),
(2, 'A3', 'Расследовать сам', 5, '{}', '["morgana_loner_start"]');

-- 5. Создать skill check
INSERT INTO skill_checks (quest_id, check_id, check_name, check_type, skill, attribute, dc, success_node_id, failure_node_id)
VALUES
('NCPD-MORGANA-001', 'SC-001', 'Убедить Моргану', 'Social', 'Persuasion', 'EMP', 18, 6, 7);

-- 6. Создать последствия
INSERT INTO quest_consequences (source_quest_id, source_branch_id, consequence_type, world_state_changes)
VALUES
('NCPD-MORGANA-001', 'pathTruth', 'WORLD_STATE', '{"npcFates": {"morgana": "hero"}, "NCPD": "reformed"}');
```

### Пример 2: Отслеживание прогресса игрока

```sql
-- 1. Игрок начинает квест
INSERT INTO quest_progress (character_id, quest_id, current_node_id, status)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'NCPD-MORGANA-001', 1, 'ACTIVE');

-- 2. Игрок делает выбор
INSERT INTO player_quest_choices (character_id, quest_id, node_id, choice_id, choice_text, branch_id, applied_reputation, applied_flags)
VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'NCPD-MORGANA-001', 2, 'A2', 'Доложить IA', 'pathTruth', '{"NCPD": 10}', '["morgana_truth_start"]');

-- 3. Установить флаг игроку
INSERT INTO player_flags (character_id, flag_name, set_by_quest_id, set_by_choice_id, category)
VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'morgana_truth_start', 'NCPD-MORGANA-001', 'A2', 'QUEST');

-- 4. Обновить прогресс
UPDATE quest_progress
SET current_node_id = 4, current_branch_id = 'pathTruth', progress = 33
WHERE character_id = '550e8400-e29b-41d4-a716-446655440000' AND quest_id = 'NCPD-MORGANA-001';

-- 5. При завершении квеста
UPDATE quest_progress
SET status = 'COMPLETED', completed_at = NOW(), chosen_path = 'pathTruth', progress = 100
WHERE character_id = '550e8400-e29b-41d4-a716-446655440000' AND quest_id = 'NCPD-MORGANA-001';

-- 6. Применить последствия к мировому состоянию
INSERT INTO world_state (server_id, state_key, state_value, category, set_by_quest_id, set_by_event_id)
VALUES 
('server-01', 'npc_morgana_fate', 'hero', 'NPC_FATE', 'NCPD-MORGANA-001', NULL);

-- 7. Обновить состояние NPC
UPDATE npc_states
SET state = 'ALIVE', fate = 'hero', fate_set_by_quest = 'NCPD-MORGANA-001', 
    fate_set_by_character = '550e8400-e29b-41d4-a716-446655440000'
WHERE server_id = 'server-01' AND npc_id = 'npc-morgana';
```

### Пример 3: Проверка условий для следующего квеста

```sql
-- Проверить, может ли игрок начать квест "NCPD Reform"
-- (требуется завершить "NCPD-MORGANA-001" по пути "pathTruth")

SELECT 
    q.id,
    q.name,
    CASE 
        WHEN qp.quest_id IS NOT NULL AND qp.status = 'COMPLETED' AND qp.chosen_path = 'pathTruth' THEN true
        ELSE false
    END as can_start
FROM quests q
LEFT JOIN quest_progress qp 
    ON qp.character_id = '550e8400-e29b-41d4-a716-446655440000' 
    AND qp.quest_id = 'NCPD-MORGANA-001'
WHERE q.id = 'NCPD-REFORM-001';
```

### Пример 4: Получение истории выборов игрока

```sql
-- Получить всю историю выборов игрока для анализа
SELECT 
    pqc.quest_id,
    q.name as quest_name,
    pqc.choice_text,
    pqc.branch_id,
    pqc.moral_weight,
    pqc.applied_reputation,
    pqc.created_at
FROM player_quest_choices pqc
JOIN quests q ON q.id = pqc.quest_id
WHERE pqc.character_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY pqc.created_at DESC;
```

### Пример 5: Получение мирового состояния для региона

```sql
-- Получить состояние мира для Watson
SELECT 
    ws.state_key,
    ws.state_value,
    ws.category,
    ws.changed_at,
    q.name as changed_by_quest
FROM world_state ws
LEFT JOIN quests q ON q.id = ws.set_by_quest_id
WHERE ws.server_id = 'server-01' 
  AND ws.region = 'Watson'
ORDER BY ws.changed_at DESC;
```

---

## 📈 Индексы и оптимизация

### Критические индексы

1. **quest_progress**:
   - `(character_id, status)` - для получения активных квестов
   - `(quest_id, status)` - для статистики квестов
   - `(last_interaction_at)` - для нотификаций о неактивных квестах

2. **player_quest_choices**:
   - `(character_id, created_at DESC)` - история выборов
   - `(quest_id, branch_id)` - анализ популярности веток

3. **player_flags**:
   - `(character_id, flag_name)` - быстрая проверка флагов
   - `(category)` - фильтрация по категориям

4. **world_state**:
   - `(server_id, category, region)` - получение состояния региона
   - `(state_key)` - быстрый поиск конкретного состояния

5. **territory_control**:
   - `(server_id, region)` - карта контроля
   - `(is_contested)` - активные конфликты

### Оптимизации для производительности

1. **Партиционирование**:
   - `player_quest_choices` - по дате создания (monthly partitions)
   - `world_state_history` - по дате создания (monthly partitions)

2. **Материализованные представления**:
```sql
-- Популярные пути квестов
CREATE MATERIALIZED VIEW quest_path_popularity AS
SELECT 
    quest_id,
    chosen_path,
    COUNT(*) as times_chosen,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY quest_id), 2) as percentage
FROM quest_progress
WHERE status = 'COMPLETED' AND chosen_path IS NOT NULL
GROUP BY quest_id, chosen_path;

CREATE UNIQUE INDEX ON quest_path_popularity (quest_id, chosen_path);

-- Refresh периодически
REFRESH MATERIALIZED VIEW CONCURRENTLY quest_path_popularity;
```

3. **Кэширование**:
   - Кэшировать dialogue trees в Redis (полное дерево квеста)
   - Кэшировать world_state для быстрого доступа
   - Кэшировать player_flags для каждого игрока

4. **Денормализация для READ операций**:
   - Дублировать часто читаемые данные (например, current quest objectives в quest_progress)
   - Использовать JSONB для гибких структур

---

## 🔐 Права доступа и безопасность

### Роли БД

```sql
-- Игровой сервер (полный доступ к quest data)
CREATE ROLE game_server_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO game_server_role;
GRANT DELETE ON player_quest_choices, player_flags, player_quest_consequences TO game_server_role;

-- Аналитика (только чтение)
CREATE ROLE analytics_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_role;

-- Администратор квестов (создание/редактирование квестов)
CREATE ROLE quest_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON quests, quest_branches, dialogue_nodes, dialogue_choices, skill_checks, quest_consequences TO quest_admin_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO quest_admin_role;
```

### Row-Level Security (RLS)

```sql
-- Игроки могут видеть только свои данные
ALTER TABLE quest_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY quest_progress_player_policy ON quest_progress
    FOR ALL
    USING (character_id = current_setting('app.current_character_id')::UUID);

ALTER TABLE player_quest_choices ENABLE ROW LEVEL SECURITY;
CREATE POLICY player_choices_policy ON player_quest_choices
    FOR ALL
    USING (character_id = current_setting('app.current_character_id')::UUID);

ALTER TABLE player_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY player_flags_policy ON player_flags
    FOR ALL
    USING (character_id = current_setting('app.current_character_id')::UUID);
```

---

## 🚀 Миграция с текущей структуры

### Этап 1: Создание новых таблиц

```sql
-- Выполнить все CREATE TABLE statements из секции "Предлагаемая структура БД"
```

### Этап 2: Миграция данных

```sql
-- Миграция quests (обновление существующих полей)
UPDATE quests SET
    has_branches = false,
    era = '2020-2030', -- По умолчанию
    is_active = true,
    version = 1;

-- Миграция quest_progress (добавление новых полей)
UPDATE quest_progress SET
    progress = 0,
    version = 1;
```

### Этап 3: Обратная совместимость

```sql
-- Создать view для старого API
CREATE VIEW quests_legacy AS
SELECT 
    id,
    name,
    description,
    type,
    level as min_level,
    giver_npc_id,
    reward_experience,
    reward_money,
    reward_items,
    reward_reputation_faction,
    reward_reputation_amount,
    created_at,
    updated_at
FROM quests;
```

### Этап 4: Постепенный переход

1. **Неделя 1-2**: Развернуть новые таблицы, не трогая старые
2. **Неделя 3-4**: Обновить API для поддержки обеих структур
3. **Неделя 5-6**: Постепенная миграция квестов (по одному)
4. **Неделя 7-8**: Переключить frontend на новый API
5. **Неделя 9+**: Удалить старые таблицы после тестирования

---

## 📝 Следующие шаги

### 1. **Валидация структуры с командой**
   - [ ] Обсудить предложенную структуру с backend разработчиками
   - [ ] Проверить совместимость с текущим API
   - [ ] Оценить сложность миграции

### 2. **Прототипирование**
   - [ ] Создать тестовую БД с новой структурой
   - [ ] Загрузить 1-2 квеста с ветвлениями
   - [ ] Протестировать производительность запросов

### 3. **Документирование**
   - [ ] Создать ER-диаграмму
   - [ ] Написать API спецификации для новых endpoints
   - [ ] Создать гайды для разработчиков

### 4. **Имплементация**
   - [ ] Создать Liquibase миграции
   - [ ] Обновить Entity классы в BACK-JAVA
   - [ ] Обновить Repository классы
   - [ ] Создать Service слой для работы с ветвлениями

### 5. **Тестирование**
   - [ ] Unit тесты для новых Entity
   - [ ] Integration тесты для Quest branching logic
   - [ ] Load тесты для производительности

---

## 🎯 Ключевые преимущества предложенной структуры

1. **Полное ветвление** - поддержка сложных диалоговых деревьев
2. **Влияние на мир** - реальное изменение world state
3. **Масштабируемость** - структура готова к тысячам квестов
4. **Аудит** - полная история всех выборов
5. **MMORPG** - учет множества игроков и их влияния на мир
6. **Гибкость** - JSONB для расширения без изменения схемы
7. **Производительность** - правильные индексы и оптимизации
8. **Аналитика** - легко анализировать популярность путей

---

## 📚 Связанные документы

- `.BRAIN/04-narrative/quest-system.md` - Философия системы квестов
- `.BRAIN/04-narrative/quests/BRANCHING-QUESTS-SUMMARY.md` - Примеры квестов с ветвлениями
- `.BRAIN/05-technical/api-structures/quests-json-schema.md` - JSON-схемы квестов
- `.BRAIN/02-gameplay/world/events/global-events-2020-2093.md` - Глобальные события

---

## История изменений

- v1.0.0 (2025-11-06 20:31) - Создание документа с детальным анализом и предложениями

