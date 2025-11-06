# Romance Event Selection Engine - Навигация

**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:05  
**Статус:** approved  
**api-readiness:** ready

---

## 📋 Описание

AI-powered алгоритм выбора романтических событий на основе множества факторов.

**Архитектура:**
```
Player Context + NPC Profile + Relationship State
                    ↓
            Event Selection Engine
                    ↓
    Filter → Weight → Score → Select → Adapt
                    ↓
            Recommended Event(s)
```

---

## 📑 Структура

### Part 1: Filtering & Weighting
**Файл:** [part1-filtering-weighting.md](./part1-filtering-weighting.md)  
**Содержание:** Event Filtering (Hard & Soft), Event Weighting, Personality Alignment

### Part 2: Scoring & Selection
**Файл:** [part2-scoring-selection.md](./part2-scoring-selection.md)  
**Содержание:** Event Scoring, Selection Strategy, NPC-Initiated Events, Event Adaptation

### Part 3: Advanced Systems
**Файл:** [part3-advanced-systems.md](./part3-advanced-systems.md)  
**Содержание:** Chemistry Calculator, Trigger System, Context Gathering, Smart Recommendations, Memory System, Full Event Cycle

---

## API Tasks Status

- ✅ **Задача создана:** API-TASK-164
- 📅 **Дата:** 2025-11-07
- 🔄 **Статус:** queued

---

## 🔗 Связанные документы

- [NPC Personality & Romance AI](../../ai-systems/npc-personality-romance-ai.md)
- [Romance Events Index](../../../04-narrative/quests/romantic/ROMANCE-EVENTS-INDEX-1000.md)
- [Romance System Technical Overview](../../ROMANCE-SYSTEM-TECHNICAL-OVERVIEW.md)

---

## История изменений

- v1.0.1 (2025-11-07 02:05) - Разбит на 3 части (сохранён весь код)
- v1.0.0 (2025-11-06) - Создан (1027 строк)

