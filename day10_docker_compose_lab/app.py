import os
import time
from flask import Flask
import redis

app = Flask(__name__)

REDIS_HOST = os.environ.get("REDIS_HOST", "redis-db")
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))

def get_redis():
    retries = 5
    while True:
        try:
            return redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
        except redis.exceptions.ConnectionError:
            if retries == 0:
                raise
            retries -= 1
            time.sleep(1)

r = get_redis()

@app.route("/")
def home():
    hits = r.incr("visitor_counter")
    return f"""
    <div style="font-family: Arial; padding: 30px; background: #eef2f7; border-radius: 10px;">
        <h1 style="color: #0b5ed7;">🐳 Docker Compose Multi-Tier Architecture</h1>
        <p><strong>Frontend Service:</strong> Web (Python 3.11 Flask)</p>
        <p><strong>Backend Service:</strong> Redis Database (<code>{REDIS_HOST}:{REDIS_PORT}</code>)</p>
        <hr style="border: 1px solid #ccc;"/>
        <h2 style="color: #198754;">🎉 Live Visits Count: <span style="font-size: 36px;">{hits}</span></h2>
        <p><i>Orchestrated via a single <code>docker-compose.yml</code> file!</i></p>
    </div>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

