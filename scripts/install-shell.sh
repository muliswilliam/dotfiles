#!/usr/bin/env bash
# Installs oh-my-zsh, powerlevel10k, and the zsh plugins referenced in
# config/zshrc. Safe to re-run: every install is guarded by a marker-file
# check, not just directory presence - a directory that exists but is
# missing its expected file (partial clone, interrupted install) is removed
# and reinstalled instead of being treated as done forever.
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$HOME/.oh-my-zsh" ] && [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
  echo "==> ~/.oh-my-zsh looks incomplete (missing oh-my-zsh.sh) - removing and reinstalling"
  rm -rf "$HOME/.oh-my-zsh"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "==> oh-my-zsh already installed, skipping"
fi

clone_if_missing() {
  local repo="$1" dest="$2" marker="$3"
  if [ -d "$dest" ] && [ ! -e "$dest/$marker" ]; then
    echo "==> $(basename "$dest") looks incomplete (missing $marker) - removing and re-cloning"
    rm -rf "$dest"
  fi
  if [ ! -d "$dest" ]; then
    echo "==> Cloning $repo"
    git clone --depth=1 "$repo" "$dest"
  else
    echo "==> $(basename "$dest") already installed, skipping"
  fi
}

clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions" "zsh-autosuggestions.zsh"
clone_if_missing "https://github.com/zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions" "zsh-completions.plugin.zsh"
clone_if_missing "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k" "powerlevel10k.zsh-theme"
