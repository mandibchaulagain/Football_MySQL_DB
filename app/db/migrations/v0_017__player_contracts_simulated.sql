-- Clear old data
DELETE FROM player_contracts;

SET @team_count = (SELECT COUNT(*) FROM teams);
SET @players_per_team = FLOOR((SELECT COUNT(*) FROM players) / @team_count);
SET @extra_players = (SELECT COUNT(*) FROM players) % @team_count;

-- Base distribution: even allocation
INSERT INTO player_contracts (player_id, team_id, competition_id, start_date, end_date, salary, shirt_number)
SELECT 
    p.id,
    t.id AS team_id,
    1 AS competition_id,  -- Premier League
    '2023-07-01',
    '2026-06-30',
    FLOOR(50000 + (RAND() * 250000)) AS salary,
    -- Weighted random: 1–25 more common, 26–50 less common
    CASE 
        WHEN RAND() < 0.8 THEN FLOOR(1 + (RAND() * 25))
        ELSE FLOOR(26 + (RAND() * 25))
    END AS shirt_number
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

-- Handle any leftover players (distribute randomly)
INSERT INTO player_contracts (player_id, team_id, competition_id, start_date, end_date, salary, shirt_number)
SELECT 
    p.id,
    (SELECT id FROM teams ORDER BY RAND() LIMIT 1),
    1 AS competition_id,
    '2023-07-01',
    '2026-06-30',
    FLOOR(50000 + (RAND() * 250000)) AS salary,
    CASE 
        WHEN RAND() < 0.8 THEN FLOOR(1 + (RAND() * 25))
        ELSE FLOOR(26 + (RAND() * 25))
    END AS shirt_number
FROM players p
WHERE p.id NOT IN (SELECT player_id FROM player_contracts);
