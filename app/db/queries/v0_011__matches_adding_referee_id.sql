ALTER TABLE matches
ADD COLUMN referee_id INT,
ADD CONSTRAINT fk_matches_referee
FOREIGN KEY (referee_id) REFERENCES referees(id)
ON DELETE CASCADE;
