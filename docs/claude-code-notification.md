# Claude Code notification

Sends a macOS notification when Claude Code finishes a task or needs
attention, while running inside a devcontainer.

## How it works

### Container side

`.claude/notify.sh` is called by hooks in `.claude/settings.local.json`:

- `Stop` hook: `notify.sh stop`
- `Notification` hook: `notify.sh notification`

The script fans out a fire-and-forget `curl` to all 20 ports in the
range 9999-10018 in parallel:

```sh
while [ "$port" -le 10018 ]; do
  curl -sf --max-time 1 "http://host.docker.internal:$port/..." &
  port=$((port + 1))
done
```

`host.docker.internal` resolves to the Mac host from Docker Desktop,
so no bind-mounts or SSH tunnels are needed.

Query parameters sent with each request:

| Param    | Value                                              |
|----------|----------------------------------------------------|
| `window` | `$(basename "$PWD")`                               |
| `event`  | `stop` or `notification`                           |
| `ntype`  | `notification_type` from hook stdin (e.g. `idle_prompt`) |

### Host side (init.lua)

At startup, each Neovim instance tries to bind to ports 9999-10018 in
order and claims the first free one. This means up to 20 Neovim
instances (e.g. across tmux windows) can each receive notifications
independently.

Because the fan-out hits every port, all open instances receive the
request. Any one of them can fire the macOS notification — it doesn't
need to be the instance "paired" with the devcontainer session.

When a request arrives, the handler:

1. Parses `window`, `event`, and `ntype` from the request URL.
2. Drops the request silently if `event` is `notification` and `ntype`
   is `idle_prompt` — Claude polls this constantly while waiting for
   input and it isn't actionable.
3. Builds the message:
   - `<project>: task finished` (Stop hook)
   - `<project>: needs attention` (Notification hook)
4. Decides whether to fire a macOS notification:
   - `$TMUX_PANE` identifies the pane where this Neovim is running.
   - **In tmux, pane not active**: user is in a different tmux window
     and can't see this Neovim — always notify.
   - **In tmux, pane active** or **not in tmux**: suppress only if
     kitty is the frontmost macOS app (checked via AppleScript).

## Files

| File                          | Role                              |
|-------------------------------|-----------------------------------|
| `init.lua`                    | TCP server + notification handler |
| `.claude/notify.sh`           | curl fan-out from container       |
| `.claude/settings.local.json` | Stop and Notification hooks       |
