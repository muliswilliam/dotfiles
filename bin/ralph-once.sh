#!/usr/bin/env bash
# Ralph loop, single supervised iteration: reads PRD.md + progress.txt from the
# current directory, has Claude implement the next task, then commits.
# Run this a few times by hand before trusting afk-ralph with unattended loops.
# https://www.aihero.dev/getting-started-with-ralph
set -euo pipefail

for f in PRD.md progress.txt; do
  [ -f "$f" ] || { echo "==> Missing $f in $(pwd) - create it before running ralph" >&2; exit 1; }
done

claude --permission-mode acceptEdits "@PRD.md @progress.txt
1. Read the PRD and progress file.
2. Find the next incomplete task and implement it.
3. Run tests and type checks.
4. Commit your changes.
5. Update progress.txt with what you did.
ONLY DO ONE TASK AT A TIME."
