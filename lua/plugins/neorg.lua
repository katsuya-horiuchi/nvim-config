return {
  -- Required for neorg
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "rst", "norg", "markdown", "markdown_inline", "python" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-neorg/neorg",
    lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    dependencies = {
      "nvim-neorg/tree-sitter-norg",
      "nvim-neorg/tree-sitter-norg-meta",
    },
    config = function()
      -- vim.api.nvim_set_hl(0, "@neorg.tags.ranged_verbatim.code_block", { bg = "#333354" })
      vim.api.nvim_set_hl(0, "CodeBlock", { bg = "#282854" })
      require("neorg").setup(
        {
          load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {
              config = {
                icons = {
                  code_block = {
                    content_only = true,
                    conceal = true,
                    highlight = "CodeBlock"
                  }
                }
              }
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
        }
      )

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
      vim.api.nvim_create_user_command(
        "No",
        ":Neorg index",
        { desc = "Neorg" }
      )

      vim.keymap.set("n", "<leader>tt",
        "<Plug>(neorg.qol.todo-items.todo.task-cycle)", {})
    end,
  }
}
