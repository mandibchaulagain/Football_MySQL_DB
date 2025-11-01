DELIMITER //
CREATE TRIGGER trg_players_after_insert
AFTER INSERT ON players
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'players',
        NEW.id,
        'INSERT',
        USER(),
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