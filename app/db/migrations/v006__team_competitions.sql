CREATE TABLE team_competition (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL,
    competition_id INT NOT NULL,
    season VARCHAR(20),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE
);