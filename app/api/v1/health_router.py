# app/api/v1/health_router.py
from fastapi import APIRouter
from db.connection import connection_pool

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("")
def health_check():
    """
    One important lesson learned: Even when the database connection is valid and everything else is correct, the health check could report 'unavailable'. 
    This happens because some MySQL connector setups do not fully finalize a query until its result is consumed. 
    In our case, not consuming the result of 'SELECT 1' caused a minor exception to be raised silently, which led to the database being marked as 'unavailable'.
    """

    # Attempt DB connection
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1;")
        cursor.fetchone() 
        cursor.close()
        conn.close()
        db_status = "connected"
    except Exception:
        db_status = "unavailable"

    # Pool details
    try:
        pool_name = connection_pool.pool_name
        pool_size = connection_pool.pool_size
        available = connection_pool._cnx_queue.qsize()  # safe queue check
    except:
        pool_name = None
        pool_size = None
        available = None

    return {
        "status": "ok",
        "database": db_status,
        "pool": {
            "name": pool_name,
            "size": pool_size,
            "available_connections": available,
        },
    }
