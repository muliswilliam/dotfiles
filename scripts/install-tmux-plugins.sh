#!/usr/bin/env bash
# Installs the Tmux Plugin Manager (TPM) and the plugins config/tmux.conf
# declares (theme, resurrect, continuum, vim-tmux-navigator, ...).
# Without actually running the plugins, tmux falls back to its plain
# default status bar instead of the configured Kanagawa theme.
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  echo "==> Cloning tmux plugin manager (tpm)"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "==> tpm already installed, skipping clone"
fi

# install_plugins needs TMUX_PLUGIN_MANAGER_PATH set as a global tmux
# server variable first. Normally tmux.conf's `run` line does this on server
# startup, but triggering that indirectly (tmux source-file / run-shell)
# does not reliably persist it - confirmed by testing. Running tpm.tmux
# directly does, so do that instead of routing through tmux's config-sourcing.
echo "==> Initializing tpm"
bash "$TPM_DIR/tpm"

echo "==> Installing tmux plugins declared in tmux.conf (non-interactive, skips already-installed ones)"
"$TPM_DIR/bin/install_plugins"

echo "==> If tmux is already running, reload with: tmux source-file ~/.tmux.conf"
