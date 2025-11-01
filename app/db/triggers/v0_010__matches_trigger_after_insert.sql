DELIMITER //
CREATE TRIGGER trg_matches_after_insert
AFTER INSERT ON matches
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'matches',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('competition_id', NEW.competition_id, 'home_team_id', NEW.home_team_id, 'away_team_id', NEW.away_team_id, 'stadium_id', NEW.stadium_id, 'match_date', NEW.match_date, 'home_score', NEW.home_score, 'away_score', NEW.away_score)
    );
END;
//