# Технические задания

**api-readiness:** needs-work  
**api-readiness-check-date:** 2025-11-04 00:15  
**api-readiness-notes:** Служебный файл, обзор раздела. Документы с техническими требованиями для MVP в процессе создания.

Этот раздел содержит технические задания, требования к API, схемы БД и архитектурные решения.

## Структура

### MVP (Минимальная версия продукта)
- `mvp-text-version-plan.md` - План и требования для MVP текстовой версии
- `ui-mvp-screens.md` - Детальное описание всех экранов MVP (требует создания)

### UI/UX (Интерфейсы)
- `ui-registration.md` - Экран регистрации ✅ ready
- `ui-character-creation.md` - Начальный интерфейс: выбор и создание персонажа ✅ ready
- `ui-game-start.md` - Начало игры и боевая система D&D формата ✅ ready
- `ui-main-game.md` - Основной игровой интерфейс (текстовая версия) ✅ ready

### API Requirements (Требования к API)
- `api-requirements/mvp-endpoints.md` - Endpoints для MVP (требует создания)
- `api-requirements/mvp-data-models.md` - Модели данных для MVP (требует создания)
- `api-requirements/equipment-matrix-entities.md` - Equipment Matrix entities ✅ ready

### Database (База данных)
- `database/schema.md` - Схема БД для MVP (требует создания)
- `database/migrations.md` - Миграции для MVP (требует создания)
- `mvp-initial-data.md` - Минимальный набор данных для MVP (требует создания)

### Architecture (Архитектура)
- `architecture/mvp-backend-architecture.md` - Архитектура бекенда для MVP (требует создания)
- `architecture/mvp-frontend-architecture.md` - Архитектура фронтенда для MVP (требует создания)

## Связь с API-SWAGGER

Технические документы должны ссылаться на соответствующие API спецификации в репозитории `API-SWAGGER`.

## Статус MVP

**Текущий этап:** Документация MVP + Контент

**Готово:**
- ✅ План MVP (mvp-text-version-plan.md)
- ✅ Регистрация (ui-registration.md) - ready
- ✅ Создание персонажа (ui-character-creation.md) - ready
- ✅ Основной интерфейс (ui-main-game.md) - ready
- ✅ API требования для MVP (api-requirements/mvp-endpoints.md)
- ✅ Модели данных для MVP (api-requirements/mvp-data-models.md)
- ✅ Минимальный набор данных (mvp-initial-data.md)
- ✅ JSON данные для MVP (mvp-data-json/*.json)
- ✅ Детальные тексты и контент (mvp-content/*)

**Требует работы:**
- ⚠️ UI спецификация для MVP (ui-mvp-screens.md)
- ⚠️ Архитектура бекенда для MVP
- ⚠️ Архитектура фронтенда для MVP
- ⚠️ SQL скрипты для миграций БД

