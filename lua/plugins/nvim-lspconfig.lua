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
    local version = vim.version()

    -- Flag to check whether the new syntax should be used for LSP configuration
    local is_new = version.major == 0 and version.minor >= 11

    if not is_new then
      lspconfig = require("lspconfig")
    end

    pylsp_config = {
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
    }

    --- Python
    if is_new then
      vim.lsp.config("pylsp", pylsp_config)
      vim.lsp.enable("pylsp")
    else
      lspconfig.pylsp.setup(pylsp_config)
    end

    --- Lua
    lua_ls_config = {
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
    }
    if is_new then
      vim.lsp.config("lua_ls", lua_ls_config)
      vim.lsp.enable("lua_ls")
    else
      lspconfig.lua_ls.setup(lua_ls_config)
    end

    --- SQL
    -- https://github.com/sqls-server/sqls
    local sqls_config = {
      on_attach = function(client, bufnr)
        if load_require("sqls") == 0 then
          require("sqls").on_attach(client, bufnr)
        else
          print("Not using sql-language-server")
        end
      end,
    }

    if is_new then
      vim.lsp.config("sqls", sqls_config)
      vim.lsp.enable("sqls")
    else
      lspconfig.sqls.setup(sqls_config)
    end

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
