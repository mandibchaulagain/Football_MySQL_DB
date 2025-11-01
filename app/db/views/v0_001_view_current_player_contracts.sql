CREATE OR REPLACE VIEW v_player_contracts_current AS
SELECT
    p.id AS player_id,
    CONCAT(p.first_name, ' ', p.last_name) AS player_name,
    t.id AS team_id,
    t.name AS team_name,
    pc.start_date,
    pc.end_date,
    pc.status,
    pc.shirt_number
FROM
    player_contracts pc
    INNER JOIN players p ON pc.player_id = p.id
    INNER JOIN teams t ON pc.team_id = t.id
WHERE
    pc.status = 'ACTIVE'
    AND (pc.end_date IS NULL OR pc.end_date >= CURDATE());