local M = {}

-- Returns a table mapping buffer name -> width for all windows, optionally
-- excluding exclude_win (used to skip the sidebar window itself on close).
local function save_widths(exclude_win)
  local widths = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= exclude_win then
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      widths[name] = vim.api.nvim_win_get_width(win)
    end
  end
  return widths
end

-- Schedules restoration of window widths from a save_widths() snapshot.
-- Deferred so the sidebar has finished opening/closing before we resize.
local function restore_widths(widths)
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      if widths[name] then
        vim.api.nvim_win_set_width(win, widths[name])
      end
    end
  end)
end

-- Runs cmd (e.g. "NvimTreeToggle") and restores window widths afterwards.
-- winrestcmd() is not used because sidebar toggles shift window numbers,
-- causing it to apply saved sizes to the wrong windows.
function M.toggle_with_restore(cmd)
  local widths = save_widths()
  vim.cmd(cmd)
  restore_widths(widths)
end

-- Registers a WinClosed autocmd that restores window widths whenever a window
-- of the given filetype is closed (e.g. via :q). WinClosed fires while the
-- window is still valid, so widths are captured before Neovim redistributes space.
function M.restore_on_close(filetype)
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local win = tonumber(args.match)
      if not vim.api.nvim_win_is_valid(win) then return end
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= filetype then return end
      restore_widths(save_widths(win))
    end,
  })
end

return M
