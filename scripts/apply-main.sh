#!/usr/bin/env bash
# Apply tracked files from origin/main, or selected agents from this checkout.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/dotfiles-lib.sh"
dot_init
local_source=0
agents_only=0
choice=''
while [[ $# -gt 0 ]]; do
    case "$1" in
        --local) local_source=1; shift ;;
        --agents-only) agents_only=1; shift ;;
        --agents) [[ $# -ge 2 ]] || dot_error '--agents requires a value'; choice="$2"; shift 2 ;;
        *) dot_error "Unknown argument: $1" ;;
    esac
done
dot_select "$choice"
if [[ "$local_source" == 1 ]]; then
    mirror="$DOT_REPO/home"
else
    git -C "$DOT_REPO" fetch origin main
    git -C "$DOT_REPO" archive origin/main home > "$DOT_WORK/main.tar"
    tar -xf "$DOT_WORK/main.tar" -C "$DOT_WORK"
    mirror="$DOT_WORK/home"
fi
if [[ "$agents_only" == 1 ]]; then
    dot_agent_targets > "$DOT_WORK/targets"
else
    dot_tracked "$mirror/.config/mise/config.toml" > "$DOT_WORK/common"
    { cat "$DOT_WORK/common"; dot_agent_targets; } | LC_ALL=C sort -u > "$DOT_WORK/targets"
fi
# Build and validate the entire file list before modifying destinations.
: > "$DOT_WORK/files"
while IFS= read -r relative; do
    dot_validate "$relative"
    dot_enabled "$relative" || continue
    if [[ ! -e "$mirror/$relative" && ! -L "$mirror/$relative" ]]; then
        printf 'skip (not mirrored): ~/%s\n' "$relative" >&2
        continue
    fi
    dot_files "$mirror" "$relative" >> "$DOT_WORK/files"
done < "$DOT_WORK/targets"
while IFS= read -r -d '' relative; do
    dot_no_symlinks "$DOT_HOME/$relative"
    [[ ! -e "$DOT_HOME/$relative" || -f "$DOT_HOME/$relative" ]] || dot_error "Destination type conflict: $relative"
done < "$DOT_WORK/files"
count=0
while IFS= read -r -d '' relative; do
    if dot_copy "$mirror/$relative" "$DOT_HOME/$relative"; then
        printf 'applied: ~/%s\n' "$relative"
        count=$((count + 1))
    fi
done < "$DOT_WORK/files"
if [[ "$agents_only" == 1 ]]; then dot_migrate; fi
dot_save
printf '%s file(s) updated; agents=%s.\n' "$count" "$DOT_AGENT"
