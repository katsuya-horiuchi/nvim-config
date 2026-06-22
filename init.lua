-- Nvim configuration

vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.opt.listchars = { tab = ">-", space = "·" }
vim.opt.list = true

-- Prevent "File exists" error when external tools (e.g. Claude Code)
-- write files atomically
vim.opt.backupcopy = "yes"

-- Disable netrw at the very start of your init.lua, for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load Lazy, the plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")

-- Keymaps
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("n", "<Leader>w", ":w<CR>")
vim.keymap.set("n", "<Leader>q", ":q<CR>")
vim.keymap.set("n", "<Space>", "za")

-- Keymaps for terminal
vim.keymap.set("n", "<Leader>1", "1gt")
vim.keymap.set("n", "<Leader>2", "2gt")
vim.keymap.set("n", "<Leader>3", "3gt")
vim.keymap.set("n", "<Leader>4", "4gt")
vim.keymap.set("n", "<Leader>5", "5gt")
vim.keymap.set("n", "<Leader>6", "6gt")
vim.keymap.set("n", "<Leader>7", "7gt")
vim.keymap.set("n", "<Leader>8", "8gt")
vim.keymap.set("n", "<Leader>9", "9gt")
vim.keymap.set("n", "<Leader>0", ":tablast")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "jj", "<C-\\><C-n>")
vim.keymap.set("t", "<C-v><Esc>", "<Esc>")

-- Keymaps for plugins

local utils = require("utils")
vim.keymap.set("n", "<F2>", function()
  utils.toggle_with_restore("NvimTreeToggle", "NvimTree")
end)
vim.keymap.set("n", "<C-W>X", ":WinShift swap<CR>")

-- <leader>b: prompt for width and set current window width
vim.keymap.set("n", "<leader>b", function()
  local input = vim.fn.input("Width: ")
  local w = tonumber(input)
  if w then
    vim.api.nvim_win_set_width(0, w)
  end
  vim.cmd("echo ''") -- clear output
end, { desc = "Set current window width" })

-- Settings by language
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "*.lua",
    "*.cpp",
    "*.h",
    "*.html",
    "*.jinja2",
    "*.js",
    "*.css",
    "*.jinja",
  },
  callback = function()
    vim.o.tabstop = 2
    vim.o.softtabstop = 2
    vim.o.shiftwidth = 2
    vim.wo.colorcolumn = "80"
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.py" },
  callback = function()
    vim.o.tabstop = 4
    vim.o.softtabstop = 4
    vim.o.shiftwidth = 4
    vim.wo.colorcolumn = "80"
  end,
})

-- Markdown folding: ufo is disabled for markdown (see utils.lua), so set
-- up native treesitter folds here. Empty foldtext makes Neovim display
-- the fold's first line with full rendering, letting render-markdown draw
-- the fold (heading icon, indent, code language icon, etc.). vim.schedule
-- defers foldtext so it wins over ufo's own BufWinEnter handler.
--
-- winhighlight remaps the built-in Folded group (gray) to Normal in
-- markdown windows only: otherwise Neovim's fold highlight overlays the
-- fold line and cuts into render-markdown's heading/code backgrounds.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("markdown.fold", {}),
  pattern = "*.md",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.winhighlight = "Folded:Normal"
    vim.schedule(function()
      vim.opt_local.foldtext = ""
    end)
  end,
})

-- For LSP
vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {})
vim.keymap.set("n", "<leader><right>", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader><left>", vim.diagnostic.goto_prev)
vim.api.nvim_create_user_command(
  "Bug",
  vim.diagnostic.setloclist,
  { desc = "Show diagnistic window" }
)
vim.api.nvim_create_user_command("Rename", function()
  vim.lsp.buf.rename()
end, { desc = "Rename variable" })
vim.api.nvim_create_user_command("Ref", function()
  vim.lsp.buf.references(nil, {
    on_list = function(list)
      vim.fn.setqflist({}, " ", list)
      vim.cmd("copen")
    end,
  })
end, { desc = "Find references" })
vim.api.nvim_create_user_command("RefBuf", function()
  vim.lsp.buf.references(nil, {
    on_list = function(list)
      local bufname = vim.api.nvim_buf_get_name(0)
      list.items = vim.tbl_filter(function(item)
        return item.filename == bufname
      end, list.items)
      vim.fn.setqflist({}, " ", list)
      vim.cmd("copen")
    end,
  })
end, { desc = "Find references in current buffer" })
vim.api.nvim_create_user_command(
  "Bash",
  ":tab term",
  { desc = "Start terminal in a new tab" }
)
vim.api.nvim_create_user_command("Template", function(opts)
  local lang = opts.args
  local file
  if lang == "python" then
    file = "python.py"
  else
    print("Template not available for the language:", lang)
    return
  end
  local path = table.concat({
    os.getenv("HOME"),
    "/.config/nvim/templates/",
    file,
  })

  local f = io.open(path, "r")
  if f ~= nil then
    local content = f:read("*a")
    vim.snippet.expand(content)
  end
end, { desc = "Copy from template", nargs = "?" })
vim.api.nvim_create_user_command("Find", function(opts)
  local input_string = opts.args
  if input_string == "" then
    return
  end
  require("telescope.builtin").grep_string({
    search = input_string,
  })
end, { desc = "Find words", nargs = "?" })

-- Claude Code notification server
--
-- Overview:
--   Claude Code runs in a devcontainer. When a task finishes (or needs
--   attention), .claude/notify.sh sends an HTTP request to the Mac host
--   via host.docker.internal. This server receives those requests and
--   fires a macOS notification.
--
-- Port allocation:
--   Each Neovim instance claims the first free port in 9999-10018.
--   notify.sh fans out to all 20 ports in parallel so every open
--   Neovim instance gets the notification.
--
-- Notification suppression:
--   $TMUX_PANE identifies the pane where this Neovim is running.
--   - In tmux, pane not active: user is in a different window;
--     always notify.
--   - In tmux, pane active: user may be looking here; suppress if
--     kitty is the frontmost macOS app.
--   - Not in tmux: no pane distinction; suppress if kitty is
--     frontmost.

local notify_sound = "Submarine" -- any name from /System/Library/Sounds/
local notify_server, notify_port
for port = 9999, 10018 do
  local srv = vim.uv.new_tcp()
  if pcall(function()
    srv:bind("127.0.0.1", port)
  end) then
    notify_server = srv
    notify_port = port
    break
  end
  srv:close()
end

if notify_server then
  notify_server:listen(128, function(err)
    if err then
      return
    end
    local client = vim.uv.new_tcp()
    notify_server:accept(client)
    client:read_start(function(_, data)
      if not data then
        client:close()
        return
      end

      -- Respond immediately so curl doesn't hang
      client:write("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")

      -- Parse ?window=<project>&event=<stop|notification>&ntype=<...>
      local project = data:match("%?window=([^%s&]+)") or ""
      local event = data:match("event=([^%s&]+)") or ""
      local ntype = data:match("ntype=([^%s&]+)") or ""
      if event ~= "stop" and event ~= "notification" then
        vim.schedule(function()
          vim.notify(
            "notify: unknown event '" .. event .. "'",
            vim.log.levels.ERROR
          )
        end)
        client:close()
        return
      end
      -- "idle_prompt" fires constantly while Claude waits for input;
      -- Only permission requests and other notification types are
      -- worth surfacing
      if event == "notification" and ntype == "idle_prompt" then
        client:close()
        return
      end

      -- Construct message for OS notification
      local status
      if event == "notification" then
        status = "needs attention"
      else
        status = "task finished"
      end
      local msg
      if project ~= "" then
        msg = project .. ": " .. status
      else
        msg = "Claude Code: " .. status
      end

      vim.schedule(function()
        -- Check if this Neovim's tmux pane is currently visible
        local tmux_pane = os.getenv("TMUX_PANE")
        local pane_active = tmux_pane
          and vim.trim(
              vim.fn.system(
                "tmux display-message -t "
                  .. tmux_pane
                  .. " -p '#{pane_active}'"
              )
            )
            == "1"
        local notify_script

        if tmux_pane and not pane_active then
          -- Different tmux window: user can't see this Neovim,
          -- skip the frontmost check and always notify
          notify_script = string.format(
            "display notification \"%s\""
              .. " with title \"Claude Code\" sound name \""
              .. notify_sound
              .. "\"",
            msg
          )
        else
          -- Not in tmux, or pane is active: suppress only
          -- if kitty is already frontmost
          notify_script = string.format(
            [[
            tell application "System Events"
              set frontApp to name of first application process whose frontmost is true
            end tell
            if frontApp is not "kitty" then
              display notification "%s" with title "Claude Code" sound name "%s"
            end if
          ]],
            msg,
            notify_sound
          )
        end

        vim.fn.jobstart({ "osascript", "-e", notify_script })
      end)
      client:close()
    end)
  end)
end
