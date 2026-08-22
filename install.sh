#!/usr/bin/env bash
# One-shot dev machine setup. Every step is idempotent - re-running this
# (on this machine or a fresh one) skips anything already installed/linked.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

TOTAL_STEPS=9
step() {
  STEP_NUM=$((STEP_NUM + 1))
  echo
  echo "===== [$STEP_NUM/$TOTAL_STEPS] $1 ====="
}
STEP_NUM=0

if [ "$(uname)" != "Darwin" ]; then
  echo "This repo targets macOS only." >&2
  exit 1
fi

step "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools - a system dialog will pop up, click Install"
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  echo "==> Xcode Command Line Tools installed"
else
  echo "==> Xcode Command Line Tools already installed, skipping"
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed, skipping"
fi

step "Homebrew formulae and casks"
echo "==> Trusting third-party taps referenced by the Brewfile (AeroSpace lives outside homebrew/cask)"
brew tap nikitabobko/tap
brew trust --tap nikitabobko/tap
echo "==> --no-upgrade: install what's missing, never silently upgrade what's already there"
brew bundle install --verbose --no-upgrade --file=Brewfile

step "Node.js, nvm, pnpm/yarn"
bash scripts/install-node.sh

step "zsh, oh-my-zsh, Powerlevel10k"
bash scripts/install-shell.sh

step "tmux plugin manager"
bash scripts/install-tmux-plugins.sh

step "Claude Code CLI"
bash scripts/install-claude-code.sh

step "Claude Code plugins"
bash scripts/install-claude-plugins.sh

step "Symlinking dotfiles"
bash scripts/link-dotfiles.sh

if command -v code >/dev/null 2>&1; then
  step "VS Code extensions"
  bash scripts/install-vscode-extensions.sh
else
  step "VS Code extensions"
  echo "==> Skipping: 'code' CLI not on PATH yet (open VS Code once, then re-run scripts/install-vscode-extensions.sh)"
fi

echo
echo "===== Done ====="
echo "Open a new terminal (WezTerm) for the shell config to take effect."
echo "Fill in real secrets in ~/.zshrc.local (created from config/zshrc.local.example)."
