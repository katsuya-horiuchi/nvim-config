local M = {}

-- per-filetype snapshots
-- pre_open:  editor widths captured before the sidebar opened
-- pre_close: full layout (editor + sidebar) captured before the sidebar closed
local pre_open   = {}
local pre_close  = {}
local in_toggle  = {}
local sidebars   = {}  -- all registered sidebar filetypes; excluded from each other's snapshots

local function snapshot(exclude_filetype)
  local s = { editor = {}, sidebar_width = nil }
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft  = vim.bo[buf].filetype
    local w   = vim.api.nvim_win_get_width(win)
    if ft == exclude_filetype then
      s.sidebar_width = w
    elseif not sidebars[ft] then
      -- only record true editor windows; other sidebars manage themselves
      s.editor[vim.api.nvim_buf_get_name(buf)] = w
    end
  end
  return s
end

local function apply(s, sidebar_win)
  if not s then return end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local target
    if win == sidebar_win then
      target = s.sidebar_width
    else
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      target = s.editor[name]
    end
    -- Skip no-op sets: nvim-tree's preserve_window_proportions fires on any
    -- resize event and cascades into adjacent windows, even for same-width sets.
    if target and vim.api.nvim_win_get_width(win) ~= target then
      vim.api.nvim_win_set_width(win, target)
    end
  end
end

local function find_win(filetype)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == filetype then
      return win
    end
  end
end

-- opts.restore_on_open (default true): whether to restore the saved layout when
-- the sidebar opens. NvimTree needs this because its natural open width can differ
-- from the saved one, leaving editor windows at wrong proportions. Aerial opens at
-- its configured width every time, so restoring on open causes unnecessary width
-- changes that cascade through nvim-tree's preserve_window_proportions.
function M.toggle_with_restore(cmd, filetype, opts)
  opts = opts or {}
  sidebars[filetype] = true
  local sidebar_win = filetype and find_win(filetype)
  if sidebar_win then
    pre_close[filetype] = snapshot(filetype)
    pre_close[filetype].sidebar_width = vim.api.nvim_win_get_width(sidebar_win)
    in_toggle[filetype] = true
    vim.cmd(cmd)
    in_toggle[filetype] = false
    apply(pre_open[filetype], nil)
  else
    pre_open[filetype] = snapshot(nil)
    vim.cmd(cmd)
    if opts.restore_on_open ~= false then
      local s = pre_close[filetype]
      if s and next(s.editor) ~= nil then
        apply(s, find_win(filetype))
      end
    end
  end
end

-- Handles sidebar closed via :q instead of the toggle keybind.
function M.restore_on_close(filetype)
  sidebars[filetype] = true
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local win = tonumber(args.match)
      if not vim.api.nvim_win_is_valid(win) then return end
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= filetype then return end
      if in_toggle[filetype] then return end  -- toggle_with_restore handles this itself
      pre_close[filetype] = snapshot(filetype)
      pre_close[filetype].sidebar_width = vim.api.nvim_win_get_width(win)
      -- Deferred: WinClosed fires before nvim removes the window, so we wait
      -- for the close to finish before resizing the remaining windows.
      vim.schedule(function()
        apply(pre_open[filetype], nil)
      end)
    end,
  })
end

return M
