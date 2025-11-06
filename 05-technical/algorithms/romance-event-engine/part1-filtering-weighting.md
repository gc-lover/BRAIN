# Romance Event Engine - Part 1: Filtering & Weighting

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:06  
**Часть:** 1 из 3

[Навигация](./README.md) | [Part 2 →](./part2-scoring-selection.md)

---

## 1. Event Filtering (Фильтрация)

### Phase 1: Hard Filters (Обязательные условия)

```python
def filter_events_hard(events, player, npc, relationship):
    """Убираем события, которые точно не подходят"""
    filtered = []
    
    for event in events:
        # Check relationship range
        if not (event.relationship_min <= relationship.score <= event.relationship_max):
            continue
        
        # Check if already completed (for unique events)
        if event.unique and event.id in relationship.completed_events:
            continue
        
        # Check location compatibility
        if event.triggers.location_required:
            if player.location not in event.triggers.locations:
                continue
        
        # Check time compatibility
        if event.triggers.time_required:
            if current_time() not in event.triggers.time:
                continue
        
        # Check season (if required)
        if event.triggers.season:
            if current_season() != event.triggers.season:
                continue
        
        # Check chemistry minimum
        if event.triggers.chemistry_min:
            if relationship.chemistry < event.triggers.chemistry_min:
                continue
        
        # Check cultural compatibility
        if event.culture_specific:
            if not is_culturally_compatible(player, npc, event):
                continue
        
        filtered.append(event)
    
    return filtered
```

---

### Phase 2: Soft Filters (Предпочтения)

```python
def filter_events_soft(events, player, npc, relationship, history):
    """Приоритизируем события по предпочтениям"""
    scored_events = []
    
    for event in events:
        score = 0
        
        # Avoid repetition (недавно использованные события)
        if event.category in history.recent_categories(last=5):
            score -= 20
        
        # Prefer events matching current arc phase
        if event.category == get_expected_category(relationship.score):
            score += 30
        
        # Prefer regional events if in NPC's region
        if event.region == npc.home_region and player.location == npc.home_city:
            score += 25
        
        # Prefer events matching player preferences
        if event.category in player.preferences.favorite_event_types:
            score += 15
        
        # Avoid conflict events if relationship fragile
        if event.category == 'conflict' and relationship.health < 50:
            score -= 30
        
        scored_events.append((event, score))
    
    # Sort by score
    scored_events.sort(key=lambda x: x[1], reverse=True)
    
    return [event for event, score in scored_events if score > 0]
```

---

## 2. Event Weighting (Взвешивание)

### Факторы веса события

```python
def calculate_event_weight(event, player, npc, relationship, chemistry):
    """Рассчитать вес события (0-100)"""
    
    weight = 50  # Base weight
    
    # === Personality Match (0-25 points) ===
    personality_alignment = calculate_personality_alignment(
        player.personality, 
        npc.personality, 
        event.personality_requirements
    )
    weight += (personality_alignment / 100) * 25
    
    # === Chemistry Boost (0-20 points) ===
    if chemistry.total > 80:
        weight += 20
    elif chemistry.total > 60:
        weight += 15
    elif chemistry.total > 40:
        weight += 10
    
    # === Timing Appropriateness (0-15 points) ===
    if is_perfect_timing(event, relationship, history):
        weight += 15
    elif is_good_timing(event, relationship):
        weight += 10
    
    # === Cultural Appropriateness (0-15 points) ===
    cultural_fit = calculate_cultural_fit(event, npc.culture, player.cultural_knowledge)
    weight += (cultural_fit / 100) * 15
    
    # === Narrative Coherence (0-15 points) ===
    if fits_narrative_arc(event, relationship.arc):
        weight += 15
    
    # === Player Preferences (0-10 points) ===
    if event.category in player.preferences.preferred_categories:
        weight += 10
    
    # === Penalties ===
    
    # Repetition penalty
    if event.category in history.recent_categories(last=3):
        weight -= 15
    
    # Incompatibility penalty
    if event.requires_trait and not npc.has_trait(event.requires_trait):
        weight -= 20
    
    # Risk penalty (if relationship fragile)
    if event.category == 'conflict' and relationship.health < 60:
        weight -= 25
    
    # Out of region penalty
    if event.region and event.region != player.current_region:
        weight -= 10
    
    return max(0, min(100, weight))
```

---

### Personality Alignment Calculation

```python
def calculate_personality_alignment(player_personality, npc_personality, event_requirements):
    """
    Рассчитать насколько личности игрока и NPC подходят для события
    Returns: 0-100
    """
    
    if not event_requirements:
        return 75  # Neutral if no requirements
    
    alignment = 0
    factors = 0
    
    # Check each personality trait
    for trait, required_range in event_requirements.items():
        if trait in npc_personality:
            npc_value = npc_personality[trait]
            min_req, max_req = required_range
            
            if min_req <= npc_value <= max_req:
                alignment += 100  # Perfect match
            else:
                # Calculate distance from range
                if npc_value < min_req:
                    distance = min_req - npc_value
                else:
                    distance = npc_value - max_req
                
                # Penalty proportional to distance
                alignment += max(0, 100 - (distance * 2))
            
            factors += 1
    
    return alignment / factors if factors > 0 else 50
```

---

[Part 2: Scoring & Selection →](./part2-scoring-selection.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:06) - Создан из romance-event-engine.md (ПОЛНЫЙ код)

