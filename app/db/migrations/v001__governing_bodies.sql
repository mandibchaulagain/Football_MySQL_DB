CREATE TABLE governing_bodies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100),
    founded_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);