---
name: aeq
description: Drive the per-repo agentic-engineering task queue (the `aeq` CLI) — add, list, grab, block, and finish backlog items for the current repo.
disable-model-invocation: true
---

# aeq

`aeq` is the CLI over a **directory-as-queue**: each item is a markdown file, its status is the folder it sits in (`queued/` → `in-progress/` → `blocked/` → `done/`), and a status change is an `mv`. Shell out to `aeq` for every mutation — don't hand-edit the files or reimplement the queue.

The store lives **out-of-repo**, keyed to the repo — not in the working tree, so don't look for it there. repo-id resolves from `cwd` and is worktree-invariant, so every worktree of a repo shares one queue. Pass `--repo <id>` when outside a git repo.

## Commands

```
aeq add [-m SPEC] "TITLE"   enqueue (SPEC from -m, stdin, or $EDITOR)
aeq list [STATUS]           STATUS = open(default) | queued | in-progress | blocked | done | all
aeq grab [ID]               oldest queued (or ID) -> in-progress; prints the path
aeq block ID [-m REASON]    -> blocked, appending REASON
aeq done ID                 -> done
aeq show ID                 print an item (ID = any unique substring)
aeq rm ID / aeq path / aeq repo
```

## Using it well

- **add** — capture intent the moment it surfaces, terse enough that a fresh agent could act on it; one deliverable per item.
- **grab** — *awareness ≠ execution*: only a drain worker grabs (it owns that one item). An interactive session reads the queue for context but never `grab`s or `/loop`s it.
- **block** — parked on something external; record *why* in the reason.
- **done** — the work actually shipped (PR merged), not just coded.
