#!/bin/sh
# Statusline wrapper: ccusage + SREaaS batch indicators
# 📥 = queued tasks in ~/batch/inbox.md · ⚠ = unreported client sessions

input=$(cat)
out=$(printf '%s' "$input" | npx -y ccusage statusline 2>/dev/null)

extra=""
if [ -f "$HOME/batch/inbox.md" ]; then
  q=$(grep -c '^- \[ \] ' "$HOME/batch/inbox.md" 2>/dev/null || true)
  [ "${q:-0}" -gt 0 ] && extra="$extra | 📥 $q queued"
fi
if [ -f "$HOME/batch/unreported.md" ]; then
  u=$(grep -c '^- ' "$HOME/batch/unreported.md" 2>/dev/null || true)
  [ "${u:-0}" -gt 0 ] && extra="$extra | ⚠ $u unreported"
fi

printf '%s%s' "$out" "$extra"
