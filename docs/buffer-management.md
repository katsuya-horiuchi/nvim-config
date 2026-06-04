# Buffer (window width) management

`lua/utils.lua` provides two public functions for toggling sidebars (nvim-tree,
aerial, etc.) while preserving the widths of the surrounding editor windows.

## The problem

When a sidebar opens or closes, Neovim redistributes the freed or taken columns
among the remaining windows. Without intervention this means:

- Closing a sidebar leaves editor windows at whatever width Neovim happened to
  give them, not their original widths.
- Reopening a sidebar may open at a different width than before, again
  distorting editor windows.

## State

Two snapshots are kept per sidebar filetype:

| Table | Captured when | Contains |
|---|---|---|
| `pre_open` | Just before the sidebar opens | Editor window widths with no sidebar present |
| `pre_close` | Just before the sidebar closes | Editor window widths + sidebar width, all with the sidebar present |

A snapshot maps buffer name → width for every editor window, plus an optional
`sidebar_width` field for the sidebar itself. Other sidebars are excluded from
each other's snapshots (see "Multiple sidebars" below).

## `toggle_with_restore(cmd, filetype, opts)`

Runs `cmd` to toggle the sidebar and restores widths in both directions.

**Closing (sidebar is currently open):**

1. Take a `pre_close` snapshot while the sidebar is still open.
2. Set `in_toggle[filetype] = true` to suppress the `WinClosed` autocmd
   (see "Closing via `:q`" below).
3. Run `cmd` to close the sidebar.
4. Apply `pre_open` synchronously — editor windows return to the widths they had
   before the sidebar was ever opened.

**Opening (sidebar is currently closed):**

1. Take a `pre_open` snapshot of the current editor layout.
2. Run `cmd` to open the sidebar.
3. If `opts.restore_on_open ~= false`, apply `pre_close` — restoring the sidebar
   and editor widths to what they looked like the last time the sidebar was open.
   Skipped if `pre_close.editor` is empty (sidebar was the only window when last
   closed, so its saved width would be the full screen width, which would collapse
   the editor to zero).

**Why apply is synchronous**

Width restoration happens synchronously (no `vim.schedule`) so that by the time
`toggle_with_restore` returns, windows are at their correct widths. If it were
deferred, a fast second keypress could trigger a new `pre_open = snapshot()`
before the restore ran, capturing the still-shrunken widths and ratcheting editor
windows smaller on each toggle cycle.

## `restore_on_close(filetype)`

Handles the case where the user closes a sidebar with `:q` instead of the toggle
keybind. Registers a `WinClosed` autocmd that:

1. Ignores the event if `in_toggle[filetype]` is set (meaning
   `toggle_with_restore` is already handling this close).
2. Captures `pre_close` while the window is still valid (`WinClosed` fires before
   Neovim removes the window).
3. Applies `pre_open` via `vim.schedule` — deferred here because `WinClosed`
   fires before Neovim has finished removing the window, so synchronous resizing
   of the remaining windows would conflict with Neovim's own layout update.

## Multiple sidebars

When more than one sidebar is registered (e.g. nvim-tree + aerial),
`snapshot()` excludes all known sidebar filetypes from the `editor` map (except
the one being toggled, which becomes `sidebar_width`). This means each sidebar
only manages true editor windows and never calls `nvim_win_set_width` on another
sidebar.

Without this, restoring aerial's layout would also set nvim-tree's width.
nvim-tree has a `preserve_window_proportions` option that fires a resize event
whenever its window is resized — even by the same value. That event cascades into
adjacent editor windows, causing widths to drift smaller on each toggle cycle.

## `restore_on_open` option

`toggle_with_restore` accepts an optional third argument:

```lua
utils.toggle_with_restore("AerialToggle", "aerial", { restore_on_open = false })
```

This skips width restoration when the sidebar opens.

nvim-tree needs open-direction restoration because its natural open width (its
internal default) can differ from the last saved width, which would leave editor
windows at wrong proportions.

Aerial always opens at its configured `width`, so restoration is unnecessary.
More importantly, calling `nvim_win_set_width` even as a no-op fires `WinResized`,
which triggers nvim-tree's `preserve_window_proportions` handler and cascades
into adjacent windows. Setting `restore_on_open = false` avoids the event
entirely.
