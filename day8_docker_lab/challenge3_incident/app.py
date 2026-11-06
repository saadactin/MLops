import os, sys
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

# FATAL CRASH 1: The developer used 'requests' without installing it in the Dockerfile!
import requests

# FATAL CRASH 2: The developer requires an environment secret!
api_secret = os.getenv("APP_SECRET_KEY")
if not api_secret:
    print("❌ FATAL ERROR: APP_SECRET_KEY environment variable is missing!")
    sys.exit(1)

class CurrencyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        data = {
            "service": "Currency Converter Microservice",
            "status": "HEALTHY",
            "secret_configured": True
        }
        self.wfile.write(json.dumps(data).encode())

if __name__ == "__main__":
    print("🚀 Currency Service is starting on port 5000...")
    server = HTTPServer(("0.0.0.0", 5000), CurrencyHandler)
    server.serve_forever()
