import os
import mysql.connector
from mysql.connector import pooling

DB_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "mysql"),
    "port": int(os.getenv("MYSQL_PORT", 3306)),
    "database": os.getenv("MYSQL_DATABASE", "legalcontracts_db"),
    "user": os.getenv("MYSQL_USER", "legal_user"),
    "password": os.getenv("MYSQL_PASSWORD", "legal_password"),
}

connection_pool = pooling.MySQLConnectionPool(
    pool_name="legalcontracts_pool",
    pool_size=5,
    **DB_CONFIG,
)


def get_connection():
    return connection_pool.get_connection()
