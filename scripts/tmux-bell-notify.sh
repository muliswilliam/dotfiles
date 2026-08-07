#!/usr/bin/env bash
# Fires a native macOS notification for a tmux bell. Invoked by the
# `alert-bell` hook in config/tmux.conf, which runs server-side for any
# window in any session as soon as its bell flag is set -- unlike escape-
# sequence bell forwarding, this does not require a client to be attached
# to that session, so it also covers Claude Code/Codex CLI prompting for
# input in a session you're not currently attached to.
set -euo pipefail

session="${1:-tmux}"
window="${2:-}"

osascript -e "display notification \"${window}\" with title \"Agent needs input (${session})\""
