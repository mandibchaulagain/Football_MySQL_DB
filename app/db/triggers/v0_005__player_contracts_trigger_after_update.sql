DELIMITER //
CREATE TRIGGER trg_player_contracts_after_update
AFTER UPDATE ON player_contracts
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'player_contracts',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('player_id', OLD.player_id, 'team_id', OLD.team_id, 'start_date', OLD.start_date, 'end_date', OLD.end_date, 'status', OLD.status, 'shirt_number', OLD.shirt_number),
        JSON_OBJECT('player_id', NEW.player_id, 'team_id', NEW.team_id, 'start_date', NEW.start_date, 'end_date', NEW.end_date, 'status', NEW.status, 'shirt_number', NEW.shirt_number)
    );
END;
//