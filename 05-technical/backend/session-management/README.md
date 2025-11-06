# Session Management System - Навигация

**Версия:** 1.0.2  
**Дата:** 2025-11-07  
**Статус:** approved

---

## Микросервисная архитектура

**Ответственный микросервис:** auth-service  
**Порт:** 8081  
**API Gateway маршрут:** `/api/v1/auth/session/*`  
**Статус:** ✅ Частично реализовано (Фаза 1)

**Взаимодействие с другими сервисами:**
- character-service: обновление session при выборе персонажа
- world-service: обновление session при смене зоны
- gameplay-service: heartbeat для активной сессии

**Event Bus события:**
- Публикует: `session:created`, `session:expired`, `session:terminated`
- Подписывается: `auth:login`, `auth:logout`, `character:selected`

---

## 📋 Описание

Управление сессиями: JWT refresh, multi-device support, session security.

---

## 📑 Структура

### Part 1: Core Session Management
**Файл:** [part1-core-sessions.md](./part1-core-sessions.md)  
**Содержание:** Database schema, Create/Validate/Refresh sessions, Security

### Part 2: Advanced Features
**Файл:** [part2-advanced-features.md](./part2-advanced-features.md)  
**Содержание:** Multi-device, Session analytics, Cleanup, Best practices

---

## История изменений

- v1.0.1 (2025-11-07 02:18) - Разбит на 2 части
- v1.0.0 (2025-11-06) - Создан (961 строка)

