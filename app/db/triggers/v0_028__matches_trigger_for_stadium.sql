DELIMITER $$

CREATE TRIGGER set_stadium_before_insert
BEFORE INSERT ON matches
FOR EACH ROW
BEGIN
    -- Ensure that the home team's stadium is set as the stadium for the match
    SET NEW.stadium_id = (SELECT stadium_id FROM teams WHERE id = NEW.home_team_id);
END $$

DELIMITER ;
