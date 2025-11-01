DELIMITER //
CREATE TRIGGER trg_player_contracts_after_insert
AFTER INSERT ON player_contracts
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'player_contracts',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('player_id', NEW.player_id, 'team_id', NEW.team_id, 'start_date', NEW.start_date, 'end_date', NEW.end_date, 'status', NEW.status, 'shirt_number', NEW.shirt_number)
    );
END;
//

