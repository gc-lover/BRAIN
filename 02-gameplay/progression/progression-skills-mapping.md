---
**API Tasks Status:**
- Status: queued
- Tasks:
  - API-TASK-159: api/v1/progression/skills-mapping.yaml (2025-11-07 11:22)
- Last Updated: 2025-11-07 00:18
---


# Навыки — соответствия предметам и имплантам

**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 16:46  
**api-readiness-notes:** «Маппинг навыков расширен: полные таблицы соответствий, структура данных, REST API и валидация с equipment/implants. Готово для API задач.»

**target-domain:** gameplay-progression  
**target-microservice:** gameplay-service (port 8083)  
**target-frontend-module:** modules/progression/skills

**Статус:** approved  
**Версия:** 1.1.0  
**Дата создания:** 2025-11-05  
**Последнее обновление:** 2025-11-07 16:46  
**Приоритет:** Высокий

---

## Сводная таблица соответствий (v1)

| Навык/Категория | Требуемые предметы (type/subtype) | Теги/поля (equipment-matrix) | Импланты (slotType) | Синергийные теги |
|---|---|---|---|---|
| Стрельба: «Точный выстрел» | weapon/sniper_rifle, weapon/assault_rifle | StatsCore.accuracy, WeaponStats.adsBonus | combat (оптика), tactical (оптика) | brand: Tsunami, Kiroshi; tags: smartLock |
| Стрельба: «Стабилизация отдачи» | weapon/* | StatsCore.recoil, WeaponStats.handling | combat (стабилизатор) | brand: Militech; tags: recoilStability |
| Стрельба: «Контроль дыхания» | weapon/sniper_rifle | WeaponStats.adsBonus | tactical (оптика) | brand: Tsunami; tags: accuracy++ |
| Ближний бой: «Парирование» | weapon/melee | StatsExtended.damageType=melee | combat (киберруки/клинки) | tags: blades, melee |
| Паркур: «Кошачий прыжок» | armor/legs | ArmorStats.modSlots.utility | mobility (киберноги) | tags: mobility+ |
| Стелс: «Тихий шаг» | armor/legs, armor/body | ArmorStats.noiseDamp | mobility (Lynx Paws), defensive (киберкожа) | tags: lowNoise |
| Хакерство: «Быстрый протокол» | cyberdeck/* | CyberdeckStats.ioBandwidth, regenRate | os (Cyberdeck) | deckLevel: T2+ |
| Хакерство/Бой: «Нейрошок» | weapon/smart | StatsExtended.damageType=emp | os (Cyberdeck), tactical (оптика) | tags: emp, smart |
| Крафт: «Полевой ремонт» | mod/*, armor/*, weapon/* | ModStats.statDelta, ArmorStats.modSlots | defensive (инструм.), combat (универс.) | tags: repairEase |
| Социальные: «Командная аура» | armor/head (комм‑модули) | ArmorStats.energyBuffer | tactical (связь) | tags: aura, group |
| Поддержка: «Тактическая сеть» | armor/head, armor/body | ArmorStats.commSuite, Defense.shieldBonus | tactical (Netrunner Link) | tags: teamBuff |
| Вождение: «Дрифт-контроль» | vehicle/mod/drift_kit | VehicleStats.handling | mobility (drive assist) | tags: vehicleHandling |
| Биомодификация: «Стабилизация имплантов» | mod/biotech | ImplantStats.failureChance | defensive (immune system) | tags: implantStability |
| Торговля: «Экономический анализ» | item/datachips/trade | ItemStats.marketInfluence | neural (risk assessor) | tags: tradeBoost |

Примечания:
- Типы/подтипы предметов см. `economy/equipment-matrix.md` (разделы Weapon/Armor/Cyberdeck/Mod).
- Типы имплантов см. `combat-implants-types.md` (`slotType`: combat, tactical, defensive, mobility, os).
- Синергийные теги сопоставляются с `synergyTags`/`brand.signatureBonuses`.

---

## Примеры требований для продвинутых навыков

- «Контроль дыхания»: прицел T2 (mod: sight), weapon: sniper_rifle, REF ≥ 12
- «Нейрошок»: Cyberdeck T2+, ioBandwidth ≥ X, INT ≥ 14, WILL ≥ 10
- «Кошачий прыжок»: mobility-имплант (Reinforced Tendons), AGI ≥ 10
- «Тихий шаг»: armor legs c `noiseDamp ≥ 10%`, Lynx Paws

---

## Связанные документы

- `progression-skills.md` — формулы/категории/ранги
- `progression-attributes-matrix.md` — требования и штрафы
- `economy/equipment-matrix.md` — типы предметов и статы
- `combat-implants-types.md` — типы имплантов и OS
