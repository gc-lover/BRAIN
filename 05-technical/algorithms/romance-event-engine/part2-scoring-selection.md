# Romance Event Engine - Part 2: Scoring & Selection

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:07  
**Часть:** 2 из 3

[← Part 1](./part1-filtering-weighting.md) | [Навигация](./README.md) | [Part 3 →](./part3-advanced-systems.md)

---

## 3. Event Scoring (Оценка)

### Composite Score Formula

```python
def calculate_final_event_score(event, weight, player, npc, relationship, context):
    """
    Финальная оценка события для ранжирования
    Returns: 0-100
    """
    
    score = weight  # Start with weight (0-100)
    
    # === Context Bonuses ===
    
    # Perfect location bonus
    if context.location in event.triggers.perfect_locations:
        score += 10
    
    # Special date/time bonus
    if is_special_date(context.date, npc.culture):  # Birthday, holiday, etc.
        score += 15
    
    # Weather bonus
    if event.triggers.weather_preferred == context.weather:
        score += 5
    
    # === Relationship State Bonuses ===
    
    # Progress momentum (ready for next stage)
    if relationship.score >= (event.relationship_min + 5):  # Near top of range
        score += 10  # Good time to advance
    
    # Chemistry synergy
    chemistry_diff = abs(relationship.chemistry - event.optimal_chemistry)
    if chemistry_diff < 10:
        score += 15  # Perfect chemistry match
    
    # === AI Learning Bonuses ===
    
    # Player historically likes this type
    if event.category in player.favorite_event_types:
        score += 12
    
    # NPC historically positive reaction to similar
    if similar_events_positive(event, npc, history):
        score += 10
    
    # === Variety Bonus ===
    
    # Encourage variety (not same category repeatedly)
    if event.category not in history.last_n_categories(3):
        score += 8
    
    # === Drama/Conflict Management ===
    
    # Inject conflict if too smooth (add drama)
    if relationship.events_since_conflict > 10 and event.category != 'conflict':
        score -= 5  # Slightly prefer conflict to add drama
    
    # Avoid conflict if too many unresolved
    if event.category == 'conflict' and relationship.conflicts_unresolved >= 2:
        score -= 20
    
    # === Random Factor (реализм) ===
    random_factor = random.randint(-5, 5)
    score += random_factor
    
    return max(0, min(100, score))
```

---

## 4. Event Selection (Выбор)

### Selection Strategy

```python
def select_next_events(player, npc, relationship, count=3):
    """
    Выбрать топ-N событий для предложения игроку
    Returns: List of recommended events
    """
    
    # 1. Get all events from database
    all_events = get_all_romance_events()
    
    # 2. Hard filter
    available = filter_events_hard(all_events, player, npc, relationship)
    
    # 3. Soft filter
    preferred = filter_events_soft(available, player, npc, relationship, history)
    
    # 4. Calculate weights
    weighted = [
        (event, calculate_event_weight(event, player, npc, relationship, chemistry))
        for event in preferred
    ]
    
    # 5. Calculate final scores
    scored = [
        (event, calculate_final_event_score(event, weight, player, npc, relationship, context))
        for event, weight in weighted
    ]
    
    # 6. Sort by score
    scored.sort(key=lambda x: x[1], reverse=True)
    
    # 7. Select top N
    top_events = [event for event, score in scored[:count]]
    
    # 8. Ensure variety in selection
    top_events = ensure_variety(top_events, min_different_categories=2)
    
    # 9. Add random wildcard (5% chance)
    if random.random() < 0.05:
        wildcard = random.choice(available)
        top_events.append(wildcard)
    
    return top_events
```

---

### NPC-Initiated Events

```python
def npc_initiate_event(npc, player, relationship):
    """
    NPC инициирует событие (звонок, текст, случайная встреча)
    """
    
    # Check if NPC personality is proactive
    if npc.personality.extraversion < 50:
        chance = 0.10  # 10% for introverts
    else:
        chance = 0.30  # 30% for extroverts
    
    # Increase chance if high relationship
    if relationship.score > 70:
        chance += 0.20
    
    # Decrease if recent conflict
    if relationship.conflicts_unresolved > 0:
        chance -= 0.15
    
    if random.random() < chance:
        # NPC initiates!
        event_type = select_npc_initiated_type(npc, relationship)
        
        # Send notification to player
        send_notification(
            player_id=player.id,
            npc_id=npc.id,
            type='phone_call' if urgent else 'text_message',
            message=generate_invitation_message(npc, event_type, relationship)
        )
        
        return True
    
    return False
```

---

## 5. Event Adaptation (Адаптация)

### Cultural Adaptation

```python
def adapt_event_to_culture(event, npc_culture, player_cultural_knowledge):
    """
    Адаптировать событие под культуру NPC
    """
    
    cultural_context = get_cultural_context(npc_culture)
    adapted_event = event.copy()
    
    # === Dialogue Adaptation ===
    adapted_event.dialogue = translate_dialogue(
        event.dialogue, 
        npc_culture.primary_language,
        include_cultural_references=True
    )
    
    # === DC Modification ===
    # Easier if player knows culture
    if player_cultural_knowledge.knows(npc_culture.id):
        adapted_event.skill_check.dc -= cultural_context.knowledge_bonus
    else:
        adapted_event.skill_check.dc += 2  # Harder if unfamiliar
    
    # === PDA Adaptation ===
    if event.involves_pda and not cultural_context.pda_allowed:
        # Replace public display with private version
        adapted_event = replace_pda_with_private_version(event)
        adapted_event.warnings.append("Public displays of affection not culturally appropriate")
    
    # === Family Involvement ===
    if cultural_context.family_approval_required and event.category == 'commitment':
        # Add family approval step
        adapted_event.additional_steps.append({
            "step": "family_approval",
            "dc": 24,
            "critical": True
        })
    
    # === Language Bonuses ===
    if player.speaks(npc_culture.primary_language):
        adapted_event.bonuses.append({
            "type": "language",
            "value": cultural_context.language_bonus,
            "description": f"You speak {npc_culture.primary_language}"
        })
    
    # === Timing Adaptation ===
    # Some cultures: romance slower
    if cultural_context.romance_tempo == 'very_slow':
        adapted_event.relationship_gain *= 0.7  # 30% slower progress
    elif cultural_context.romance_tempo == 'very_fast':
        adapted_event.relationship_gain *= 1.3  # 30% faster progress
    
    return adapted_event
```

---

[Part 3: Advanced Systems →](./part3-advanced-systems.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:07) - Создан из romance-event-engine.md (ПОЛНЫЙ код)

