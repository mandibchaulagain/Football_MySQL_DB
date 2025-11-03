DROP TABLE IF EXISTS mv_team_season_summary;

CREATE TABLE mv_team_season_summary AS
SELECT 
    competition_id,
    competition_name,
    season,
    team_id,
    team_name,
    COUNT(DISTINCT match_id) AS matches_played,
    SUM(wins) AS wins,
    SUM(draws) AS draws,
    SUM(losses) AS losses,
    SUM(goals_for) AS goals_for,
    SUM(goals_against) AS goals_against
FROM (
    SELECT
        c.id AS competition_id,
        c.name AS competition_name,
        c.season,
        t.id AS team_id,
        t.name AS team_name,
        m.id AS match_id,
        CASE WHEN (m.home_team_id = t.id AND m.home_score > m.away_score)
              OR (m.away_team_id = t.id AND m.away_score > m.home_score) THEN 1 ELSE 0 END AS wins,
        CASE WHEN m.home_score = m.away_score THEN 1 ELSE 0 END AS draws,
        CASE WHEN (m.home_team_id = t.id AND m.home_score < m.away_score)
              OR (m.away_team_id = t.id AND m.away_score < m.home_score) THEN 1 ELSE 0 END AS losses,
        CASE WHEN m.home_team_id = t.id THEN m.home_score ELSE m.away_score END AS goals_for,
        CASE WHEN m.home_team_id = t.id THEN m.away_score ELSE m.home_score END AS goals_against
    FROM matches m
    JOIN competitions c ON m.competition_id = c.id
    JOIN teams t ON t.id IN (m.home_team_id, m.away_team_id)
) AS team_data
GROUP BY competition_id, team_id, competition_name, team_name, season;

ALTER TABLE mv_team_season_summary
  ADD PRIMARY KEY (competition_id, team_id),
  ADD INDEX idx_team_name (team_name),
  ADD INDEX idx_season (season);

DROP EVENT IF EXISTS ev_refresh_team_season_summary;

DELIMITER $$

CREATE EVENT ev_refresh_team_season_summary
ON SCHEDULE EVERY 6 HOUR
DO
BEGIN

  TRUNCATE TABLE mv_team_season_summary;

  INSERT INTO mv_team_season_summary
  SELECT 
      competition_id,
      competition_name,
      season,
      team_id,
      team_name,
      COUNT(DISTINCT match_id) AS matches_played,
      SUM(wins) AS wins,
      SUM(draws) AS draws,
      SUM(losses) AS losses,
      SUM(goals_for) AS goals_for,
      SUM(goals_against) AS goals_against
  FROM (
      SELECT
          c.id AS competition_id,
          c.name AS competition_name,
          c.season,
          t.id AS team_id,
          t.name AS team_name,
          m.id AS match_id,
          CASE WHEN (m.home_team_id = t.id AND m.home_score > m.away_score)
                OR (m.away_team_id = t.id AND m.away_score > m.home_score) THEN 1 ELSE 0 END AS wins,
          CASE WHEN m.home_score = m.away_score THEN 1 ELSE 0 END AS draws,
          CASE WHEN (m.home_team_id = t.id AND m.home_score < m.away_score)
                OR (m.away_team_id = t.id AND m.away_score < m.home_score) THEN 1 ELSE 0 END AS losses,
          CASE WHEN m.home_team_id = t.id THEN m.home_score ELSE m.away_score END AS goals_for,
          CASE WHEN m.home_team_id = t.id THEN m.away_score ELSE m.home_score END AS goals_against
      FROM matches m
      JOIN competitions c ON m.competition_id = c.id
      JOIN teams t ON t.id IN (m.home_team_id, m.away_team_id)
  ) AS team_data
  GROUP BY competition_id, team_id, competition_name, team_name, season;
END$$

DELIMITER ;