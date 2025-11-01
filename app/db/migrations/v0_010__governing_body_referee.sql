CREATE TABLE governing_body_referee (
    id INT AUTO_INCREMENT PRIMARY KEY,
    governing_body_id INT NOT NULL,
    referee_id INT NOT NULL,
    FOREIGN KEY (governing_body_id) REFERENCES governing_bodies(id) ON DELETE CASCADE,
    FOREIGN KEY (referee_id) REFERENCES referees(id) ON DELETE CASCADE
);