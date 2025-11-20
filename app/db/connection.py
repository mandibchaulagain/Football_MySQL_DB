# Direct MySQL connector (no ORM), connection pooling

import mysql.connector
from mysql.connector import pooling, Error
from fastapi import HTTPException
from core.config import settings



# Create a global MySQL connection pool
try:
    connection_pool = pooling.MySQLConnectionPool(
        pool_name="main_pool",
        pool_size=10,  # Enough for dev; scalable later
        pool_reset_session=True,
        host=settings.DB_HOST,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_NAME,
        port=settings.DB_PORT,
        charset="utf8mb4"
    )
except Error as e:
    print("ERROR INITIALIZING DB POOL:", e)
    raise

# Plain connection getter
def get_connection():
    """
    Returns a pooled MySQL connection.
    """
    try:
        return connection_pool.get_connection()
    except Error:
        raise HTTPException(status_code=500, detail="DB connection unavailable")


# Dependency for FastAPI routes
def get_db():
    """
    In this function, we first get a TCP connection to the Database(through connection pooling). Then, we make a cursor object in that connection, made to return a dictionary. Cursor is a tool that is used to interact and execute query to the database(named in the sense that it works as a pointer going row by row and allows access to various methods like fetchone() and fetchall(). Then, we yield the cursor. Yield is a keyword that turns a function to a generator, and in essence, it acts as a pause button. The flow is something like this: when the interpreter hits yield, it pauses, then FastAPI injects the cursor as a Dependency Injection through Depends() function in the respective route handler and executes the route function and returns the value(where it just executed a query). Then, it comes back here, and commits the execution, and in case of error, rolls back the execution.)
    """
    conn = get_connection() #TCP link to the DB
    cursor = conn.cursor(dictionary=True)  # tool used to send commands over the connection; return rows as dicts

    try:
        yield cursor
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()
