#!/usr/bin/env python3
"""apply-main.py — apply origin/main's home/ tree onto this machine's live files.

The repo -> live direction (reverse of propose). main's home/ tree is the
single source of truth; every machine takes merged changes in with:

  mise run apply-main      # fetch origin/main, apply tracked paths to $HOME
  mise bootstrap           # if [tools]/[dotfiles]/templates changed

A local edit that was never proposed (see propose.py) differs from main and
would be overwritten — propose it first, or recover with `mise dot rollback`.

Scope and safety:
- Only paths declared with mode = "track" in [dotfiles] of the MERGED
  home/.config/mise/config.toml are applied (template targets are rendered by
  `mise bootstrap`, not copied).
- Additions and updates only — nothing is ever deleted, so live-only files
  (lazy-lock.json, slide-deck/, ...) are untouched.
- The working tree and current branch are untouched: content is read from
  origin/main via `git archive`.
- Every applied file is watcher-tracked, so `mise dot rollback` recovers
  pre-apply versions.
"""

import io
import subprocess
import sys
import tarfile
import tempfile
import tomllib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
HOME = Path.home()


def extract_main_home(tmp: Path) -> Path:
    subprocess.run(["git", "fetch", "origin", "main"], cwd=REPO, check=True)
    archive = subprocess.run(
        ["git", "archive", "origin/main", "home"],
        cwd=REPO,
        check=True,
        stdout=subprocess.PIPE,
    )
    with tarfile.open(fileobj=io.BytesIO(archive.stdout)) as tf:
        tf.extractall(tmp, filter="data")
    return tmp / "home"


def tracked_paths(mirror: Path) -> list[str]:
    config = tomllib.loads((mirror / ".config/mise/config.toml").read_text())
    paths = []
    for target, spec in config.get("dotfiles", {}).items():
        if isinstance(spec, dict) and spec.get("mode") == "track":
            paths.append(target)
    return paths


def apply_file(src: Path, dst: Path) -> bool:
    if dst.exists() and dst.read_bytes() == src.read_bytes():
        return False
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(src.read_bytes())
    dst.chmod(src.stat().st_mode & 0o777)
    return True


def apply_path(src: Path, dst: Path) -> int:
    if src.is_file():
        return int(apply_file(src, dst))
    updated = 0
    for f in sorted(p for p in src.rglob("*") if p.is_file()):
        updated += int(apply_file(f, dst / f.relative_to(src)))
    return updated


def main() -> int:
    total = 0
    with tempfile.TemporaryDirectory() as td:
        mirror = extract_main_home(Path(td))
        for target in tracked_paths(mirror):
            rel = target.removeprefix("~/")
            src = mirror / rel
            if not src.exists():
                print(f"skip (not mirrored on main): {target}", file=sys.stderr)
                continue
            updated = apply_path(src, HOME / rel)
            if updated:
                print(f"applied: {target} ({updated} file(s))")
                total += updated
    if total:
        print(f"\n{total} file(s) updated from origin/main.")
        print("Run `mise bootstrap` if [tools]/[dotfiles]/templates changed.")
    else:
        print("live files already match origin/main.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
