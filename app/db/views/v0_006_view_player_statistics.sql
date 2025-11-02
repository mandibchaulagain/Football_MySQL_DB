CREATE OR REPLACE VIEW v_player_statistics AS
SELECT
    p.id AS player_id,
    CONCAT(p.first_name, ' ', p.last_name) AS player_name,
    c.id AS competition_id,
    c.name AS competition_name,
    COUNT(DISTINCT m.id) AS matches_played,
    SUM(CASE WHEN me.event_type = 'GOAL' THEN 1 ELSE 0 END) AS total_goals,
    SUM(CASE WHEN me.event_type = 'ASSIST' THEN 1 ELSE 0 END) AS total_assists,
    SUM(CASE WHEN me.event_type = 'YELLOW_CARD' THEN 1 ELSE 0 END) AS yellow_cards,
    SUM(CASE WHEN me.event_type = 'RED_CARD' THEN 1 ELSE 0 END) AS red_cards
FROM
    players p
    LEFT JOIN match_events me ON p.id = me.player_id
    LEFT JOIN matches m ON me.match_id = m.id
    LEFT JOIN competitions c ON m.competition_id = c.id
GROUP BY
    p.id, c.id;