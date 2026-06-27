# Claude Code notification

Sends a macOS notification when Claude Code finishes a task or needs
attention. Works in two scenarios:

- **Devcontainer on Mac** — Claude runs in Docker/Podman on the same Mac
  as Neovim.
- **SSH to Linux** — Neovim runs on a remote Linux machine accessed via
  SSH from Mac.

## Setup

### 1. Mac listener daemon

The listener is a small Python HTTP server (`mac-listener.py`) that
receives requests from Neovim and fires macOS notifications via
`osascript`. Run it as a launchd daemon so it starts at login:

```sh
cp ~/.config/nvim/.claude/com.claudecode.notifylistener.plist \
   ~/Library/LaunchAgents/
launchctl load \
   ~/Library/LaunchAgents/com.claudecode.notifylistener.plist
```

Logs go to `/tmp/claude-notify.log`. Useful commands:

```sh
launchctl list | grep claudecode        # check it is running
tail -f /tmp/claude-notify.log          # live log

# restart after editing mac-listener.py
launchctl unload ~/Library/LaunchAgents/com.claudecode.notifylistener.plist
launchctl load   ~/Library/LaunchAgents/com.claudecode.notifylistener.plist
```

The plist assumes the nvim config is at `~/.config/nvim/`. Edit
`ProgramArguments` in the plist if your path differs.

### 2. Neovim transport

On first launch after the config loads, Neovim prompts you to choose a
transport (with an OS-detected recommendation). The choice is saved to
`stdpath("data")/notify_transport` and reused on subsequent startups.

To change it later: `:NotifyTransport <tab>` — completes to
`mac-listener`, `notify-send`, or `none`.

## How it works

### Container side

`.claude/notify.sh` is called by hooks in `.claude/settings.local.json`:

- `Stop` hook: `notify.sh stop`
- `Notification` hook: `notify.sh notification`

The script fans out a fire-and-forget `curl` to all 20 ports in the
range 9999-10018:

```sh
while [ "$port" -le 10018 ]; do
  curl -sf --max-time 1 "http://${NOTIFY_HOST:-host.docker.internal}:$port/..." &
  port=$((port + 1))
done
```

`host.docker.internal` resolves to the Mac host from Docker Desktop.
For Podman on Linux, set `NOTIFY_HOST` to the container gateway IP if
`host.docker.internal` does not resolve.

Query parameters sent with each request:

| Param    | Value                                                     |
|----------|-----------------------------------------------------------|
| `window` | `$(basename "$PWD")`                                      |
| `event`  | `stop` or `notification`                                  |
| `ntype`  | `notification_type` from hook stdin (e.g. `idle_prompt`)  |

### Neovim TCP server (init.lua)

At startup each Neovim instance claims the first free port in 9999-10018.
The fan-out reaches every open instance; any one of them can fire the
notification.

When a request arrives the handler:

1. Parses `window`, `event`, and `ntype`.
2. Drops `notification` events with `ntype=idle_prompt` — Claude polls
   this constantly while waiting for input; it isn't actionable.
3. Checks suppression: if `$TMUX_PANE` reports the pane is active
   (the user is looking at this Neovim right now), skip the notification.
4. Forwards `window` and `event` to the configured transport.

### Transport: mac-listener

Neovim sends `GET /?window=<name>&event=<stop|notification>` to the Mac
listener on port 9998.

**Mac host detection:**
- On Darwin: `127.0.0.1`
- On Linux: first field of `$SSH_CONNECTION` (the SSH client IP — set by
  the SSH server and propagated by tmux's `update-environment`)

The Mac listener constructs the message and calls `osascript`:
- `stop` → `<project>: task finished`
- `notification` → `<project>: needs attention`

### Transport: notify-send

Fires a Linux desktop notification directly — no Mac in the loop. Useful
when working locally on Linux without SSH.

## Files

| File                                              | Role                         |
|---------------------------------------------------|------------------------------|
| `init.lua`                                        | TCP server + dispatch        |
| `.claude/notify.sh`                               | curl fan-out from container  |
| `.claude/mac-listener.py`                         | Mac HTTP → osascript bridge  |
| `.claude/com.claudecode.notifylistener.plist`     | launchd daemon config        |
| `.claude/settings.local.json`                     | Stop and Notification hooks  |

## Commands

| Command                      | Action                                    |
|------------------------------|-------------------------------------------|
| `:NotifyTest`                | Send a test notification (bypasses pane   |
|                              | suppression)                              |
| `:NotifyTransport <t>`       | Switch transport; `<t>` is `mac-listener`,|
|                              | `notify-send`, or `none`                  |
