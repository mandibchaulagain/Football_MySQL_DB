DELIMITER //
CREATE TRIGGER trg_players_after_delete
AFTER DELETE ON players
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'players',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT(
          'first_name', OLD.first_name,
          'last_name', OLD.last_name,
          'birth_date', OLD.birth_date,
          'nationality', OLD.nationality,
          'position', OLD.position
        )
    );
END;
//