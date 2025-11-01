DELIMITER //
CREATE TRIGGER trg_match_events_after_insert
AFTER INSERT ON match_events
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, changed_by, new_data)
    VALUES (
        'match_events',
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT('match_id', NEW.match_id, 'player_id', NEW.player_id, 'event_type', NEW.event_type, 'event_time', NEW.event_time, 'details', NEW.details)
    );
END;
//