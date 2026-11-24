import sys
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(sys.argv[1])
BACKEND = sys.argv[2]

class Handler(BaseHTTPRequestHandler):

    def respond(self, send_body=True):

        path = self.path.split("?", 1)[0]

        if path == "/api/status":
            body = json.dumps({
                "backend": BACKEND,
                "status": "ok"
            }).encode()

            etag = f'"status-{BACKEND}-v1"'
            cache_control = "max-age=60"

        elif path == "/api/cache":
            body = json.dumps({
                "cache": "demo",
                "message": "This response is cacheable"
            }).encode()

            etag = '"cache-v1"'
            cache_control = "max-age=60"

        else:
            body = json.dumps({
                "backend": BACKEND,
                "service": "running"
            }).encode()

            etag = None
            cache_control = "no-cache"

        if etag and self.headers.get("If-None-Match") == etag:
            self.send_response(304)
            self.send_header("ETag", etag)
            self.send_header("Cache-Control", cache_control)
            self.send_header("X-Backend", BACKEND)
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-Backend", BACKEND)
        self.send_header("Cache-Control", cache_control)

        if etag:
            self.send_header("ETag", etag)

        self.end_headers()

        if send_body:
            self.wfile.write(body)

    def do_GET(self):
        self.respond(True)

    def do_HEAD(self):
        self.respond(False)

    def log_message(self, format, *args):
        print(f"[Backend {BACKEND}] {format % args}")

server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)

print(f"Backend {BACKEND} running on 0.0.0.0:{PORT}")

server.serve_forever()
