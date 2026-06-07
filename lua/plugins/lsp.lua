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
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "nanotee/sqls.nvim",
      {
        dir = vim.fn.stdpath("config") .. "/submodules/devcontainers.nvim",
        dependencies = {
          { dir = vim.fn.stdpath("config") .. "/submodules/netman.nvim" }, -- optional to browser files in docker container
        },
        config = function()
          require("devcontainers").setup({
            docker_cmd = "podman",
            -- devcontainers_cli_cmd = {
            --   "devcontainer", "--docker-path", "podman"
            -- },
            log = { level = "trace" }
          })
        end
      }
    },
    config = function()
      require("mason").setup()

      local version = vim.version()

      -- Flag to check whether the new syntax should be used for LSP configuration
      local is_new = version.major == 0 and version.minor >= 11

      if not is_new then
        lspconfig = require("lspconfig")
      end

      vim.filetype.add(
        {
          extension = {
            jinja = "jinja",
            jinja2 = "jinja",
            j2 = "jinja"
          }
        }
      )

      local does_devcontainer_exist = function()
        local dir = vim.fn.getcwd() .. "/.devcontainer"
        if vim.uv.fs_stat(dir) then
          return true
        end
        return false
      end

      local pylsp_settings = {
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
      }

      local is_env_activated = function()
        local pythonpath_env = os.getenv("HOME") .. "/env/bin/python"
        local pythonpath = os.execute("which python")
        return pythonpath == pythonpath_env
      end

      --- Python
      if is_new then
        if does_devcontainer_exist() and not is_env_activated() then
          print("Using devcontainer for pylsp")
          vim.lsp.config(
            "pylsp",
            {
              cmd = require("devcontainers").lsp_cmd({ "pylsp" }),
              settings = pylsp_settings
            }
          )
        else
          vim.lsp.config("pylsp", { settings = pylsp_settings })
        end
        vim.lsp.enable("pylsp")
      else
        lspconfig.pylsp.setup({ settings = pylsp_settings })
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


      -- Enable (broadcasting) snippet capability for completion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      --- SQL
      -- https://github.com/sqls-server/sqls
      -- You must run `:lua vim.lsp.enable("sqls")` in order to activate it
      if is_new then
        vim.lsp.config("sqls", {
          capabilities = capabilities
        })
      end

      vim.lsp.config("postgres_lsp", { capabilities = capabilities })
      vim.lsp.enable("postgres_lsp")

      vim.lsp.config("cssls", {
        capabilities = capabilities,
      })
      vim.lsp.enable("cssls")

      vim.lsp.config("html", {
        filetypes = { "html", "htmldjango.jinja" },
        capabilities = capabilities,
        init_options = {
          configurationSection = { "html", "htmldjango.jinja" },
          embeddedLanguage = {
            javascript = true
          },
          provideFormatter = true,
        }
      })
      vim.lsp.enable("html")

      vim.lsp.config("jsonls",
        { capabilities = capabilities }
      )
      vim.lsp.enable("jsonls")

      vim.lsp.config("jinja_lsp",
        { capabilities = capabilities }
      )
      vim.lsp.enable("jinja_lsp")

      local emmet_config = {
        filetypes = { "html", "htmldjango.jinja" },
        cmd = { "emmet-language-server", "--stdio" },
        init_options = {
          showAbbreviationSuggestions = true,
          showExpandedAbbreviation = "always",
          showSuggestionsAsSnippets = false,
        },
      }
      vim.lsp.config("emmet-language-server", emmet_config)
      vim.lsp.enable("emmet-language-server")

      --- C/C++
      vim.lsp.enable("clangd")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            local switch = function()
              vim.lsp.buf_request(0, "clangd/switchSourceHeader",
                vim.lsp.util.make_text_document_params(), function(err, result)
                  if result then vim.cmd("edit " .. vim.uri_to_fname(result)) end
                end)
            end
            vim.keymap.set("n", "<leader>ch", switch,
              { buffer = args.buf, desc = "clangd: switch source/header" })
            vim.api.nvim_buf_create_user_command(args.buf,
              "ClangdSwitchSourceHeader", switch,
              { desc = "clangd: switch source/header" })
          end
        end,
      })
    end,
  },
  {
    "creativenull/efmls-configs-nvim",
    -- version = "v1.x.x", -- version is optional, but recommended
    config = function()
      local prettier = require("efmls-configs.formatters.prettier")
      local stylua = require("efmls-configs.formatters.stylua")
      vim.lsp.config("efm", {
        filetypes = { "html", "htmldjango.jinja", "htmldjango", "lua" },
        settings = {
          languages = {
            html = { prettier },
            lua  = { stylua },
          }
        },
        init_options = {
          documentFormatting = true,
          documentRangeFormatting = true,
        }
      })
      vim.lsp.enable("efm")

      -- For Lua, prefer efm (stylua) over lua-ls's built-in formatter so that
      -- .stylua.toml is respected. Falls back to lua-ls if efm is not running
      -- (e.g. in projects without stylua). Notifies which formatter was used.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          vim.keymap.set("n", "<leader>f", function()
            local efm = vim.lsp.get_clients({ bufnr = 0, name = "efm" })
            local use_efm = #efm > 0
            vim.lsp.buf.format({
              filter = use_efm and function(c) return c.name == "efm" end or nil,
              async = true,
            })
            vim.notify("formatter: " .. (use_efm and "efm (stylua)" or "lua-ls"))
          end, { buffer = true })
        end,
      })
    end
  },
  -- LSP for jinja
  -- FIXME: With `jinja.nvim` enabled, LSP doesn't show snippets?
  -- {
  --   "uros-5/jinja-lsp"
  -- },
  -- Syntax highlight for jinja
  {
    "HiPhish/jinja.vim"
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(5),
          ["<C-u>"] = cmp.mapping.scroll_docs(-5),
          -- ["<C-Space>"] = cmp.mapping.complete(),  -- This changes keyboard language on mac
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "luasnip" }, -- For luasnip users.
          -- { name = "orgmode" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").setup()
    end,
  },
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>xe",
        require("nvim-emmet").wrap_with_abbreviation)
    end,
  }
}
