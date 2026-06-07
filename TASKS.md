# Tasks

## Fix aerial bugs
- [ ] 1. Folding with `<leader>z`, followed by `<Space>` to expand fails
- [ ] 2. Investigate using aerial's `treesitter` backend for markdown to get more
      consistent symbol depth/indentation in the aerial buffer

### Notes for bug #2

**What was fixed:**
- `<Space>` in aerial now correctly triggers aerial's fold toggle (`za` handler)
  - Root cause: global `<Space>→za` in `init.lua` uses `noremap=true`
    (default for `vim.keymap.set`), which bypasses aerial's buffer-local
    `za` handler
  - Fix 1: `keymaps = { ["<Space>"] = false }` in `aerial.setup()` prevents
    aerial from overriding Space with its own action
  - Fix 2: buffer-local `<Space>→"za"` with `remap=true` in the
    `FileType aerial` autocmd so keystrokes go through mapping resolution
    and hit aerial's handler
- `<leader>z` (fold to level) now works in aerial
  - Uses `foldmethod=expr` with
    `"indent(v:lnum)==0?0:'>'.(indent(v:lnum)/2)"` — the `>N` prefix
    forces each indented line to start its own fold, avoiding
    `foldmethod=indent`'s boundary-adjustment quirks
  - Had to hardcode divisor `2` because `shiftwidth()` in the aerial buffer
    returns 4 (global default), not 2 (aerial's actual indent step)

**What didn't work / was tried and reverted:**
- `foldmethod=expr` with `v:lua.require('aerial').foldexpr()` —
  `aerial.foldexpr()` does not exist in the `nvim-0.11` branch; broke `za`
  entirely because no folds were created
- `foldmethod=indent` — `za` worked but `foldlevel()` was inconsistent due
  to vim's boundary-adjustment: same header level (`##`) returned 1 or 2
  depending on neighboring lines; unusable for level navigation
- Buffer-local `<Space>` mapped to
  `function() vim.cmd("normal! za") end` — `normal!` bypasses all mappings
  including aerial's handler, so it hit the built-in fold toggle which
  doesn't work without proper folds
- Custom markdown fold provider for ufo (`markdown_folds`) — was solving
  the wrong problem; the issue was in the aerial buffer, not the markdown
  buffer; reverted

**Still inconsistent:**
- `indent('.')` returns inconsistent values for lines at the same heading
  level in aerial (likely due to fold markers like `▶`/`▸` shifting
  indentation on some lines)
- `<leader>z` works well in practice despite this, because most lines land
  at the correct indentation level


## Neovim 0.12 Upgrade Tasks

### Downgrade to 0.11 (to revert)

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

### Pending

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
