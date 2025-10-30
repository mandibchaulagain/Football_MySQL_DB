import os
import logging
import mysql.connector.pooling
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

class DatabaseConnectionError(Exception):
    pass

def get_db_config():
    """Load database configuration from environment variables"""
    config = {
        "host": os.getenv("DB_HOST"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "database": os.getenv("DB_NAME"),
        "pool_name": "auth_pool",
        "pool_size": int(os.getenv("DB_POOL_SIZE")),
        "autocommit": True
    }
    if None in [config['user'], config['password'], config['database']]:
        raise ValueError("Missing required database configuration in .env")
    return config

def create_connection_pool():
    """Create and test the MySQL connection pool"""
    try:
        config = get_db_config()
        pool = mysql.connector.pooling.MySQLConnectionPool(**config)
        # Test connection
        conn = pool.get_connection()
        conn.ping(reconnect=True, attempts=3, delay=5)
        conn.close()
        logger.info("Database connection pool established successfully")
        return pool
    except mysql.connector.Error as err:
        logger.error(f"Database connection failed: {err}")
        raise DatabaseConnectionError(f"Could not connect to database: {err}") from err

# Initialize connection pool
try:
    connection_pool = create_connection_pool()
except DatabaseConnectionError as e:
    logger.critical(f"Critical database error: {e}")
    connection_pool = None
