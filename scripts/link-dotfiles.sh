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

  mkdir -p "$(dirname "$dest")"

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
if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
  echo "==> Reloading tmux config in the running server"
  tmux source-file "$HOME/.tmux.conf"
fi
# WezTerm checks ~/.config/wezterm/wezterm.lua before the legacy ~/.wezterm.lua -
# link both so ours always wins regardless of which path a given machine resolves first.
# (WezTerm watches its config file and reloads automatically on change - no action needed.)
link "wezterm.lua" ".wezterm.lua"
link "wezterm.lua" ".config/wezterm/wezterm.lua"
link "p10k.zsh" ".p10k.zsh"
link "gitconfig" ".gitconfig"

# AeroSpace checks ~/.aerospace.toml before ~/.config/aerospace/aerospace.toml -
# a leftover file there would silently shadow the one we symlink below.
if [ -e "$HOME/.aerospace.toml" ] && [ ! -L "$HOME/.aerospace.toml" ]; then
  echo "==> Found ~/.aerospace.toml (takes priority over our config) - backing up to ~/.aerospace.toml.bak"
  mv "$HOME/.aerospace.toml" "$HOME/.aerospace.toml.bak"
fi
link "aerospace.toml" ".config/aerospace/aerospace.toml"

if [ ! -f "$HOME/.zshrc.local" ]; then
  echo "==> Creating ~/.zshrc.local from template (fill in your real API keys)"
  cp "$REPO_DIR/config/zshrc.local.example" "$HOME/.zshrc.local"
fi

if command -v aerospace >/dev/null 2>&1; then
  if pgrep -x AeroSpace >/dev/null 2>&1; then
    echo "==> Reloading AeroSpace config so the symlinked file takes effect now"
    aerospace reload-config
  else
    echo "==> Starting AeroSpace"
    open -a AeroSpace
  fi
  echo "==> AeroSpace needs Accessibility permission to move/manage windows (System Settings > Privacy & Security > Accessibility)."
  echo "    If per-app workspace rules aren't firing, check it's granted there."
fi
