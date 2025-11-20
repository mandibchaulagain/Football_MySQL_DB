# Endpoints related to teams (CRUD, listing, search)
from fastapi import APIRouter, Depends, HTTPException
from typing import List, Dict, Any
from db.connection import get_db

router = APIRouter(prefix="/teams", tags=["Teams"])



# GET /teams → all teams

@router.get("", summary="Get all teams")
def get_all_teams(cursor = Depends(get_db)) -> Dict[str, List[Dict[str, Any]]]:
    query = """
        SELECT id, name, city, founded_year, created_at, stadium_id
        FROM teams
        ORDER BY id;
    """
    cursor.execute(query)
    rows = cursor.fetchall()

    results = []
    for row in rows:
        results.append({
            "id": row["id"],
            "name": row["name"],
            "city": row["city"],
            "founded_year": row["founded_year"],
            "created_at": row["created_at"],
            "stadium_id": row["stadium_id"]
        })


    return {"teams": results}



# GET /teams/{id} → single

@router.get("/{team_id}", summary="Get a single team by ID")
def get_team_by_id(team_id: int, cursor = Depends(get_db)):
    query = """
        SELECT id, name, city, founded_year, created_at, stadium_id
        FROM teams
        WHERE id = %s;
    """
    cursor.execute(query, (team_id,))
    row = cursor.fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="Team not found")

    # Access using dictionary keys, not numeric indices
    return {
        "id": row["id"],
        "name": row["name"],
        "city": row["city"],
        "founded_year": row["founded_year"],
        "created_at": row["created_at"],
        "stadium_id": row["stadium_id"]
    }
