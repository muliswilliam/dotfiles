#!/usr/bin/env bash
# Symlinks config/* into $HOME. Any existing real file is backed up once to
# <name>.bak before being replaced; stale symlinks are just replaced.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO_DIR="$(pwd)"

link_path() {
  local src="$1" dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "==> ${dest#"$HOME"/} already linked, skipping"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    echo "==> Replacing stale symlink ${dest#"$HOME"/}"
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "==> Backing up existing ${dest#"$HOME"/} to ${dest#"$HOME"/}.bak"
    mv "$dest" "$dest.bak"
  fi

  echo "==> Linking ${dest#"$HOME"/} -> $src"
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

# Ralph loop scripts (github.com/mattpocock skills setup) - symlinked without
# the .sh suffix so they read as ordinary CLI commands on $PATH.
link_path "$REPO_DIR/bin/ralph-once.sh" "$HOME/bin/ralph-once"
link_path "$REPO_DIR/bin/afk-ralph.sh" "$HOME/bin/afk-ralph"

# config/agents.md is the cross-tool source of truth for global agent
# instructions, linked into each tool's global instructions path. Not linked to
# ~/AGENTS.md: Claude Code also reads that as project instructions for anything
# under $HOME, so it would load the same content twice.
link "agents.md" ".claude/CLAUDE.md"
link "agents.md" ".codex/AGENTS.md"
if [ -L "$HOME/AGENTS.md" ] && [ "$(readlink "$HOME/AGENTS.md")" = "$REPO_DIR/config/agents.md" ]; then
  echo "==> Removing legacy AGENTS.md link"
  rm "$HOME/AGENTS.md"
fi

# Personal Claude Code skills: each skills/<name>/ dir becomes ~/.claude/skills/<name>.
for skill in "$REPO_DIR"/skills/*/; do
  skill="${skill%/}"
  link_path "$skill" "$HOME/.claude/skills/$(basename "$skill")"
done

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

link "herdr.toml" ".config/herdr/config.toml"
if command -v herdr >/dev/null 2>&1 && herdr status server >/dev/null 2>&1; then
  echo "==> Reloading herdr config in the running server"
  herdr server reload-config || echo "==> herdr reload failed (non-fatal) - reload manually with 'herdr server reload-config'"
fi

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
