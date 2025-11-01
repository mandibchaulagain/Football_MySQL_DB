DELIMITER //
CREATE TRIGGER trg_team_competition_after_delete
AFTER DELETE ON team_competition
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'team_competition',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('team_id', OLD.team_id, 'competition_id', OLD.competition_id, 'season', OLD.season)
    );
END;
//