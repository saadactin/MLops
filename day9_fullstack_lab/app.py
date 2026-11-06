import os
import time
from flask import Flask
import redis

app = Flask(__name__)

# Connect to Redis using the CONTAINER NAME as the host!
# Notice: No hardcoded IP address! Docker's internal DNS handles "redis-db".
REDIS_HOST = os.environ.get("REDIS_HOST", "redis-db")
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))

def get_redis_connection():
    retries = 5
    while True:
        try:
            return redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(1)

r = get_redis_connection()

@app.route("/")
def hello():
    try:
        # Increment visitor count in Redis database
        count = r.incr("hits")
        return f"""
        <div style="font-family: Arial; padding: 20px; background: #f4f6f8; border-radius: 8px;">
            <h1 style="color: #0066cc;">🚀 Saad's Production Python + Database App</h1>
            <p><strong>Database Host:</strong> {REDIS_HOST}</p>
            <p><strong>Database Port:</strong> {REDIS_PORT}</p>
            <h2 style="color: #28a745;">🎉 You are visitor number: <span style="font-size: 32px;">{count}</span></h2>
            <p><i>Every time you refresh, Python sends an INCR command to the database container over Docker custom network!</i></p>
        </div>
        """
    except Exception as e:
        return f"<h1>Database Connection Error:</h1><p>{str(e)}</p>", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

