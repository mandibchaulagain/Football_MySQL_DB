```markdown
# ⚽ Football Database Project (MySQL + Python)

A fully-designed end-to-end football league database system built with **MySQL 8** and **Python 3**.  
This project includes database schema, migrations, materialized views, data seeding, simulation scripts, and CSV loaders.

This README will guide you step-by-step on how to set up the project on **Windows**, including creating a virtual environment, loading data, running SQL migrations, and executing match simulation scripts.

---

# 1. Clone the Repository

```bash
git clone https://github.com/mandibchaulagain/Football_MySQL_DB.git
cd Football_MySQL_DB
````

---

# 2. Set Up Python Virtual Environment (Windows)

Open **Windows Terminal**:

```bash
python -m venv venv
```

Activate it:

```bash
.\venv\Scripts\activate
```

Now open the project in VS Code:

```bash
code .
```

Install required Python packages:

```bash
pip install -r requirements.txt
```

---

# 3. Prepare MySQL Environment

### Open **MySQL Shell**:

```bash
mysqlsh
```

Inside MySQL shell, connect:

```sql
\connect root@localhost
```

Switch to the database:

```sql
USE footballdb;
```

---

# 4. Run SQL Migrations

In VS Code, open any SQL file inside:

```
/app/db/migrations/
```

Right-click → **Copy Path**.

Then in MySQL Shell:

```sql
source [paste-your-file-path-here];
```

Repeat this for everything. Be mindful of the /alters after executing all files in /migrations

---

# 5. Load Sample CSV Data

CSV files are located here:

```
/app/db/sample_data/
```

For MySQL to import them, copy all CSVs into the official MySQL Uploads folder:

```
C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
```

Then execute each loader SQL in:

```
/app/db/load/
```

Example:

Open the file → copy full path → run:

```sql
source C:/path/to/your/Football_MySQL_DB/app/db/load/v0_players_load.sql;
```

This loads:
,,,,
* first_name
* last_name
* birth_date
* nationality
* position

And more.

---

# 6. Run Match Fixture & Event Simulations

Some tables like `match_events` and `matches` are filled through **Python simulation scripts**.

Go to:

```
/app/db/pythonScripts/
```

To run a simulation:

```bash
python generate_season.py
```

or

```bash
python generate_match_events.py
```

These scripts:

* Generate full Premier League season fixtures
* Prevent back-to-back matches
* Assign correct stadiums
* Produce realistic match results
* Generate goals, cards, substitutions, timestamps

---

# 7. Materialized Views Refresh (Optional)

Materialized views auto-refresh via MySQL scheduled events.
If needed, manually refresh by running:

```sql
CALL refresh_player_statistics_mv();
CALL refresh_team_standings_mv();
CALL refresh_competition_summary_mv();
```

---

# 8. Verify Setup

Run:

```sql
SELECT COUNT(*) FROM players;
SELECT COUNT(*) FROM teams;
SELECT COUNT(*) FROM fixtures;
SELECT COUNT(*) FROM match_events;
```

If numbers appear → setup complete.

---

# 9. Common Windows Paths (Reference)

Purpose: Path                                             

MySQL Upload Folder : `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/` 
MySQL Config Path   : `C:/ProgramData/MySQL/MySQL Server 8.0/my.ini`   
Python Virtual Env  : `./venv/`                                        
SQL Migration Dir   : `app/db/migrations/`                             

---

# 10. Features Implemented

* Full football schema (teams, players, matches, referees…)
* Contract logic with distribution to 20 teams
* Fixture generator (round-robin)
* Match simulation engine
* Match events generator
* CSV loaders for massive dataset
* Materialized views for analytics
* Automated scheduled refresh events
* Indexing and performance optimization
* Fully reproducible setup instructions