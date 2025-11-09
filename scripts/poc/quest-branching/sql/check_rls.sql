SET app.current_character_id = '00000000-0000-0000-0000-000000000001';
SELECT 'quest_progress' AS table, COUNT(*) AS rows FROM quest_progress;
SELECT 'player_quest_choices' AS table, COUNT(*) AS rows FROM player_quest_choices;
SELECT 'player_flags' AS table, COUNT(*) AS rows FROM player_flags;

RESET app.current_character_id;
SELECT 'quest_progress_no_param' AS table, COUNT(*) AS rows FROM quest_progress;
SELECT 'player_quest_choices_no_param' AS table, COUNT(*) AS rows FROM player_quest_choices;
SELECT 'player_flags_no_param' AS table, COUNT(*) AS rows FROM player_flags;

