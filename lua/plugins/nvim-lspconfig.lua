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

    lspconfig.lua_ls.setup({
      -- This disable "Undefined global vim" error message
      -- https://github.com/neovim/neovim/discussions/24119#discussioncomment-9137639
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
            }
          }
        })
      end,
      settings = {
        Lua = {}
      }
    })
  end,
}
