CREATE OR REPLACE VIEW v_player_match_events AS
SELECT
    me.id AS event_id,
    me.match_id,
    m.match_date,
    c.name AS competition,
    p.id AS player_id,
    CONCAT(p.first_name, ' ', p.last_name) AS player_name,
    me.event_type,
    me.event_time,
    me.details,
    CASE
        WHEN me.event_type = 'GOAL' THEN 1
        ELSE 0
    END AS goals,
    CASE
        WHEN me.event_type = 'YELLOW_CARD' THEN 1
        ELSE 0
    END AS yellow_cards,
    CASE
        WHEN me.event_type = 'RED_CARD' THEN 1
        ELSE 0
    END AS red_cards
FROM
    match_events me
    INNER JOIN matches m ON me.match_id = m.id
    INNER JOIN competitions c ON m.competition_id = c.id
    INNER JOIN players p ON me.player_id = p.id;