DELIMITER //
CREATE TRIGGER trg_matches_after_delete
AFTER DELETE ON matches
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'matches',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('competition_id', OLD.competition_id, 'home_team_id', OLD.home_team_id, 'away_team_id', OLD.away_team_id, 'stadium_id', OLD.stadium_id, 'match_date', OLD.match_date, 'home_score', OLD.home_score, 'away_score', OLD.away_score)
    );
END;
//