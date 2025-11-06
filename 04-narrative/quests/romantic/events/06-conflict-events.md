---
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06
---

# Романтические события: Конфликты (Conflict Events)

80 событий для ссор, недопониманий и конфликтов (любой уровень relationship).


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-164](../../../API-SWAGGER/tasks/active/queue/task-164-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## RE-136: Ревность

**Категория:** Conflict | **Relationship:** Any 40+ | **DC:** 18 (Social)

### Триггеры
- Player flirts/interacts with another NPC
- NPC witnesses this
- Relationship 40+ (ревность возможна)

### Сценарии ревности

#### Level 1: Mild jealousy (Relationship 40-60)
- NPC: "Who was that?"
- Player response:
  1. **"Just a friend"** (Persuasion DC 16)
     - Успех: NPC believes +5 relationship, "Okay, I trust you"
     - Провал: NPC suspicious -10 relationship, "Sure..."

  2. **"You're jealous?"** (Charisma DC 18)
     - Успех: "Maybe a little" +8 relationship, Flirty tension
     - Провал: "No!" (defensive) -5 relationship

  3. **Reassure with actions** (Romantic DC 16)
     - Kiss NPC in front of other → +15 relationship, "You're mine"

#### Level 2: Serious jealousy (Relationship 60-80)
- NPC: "I saw you with them. What's going on?"
- More serious, trust questioned
- Harder to resolve (Social DC 22)
- Risk: -20 relationship if handled poorly

#### Level 3: Rage jealousy (Relationship 80+)
- NPC: "How could you?!"
- May storm off
- Requires RE-166 (Reconciliation) or relationship at risk
- Can lead to RE-201 (Breakup crisis)

### Outcomes
- **Resolved quickly:** +5 relationship, "I'm sorry I doubted"
- **Unresolved:** -15 relationship, Lingering doubt
- **Escalated:** -30 relationship, Major conflict

---

## RE-137: Разные ценности

**Категория:** Conflict | **Relationship:** 50-90 | **DC:** 20 (Persuasion)

### Триггеры
- Moral choice in quest
- NPC disagrees strongly
- Core values clash

### Типы конфликтов ценностей

1. **Corpo vs. Street** (Faction conflict)
   - You chose corpo, NPC is street → -20 relationship
   - Persuasion DC 24 to explain
   - May be unresolvable

2. **Violence vs. Peace**
   - You killed, NPC pacifist → -25 relationship
   - WILL DC 22 to defend choice

3. **Loyalty vs. Betrayal**
   - You betrayed faction NPC loyal to → -40 relationship, **Critical conflict**
   - Persuasion DC 28 or relationship ends

4. **Money vs. Morals**
   - You chose money over morals → -20 relationship
   - Social DC 22 to justify

### Outcomes
- **Agree to disagree:** +5 relationship, Tension remains
- **One changes view:** +10 relationship, Growth
- **Irreconcilable:** -40 relationship, May break up

---

## RE-138: Забытая годовщина/важная дата

**Категория:** Conflict | **Relationship:** 70-90 | **DC:** 16 (Social)

### Триггеры
- Important date (anniversary, birthday)
- Player forgot or didn't acknowledge

### NPC reaction (depends on personality)
- **Understanding:** "It's okay, you're busy" +0 relationship
- **Hurt:** "You forgot?" -15 relationship
- **Angry:** "This is important to me!" -25 relationship

### Recovery options
1. **Immediate apology** (Empathy DC 16)
   - Успех: "I forgive you" -5 relationship (damage control)
   - Провал: "Not good enough" -20 relationship

2. **Grand gesture** (Charisma DC 22)
   - Organize surprise late celebration → +10 relationship, "You made up for it"

3. **Expensive gift** (Cost varies)
   - Jewelry/Flowers → +5 relationship, Materialistic fix

### Consequences
- **Forgiven:** -5 relationship, Don't forget again
- **Not forgiven:** -25 relationship, NPC remembers
- **Second time:** -40 relationship, "You don't care"

---

## RE-139: Ложь обнаружена

**Категория:** Conflict | **Relationship:** Any | **DC:** 24 (Persuasion)

### Триггеры
- Player lied before
- Truth revealed
- NPC discovers lie

### Типы лжи

1. **White lie** (minor)
   - "Why did you lie?" → Persuasion DC 20
   - -10 relationship, "Don't lie again"

2. **Serious lie** (about feelings, past)
   - "I trusted you!" → Persuasion DC 24
   - -30 relationship, Trust damaged

3. **Betrayal lie** (cheating, major betrayal)
   - "We're done." → Persuasion DC 28 or relationship ends
   - -50 relationship, May be unrecoverable

### Recovery
- **Honest explanation:** -15 relationship, but salvageable
- **More lies:** -50 relationship, Definitely over
- **Grovel:** -20 relationship, "I need time"

---

## RE-140: Проведение времени с другими

**Категория:** Conflict | **Relationship:** 60-90 | **DC:** 16 (Social)

### Триггеры
- Player spent много времени away
- With other friends/NPCs
- NPC feels neglected

### NPC complaint
- "You're never around anymore"
- "Do you even care about us?"
- "I feel like I'm not a priority"

### Responses
1. **Explain** (Social DC 16)
   - Успех: "I understand, but I miss you" -5 relationship
   - Провал: NPC still hurt -15 relationship

2. **Promise more time** (Social DC 14)
   - Keep promise: +10 relationship
   - Break promise: -30 relationship, Trust broken

3. **Dismiss** ("You're overreacting")
   - → -25 relationship, "Maybe we're not compatible"

---

## RE-141-165: [Ещё 25 конфликтных событий]

**RE-141: Financial argument**
- Money spending dispute (Trading DC 20)
- -15 relationship if unresolved

**RE-142: Family interference**
- NPC's family doesn't like you (Social DC 24)
- -20 relationship, May have to choose

**RE-143: Work vs. relationship**
- Player prioritizes work (Social DC 22)
- -18 relationship, "Am I not important?"

**RE-144: Secrets discovered**
- NPC finds your secret (Varies DC 26)
- -25 relationship, "Why didn't you tell me?"

**RE-145: Ex-partner returns**
- NPC's ex wants them back (WILL DC 24)
- -20 relationship if you're insecure

**RE-146: Cheating suspicion**
- Misunderstanding, NPC thinks you cheated (Persuasion DC 26)
- -35 relationship, "Prove you didn't"

**RE-147: Addiction discovered**
- NPC's addiction (drugs, BD) revealed (Medtech DC 22)
- Help or leave? Choice determines relationship

**RE-148: Violence witnessed**
- NPC sees your violent side (WILL DC 22)
- -20 relationship, "I didn't know you could..."

**RE-149: Political disagreement**
- Opposite political views (Social DC 24)
- -15 relationship, Can you coexist?

**RE-150: Religious conflict**
- Different religions (Culture DC 26)
- -20 relationship, Serious issue for some

**RE-151: Lifestyle clash**
- Nomad vs. Settled, Night owl vs. Early bird
- -10 relationship, Compatibility question

**RE-152: Friends don't approve**
- Your friends don't like NPC (Social DC 20)
- Choose friends or NPC?

**RE-153: Career sacrifice**
- NPC wants you to give up career (Social DC 26)
- -25 relationship if refuse

**RE-154: Relocation conflict**
- One wants to move cities (Social DC 24)
- -30 relationship, Long distance or break up?

**RE-155: Baby discussion (future)**
- Want kids? Disagreement (Social DC 26)
- -35 relationship, Deal-breaker for some

**RE-156: Marriage pressure**
- NPC wants marriage, you don't (Social DC 24)
- -30 relationship, "What are we waiting for?"

**RE-157: Invasion of privacy**
- Went through phone/messages (Trust issue)
- -40 relationship, "I can't trust you"

**RE-158: Embarrassed in public**
- NPC embarrassed you in front of friends (Social DC 20)
- -20 relationship, Resentment

**RE-159: Broken promise**
- You promised something, didn't deliver (Social DC 22)
- -25 relationship, "Your word means nothing"

**RE-160: Substance abuse**
- You have substance problem (WILL DC 24)
- -30 relationship, "Get help or we're done"

**RE-161: Gambling debts**
- You gambled shared money (Trading DC 26)
- -40 relationship, Financial trust broken

**RE-162: Prioritized friend over NPC**
- Chose friend over NPC in conflict (Social DC 22)
- -20 relationship, "I thought I mattered more"

**RE-163: Canceled date last minute**
- Third time canceling (Social DC 24)
- -25 relationship, "I'm tired of this"

**RE-164: Insensitive comment**
- Said something hurtful (Empathy DC 18)
- -15 relationship, "That hurt"

**RE-165: Ignored calls/messages**
- Ghosted NPC for days (Social DC 20)
- -30 relationship, "I thought something happened to you"

---

## Механика конфликтов

### Conflict Severity
- **Minor (1-3)** — Small argument, easy to resolve
- **Moderate (4-6)** — Serious fight, needs reconciliation event
- **Major (7-9)** — Relationship-threatening, may need multiple reconciliation
- **Critical (10)** — Break-up crisis, may be unrecoverable

### Conflict Resolution Paths
1. **Immediate apology** — Quick fix (DC lower)
2. **Give space** — Cool off period, then reconcile
3. **Grand gesture** — Big apology (DC higher but +relationship if success)
4. **Therapy/Mediation** — Third party help (Empathy DC 22)
5. **Unresolved** — Leads to more conflicts, eventual crisis

### Conflict accumulation
```
Unresolved_Conflicts = Count of conflicts not resolved
If Unresolved_Conflicts >= 3: Trigger RE-201 (Crisis/Breakup)
If Unresolved_Conflicts >= 5: Relationship ends (unless major reconciliation)
```

### Make-up events
- After conflict resolved → RE-166-185 (Reconciliation events)
- "Make-up sex" — +40 relationship, Passion after fight
- "I'm sorry" kiss — +25 relationship, Sweet reconciliation
- Long talk resolution — +30 relationship, Understanding reached

---

## Regional conflict variations

### Asian cultures
- **Public argument:** -30 relationship (loss of face)
- **Family sided with:** Critical (can end relationship)
- **Indirect conflict:** Passive-aggressive, harder to resolve

### Western cultures
- **Direct confrontation:** Expected, healthy
- **Therapy accepted:** Couples counseling option
- **Independence valued:** Personal space respected

### Latin cultures
- **Passionate fights:** Normal, part of relationship
- **Dramatic gestures:** Expected for reconciliation
- **Family mediates:** Often involves family

### Middle Eastern
- **Honor important:** Public respect critical
- **Family involvement:** Family may demand breakup if dishonor
- **Gender roles:** Traditional expectations may cause conflict

---

## 80 conflict events total

Реалистичные проблемы отношений, требующие работы и решения.

