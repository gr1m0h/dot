#!/usr/bin/env python3
"""Mirror explicitly tracked agent files. Preview by default; never publish."""

import argparse
import fnmatch
from pathlib import Path
import shutil
import sys
import tomllib


ROOTS = (".claude", ".codex", ".agents")
EXCLUDED = (
    ".DS_Store", "*.log", "*.jsonl", "*.sqlite*", "*.db", "*.bak",
    "*.local.*", ".env", ".env.*", "auth.json", "node_modules", "__pycache__",
    ".claude", ".codex", ".git", ".hg", ".svn", "slide-deck", "sessions", "projects", "memory",
    "memories", "cache", "backups", ".system", "plugins",
)
# These need a separately reviewed, portable representation, not raw copying.
MANUAL = {".claude/settings.json", ".codex/config.toml",
          ".codex/hooks.json", ".codex/rules/default.rules"}


def excluded(relative):
    return any(fnmatch.fnmatch(part, pattern)
               for part in relative.parts[1:] for pattern in EXCLUDED)


def reject_symlinks(path):
    if any(parent.is_symlink() for parent in (path, *path.parents)):
        raise ValueError(f"symlink path is not supported: {path}")


def targets(config, only=None):
    result = []
    for name, options in config.get("dotfiles", {}).items():
        if not name.startswith("~/"):
            continue
        relative = Path(name[2:])
        if not relative.parts or relative.parts[0] not in ROOTS:
            continue
        if only and relative.parts[0] != f".{only}":
            continue
        if len(relative.parts) < 2 or ".." in relative.parts:
            raise ValueError(f"unsafe tracking target: {name}")
        if options.get("mode") != "track":
            raise ValueError(f"agent target requires track mode: {name}")
        if relative.as_posix() in MANUAL or excluded(relative):
            print(f"MANUAL {relative}")
            continue
        result.append(relative)
    return result


def collect(base, relative):
    path = base / relative
    reject_symlinks(path)
    if not path.exists():
        return {}
    if path.is_file():
        return {relative: path}
    result = {}
    for child in sorted(path.rglob("*")):
        item = child.relative_to(base)
        if excluded(item):
            continue
        reject_symlinks(child)
        if child.is_file() and item.as_posix() not in MANUAL:
            result[item] = child
    return result


def plan(source, destination, entries):
    changes = {}
    for entry in entries:
        reject_symlinks(source / entry)
        if not (source / entry).exists():
            # An unavailable source must never erase an existing mirror.
            print(f"MISSING {entry} (preserved)")
            continue
        live = collect(source, entry)
        mirrored = collect(destination, entry)
        for relative, path in live.items():
            target = destination / relative
            reject_symlinks(target)
            if any(parent.exists() and not parent.is_dir() for parent in target.parents):
                raise ValueError(f"destination parent is not a directory: {relative}")
            if target.exists() and not target.is_file():
                raise ValueError(f"destination type conflict: {relative}")
            if not target.exists():
                changes[relative] = "ADD"
            elif path.read_bytes() != target.read_bytes() or (
                path.stat().st_mode & 0o777 != target.stat().st_mode & 0o777
            ):
                changes[relative] = "UPDATE"
        for relative in mirrored.keys() - live.keys():
            changes[relative] = "DELETE"
    return sorted(changes.items())


def apply_changes(source, destination, changes, delete=False):
    for relative, action in changes:
        target = destination / relative
        if action == "DELETE":
            if delete:
                target.unlink()
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source / relative, target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true")
    mode.add_argument("-n", "--dry-run", action="store_true")
    parser.add_argument("--only", choices=("claude", "codex", "agents"),
                        help="limit the mirror to one configuration root")
    parser.add_argument("--delete", action="store_true",
                        help="also apply the displayed deletions (otherwise preserve)")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parent.parent
    source = Path.home().resolve()
    destination = repo / "home"
    with (destination / ".config/mise/config.toml").open("rb") as stream:
        entries = targets(tomllib.load(stream), args.only)
    changes = plan(source, destination, entries)
    for relative, action in changes:
        suffix = " (preserved without --delete)" if action == "DELETE" and not args.delete else ""
        print(f"{action} {relative}{suffix}")
    print(f"{len(changes)} planned changes; {'apply' if args.apply else 'dry run'}")
    if args.apply:
        apply_changes(source, destination, changes, delete=args.delete)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
