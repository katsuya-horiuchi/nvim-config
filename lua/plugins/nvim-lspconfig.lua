-- Plugin for LSP

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- FOR PYLINT
    -- Check if file exists
    function does_exist(file_name)
      local f = io.open(file_name, "r")
      return f ~= nil and io.close(f)
    end

    -- Determine separator for path, for windows
    local sep = "/"
    if vim.fn.has("win32") == 1 then
      sep = "\\"
    end

    -- Use .pylintrc if there's one in the root of working directory
    local pylintrc = (vim.fn.getcwd() .. sep .. ".pylintrc")
    local pylintarg = ""
    if does_exist(pylintrc) then
      print("Using .pylintrc")
      pylintarg = ("--pylintarg=" .. pylintrc)
    end

    local lspconfig = require("lspconfig")

    lspconfig.pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            black = {
              enabled = true,
              line_length = 80,
            },
            pylint = {
              enabled = true,
              args = { pylintarg },
            },
            pyright = {
              enabled = false,
            },
            mccabe = {
              enabled = false,
            },
          },
        },
      },
    })

    -- Show list of issues in diagnostic window (?)
    function show_diagnostics()
      vim.diagnostic.setloclist()
      -- TODO: Adjust the window height here
    end

    vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, {})
    vim.keymap.set("n", "<leader>b", vim.lsp.buf.format, {})
    vim.keymap.set("n", "<leader><right>", vim.diagnostic.goto_next)
    vim.keymap.set("n", "<leader><left>", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "<leader>?", show_diagnostics)
  end,
}
