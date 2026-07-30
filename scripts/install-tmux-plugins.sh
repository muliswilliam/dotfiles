#!/usr/bin/env bash
# Installs the Tmux Plugin Manager (TPM) and the plugins config/tmux.conf
# declares (resurrect, continuum, vim-tmux-navigator, yank).
# The status bar theme is NOT one of them - config/tmux.conf sets it directly -
# so a missing plugin here costs you session persistence and pane navigation,
# not the colours.
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
# tpm talks to a live tmux server (tmux set-environment/show-environment) to
# record its own path - on a fresh machine, before tmux has ever been started,
# there is no server to talk to and it fails outright ("error connecting to
# ... No such file or directory"), which under `set -e` would silently abort
# this whole script before install_plugins ever runs. Spin up a disposable
# detached session so tpm has a server to talk to, then tear it down.
STARTED_TMP_SESSION=false
if ! tmux list-sessions >/dev/null 2>&1; then
  echo "==> No tmux server running yet - starting a disposable one so tpm can initialize"
  tmux new-session -d -s __tpm_install__
  STARTED_TMP_SESSION=true
fi

echo "==> Initializing tpm"
bash "$TPM_DIR/tpm"

echo "==> Installing tmux plugins declared in tmux.conf (non-interactive, skips already-installed ones)"
"$TPM_DIR/bin/install_plugins"

if [ "$STARTED_TMP_SESSION" = true ]; then
  tmux kill-session -t __tpm_install__
fi

echo "==> If tmux is already running, reload with: tmux source-file ~/.tmux.conf"
