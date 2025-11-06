---
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06
---

# Romance Event Selection Engine

Алгоритм выбора подходящих романтических событий на основе AI и множества факторов.


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-164](../../../API-SWAGGER/tasks/active/queue/task-164-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Архитектура Engine

```
Player Context + NPC Profile + Current Relationship State
                    ↓
            Event Selection Engine
                    ↓
    Filter → Weight → Score → Select → Adapt
                    ↓
            Recommended Event(s)
```

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

## 6. Chemistry Calculator

### Comprehensive Chemistry System

```python
class ChemistryCalculator:
    """Расчёт совместимости между игроком и NPC"""
    
    def calculate_total_chemistry(self, player, npc):
        """
        Главная функция расчёта chemistry (0-100)
        """
        
        # Components
        personality_match = self.calculate_personality_match(player, npc)
        shared_interests = self.calculate_shared_interests(player, npc)
        physical_attraction = self.calculate_physical_attraction(player, npc)
        cultural_compatibility = self.calculate_cultural_compatibility(player, npc)
        
        # Weights (configurable)
        weights = {
            'personality': 0.40,
            'interests': 0.30,
            'attraction': 0.20,
            'cultural': 0.10
        }
        
        # Weighted sum
        total = (
            personality_match * weights['personality'] +
            shared_interests * weights['interests'] +
            physical_attraction * weights['attraction'] +
            cultural_compatibility * weights['cultural']
        )
        
        return int(total)
    
    def calculate_personality_match(self, player, npc):
        """
        Big Five personality compatibility (0-100)
        """
        
        # Get personality vectors
        p_personality = player.personality
        n_personality = npc.personality
        
        match_score = 0
        
        # Openness: Similar is good
        openness_diff = abs(p_personality.openness - n_personality.openness)
        match_score += max(0, 100 - openness_diff)
        
        # Conscientiousness: Similar or complementary
        consc_diff = abs(p_personality.conscientiousness - n_personality.conscientiousness)
        if consc_diff < 30:  # Similar
            match_score += 100
        else:  # Very different might work (opposites attract)
            match_score += 60
        
        # Extraversion: Complementary often good (extrovert + introvert)
        extrav_sum = p_personality.extraversion + n_personality.extraversion
        if 80 <= extrav_sum <= 120:  # One intro, one extro
            match_score += 100
        elif extrav_sum > 150 or extrav_sum < 50:  # Both very similar
            match_score += 80
        
        # Agreeableness: Higher is better for relationships
        avg_agree = (p_personality.agreeableness + n_personality.agreeableness) / 2
        match_score += avg_agree
        
        # Neuroticism: Lower combined is better
        avg_neuro = (p_personality.neuroticism + n_personality.neuroticism) / 2
        match_score += (100 - avg_neuro)
        
        # Romance-specific traits
        if hasattr(npc.personality, 'romanticism'):
            # High romanticism NPC needs romantic player
            if p_personality.romanticism and n_personality.romanticism:
                romantic_match = 100 - abs(p_personality.romanticism - n_personality.romanticism)
                match_score += romantic_match
        
        # Average all factors
        return int(match_score / 6)
    
    def calculate_shared_interests(self, player, npc):
        """
        Общие интересы (0-100)
        """
        
        player_interests = set(player.interests + player.hobbies)
        npc_interests = set(npc.interests + npc.hobbies)
        
        # Intersection
        shared = player_interests.intersection(npc_interests)
        
        # Calculate percentage
        total_unique = len(player_interests.union(npc_interests))
        if total_unique == 0:
            return 50
        
        shared_percentage = (len(shared) / total_unique) * 100
        
        # Boost if shared interests in important categories
        important_shared = shared.intersection({'music', 'art', 'sports', 'tech', 'cooking'})
        boost = len(important_shared) * 5
        
        return min(100, int(shared_percentage * 2 + boost))
    
    def calculate_physical_attraction(self, player, npc):
        """
        Физическое влечение (0-100)
        Базируется на предпочтениях + random factor
        """
        
        base_attraction = 50  # Neutral start
        
        # Gender preference
        if player.sexual_orientation == 'heterosexual':
            if player.gender != npc.gender:
                base_attraction += 30
            else:
                return 0  # Not attracted
        elif player.sexual_orientation == 'homosexual':
            if player.gender == npc.gender:
                base_attraction += 30
            else:
                return 0
        else:  # Bisexual, pansexual
            base_attraction += 20
        
        # Age preference
        age_diff = abs(player.age - npc.age)
        if age_diff <= 5:
            base_attraction += 15
        elif age_diff <= 10:
            base_attraction += 10
        elif age_diff > 20:
            base_attraction -= 20
        
        # Physical traits preferences (if system has this)
        if player.preferences.physical_traits:
            matches = count_matching_traits(player.preferences.physical_traits, npc.physical_traits)
            base_attraction += matches * 5
        
        # Random chemistry factor (пресловутая "искра")
        random_chemistry = random.randint(20, 50)
        
        # Charisma influence
        charisma_bonus = (npc.attributes.COOL - 10) * 2  # -10 to +10 bonus
        
        total = base_attraction + random_chemistry + charisma_bonus
        
        return max(0, min(100, total))
    
    def calculate_cultural_compatibility(self, player, npc):
        """
        Культурная совместимость (0-100)
        """
        
        compatibility = 50  # Neutral
        
        # Same culture: bonus
        if player.culture == npc.culture:
            compatibility += 40
        
        # Similar region: moderate bonus
        elif player.region == npc.region:
            compatibility += 20
        
        # Player knows NPC's culture: bonus
        if npc.culture in player.cultural_knowledge:
            compatibility += 30
        
        # Player speaks NPC's language: big bonus
        if npc.primary_language in player.languages:
            compatibility += 25
        
        # Cultural openness
        if player.personality.openness > 70:
            compatibility += 10  # Open to new cultures
        
        # NPC's traditionalism
        if npc.personality.traditionalism > 70:
            # Traditional NPC prefers same culture
            if player.culture != npc.culture:
                compatibility -= 20
        
        return max(0, min(100, compatibility))
```

## 7. Trigger System

### Event Trigger Engine

```python
class EventTriggerEngine:
    """Система триггеров событий"""
    
    def check_triggers(self, event, player, npc, relationship, context):
        """
        Проверить все триггеры события
        Returns: (bool, reason)
        """
        
        triggers = event.triggers
        
        # === Location Triggers ===
        if 'locations' in triggers:
            if context.location not in triggers['locations']:
                return False, f"Wrong location. Need: {triggers['locations']}"
        
        # === Time Triggers ===
        if 'time' in triggers:
            current_time_category = self.get_time_category(context.time)
            if current_time_category not in triggers['time']:
                return False, f"Wrong time. Need: {triggers['time']}"
        
        # === Season Triggers ===
        if 'season' in triggers:
            if context.season != triggers['season']:
                return False, f"Wrong season. Need: {triggers['season']}"
        
        # === Weather Triggers ===
        if 'weather' in triggers:
            if context.weather != triggers['weather']:
                return False, f"Weather not suitable. Need: {triggers['weather']}"
        
        # === Relationship Triggers ===
        if 'relationship' in triggers:
            if relationship.score < triggers['relationship']:
                return False, f"Relationship too low. Need: {triggers['relationship']}"
        
        # === Chemistry Triggers ===
        if 'chemistry' in triggers:
            if relationship.chemistry < triggers['chemistry']:
                return False, f"Chemistry too low. Need: {triggers['chemistry']}"
        
        # === Quest Triggers ===
        if 'questActive' in triggers:
            if not player.has_active_quest(triggers['questActive']):
                return False, f"Quest not active. Need: {triggers['questActive']}"
        
        # === NPC State Triggers ===
        if 'npcPresent' in triggers and triggers['npcPresent']:
            if not npc.is_in_location(context.location):
                return False, "NPC not present in location"
        
        # === Flags Triggers ===
        if 'flagsRequired' in triggers:
            for flag in triggers['flagsRequired']:
                if flag not in relationship.flags:
                    return False, f"Required flag missing: {flag}"
        
        # === Privacy Triggers ===
        if 'privacy' in triggers:
            if triggers['privacy'] == 'required' and context.is_public:
                return False, "Event requires privacy"
        
        # === Random Chance ===
        if 'randomChance' in triggers:
            if random.random() > triggers['randomChance']:
                return False, "Random chance not met"
        
        # All triggers met!
        return True, "All conditions met"
    
    def get_time_category(self, hour):
        """Convert hour to category"""
        if 6 <= hour < 12:
            return 'morning'
        elif 12 <= hour < 17:
            return 'afternoon'
        elif 17 <= hour < 21:
            return 'evening'
        else:
            return 'night'
```

## 8. Context Gathering

### Game Context Collection

```python
def gather_romance_context(player, npc):
    """
    Собрать весь контекст для принятия решений
    """
    
    return {
        # Location
        'location': player.current_location,
        'region': player.current_region,
        'city': player.current_city,
        'is_public': is_public_location(player.current_location),
        
        # Time
        'time': current_game_time(),
        'date': current_game_date(),
        'season': current_season(),
        'weather': current_weather(),
        
        # Special dates
        'is_holiday': check_if_holiday(current_game_date(), npc.culture),
        'is_npc_birthday': is_birthday(current_game_date(), npc.birthday),
        'is_anniversary': is_anniversary(current_game_date(), relationship.first_met_at),
        
        # Quest context
        'active_quests': player.active_quests,
        'quest_with_npc': player.has_quest_with(npc.id),
        
        # Social context
        'other_npcs_present': get_npcs_in_location(player.current_location),
        'friends_present': get_player_friends_in_location(),
        
        # Relationship state
        'relationship': get_relationship(player.id, npc.id),
        'chemistry': get_chemistry(player.id, npc.id),
        'history': get_relationship_history(player.id, npc.id),
        
        # Player state
        'player_mood': player.current_mood,
        'player_stress': player.stress_level,
        'player_intoxication': player.alcohol_level,
        
        # Recent history
        'days_since_interaction': days_since_last_interaction(relationship),
        'recent_events': relationship.get_recent_events(count=5),
        
        # Flags
        'relationship_flags': relationship.flags,
        'global_flags': player.global_flags
    }
```

## 9. Smart Recommendations

### AI-Driven Recommendation System

```python
def get_smart_recommendations(player, npc, relationship, count=3):
    """
    AI-powered умные рекомендации событий
    """
    
    context = gather_romance_context(player, npc)
    
    # === Analyze Relationship State ===
    analysis = analyze_relationship_state(relationship, history)
    
    recommendations = []
    
    # === Strategy 1: Progress Romance ===
    if analysis.ready_for_next_stage:
        # Suggest events that advance relationship
        next_stage_events = get_events_for_next_stage(relationship.stage)
        recommendations.extend(next_stage_events[:2])
    
    # === Strategy 2: Resolve Conflicts ===
    if relationship.conflicts_unresolved > 0:
        # Priority: reconciliation!
        reconciliation_events = get_reconciliation_events(context)
        recommendations.insert(0, reconciliation_events[0])  # Top priority
    
    # === Strategy 3: Add Drama (if too smooth) ===
    if analysis.too_smooth and relationship.score > 50:
        # Inject conflict for narrative interest
        mild_conflict = get_mild_conflict_event(relationship)
        recommendations.append(mild_conflict)
    
    # === Strategy 4: Cultural Experience ===
    if player.location == npc.home_city:
        # In NPC's home city: suggest regional events
        regional_event = get_regional_event(npc.home_region, relationship.score)
        recommendations.append(regional_event)
    
    # === Strategy 5: Milestone Events ===
    if analysis.approaching_milestone:
        # Big moments: first kiss, meeting family, proposal
        milestone_event = get_milestone_event(analysis.next_milestone, relationship)
        recommendations.insert(0, milestone_event)
    
    # === Strategy 6: Variety ===
    # Ensure recommendations are varied (not all same category)
    recommendations = ensure_category_variety(recommendations)
    
    # === Strategy 7: Player Preferences ===
    # Consider what player has enjoyed before
    if player.romance_history.favorite_categories:
        bonus_event = get_event_from_category(
            player.romance_history.favorite_categories[0],
            relationship.score
        )
        recommendations.append(bonus_event)
    
    # Deduplicate and return top N
    recommendations = list(dict.fromkeys(recommendations))[:count]
    
    return recommendations


def analyze_relationship_state(relationship, history):
    """
    Анализ текущего состояния отношений
    """
    
    return {
        'ready_for_next_stage': (
            relationship.score >= get_threshold_for_next_stage(relationship.stage) - 5
        ),
        'too_smooth': (
            relationship.events_since_conflict > 10 and 
            relationship.conflicts_total == 0
        ),
        'approaching_milestone': detect_approaching_milestone(relationship),
        'next_milestone': get_next_expected_milestone(relationship),
        'health_status': classify_relationship_health(relationship.health),
        'breakup_risk': relationship.breakup_risk,
        'momentum': calculate_relationship_momentum(history.last_10_events),
        'stagnation': days_since_progress(history) > 7
    }
```

## 10. Memory System

### Relationship Memory Engine

```python
class RelationshipMemory:
    """Система памяти отношений"""
    
    def remember_event(self, relationship_id, event, choices, outcome):
        """
        Запомнить событие в историю
        """
        
        memory = {
            'event_id': event.id,
            'event_name': event.name,
            'category': event.category,
            'timestamp': current_timestamp(),
            'location': current_location(),
            'choices_made': choices,
            'outcome': outcome,
            'relationship_before': relationship.score,
            'relationship_after': relationship.score + outcome.relationship_change,
            'memorable_dialogue': outcome.dialogue,
            'emotional_impact': classify_emotional_impact(outcome)
        }
        
        # Store in database
        store_event_history(relationship_id, memory)
        
        # Update relationship flags
        if outcome.flags:
            add_flags_to_relationship(relationship_id, outcome.flags)
        
        # Check for milestones
        check_and_record_milestones(relationship_id, event, outcome)
    
    def recall_memory(self, relationship_id, event_type=None, limit=10):
        """
        Вспомнить прошлые события
        """
        
        query = """
            SELECT * FROM relationship_event_history
            WHERE relationship_id = %s
        """
        
        if event_type:
            query += " AND event_id LIKE %s"
            params = (relationship_id, f"{event_type}%")
        else:
            params = (relationship_id,)
        
        query += " ORDER BY triggered_at DESC LIMIT %s"
        params += (limit,)
        
        return execute_query(query, params)
    
    def get_significant_memories(self, relationship_id):
        """
        Получить значимые воспоминания (для диалогов)
        """
        
        # Get milestones
        milestones = get_relationship_milestones(relationship_id)
        
        # Get high-impact events
        high_impact = get_high_impact_events(relationship_id, min_impact=20)
        
        # Get conflicts and resolutions
        conflicts = get_conflict_memories(relationship_id)
        
        return {
            'milestones': milestones,
            'high_impact_moments': high_impact,
            'conflicts': conflicts,
            'first_meeting': get_first_event(relationship_id),
            'most_recent': get_recent_events(relationship_id, count=5)
        }
    
    def reference_past_event_in_dialogue(self, current_event, relationship_id):
        """
        Вставить отсылку к прошлому событию в диалог
        """
        
        significant = self.get_significant_memories(relationship_id)
        
        # NPC может сказать:
        # "Remember when we first met at that bar?" (RE-001)
        # "That first kiss under sakura... I'll never forget" (RE-TOKYO-002)
        # "We've been through so much together" (if many conflicts resolved)
        
        past_ref = select_relevant_past_event(
            current_event.category, 
            significant
        )
        
        if past_ref:
            dialogue_addition = generate_nostalgic_dialogue(past_ref, npc.personality)
            current_event.dialogue.add_reference(dialogue_addition)
        
        return current_event
```

## 11. Полный цикл события

### End-to-End Event Flow

```python
async def execute_romance_event(player_id, npc_id, event_id=None, player_initiated=True):
    """
    Полный цикл выполнения романтического события
    """
    
    # 1. Load data
    player = await get_player(player_id)
    npc = await get_npc(npc_id)
    relationship = await get_relationship(player_id, npc_id)
    context = gather_romance_context(player, npc)
    
    # 2. Select event (if not specified)
    if not event_id:
        recommended = get_smart_recommendations(player, npc, relationship, count=3)
        # Present to player or auto-select based on context
        event = recommended[0]  # or let player choose
    else:
        event = await get_event(event_id)
    
    # 3. Check triggers
    can_trigger, reason = check_event_triggers(event, context)
    if not can_trigger:
        return {"error": reason, "code": "TRIGGER_NOT_MET"}
    
    # 4. Adapt to culture
    adapted_event = adapt_event_to_culture(event, npc.culture, player.cultural_knowledge)
    
    # 5. Add memory references
    adapted_event = reference_past_event_in_dialogue(adapted_event, relationship.id)
    
    # 6. Present event to player
    presentation = {
        'event': adapted_event,
        'npc': npc,
        'context': context,
        'relationship_current': relationship.score,
        'chemistry': relationship.chemistry
    }
    
    # 7. Wait for player choices
    choices = await wait_for_player_choices(presentation)
    
    # 8. Process skill checks (if any)
    if adapted_event.skill_check:
        roll_result = roll_d20()
        total = calculate_skill_check_total(roll_result, player, adapted_event.skill_check)
        success = total >= adapted_event.skill_check.dc
        critical = (roll_result == 20) or (roll_result == 1)
    else:
        success = True
        critical = False
    
    # 9. Determine outcome
    if critical and roll_result == 20:
        outcome = adapted_event.outcomes.critical_success
    elif critical and roll_result == 1:
        outcome = adapted_event.outcomes.critical_failure
    elif success:
        outcome = adapted_event.outcomes.success
    else:
        outcome = adapted_event.outcomes.failure
    
    # 10. Apply outcome
    await apply_event_outcome(relationship.id, outcome)
    
    # 11. Record in memory
    await record_event_history(relationship.id, adapted_event, choices, outcome, roll_result)
    
    # 12. Update relationship scores
    await update_relationship_scores(relationship.id, outcome)
    
    # 13. Check for milestones
    await check_milestones(relationship.id, adapted_event, outcome)
    
    # 14. Check for achievements
    await check_achievements(player_id, relationship.id)
    
    # 15. Suggest next events
    next_suggestions = get_smart_recommendations(player, npc, relationship, count=3)
    await save_next_suggestions(relationship.id, next_suggestions)
    
    # 16. NPC may schedule next interaction
    if outcome.relationship_change > 15:  # Good outcome
        schedule_npc_initiated_event(npc, player, relationship, days=1-3)
    
    return {
        'success': True,
        'outcome': outcome,
        'relationship_new': relationship.score + outcome.relationship_change,
        'next_events': next_suggestions,
        'milestones_achieved': get_new_milestones(relationship.id),
        'achievements_unlocked': get_new_achievements(player_id)
    }
```

---

## Готово к реализации

Полный Event Engine с:
- ✅ Фильтрация событий (hard & soft)
- ✅ Взвешивание по множеству факторов
- ✅ Scoring система
- ✅ Умный выбор событий
- ✅ Культурная адаптация
- ✅ Chemistry калькулятор
- ✅ Trigger system
- ✅ Memory system
- ✅ Полный цикл события

