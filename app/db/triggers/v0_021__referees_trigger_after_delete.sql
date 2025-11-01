DELIMITER //
CREATE TRIGGER trg_referees_after_delete
AFTER DELETE ON referees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'referees',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('name', OLD.name, 'country', OLD.country)
    );
END;
//