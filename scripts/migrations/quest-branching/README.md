# Quest Branching Liquibase

## Назначение

Каталог содержит миграции БД, реализующие структуру ветвящихся квестов из документа `06-tasks/active/CURRENT-WORK/active/2025-11-06-quest-branching-database-design.md`. Ченджсеты организованы по версиям, master-файл подключает их в требуемом порядке.

## Структура каталогов

```
scripts/migrations/quest-branching/
 ├─ master.xml
 └─ v1/
    ├─ 01-create-core-tables.xml
    └─ 02-create-branching-tables.xml
```

## Запуск

1. Убедиться, что Liquibase настроен на окружение PostgreSQL.
2. Выполнить `liquibase --defaultsFile=liquibase.properties --changelog-file=scripts/migrations/quest-branching/master.xml update`.
3. Для фиксации конкретной версии использовать тег: `liquibase tag quest-branching-v1`.

## Откат

```
liquibase --defaultsFile=liquibase.properties \
  --changelog-file=scripts/migrations/quest-branching/master.xml \
  rollbackOneTag quest-branching-v1
```

## Контроль

- После применения миграций сравнить количество столбцов в `quests` и `quest_progress` с ожидаемым.
- Проверить создание индексов `idx_quests_*` и `idx_quest_progress_*`.
- Зафиксировать результат в документе `06-tasks/active/CURRENT-WORK/active/2025-11-09-quest-branching-liquibase-plan.md`.

