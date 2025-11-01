DELIMITER //
CREATE TRIGGER trg_competitions_after_insert
AFTER INSERT ON competitions
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'competitions',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('name', NEW.name, 'type', NEW.type, 'season', NEW.season, 'governing_body_id', NEW.governing_body_id)
    );
END;
//