# Neovim 0.12 Upgrade Tasks

## Downgrade to 0.11 (to revert)

```sh
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-macos-arm64.tar.gz
tar xzf nvim-macos-arm64.tar.gz
mkdir -p ~/.local/nvim-0.11
cp -r nvim-macos-arm64/* ~/.local/nvim-0.11/
```

Add to `~/.zshrc` (before Homebrew):
```sh
export PATH="$HOME/.local/nvim-0.11/bin:$PATH"
```

## Pending

- [ ] Switch nvim-treesitter to `neovim-treesitter/nvim-treesitter`
  - Archived `nvim-treesitter/nvim-treesitter` master is incompatible with 0.12
  - Update config to new API: remove `require("nvim-treesitter.configs").setup()`
  - Enable highlighting via FileType autocmd + `vim.treesitter.start()`
  - Delete `~/.local/share/nvim/lazy/nvim-treesitter` and remove lock entry to force re-clone

- [ ] Fix norg treesitter parser
  - New nvim-treesitter only supports C scanners; norg uses `scanner.cc` (C++)
  - Workaround: add `tree-sitter-norg` as a lazy plugin with a build step that runs `tree-sitter build --output <parser_dir>/norg.so`
  - Or wait for neorg to ship a C scanner
  - Note: also add explicit dependencies to the neorg plugin spec (solved the issue on 0.11):
    ```lua
    dependencies = {
      "nvim-neorg/tree-sitter-norg",
      "nvim-neorg/tree-sitter-norg-meta",
    },
    ```

- [ ] Verify neorg compatibility
  - Neorg currently recommends `nvim-treesitter-legacy-api` and hasn't migrated to new API
  - Check if neorg has updated by the time of upgrade

- [ ] Verify render-markdown
  - Confirm markdown/markdown_inline parsers install correctly
  - Confirm no errors from `render-markdown/core/ui.lua`

- [ ] Remove `branch = "nvim-0.11"` from aerial.nvim once main branch supports 0.12
