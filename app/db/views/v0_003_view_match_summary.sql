CREATE OR REPLACE VIEW v_match_summary AS
SELECT
    m.id AS match_id,
    c.name AS competition,
    c.season,
    ht.name AS home_team,
    at.name AS away_team,
    m.home_score,
    m.away_score,
    s.name AS stadium,
    s.city AS stadium_city,
    r.name AS referee,
    m.match_date
FROM
    matches m
    INNER JOIN competitions c ON m.competition_id = c.id
    INNER JOIN teams ht ON m.home_team_id = ht.id
    INNER JOIN teams at ON m.away_team_id = at.id
    INNER JOIN stadiums s ON m.stadium_id = s.id
    LEFT JOIN referees r ON m.referee_id = r.id;