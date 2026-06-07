return {
  -- Required for neorg
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    commit = "90cd6580", -- Last commit that's compatible with 0.11
    build = ":TSUpdate",
    config = function()
      local ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "rst",
        "markdown",
        "markdown_inline",
        "python",
      }
      local version = vim.version()
      if version.minor >= 12 then
        local treesitter = require("nvim-treesitter")
        treesitter.setup()
        treesitter.install(ensure_installed)
        vim.api.nvim_create_autocmd("FileType", {
          pattern = ensure_installed,
          callback = function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })
      else
        require("nvim-treesitter.configs").setup({
          ensure_installed = ensure_installed,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },
  {
    "nvim-neorg/neorg",
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    dependencies = {
      "nvim-neorg/tree-sitter-norg",
      "nvim-neorg/tree-sitter-norg-meta",
    },
    config = function()
      -- vim.api.nvim_set_hl(0, "@neorg.tags.ranged_verbatim.code_block", { bg = "#333354" })
      vim.api.nvim_set_hl(0, "CodeBlock", { bg = "#282854" })
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              icons = {
                code_block = {
                  content_only = true,
                  conceal = true,
                  highlight = "CodeBlock",
                },
              },
            },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                main = "$NEORG_PATH",
              },
              default_workspace = "main",
            },
          },
        },
      })

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
      vim.api.nvim_create_user_command("No", ":Neorg index", { desc = "Neorg" })

      vim.keymap.set(
        "n",
        "<leader>tt",
        "<Plug>(neorg.qol.todo-items.todo.task-cycle)",
        {}
      )
    end,
  },
}
