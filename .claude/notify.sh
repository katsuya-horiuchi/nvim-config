#!/bin/sh

# Notify Neovim on the host when Claude Code finishes.
# Each Neovim instance claims a port in 9999-10018; we fan out to all.
# host.docker.internal resolves to the Mac host from container.

NOTIFY_PORT="${NOTIFY_PORT:-9999}"
PROJECT=$(basename "$PWD")
EVENT="${1:-stop}"
STDIN=$(cat)
NTYPE=$(printf '%s' "$STDIN" \
  | grep -o '"notification_type":"[^"]*"' \
  | sed 's/.*":"//;s/"//')
BASE="http://host.docker.internal"
port=$NOTIFY_PORT
while [ "$port" -le 10018 ]; do
  url="${BASE}:${port}/?window=${PROJECT}&event=${EVENT}&ntype=${NTYPE}"
  curl -sf --max-time 1 "$url" >/dev/null 2>&1 &
  port=$((port + 1))
done
