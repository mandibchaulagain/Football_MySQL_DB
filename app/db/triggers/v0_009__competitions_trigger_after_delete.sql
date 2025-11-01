DELIMITER //
CREATE TRIGGER trg_competitions_after_delete
AFTER DELETE ON competitions
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'competitions',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('name', OLD.name, 'type', OLD.type, 'season', OLD.season, 'governing_body_id', OLD.governing_body_id)
    );
END;
//