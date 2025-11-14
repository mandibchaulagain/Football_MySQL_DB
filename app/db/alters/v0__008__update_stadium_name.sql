UPDATE teams t
JOIN stadiums s
  ON t.city = s.city
SET t.stadium_id = s.id
WHERE t.stadium_id IS NULL;