-- Plugin to change color scheme

return {
  "loctvl842/monokai-pro.nvim",
  priority = 1000, -- Make sure to load this before all the other plugins
  config = function()
    require("monokai-pro").setup({
      transparent_background = false,
      terminal_colors = true,
      devicons = true,
      styles = {
        comment = { italic = false },
        keyword = { italic = false },
        type = { italic = false },
        storageclass = { italic = false },
        structure = { italic = false },
        parameter = { italic = false },
        annotation = { italic = false },
        tag_attribute = { italic = false },
      },
      filter = "spectrum",
    })
    vim.cmd([[colorscheme monokai-pro]])
  end,
}
