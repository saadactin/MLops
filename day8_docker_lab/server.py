from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        
        response_data = {
            "status": "SUCCESS",
            "version": "2.0.0",
            "feature": "NEW PAYMENT GATEWAY & 20% DISCOUNT ADDED!",
            "message": "Hello Saad! You just upgraded to Docker v2!",
            "port": 8080
        }
        self.wfile.write(json.dumps(response_data, indent=2).encode())

if __name__ == "__main__":
    print("🚀 Microservice v2.0.0 starting on port 8080...")
    server = HTTPServer(("0.0.0.0", 8080), SimpleHandler)
    server.serve_forever()
