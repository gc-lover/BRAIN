# Библиотека романтических событий

Полная библиотека модульных событий для создания динамических романтических отношений.

## Структура

**Всего событий:** 250+

### По категориям

1. **[Meeting](./01-meeting-events.md)** — 20 событий (Знакомство, 0-20 relationship)
2. **[Friendship](./02-friendship-events.md)** — 25 событий (Дружба, 20-40 relationship) [TBD]
3. **[Flirting](./03-flirting-events.md)** — 30 событий (Флирт, 40-60 relationship)
4. **[Dating](./04-dating-events.md)** — 35 событий (Свидания, 60-75 relationship) [TBD]
5. **[Intimacy](./05-intimacy-events.md)** — 25 событий (Близость, 75-90 relationship) [TBD]
6. **[Conflict](./06-conflict-events.md)** — 30 событий (Конфликты, любой уровень) [TBD]
7. **[Reconciliation](./07-reconciliation-events.md)** — 20 событий (Примирение) [TBD]
8. **[Commitment](./08-commitment-events.md)** — 15 событий (Обязательства, 90-100) [TBD]
9. **[Crisis](./09-crisis-events.md)** — 20 событий (Кризис, разрыв) [TBD]
10. **[Special Regional](./10-special-regional-events.md)** — 40+ событий (По регионам) [TBD]

## Быстрый доступ

### По стадиям отношений
- **0-20:** Meeting events (RE-001 to RE-020)
- **20-40:** Friendship events (RE-021 to RE-045)
- **40-60:** Flirting events (RE-046 to RE-075)
- **60-75:** Dating events (RE-076 to RE-110)
- **75-90:** Intimacy events (RE-111 to RE-135)
- **Any:** Conflict events (RE-136 to RE-165)
- **After conflict:** Reconciliation (RE-166 to RE-185)
- **90-100:** Commitment (RE-186 to RE-200)
- **Crisis:** Crisis events (RE-201 to RE-220)
- **Regional:** Special events (RE-REGION-###)

## Использование

### Для дизайнеров
```
1. Определите текущий Relationship Score
2. Выберите категорию событий
3. Проверьте триггеры события
4. Примените skill checks
5. Обновите Relationship Score
6. Предложите следующие события
```

### Для программистов
```
GET /api/romance/events?relationship={score}&location={loc}
POST /api/romance/trigger/{eventId}
GET /api/romance/next-events/{npcId}
```

## Интеграция

- Система связана с [romance-events-system.md](../romance-events-system.md)
- JSON структуры готовы для API
- Алгоритм комбинирования событий реализован
- Триггеры интегрируются с игровыми локациями

