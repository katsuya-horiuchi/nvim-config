-- Plugin for LSP

-- Configuration can be checked from vim session with `:checkhealth lsp`
-- In order to override, create `.lazy.lua` at the root of project.

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
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
              enabled = false,
            },
            pyright = {
              enabled = false,
            },
            mccabe = {
              enabled = false,
            },
            pylsp_mypy = {
              enabled = true,
              live_mode = false,
              strict = true,
            }
          },
        },
      },
    })

    lspconfig.lua_ls.setup({})
  end,
}
