import random
from datetime import datetime, timedelta
import sys
import os

# Add the app root directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
from database.connection import connection_pool

# FETCH TEAMS
def fetch_teams():
    conn = connection_pool.get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, name, stadium_id FROM teams ORDER BY id")
    teams = cursor.fetchall()
    cursor.close()
    conn.close()
    return teams



# FIXTURE GENERATION (NO BACK TO BACK)
def generate_round_robin(teams):
    team_ids = [t["id"] for t in teams]

    if len(team_ids) % 2 == 1:
        team_ids.append(None)

    n = len(team_ids)
    half = n // 2
    rounds = []

    for _ in range(n - 1):
        pairings = []
        for i in range(half):
            t1 = team_ids[i]
            t2 = team_ids[n - 1 - i]
            if t1 and t2:
                pairings.append((t1, t2))
        rounds.append(pairings)

        team_ids = [team_ids[0]] + [team_ids[-1]] + team_ids[1:-1]

    return rounds



# SCORE SIMULATION
def simulate_score():
    """
    Returns (home, away) goals using:
    - draw chance < 26%
    - 0–0 chance ≈ 6%
    - realistic football scoring distribution
    """

    # 1. 0-0 occurs once every 16 games → 6.25%
    if random.random() < 0.0625:
        return 0, 0

    # 2. General draw probability 26%
    is_draw = random.random() < 0.26

    # Goal distribution: Poisson-like
    def get_goals():
        r = random.random()
        if r < 0.45: return random.choice([0, 1])
        if r < 0.75: return random.choice([1, 2])
        if r < 0.92: return random.choice([2, 3])
        if r < 0.98: return random.choice([3, 4])
        return random.randint(4, 6)

    if is_draw:
        g = get_goals()
        return g, g  # draw

    # Non-draw → allow one side to win
    home = get_goals()
    away = get_goals()

    # if equal, force slight adjustment
    if home == away:
        if random.random() < 0.5:
            home += 1
        else:
            away += 1

    return home, away



# INSERT MATCH INTO DB
def insert_match(competition_id, home_id, away_id, stadium_id, match_date, referee_id, home_score, away_score):
    conn = connection_pool.get_connection()
    cursor = conn.cursor()

    sql = """
        INSERT INTO matches
        (competition_id, home_team_id, away_team_id, stadium_id, match_date, home_score, away_score, referee_id)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
    """

    cursor.execute(sql, (
        competition_id,
        home_id,
        away_id,
        stadium_id,
        match_date,
        home_score,
        away_score,
        referee_id
    ))

    conn.commit()
    cursor.close()
    conn.close()



# MAIN
def main():
    competition_id = 1  # Premier League 23/24
    teams = fetch_teams()
    rounds = generate_round_robin(teams)

    # Home & away reversed for double round robin
    all_rounds = rounds + [[(b, a) for (a, b) in rnd] for rnd in rounds]

    start_date = datetime(2023, 8, 12)
    days_between_rounds = 7

    # 28 referees, repeat equally
    referees = list(range(1, 29))
    referee_index = 0

    print(f"Generating {len(all_rounds)} matchweeks...")

    for round_index, fixtures in enumerate(all_rounds):
        match_date = start_date + timedelta(days=round_index * days_between_rounds)

        for home_id, away_id in fixtures:

            # Stadium = home team stadium
            home_team = next(t for t in teams if t["id"] == home_id)
            stadium_id = home_team["stadium_id"]

            # Assign referee (cycle)
            referee_id = referees[referee_index]
            referee_index = (referee_index + 1) % len(referees)

            # Simulate score
            home_score, away_score = simulate_score()

            # Insert into DB
            insert_match(
                competition_id,
                home_id,
                away_id,
                stadium_id,
                match_date,
                referee_id,
                home_score,
                away_score
            )

        print(f"Inserted round {round_index + 1}")

    print("DONE — Fixtures with scores & referees generated!")


if __name__ == "__main__":
    main()
