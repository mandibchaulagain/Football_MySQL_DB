DELIMITER //
CREATE TRIGGER trg_stadiums_after_delete
AFTER DELETE ON stadiums
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'stadiums',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('name', OLD.name, 'city', OLD.city, 'capacity', OLD.capacity)
    );
END;
//