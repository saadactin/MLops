import os
import sys
import time
import psycopg2

DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("POSTGRES_DB", "postgres")
DB_USER = os.environ.get("POSTGRES_USER", "postgres")
DB_PASS = os.environ.get("POSTGRES_PASSWORD", "secret123")

print("🚀 [STARTUP] Web Application booting...", flush=True)
print(f"📡 Attempting connection to PostgreSQL at {DB_HOST}:5432...", flush=True)

try:
    # Attempting to connect immediately upon container startup
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        connect_timeout=2
    )
    print("✅ [SUCCESS] Connected to PostgreSQL! Database is ready to accept queries.", flush=True)
    cur = conn.cursor()
    cur.execute("SELECT version();")
    db_version = cur.fetchone()[0]
    print(f"📊 PostgreSQL Version: {db_version}", flush=True)
    print("🎉 Application running in healthy state. Listening for user traffic...", flush=True)
    while True:
        time.sleep(10)
except psycopg2.OperationalError as e:
    print("\n💥 ========================================================", file=sys.stderr, flush=True)
    print("FATAL CRASH: Database connection refused on startup!", file=sys.stderr, flush=True)
    print(f"Error Details: {e}", file=sys.stderr, flush=True)
    print("========================================================\n", file=sys.stderr, flush=True)
    sys.exit(1)

