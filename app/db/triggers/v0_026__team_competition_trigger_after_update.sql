DELIMITER //
CREATE TRIGGER trg_team_competition_after_update
AFTER UPDATE ON team_competition
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'team_competition',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('team_id', OLD.team_id, 'competition_id', OLD.competition_id, 'season', OLD.season),
        JSON_OBJECT('team_id', NEW.team_id, 'competition_id', NEW.competition_id, 'season', NEW.season)
    );
END;
//