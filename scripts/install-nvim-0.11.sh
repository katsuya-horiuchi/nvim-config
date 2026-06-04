#!/usr/bin/env zsh

set -e

ARCH=$(uname -m)
[[ "$ARCH" == "x86_64" ]] && ARCH="x86_64" || ARCH="arm64"

TARBALL="nvim-macos-${ARCH}.tar.gz"
URL="https://github.com/neovim/neovim/releases/download/v0.11.0/${TARBALL}"
INSTALL_DIR="$HOME/.local/nvim-0.11"

curl -LO "$URL"
tar xzf "$TARBALL"
mkdir -p "$INSTALL_DIR"
cp -r "nvim-macos-${ARCH}/"* "$INSTALL_DIR/"
rm -rf "$TARBALL" "nvim-macos-${ARCH}"

echo "Done. Add this to ~/.zshrc if not already present:"
echo "  export PATH=\"\$HOME/.local/nvim-0.11/bin:\$PATH\""
