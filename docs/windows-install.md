# Windows installation

This setup keeps one normal Git clone as the source of truth and exposes each skill to
Codex Desktop and Claude Code Desktop with Windows directory junctions. Changes made in
the clone are visible through the junctions, so the repository can be edited, committed,
pulled, and pushed normally.

## Prerequisites

- Windows 10 or later
- Git for Windows
- PowerShell
- Codex Desktop, Claude Code Desktop, or both

## Clone the repository

Open PowerShell and run:

```powershell
$repo = Join-Path $HOME '.skill-repos\skills'
New-Item -ItemType Directory -Force (Split-Path $repo) | Out-Null
git clone https://github.com/ssuyi-tw/skills.git $repo
```

If the repository is already cloned, update it instead:

```powershell
git -C (Join-Path $HOME '.skill-repos\skills') pull --ff-only
```

## Enable skills in Codex Desktop

Codex reads personal skills from `~/.codex/skills/<name>/SKILL.md`. Create one junction
per skill so Codex's bundled `.system` skills remain untouched:

```powershell
$repoSkills = Join-Path $HOME '.skill-repos\skills\skills'
$destination = Join-Path $HOME '.codex\skills'
New-Item -ItemType Directory -Force $destination | Out-Null

Get-ChildItem $repoSkills -Directory | ForEach-Object {
    $link = Join-Path $destination $_.Name
    if (-not (Test-Path -LiteralPath $link)) {
        New-Item -ItemType Junction -Path $link -Target $_.FullName | Out-Null
    }
}
```

Restart Codex Desktop after the initial installation. Edits within an existing skill are
then available from the Git-managed source directory.

## Enable skills in Claude Code Desktop and CLI

Claude Code Desktop and the Claude Code CLI share personal skills under
`~/.claude/skills/<name>/SKILL.md`. Create equivalent junctions:

```powershell
$repoSkills = Join-Path $HOME '.skill-repos\skills\skills'
$destination = Join-Path $HOME '.claude\skills'
New-Item -ItemType Directory -Force $destination | Out-Null

Get-ChildItem $repoSkills -Directory | ForEach-Object {
    $link = Join-Path $destination $_.Name
    if (-not (Test-Path -LiteralPath $link)) {
        New-Item -ItemType Junction -Path $link -Target $_.FullName | Out-Null
    }
}
```

Claude Code watches existing skill directories for changes. If `~/.claude/skills` did not
exist when the current session started, restart Claude Code Desktop or the CLI once.

## Daily Git workflow

```powershell
$repo = Join-Path $HOME '.skill-repos\skills'
git -C $repo pull --ff-only
git -C $repo status
```

Edit files under `$repo\skills`, then validate and commit from the clone:

```powershell
git -C $repo diff --check
git -C $repo add skills docs README.md
git -C $repo commit -m "docs: update skill instructions"
git -C $repo push
```

## Add a skill

Create `skills/<skill-name>/SKILL.md`, commit it, then rerun the junction block for each
application. Existing skills update live, but a new top-level skill needs a new junction.

## Remove a skill

Remove its junctions first, then delete the source directory with Git:

```powershell
$name = 'my-skill'
Remove-Item -LiteralPath (Join-Path $HOME ".codex\skills\$name")
Remove-Item -LiteralPath (Join-Path $HOME ".claude\skills\$name")
git -C (Join-Path $HOME '.skill-repos\skills') rm -r "skills/$name"
```

`Remove-Item` removes the junction, not the source directory it targets.

## Verify

```powershell
Get-ChildItem (Join-Path $HOME '.codex\skills') |
    Where-Object LinkType -eq Junction |
    Select-Object Name, Target

Get-ChildItem (Join-Path $HOME '.claude\skills') |
    Where-Object LinkType -eq Junction |
    Select-Object Name, Target
```

Each enabled skill should point into the same Git clone.

## Existing destination conflicts

The setup intentionally does not overwrite an existing directory or junction. If a skill
name already exists at a destination, compare it with the repository version, back it up,
and remove it only after deciding which copy should be authoritative.
