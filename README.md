# Neovim config

My neovim configuration

## Requirements

### Environment variables
* `NEORG_PATH`: Path to the default workspace for Neorg

### Install nerd font on mac
This config uses `nvim-tree` which uses nerd icons.

```bash
$ brew install font-hack-nerd-font
```
Change the font on iTerm2 by `Preferences` -> `Profiles` -> `Text` and change
`Non-ASCII Font` to it.

## LSP setup

### Where to install

LSPs that need access to the project's runtime (installed packages, compiler,
toolchain) run inside the project's devcontainer. Everything else is installed
on the host via Mason.

| Language   | Server                   | Binary                        | Where        |
|------------|--------------------------|-------------------------------|--------------|
| Python     | pylsp                    | pylsp                         | devcontainer |
| C/C++      | clangd                   | clangd                        | host         |
| Lua        | lua-language-server      | lua-language-server           | host         |
| CSS        | cssls                    | vscode-css-language-server    | host         |
| HTML       | html-lsp                 | vscode-html-language-server   | host         |
| Lua        | efm-langserver (stylua)  | efm-langserver, stylua        | host         |
| HTML       | efm-langserver           | efm-langserver                | host         |
| HTML       | emmet-language-server    | emmet-language-server         | host         |
| JSON       | jsonls                   | vscode-json-language-server   | host         |
| Jinja      | jinja-lsp                | jinja-lsp                     | host         |
| SQL        | sqls                     | sqls                          | host         |
| PostgreSQL | postgres-language-server | postgres-language-server      | host         |

### Host — install via Mason

Mason is a Neovim plugin (already included) that manages LSP server
installations independently of your system package manager. Open the UI with:

```
:Mason
```

Then install each server by name. Alternatively, run directly from the command
line:

```
:MasonInstall <language-server-name>
```

### Verifying which binary is active

`:checkhealth lsp` shows running servers and filetypes but does **not** show
which binary is resolved. To confirm the actual binary in use (e.g. Mason vs
system), run inside Neovim:

```
:lua print(vim.fn.exepath("lua-language-server"))
```

Replace the binary name with the value from the Binary column above.

### Devcontainer — add to project's Containerfile

For LSPs that need the project's runtime, install them in the project's
`Containerfile`. The Neovim config detects a `.devcontainer` directory and
routes the LSP to the container automatically.

#### Python

```dockerfile
RUN pip install "python-lsp-server[pylint]" python-lsp-black pylsp-mypy
```

To add support for another runtime-dependent LSP, install it in the project's
`Containerfile` and add a `does_devcontainer_exist()` branch in
`lua/plugins/lsp.lua`.

## Formatting

Lua files are formatted with [StyLua](https://github.com/JohnnyMorganz/StyLua)
via efm-langserver. Style is configured in `.stylua.toml`. `<leader>f`
prefers efm (stylua) over lua-ls's built-in formatter and notifies which was
used. For other filetypes, `<leader>f` uses the LSP's built-in formatter.

### Pre-commit

Install pre-commit and the hooks:

```bash
brew install pre-commit
pre-commit install
```

On each commit, stylua will format all staged Lua files automatically.
