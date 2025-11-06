---
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06
---

# Romance System: Техническая документация

Полная техническая спецификация системы романтических событий (1550+ событий).

## 📊 Обзор системы

### Компоненты

1. **[API Specification](./api-structures/romance-events-api-spec.yaml)** — OpenAPI 3.0 спецификация
2. **[Database Schema](./database/romance-database-schema.sql)** — PostgreSQL схема
3. **[Event Engine](./algorithms/romance-event-engine.md)** — Алгоритм выбора событий
4. **[AI Personality System](./ai-systems/npc-personality-romance-ai.md)** — NPC личности и реакции

### Архитектура

```
┌─────────────┐
│   Player    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│   Romance Event Engine          │
│  ┌─────────────────────────┐   │
│  │ Event Selection AI      │   │
│  │ - Filter (1550→50)      │   │
│  │ - Weight (0-100)        │   │
│  │ - Score (final)         │   │
│  │ - Select (top 3)        │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Chemistry Calculator    │   │
│  │ - Personality (40%)     │   │
│  │ - Interests (30%)       │   │
│  │ - Attraction (20%)      │   │
│  │ - Cultural (10%)        │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Cultural Adapter        │   │
│  │ - DC modification       │   │
│  │ - Dialogue translation  │   │
│  │ - PDA rules            │   │
│  │ - Family importance     │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Trigger System          │   │
│  │ - Location checks       │   │
│  │ - Time checks          │   │
│  │ - Relationship checks   │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│   NPC Romance AI                │
│  ┌─────────────────────────┐   │
│  │ Personality Model       │   │
│  │ - Big Five traits       │   │
│  │ - Romance traits        │   │
│  │ - Attachment style      │   │
│  │ - Love language         │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Emotional State         │   │
│  │ - Current mood          │   │
│  │ - In love meter         │   │
│  │ - Stress level          │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Reaction System         │   │
│  │ - Jealousy              │   │
│  │ - Confession response   │   │
│  │ - Conflict handling     │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ Dialogue Generator      │   │
│  │ - Context-aware         │   │
│  │ - Personality-based     │   │
│  │ - Culture-adapted       │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│   PostgreSQL Database           │
│  - romance_events (1550)        │
│  - npc_romance_profiles         │
│  - relationships                │
│  - relationship_event_history   │
│  - relationship_conflicts       │
│  - chemistry_scores             │
│  - cultural_contexts            │
└─────────────────────────────────┘
```

---

## 🔧 Технические спецификации

### API Endpoints (14 endpoints)

1. `GET /romance/events` — Получить события
2. `GET /romance/events/{eventId}` — Детали события
3. `POST /romance/trigger` — Триггер события
4. `POST /romance/choice` — Выбор в событии
5. `GET /romance/relationship/{npcId}` — Статус отношений
6. `POST /romance/chemistry/calculate` — Расчёт chemistry
7. `POST /romance/generate-arc` — Генерация арки
8. `GET /romance/history/{npcId}` — История отношений
9. `GET /romance/npcs/available` — Доступные NPC
10. `POST /romance/cultural/adapt` — Культурная адаптация
11. `GET /romance/recommendations` — Умные рекомендации
12. `POST /romance/npc/initiate` — NPC инициирует
13. `GET /romance/achievements` — Достижения
14. `POST /romance/notification/send` — Отправить уведомление

### Database Tables (11 таблиц)

1. **romance_events** — 1,550+ событий
2. **npc_romance_profiles** — Профили NPC
3. **relationships** — Активные отношения
4. **relationship_event_history** — История событий
5. **relationship_conflicts** — Конфликты
6. **relationship_milestones** — Важные моменты
7. **chemistry_scores** — Совместимость
8. **cultural_contexts** — Культурные контексты (16 культур)
9. **event_triggers_log** — Лог триггеров
10. **player_romance_preferences** — Предпочтения игрока
11. **romance_notifications** — Уведомления

### Indexes (25+)

Оптимизация для быстрых запросов:
- Relationship lookups (player_id, npc_id)
- Event filtering (category, region, relationship_range)
- History queries (timestamp-based)
- Chemistry calculations

---

## ⚡ Performance

### Expected Load
- **Players:** 100,000+
- **NPCs:** 10,000+ (romanceable)
- **Active romances:** 50,000+
- **Events/day:** 200,000+
- **Database size:** ~500GB (with history)

### Optimization Strategies

1. **Caching**
   - Cache frequently accessed events (Redis)
   - Cache chemistry scores (recalculate weekly)
   - Cache cultural contexts (static data)

2. **Indexing**
   - Composite indexes for common queries
   - JSONB indexes for triggers
   - Partial indexes for active romances

3. **Partitioning**
   - Partition event_history by date (monthly)
   - Partition notifications by status (read/unread)

4. **Lazy Loading**
   - Load only top 3 recommended events
   - Load full event details on demand
   - Paginate history (load last 20, rest on scroll)

---

## 🎮 Implementation Plan

### Phase 1: Core System (Sprint 1-2)
- ✅ Database schema
- ✅ Basic API endpoints
- ✅ Event filtering logic
- ✅ Relationship tracking

### Phase 2: AI & Selection (Sprint 3-4)
- ✅ Chemistry calculator
- ✅ Event weighting algorithm
- ✅ Smart recommendations
- ✅ NPC personality model

### Phase 3: Cultural System (Sprint 5-6)
- ✅ Cultural contexts
- ✅ Cultural adapter
- ✅ Regional event loading
- ✅ Language integration

### Phase 4: Advanced Features (Sprint 7-8)
- ✅ Memory system
- ✅ Conflict & reconciliation
- ✅ NPC initiative
- ✅ Learning system

### Phase 5: Polish (Sprint 9-10)
- Dialogue generation
- Trigger optimization
- Performance tuning
- Testing & balancing

---

## 🧪 Testing Strategy

### Unit Tests
- Chemistry calculation accuracy
- Event filtering correctness
- Trigger system reliability
- Cultural adapter appropriateness

### Integration Tests
- Full event flow (trigger → choice → outcome)
- Relationship progression (0 → 100)
- Multi-NPC romances (polyamory testing)
- Conflict resolution paths

### Cultural Testing
- Each culture tested by native speakers
- Cultural sensitivity review
- Language accuracy check
- Tradition authenticity

### Load Testing
- 10,000 concurrent users
- 50,000 events/minute
- Database query performance
- API response times < 200ms

---

## 📐 Data Models (JSON Examples)

### Romance Event (minimal)

```json
{
  "eventId": "RE-TOKYO-002",
  "category": "dating",
  "name": "Hanami (Цветение сакуры)",
  "relationshipRange": [60, 80],
  "region": "asia",
  "city": "tokyo",
  "triggers": {
    "locations": ["ueno_park", "sumida_park"],
    "season": "spring",
    "time": ["afternoon", "evening"]
  },
  "skillCheck": {
    "type": "Romantic",
    "dc": 14
  },
  "outcomes": {
    "success": {
      "relationship": 22,
      "flags": ["hanami_together"],
      "nextEvents": ["RE-TOKYO-007", "RE-441"]
    }
  }
}
```

### Relationship Status (minimal)

```json
{
  "playerId": "player-123",
  "npcId": "hanako-tanaka",
  "relationshipScore": 75,
  "relationshipStage": "dating",
  "chemistry": 82,
  "trust": 88,
  "physicalIntimacy": 60,
  "emotionalIntimacy": 90,
  "completedEvents": ["RE-001", "RE-TOKYO-002", "RE-441"],
  "flags": ["first_kiss_done", "hanami_together"],
  "conflictsUnresolved": 0,
  "relationshipHealth": 95,
  "breakupRisk": 0.05
}
```

### NPC Profile (minimal)

```json
{
  "npcId": "hanako-tanaka",
  "name": "Hanako \"Ghost\" Tanaka",
  "culture": "japanese",
  "region": "asia",
  "city": "tokyo",
  "personality": {
    "openness": 85,
    "extraversion": 40,
    "romanticism": 70,
    "jealousy": 45,
    "commitment": 85
  },
  "sexualOrientation": "bisexual",
  "loveLanguage": "quality_time",
  "attachmentStyle": "secure"
}
```

---

## 🚀 Deployment

### Infrastructure Requirements

**Backend:**
- Java Spring Boot 3.x
- PostgreSQL 15+
- Redis (caching)
- RabbitMQ (notifications)

**Frontend:**
- React/Vue для Romance UI
- WebSocket для real-time updates
- Notification system

**AI/ML:**
- Python microservice для AI recommendations
- TensorFlow/PyTorch для learning
- NLP для dialogue generation

### Environment Variables

```env
# Database
ROMANCE_DB_HOST=localhost
ROMANCE_DB_PORT=5432
ROMANCE_DB_NAME=necpgame_romance
ROMANCE_DB_USER=romance_service
ROMANCE_DB_PASSWORD=***

# Redis
ROMANCE_REDIS_HOST=localhost
ROMANCE_REDIS_PORT=6379

# AI Service
ROMANCE_AI_SERVICE_URL=http://localhost:8001
ROMANCE_AI_MODEL_PATH=/models/romance-ai

# Features
ROMANCE_POLYAMORY_ENABLED=false
ROMANCE_NPC_INITIATIVE_ENABLED=true
ROMANCE_CULTURAL_ADAPTATION=true
ROMANCE_AI_RECOMMENDATIONS=true

# Limits
ROMANCE_MAX_CONCURRENT_ROMANCES=3
ROMANCE_EVENT_CACHE_TTL=3600
ROMANCE_CHEMISTRY_RECALC_DAYS=7
```

---

## 📚 Integration Points

### With Main Game Systems

**Quest System:**
- Romance events can trigger during quests
- Joint quests with romantic interest
- Faction conflicts affect romances

**Reputation System:**
- NPC faction reputation affects romance
- Romance with faction leader = bonuses
- Betrayal = romance consequences

**World Events:**
- Global events affect romance availability
- Wars separate lovers
- Festivals create romantic opportunities

**Character Progression:**
- Relationship milestones give XP
- Companion perks from partners
- Skills improve through romance events

---

## 🎯 Success Metrics

### KPIs to Track

- **Engagement Rate:** % players who start romance
- **Completion Rate:** % romances that reach commitment
- **Breakup Rate:** % romances that fail
- **Cultural Diversity:** Romances across all regions
- **Replay Value:** Repeat romances with different NPCs
- **Player Satisfaction:** NPS for romance system

### Goals
- 80%+ players engage with romance system
- 40%+ romances reach commitment (marriage)
- 60%+ breakup rate realistic (not too high/low)
- 20%+ players romance in multiple regions
- 50%+ players replay with different NPCs

---

## 🔒 Privacy & Ethics

### Content Guidelines

**Age Ratings:**
- Mature (17+) content
- No explicit sexual content (fade to black)
- Emotional intimacy focus
- Respectful representations

**Cultural Sensitivity:**
- Native speakers review cultural events
- Avoid stereotypes
- Respect religious traditions
- Acknowledge cultural diversity

**Consent:**
- Player can decline any event
- NPC can say no
- No forced romance
- Breakup always possible

**Inclusivity:**
- LGBTQ+ romances fully supported
- Non-binary NPCs available
- Asexual romance options
- Polyamory optional

---

## 📖 Documentation for Developers

### Quick Start Guide

```bash
# 1. Setup database
psql -U postgres -d necpgame < romance-database-schema.sql

# 2. Import events data
npm run import-romance-events

# 3. Start romance service
cd services/romance
npm install
npm run dev

# 4. Test API
curl http://localhost:8080/api/v1/romance/events?relationship=50

# 5. Generate sample romance
curl -X POST http://localhost:8080/api/v1/romance/generate-arc \
  -H "Content-Type: application/json" \
  -d '{"playerId": "player-123", "npcId": "hanako-tanaka"}'
```

### Code Examples

**Trigger Event:**
```javascript
// Frontend
const triggerRomanceEvent = async (eventId, npcId) => {
  const response = await fetch('/api/v1/romance/trigger', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      playerId: currentPlayer.id,
      npcId: npcId,
      eventId: eventId,
      location: currentLocation,
      context: gatherContext()
    })
  });
  
  const result = await response.json();
  
  if (result.success) {
    displayEvent(result.event);
    updateRelationshipUI(result.relationship_new);
  }
};
```

**Backend (Java Spring Boot):**
```java
@PostMapping("/romance/trigger")
public ResponseEntity<EventOutcome> triggerEvent(@RequestBody TriggerRequest request) {
    // Validate
    validateTriggerRequest(request);
    
    // Load data
    Player player = playerService.findById(request.getPlayerId());
    NPC npc = npcService.findById(request.getNpcId());
    RomanceEvent event = eventService.findById(request.getEventId());
    Relationship relationship = relationshipService.findByPlayerAndNpc(player.getId(), npc.getId());
    
    // Check triggers
    boolean canTrigger = triggerSystem.checkTriggers(event, player, npc, relationship, request.getContext());
    if (!canTrigger) {
        throw new EventNotAvailableException("Trigger conditions not met");
    }
    
    // Adapt to culture
    RomanceEvent adaptedEvent = culturalAdapter.adapt(event, npc.getCulture(), player.getCulturalKnowledge());
    
    // Execute event
    EventOutcome outcome = eventEngine.executeEvent(adaptedEvent, player, npc, relationship);
    
    // Update relationship
    relationshipService.updateScores(relationship.getId(), outcome);
    
    // Record history
    memorySystem.recordEvent(relationship.getId(), event, outcome);
    
    // Get recommendations
    List<RomanceEvent> nextEvents = eventEngine.getSmartRecommendations(player, npc, relationship, 3);
    outcome.setNextEventSuggestions(nextEvents);
    
    return ResponseEntity.ok(outcome);
}
```

---

## 🎨 UI/UX Guidelines

### Romance Dashboard

```
┌─────────────────────────────────────┐
│  ❤️ Active Romances                 │
├─────────────────────────────────────┤
│  Hanako "Ghost" Tanaka              │
│  ━━━━━━━━━━━━━━━━━━ 75%            │
│  💕 Dating • 🎭 High Chemistry       │
│  Last interaction: 2 days ago       │
│  [View] [Message] [Plan Date]      │
├─────────────────────────────────────┤
│  Sofia Morales                      │
│  ━━━━━━━━━ 45%                      │
│  👥 Close Friend • ⚡ Moderate       │
│  Last interaction: 5 days ago       │
│  [View] [Message]                   │
└─────────────────────────────────────┘

Available Events:
┌─────────────────────────────────────┐
│ 🌸 Hanami (Цветение сакуры)         │
│ Special Tokyo event • Spring only   │
│ Recommended! High romance potential │
│ DC: 14 (Romantic)                   │
│ [Start Event]                       │
├─────────────────────────────────────┤
│ 🌙 Moonlight Walk                   │
│ Classic romantic date               │
│ DC: 12 (Romantic)                   │
│ [Start Event]                       │
└─────────────────────────────────────┘
```

### In-Event UI

```
┌─────────────────────────────────────┐
│  Event: Hanami (Цветение сакуры)    │
│  Location: Ueno Park, Tokyo         │
│  With: Hanako Tanaka ❤️ 75          │
├─────────────────────────────────────┤
│  [NPC Portrait]                     │
│                                     │
│  Hanako: "桜がきれいですね..."       │
│  (The cherry blossoms are beautiful)│
│                                     │
│  You sit together under blooming    │
│  sakura trees. Petals fall gently.  │
│  Pink and white everywhere. Magic.  │
│                                     │
│  Choices:                           │
│  ┌─────────────────────────────┐   │
│  │ 💬 "Beautiful, like you"    │   │
│  │    Romantic DC 14           │   │
│  │    Success: +22 ❤️          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 💋 Lean in for kiss         │   │
│  │    Romantic DC 18           │   │
│  │    Success: First kiss! 💕  │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 🤝 Enjoy the moment quietly │   │
│  │    Auto-success: +10 ❤️     │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 📊 Analytics & Telemetry

### Data to Collect

```python
# Event analytics
{
  'event_id': 'RE-TOKYO-002',
  'triggered_count': 15234,
  'success_rate': 0.73,
  'average_relationship_gain': 19.5,
  'player_rating': 4.7,
  'most_common_choice': 'A1',
  'average_duration_seconds': 180
}

# Relationship analytics
{
  'total_romances_started': 45000,
  'reached_dating': 32000,
  'reached_commitment': 18000,
  'reached_marriage': 5600,
  'breakups': 8400,
  'average_events_to_commitment': 35,
  'average_days_to_commitment': 45
}

# Cultural analytics
{
  'region': 'asia',
  'total_regional_events_triggered': 25000,
  'most_popular_event': 'RE-TOKYO-002',
  'cultural_appreciation_score': 4.8,
  'player_satisfaction': 4.6
}
```

---

## 🔐 Security

### Authentication
- JWT tokens for API
- Player session validation
- Rate limiting (100 requests/minute)

### Data Privacy
- Encrypt sensitive relationship data
- GDPR compliance (EU players)
- Right to delete romance history
- Anonymous analytics

### Anti-Exploit
- Prevent relationship score manipulation
- Detect bot behavior
- Rate limit event triggering
- Validate skill check rolls server-side

---

## 🌍 Localization

### Supported Languages (18)

- English (global)
- Japanese (日本語)
- Korean (한국어)
- Chinese Simplified (简体中文)
- French (Français)
- German (Deutsch)
- Italian (Italiano)
- Spanish (Español)
- Portuguese (Português)
- Russian (Русский)
- Arabic (العربية)
- Hebrew (עברית)
- Turkish (Türkçe)
- Polish (Polski)
- Hindi (हिन्दी)
- Thai (ไทย)
- Tagalog
- Swahili

### Translation Strategy
- All event dialogues translated
- Cultural phrases kept in original + translation
- "I love you" in all languages
- Professional translators + native speaker review

---

## 🎓 Learning & Adaptation

### ML Model for Recommendations

```python
# Features for ML model
features = [
    'relationship_score',
    'chemistry_score',
    'player_class',
    'npc_culture',
    'time_of_day',
    'season',
    'recent_event_categories',
    'player_historical_preferences',
    'npc_personality_vector',
    'conflict_count',
    'days_since_interaction'
]

# Labels
labels = ['player_satisfaction_rating']  # 1-5 stars

# Model
from sklearn.ensemble import RandomForestRegressor

model = RandomForestRegressor(n_estimators=100)
model.fit(features_train, labels_train)

# Predict best events
predictions = model.predict(candidate_events_features)
top_events = get_top_n_events(predictions, n=3)
```

---

## ✅ ГОТОВО К РЕАЛИЗАЦИИ

### Документация: ПОЛНАЯ ✅

1. ✅ **OpenAPI спецификация** (14 endpoints)
2. ✅ **Database schema** (11 tables, PostgreSQL)
3. ✅ **Event Selection Engine** (фильтрация → scoring → выбор)
4. ✅ **Chemistry Calculator** (4 компонента, weighted)
5. ✅ **Cultural Adapter** (16 культур)
6. ✅ **Trigger System** (10+ типов триггеров)
7. ✅ **Memory System** (полная история)
8. ✅ **AI Personality** (Big Five + Romance traits)

### Код готов для:
- Backend implementation (Java Spring Boot)
- Frontend integration (React/Vue)
- Database setup (PostgreSQL)
- AI service (Python)
- Testing (Unit, Integration, E2E)
- Deployment (Production-ready)

---

**СИСТЕМА РОМАНСОВ — ГОТОВА ДЛЯ СОЗДАНИЯ САМОГО РЕАЛИСТИЧНОГО И РАЗНООБРАЗНОГО РОМАНТИЧЕСКОГО ОПЫТА В ИСТОРИИ MMORPG!** 🌍💕🎮

