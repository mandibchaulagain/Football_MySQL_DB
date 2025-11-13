ALTER TABLE teams
ADD COLUMN stadium_id INT,
ADD CONSTRAINT fk_stadium_id FOREIGN KEY (stadium_id) REFERENCES stadiums(id);
