DELIMITER //
CREATE TRIGGER trg_match_lineups_after_insert
AFTER INSERT ON match_lineups
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'match_lineups',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('match_id', NEW.match_id, 'player_id', NEW.player_id, 'team_id', NEW.team_id, 'is_starting', NEW.is_starting, 'position', NEW.position)
    );
END;
//