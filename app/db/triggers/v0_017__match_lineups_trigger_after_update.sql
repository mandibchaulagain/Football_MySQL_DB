DELIMITER //
CREATE TRIGGER trg_match_lineups_after_update
AFTER UPDATE ON match_lineups
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'match_lineups',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('match_id', OLD.match_id, 'player_id', OLD.player_id, 'team_id', OLD.team_id, 'is_starting', OLD.is_starting, 'position', OLD.position),
        JSON_OBJECT('match_id', NEW.match_id, 'player_id', NEW.player_id, 'team_id', NEW.team_id, 'is_starting', NEW.is_starting, 'position', NEW.position)
    );
END;
//