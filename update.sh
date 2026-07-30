#!/usr/bin/env bash
# Pulls the latest dotfiles and applies them on this machine.
# Safe to run any time: install.sh is fully idempotent, so this only
# touches whatever actually changed upstream (new Brewfile entries, new
# scripts, edited configs).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "==> Pulling latest dotfiles"
git pull --ff-only

echo "==> Re-applying (idempotent - only new/changed things actually do anything)"
./install.sh
