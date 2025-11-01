DELIMITER //
CREATE TRIGGER trg_team_competition_after_insert
AFTER INSERT ON team_competition
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'team_competition',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('team_id', NEW.team_id, 'competition_id', NEW.competition_id, 'season', NEW.season)
    );
END;
//