from typing import Generator
from database.connection import connection_pool

def get_db_conn():
    """
    Yield a MySQL connection from your existing pool.
    Use in endpoints and CRUD functions.
    """
    conn = connection_pool.get_connection()
    try:
        yield conn
    finally:
        try:
            conn.close()
        except Exception:
            pass
