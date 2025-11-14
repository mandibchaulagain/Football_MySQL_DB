DELIMITER $$

CREATE PROCEDURE simulate_fixtures()
BEGIN
    DECLARE total_teams INT;
    DECLARE half_teams INT;
    DECLARE total_rounds INT;
    DECLARE round_num INT;
    DECLARE k INT;
    DECLARE home_team_id INT;
    DECLARE away_team_id INT;
    DECLARE stadium_id INT;
    DECLARE referee_id INT;
    DECLARE r DOUBLE;
    DECLARE home_score INT;
    DECLARE away_score INT;
    DECLARE match_date DATE;

    -- clean old matches
    DELETE FROM matches;

    DROP TABLE IF EXISTS simulation_team_order;

    CREATE TABLE simulation_team_order (
        pos INT PRIMARY KEY,
        team_id INT NOT NULL
    );

    -- populate order
    SET @rn = 0;

    INSERT INTO simulation_team_order (pos, team_id)
    SELECT 
        (@rn := @rn + 1) AS pos,
        t.id
    FROM teams t
    ORDER BY t.id;

    SELECT COUNT(*) INTO total_teams FROM simulation_team_order;

    IF (total_teams % 2) <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Number of teams must be even.';
    END IF;

    SET half_teams = total_teams / 2;
    SET total_rounds = (total_teams - 1) * 2;
    SET round_num = 1;

    SET match_date = '2023-08-12';

    WHILE round_num <= total_rounds DO
        SET k = 1;

        WHILE k <= half_teams DO
            SELECT team_id INTO home_team_id 
            FROM simulation_team_order WHERE pos = k;

            SELECT team_id INTO away_team_id
            FROM simulation_team_order WHERE pos = total_teams - k + 1;

            SELECT stadium_id INTO stadium_id 
            FROM teams WHERE id = home_team_id;

            SELECT id INTO referee_id
            FROM referees ORDER BY RAND() LIMIT 1;

            SET r = RAND();

            IF r < 0.47 THEN
                SET home_score = FLOOR(1 + RAND() * 4);
                SET away_score = FLOOR(RAND() * 3);
            ELSEIF r < 0.73 THEN
                SET home_score = FLOOR(RAND() * 4);
                SET away_score = home_score;
            ELSE
                SET away_score = FLOOR(1 + RAND() * 4);
                SET home_score = FLOOR(RAND() * 3);
            END IF;

            INSERT INTO matches (
                competition_id,
                home_team_id,
                away_team_id,
                stadium_id,
                referee_id,
                match_date,
                home_score,
                away_score,
                created_at
            ) VALUES (
                1,
                home_team_id,
                away_team_id,
                stadium_id,
                referee_id,
                match_date,
                home_score,
                away_score,
                NOW()
            );

            SET k = k + 1;
        END WHILE;

        -- rotation algorithm
        UPDATE simulation_team_order
        SET pos = CASE
            WHEN pos = 1 THEN 1
            WHEN pos = 2 THEN total_teams
            ELSE pos - 1
        END;

        SET round_num = round_num + 1;
        SET match_date = DATE_ADD(match_date, INTERVAL 7 DAY);
    END WHILE;

    DROP TABLE simulation_team_order;
END $$

DELIMITER ;
