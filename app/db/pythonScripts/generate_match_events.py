import random
from datetime import datetime
import sys
import os
from collections import defaultdict

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
from database.connection import connection_pool


# -----------------------------------------------------------
#  Utility DB functions
# -----------------------------------------------------------

def fetch_matches():
    conn = connection_pool.get_connection()
    cur = conn.cursor(dictionary=True)

    cur.execute("""
        SELECT *
        FROM matches
        ORDER BY match_date ASC
    """)

    matches = cur.fetchall()
    cur.close()
    conn.close()
    return matches


def fetch_team_squad(team_id, match_date):
    """
    Returns all players who have an active contract for the team on match_date.
    """
    conn = connection_pool.get_connection()
    cur = conn.cursor(dictionary=True)

    cur.execute("""
        SELECT p.id AS player_id, pc.shirt_number
        FROM player_contracts pc
        JOIN players p ON pc.player_id = p.id
        WHERE pc.team_id = %s
          AND pc.start_date <= %s
          AND pc.end_date >= %s
    """, (team_id, match_date, match_date))

    players = cur.fetchall()
    cur.close()
    conn.close()
    return players


def insert_event(match_id, player_id, team_id, event_type, minute, details=None):
    conn = connection_pool.get_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO match_events (match_id, player_id, team_id, event_type, event_time, details)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (match_id, player_id, team_id, event_type, minute, details))

    conn.commit()
    cur.close()
    conn.close()


# -----------------------------------------------------------
#  Suspension tracking (memory only, resets per new simulation)
# -----------------------------------------------------------

yellow_counts = defaultdict(int)       # season cumulative yellows
suspended_until = defaultdict(int)     # player_id → match_index they can return
red_card_ban_length = 1                # simple rule: 1-match ban
yellow_card_pending_ban = {}           # player_id → ban length


# -----------------------------------------------------------
#  Helpers
# -----------------------------------------------------------

def pick_assister(team_players, scorer_id):
    """Pick an assister different from the scorer with probability ~70%."""
    if random.random() > 0.70:
        return None

    candidates = [p["player_id"] for p in team_players if p["player_id"] != scorer_id]
    return random.choice(candidates) if candidates else None


def choose_lineup(players):
    """
    Simplified:
    - Choose 11 starters
    - Remaining are potential subs
    """
    players_copy = players[:]
    random.shuffle(players_copy)

    starters = players_copy[:11]
    bench = players_copy[11:]

    return starters, bench


def is_eligible(player_id, match_idx):
    """
    A player is ineligible if:
    - Suspended due to red card
    - Suspended due to yellow accumulation ban
    """
    if player_id in suspended_until and suspended_until[player_id] >= match_idx:
        return False
    return True


# -----------------------------------------------------------
#  MAIN MATCH EVENT SIMULATION
# -----------------------------------------------------------

def simulate_events_for_match(match, match_idx):
    match_id = match["id"]
    home_id = match["home_team_id"]
    away_id = match["away_team_id"]
    home_goals = match["home_score"]
    away_goals = match["away_score"]
    match_date = match["match_date"]

    # ------- Load squads -------
    home_squad = fetch_team_squad(home_id, match_date)
    away_squad = fetch_team_squad(away_id, match_date)

    # Filter suspended players
    home_squad = [p for p in home_squad if is_eligible(p["player_id"], match_idx)]
    away_squad = [p for p in away_squad if is_eligible(p["player_id"], match_idx)]

    # Choose lineups
    home_starters, home_bench = choose_lineup(home_squad)
    away_starters, away_bench = choose_lineup(away_squad)

    # Track substitutions
    home_subs_used = 0
    away_subs_used = 0

    # EVENT MINUTE DISTRIBUTION
    events_minutes = list(range(1, 91))

    # -----------------------
    # GOALS + ASSISTS
    for _ in range(home_goals):
        scorer = random.choice(home_starters)
        minute = random.choice(events_minutes)
        insert_event(
            match_id, scorer["player_id"], home_id, "Goal", minute
        )

        assister_id = pick_assister(home_starters, scorer["player_id"])
        if assister_id:
            insert_event(
                match_id, assister_id, home_id, "Assist", minute
            )

    for _ in range(away_goals):
        scorer = random.choice(away_starters)
        minute = random.choice(events_minutes)
        insert_event(
            match_id, scorer["player_id"], away_id, "Goal", minute
        )

        assister_id = pick_assister(away_starters, scorer["player_id"])
        if assister_id:
            insert_event(
                match_id, assister_id, away_id, "Assist", minute
            )

    # -----------------------
    # CARDS
    # Red card chance = 0.12 per TEAM per match
    red_chance = 0.12

    def process_cards(starters, team_id):
        global yellow_counts, suspended_until

        for player in starters:
            pid = player["player_id"]

            # random yellow ~1–3 per team
            if random.random() < 0.05:
                minute = random.randint(1, 90)
                insert_event(match_id, pid, team_id, "Yellow Card", minute)

                yellow_counts[pid] += 1

                # two yellows => red
                if yellow_counts[pid] % 2 == 0:
                    minute += 1
                    insert_event(match_id, pid, team_id, "Red Card", minute)
                    suspended_until[pid] = match_idx + red_card_ban_length

            # direct red
            if random.random() < red_chance:
                minute = random.randint(1, 90)
                insert_event(match_id, pid, team_id, "Red Card", minute)
                suspended_until[pid] = match_idx + red_card_ban_length

            # Yellow-card accumulation suspensions
            if match_idx <= 19:
                if yellow_counts[pid] == 5:
                    suspended_until[pid] = match_idx + 1
            elif 20 <= match_idx <= 32:
                if yellow_counts[pid] == 10:
                    suspended_until[pid] = match_idx + 2

    process_cards(home_starters, home_id)
    process_cards(away_starters, away_id)

    # -----------------------
    # SUBSTITUTIONS (max 5)
    def do_substitutions(starters, bench, team_id):
        subs = 0
        random.shuffle(bench)
        random.shuffle(starters)

        for b in bench[:5]:
            if subs >= 5:
                break

            off = starters.pop(0)
            starters.append(b)

            minute = random.randint(46, 88)

            insert_event(
                match_id,
                off["player_id"],
                team_id,
                "Substitution",
                minute,
                details=f"Off → Shirt {b['shirt_number']}"
            )
            insert_event(
                match_id,
                b["player_id"],
                team_id,
                "Substitution",
                minute,
                details=f"On (replacing shirt {off['shirt_number']})"
            )

            subs += 1

    do_substitutions(home_starters, home_bench, home_id)
    do_substitutions(away_starters, away_bench, away_id)


# -----------------------------------------------------------
#  MAIN ENTRY
# -----------------------------------------------------------

def main():
    matches = fetch_matches()
    print(f"Simulating events for {len(matches)} matches...")

    for idx, match in enumerate(matches):
        simulate_events_for_match(match, idx)

    print("Match event simulation FINISHED.")


if __name__ == "__main__":
    main()
