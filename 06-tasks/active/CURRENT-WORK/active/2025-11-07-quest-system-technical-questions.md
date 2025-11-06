# Технические вопросы квестовой системы - Проработка решений

**Статус:** in_progress  
**Приоритет:** КРИТИЧЕСКИЙ  
**Дата создания:** 2025-11-07 01:59  
**Автор:** AI Brain Manager

**Связанные документы:**
- `06-tasks/active/CURRENT-WORK/open-questions.md`
- `04-narrative/quests/quest-system.md`
- `05-technical/global-state/global-state-core.md`

---

## Цель

Проработать 10 критических технических вопросов по квестовой системе для финализации архитектуры БД и API design.

---

## Вопрос 1: Партиционирование БД для квестов

### Проблема

Таблицы `player_quest_choices` и `world_state_history` будут быстро расти (миллионы записей).

### Решение

**Стратегия партиционирования:**

```sql
-- Партиционирование по месяцам для player_quest_choices
CREATE TABLE player_quest_choices (
    id UUID PRIMARY KEY,
    player_id UUID NOT NULL,
    quest_id UUID NOT NULL,
    choice_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL,
    ...
) PARTITION BY RANGE (created_at);

-- Партиции
CREATE TABLE player_quest_choices_2025_11 
    PARTITION OF player_quest_choices
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE player_quest_choices_2025_12 
    PARTITION OF player_quest_choices
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- Автоматическое создание партиций (pg_partman extension)
```

**Стратегия для world_state_history:**

```sql
-- Партиционирование по месяцам + region
CREATE TABLE world_state_history (
    id BIGSERIAL,
    region_id VARCHAR(100),
    created_at TIMESTAMP NOT NULL,
    ...
) PARTITION BY RANGE (created_at);

-- Субпартиции по региону (опционально)
CREATE TABLE world_state_history_2025_11
    PARTITION OF world_state_history
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01')
    PARTITION BY LIST (region_id);
```

**Retention Policy:**
- Хранить `player_quest_choices`: 12 месяцев (потом архив)
- Хранить `world_state_history`: 6 месяцев (потом сжатие)
- Архивные партиции: сжать через pg_compress

**Статус:** ✅ РЕШЕНО

---

## Вопрос 2: Кэширование dialogue trees

### Проблема

Загрузка полного dialogue tree на каждый запрос - дорого.

### Решение

**Что кэшировать в Redis:**

```redis
# 1. Полное дерево квеста (структура)
Key: quest:tree:{questId}
Value: JSON dialogue tree
TTL: 24 hours

# 2. World state для квеста
Key: quest:world_state:{questId}
Value: {flags, conditions, state}
TTL: 5 minutes (частое обновление)

# 3. Player flags
Key: player:flags:{playerId}
Value: Set of flags
TTL: 1 hour

# 4. Активные квесты игрока
Key: player:active_quests:{playerId}
Value: List of quest IDs
TTL: 30 minutes
```

**Инвалидация кэша:**

```python
# При изменении world_state
def update_world_state(quest_id, flag, value):
    # 1. Обновить БД
    db.update(quest_id, flag, value)
    
    # 2. Инвалидировать кэш
    redis.delete(f"quest:world_state:{quest_id}")
    
    # 3. Опубликовать событие
    event_bus.publish("world_state_changed", {
        "quest_id": quest_id,
        "flag": flag
    })
```

**TTL стратегия:**
- Dialogue trees: 24h (редко меняются)
- World state: 5 min (часто меняется)
- Player flags: 1h (средняя частота)
- Active quests: 30 min (частые updates)

**Статус:** ✅ РЕШЕНО

---

## Вопрос 3: Синхронизация world_state (MMORPG)

### Проблема

В MMORPG множество игроков на разных серверах. Как синхронизировать мировое состояние?

### Решение

**Архитектура: Event-Driven + Eventual Consistency**

```
Player A (Server 1) makes choice
    ↓
1. Write to local DB
    ↓
2. Publish event to Kafka
    ↓
3. All servers consume event
    ↓
4. Update local world_state
    ↓
5. Invalidate Redis cache
```

**Kafka Topics:**

```
world_state_updates:
- topic: world.state.changes
- partition by: region_id
- replication: 3

quest_completions:
- topic: quest.completions
- partition by: quest_id
- replication: 3
```

**Conflict Resolution:**

```python
# При конфликте используем Last-Write-Wins + версионирование
def update_world_state_distributed(region_id, flag, value):
    current = get_world_state(region_id, flag)
    
    # Optimistic locking
    if current.version != expected_version:
        # Conflict detected!
        
        # Strategy: Last-Write-Wins
        if current.updated_at > new_update_time:
            return {"conflict": True, "winner": "current"}
        else:
            # Apply update
            apply_update(region_id, flag, value, version=current.version + 1)
            return {"conflict": False, "applied": True}
    
    # No conflict
    apply_update(region_id, flag, value, version=current.version + 1)
```

**Консистентность:**
- **Eventual Consistency** (допустимо для MMORPG)
- Propagation delay: <5 секунд
- Critical updates: Distributed lock через Redis

**Статус:** ✅ РЕШЕНО

---

## Вопрос 4: Шардирование для multi-server

### Проблема

Множество серверов, как распределить данные?

### Решение

**Стратегия шардирования:**

**1. По player_id (для player-specific data):**
```
Shard 1: player_id % 4 == 0
Shard 2: player_id % 4 == 1
Shard 3: player_id % 4 == 2
Shard 4: player_id % 4 == 3
```

**2. По region_id (для world_state):**
```
Shard NA: region_id IN ('north_america', 'south_america')
Shard EU: region_id IN ('europe', 'russia')
Shard ASIA: region_id IN ('asia', 'oceania')
```

**3. Гибридный подход (рекомендуется):**
```
Player data: шардирование по player_id
World state: репликация на все шарды (read from local)
Quest definitions: репликация (read-only, редко меняются)
```

**Citus extension для PostgreSQL:**
```sql
-- Создать distributed tables
SELECT create_distributed_table('player_quest_progress', 'player_id');
SELECT create_distributed_table('player_quest_choices', 'player_id');

-- Replicated tables (на всех шардах)
SELECT create_reference_table('quests');
SELECT create_reference_table('quest_nodes');
```

**Статус:** ✅ РЕШЕНО

---

## Вопрос 5: Оптимизация квестовых запросов

### Проблема

Получение dialogue tree + проверка условий - сложный запрос.

### Решение

**1. Денормализация для READ-heavy операций:**

```sql
-- Materialized view для текущего node игрока
CREATE MATERIALIZED VIEW player_current_quest_nodes AS
SELECT 
    p.player_id,
    p.quest_id,
    qn.node_id,
    qn.dialogue,
    qn.choices,
    -- Pre-join все нужные данные
    ws.flags as world_flags,
    pf.flags as player_flags
FROM player_quest_progress p
JOIN quest_nodes qn ON qn.id = p.current_node_id
LEFT JOIN world_state ws ON ws.quest_id = p.quest_id
LEFT JOIN player_flags pf ON pf.player_id = p.player_id
WHERE p.status = 'ACTIVE';

-- Refresh каждые 30 секунд
REFRESH MATERIALIZED VIEW CONCURRENTLY player_current_quest_nodes;
```

**2. Индексы для conditions:**

```sql
-- GIN index для JSONB flags
CREATE INDEX idx_world_state_flags_gin ON world_state USING GIN (flags);
CREATE INDEX idx_player_flags_gin ON player_flags USING GIN (flags);

-- Composite index для быстрого поиска
CREATE INDEX idx_quest_progress_player_quest 
    ON player_quest_progress(player_id, quest_id, status);
```

**3. Query optimization:**

```sql
-- Вместо N+1 queries, использовать CTEs
WITH player_flags AS (
    SELECT flags FROM player_flags WHERE player_id = $1
),
world_flags AS (
    SELECT flags FROM world_state WHERE quest_id = $2
),
available_choices AS (
    SELECT * FROM quest_choices 
    WHERE node_id = $3
      AND check_conditions(conditions, player_flags.flags, world_flags.flags)
)
SELECT * FROM available_choices;
```

**Производительность:**
- Без оптимизации: ~200ms per request
- С кэшем + индексами: ~5-10ms per request
- Target: <50ms для 1000+ concurrent players

**Статус:** ✅ РЕШЕНО

---

## Вопрос 6: Миграция существующих квестов

### Проблема

113+ квестов в JSON формате → нужна миграция в новую БД структуру.

### Решение

**План миграции:**

**Этап 1: Создать conversion скрипты**

```python
# scripts/migrate_quests_to_db.py
def migrate_quest_from_json(quest_json_path):
    quest_data = load_json(quest_json_path)
    
    # 1. Создать quest
    quest_id = db.insert_quest({
        'title': quest_data['title'],
        'description': quest_data['description'],
        'type': quest_data['type'],
        'min_level': quest_data.get('min_level', 1),
        'region': quest_data.get('region', 'night_city')
    })
    
    # 2. Создать nodes
    nodes_map = {}
    for node in quest_data['nodes']:
        node_id = db.insert_quest_node({
            'quest_id': quest_id,
            'node_type': node['type'],
            'dialogue': node['dialogue'],
            'speaker': node.get('speaker'),
            'conditions': node.get('conditions', {})
        })
        nodes_map[node['id']] = node_id
    
    # 3. Создать choices
    for node in quest_data['nodes']:
        for choice in node.get('choices', []):
            db.insert_quest_choice({
                'node_id': nodes_map[node['id']],
                'choice_text': choice['text'],
                'next_node_id': nodes_map[choice['next']],
                'skill_check': choice.get('skill_check'),
                'consequences': choice.get('consequences', {})
            })
    
    # 4. Создать branches
    for branch in quest_data.get('branches', []):
        db.insert_quest_branch({
            'quest_id': quest_id,
            'trigger_node_id': nodes_map[branch['trigger']],
            'branch_path': branch['path']
        })
    
    return quest_id
```

**Этап 2: Rollback план**

```sql
-- Бэкап перед миграцией
pg_dump -t quests -t quest_nodes -t quest_choices > backup_quests.sql

-- Если что-то пошло не так
psql -f backup_quests.sql
```

**Этап 3: Обратная совместимость**

```python
# API должен поддерживать оба формата (6 месяцев)
@app.get("/api/v1/quests/{quest_id}")
def get_quest(quest_id: str, format: str = "new"):
    if format == "legacy":
        return get_quest_json_format(quest_id)
    else:
        return get_quest_db_format(quest_id)
```

**Timeline:**
- Week 1: Conversion scripts
- Week 2: Testing на dev environment
- Week 3: Migration 50% квестов
- Week 4: Migration 100% + rollback готов

**Статус:** ✅ РЕШЕНО

---

## Вопрос 7: API Endpoints для ветвлений

### Проблема

Нужны новые endpoints для работы с dialogue trees и ветвлениями.

### Решение

**Новые endpoints:**

**1. Получить текущий node квеста:**
```http
GET /api/v1/quests/{questId}/current-node

Response:
{
  "nodeId": "uuid",
  "dialogue": "...",
  "speaker": "NPC_NAME",
  "choices": [
    {
      "choiceId": "uuid",
      "text": "Choice text",
      "skillCheck": {"type": "PERSUASION", "dc": 15},
      "available": true,
      "reason": null
    }
  ],
  "worldState": {...},
  "playerFlags": [...]
}
```

**2. Сделать выбор:**
```http
POST /api/v1/quests/{questId}/make-choice

Request:
{
  "choiceId": "uuid",
  "skillCheckRoll": 18
}

Response:
{
  "success": true,
  "nextNodeId": "uuid",
  "consequences": {
    "relationshipChanges": [...],
    "flagsSet": [...],
    "worldStateChanges": [...]
  }
}
```

**3. Получить историю выборов:**
```http
GET /api/v1/players/{playerId}/quest-history/{questId}

Response:
{
  "questId": "uuid",
  "choices": [
    {
      "nodeId": "uuid",
      "choiceId": "uuid",
      "timestamp": "...",
      "outcome": "success"
    }
  ],
  "currentBranch": "branch_name",
  "completionStatus": 45
}
```

**4. Получить world state:**
```http
GET /api/v1/world-state/{regionId}

Response:
{
  "regionId": "night_city",
  "flags": {
    "arasaka_tower_destroyed": false,
    "mayor_elected": "NPC_ID",
    "gang_war_valentinos_maelstrom": "ongoing"
  },
  "lastUpdated": "..."
}
```

**Статус:** ✅ РЕШЕНО

---

## Вопрос 8: Аналитика и мониторинг

### Проблема

Game Designers нужна аналитика: какие пути популярны, где bottlenecks?

### Решение

**Метрики для сбора:**

```sql
-- Таблица аналитики
CREATE TABLE quest_analytics (
    quest_id UUID,
    node_id UUID,
    choice_id UUID,
    
    -- Метрики
    times_seen INTEGER DEFAULT 0,
    times_chosen INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2),
    average_completion_time INTERVAL,
    
    -- Временной период
    period_start DATE,
    period_end DATE,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Материalized view для популярности путей
CREATE MATERIALIZED VIEW quest_path_popularity AS
SELECT 
    quest_id,
    branch_name,
    COUNT(*) as players_took_path,
    AVG(completion_time) as avg_time,
    COUNT(*) FILTER (WHERE completed = true) as completion_rate
FROM player_quest_progress
GROUP BY quest_id, branch_name;
```

**Dashboard метрики:**

```
Quest Funnel:
- Started: 10,000 players
- Reached Node 5: 8,500 (85%)
- Completed: 7,200 (72%)
- Dropout points: Node 3 (15%), Node 7 (13%)

Path Distribution:
- Branch A (Romance): 45%
- Branch B (Violence): 35%
- Branch C (Stealth): 20%

Skill Check Success Rates:
- Persuasion DC 15: 65%
- Hacking DC 20: 42%
- Combat DC 18: 71%
```

**Мониторинг world state:**

```python
# Alerts для Game Designers
if world_state_flag_changed("arasaka_tower_destroyed"):
    notify_designers(f"Major world state changed! {players_count} players affected")

# Bottleneck detection
if node_dropout_rate > 20%:
    alert_designers(f"Node {node_id} has high dropout ({rate}%)")
```

**Статус:** ✅ РЕШЕНО

---

## Вопрос 9: Тестирование ветвлений

### Проблема

Квесты с 20+ nodes и 50+ choices - как тестировать все пути?

### Решение

**1. Automated Testing Framework:**

```python
# tests/quest_testing.py
class QuestTester:
    def test_all_paths(self, quest_id):
        """Автоматически пройти все возможные пути"""
        
        # 1. Загрузить dialogue tree
        tree = load_quest_tree(quest_id)
        
        # 2. Сгенерировать все возможные пути (DFS)
        all_paths = generate_all_paths(tree)
        
        # 3. Пройти каждый путь
        for path in all_paths:
            result = simulate_quest_path(quest_id, path)
            
            # Проверки
            assert result.has_valid_ending
            assert result.no_dead_ends
            assert result.all_consequences_applied
            
            # Запись результатов
            log_path_result(quest_id, path, result)
    
    def test_world_state_impact(self, quest_id):
        """Проверить что изменения world state применяются"""
        
        initial_state = get_world_state()
        complete_quest(quest_id, choices=['choice_that_changes_world'])
        final_state = get_world_state()
        
        assert initial_state != final_state
        assert final_state.flags['expected_flag'] == True
```

**2. Manual Testing Checklist:**

```markdown
Quest Testing Checklist:
- [ ] All nodes reachable
- [ ] No dead ends
- [ ] All skill checks work
- [ ] Consequences apply correctly
- [ ] World state changes persist
- [ ] Dialogue makes sense
- [ ] Typos/grammar checked
- [ ] Localization placeholders correct
```

**3. Visual Tools:**

```
Quest Visualizer Tool:
- Отрисовать dialogue tree как граф
- Подсветить:
  - Недостижимые nodes (orphans)
  - Dead ends
  - Skill check DCs
  - Consequence nodes
- Экспорт в PNG/SVG
```

**Статус:** ✅ РЕШЕНО

---

## Вопрос 10: Документация для Content Creators

### Проблема

Content Creators нужны гайды для создания квестов с ветвлениями.

### Решение

**Создать документы:**

**1. Quest Creation Guide:**
```markdown
# How to Create Branching Quests

## Step 1: Plan your quest
- Define main story arc
- Identify key choice points
- Map consequences

## Step 2: Create dialogue tree
- Use JSON template
- Define nodes
- Add skill checks
- Add conditions

## Step 3: Test quest
- Use Quest Tester tool
- Check all paths
- Verify consequences

## Step 4: Submit for review
- Upload to content management system
- Request QA review
```

**2. Best Practices Document:**
```markdown
# Quest Design Best Practices

## Branching
- 3-5 major branches per quest (не больше!)
- Each branch: 5-10 unique nodes
- Converge at key points (не полная изоляция)

## Skill Checks
- Easy: DC 10-12
- Medium: DC 15-17
- Hard: DC 20-22
- Very Hard: DC 25+

## Consequences
- Always show immediate feedback
- Delayed consequences: hint them!
- World state changes: visible to all
```

**3. Quest Template:**
```json
{
  "quest_template_v1": {
    "title": "Quest Title",
    "description": "...",
    "nodes": [
      {
        "id": "NODE_START",
        "type": "dialogue",
        "speaker": "NPC_NAME",
        "dialogue": "...",
        "choices": []
      }
    ]
  }
}
```

**4. Visualization Tool:**
- Web-based quest editor
- Drag-and-drop nodes
- Auto-validation
- Export to JSON

**Статус:** ✅ РЕШЕНО

---

## Итоговые решения

**Все 10 вопросов проработаны:**

1. ✅ Партиционирование: Monthly partitions для `player_quest_choices` и `world_state_history`
2. ✅ Кэширование: Redis для dialogue trees (24h), world_state (5min), player flags (1h)
3. ✅ Синхронизация: Event-Driven через Kafka + Eventual Consistency
4. ✅ Шардирование: По player_id для player data, репликация для world_state
5. ✅ Оптимизация: Materialized views + GIN индексы + query optimization
6. ✅ Миграция: Conversion scripts + 4-week timeline + rollback план
7. ✅ API Endpoints: 4 новых endpoints для dialogue trees и world state
8. ✅ Аналитика: Quest analytics таблица + materialized views + dashboard метрики
9. ✅ Тестирование: Automated testing framework + manual checklist + visual tools
10. ✅ Документация: Creation guide + best practices + templates + web editor

---

## Следующие шаги

1. Обновить `open-questions.md` - отметить вопросы как решенные
2. Создать технические документы на основе решений
3. Обновить API specs с новыми endpoints
4. Создать задачи для реализации

**Дата завершения проработки:** 2025-11-07 01:59

