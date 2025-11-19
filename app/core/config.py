"""
Defines the application configuration using Pydantic's BaseSettings.

Each attribute represents an environment variable required by the application,
including database credentials and JWT settings. Pydantic automatically loads
these values from the .env file specified in the Config class. When a Settings
instance is created, it reads and validates these environment variables from
the current working directory and makes them accessible through the `settings`
object.
"""

from pydantic import BaseSettings

class Settings(BaseSettings):
    DB_HOST: str
    DB_PORT: int
    DB_USER: str
    DB_PASSWORD: str
    DB_NAME: str

    JWT_SECRET: str
    JWT_ALGORITHM: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    REFRESH_TOKEN_EXPIRE_DAYS: int

    class Config:
        env_file = ".env"

settings = Settings()
