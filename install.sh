#!/usr/bin/env bash
# One-shot dev machine setup. Every step is idempotent - re-running this
# (on this machine or a fresh one) skips anything already installed/linked.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$(uname)" != "Darwin" ]; then
  echo "This repo targets macOS only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed, skipping"
fi

echo "==> Installing Homebrew formulae and casks (brew bundle skips anything already installed)"
brew bundle install --file=Brewfile

bash scripts/install-node.sh
bash scripts/install-shell.sh
bash scripts/install-tmux-plugins.sh
bash scripts/install-claude-code.sh
bash scripts/link-dotfiles.sh

if command -v code >/dev/null 2>&1; then
  bash scripts/install-vscode-extensions.sh
else
  echo "==> Skipping VS Code extensions: 'code' CLI not on PATH yet (open VS Code once, then re-run scripts/install-vscode-extensions.sh)"
fi

echo
echo "Done. Open a new terminal (WezTerm) for the shell config to take effect."
echo "Fill in real secrets in ~/.zshrc.local (created from config/zshrc.local.example)."
