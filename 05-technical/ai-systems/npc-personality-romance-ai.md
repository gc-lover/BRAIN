---
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06
---

# NPC Romance AI: Personality & Reactions

AI-система для реалистичных личностей NPC и их реакций в романтических ситуациях.


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-164](../../../API-SWAGGER/tasks/active/queue/task-164-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Архитектура NPC Romance AI

```
NPC Personality Profile → Behavior Model → Context Analysis → Response Generation
                               ↓
                    Emotional State Machine
                               ↓
                    Dialogue Generation
                               ↓
                    Action Decision
```

## 1. Personality Model (Big Five + Romance Traits)

### Core Personality Traits (Big Five)

```python
class NPCPersonality:
    """
    Модель личности NPC на основе Big Five + романтические черты
    """
    
    def __init__(self):
        # Big Five (0-100 each)
        self.openness = random.randint(30, 90)
        self.conscientiousness = random.randint(30, 90)
        self.extraversion = random.randint(20, 95)
        self.agreeableness = random.randint(30, 90)
        self.neuroticism = random.randint(20, 80)
        
        # Romance-specific traits (0-100 each)
        self.romanticism = random.randint(40, 95)  # Насколько романтичен
        self.jealousy = random.randint(20, 80)  # Склонность к ревности
        self.commitment_readiness = random.randint(40, 90)  # Готовность к серьёзным отношениям
        self.passionateness = random.randint(30, 95)  # Страстность
        self.traditionalism = random.randint(20, 90)  # Традиционность взглядов
        self.family_oriented = random.randint(30, 95)  # Ориентация на семью
        self.emotional_stability = 100 - self.neuroticism
        self.trust_easily = self.agreeableness
        self.independence = 100 - self.family_oriented
        
    def get_attachment_style(self):
        """
        Стиль привязанности (attachment theory)
        """
        if self.neuroticism < 40 and self.agreeableness > 60:
            return 'secure'  # Здоровая привязанность
        elif self.neuroticism > 60 and self.agreeableness > 60:
            return 'anxious'  # Тревожная привязанность
        elif self.neuroticism < 40 and self.agreeableness < 40:
            return 'avoidant'  # Избегающая привязанность
        else:
            return 'fearful'  # Тревожно-избегающая
    
    def get_love_language(self):
        """
        Язык любви (по Gary Chapman)
        """
        traits = {
            'words_of_affirmation': self.romanticism + self.extraversion,
            'quality_time': self.agreeableness + (100 - self.independence),
            'receiving_gifts': self.traditionalism + self.conscientiousness,
            'acts_of_service': self.conscientiousness + self.agreeableness,
            'physical_touch': self.passionateness + (100 - self.neuroticism)
        }
        
        return max(traits, key=traits.get)
```

### Personality Archetypes (Готовые шаблоны)

```python
PERSONALITY_ARCHETYPES = {
    'romantic_dreamer': {
        'openness': 85, 'romanticism': 95, 'passionateness': 75,
        'description': 'Мечтательный романтик, верит в судьбу',
        'love_language': 'words_of_affirmation',
        'attachment': 'secure'
    },
    'passionate_lover': {
        'passionateness': 95, 'extraversion': 85, 'jealousy': 70,
        'description': 'Страстный любовник, эмоциональный, может ревновать',
        'love_language': 'physical_touch',
        'attachment': 'anxious'
    },
    'reserved_intellectual': {
        'openness': 90, 'extraversion': 30, 'romanticism': 60,
        'description': 'Сдержанный интеллектуал, медленно открывается',
        'love_language': 'quality_time',
        'attachment': 'avoidant'
    },
    'traditional_family_person': {
        'traditionalism': 85, 'family_oriented': 95, 'commitment_readiness': 90,
        'description': 'Традиционные ценности, семья на первом месте',
        'love_language': 'acts_of_service',
        'attachment': 'secure'
    },
    'free_spirit': {
        'openness': 95, 'independence': 90, 'commitment_readiness': 40,
        'description': 'Свободный дух, ценит независимость',
        'love_language': 'quality_time',
        'attachment': 'avoidant'
    },
    'damaged_soul': {
        'neuroticism': 75, 'trust_easily': 30, 'emotional_stability': 40,
        'description': 'Раненая душа, трудно доверяет, нужна забота',
        'love_language': 'acts_of_service',
        'attachment': 'fearful'
    }
}
```

## 2. Emotional State Machine

### Current Emotional State

```python
class EmotionalState:
    """Текущее эмоциональное состояние NPC"""
    
    def __init__(self, npc):
        self.npc = npc
        self.current_mood = 'neutral'  # happy, sad, angry, anxious, excited, in_love
        self.mood_intensity = 50  # 0-100
        self.stress_level = 0  # 0-100
        self.happiness = 50  # 0-100
        self.in_love_meter = 0  # 0-100
        
    def update_after_event(self, event_outcome, relationship_score):
        """Обновить эмоции после события"""
        
        # Positive outcome
        if event_outcome.relationship_change > 15:
            self.happiness += 20
            self.mood = 'happy'
            if relationship_score > 70:
                self.in_love_meter += 15
                self.mood = 'in_love'
        
        # Negative outcome
        elif event_outcome.relationship_change < -10:
            self.happiness -= 20
            self.stress_level += 15
            self.mood = 'sad' if self.npc.personality.neuroticism > 50 else 'angry'
        
        # Conflict
        if event_outcome.conflict_triggered:
            self.stress_level += 25
            self.mood = 'angry' if self.npc.personality.agreeableness < 50 else 'sad'
        
        # Normalize values
        self.happiness = max(0, min(100, self.happiness))
        self.stress_level = max(0, min(100, self.stress_level))
        self.in_love_meter = max(0, min(100, self.in_love_meter))
    
    def get_dialogue_modifier(self):
        """Модификатор диалога на основе настроения"""
        
        if self.mood == 'in_love':
            return {
                'tone': 'affectionate',
                'emoji_use': 'high',
                'text_frequency': 'high',
                'compliments': 'frequent'
            }
        elif self.mood == 'happy':
            return {
                'tone': 'cheerful',
                'emoji_use': 'moderate',
                'responsiveness': 'quick'
            }
        elif self.mood == 'angry':
            return {
                'tone': 'cold',
                'response_delay': 'long',
                'short_answers': True
            }
        elif self.mood == 'sad':
            return {
                'tone': 'melancholic',
                'needs_comfort': True,
                'vulnerability': 'high'
            }
        
        return {'tone': 'neutral'}
```

## 3. Reaction System

### Event Reaction Generator

```python
class NPCReactionSystem:
    """Система реакций NPC на действия игрока"""
    
    def react_to_player_action(self, action, npc, relationship, context):
        """
        Генерировать реакцию NPC на действие игрока
        """
        
        # Analyze action through personality lens
        reaction_base = self.analyze_action(action, npc.personality)
        
        # Modify by current emotional state
        reaction = self.apply_emotional_modifier(reaction_base, npc.emotional_state)
        
        # Modify by relationship history
        reaction = self.apply_history_modifier(reaction, relationship.history)
        
        # Generate dialogue
        dialogue = self.generate_reaction_dialogue(reaction, npc, context)
        
        # Determine relationship change
        relationship_change = self.calculate_relationship_impact(reaction, action)
        
        return {
            'dialogue': dialogue,
            'emotional_reaction': reaction,
            'relationship_change': relationship_change,
            'body_language': self.generate_body_language(reaction),
            'next_action': self.decide_npc_next_action(reaction, npc, relationship)
        }
    
    def analyze_action(self, action, personality):
        """Анализ действия через призму личности"""
        
        reactions = {
            'approval': 0,
            'surprise': 0,
            'happiness': 0,
            'attraction': 0,
            'annoyance': 0,
            'anger': 0,
            'fear': 0
        }
        
        if action.type == 'flirt':
            # Extroverts appreciate direct flirt
            if personality.extraversion > 60:
                reactions['approval'] += 30
                reactions['attraction'] += 20
            else:
                reactions['surprise'] += 20
                reactions['attraction'] += 10
            
            # Romantic NPC loves flirting
            if personality.romanticism > 70:
                reactions['happiness'] += 25
                reactions['attraction'] += 15
            
            # Traditional NPC may be reserved
            if personality.traditionalism > 70:
                reactions['surprise'] += 15
                if action.public:
                    reactions['annoyance'] += 10  # Too forward publicly
        
        elif action.type == 'gift':
            # Everyone likes gifts, but depends on type
            reactions['happiness'] += 20
            reactions['approval'] += 15
            
            if action.gift_thoughtful:
                reactions['attraction'] += 20
                reactions['happiness'] += 10
            
            if action.gift_expensive:
                if personality.traditionalism > 60:
                    reactions['approval'] += 15
                else:
                    reactions['annoyance'] += 5  # "Money can't buy love"
        
        elif action.type == 'help':
            reactions['approval'] += 30
            reactions['happiness'] += 15
            
            if personality.agreeableness > 70:
                reactions['attraction'] += 20  # Values kindness
        
        elif action.type == 'jealousy_trigger':
            # Jealousy depends on personality
            jealousy_intensity = personality.jealousy
            reactions['anger'] += jealousy_intensity * 0.5
            reactions['annoyance'] += jealousy_intensity * 0.7
            
            if personality.attachment_style == 'anxious':
                reactions['fear'] += 30  # Fear of losing you
        
        return reactions
    
    def generate_reaction_dialogue(self, reaction, npc, context):
        """
        Генерировать диалог на основе реакции
        """
        
        # Dominant emotion
        dominant = max(reaction, key=reaction.get)
        intensity = reaction[dominant]
        
        # Personality influences expression
        if npc.personality.extraversion > 60:
            expressiveness = 'high'
        else:
            expressiveness = 'low'
        
        # Culture influences expression
        cultural_style = get_cultural_expression_style(npc.culture)
        
        # Generate dialogue
        if dominant == 'happiness' and intensity > 50:
            if expressiveness == 'high':
                if cultural_style == 'passionate':
                    return "¡Mi amor! ¡Eres increíble!"  # Spanish example
                elif cultural_style == 'reserved':
                    return "これは嬉しいです" # Japanese example
                else:
                    return "I'm so happy! This is wonderful!"
            else:
                return "That's... really nice. Thank you."
        
        elif dominant == 'anger' and intensity > 50:
            if npc.personality.agreeableness < 40:
                return "I can't believe you! How could you?!"
            else:
                return "I'm... I'm really hurt by this."
        
        elif dominant == 'attraction' and intensity > 60:
            if npc.personality.romanticism > 70:
                return "You make my heart race..."
            else:
                return "I... I like spending time with you."
        
        # Template-based generation with personality + culture
        template = select_dialogue_template(dominant, intensity, npc, context)
        dialogue = fill_template(template, npc, context)
        
        return dialogue
```

## 4. NPC Initiative & Behavior

### Proactive NPC Behavior

```python
class NPCInitiative:
    """NPC инициативное поведение"""
    
    def should_npc_initiate_contact(self, npc, relationship, days_since_last):
        """
        Должен ли NPC инициировать контакт?
        """
        
        # Base chance
        base_chance = 0.10
        
        # Personality factors
        if npc.personality.extraversion > 70:
            base_chance += 0.20  # Extroverts reach out more
        
        if npc.personality.romanticism > 80:
            base_chance += 0.15  # Romantics initiate more
        
        # Relationship factors
        if relationship.score > 70:
            base_chance += 0.25  # In love = more contact
        
        if relationship.score < 30:
            base_chance -= 0.05  # Not close yet
        
        # Time since last interaction
        if days_since_last > 7:
            base_chance += 0.30  # Miss you!
        elif days_since_last > 3:
            base_chance += 0.15
        elif days_since_last < 1:
            base_chance -= 0.10  # Don't be clingy
        
        # Emotional state
        if npc.emotional_state.in_love_meter > 80:
            base_chance += 0.20  # Can't stop thinking about you
        
        # Unresolved conflict
        if relationship.conflicts_unresolved > 0:
            if npc.personality.agreeableness > 60:
                base_chance += 0.25  # Want to fix it
            else:
                base_chance -= 0.15  # Stubborn, wait for you to apologize
        
        return random.random() < base_chance
    
    def generate_npc_message(self, npc, relationship, context):
        """
        Генерировать сообщение от NPC
        """
        
        # Determine message type
        message_type = self.select_message_type(npc, relationship)
        
        templates = {
            'casual_check_in': [
                "Hey! How's your day going?",
                "Thinking about you. What are you up to?",
                "Miss you. Want to hang out?"
            ],
            'romantic': [
                "Can't stop thinking about you...",
                "You're on my mind ❤️",
                "I had a dream about you last night"
            ],
            'date_invitation': [
                "Want to grab dinner tonight?",
                "I found this cool place, want to check it out together?",
                "Free this weekend? Let's do something fun"
            ],
            'conflict_resolution': [
                "Can we talk? I don't like how we left things",
                "I'm sorry about earlier. Can we meet?",
                "I miss you. Please, let's work this out"
            ],
            'playful': [
                "Guess what I'm doing? 😏",
                "I'm bored. Entertain me?",
                "Random thought: you're cute"
            ]
        }
        
        # Select template based on type
        template = random.choice(templates[message_type])
        
        # Personalize based on personality
        if npc.personality.extraversion > 70:
            template += " 😊"  # Extroverts use more emojis
        
        if npc.culture == 'japanese' and npc.personality.traditionalism > 60:
            # Japanese more formal
            template = make_more_formal(template)
        
        return template
    
    def decide_npc_next_action(self, npc, relationship, player_location):
        """
        NPC решает что делать дальше
        """
        
        # If relationship is high and same location: approach player
        if relationship.score > 60 and npc.location == player_location:
            if random.random() < 0.40:
                return {
                    'action': 'approach_player',
                    'message': "Hey! Fancy meeting you here!",
                    'trigger_event': True
                }
        
        # If in love and haven't seen player in days: call
        if relationship.score > 80 and days_since_interaction(relationship) > 3:
            return {
                'action': 'phone_call',
                'message': "I miss you... Can we meet?",
                'urgency': 'high'
            }
        
        # If conflict unresolved: reach out (if agreeable)
        if relationship.conflicts_unresolved > 0 and npc.personality.agreeableness > 60:
            return {
                'action': 'text_message',
                'message': "Can we talk?",
                'trigger_reconciliation': True
            }
        
        # Default: no action
        return {'action': 'none'}
```

## 5. Reaction to Specific Scenarios

### Jealousy Reaction

```python
def react_to_jealousy(npc, relationship, situation):
    """
    Реакция NPC на ревность
    """
    
    jealousy_level = npc.personality.jealousy
    
    # Situation severity
    severity = {
        'flirt_with_other': 50,
        'kiss_other': 90,
        'seen_with_ex': 70,
        'late_home': 30,
        'secretive_phone': 40
    }[situation.type]
    
    # Calculate reaction intensity
    intensity = (jealousy_level + severity) / 2
    
    # Attachment style affects reaction
    if npc.attachment_style == 'anxious':
        intensity += 20  # Anxious attachment = more jealous
    elif npc.attachment_style == 'secure':
        intensity -= 20  # Secure = less jealous
    
    # Generate reaction
    if intensity > 80:
        # Rage jealousy
        return {
            'reaction': 'rage',
            'dialogue': "How DARE you! Who is that?!",
            'action': 'storm_off',
            'relationship_change': -35,
            'trust_change': -40,
            'trigger_conflict': True
        }
    elif intensity > 50:
        # Serious jealousy
        return {
            'reaction': 'serious_jealous',
            'dialogue': "I saw you with them. What's going on?",
            'action': 'demand_explanation',
            'relationship_change': -15,
            'trust_change': -20
        }
    elif intensity > 30:
        # Mild jealousy
        return {
            'reaction': 'mild_jealous',
            'dialogue': "Who was that?",
            'action': 'ask_casually',
            'relationship_change': -5,
            'trust_change': -5
        }
    else:
        # Secure, no jealousy
        return {
            'reaction': 'secure',
            'dialogue': "Hey, who's your friend?",
            'action': 'introduce_self',
            'relationship_change': 0
        }
```

### Confession Reaction

```python
def react_to_love_confession(npc, relationship, context):
    """
    Реакция на признание в любви
    """
    
    # Check if NPC ready
    npc_in_love = npc.emotional_state.in_love_meter > 70
    relationship_ready = relationship.score > 80
    chemistry_high = relationship.chemistry > 70
    
    # Calculate readiness score
    readiness = (
        (npc_in_love * 0.4) +
        (relationship_ready * 0.4) +
        (chemistry_high * 0.2)
    ) * 100
    
    # Personality modifiers
    if npc.personality.romanticism > 80:
        readiness += 15  # Romantics ready sooner
    
    if npc.personality.commitment_readiness < 50:
        readiness -= 20  # Commitment-phobes need longer
    
    # Past trauma
    if 'past_heartbreak' in npc.flags:
        readiness -= 15  # Harder to trust
    
    # Generate reaction
    if readiness > 85:
        # Ready to say it back!
        return {
            'response': 'reciprocate',
            'dialogue': generate_love_confession(npc.culture, npc.personality),
            'relationship_change': +50,
            'emotional_state': 'in_love',
            'milestone': 'mutual_love_confession'
        }
    elif readiness > 60:
        # Almost ready, needs a bit more time
        return {
            'response': 'almost_ready',
            'dialogue': "I... I care about you deeply. I think I'm falling for you too.",
            'relationship_change': +25,
            'emotional_state': 'conflicted',
            'milestone': 'almost_love'
        }
    elif readiness > 40:
        # Not ready yet
        return {
            'response': 'not_ready',
            'dialogue': "I... I need time. This is moving fast.",
            'relationship_change': +10,
            'emotional_state': 'anxious',
            'pressure': +20
        }
    else:
        # Too soon!
        return {
            'response': 'too_soon',
            'dialogue': "I... I don't know what to say. I'm sorry.",
            'relationship_change': -5,
            'emotional_state': 'uncomfortable',
            'risk_of_pulling_away': True
        }
```

### Proposal Reaction

```python
def react_to_marriage_proposal(npc, relationship, proposal_context):
    """
    Реакция на предложение руки и сердца
    """
    
    # Factors for acceptance
    factors = {
        'relationship_score': relationship.score,
        'in_love': npc.emotional_state.in_love_meter,
        'commitment_ready': npc.personality.commitment_readiness,
        'time_together': relationship.days_together,
        'family_approval': relationship.family_approval_score,
        'life_stage_ready': npc.age > 25 and npc.career_stable
    }
    
    # Calculate acceptance probability
    acceptance_score = (
        factors['relationship_score'] * 0.30 +
        factors['in_love'] * 0.25 +
        factors['commitment_ready'] * 0.20 +
        min(100, factors['time_together'] / 365 * 100) * 0.10 +
        factors['family_approval'] * 0.10 +
        (100 if factors['life_stage_ready'] else 30) * 0.05
    )
    
    # Proposal quality modifier
    if proposal_context.location in npc.dream_locations:
        acceptance_score += 15
    
    if proposal_context.ring_quality == 'perfect':
        acceptance_score += 10
    
    if proposal_context.romantic_speech:
        acceptance_score += 10
    
    # Cultural expectations
    cultural_context = get_cultural_context(npc.culture)
    if cultural_context.family_approval_required and not relationship.family_approved:
        acceptance_score -= 40  # Critical in some cultures!
    
    # Generate response
    if acceptance_score > 85:
        # YES!
        return {
            'response': 'enthusiastic_yes',
            'dialogue': generate_proposal_acceptance(npc.culture, 'enthusiastic'),
            'relationship_change': +100,
            'milestone': 'engaged',
            'next_phase': 'wedding_planning'
        }
    elif acceptance_score > 70:
        # Yes, but nervous
        return {
            'response': 'nervous_yes',
            'dialogue': "Yes! I... I'm scared but yes!",
            'relationship_change': +80,
            'milestone': 'engaged',
            'emotional_state': 'excited_anxious'
        }
    elif acceptance_score > 50:
        # Need to think
        return {
            'response': 'need_time',
            'dialogue': "This is... wow. Can I think about it?",
            'relationship_change': +15,
            'will_answer_in_days': 7,
            'acceptance_probability': 0.75
        }
    else:
        # Not ready / No
        return {
            'response': 'not_ready',
            'dialogue': "I... I'm not ready for this. I'm sorry.",
            'relationship_change': -10,
            'risk_of_breakup': 0.30,
            'can_propose_again_in_days': 180
        }
```

## 6. Dialogue Generation

### Dynamic Dialogue System

```python
class RomanceDialogueGenerator:
    """Генератор диалогов для романтических событий"""
    
    def generate_contextual_dialogue(self, npc, situation, relationship, history):
        """
        Генерировать контекстный диалог
        """
        
        # Base dialogue template
        template = self.select_template(situation.type, npc.personality)
        
        # Fill with context
        dialogue = self.fill_template(template, {
            'npc_name': npc.name,
            'player_name': player.name,
            'relationship_stage': relationship.stage,
            'location': situation.location,
            'time': situation.time
        })
        
        # Add personality flavor
        dialogue = self.add_personality_flavor(dialogue, npc.personality)
        
        # Add cultural elements
        dialogue = self.add_cultural_elements(dialogue, npc.culture)
        
        # Add emotional state
        dialogue = self.add_emotional_tone(dialogue, npc.emotional_state)
        
        # Reference past events (nostalgia)
        if random.random() < 0.30:  # 30% chance
            past_reference = self.select_memorable_past_event(history)
            dialogue += f"\n\n{self.generate_nostalgia_line(past_reference)}"
        
        return dialogue
    
    def add_personality_flavor(self, dialogue, personality):
        """Добавить personality-based речь"""
        
        # Extroverts: more exclamation marks, emojis
        if personality.extraversion > 70:
            dialogue = dialogue.replace('.', '!')
            if random.random() < 0.50:
                dialogue += " 😊"
        
        # Neurotics: more uncertain language
        if personality.neuroticism > 60:
            dialogue = dialogue.replace("I will", "I think I will")
            dialogue = dialogue.replace("I want", "I think I want")
        
        # Agreeable: softer language
        if personality.agreeableness > 70:
            dialogue = dialogue.replace("No", "I don't think so")
            dialogue = dialogue.replace("You're wrong", "I see it differently")
        
        # Conscientious: more formal
        if personality.conscientiousness > 70:
            dialogue = make_more_formal(dialogue)
        
        return dialogue
    
    def add_cultural_elements(self, dialogue, culture):
        """Добавить культурные элементы"""
        
        cultural_phrases = {
            'japanese': {
                'greeting': 'こんにちは',
                'thanks': 'ありがとう',
                'sorry': 'ごめんなさい',
                'endearment': 'あなた'
            },
            'french': {
                'greeting': 'Bonjour, mon amour',
                'endearment': 'mon chéri / ma chérie',
                'romantic': 'Je t\'aime'
            },
            'spanish': {
                'greeting': 'Hola, mi amor',
                'endearment': 'cariño / mi vida',
                'romantic': 'Te amo'
            },
            'russian': {
                'greeting': 'Привет, любимая/любимый',
                'endearment': 'дорогая/дорогой',
                'romantic': 'Я люблю тебя'
            }
        }
        
        # Insert cultural phrase (10% chance for flavor)
        if culture in cultural_phrases and random.random() < 0.10:
            phrase_type = random.choice(list(cultural_phrases[culture].keys()))
            phrase = cultural_phrases[culture][phrase_type]
            dialogue = f"{phrase}! {dialogue}"
        
        return dialogue
```

## 7. Learning System

### NPC Learns Player Preferences

```python
class NPCLearningSystem:
    """NPC учится предпочтениям игрока"""
    
    def learn_from_interaction(self, npc, event, player_choices, outcome):
        """
        NPC запоминает что игрок любит/не любит
        """
        
        # Update preference model
        if outcome.relationship_change > 15:
            # Player liked this!
            npc.learned_preferences['liked_events'].append(event.category)
            npc.learned_preferences['liked_activities'].append(event.activity_type)
            
            if event.region:
                npc.learned_preferences['liked_regions'].append(event.region)
        
        elif outcome.relationship_change < -5:
            # Player didn't like this
            npc.learned_preferences['disliked_events'].append(event.category)
        
        # Learn communication style
        if player_choices.communication_style:
            npc.learned_preferences['player_communication_style'] = player_choices.communication_style
        
        # Learn gift preferences
        if event.category == 'gift' and outcome.positive:
            npc.learned_preferences['gift_types_liked'].append(event.gift_type)
        
        # Future events will use this knowledge
        save_npc_learned_preferences(npc.id, npc.learned_preferences)
    
    def suggest_event_based_on_learning(self, npc, relationship):
        """
        NPC предлагает событие основываясь на изученных предпочтениях
        """
        
        preferences = npc.learned_preferences
        
        # Select event from liked categories
        if preferences['liked_events']:
            favorite_category = most_common(preferences['liked_events'])
            event = select_random_event(category=favorite_category, relationship_score=relationship.score)
            return event
        
        # Or from liked regions
        if preferences['liked_regions']:
            favorite_region = most_common(preferences['liked_regions'])
            event = select_regional_event(region=favorite_region, relationship_score=relationship.score)
            return event
        
        # Default
        return None
```

## 8. Adaptive Difficulty

### Dynamic DC Adjustment

```python
def calculate_adaptive_dc(base_dc, player, npc, relationship, event):
    """
    Динамически адаптировать DC на основе множества факторов
    """
    
    dc = base_dc
    
    # === Player Skill ===
    player_skill_level = get_player_skill_level(event.skill_check.skill)
    if player_skill_level > 15:
        dc -= 2  # Experienced player
    elif player_skill_level < 5:
        dc += 2  # Novice
    
    # === Relationship Bonus ===
    # Easier as relationship grows
    dc -= int(relationship.score / 10)
    
    # === Chemistry Bonus ===
    if relationship.chemistry > 80:
        dc -= 3
    elif relationship.chemistry > 60:
        dc -= 2
    
    # === Trust Bonus ===
    if relationship.trust > 80:
        dc -= 2
    
    # === Cultural Knowledge ===
    if event.region and player.knows_culture(event.culture):
        dc -= cultural_knowledge_bonus(player, event.culture)
    else:
        dc += 2  # Unfamiliar culture harder
    
    # === Emotional State ===
    if npc.emotional_state.mood == 'happy':
        dc -= 2  # Easier when NPC happy
    elif npc.emotional_state.mood == 'angry':
        dc += 4  # Harder when NPC angry
    
    # === Timing ===
    if is_perfect_timing(event, context):
        dc -= 3  # Right moment
    elif is_poor_timing(event, context):
        dc += 4  # Wrong moment
    
    # === Recent Conflict ===
    if relationship.conflicts_unresolved > 0:
        dc += relationship.conflicts_unresolved * 2
    
    # === NPC Personality ===
    if event.type == 'flirt' and npc.personality.romanticism > 80:
        dc -= 2  # Romantic NPC easier to flirt with
    
    # Bounds
    return max(8, min(35, dc))
```

## 9. Emergent Behavior

### NPC Autonomous Actions

```python
def npc_autonomous_behavior(npc, relationship, world_state):
    """
    NPC действуют автономно (не только реагируют)
    """
    
    behaviors = []
    
    # Check if NPC initiates today
    if should_npc_initiate_contact(npc, relationship):
        behaviors.append(generate_npc_contact(npc, relationship))
    
    # Check if NPC gets jealous (if player dating others)
    if player_dating_others(player.id) and npc.personality.jealousy > 60:
        if random.random() < (npc.personality.jealousy / 100):
            behaviors.append({
                'type': 'jealousy_confrontation',
                'trigger_event': 'RE-136'
            })
    
    # NPC may plan surprise (if romantic)
    if npc.personality.romanticism > 80 and relationship.score > 70:
        if random.random() < 0.05:  # 5% daily
            behaviors.append(plan_surprise_for_player(npc, relationship))
    
    # NPC may introduce player to friends/family
    if relationship.score > 65 and 'met_friends' not in relationship.flags:
        if npc.personality.extraversion > 60:
            behaviors.append({
                'type': 'introduce_to_friends',
                'trigger_event': 'RE-119'
            })
    
    # NPC may pull away if overwhelmed
    if relationship.progress_too_fast(npc.comfort_zone):
        behaviors.append({
            'type': 'need_space',
            'message': "Hey, can we slow down a bit? This is moving fast..."
        })
    
    return behaviors
```

---

## Готово к реализации

AI система включает:
- ✅ Big Five + Romance personality model
- ✅ Emotional state machine
- ✅ Reaction system для всех сценариев
- ✅ NPC initiative behavior
- ✅ Dialogue generation
- ✅ Learning system
- ✅ Adaptive difficulty
- ✅ Autonomous NPC behavior

NPC теперь — живые персонажи с реалистичными эмоциями и реакциями!

