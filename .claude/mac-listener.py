#!/usr/bin/env python3
"""
Mac notification listener for Claude Code.

Run this on Mac before SSH-ing to Linux:
  python3 .claude/mac-listener.py

Accepts GET /?window=<name>&event=<stop|notification>
The Mac's IP is read from $SSH_CONNECTION on Linux.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import subprocess

PORT = 9998
SOUND = "Submarine"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        q = parse_qs(urlparse(self.path).query)
        window = q.get("window", [""])[0]
        event = q.get("event", [""])[0]
        print(f"[request] window={window!r} event={event!r}")
        self.send_response(200)
        self.end_headers()
        if event == "stop":
            status = "task finished"
        elif event == "notification":
            status = "needs attention"
        else:
            print(f"[skip] unknown event {event!r}")
            return
        msg = f"{window}: {status}" if window else f"Claude Code: {status}"
        safe = msg.replace("\\", "\\\\").replace('"', '\\"')
        print(f"[notify] {msg!r}")
        result = subprocess.run(
            [
                "osascript", "-e",
                f'display notification "{safe}"'
                f' with title "Claude Code"'
                f' sound name "{SOUND}"',
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(f"[osascript error] {result.stderr.strip()}")


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Listening on 0.0.0.0:{PORT}")
    server.serve_forever()
