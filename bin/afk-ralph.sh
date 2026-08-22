#!/usr/bin/env bash
# Ralph loop, unattended: repeats a ralph-once-style iteration in the current
# directory up to N times, stopping early if Claude reports the PRD is done.
# Usage: afk-ralph <iterations>
# https://www.aihero.dev/getting-started-with-ralph
set -euo pipefail

iterations="${1:?Usage: afk-ralph <iterations>}"

for f in PRD.md progress.txt; do
  [ -f "$f" ] || { echo "==> Missing $f in $(pwd) - create it before running ralph" >&2; exit 1; }
done

for ((i = 1; i <= iterations; i++)); do
  echo "==> Ralph iteration $i/$iterations"
  result=$(claude --permission-mode acceptEdits -p "@PRD.md @progress.txt
1. Find the highest-priority incomplete task.
2. Implement it.
3. Run tests and type checks.
4. Commit your changes.
5. Update PRD.md and progress.txt.
ONLY WORK ON A SINGLE TASK.
If the entire PRD is complete, output <promise>COMPLETE</promise>.")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "==> PRD complete after $i iteration(s)"
    exit 0
  fi
done

echo "==> Reached $iterations iteration(s) without completion"
