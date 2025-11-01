DELIMITER //
CREATE TRIGGER trg_referees_after_insert
AFTER INSERT ON referees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'referees',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('name', NEW.name, 'country', NEW.country)
    );
END;
//