CREATE TABLE match_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    player_id INT,
    event_type ENUM('Goal','Yellow Card','Red Card','Substitution') NOT NULL,
    event_time INT NOT NULL,
    details VARCHAR(255),
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE SET NULL
);