#!/usr/bin/env bash
# Installs herdr (terminal workspace manager for AI agents) via the official
# installer, if not already present. Lands in ~/.local/bin, which zshrc puts on PATH.
set -euo pipefail

if command -v herdr >/dev/null 2>&1 || [ -x "$HOME/.local/bin/herdr" ]; then
  echo "==> herdr already installed, skipping"
else
  echo "==> Installing herdr"
  curl -fsSL https://herdr.dev/install.sh | sh
fi
