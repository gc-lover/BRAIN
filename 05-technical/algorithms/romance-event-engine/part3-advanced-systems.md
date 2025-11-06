# Romance Event Engine - Part 3: Advanced Systems

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:08  
**Часть:** 3 из 3

[← Part 2](./part2-scoring-selection.md) | [Навигация](./README.md)

---

## 6. Chemistry Calculator

### Comprehensive Chemistry System

```python
class ChemistryCalculator:
    """Расчёт совместимости между игроком и NPC"""
    
    def calculate_total_chemistry(self, player, npc):
        """Главная функция расчёта chemistry (0-100)"""
        
        # Components
        personality_match = self.calculate_personality_match(player, npc)
        shared_interests = self.calculate_shared_interests(player, npc)
        physical_attraction = self.calculate_physical_attraction(player, npc)
        cultural_compatibility = self.calculate_cultural_compatibility(player, npc)
        
        # Weights
        weights = {'personality': 0.40, 'interests': 0.30, 'attraction': 0.20, 'cultural': 0.10}
        
        # Weighted sum
        total = (
            personality_match * weights['personality'] +
            shared_interests * weights['interests'] +
            physical_attraction * weights['attraction'] +
            cultural_compatibility * weights['cultural']
        )
        
        return int(total)
    
    def calculate_personality_match(self, player, npc):
        """Big Five personality compatibility (0-100)"""
        
        p, n = player.personality, npc.personality
        match_score = 0
        
        # Openness: Similar is good
        match_score += max(0, 100 - abs(p.openness - n.openness))
        
        # Conscientiousness: Similar or complementary
        consc_diff = abs(p.conscientiousness - n.conscientiousness)
        match_score += 100 if consc_diff < 30 else 60
        
        # Extraversion: Complementary often good
        extrav_sum = p.extraversion + n.extraversion
        if 80 <= extrav_sum <= 120:
            match_score += 100  # One intro, one extro
        else:
            match_score += 80
        
        # Agreeableness & Neuroticism
        match_score += (p.agreeableness + n.agreeableness) / 2
        match_score += (100 - (p.neuroticism + n.neuroticism) / 2)
        
        return int(match_score / 6)
    
    def calculate_shared_interests(self, player, npc):
        """Общие интересы (0-100)"""
        
        player_interests = set(player.interests + player.hobbies)
        npc_interests = set(npc.interests + npc.hobbies)
        
        shared = player_interests.intersection(npc_interests)
        total_unique = len(player_interests.union(npc_interests))
        
        if total_unique == 0:
            return 50
        
        shared_percentage = (len(shared) / total_unique) * 100
        
        # Boost for important shared interests
        important_shared = shared.intersection({'music', 'art', 'sports', 'tech', 'cooking'})
        boost = len(important_shared) * 5
        
        return min(100, int(shared_percentage * 2 + boost))
    
    def calculate_physical_attraction(self, player, npc):
        """Физическое влечение (0-100)"""
        
        base_attraction = 50
        
        # Gender preference
        if player.sexual_orientation == 'heterosexual':
            base_attraction += 30 if player.gender != npc.gender else -50
        elif player.sexual_orientation == 'homosexual':
            base_attraction += 30 if player.gender == npc.gender else -50
        else:  # Bi/Pan
            base_attraction += 20
        
        # Age preference
        age_diff = abs(player.age - npc.age)
        if age_diff <= 5:
            base_attraction += 15
        elif age_diff > 20:
            base_attraction -= 20
        
        # Random chemistry factor
        random_chemistry = random.randint(20, 50)
        
        # Charisma influence
        charisma_bonus = (npc.attributes.COOL - 10) * 2
        
        return max(0, min(100, base_attraction + random_chemistry + charisma_bonus))
    
    def calculate_cultural_compatibility(self, player, npc):
        """Культурная совместимость (0-100)"""
        
        compatibility = 50
        
        if player.culture == npc.culture:
            compatibility += 40
        elif player.region == npc.region:
            compatibility += 20
        
        if npc.culture in player.cultural_knowledge:
            compatibility += 30
        
        if npc.primary_language in player.languages:
            compatibility += 25
        
        if player.personality.openness > 70:
            compatibility += 10
        
        if npc.personality.traditionalism > 70 and player.culture != npc.culture:
            compatibility -= 20
        
        return max(0, min(100, compatibility))
```

---

## 7. Trigger System

```python
class EventTriggerEngine:
    """Система триггеров событий"""
    
    def check_triggers(self, event, player, npc, relationship, context):
        """Проверить все триггеры события"""
        
        triggers = event.triggers
        
        # Location, Time, Season, Weather checks
        if 'locations' in triggers and context.location not in triggers['locations']:
            return False, f"Wrong location"
        
        if 'relationship' in triggers and relationship.score < triggers['relationship']:
            return False, f"Relationship too low"
        
        if 'chemistry' in triggers and relationship.chemistry < triggers['chemistry']:
            return False, f"Chemistry too low"
        
        if 'flagsRequired' in triggers:
            for flag in triggers['flagsRequired']:
                if flag not in relationship.flags:
                    return False, f"Required flag missing: {flag}"
        
        if 'randomChance' in triggers and random.random() > triggers['randomChance']:
            return False, "Random chance not met"
        
        return True, "All conditions met"
```

---

## 8. Smart Recommendations

```python
def get_smart_recommendations(player, npc, relationship, count=3):
    """AI-powered умные рекомендации событий"""
    
    context = gather_romance_context(player, npc)
    analysis = analyze_relationship_state(relationship, history)
    
    recommendations = []
    
    # Strategy 1: Progress Romance
    if analysis.ready_for_next_stage:
        next_stage_events = get_events_for_next_stage(relationship.stage)
        recommendations.extend(next_stage_events[:2])
    
    # Strategy 2: Resolve Conflicts
    if relationship.conflicts_unresolved > 0:
        reconciliation_events = get_reconciliation_events(context)
        recommendations.insert(0, reconciliation_events[0])
    
    # Strategy 3: Add Drama (if too smooth)
    if analysis.too_smooth and relationship.score > 50:
        mild_conflict = get_mild_conflict_event(relationship)
        recommendations.append(mild_conflict)
    
    # Strategy 4: Milestone Events
    if analysis.approaching_milestone:
        milestone_event = get_milestone_event(analysis.next_milestone, relationship)
        recommendations.insert(0, milestone_event)
    
    # Variety & Player Preferences
    recommendations = ensure_category_variety(recommendations)
    
    return list(dict.fromkeys(recommendations))[:count]
```

---

## 9. Memory System

```python
class RelationshipMemory:
    """Система памяти отношений"""
    
    def remember_event(self, relationship_id, event, choices, outcome):
        """Запомнить событие в историю"""
        
        memory = {
            'event_id': event.id,
            'category': event.category,
            'timestamp': current_timestamp(),
            'choices_made': choices,
            'outcome': outcome,
            'relationship_change': outcome.relationship_change,
            'emotional_impact': classify_emotional_impact(outcome)
        }
        
        store_event_history(relationship_id, memory)
        
        if outcome.flags:
            add_flags_to_relationship(relationship_id, outcome.flags)
        
        check_and_record_milestones(relationship_id, event, outcome)
    
    def get_significant_memories(self, relationship_id):
        """Получить значимые воспоминания"""
        
        return {
            'milestones': get_relationship_milestones(relationship_id),
            'high_impact_moments': get_high_impact_events(relationship_id, min_impact=20),
            'conflicts': get_conflict_memories(relationship_id),
            'first_meeting': get_first_event(relationship_id)
        }
```

---

## 10. Full Event Cycle

```python
async def execute_romance_event(player_id, npc_id, event_id=None):
    """Полный цикл выполнения романтического события"""
    
    # 1. Load data
    player = await get_player(player_id)
    npc = await get_npc(npc_id)
    relationship = await get_relationship(player_id, npc_id)
    context = gather_romance_context(player, npc)
    
    # 2. Select event
    if not event_id:
        recommended = get_smart_recommendations(player, npc, relationship, count=3)
        event = recommended[0]
    else:
        event = await get_event(event_id)
    
    # 3. Check triggers
    can_trigger, reason = check_event_triggers(event, context)
    if not can_trigger:
        return {"error": reason}
    
    # 4. Adapt to culture
    adapted_event = adapt_event_to_culture(event, npc.culture, player.cultural_knowledge)
    
    # 5. Present & wait for choices
    presentation = {'event': adapted_event, 'npc': npc, 'context': context}
    choices = await wait_for_player_choices(presentation)
    
    # 6. Process skill checks
    if adapted_event.skill_check:
        roll_result = roll_d20()
        total = calculate_skill_check_total(roll_result, player, adapted_event.skill_check)
        success = total >= adapted_event.skill_check.dc
        critical = (roll_result == 20) or (roll_result == 1)
    else:
        success = True
        critical = False
    
    # 7. Determine outcome
    if critical and roll_result == 20:
        outcome = adapted_event.outcomes.critical_success
    elif critical and roll_result == 1:
        outcome = adapted_event.outcomes.critical_failure
    elif success:
        outcome = adapted_event.outcomes.success
    else:
        outcome = adapted_event.outcomes.failure
    
    # 8-14. Apply, record, update, check milestones
    await apply_event_outcome(relationship.id, outcome)
    await record_event_history(relationship.id, adapted_event, choices, outcome, roll_result)
    await update_relationship_scores(relationship.id, outcome)
    await check_milestones(relationship.id, adapted_event, outcome)
    
    # 15. Suggest next events
    next_suggestions = get_smart_recommendations(player, npc, relationship, count=3)
    
    return {
        'success': True,
        'outcome': outcome,
        'next_suggestions': next_suggestions,
        'relationship_new_score': relationship.score + outcome.relationship_change
    }
```

---

## Готово к реализации

✅ **Все компоненты определены**  
✅ **Python псевдокод готов**  
✅ **Интеграция с БД описана**  
✅ **API-ready**

---

[← Назад к навигации](./README.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:08) - Создан из romance-event-engine.md (ПОЛНЫЙ код)

