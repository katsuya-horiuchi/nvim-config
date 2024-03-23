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
-- Keymaps for plugins
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<Leader>b", ":ALEFix<CR>")
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
