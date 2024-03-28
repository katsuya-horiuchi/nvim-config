return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  config = function()
    require("nvim-tree").setup({
      filters = {
        dotfiles = false,
      },
    })
  end,
}
