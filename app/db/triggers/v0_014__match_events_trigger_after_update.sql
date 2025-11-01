DELIMITER //
CREATE TRIGGER trg_match_events_after_update
AFTER UPDATE ON match_events
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, old_data, new_data)
    VALUES (
        'match_events',
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT('match_id', OLD.match_id, 'player_id', OLD.player_id, 'event_type', OLD.event_type, 'event_time', OLD.event_time, 'details', OLD.details),
        JSON_OBJECT('match_id', NEW.match_id, 'player_id', NEW.player_id, 'event_type', NEW.event_type, 'event_time', NEW.event_time, 'details', NEW.details)
    );
END;
//