DELIMITER //
CREATE TRIGGER trg_stadiums_after_update
AFTER UPDATE ON stadiums
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'stadiums',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('name', OLD.name, 'city', OLD.city, 'capacity', OLD.capacity),
        JSON_OBJECT('name', NEW.name, 'city', NEW.city, 'capacity', NEW.capacity)
    );
END;
//