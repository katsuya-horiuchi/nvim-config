return {
  "nvim-neorg/neorg",
  lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release
  config = function()
    -- vim.api.nvim_set_hl(0, "@neorg.tags.ranged_verbatim.code_block", { bg = "#0d1956" })
    vim.api.nvim_set_hl(0, "CodeBlock", { bg = "#0d1956" })
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
  end,
}
