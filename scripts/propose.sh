#!/usr/bin/env bash
# Mirror selected live files into home/. Never stage, commit, or delete.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/dotfiles-lib.sh"
dot_init
[[ $# -eq 0 ]] || dot_error 'Usage: bash scripts/propose.sh'
dot_select
dot_tracked "$DOT_CONFIG/mise/config.toml" > "$DOT_WORK/common"
{ cat "$DOT_WORK/common"; dot_agent_targets; } | LC_ALL=C sort -u > "$DOT_WORK/targets"
: > "$DOT_WORK/files"
while IFS= read -r relative; do
    dot_enabled "$relative" || continue
    dot_files "$DOT_HOME" "$relative" >> "$DOT_WORK/files"
done < "$DOT_WORK/targets"
: > "$DOT_WORK/plan"
while IFS= read -r -d '' relative; do
    # check-ignore status 1 means not ignored; other errors must not be hidden.
    if git -C "$DOT_REPO" check-ignore -q -- "home/$relative"; then continue; else
        status=$?; [[ "$status" == 1 ]] || dot_error 'git check-ignore failed'
    fi
    dot_no_symlinks "$DOT_REPO/home/$relative"
    [[ ! -e "$DOT_REPO/home/$relative" || -f "$DOT_REPO/home/$relative" ]] || dot_error "Destination type conflict: $relative"
    printf '%s\0' "$relative" >> "$DOT_WORK/plan"
done < "$DOT_WORK/files"
count=0
while IFS= read -r -d '' relative; do
    if dot_copy "$DOT_HOME/$relative" "$DOT_REPO/home/$relative"; then
        printf 'mirrored: home/%s\n' "$relative"
        count=$((count + 1))
    fi
done < "$DOT_WORK/plan"
printf '%s file(s) mirrored. Review with git diff.\n' "$count"
