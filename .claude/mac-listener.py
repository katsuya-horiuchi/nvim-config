#!/usr/bin/env python3
"""
Mac notification listener for Claude Code.

Run this on Mac before SSH-ing to Linux:
  python3 .claude/mac-listener.py

Neovim on Linux sends GET /?msg=<url-encoded> to port 9998.
The Mac's IP is picked up automatically from $SSH_CONNECTION.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import subprocess

PORT = 9998
SOUND = "Submarine"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        q = parse_qs(urlparse(self.path).query)
        msg = q.get("msg", [""])[0]
        self.send_response(200)
        self.end_headers()
        if msg:
            safe = msg.replace("\\", "\\\\").replace('"', '\\"')
            subprocess.run([
                "osascript", "-e",
                f'display notification "{safe}"'
                f' with title "Claude Code"'
                f' sound name "{SOUND}"',
            ])

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Listening on 0.0.0.0:{PORT}")
    server.serve_forever()
