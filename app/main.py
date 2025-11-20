from fastapi import FastAPI
from api.v1.health_router import router as health_router
from api.v1.teams_router import router as teams_router

app = FastAPI(title="Football API")


app.include_router(health_router)
app.include_router(teams_router)

@app.get("/")
def root():
    return {"message": "Football API running"}
