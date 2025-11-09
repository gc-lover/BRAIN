# Quest Branching Liquibase PoC Scripts

## Состав

```
scripts/poc/quest-branching/
 ├─ README.md
 └─ run_poc.ps1
```

- `README.md` — инструкция по запуску PoC.
- `run_poc.ps1` — PowerShell-скрипт с последовательностью команд (остановки закомментированы, выполняй по шагам вручную).

## Предварительные требования

- Установлен Liquibase (4.17+).
- Настроен `liquibase.properties` с доступом к PoC-базе (PostgreSQL 15+).
- Пользователь БД с правами `SUPERUSER` (для RLS и ролей).
- Пустая база данных `quest_branching_poc`.

## Последовательность

1. Очистить базу (опционально):
   ```sql
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   ```
2. Выполнить `liquibase update --tag=quest-branching-v1`.
3. Запустить проверки shadow-write (вставка тестовых квестов), MV и RLS.
4. Вызвать `SELECT quest_branching_rollback();`.
5. Сделать `liquibase rollbackOneTag quest-branching-v1`.
6. Повторный цикл при необходимости (например, через `run_poc.ps1`).

## Метрики

- Время `update`, `rollback`, `quest_branching_rollback()`.
- Количество записей в `quest_path_popularity`.
- Наличие флагов `quest:<id>:completed` после завершения квеста.

## Отчёт

- Снимки логов команд.
- Таблица с метриками и замечаниями.
- Список выявленных проблем + рекомендации.

