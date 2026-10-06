#!/usr/bin/env bash
# Installs third-party Claude Code skills plugins:
# - Matt Pocock's skills (grill/spec/tdd/code-review/etc): https://github.com/mattpocock/skills
# - HumanLayer's visual-pr (/visual-pr PR descriptions): https://github.com/humanlayer/skills
set -euo pipefail

# add_marketplace <name> <github-repo>
add_marketplace() {
  if claude plugin marketplace list 2>/dev/null | grep -q "$2"; then
    echo "==> $1 marketplace ($2) already added, skipping"
  else
    echo "==> Adding $1 Claude Code marketplace ($2)"
    claude plugin marketplace add "$2"
  fi
}

# install_plugin <plugin@marketplace>
install_plugin() {
  if claude plugin list 2>/dev/null | grep -q "$1"; then
    echo "==> $1 plugin already installed, skipping"
  else
    echo "==> Installing $1 plugin"
    claude plugin install "$1"
  fi
}

add_marketplace mattpocock mattpocock/skills
install_plugin mattpocock-skills@mattpocock

# HumanLayer's marketplace is named just "skills".
add_marketplace skills humanlayer/skills
install_plugin visual-pr@skills

echo "==> Run '/setup-matt-pocock-skills' once inside each repo you want to use these skills in"
