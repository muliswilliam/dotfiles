# Idea to prod with Claude Code

How I take an idea to production with Claude Code. Takes 10 minutes to set up.

```mermaid
flowchart LR
    A[Idea] --> B[/grill-with-docs + lavish/]
    B --> C[/to-spec/]
    C --> D[/to-tickets/]
    D --> E[/implement-spec/]
    E --> F[/code-review/]
    F -->|findings| E
    F -->|clean| G[/goal merge + deploy/]
    G --> H[Prod]
```

## Setup (once)

**0. Prerequisites:** Node 18+ and the GitHub CLI, signed in. The skills use `gh` to create issues and PRs.

- macOS: `brew install gh node`
- Windows: `winget install GitHub.cli OpenJS.NodeJS.LTS`, then open a new terminal

Then run `gh auth login`.

**1. Install the skills**

```sh
claude plugin marketplace add mattpocock/skills
claude plugin install mattpocock-skills@mattpocock
```

**2. Install Lavish** (turns plans, specs and reviews into an HTML page in your browser that you can click on, annotate and send feedback from).

macOS / Linux:

```sh
npx skills add kunchenguid/lavish-axi --skill lavish -g
```

Windows (PowerShell). `--copy` avoids symlinks, which need admin or Developer Mode on Windows:

```powershell
npx skills add kunchenguid/lavish-axi --skill lavish -g --copy
```

Pick Claude Code when it asks which agents. Restart Claude Code afterwards.

**3. Point the skills at your repo.** Run this inside the repo, then commit the `docs/agents/` folder it creates:

```
/setup-matt-pocock-skills
```

**4. Add a few global rules** to `~/.claude/CLAUDE.md` (Windows: `%USERPROFILE%\.claude\CLAUDE.md`). These are the ones I'd start with:

```markdown
- Prefer quality, simplicity and long term maintainability over development speed.
- Bug fixes: reproduce the bug end to end first, then add a regression test that fails before the fix and passes after.
- Fix lint errors, failing tests and flaky tests you come across, in separate commits.
- PRs that change UI include before/after screenshots. Non-trivial PRs include a Mermaid diagram.
- Clean up dev servers and background processes before you finish.
- Keep reports short.
```

When you correct Claude twice for the same thing, add a rule for it.

## The flow

### 1. Shape the idea

Explain the idea to Claude, then:

```
/grill-with-docs
```

It interviews you until the plan has no gaps. Skip this step if the idea is already clear.

To see the plan before committing to it:

```
/lavish show me the plan
```

This opens the plan in your browser as a page with diagrams and options. Click any part of it to comment, then send your feedback back to Claude. Repeat until you're happy with the plan.

### 2. Write the spec

```
/to-spec
```

This turns the conversation into a GitHub issue covering the problem, the solution, user stories, decisions and what's out of scope. You can also point it at notes, e.g. `/to-spec <paste QA notes>`.

### 3. Break it into tickets

```
/to-tickets #<spec-number>
```

This creates one issue per piece of work and links which tickets block which, so independent work can run in parallel.

### 4. Implement

Always run `/clear` first. The spec and tickets already hold everything Claude needs, and starting with a long conversation in context makes the implementation worse.

```
/clear
/implement-spec #<spec-number>
```

You get one branch and one draft PR. Claude runs parallel subagents, one per unblocked ticket, merges their work, and reviews it at the end.

For a single small ticket, use `/clear` then `/implement #<issue>` instead.

### 5. Review in a fresh session

Open a **new** Claude session. A fresh session is better at catching problems than the one that wrote the code. Then run:

```
/code-review main
```

The review checks two things separately:
- **Standards:** does the code follow our conventions?
- **Spec:** does it do what the issue asked, nothing missing and nothing extra?

For a long review, `/lavish show me the review findings` makes them easier to work through.

Paste the findings back into the session that wrote the code to fix them, and repeat until the review is clean. After that, a human reviews the PR.

### 6. Ship

```
/goal Get PR <n> merged: fix CI, address review comments, merge when green, wait for the staging deploy, verify the feature works on staging, report back
```

`/goal` keeps Claude working until the outcome is true, so it doesn't stop halfway. Release to prod the way the repo normally does it.

## Bug fixes

Bugs take a shorter path:

1. Reproduce the bug the way a user would hit it (for UI bugs, ask Claude to drive the browser and take screenshots).
2. Write a test that fails because of the bug.
3. Fix it and confirm the test passes.
4. Run `/code-review`, then open the PR.

## Running several agents: herdr

Once you work like this, you'll have several Claude sessions going at once: one implementing, one reviewing, one shaping the next idea. [herdr](https://herdr.dev) puts them all in one terminal window:

- A sidebar with every session and whether it's **working**, **blocked** waiting on you, or **done**. You stop flipping between tabs to check.
- Sessions keep running after you close the terminal. Reopen herdr and you're back where you left off.
- Works with Claude Code out of the box.

Install it:

- macOS / Linux: `curl -fsSL https://herdr.dev/install.sh | sh`
- Windows (PowerShell): `irm https://herdr.dev/install.ps1 | iex`

Run `herdr`, open one workspace per project, and start `claude` in each one.

## Tips

- **Describe the outcome, not the steps.** "Migrate backend to vitest" works better than a 10-step plan.
- **Keep specs in GitHub, not chat.** That way anyone, human or agent, can pick up a ticket later.
- **Use `/btw status`** to check on a long run without derailing it.
- **Use `/clear` between unrelated tasks.** Old context makes Claude worse.
- **When you explain a repo fact to Claude twice,** add it to `docs/agents/` or the repo's `CLAUDE.md`.
