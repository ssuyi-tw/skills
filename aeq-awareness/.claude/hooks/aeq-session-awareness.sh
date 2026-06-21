#!/bin/bash
# SessionStart hook — inject read-only awareness of this repo's aeq backlog.
#
# awareness != execution: an interactive session sees the open queue for context;
# only a drain worker grabs and runs items. This hook never mutates the queue, and
# no-ops silently (exit 0, no output) whenever there's nothing useful to inject —
# jq missing, aeq not installed, not a git repo, or an empty queue.

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

# locate aeq (stow-installed at ~/.local/bin; a hook's PATH may be minimal)
AEQ=$(command -v aeq 2>/dev/null)
[ -z "$AEQ" ] && [ -x "$HOME/.local/bin/aeq" ] && AEQ="$HOME/.local/bin/aeq"
[ -z "$AEQ" ] && exit 0

# resolve the session's working dir (aeq derives repo-id from cwd)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null

# open items for this repo; bail quietly if not a git repo / nothing open
OPEN=$("$AEQ" list open 2>/dev/null)
[ -z "$OPEN" ] && exit 0
ITEMS=$(printf '%s\n' "$OPEN" | grep -cE '^[[:space:]]+[0-9]{8}T' 2>/dev/null)
[ "${ITEMS:-0}" -eq 0 ] && exit 0

OPEN=$(printf '%s' "$OPEN" | head -c 7000)
CONTEXT="This repo has a private \`aeq\` backlog. Open items — read-only awareness, do NOT grab or /loop them (that is a drain worker's job):
$OPEN

Capture new intent with \`aeq add -m \"spec\" \"title\"\` (see the /aeq skill)."

jq -n --arg ctx "$CONTEXT" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
