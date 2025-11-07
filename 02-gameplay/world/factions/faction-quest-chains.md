---
**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07  
**Последнее обновление:** 2025-11-07 22:04  
**Приоритет:** high  
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 22:04  
**api-readiness-notes:** Фракционные цепочки квестов: задания, подрядчики, условия вступления, репутационные развилки и REST/WS контракты для world-service/social-service.
---

# Faction Quest Chains — Контракты и ветвления

**target-domain:** gameplay-world/factions  
**target-microservice:** world-service (8086), social-service (8084)  
**target-frontend-module:** modules/world/contracts  
**интеграции:** combat-session, economy-service, analytics-service

## 1. Цели
- Связать авторские корпорации/банды и исторические фракции с многоступенчатыми заданиями.
- Описать условия вступления, подрядчиков (контакт NPC) и репутационные развилки.
- Подготовить REST/WS контракты для выдачи, трекинга и завершения цепочек.

## 2. Структура цепочек
| Фракция | Цепочка | Стартовый NPC | Требование вступления | Ключевые ветви |
| --- | --- | --- | --- | --- |
| Aeon Dynasty Systems | orbital-supply-crusade | Liang  Celestial Wen | ep.corp.aeon >= 20, доступ к орбитальному доку | Выбор между защитой грузов и саботажем конкурентов |
| Crescent Energy Union | desert-grid-reclamation | Amira Al-Faris | Завершить эвенты Helix Reclaimers, иметь Nomad союз | Решение: стабилизировать энергосеть или перенаправить мощность Nomad |
| Mnemosyne Archives | memory-echo-accord | Dr. Sofia Arvidsson | legacy_rep.hist-urban-scribes >= 15, выполнения архивных квестов | Ветвление: восстановить личность или стереть данные |
| Ember Saints | inferno-covenant | Mother Pyra | Провести Harbor Broadcast, ep.street.ember >= 10 | Пощадить врагов → бонус защите района, уничтожить → усиленные моды |
| Void Sirens | zero-g-privateer | Captain Nyla Kalu | Репутация Aeon >=10 или Maelstrom >=5, наличие космокорабля | Ветвь между контрабандой корпоратов или спасением колонистов |
| Basilisk Sons | asilisk-hunt | Marshal Vega | Контракт с Nomad Coalition, транспорт с броней | Ветка: найм мехов или сбор данных для Militech |
| Quantum Fable Collective | story-heist-legacies | Lyra Voss | ep.media.indie >= 12, участие в Urban Scribes событиях | Развилка: публиковать архивы или монетизировать их |
| Echo Dominion | metanet-tribunal | Echo Arbiter Z3N | Завершённые квесты Voodoo Boys, legacy_rep.hist-echo-dominion >= 10 | Выбор ИИ-кандидатов, влияющих на world flags |

## 3. Шаги цепочки (пример Aeon Dynasty)
1. **Briefing:** Liang Wen поясняет угрозу конкурентных рейдов, активируется GET /world/contracts/aed/orbital-supply-crusade.
2. **Mission Fork:** игрок выбирает Escort или Sabotage через POST /world/contracts/aed/orbital-supply-crusade/choose.
3. **Dynamic Events:** world-service вызывает Escort → события на орбитальных трассах; Sabotage → атаки на логистику конкурентов.
4. **Outcome:** POST /world/contracts/aed/orbital-supply-crusade/outcome фиксирует успех/провал, обновляет ep.corp.aeon и world flags.
5. **Legacy Hook:** social-service отправляет ContractConclusion и активирует доступ к рейду orbital-lockdown.

## 4. Ветвления репутации
- **Позитивная ветка:** выполнение без collateral повышает репутацию фракции и открывает романтические ветки (если применимо).
- **Серая ветка:** компромиссные действия дают гибридный лут, но фиксируют legacy_conflict флаг -> влияет на исторические фракции.
- **Негативная ветка:** саботаж усиливает rival фракции, добавляет новых мировых событий (вражеские рейды).

## 5. REST/WS Контракты
| Endpoint | Метод | Назначение |
| --- | --- | --- |
| /world/contracts | GET | Список доступных фракционных цепочек с фильтрами по репутации |
| /world/contracts/{chainId} | GET | Детали цепочки, этапы, требования |
| /world/contracts/{chainId}/choose | POST | Выбор ветки (escort, sabotage, archive, tribunal) |
| /world/contracts/{chainId}/progress | POST | Фиксация этапа, обновление world flags |
| /world/contracts/{chainId}/outcome | POST | Финальный результат, награды, репутация |

**WebSocket:** wss://world-service/contracts/{chainId} вещает StageStart, StageUpdate, ChoiceLocked, OutcomeApplied.

## 6. Схемы данных
`sql
CREATE TABLE faction_contracts (
    chain_id VARCHAR(64) PRIMARY KEY,
    faction_id VARCHAR(64) NOT NULL,
    title VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    entry_requirements JSONB NOT NULL,
    stages JSONB NOT NULL,
    reputation_branches JSONB NOT NULL,
    rewards JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faction_contract_progress (
    chain_id VARCHAR(64) REFERENCES faction_contracts(chain_id) ON DELETE CASCADE,
    player_id UUID NOT NULL,
    current_stage VARCHAR(64) NOT NULL,
    selected_branch VARCHAR(32),
    progress_state JSONB,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (chain_id, player_id)
);
`

## 7. Готовность
- Цепочки прописаны, ветки репутации и API контуры подготовлены.
- Связь с actions-original-catalog.md, actions-timeline-2020-2093.md, action-cult-defenders.md установлена.
