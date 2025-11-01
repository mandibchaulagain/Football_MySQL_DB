DELIMITER //
CREATE TRIGGER trg_player_contracts_after_delete
AFTER DELETE ON player_contracts
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'player_contracts',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('player_id', OLD.player_id, 'team_id', OLD.team_id, 'start_date', OLD.start_date, 'end_date', OLD.end_date, 'status', OLD.status, 'shirt_number', OLD.shirt_number)
    );
END;
//
