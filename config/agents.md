# global agent instructions

- Never use the em dash "—" or en dash "–". Use plain dash "-" instead.
- Never add AI attribution to commits or PRs: no "Co-Authored-By" agent lines, no "Generated with Claude Code" or similar footers.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When making technical decisions on product code, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it. Then add a regression test that fails before the fix and passes after.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Keep those unrelated fixes in separate commits. If one is large or risky, flag it to me instead of doing it.
- Always clean up processes you start (dev servers, backends, watchers, browser daemons, wait/poll loops, background jobs) before your final handoff, unless I explicitly ask to keep them running or the next step clearly needs them.
  Kill the whole process tree, not just the parent, and verify nothing is left running or holding ports. If you leave something running on purpose, tell me what and why.
- When reporting information to me, be extremely concise and sacrifice grammar for the sake of concision.
- PRs that add or change UI must include screenshots of the affected screens (before/after when changing existing UI).
- Non-trivial PRs must include a Mermaid diagram explaining the change and/or the affected product flow.
- While a review loop (review-loop / review agent) is running on a PR, do not wait for CI between rounds.
  Keep fixing review feedback as it arrives; check CI only once the review agent reports reviews are clean.
