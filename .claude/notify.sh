#!/bin/sh

# Notify Neovim on the host when Claude Code finishes.
# Each Neovim instance claims a port in 9999-10018; we fan out to all.
# NOTIFY_HOST: host running Neovim. Auto-detected if unset:
#   host.docker.internal (Docker) or host.containers.internal (Podman).

NOTIFY_PORT="${NOTIFY_PORT:-9999}"
PROJECT=$(basename "$PWD")
EVENT="${1:-stop}"
STDIN=$(cat)
NTYPE=$(printf '%s' "$STDIN" \
  | grep -o '"notification_type":"[^"]*"' \
  | sed 's/.*":"//;s/"//')
if [ -z "$NOTIFY_HOST" ]; then
  if getent hosts host.docker.internal >/dev/null 2>&1; then
    NOTIFY_HOST="host.docker.internal"
  else
    NOTIFY_HOST="host.containers.internal"
  fi
fi
BASE="http://${NOTIFY_HOST}"
port=$NOTIFY_PORT
while [ "$port" -le 10018 ]; do
  url="${BASE}:${port}/?window=${PROJECT}&event=${EVENT}&ntype=${NTYPE}"
  curl -sf --max-time 1 "$url" >/dev/null 2>&1 &
  port=$((port + 1))
done
