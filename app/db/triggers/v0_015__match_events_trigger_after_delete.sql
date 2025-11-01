DELIMITER //
CREATE TRIGGER trg_match_events_after_delete
AFTER DELETE ON match_events
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data)
    VALUES (
        'match_events',
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT('match_id', OLD.match_id, 'player_id', OLD.player_id, 'event_type', OLD.event_type, 'event_time', OLD.event_time, 'details', OLD.details)
    );
END;
//