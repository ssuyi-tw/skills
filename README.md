# skills

Personal Claude skills, managed with [GNU stow](https://www.gnu.org/software/stow/).

Installed via `stow` rather than an npm wrapper. Also includes optional home-level Claude guidance.

On Windows, use the Git-managed junction setup instead of GNU stow. See
[Windows installation for Codex Desktop and Claude Code Desktop](docs/windows-install.md).

## Skills

| Skill | What it does |
| --- | --- |
| [`aeq`](skills/aeq/SKILL.md) | Drives the private, per-repo agentic-engineering task queue (`aeq` CLI). See [docs/agentic-engineering.md](docs/agentic-engineering.md). |
| [`blunt-mode`](skills/blunt-mode/SKILL.md) | Terse dev-chat register — strips filler and hedging, keeps every concrete fact. |
| [`capture-english-lessons`](skills/capture-english-lessons/SKILL.md) | Distills English phrasing diffs from a session into a dated lesson file. Manual (`/capture-english-lessons`). |
| [`distill`](skills/distill/SKILL.md) | Distills a session into a one-off `DISTILL.md` of durable concepts and reasoning — decisions, models, lessons. Manual (`/distill`). See [docs/distill.md](docs/distill.md). |
| [`english-practice`](skills/english-practice/SKILL.md) | Toggles focused English coaching for the current conversation. Manual (`$english-practice`). |
| [`greeting`](skills/greeting/SKILL.md) | Casual greeting register when you open with "hi" / "hey" / etc. |
| [`grilling`](skills/grilling/SKILL.md) | Interviews you relentlessly to stress-test a plan or design before building. |
| [`handoff`](skills/handoff/SKILL.md) | Compacts the conversation into a handoff doc so a fresh agent can continue. Manual (`/handoff`). |
| [`i-have-adhd`](skills/i-have-adhd/SKILL.md) | Shapes responses for ADHD readers: action first, numbered steps, visible progress, and no tangents. |
| [`sharpen`](skills/sharpen/SKILL.md) | Tightens a vague prompt before acting — surfaces what's missing and asks. Manual (`/sharpen`). |
| [`ssuyi-voice`](skills/ssuyi-voice/SKILL.md) | Voice and register calibration for natural written output. Manual. |
| [`writing-great-skills`](skills/writing-great-skills/SKILL.md) | Reference for the vocabulary and principles that make a skill predictable. |

## Credits

Home-level `CLAUDE.md` is adapted from [`multica-ai/andrej-karpathy-skills`](https://github.com/multica-ai/andrej-karpathy-skills).

`blunt-mode` is a terser, blunter cousin of [`caveman`](https://github.com/JuliusBrussee/caveman) by Julius Brussee.

`handoff` mirrors [mattpocock/skills](https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md) by Matt Pocock.

`i-have-adhd` is from [`ayghri/i-have-adhd`](https://github.com/ayghri/i-have-adhd/tree/main) by Ayoub G.

`grilling` is from [mattpocock/skills](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md) by Matt Pocock.

`writing-great-skills` is from [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-great-skills) by Matt Pocock.

`git-guardrails` uses the `block-dangerous-git.sh` hook from [`mattpocock/skills`](https://github.com/mattpocock/skills/tree/main/skills/misc/git-guardrails-claude-code) by Matt Pocock (script only; install rewired for this repo's stow flow).

## Layout

Skills live under a single `skills/` directory in the standard `skills/<name>/SKILL.md`
layout — the same shape used by Claude Code plugin marketplaces and `skills.sh`, so this
repo is shareable/installable the common way too (see [Sharing](#sharing)). Home-level
guidance, hooks, and bins each remain their own stow package at the repo root.

```text
.
├── skills/                     <- one stow package; each child folds into ~/.claude/skills/
│   ├── blunt-mode/
│   │   └── SKILL.md            <- this dir name appears in ~/.claude/skills/
│   └── <next-skill>/
│       └── SKILL.md
├── karpathy-guidelines/        <- stow package for home-level Claude guidance
│   └── .claude/
│       └── karpathy-guidelines.md
├── commit-style/               <- stow package for commit-style guidance
│   └── .claude/
│       └── commit-style.md
├── slack-style/                <- stow package for slack-style guidance
│   └── .claude/
│       └── slack-style.md
├── git-guardrails/             <- stow package for a Claude Code hook
│   └── .claude/
│       └── hooks/
│           └── block-dangerous-git.sh
├── aeq-bin/                    <- stow package for aeq CLI -> ~/.local/bin/
│   └── .local/bin/
│       ├── aeq
│       └── aeq-drain-supacode
├── aeq-awareness/              <- stow package for aeq SessionStart hook
│   └── .claude/
│       └── hooks/
│           └── aeq-session-awareness.sh
├── docs/                       <- design-of-record docs (not stowed)
├── scripts/                    <- validation and tooling
├── LICENSE
├── Makefile
└── README.md
```

`stow` links `skills/` as one package: its tree-folding turns each child skill dir into a
single directory symlink under `~/.claude/skills/`. Because the package strips its own name,
no per-skill "doubling" is needed — the skill dir itself is the unit that gets linked.

## Install

```bash
brew install stow            # if not already installed
make install
```

`make install` will:

1. Create `~/.claude/skills/` (Claude Code's real skill dir).
2. Create `~/.agent/skills` as a symlink to `~/.claude/skills/`.
3. Stow the `skills` package into `~/.agent/skills/` — each skill dir folds to a symlink under `~/.claude/skills/`.

## Install for Pi

Pi discovers global skills from `~/.pi/agent/skills/`. The source format is the same, so
the existing skill directories can be stowed there directly:

```bash
make install-pi
```

This creates directory symlinks in Pi's skill directory; it does not copy or fork the
skills. Restart Pi after installing, then invoke manual-only skills with commands such as
`/skill:handoff` or `/skill:sharpen`.

## Install Karpathy guidelines

This keeps your existing `~/.claude/CLAUDE.md` as the aggregator. It stows only `karpathy-guidelines.md`, then adds `@karpathy-guidelines.md` to `~/.claude/CLAUDE.md` if missing.

```bash
make install-karpathy-guidelines
```

## Install Codex guidance and skills

Codex gets a home layout that mirrors the Claude guidance aggregator, while
keeping Codex's bundled system skills untouched.

```bash
make install-codex
```

`make install-codex` will:

1. Create `~/.codex/skills/` if needed.
2. Create `~/.codex/skills/personal` as a symlink to this repo's `skills/` directory.
3. Create `~/.codex/AGENTS.md` with the same five imports used by `~/.claude/CLAUDE.md`.
4. Link the imported guidance files into `~/.codex/`.

**Prerequisite:** `~/.claude/RTK.md` must already exist (the Codex target symlinks to it).
If you haven't set up RTK yet, the install will fail with an actionable error.

Expected layout:

```text
~/.codex/
├── AGENTS.md
├── RTK.md -> ~/.claude/RTK.md
├── karpathy-guidelines.md -> <repo>/karpathy-guidelines/.claude/karpathy-guidelines.md
├── commit-style.md -> <repo>/commit-style/.claude/commit-style.md
├── slack-style.md -> <repo>/slack-style/.claude/slack-style.md
└── skills/
    ├── .system/
    └── personal -> <repo>/skills
```

To remove only the Codex links/files managed by this repo:

```bash
make uninstall-codex
```

## Install git guardrails (PreToolUse hook)

A `PreToolUse` hook (`block-dangerous-git.sh`) that blocks destructive git commands
(`push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .` / `restore .`) before
Claude Code runs them. It is not a skill — the script is stow-managed into
`~/.claude/hooks/`, and registration lives in `~/.claude/settings.json`.

Requires `jq` (used at install time and by the hook at runtime).

```bash
make install-git-guardrails
```

`make install-git-guardrails` will:

1. Stow the script to `~/.claude/hooks/block-dangerous-git.sh` (a symlink into this repo).
2. Idempotently add a `Bash` `PreToolUse` entry to `~/.claude/settings.json`, merging into
   any existing `hooks` without touching other settings.

Editing the blocked patterns is a one-line change to the script in this repo — reflected
live through the symlink, no restow needed. To remove:

```bash
make uninstall-git-guardrails
```

This unregisters the hook from `settings.json` and unstows the script.

## Install the aeq queue CLI

The [`aeq`](docs/agentic-engineering.md) queue primitive and its supervised drain dispatcher (`aeq-drain-supacode`) are one stow package linked into `~/.local/bin` (already on PATH, XDG-correct for executables).

```bash
make install-aeq      # ~/.local/bin/{aeq,aeq-drain-supacode}
make uninstall-aeq
```

## Install aeq awareness (SessionStart hook)

A `SessionStart` hook that injects this repo's open `aeq` queue into an interactive session as **read-only awareness** — *awareness ≠ execution*: the session sees what's queued for context, but only a drain worker grabs and runs items. It no-ops silently outside a git repo, on an empty queue, or when `aeq`/`jq` aren't installed. Requires `jq`.

```bash
make install-aeq-awareness
make uninstall-aeq-awareness
```

`make install-aeq-awareness` stows the hook to `~/.claude/hooks/aeq-session-awareness.sh` and idempotently registers it under `SessionStart` in `~/.claude/settings.json`, merging into existing hooks without touching other settings.

## Add a new skill

```bash
mkdir -p skills/my-skill
$EDITOR skills/my-skill/SKILL.md
make restow                 # fold the new skill dir into ~/.claude/skills/
```

## Remove a skill

`restow` won't remove a skill whose dir is already gone (stow no longer sees it), so drop
the links first, then delete:

```bash
make uninstall              # drop all skill symlinks (dirs/sources untouched)
git rm -r skills/my-skill
make install                # re-fold what remains
```

## Refresh after adding or removing a skill

Editing a skill's files — or adding/removing files *inside* an existing skill — is reflected
live through the directory symlink. `make restow` is only needed when you add a new skill dir
(or to repair links):

```bash
make restow
```

For Pi, use `make restow-pi` after adding or removing a skill directory.

## Refresh home guidance

Only needed when you add/remove files under a home package:

```bash
make restow-home
```

## Inspect state

```bash
make list      # which skills this repo defines
make doctor    # resolved paths and current symlink state
```

## Validate

Run the full check suite (skill metadata, shell syntax, markdown lint):

```bash
make check
```

Individual checks:

```bash
make check-skills      # frontmatter, naming, links, README coverage
make check-shell       # bash -n on all .sh files
make check-markdown    # markdownlint (skips if not installed)
```

## Sharing

The `skills/<name>/SKILL.md` layout is the common, tool-agnostic one, so others can install
these without stow:

- **skills.sh** — works as-is against the flat layout: `npx skills add <user>/<repo>`.
- **Claude Code plugin marketplace** (optional, not yet configured) — add a
  `.claude-plugin/marketplace.json` pointing at `skills/`, then consumers run
  `/plugin marketplace add <user>/<repo>` + `/plugin install`, or
  `claude --plugin-dir <path>` locally.

Those are copy-based installs for *other* machines. On your own machine you keep the live
stow symlinks (this repo stays the single source of truth) — the two don't conflict.

## How it works

```text
skills/<name>/               (source — this repo; one stow package: `skills`)
       │
       │  stow folds each child dir into
       ▼
~/.agent/skills/<name>/       (agent-neutral abstraction)
       │
       │  is a symlink to
       ▼
~/.claude/skills/<name>/      (what Claude Code reads)
```

The `~/.agent/skills` indirection means the same source can later be pointed at a different agent's skill dir without reorganizing this repo.

Home guidance uses a separate stow target:

```text
karpathy-guidelines/.claude/karpathy-guidelines.md
                                  (source file — this repo)
       │
       │  stow links into
       ▼
~/.claude/karpathy-guidelines.md
```

`make install-karpathy-guidelines` then adds this import to your existing aggregator:

```markdown
@karpathy-guidelines.md
```

## License

[MIT](./LICENSE) — © 2026 SzuYi Huang
