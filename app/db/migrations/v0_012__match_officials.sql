CREATE TABLE match_officials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    referee_id INT NOT NULL,
    role ENUM('Main','Assistant 1','Assistant 2','VAR','Fourth Official') DEFAULT 'Main',
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (referee_id) REFERENCES referees(id) ON DELETE CASCADE
);