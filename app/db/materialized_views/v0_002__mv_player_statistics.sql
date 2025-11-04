DROP TABLE IF EXISTS mv_player_statistics;
DROP EVENT IF EXISTS ev_refresh_player_statistics;

CREATE TABLE mv_player_statistics AS
SELECT 
    p.id AS player_id,
    CONCAT(p.first_name, ' ', p.last_name) AS player_name,
    t.id AS team_id,
    t.name AS team_name,
    c.id AS competition_id,
    c.name AS competition_name,
    c.season AS season,

    COUNT(DISTINCT m.id) AS matches_played,
    SUM(CASE WHEN e.event_type = 'goal' THEN 1 ELSE 0 END) AS goals,
    SUM(CASE WHEN e.event_type = 'assist' THEN 1 ELSE 0 END) AS assists,
    SUM(CASE WHEN e.event_type = 'yellow_card' THEN 1 ELSE 0 END) AS yellow_cards,
    SUM(CASE WHEN e.event_type = 'red_card' THEN 1 ELSE 0 END) AS red_cards

FROM players p
JOIN player_contracts pc ON pc.player_id = p.id
JOIN teams t ON pc.team_id = t.id
JOIN competitions c ON pc.competition_id = c.id
LEFT JOIN matches m ON m.competition_id = c.id
LEFT JOIN match_events e ON e.match_id = m.id AND e.player_id = p.id

GROUP BY 
    p.id, player_name, t.id, t.name, c.id, c.name, c.season;

ALTER TABLE mv_player_statistics
  ADD PRIMARY KEY (player_id, competition_id, season),
  ADD INDEX idx_player_name (player_name),
  ADD INDEX idx_team (team_name),
  ADD INDEX idx_competition (competition_name);

DELIMITER $$

CREATE EVENT ev_refresh_player_statistics
ON SCHEDULE EVERY 6 HOUR
DO
BEGIN
  TRUNCATE TABLE mv_player_statistics;

  INSERT INTO mv_player_statistics
  SELECT 
      p.id AS player_id,
      CONCAT(p.first_name, ' ', p.last_name) AS player_name,
      t.id AS team_id,
      t.name AS team_name,
      c.id AS competition_id,
      c.name AS competition_name,
      c.season AS season,

      COUNT(DISTINCT m.id) AS matches_played,
      SUM(CASE WHEN e.event_type = 'goal' THEN 1 ELSE 0 END) AS goals,
      SUM(CASE WHEN e.event_type = 'assist' THEN 1 ELSE 0 END) AS assists,
      SUM(CASE WHEN e.event_type = 'yellow_card' THEN 1 ELSE 0 END) AS yellow_cards,
      SUM(CASE WHEN e.event_type = 'red_card' THEN 1 ELSE 0 END) AS red_cards

  FROM players p
  JOIN player_contracts pc ON pc.player_id = p.id
  JOIN teams t ON pc.team_id = t.id
  JOIN competitions c ON pc.competition_id = c.id
  LEFT JOIN matches m ON m.competition_id = c.id
  LEFT JOIN match_events e ON e.match_id = m.id AND e.player_id = p.id

  GROUP BY 
      p.id, player_name, t.id, t.name, c.id, c.name, c.season;
END$$

DELIMITER ;
