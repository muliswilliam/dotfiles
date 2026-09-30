---
name: review-loop
description: Review a PR with mattpocock code-review, message findings to the authoring Claude session, re-review each push until nothing is open.
disable-model-invocation: true
argument-hint: "[PR number | url | branch] [author session name]"
hooks:
  Stop:
    - hooks:
        - type: command
          command: "$HOME/.claude/skills/review-loop/stop-gate.sh"
---

You are the **reviewer** session. Another local Claude Code session, the **author**, owns the PR branch. You review, send findings with SendMessage, wait for the author to push fixes, and re-review. Loop until the PR is **clean**.

Arguments: `$ARGUMENTS` (both optional).

**Clean** = every finding ID from every round is `fixed` (verified in the diff at the new head) or `declined` with reasoning you accept, the latest round raised no new must-fix or spec finding, and `gh pr checks` is green. Nits never block.

## 1. Pin identity and PR

- Call ListAgents. Note your own session name (the "This session is ..." line); the author replies to it.
- Resolve the PR: the argument (number, url, or branch), else `gh pr view` for the current branch, else ask. Work from the PR's repo root; if cwd is outside it, ask for the path.
- Capture `<repo>` (`gh repo view --json name -q .name`) and `number, url, headRefName, baseRefName, headRefOid` via `gh pr view --json`.

Done when you have your own name plus the PR's url, head branch, base branch, and head SHA.

## 2. Pick the author

- Session name given as an argument: use it.
- Otherwise run `${CLAUDE_SKILL_DIR}/find-author.py <url> <headRefName> <own-name>`. It ranks live sessions by transcript evidence (created the PR, pushed the branch, name tokens).
  - Top row says `created PR` and scores at least double the runner-up: pick it and tell the user which one you picked and why.
  - Anything else: AskUserQuestion with the top candidates (name, status, evidence). If no candidate appears, offer the ListAgents peer names.

Done when the author name appears in ListAgents' peer list.

## 3. Arm the goal

This skill's Stop hook (`stop-gate.sh`) is the loop's goal: while the marker says `open`, it blocks the turn from ending unless a background watch is armed to wake you. Arm it:

```
mkdir -p ~/.review-loop/sessions ~/.review-loop/<repo>-pr<n>
printf 'open\n%s\n' ~/.review-loop/<repo>-pr<n> > ~/.review-loop/sessions/$CLAUDE_CODE_SESSION_ID
```

Line 1 of the marker is the loop state. Keep it true:

- `ask-user` before any question to the user; back to `open` once they answer.
- `stopped` if the user ends the loop.
- `clean` in step 7.

## 4. Review a round

Check out the head in a detached review worktree so the author's checkout is untouched:

```
git fetch -q origin <base> <head>
git worktree add --detach .claude/worktrees/review-pr<n> origin/<head>   # round 1
git -C .claude/worktrees/review-pr<n> checkout -q --detach origin/<head> # later rounds
```

From inside that worktree, invoke the `mattpocock-skills:code-review` skill with fixed point `origin/<base>`, and follow it in full.

On rounds 2+, also check every open ID from the previous round against the new diff: `fixed` only when the code at the new head shows it. For a `declined` ID, accept the reasoning or re-raise it with counter-evidence.

Write the round to `~/.review-loop/<repo>-pr<n>/round<r>.md` (the author can read it too). Give every finding a stable ID that survives across rounds: `M` must-fix (bug, security, hard standards violation), `S` spec gap, `Q` judgement call, `N` nit. New findings take the next free number; never reuse an ID. Each finding cites `file:line` and says what to change.

Done when the round file lists every finding, plus (rounds 2+) a status for every earlier ID.

## 5. Send or finish

Round is **clean**: go to step 7.

Otherwise SendMessage to the author with `notify_when_idle: true`. The message carries the round file's findings plus this protocol:

> PR #<n> review round <r> at <short-sha>. Full list: `<round file>`. Fix on `<head>` and push. Verify each finding before fixing. If one is wrong or out of scope, decline it with evidence instead. When pushed, message `<own-name>` with the new head SHA and one line per ID: `fixed <sha>` / `declined: <reason>`. I re-review on each push until the PR is clean.

Done when SendMessage reports success.

## 6. Wait for the push

Arm one background watch (Bash `run_in_background`) that exits when the head moves:

```
until [ "$(git ls-remote origin refs/heads/<head> | cut -f1)" != "<last-reviewed-sha>" ]; do sleep 60; done
```

While waiting:

- **Author message with a new SHA**: kill the watch and start step 4.
- **Author says wait** (force push, rebase, retarget coming): keep waiting; re-read `baseRefName` before the next round.
- **Idle notice, no push**: read the author's reply or `git log` on its branch. If it stalled or forgot to push, send one short nudge naming what is missing.
- **Head moved, no message**: wait a few minutes for the status message, then review anyway.
- **Same ID bounced for three rounds**: set the marker to `ask-user` and ask the user to arbitrate.
- **Watch expired**: re-arm it.

Done when the head SHA differs from the last one you reviewed. Go to step 4.

## 7. Close out

- Wait for CI to settle (`gh pr checks <n>`). If a check fails because of the PR, treat it as a must-fix finding and go back to step 5. For an infra flake, rerun the job once.
- Send the author a final message: "PR #<n> @ <sha> is clean", the IDs resolved, and any optional nits.
- Write `clean` to line 1 of the marker, remove the review worktree (`git worktree remove .claude/worktrees/review-pr<n>`), and stop every background watch you started.
- Report to the user: rounds run, findings by class fixed or declined, the final SHA, CI state. Keep it terse.
