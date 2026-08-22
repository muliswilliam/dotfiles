#!/usr/bin/env bash
# Installs Matt Pocock's Claude Code skills plugin (grill/spec/tdd/code-review/etc).
# https://github.com/mattpocock/skills
set -euo pipefail

if claude plugin marketplace list 2>/dev/null | grep -q "mattpocock"; then
  echo "==> mattpocock marketplace already added, skipping"
else
  echo "==> Adding mattpocock Claude Code marketplace"
  claude plugin marketplace add mattpocock/skills
fi

if claude plugin list 2>/dev/null | grep -q "mattpocock-skills"; then
  echo "==> mattpocock-skills plugin already installed, skipping"
else
  echo "==> Installing mattpocock-skills plugin"
  claude plugin install mattpocock-skills@mattpocock
fi

echo "==> Run '/setup-matt-pocock-skills' once inside each repo you want to use these skills in"
