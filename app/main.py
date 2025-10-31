import logging
from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from database.connection import connection_pool  # your DB connection pool

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle startup and shutdown events"""
    # Startup
    if not connection_pool:
        logger.error("Failed to initialize database connection pool!")
        raise RuntimeError("Database connection failed")
    
    logger.info("Application startup: Connection pool ready")
    yield
    
    # Shutdown
    if connection_pool:
        logger.info("Closing connection pool...")
        # connection_pool.close() 
        logger.info("Connection pool closed")

app = FastAPI(lifespan=lifespan)

@app.get("/health")
async def health_check():
    """Check database connection"""
    try:
        with connection_pool.get_connection() as conn:
            conn.ping(reconnect=True)
            return {
                "status": "healthy",
                "database": "connected",
                "pool_size": connection_pool.pool_size
            }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(
            status_code=503,
            detail={"status": "unhealthy", "error": str(e)}
        )
