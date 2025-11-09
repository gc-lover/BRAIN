# Quest Branching Liquibase PoC

**Статус:** in-progress  
**Версия:** 0.1.0  
**Дата создания:** 2025-11-09  
**Последнее обновление:** 2025-11-09 14:35  
**Приоритет:** высокий  
**Автор:** AI Manager

---

## Цель

Проверить полный цикл миграций `quest-branching-v1`, убедиться в корректности shadow-write, материализованных представлений и RLS, подготовить отчёт для последующей постановки задач.

---

## Подготовка среды

- PostgreSQL 15+ с расширением `pgcrypto` (для UUID).
- Отдельная база `quest_branching_poc`.
- Права superuser для запуска RLS и ролей.
- Liquibase 4.17+ и `liquibase.properties` с подключением к PoC-базе.

---

## Последовательность

1. **Очистка**  
   - `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`  
   - Выполнить базовые миграции проекта (если требуются зависимости).

2. **Запуск миграций**  
   - `liquibase update --tag=quest-branching-v1`.
   - Зафиксировать время выполнения (ожидаемо < 90 секунд).

3. **Проверка shadow-write**  
   - Вставить данные в `quests` и `quest_progress` (старт/завершение квеста).  
   - Убедиться, что `quest_branches` создаёт запись `default`.  
   - Проверить появление флага `quest:<id>:completed` в `player_flags`.

4. **Материализованное представление**  
   - Выполнить `REFRESH MATERIALIZED VIEW CONCURRENTLY quest_path_popularity;`.  
   - Убедиться, что записи отражают популярность путей.

5. **RLS**  
   - `SET app.current_character_id = '<uuid>';`  
   - Проверить, что `SELECT * FROM quest_progress;` возвращает строки только текущего персонажа.  
   - Убедиться, что пользователи без установки параметра получают пустой результат.

6. **Rollback**  
   - `SELECT quest_branching_rollback();`.  
   - Проверить, что триггеры отключены, MV удалено, политики RLS сняты.  
   - `liquibase rollbackOneTag quest-branching-v1`.

7. **Повторный цикл**  
   - Повторить п.п.2–6 в автоматизированном скрипте (bash/PowerShell) для фиксации времени и выявления ошибок.

---

## Метрики

- Время `liquibase update` и `rollback`.  
- Время `quest_branching_rollback()` (ожидаемо < 2 сек).  
- Проверка наличия записей в `quest_path_popularity` и актуальности процентов.  
- Количество записей в `player_flags` после завершения квеста.

---

## Отчёт

- Таблица с метриками (update, refresh, rollback).  
- Логи команды `liquibase update` и `rollback`.  
- Список найденных проблем (если есть) с рекомендациями.

---

## Следующие шаги

- Реализовать автоматизированный скрипт PoC.  
- Выполнить прогон и собрать отчёт.  
- На основании результата актуализировать `readiness-tracker.yaml` и подготовить пакет задач в API-SWAGGER.


