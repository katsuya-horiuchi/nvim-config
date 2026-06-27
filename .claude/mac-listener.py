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
import re
import subprocess

PORT = 9998
SOUND = "Submarine"
# Suppress notification when one of these apps is frontmost on Mac.
# Only checked for SSH requests (not localhost).
TERMINAL_APPS = {"kitty", "Terminal", "iTerm2", "Alacritty", "WezTerm"}


def terminal_is_frontmost() -> bool:
    # lsappinfo needs no Automation permission
    result = subprocess.run(
        ["lsappinfo", "front"], capture_output=True, text=True
    )
    m = re.search(r'\bname="([^"]+)"', result.stdout)
    name = m.group(1) if m else ""
    return name in TERMINAL_APPS


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        q = parse_qs(urlparse(self.path).query)
        window = q.get("window", [""])[0]
        event = q.get("event", [""])[0]
        client_ip = self.client_address[0]
        print(f"[request] window={window!r} event={event!r}"
              f" from={client_ip}")
        self.send_response(200)
        self.end_headers()
        if event == "stop":
            status = "task finished"
        elif event == "notification":
            status = "needs attention"
        else:
            print(f"[skip] unknown event {event!r}")
            return
        # For SSH requests, suppress if terminal is already frontmost
        if client_ip != "127.0.0.1" and terminal_is_frontmost():
            print("[skip] terminal is frontmost")
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
