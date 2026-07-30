#!/usr/bin/env bash
# Symlinks config/* into $HOME. Any existing real file (not already our
# symlink) is backed up once to <name>.bak before being replaced.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO_DIR="$(pwd)"

link() {
  local src="$REPO_DIR/config/$1" dest="$HOME/$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "==> ~/$2 already linked, skipping"
    return
  fi

  if [ -e "$dest" ]; then
    echo "==> Backing up existing ~/$2 to ~/$2.bak"
    mv "$dest" "$dest.bak"
  fi

  echo "==> Linking ~/$2 -> config/$1"
  ln -s "$src" "$dest"
}

link "zshrc" ".zshrc"
link "zprofile" ".zprofile"
link "tmux.conf" ".tmux.conf"
link "wezterm.lua" ".wezterm.lua"
link "p10k.zsh" ".p10k.zsh"
link "gitconfig" ".gitconfig"

if [ ! -f "$HOME/.zshrc.local" ]; then
  echo "==> Creating ~/.zshrc.local from template (fill in your real API keys)"
  cp "$REPO_DIR/config/zshrc.local.example" "$HOME/.zshrc.local"
fi
