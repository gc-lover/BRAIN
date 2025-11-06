# Quest Branching Database Design - Навигация

**Статус:** in-progress  
**Версия:** 1.0.1  
**Дата:** 2025-11-07 02:15  
**Приоритет:** высокий

---

## 📋 Описание

Структура БД для глубокого ветвления квестов в MMORPG (по аналогии с BG3).

---

## 📑 Структура

### Part 1: Analysis & Core Tables
**Файл:** [part1-analysis-core.md](./part1-analysis-core.md)  
**Содержание:** Анализ текущего состояния, quests, quest_branches, dialogue tables

### Part 2: Advanced Tables & Examples
**Файл:** [part2-advanced-examples.md](./part2-advanced-examples.md)  
**Содержание:** Progress, flags, world_state, consequences, примеры использования

---

## ✅ Что есть

- 113+ квестов в JSON
- Базовые таблицы quests, quest_progress

## ❌ Что нужно

- Dialogue trees
- Player choices history
- Флаги состояния
- World state tracking
- Consequences system

---

## История изменений

- v1.0.1 (2025-11-07 02:15) - Разбит на 2 части (все SQL сохранены)
- v1.0.0 (2025-11-06 20:31) - Создан (988 строк)

