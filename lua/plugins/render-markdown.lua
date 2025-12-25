return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("render-markdown").setup({
      heading = {
        position = "inline",
        sign = false,
        width = 'block',
        min_width = 80,
        border = true,
      },
      indent = {
        enabled = true,
        per_level = 2,
        skip_level = 1,
        skip_heading = false,
      },
    })
  end
}
