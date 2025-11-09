-- SAMPLE QUEST INSERT
INSERT INTO quests (id, name, description, type, min_level, has_branches, era, objectives)
VALUES ('POC-QUEST-001', 'PoC Quest', 'Verification quest', 'SIDE', 1, true, '2020-2030', '[]')
ON CONFLICT (id) DO NOTHING;

INSERT INTO quest_branches (quest_id, branch_id, branch_name)
VALUES ('POC-QUEST-001', 'pathA', 'Test Path A')
ON CONFLICT (quest_id, branch_id) DO NOTHING;

INSERT INTO quest_progress (character_id, quest_id, status, progress, current_node_id, started_at)
VALUES ('00000000-0000-0000-0000-000000000001', 'POC-QUEST-001', 'COMPLETED', 100, NULL, NOW())
ON CONFLICT (character_id, quest_id) DO UPDATE SET status = 'COMPLETED', progress = 100, updated_at = NOW();

