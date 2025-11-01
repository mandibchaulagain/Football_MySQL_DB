DELIMITER //
CREATE TRIGGER trg_players_after_update
AFTER UPDATE ON players
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'players',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT(
          'first_name', OLD.first_name,
          'last_name', OLD.last_name,
          'birth_date', OLD.birth_date,
          'nationality', OLD.nationality,
          'position', OLD.position
        ),
        JSON_OBJECT(
          'first_name', NEW.first_name,
          'last_name', NEW.last_name,
          'birth_date', NEW.birth_date,
          'nationality', NEW.nationality,
          'position', NEW.position
        )
    );
END;
//