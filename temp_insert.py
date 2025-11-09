from pathlib import Path

path = Path('06-tasks/config/readiness-tracker.yaml')
text = path.read_text(encoding='utf-8')
block = " - path: \.BRAIN/03-lore/_03-lore/timeline-author/quests/europe/rome/2020-2029/quest-004-pasta-master.md\\n version: \0.1.0\\n status: \needs-work\\n priority: \low\\n checked: \2025-11-09 09:36\\n checker: \Brain Manager\\n api_target:\n microservice: null\n directory: null\n frontend_module: null\n notes: \Сценарий квеста требует оформления по QUEST-TEMPLATE: добавить версию и статус, прописать зависимости с системами, ветвления и ссылки на целевые микросервисы и фронтенд перед постановкой API задач.\\n"
new_block = " - path: \.BRAIN/03-lore/_03-lore/timeline-author/quests/europe/rome/2020-2029/quest-006-mafia-connection.md\\n version: \0.1.0\\n status: \needs-work\\n priority: \medium\\n checked: \2025-11-09 10:11\\n checker: \Brain Manager\\n api_target:\n microservice: null\n directory: null\n frontend_module: null\n notes: \Квест про вступление в мафию необходимо структурировать по QUEST-TEMPLATE: добавить статус/версию, расписать ветки и проверки, определить зависимости с криминалом, репутацией и экономикой, а также указать целевые микросервисы, каталоги API и связанный фронтенд-модуль.\\n"
if block not in text:
    raise SystemExit('reference block not found')
if new_block in text:
    raise SystemExit('new block already present')
text = text.replace(block, block + new_block)
path.write_text(text, encoding='utf-8')
