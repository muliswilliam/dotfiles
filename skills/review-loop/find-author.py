#!/usr/bin/env python3
"""Rank live local Claude Code sessions by how likely they own (authored / push to) a PR.

Usage: find-author.py <pr-url> <head-branch> <own-session-name>
Prints one line per candidate, best first: score<TAB>name<TAB>status<TAB>cwd<TAB>evidence
"""
import glob, json, os, sys

pr_url, branch, own = sys.argv[1], sys.argv[2], sys.argv[3]
home = os.path.expanduser("~/.claude")
branch_tokens = {t for t in branch.replace("_", "-").replace("/", "-").split("-") if len(t) > 2}


def commands(transcript):
    """Yield every Bash command the session ran."""
    for line in open(transcript, errors="ignore"):
        if '"Bash"' not in line:
            continue
        try:
            content = json.loads(line)["message"]["content"]
        except (ValueError, KeyError, TypeError):
            continue
        for block in content if isinstance(content, list) else []:
            if block.get("type") == "tool_use" and block.get("name") == "Bash":
                yield block["input"].get("command", "")


rows = []
for path in glob.glob(f"{home}/sessions/*.json"):
    try:
        s = json.load(open(path))
        os.kill(s["pid"], 0)
    except (OSError, ValueError, KeyError):
        continue
    name = s.get("name", "")
    if not name or name == own:
        continue
    score, evidence = 0, []
    transcripts = glob.glob(f"{home}/projects/*/{s['sessionId']}.jsonl")
    if transcripts:
        text = open(transcripts[0], errors="ignore").read()
        if "gh pr create" in text and pr_url in text:
            score += 20; evidence.append("created PR")
        elif pr_url in text:
            score += 3; evidence.append("mentions PR url")
        pushes = sum(1 for c in commands(transcripts[0]) if "git push" in c)
        if pushes and branch in text:
            score += min(pushes, 10); evidence.append(f"{pushes} git pushes, branch mentioned")
    hits = branch_tokens & set(name.split("-"))
    if hits:
        score += 2 * len(hits); evidence.append(f"name matches {sorted(hits)}")
    if score:
        rows.append((score, name, s.get("status", "?"), s.get("cwd", ""), "; ".join(evidence)))

for r in sorted(rows, reverse=True):
    print("\t".join(map(str, r)))
