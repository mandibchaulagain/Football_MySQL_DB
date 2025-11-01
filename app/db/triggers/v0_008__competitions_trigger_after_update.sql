DELIMITER //
CREATE TRIGGER trg_competitions_after_update
AFTER UPDATE ON competitions
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'competitions',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('name', OLD.name, 'type', OLD.type, 'season', OLD.season, 'governing_body_id', OLD.governing_body_id),
        JSON_OBJECT('name', NEW.name, 'type', NEW.type, 'season', NEW.season, 'governing_body_id', NEW.governing_body_id)
    );
END;
//