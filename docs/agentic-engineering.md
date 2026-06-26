# agentic-engineering

> Design-of-record for the `aeq` queue and the infra around it. Documentation only — never stowed. See the [`aeq`](../skills/aeq/SKILL.md) skill for in-session usage.

## North star

A **private, offline, per-repo agent backlog** that lives **outside** each repo's committed tree — so it never leaks to teammates and stays visible across all of a repo's git worktrees. It's a per-repo task model made private by relocation.

Three layers stay separated:

| Layer         | Where                                               | Shared?                             |
| ------------- | --------------------------------------------------- | ----------------------------------- |
| **intent**    | the `aeq` queue (this repo's CLI)                   | private — never leaves your machine |
| **execution** | the git worktree + agent session that does the work | ephemeral                           |
| **output**    | GitHub / Linear PRs                                 | shared — this is what teammates see |

Capture intent in the queue; ship output through the shared tools. One source of intent.

## Store layout

```text
${XDG_DATA_HOME:-~/.local/share}/agentic-engineering/
└── repos/
    └── <repo-id>/
        ├── queued/        not started
        ├── in-progress/   grabbed by a drain worker
        ├── blocked/       parked, waiting on something
        └── done/          finished
```

- **Directory-as-queue.** One markdown file per item. **Status is the folder it lives in.** Changing status is an atomic `mv`. There is no index and no lock — the filesystem is the source of truth, which keeps it correct under parallel agents (a losing racer's `mv` simply fails and it tries the next item).
- **Out-of-repo is the load-bearing property.** It gives teammate-privacy _and_ cross-worktree visibility at once. An in-repo gitignored dir gives neither: untracked files aren't shared across git worktrees.
- **XDG data, not state.** The backlog is precious — history, sync, recovery — so it lives in `~/.local/share` (data), not `~/.local/state`.

## repo-id resolution (worktree-invariant)

`<repo-id>` must be identical across every worktree of a repo, or worktrees would each get their own queue and lose the shared view. `aeq` resolves it from signals that are shared across worktrees:

1. **`git config remote.origin.url`** → slug (e.g. `https://github.com/ssuyi-tw/skills.git` → `github.com-ssuyi-tw-skills`). Stable across worktrees, moves, and renames.
2. **Fallback (no remote):** the basename of the parent of `git rev-parse --git-common-dir` — the _common_ git dir is shared by all linked worktrees, so this is invariant too.

Override with `--repo <id>` or `$AEQ_REPO`. Outside a git repo with no override, `aeq` errors rather than guessing.

## The CLI

`aeq` is a single zero-dependency POSIX-bash script — deliberately a **dumb tracker** (no assignees, comments, milestones, or web UI). Smarts live in the skills that drive it, not the store.

```
aeq add [-m SPEC] "TITLE"   aeq list [STATUS]   aeq grab [ID]
aeq block ID [-m REASON]    aeq done ID         aeq show ID
aeq rm ID                   aeq path            aeq repo
```

Full surface and the per-verb judgment live in the [`aeq` skill](../skills/aeq/SKILL.md).

## Awareness hook

A `SessionStart` hook surfaces the repo's open queue into an interactive session as read-only context — the *awareness* half of **awareness ≠ execution**. An interactive session sees what's queued so the backlog is in context, but it never grabs or runs items; that's a drain worker's job. The hook resolves the repo from the session's cwd (the same worktree-invariant id as the CLI) and stays silent when there's nothing to show.

## Draining (commit-on-green)

The *execution* half of **awareness ≠ execution**, via `aeq-drain-supacode [N]`: it grabs up to N items and dispatches each into its own git worktree (branch `aeq/<id>`, bound at grab) and an **interactive** Claude tab in Supacode, seeded with the task and told to run the gate, commit on green, and `aeq done` / `block`. You watch and steer each session — supervised, not headless. Fanning out is safe because the grab is atomic / lock-free, and each item is isolated on its own branch → its own PR. The gate (`$AEQ_GATE`, e.g. tests + type-check) is load-bearing: a session with nothing to push back agrees with itself.

## Install

The CLI and the drain tools install as one stow package into `~/.local/bin` (on PATH, XDG-correct for executables):

```bash
make install-aeq      # stow aeq-bin/.local/bin/{aeq,aeq-drain-supacode} -> ~/.local/bin/
make uninstall-aeq
```

The `/aeq` slash skill installs with the others via `make install`.
