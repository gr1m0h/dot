#!/usr/bin/env bash
# Preview selected portable agent files. Deletions require --apply --delete.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/dotfiles-lib.sh"
dot_init
apply=0
delete=0
only=''
mode=''
while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply) [[ "$mode" != dry ]] || dot_error '--apply and --dry-run conflict'; mode=apply; apply=1; shift ;;
        -n|--dry-run) [[ "$mode" != apply ]] || dot_error '--apply and --dry-run conflict'; mode=dry; apply=0; shift ;;
        --delete) delete=1; shift ;;
        --only) [[ $# -ge 2 ]] || dot_error '--only requires a value'; only="$2"; shift 2 ;;
        *) dot_error "Unknown argument: $1" ;;
    esac
done
case "$only" in ''|codex|claude|agents) ;; *) dot_error 'Invalid --only value' ;; esac
dot_select
dot_tracked "$DOT_REPO/home/.config/mise/config.toml" > "$DOT_WORK/common"
{ cat "$DOT_WORK/common"; dot_agent_targets; } | LC_ALL=C sort -u > "$DOT_WORK/targets"
: > "$DOT_WORK/plan"
while IFS= read -r relative; do
    case "$relative" in .codex|.claude|.agents) dot_error "Unsafe root target: $relative" ;; .codex/*|.claude/*|.agents/*) ;; *) continue ;; esac
    dot_enabled "$relative" || continue
    [[ -z "$only" || "${relative%%/*}" == ".$only" ]] || continue
    dot_portable "$relative" || continue
    dot_manual "$relative" && continue
    dot_no_symlinks "$DOT_HOME/$relative"
    if [[ ! -e "$DOT_HOME/$relative" ]]; then
        printf 'MISSING %s (preserved)\n' "$relative"
        continue
    fi
    dot_files "$DOT_HOME" "$relative" > "$DOT_WORK/live"
    dot_files "$DOT_REPO/home" "$relative" > "$DOT_WORK/mirrored"
    while IFS= read -r -d '' item; do
        dot_manual "$item" && continue
        dot_no_symlinks "$DOT_REPO/home/$item"
        [[ ! -e "$DOT_REPO/home/$item" || -f "$DOT_REPO/home/$item" ]] || dot_error "Destination type conflict: $item"
        if [[ ! -f "$DOT_REPO/home/$item" ]]; then action=ADD
        elif ! dot_same "$DOT_HOME/$item" "$DOT_REPO/home/$item"; then action=UPDATE
        else continue
        fi
        printf '%s\0%s\0' "$action" "$item" >> "$DOT_WORK/plan"
    done < "$DOT_WORK/live"
    while IFS= read -r -d '' item; do
        dot_manual "$item" && continue
        [[ ! -e "$DOT_HOME/$item" ]] || continue
        printf 'DELETE\0%s\0' "$item" >> "$DOT_WORK/plan"
    done < "$DOT_WORK/mirrored"
done < "$DOT_WORK/targets"
while IFS= read -r -d '' action && IFS= read -r -d '' item; do
    printf '%s %s' "$action" "$item"
    if [[ "$action" == DELETE && "$delete" == 0 ]]; then printf ' (preserved without --delete)'; fi
    printf '\n'
done < "$DOT_WORK/plan"
if [[ "$apply" == 1 ]]; then
    while IFS= read -r -d '' action && IFS= read -r -d '' item; do
        if [[ "$action" == DELETE ]]; then
            if [[ "$delete" == 1 ]]; then rm -- "$DOT_REPO/home/$item"; fi
        else
            dot_copy "$DOT_HOME/$item" "$DOT_REPO/home/$item" || true
        fi
    done < "$DOT_WORK/plan"
fi
