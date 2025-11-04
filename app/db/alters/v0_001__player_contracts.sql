ALTER TABLE player_contracts
ADD COLUMN competition_id INT,
ADD FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE SET NULL;
