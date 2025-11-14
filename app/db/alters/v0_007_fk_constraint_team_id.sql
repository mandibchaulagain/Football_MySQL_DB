ALTER TABLE players
ADD CONSTRAINT fk_players_team
    FOREIGN KEY (team_id) REFERENCES teams(id);
