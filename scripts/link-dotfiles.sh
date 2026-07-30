#!/usr/bin/env bash
# Symlinks config/* into $HOME. Any existing real file (not already our
# symlink) is backed up once to <name>.bak before being replaced.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO_DIR="$(pwd)"

link_path() {
  local src="$1" dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "==> ${dest#$HOME/} already linked, skipping"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ]; then
    echo "==> Backing up existing ${dest#$HOME/} to ${dest#$HOME/}.bak"
    mv "$dest" "$dest.bak"
  fi

  echo "==> Linking ${dest#$HOME/} -> $src"
  ln -s "$src" "$dest"
}

link() {
  link_path "$REPO_DIR/config/$1" "$HOME/$2"
}

link "zshrc" ".zshrc"
link "zprofile" ".zprofile"
link "tmux.conf" ".tmux.conf"
if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
  echo "==> Reloading tmux config in the running server"
  tmux source-file "$HOME/.tmux.conf" || echo "==> tmux reload failed (non-fatal) - reload manually with prefix + r"
fi
# WezTerm checks ~/.config/wezterm/wezterm.lua before the legacy ~/.wezterm.lua -
# link both so ours always wins regardless of which path a given machine resolves first.
# (WezTerm watches its config file and reloads automatically on change - no action needed.)
link "wezterm.lua" ".wezterm.lua"
link "wezterm.lua" ".config/wezterm/wezterm.lua"
link "p10k.zsh" ".p10k.zsh"
link "gitconfig" ".gitconfig"

# AGENTS.md is the cross-tool source of truth for global agent instructions
# (Claude Code, Codex CLI, Cursor, etc. all read it). ~/.claude/CLAUDE.md is
# just a symlink to it so Claude Code picks up the same content.
link "agents.md" "AGENTS.md"
link_path "$HOME/AGENTS.md" "$HOME/.claude/CLAUDE.md"

# AeroSpace errors out ("Ambiguous config error") if both ~/.aerospace.toml and
# ~/.config/aerospace/aerospace.toml exist, so - unlike WezTerm - we can't link
# both. Only ~/.config/aerospace/aerospace.toml is managed here; clear out
# anything at the legacy path first (backing up real files, just removing stale
# symlinks).
if [ -e "$HOME/.aerospace.toml" ] || [ -L "$HOME/.aerospace.toml" ]; then
  if [ -L "$HOME/.aerospace.toml" ]; then
    echo "==> Removing stale ~/.aerospace.toml symlink (legacy path - AeroSpace errors if both configs exist)"
    rm "$HOME/.aerospace.toml"
  else
    echo "==> Found ~/.aerospace.toml (legacy path - AeroSpace errors if both configs exist) - backing up to ~/.aerospace.toml.bak"
    mv "$HOME/.aerospace.toml" "$HOME/.aerospace.toml.bak"
  fi
fi
link "aerospace.toml" ".config/aerospace/aerospace.toml"

if [ ! -f "$HOME/.zshrc.local" ]; then
  echo "==> Creating ~/.zshrc.local from template (fill in your real API keys)"
  cp "$REPO_DIR/config/zshrc.local.example" "$HOME/.zshrc.local"
fi

if command -v aerospace >/dev/null 2>&1; then
  if pgrep -x AeroSpace >/dev/null 2>&1; then
    echo "==> Reloading AeroSpace config so the symlinked file takes effect now"
    aerospace reload-config || echo "==> AeroSpace reload failed (non-fatal) - reload manually or restart the app"
  else
    echo "==> Starting AeroSpace"
    open -a AeroSpace
  fi
  echo "==> AeroSpace needs Accessibility permission to move/manage windows (System Settings > Privacy & Security > Accessibility)."
  echo "    If per-app workspace rules aren't firing, check it's granted there."
fi
