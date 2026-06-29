#!/usr/bin/env bash
#
# sync-claude.sh — reflect the live ~/.claude config back into this dotfiles repo.
#
# Copies only the tracked, shareable subset of ~/.claude into home/dot_claude/.
# Runtime data (projects/, sessions/, history.jsonl, backups/, cache/ ...) and
# machine-local files (settings.local.json) are never touched.
#
# This does NOT commit anything — review the result with `git diff` and commit
# yourself. After committing & pushing, the chezmoi source still needs the usual
# `chezmoi update` / `chezmoi apply` to propagate to other machines.
#
# Usage:
#   scripts/sync-claude.sh         # sync (with --delete to mirror removals)
#   scripts/sync-claude.sh -n      # dry run: show what would change, write nothing
#
set -euo pipefail

DRY_RUN=()
case "${1:-}" in
  -n | --dry-run) DRY_RUN=(--dry-run) ;;
  "") ;;
  *)
    echo "usage: $(basename "$0") [-n|--dry-run]" >&2
    exit 2
    ;;
esac

# Resolve repo root from this script's own location (scripts/sync-claude.sh).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC="${HOME}/.claude"
DST="${REPO_ROOT}/home/dot_claude"

if [[ ! -d "$SRC" ]]; then
  echo "error: source not found: $SRC" >&2
  exit 1
fi
if [[ ! -d "$DST" ]]; then
  echo "error: destination not found: $DST" >&2
  exit 1
fi

# Tracked top-level entries — must mirror what lives in home/dot_claude/.
# settings.local.json is intentionally absent (machine-local; never synced).
ITEMS=(
  agents
  hooks
  rules
  skills
  CLAUDE.md
  settings.json
  README.md
  README_ja.md
)

# Generic excludes applied to every directory transfer.
#   slide-deck/ is gitignored in this repo, so it is excluded to avoid both
#   importing it and having --delete remove the local copy.
#   .claude/ catches nested runtime artifacts (e.g. skills/.claude/memory/*.jsonl).
EXCLUDES=(
  --exclude='.DS_Store'
  --exclude='*.log'
  --exclude='node_modules/'
  --exclude='slide-deck/'
  --exclude='.claude/'
)

echo "Syncing ~/.claude -> ${DST#"$HOME"/}"
[[ ${#DRY_RUN[@]} -gt 0 ]] && echo "(dry run — no files will be written)"
echo

for item in "${ITEMS[@]}"; do
  src_path="$SRC/$item"
  if [[ ! -e "$src_path" ]]; then
    echo "skip (missing in ~/.claude): $item" >&2
    continue
  fi

  if [[ -d "$src_path" ]]; then
    # Trailing slashes: sync directory contents and mirror deletions.
    rsync -a --delete "${EXCLUDES[@]}" ${DRY_RUN[@]+"${DRY_RUN[@]}"} \
      "$src_path/" "$DST/$item/"
  else
    rsync -a ${DRY_RUN[@]+"${DRY_RUN[@]}"} "$src_path" "$DST/$item"
  fi
  echo "  synced: $item"
done

echo
echo "Done. Review changes:"
echo "  git -C \"$REPO_ROOT\" status home/dot_claude"
echo "  git -C \"$REPO_ROOT\" diff home/dot_claude"
