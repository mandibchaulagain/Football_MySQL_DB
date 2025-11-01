DELIMITER //
CREATE TRIGGER trg_stadiums_after_insert
AFTER INSERT ON stadiums
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'stadiums',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('name', NEW.name, 'city', NEW.city, 'capacity', NEW.capacity)
    );
END;
//