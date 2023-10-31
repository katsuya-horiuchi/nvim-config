-- Plugin to change color scheme

return {
  "tanvirtin/monokai.nvim",
  priority = 1000, -- Make sure to load this before all the other start plugins
  config = function()
    vim.cmd([[colorscheme monokai]])

    -- Make background transparent
    -- Reference: https://github.com/tanvirtin/monokai.nvim/issues/13
    vim.cmd([[:hi Normal ctermbg=none guibg=none]])
  end,
}
