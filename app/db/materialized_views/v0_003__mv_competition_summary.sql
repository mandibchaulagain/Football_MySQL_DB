DROP TABLE IF EXISTS mv_competition_summary;

CREATE TABLE mv_competition_summary (
    competition_id INT NOT NULL,
    season_year INT NOT NULL,
    total_matches INT DEFAULT 0,
    total_goals INT DEFAULT 0,
    total_yellow_cards INT DEFAULT 0,
    total_red_cards INT DEFAULT 0,
    avg_goals_per_match DECIMAL(5,2) DEFAULT 0.00,
    top_scoring_team_id INT NULL,
    last_refreshed TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (competition_id, season_year),
    CONSTRAINT fk_mv_competition_summary_comp FOREIGN KEY (competition_id) REFERENCES competitions(id),
    CONSTRAINT fk_mv_competition_summary_team FOREIGN KEY (top_scoring_team_id) REFERENCES teams(id)
);

INSERT INTO mv_competition_summary (
    competition_id, season_year,
    total_matches, total_goals,
    total_yellow_cards, total_red_cards,
    avg_goals_per_match, top_scoring_team_id
)
SELECT
    c.id AS competition_id,
    YEAR(m.match_date) AS season_year,
    COUNT(DISTINCT m.id) AS total_matches,
    SUM(CASE WHEN me.event_type = 'GOAL' THEN 1 ELSE 0 END) AS total_goals,
    SUM(CASE WHEN me.event_type = 'YELLOW_CARD' THEN 1 ELSE 0 END) AS total_yellow_cards,
    SUM(CASE WHEN me.event_type = 'RED_CARD' THEN 1 ELSE 0 END) AS total_red_cards,
    ROUND(SUM(CASE WHEN me.event_type = 'GOAL' THEN 1 ELSE 0 END) / COUNT(DISTINCT m.id), 2) AS avg_goals_per_match,
    (
        SELECT t.id
        FROM match_events me2
        JOIN matches m2 ON me2.match_id = m2.id
        JOIN teams t ON t.id = me2.team_id
        WHERE m2.competition_id = c.id
          AND YEAR(m2.match_date) = YEAR(m.match_date)
          AND me2.event_type = 'GOAL'
        GROUP BY t.id
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS top_scoring_team_id
FROM competitions c
LEFT JOIN matches m ON m.competition_id = c.id
LEFT JOIN match_events me ON me.match_id = m.id
WHERE m.match_date IS NOT NULL 
GROUP BY c.id, YEAR(m.match_date), m.match_date;

DROP EVENT IF EXISTS ev_refresh_competition_summary;

DELIMITER $$

CREATE EVENT ev_refresh_competition_summary
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
BEGIN
    TRUNCATE TABLE mv_competition_summary;

    INSERT INTO mv_competition_summary (
        competition_id, season_year,
        total_matches, total_goals,
        total_yellow_cards, total_red_cards,
        avg_goals_per_match, top_scoring_team_id
    )
    SELECT
        c.id AS competition_id,
        YEAR(m.match_date) AS season_year,
        COUNT(DISTINCT m.id) AS total_matches,
        SUM(CASE WHEN me.event_type = 'GOAL' THEN 1 ELSE 0 END) AS total_goals,
        SUM(CASE WHEN me.event_type = 'YELLOW_CARD' THEN 1 ELSE 0 END) AS total_yellow_cards,
        SUM(CASE WHEN me.event_type = 'RED_CARD' THEN 1 ELSE 0 END) AS total_red_cards,
        ROUND(SUM(CASE WHEN me.event_type = 'GOAL' THEN 1 ELSE 0 END) / COUNT(DISTINCT m.id), 2) AS avg_goals_per_match,
        (
            SELECT t.id
            FROM match_events me2
            JOIN matches m2 ON me2.match_id = m2.id
            JOIN teams t ON t.id = me2.team_id
            WHERE m2.competition_id = c.id
              AND YEAR(m2.match_date) = YEAR(m.match_date)
              AND me2.event_type = 'GOAL'
            GROUP BY t.id
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS top_scoring_team_id
    FROM competitions c
    LEFT JOIN matches m ON m.competition_id = c.id
    LEFT JOIN match_events me ON me.match_id = m.id
    WHERE m.match_date IS NOT NULL
    GROUP BY c.id, YEAR(m.match_date), m.match_date;

    INSERT INTO mv_refresh_log (view_name, refreshed_at)
    VALUES ('mv_competition_summary', NOW());
END $$

DELIMITER ;
