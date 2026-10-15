#!/usr/bin/env python3
"""propose.py — mirror this machine's live tracked files into the repo's home/.

The live -> repo direction (reverse of apply-main). main's home/ tree is the
single source of truth, and this script is how a local edit gets there:

  mise run propose         # copy tracked live files into <repo>/home/
  git diff                 # review
  git switch -c <branch> && git add -A && git commit && gh pr create

Scope and safety:
- Only paths declared with mode = "track" in [dotfiles] of the LIVE
  ~/.config/mise/config.toml are mirrored.
- Additions and updates only — nothing is deleted from home/ (remove files
  with git when a deletion is intended).
- Files matched by the repo's .gitignore (slide-deck assets, lazy-lock.json,
  runtime artifacts, ...) are skipped entirely so they never reach the
  working tree.
- Nothing is staged or committed; the result is reviewed as a normal git
  diff.
"""

import subprocess
import sys
import tomllib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
HOME = Path.home()


def tracked_paths() -> list[str]:
    config = tomllib.loads((HOME / ".config/mise/config.toml").read_text())
    paths = []
    for target, spec in config.get("dotfiles", {}).items():
        if isinstance(spec, dict) and spec.get("mode") == "track":
            paths.append(target)
    return paths


def candidate_files(target: str) -> list[tuple[Path, Path]]:
    """(live file, repo destination) pairs for one tracked path."""
    rel = target.removeprefix("~/")
    src = HOME / rel
    if not src.exists():
        print(f"skip (missing live): {target}", file=sys.stderr)
        return []
    if src.is_file():
        return [(src, REPO / "home" / rel)]
    return [
        (f, REPO / "home" / rel / f.relative_to(src))
        for f in sorted(p for p in src.rglob("*") if p.is_file())
        if f.name != ".DS_Store"
    ]


def ignored_destinations(dests: list[Path]) -> set[Path]:
    relpaths = [str(d.relative_to(REPO)) for d in dests]
    out = subprocess.run(
        ["git", "check-ignore", "--stdin"],
        cwd=REPO,
        input="\n".join(relpaths),
        capture_output=True,
        text=True,
    )
    return {REPO / line for line in out.stdout.splitlines() if line}


def main() -> int:
    pairs = [p for target in tracked_paths() for p in candidate_files(target)]
    ignored = ignored_destinations([dst for _, dst in pairs])
    updated = 0
    skipped = 0
    for src, dst in pairs:
        if dst in ignored:
            skipped += 1
            continue
        if dst.exists() and dst.read_bytes() == src.read_bytes():
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(src.read_bytes())
        dst.chmod(src.stat().st_mode & 0o777)
        print(f"mirrored: {dst.relative_to(REPO)}")
        updated += 1
    if skipped:
        print(f"({skipped} gitignored file(s) skipped)")
    if updated:
        print(f"\n{updated} file(s) mirrored into home/.")
        print("Review with `git diff`, then open a PR.")
    else:
        print("home/ already matches the live tracked files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
