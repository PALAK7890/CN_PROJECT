from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/status":
            body = json.dumps({
                "backend": "B",
                "status": "ok"
            }).encode()

            etag = '"status-B-v1"'

            if self.headers.get("If-None-Match") == etag:
                self.send_response(304)
                self.send_header("ETag", etag)
                self.send_header("Cache-Control", "max-age=60")
                self.end_headers()
                return

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("X-Backend", "B")
            self.send_header("Cache-Control", "max-age=60")
            self.send_header("ETag", etag)
            self.end_headers()
            self.wfile.write(body)

        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print("%s - %s" % (self.address_string(), format % args))

server = HTTPServer(("0.0.0.0", 3002), Handler)
print("Backend B running on port 3002")
server.serve_forever()
