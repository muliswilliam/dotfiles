#!/usr/bin/env bash
# Installs VS Code extensions from vscode/extensions.txt.
# `code --install-extension` is idempotent on its own: it no-ops if the
# extension is already installed at the same or newer version.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v code >/dev/null 2>&1; then
  echo "==> 'code' CLI not found on PATH. In VS Code, run 'Shell Command: Install code command in PATH' first."
  exit 1
fi

while read -r extension; do
  [ -z "$extension" ] && continue
  echo "==> Installing VS Code extension: $extension"
  code --install-extension "$extension"
done < vscode/extensions.txt

echo "==> Copying VS Code settings.json"
mkdir -p "$HOME/Library/Application Support/Code/User"
cp vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
