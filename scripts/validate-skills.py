#!/usr/bin/env python3
"""Validate skill structure and metadata across the repository."""

import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
README = REPO_ROOT / "README.md"

REQUIRED_FRONTMATTER = {"name", "description"}

errors = []
warnings = []


def parse_frontmatter(path: Path) -> dict | None:
    text = path.read_text()
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    if end == -1:
        return None
    block = text[4:end]
    data = {}
    for line in block.splitlines():
        if ":" in line:
            key, _, value = line.partition(":")
            data[key.strip()] = value.strip().strip('"').strip("'")
    return data


def check_heading(path: Path) -> bool:
    text = path.read_text()
    after_fm = text
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end != -1:
            after_fm = text[end + 5:]
    return bool(re.search(r"^#\s+", after_fm, re.MULTILINE))


def check_relative_links(path: Path) -> list[str]:
    text = path.read_text()
    broken = []
    for match in re.finditer(r"\[([^\]]*)\]\(([^)]+)\)", text):
        target = match.group(2)
        if target.startswith("http") or target.startswith("#"):
            continue
        resolved = (path.parent / target).resolve()
        if not resolved.exists():
            broken.append(target)
    return broken


def get_readme_skill_names() -> set[str]:
    if not README.exists():
        return set()
    text = README.read_text()
    return set(re.findall(r"\[`([^`]+)`\]\(skills/[^)]+\)", text))


def main() -> int:
    if not SKILLS_DIR.is_dir():
        print(f"error: {SKILLS_DIR} not found")
        return 1

    skill_dirs = sorted(
        d for d in SKILLS_DIR.iterdir()
        if d.is_dir() and (d / "SKILL.md").exists()
    )

    if not skill_dirs:
        print("error: no skills found")
        return 1

    readme_skills = get_readme_skill_names()

    for skill_dir in skill_dirs:
        skill_file = skill_dir / "SKILL.md"
        dir_name = skill_dir.name
        prefix = f"skills/{dir_name}"

        fm = parse_frontmatter(skill_file)
        if fm is None:
            errors.append(f"{prefix}: missing or malformed YAML frontmatter")
            continue

        for field in REQUIRED_FRONTMATTER:
            if not fm.get(field):
                errors.append(f"{prefix}: missing required frontmatter field '{field}'")

        if fm.get("name") and fm["name"] != dir_name:
            errors.append(
                f"{prefix}: name '{fm['name']}' does not match directory '{dir_name}'"
            )

        if not check_heading(skill_file):
            warnings.append(f"{prefix}: no top-level heading after frontmatter")

        broken_links = check_relative_links(skill_file)
        for link in broken_links:
            errors.append(f"{prefix}: broken relative link '{link}'")

        if readme_skills and dir_name not in readme_skills:
            warnings.append(f"{prefix}: not listed in README skills table")

    for w in warnings:
        print(f"warning: {w}")
    for e in errors:
        print(f"error: {e}")

    if errors:
        print(f"\n{len(errors)} error(s), {len(warnings)} warning(s)")
        return 1

    print(f"ok — {len(skill_dirs)} skills validated, {len(warnings)} warning(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
