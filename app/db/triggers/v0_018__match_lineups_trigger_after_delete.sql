DELIMITER //
CREATE TRIGGER trg_match_lineups_after_delete
AFTER DELETE ON match_lineups
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'match_lineups',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('match_id', OLD.match_id, 'player_id', OLD.player_id, 'team_id', OLD.team_id, 'is_starting', OLD.is_starting, 'position', OLD.position)
    );
END;
//