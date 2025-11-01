DELIMITER //
CREATE TRIGGER trg_referees_after_update
AFTER UPDATE ON referees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'referees',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('name', OLD.name, 'country', OLD.country),
        JSON_OBJECT('name', NEW.name, 'country', NEW.country)
    );
END;
//