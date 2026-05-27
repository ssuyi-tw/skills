# skills

Personal Claude skills, managed with [GNU stow](https://www.gnu.org/software/stow/).

Installed via `stow` rather than an npm wrapper.

## Credits

`blunt-mode` is a terser, blunter cousin of [`caveman`](https://github.com/mattpocock/skills/tree/main/skills/productivity/caveman) by Matt Pocock.

`handoff` is from [ykdojo/claude-code-tips](https://github.com/ykdojo/claude-code-tips/blob/main/skills/handoff/SKILL.md) by YK.

## Layout

Each skill lives in a "doubled" directory — the outer dir is the stow package, the inner dir is the skill itself:

```
skills/
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

## Inspect state

```bash
make list      # which skills this repo defines
make doctor    # resolved paths and current symlink state
```

## How it works

```
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

## License

[MIT](./LICENSE) — © 2026 SzuYi Huang
