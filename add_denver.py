from pathlib import Path
from textwrap import dedent

path = Path("06-tasks/config/readiness-tracker.yaml")
block = dedent("""
  - path: ".BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-004-craft-beer-scene.md"
    version: "0.1.0"
    status: "needs-work"
    priority: "low"
    checked: "2025-11-09 09:42"
    checker: "Brain Manager"
    api_target:
      microservice: null
      directory: null
      frontend_module: null
    notes: "Конспект тура по пивоварням Денвера не следует QUEST-TEMPLATE; необходимо добавить YAML-метаданные, статус, ветви выбора, этапы с проверками и интеграции с системами перед формированием API задач."
  - path: ".BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-005-skiing-resorts.md"
    version: "0.1.0"
    status: "needs-work"
    priority: "low"
    checked: "2025-11-09 09:44"
    checker: "Brain Manager"
    api_target:
      microservice: null
      directory: null
      frontend_module: null
    notes: "Краткое описание лыжных курортов не приведено к QUEST-TEMPLATE; необходимо добавить YAML-метаданные, статус, ветвления, этапы с проверками и связи с системами (economy, progression) перед подготовкой API задач."
  - path: ".BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-006-broncos-football.md"
    version: "0.1.0"
    status: "needs-work"
    priority: "low"
    checked: "2025-11-09 09:45"
    checker: "Brain Manager"
    api_target:
      microservice: null
      directory: null
      frontend_module: null
    notes: "Документ о Denver Broncos не следует QUEST-TEMPLATE; требуется добавить YAML-метаданные, статус, ветвления, зависимости с quest-engine и экономикой фанатов, а также детализировать награды."
  - path: ".BRAIN/03-lore/_03-lore/timeline-author/quests/america/denver/2020-2029/quest-007-altitude-sickness.md"
    version: "0.1.0"
    status: "needs-work"
    priority: "low"
    checked: "2025-11-09 09:50"
    checker: "Brain Manager"
    api_target:
      microservice: null
      directory: null
      frontend_module: null
    notes: "Описание высотной болезни требует приведения к QUEST-TEMPLATE: добавить YAML-метаданные, статус, ветвления, зависимости с системами здоровья и экономики, определить каталоги API и расширить награды."
""")

path.write_text(path.read_text(encoding="utf-8") + block, encoding="utf-8")
