-- Plugin for LSP

-- Configuration can be checked from vim session with `:checkhealth lsp`
-- In order to override, create `.lazy.lua` at the root of project.

--- Check if module exists
-- Reference:
-- https://stackoverflow.com/questions/15429236/how-to-check-if-a-module-exists-in-lua#answer-15429998
local function load_require(module)
  local function requiref(module_)
    require(module_)
  end
  local res = pcall(requiref, module)
  if not res then
    return 1
  end
  return 0
end

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "nanotee/sqls.nvim",
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
            },
          },
        },
      },
    })

    lspconfig.lua_ls.setup({
      -- This disable "Undefined global vim" error message
      -- https://github.com/neovim/neovim/discussions/24119#discussioncomment-9137639
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if
          vim.loop.fs_stat(path .. "/.luarc.json")
          or vim.loop.fs_stat(path .. "/.luarc.jsonc")
        then
          return
        end

        client.config.settings.Lua =
          vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
          })
      end,
      settings = {
        Lua = {},
      },
    })

    -- SQL
    -- https://github.com/sqls-server/sqls
    lspconfig.sqls.setup({
      on_attach = function(client, bufnr)
        if load_require("sqls") == 0 then
          require("sqls").on_attach(client, bufnr)
        else
          print("Not using sql-language-server")
        end
      end,
    })

    --Enable (broadcasting) snippet capability for completion
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    vim.lsp.config("cssls", {
      capabilities = capabilities,
    })
    vim.lsp.enable("cssls")

    vim.lsp.config("html", {
      capabilities = capabilities,
    })
    vim.lsp.enable("html")
  end,
}
