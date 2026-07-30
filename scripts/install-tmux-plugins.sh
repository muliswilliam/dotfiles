#!/usr/bin/env bash
# Installs the Tmux Plugin Manager (TPM). config/tmux.conf declares the
# actual plugin list; TPM installs them on first `prefix + I` inside tmux.
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  echo "==> Cloning tmux plugin manager (tpm)"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo "==> Run 'prefix + I' inside a tmux session to install the configured plugins"
else
  echo "==> tpm already installed, skipping"
fi
