CREATE TABLE players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    position ENUM('Goalkeeper','Defender','Midfielder','Forward'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);