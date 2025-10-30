CREATE TABLE competitions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('League', 'Cup', 'Friendly') DEFAULT 'League',
    season VARCHAR(20),
    governing_body_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (governing_body_id) REFERENCES governing_bodies(id) ON DELETE SET NULL
);