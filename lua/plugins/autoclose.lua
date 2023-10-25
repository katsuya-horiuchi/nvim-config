-- Plugin to add closing quote/bracket automatically

return {
  "m4xshen/autoclose.nvim",
  config = function()
    require("autoclose").setup({
      options = {
        disabled_filetypes = { "text", "markdown" },
        disable_command_mode = true,
      },
    })
  end,
}
