-- Clear old data
DELETE FROM player_contracts;

SET @team_count = (SELECT COUNT(*) FROM teams);
SET @players_per_team = FLOOR((SELECT COUNT(*) FROM players) / @team_count);
SET @extra_players = (SELECT COUNT(*) FROM players) % @team_count;

SET @player_index = 0;

-- Base distribution: each team gets the same number of players
INSERT INTO player_contracts (player_id, team_id, start_date, end_date, salary)
SELECT 
    p.id,
    t.id AS team_id,
    '2023-07-01',
    '2026-06-30',
    FLOOR(50000 + (RAND() * 250000)) AS salary
FROM (
    SELECT p.*, ROW_NUMBER() OVER (ORDER BY id) AS row_num
    FROM players p
) p
JOIN (
    SELECT t.*, ROW_NUMBER() OVER (ORDER BY id) AS row_num
    FROM teams t
) t
ON FLOOR((p.row_num - 1) / @players_per_team) + 1 = t.row_num
WHERE t.row_num <= @team_count;

-- Assign remaining players randomly to fill the difference
INSERT INTO player_contracts (player_id, team_id, start_date, end_date, salary)
SELECT 
    p.id,
    (SELECT id FROM teams ORDER BY RAND() LIMIT 1),
    '2023-07-01',
    '2026-06-30',
    FLOOR(50000 + (RAND() * 250000)) AS salary
FROM players p
WHERE p.id NOT IN (SELECT player_id FROM player_contracts);
