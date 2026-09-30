#!/usr/bin/env bash
# Stop hook registered by the review-loop skill: the loop's goal.
# Blocks the turn from ending while this session's review loop is open and
# nothing is armed to wake it. Marker: ~/.review-loop/sessions/<session_id>
# (line 1 = state: open | clean | stopped | ask-user, line 2 = PR dir).
input=$(cat)
sid=$(jq -r '.session_id // empty' <<<"$input")
marker="$HOME/.review-loop/sessions/$sid"
[ -n "$sid" ] && [ -f "$marker" ] || exit 0
[ "$(sed -n 1p "$marker")" = open ] || exit 0
# Paused on a background watch (or cron): the session is woken when it fires.
[ "$(jq '(.background_tasks // []) + (.session_crons // []) | length' <<<"$input")" -gt 0 ] && exit 0
dir=$(sed -n 2p "$marker")
jq -n --arg r "Review loop still open (round files in $dir). Continue the review-loop skill: review the new head, send findings, or arm the step-6 wait for the author's push. If you need the user's decision, write ask-user to line 1 of $marker first; if the user asked to end the loop, write stopped." \
  '{decision: "block", reason: $r}'
