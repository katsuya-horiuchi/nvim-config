-- Nvim configuration

vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.opt.listchars = { tab = ">-", space = "·" }
vim.opt.list = true

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

-- Keymaps for plugins
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-W>X", ":WinShift swap<CR>")

-- Settings by language
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.lua", "*.cpp", "*.h", "*.html", "*.jinja2", "*.js", "*.css" },
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
vim.api.nvim_create_user_command(
  "Bash",
  ":tab term",
  { desc = "Start terminal in a new tab" }
)
