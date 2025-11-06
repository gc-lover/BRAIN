---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-161: docs/api-gateway-arch.md (2025-11-07 11:26)
- Last Updated: 2025-11-07 00:18
---


# API Gateway Architecture - Архитектура API шлюза

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-07 (обновлено с реализацией)  
**Приоритет:** высокий (Production)

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07  
**api-readiness-notes:** API Gateway architecture. Routing, load balancing, authentication check, rate limiting, caching, logging, API versioning. Production critical!

---

## Краткое описание

Архитектура API Gateway для централизованного управления запросами.

**Микрофича:** API Gateway (routing, load balancing, rate limiting, authentication)

---

## ✅ Текущая реализация (Фаза 1 - Завершена!)

**Технология:** Spring Cloud Gateway  
**Порт:** 8080  
**Статус:** ✅ Работает в production!  
**Файл:** `BACK-GO/infrastructure/api-gateway/`

**Deployment:**
```bash
cd BACK-GO
docker-compose -f docker-compose-microservices.yml up api-gateway
```

**URL:** http://localhost:8080

### Маршрутизация к микросервисам

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://AUTH-SERVICE  # Load balanced через Eureka
          predicates:
            - Path=/api/v1/auth/**
          
        - id: character-service
          uri: lb://CHARACTER-SERVICE
          predicates:
            - Path=/api/v1/characters/**,/api/v1/players/**
          
        - id: gameplay-service
          uri: lb://GAMEPLAY-SERVICE
          predicates:
            - Path=/api/v1/gameplay/**
          
        - id: social-service
          uri: lb://SOCIAL-SERVICE
          predicates:
            - Path=/api/v1/social/**
          
        - id: economy-service
          uri: lb://ECONOMY-SERVICE
          predicates:
            - Path=/api/v1/economy/**
          
        - id: world-service
          uri: lb://WORLD-SERVICE
          predicates:
            - Path=/api/v1/world/**
```

### Пример запроса через Gateway

```bash
# Клиент делает запрос к API Gateway
curl http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "player@necp.game", "password": "pass123"}'

# API Gateway:
# 1. Получает запрос на /api/v1/auth/login
# 2. Находит route для /api/v1/auth/**
# 3. Маршрутизирует на auth-service (lb://AUTH-SERVICE)
# 4. Eureka возвращает адрес auth-service: localhost:8081
# 5. Gateway делает запрос к http://localhost:8081/api/v1/auth/login
# 6. Получает ответ от auth-service
# 7. Возвращает ответ клиенту
```

---

## 🌐 Концепция

**API Gateway** — единая точка входа для всех API запросов.

**Функции:**
1. **Routing** - направление запросов к нужным микросервисам (через Eureka)
2. **Load Balancing** - распределение нагрузки между инстансами
3. **Authentication** - проверка JWT tokens
4. **Rate Limiting** - защита от DDoS
5. **Logging** - централизованное логирование
6. **Caching** - кэширование ответов
7. **Circuit Breaker** - защита от падения сервисов

---

## 🔀 Routing

### Service Discovery

```
Client Request: GET /api/v1/characters/{id}

Gateway:
1. Parse request
2. Check authentication
3. Route to Character Service
4. Return response

Services:
- Auth Service: /auth/*
- Character Service: /characters/*
- Inventory Service: /inventory/*
- Market Service: /market/*
- Etc.
```

---

## ⚖️ Load Balancing

**Algorithms:**
- Round Robin (по очереди)
- Least Connections (к наименее загруженному)
- IP Hash (одинаковый IP → одинаковый сервер)

**Health Checks:**
```
Every 30 seconds:
→ Ping each service instance
→ If unhealthy (3 failed checks):
  → Remove from pool
  → Alert admins
```

---

## 🔒 Security Features

**Rate Limiting:**
```
Per IP:
- 100 requests/minute (general)
- 10 requests/second (burst)

Per User:
- 1,000 requests/hour
- 10 login attempts/hour
```

**DDoS Protection:**
- IP blacklist
- Challenge-response (CAPTCHA)
- Traffic spike detection

---

## 📊 Структура

```
Client → API Gateway → Services

Gateway handles:
- SSL/TLS termination
- Authentication
- Rate limiting
- Routing
- Caching
- Logging

Services:
- Stateless (можно scale horizontally)
- Independent deployment
- Microservices architecture
```

---

## 🔗 Связанные документы

- `database-architecture.md`
- `caching-strategy.md`

---

## История изменений

- v1.0.0 (2025-11-06 23:00) - Создание API Gateway архитектуры

