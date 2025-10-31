CREATE TABLE player_contracts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    shirt_number INT,
    status ENUM('Active','Loan','Ended') DEFAULT 'Active',
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);