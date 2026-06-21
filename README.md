# skills

Personal Claude skills, managed with [GNU stow](https://www.gnu.org/software/stow/).

Installed via `stow` rather than an npm wrapper. Also includes optional home-level Claude guidance.

## Skills

| Skill | What it does |
| --- | --- |
| [`blunt-mode`](blunt-mode/blunt-mode/SKILL.md) | Terse dev-chat register — strips filler and hedging, keeps every concrete fact. |
| [`distill`](distill/distill/SKILL.md) | Distills a session into a one-off `DISTILL.md` of durable concepts and reasoning — decisions, models, lessons. Manual (`/distill`). See [docs/distill.md](docs/distill.md). |
| [`greeting`](greeting/greeting/SKILL.md) | Casual greeting register when you open with "hi" / "hey" / etc. |
| [`handoff`](handoff/handoff/SKILL.md) | Compacts the conversation into a handoff doc so a fresh agent can continue. Manual (`/handoff`). |
| [`writing-great-skills`](writing-great-skills/writing-great-skills/SKILL.md) | Reference for the vocabulary and principles that make a skill predictable. |

## Credits

Home-level `CLAUDE.md` is adapted from [`multica-ai/andrej-karpathy-skills`](https://github.com/multica-ai/andrej-karpathy-skills).

`blunt-mode` is a terser, blunter cousin of [`caveman`](https://github.com/JuliusBrussee/caveman) by Julius Brussee.

`handoff` mirrors [mattpocock/skills](https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md) by Matt Pocock.

`writing-great-skills` is from [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-great-skills) by Matt Pocock.

## Layout

Each skill lives in a "doubled" directory — the outer dir is the stow package, the inner dir is the skill itself:

```text
skills/
├── karpathy-guidelines/        <- stow package for home-level Claude guidance
│   └── .claude/
│       └── karpathy-guidelines.md
├── LICENSE
├── Makefile
├── README.md
├── blunt-mode/                 <- stow package
│   └── blunt-mode/             <- the actual skill (this name appears in ~/.claude/skills/)
│       └── SKILL.md
└── <next-skill>/
    └── <next-skill>/
        └── SKILL.md
```

The doubling is required so `stow` can link each skill as a directory rather than flattening its contents into the target.

## Install

```bash
brew install stow            # if not already installed
make install
```

`make install` will:

1. Create `~/.claude/skills/` (Claude Code's real skill dir).
2. Create `~/.agent/skills` as a symlink to `~/.claude/skills/`.
3. Stow every skill in this repo into `~/.agent/skills/`, which transparently lands in `~/.claude/skills/`.

## Install Karpathy guidelines

This keeps your existing `~/.claude/CLAUDE.md` as the aggregator. It stows only `karpathy-guidelines.md`, then adds `@karpathy-guidelines.md` to `~/.claude/CLAUDE.md` if missing.

```bash
make install-karpathy-guidelines
```

## Add a new skill

```bash
mkdir -p my-skill/my-skill
$EDITOR my-skill/my-skill/SKILL.md
make stow SKILL=my-skill
```

## Remove a skill

```bash
make unstow SKILL=my-skill
```

## Refresh after editing files inside a skill

Only needed when you add/remove files (existing file edits are reflected automatically through the symlink):

```bash
make restow
```

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

## How it works

```text
skills/<name>/<name>/         (source — this repo)
       │
       │  stow links into
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
