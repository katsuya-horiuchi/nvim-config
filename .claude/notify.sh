#!/bin/sh

# Notify Neovim on the host when Claude Code finishes.
# Each Neovim instance claims a port in 9999-10018; we fan out to all.
# NOTIFY_HOST: host running Neovim (default: host.docker.internal).
#   On Linux with Podman, set to the container gateway IP if needed.

NOTIFY_PORT="${NOTIFY_PORT:-9999}"
PROJECT=$(basename "$PWD")
EVENT="${1:-stop}"
STDIN=$(cat)
NTYPE=$(printf '%s' "$STDIN" \
  | grep -o '"notification_type":"[^"]*"' \
  | sed 's/.*":"//;s/"//')
BASE="http://${NOTIFY_HOST:-host.docker.internal}"
port=$NOTIFY_PORT
while [ "$port" -le 10018 ]; do
  url="${BASE}:${port}/?window=${PROJECT}&event=${EVENT}&ntype=${NTYPE}"
  curl -sf --max-time 1 "$url" >/dev/null 2>&1 &
  port=$((port + 1))
done
