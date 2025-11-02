CREATE OR REPLACE VIEW v_team_competitions_active AS
SELECT
    tc.team_id,
    t.name AS team_name,
    tc.competition_id,
    c.name AS competition_name,
    c.season,
    g.name AS governing_body
FROM
    team_competition tc
    INNER JOIN teams t ON tc.team_id = t.id
    INNER JOIN competitions c ON tc.competition_id = c.id
    INNER JOIN governing_bodies g ON c.governing_body_id = g.id
WHERE
    c.season >= YEAR(CURDATE()) - 1; -- filter for recent/current competitions
