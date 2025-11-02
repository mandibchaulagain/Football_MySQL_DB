CREATE OR REPLACE VIEW v_team_season_summary AS
SELECT
    c.id AS competition_id,
    c.name AS competition_name,
    c.season,
    t.id AS team_id,
    t.name AS team_name,
    COUNT(m.id) AS matches_played,
    SUM(CASE WHEN (m.home_team_id = t.id AND m.home_score > m.away_score)
               OR (m.away_team_id = t.id AND m.away_score > m.home_score)
        THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN m.home_score = m.away_score THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN (m.home_team_id = t.id AND m.home_score < m.away_score)
               OR (m.away_team_id = t.id AND m.away_score < m.home_score)
        THEN 1 ELSE 0 END) AS losses,
    SUM(CASE WHEN m.home_team_id = t.id THEN m.home_score ELSE m.away_score END) AS goals_for,
    SUM(CASE WHEN m.home_team_id = t.id THEN m.away_score ELSE m.home_score END) AS goals_against
FROM
    matches m
    INNER JOIN competitions c ON m.competition_id = c.id
    INNER JOIN teams t ON t.id IN (m.home_team_id, m.away_team_id)
GROUP BY
    c.id, t.id, c.season;