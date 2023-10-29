-- Plugin for LSP

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
          },
        },
      },
    })
  end,
}
