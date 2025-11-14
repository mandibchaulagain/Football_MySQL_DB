UPDATE players p
JOIN player_contracts pc
    ON p.id = pc.player_id
SET p.team_id = pc.team_id;