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

## LSP setup by language

### Python
From an environment that you're working on:
```
$ pip install "python-lsp-server[pylint]" python-lsp-black pylsp-mypy
```
