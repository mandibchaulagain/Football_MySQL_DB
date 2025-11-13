LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/referees.csv'
INTO TABLE referees
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@name, @country)
SET
  name = @name,
  country = @country,
  created_at = NOW();
