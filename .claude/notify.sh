#!/bin/sh

# Notify Neovim on the host when Claude Code finishes.
# Each Neovim instance claims a port in 9999-10018; we fan out to all.
# NOTIFY_HOST: host running Neovim (default: host.containers.internal).
#   For Docker Desktop, set NOTIFY_HOST=host.docker.internal.

NOTIFY_PORT="${NOTIFY_PORT:-9999}"
PROJECT=$(basename "$PWD")
EVENT="${1:-stop}"
STDIN=$(cat)
NTYPE=$(printf '%s' "$STDIN" \
  | grep -o '"notification_type":"[^"]*"' \
  | sed 's/.*":"//;s/"//')
BASE="http://${NOTIFY_HOST:-host.containers.internal}"
LOG="$PWD/notify-debug.log"
echo "--- $(date) ---" >> "$LOG"
echo "event=$EVENT project=$PROJECT ntype=$NTYPE" >> "$LOG"
echo "base=$BASE" >> "$LOG"
echo "curl=$(command -v curl)" >> "$LOG"
# Only probe port 9999 to keep the log short
url="${BASE}:9999/?window=${PROJECT}&event=${EVENT}&ntype=${NTYPE}"
echo "url=$url" >> "$LOG"
curl -v --max-time 2 "$url" >> "$LOG" 2>&1
echo "exit=$?" >> "$LOG"
