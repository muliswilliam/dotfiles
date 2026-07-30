#!/usr/bin/env bash
# Installs nvm (if missing), an LTS Node, and enables pnpm/yarn via Corepack.
# Safe to re-run: every step here checks state before acting.
set -euo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [ ! -d "$NVM_DIR" ]; then
  echo "==> Installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
else
  echo "==> nvm already installed, skipping"
fi

# shellcheck disable=SC1090
export NVM_DIR
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! nvm ls --lts >/dev/null 2>&1 || [ -z "$(nvm ls --lts 2>/dev/null | grep -v 'N/A')" ]; then
  echo "==> Installing latest Node LTS"
  nvm install --lts
else
  echo "==> Node LTS already installed, skipping"
fi
nvm alias default lts/*

echo "==> Enabling Corepack (pnpm, yarn)"
corepack enable
corepack prepare pnpm@latest --activate
