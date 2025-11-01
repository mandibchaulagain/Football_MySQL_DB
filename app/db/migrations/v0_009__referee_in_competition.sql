CREATE TABLE referee_in_competition (
    id INT AUTO_INCREMENT PRIMARY KEY,
    referee_id INT NOT NULL,
    competition_id INT NOT NULL,
    FOREIGN KEY (referee_id) REFERENCES referees(id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE
);