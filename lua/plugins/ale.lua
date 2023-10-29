-- Lint engine for languages that don't really require LSP

return {
  "dense-analysis/ale",
  config = function()
    vim.g["ale_fixers"] = { lua = "stylua" }
    vim.g["ale_lua_stylua_options"] = "--indent-type Spaces --indent-width 2"
  end,
}
