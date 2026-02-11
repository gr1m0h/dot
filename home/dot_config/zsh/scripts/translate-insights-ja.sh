#!/bin/bash

# Script to convert Claude Code Insights HTML to Japanese
#
# Usage:
#   translate-insights-ja.sh              # Full-text search with 'claude -p'
#   translate-insights-ja.sh --file PATH  # Specify target files
#   translate-insights-ja.sh --in-place   # Overwrite original files directly
#
# Note:
#   By default, output as report_ja.html, and the original file is not modified.

set -euo pipefail

REPORT="${HOME}/.claude/usage-data/report.html"

show_usage() {
  cat <<EOF
Usage: $(basename "$0") [Options]

Options:
  --file PATH   Specify the target HTML file ( default: ~/.claude/usage-data/report.html)
  --in-place    Overwrite the original file directly (default: output as a separate file named 'reportt_ja.html')
  --dry-run     Preview changes (no file modification)
  --help        Display help

e.g.,:
  $(basename "$0")              # Output as 'report_ja.html'
  $(basename "$0") --in-place   # Overwrite 'report.html' directly
EOF
  exit 0
}

# Argument parsing
DRY_RUN=false
IN_PLACE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
  --file)
    REPORT="$2"
    shift 2
    ;;
  --in-place)
    IN_PLACE=true
    shift
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --help) show_usage ;;
  *)
    echo "Error: Unknown option: $1"
    show_usage
    ;;
  esac
done

# Check for file existence
if [[ ! -f "$REPORT" ]]; then
  echo "Error: File not found: $REPORT"
  echo "Please run 'claude insights' first"
  exit 1
fi

# Determine output destination
if [[ "$IN_PLACE" == true ]]; then
  OUTPUT="$REPORT"
else
  OUTPUT="${REPORT%.html}_ja.html"
fi

if ! command -v claude &>/dev/null; then
  echo "Error: claude CLI not found"
  exit 1
fi

echo "Translating full text (claude -p)..."

PROMPT='Translate all text content in the following HTML file to Japanese
Rules:
1. Do not change HTML structure, CSS styles, Javascript functions
2. Translate only visible text
3. Keep technical tool names(Bash, Read, Edit, Glob, Grep, WebSearch, Write, WebFetch...) in English
4. Keep programming language names(JavaScript, Ruby, Go, Python...) in English
5. Change <html lang="en"> to <html lang="ja">
6. Output only HTML code, without explanations or code fences
7. Do not translate any of the following copyable elements, keep them in their original English:
- Text within <code class="cmd-code"> (instructions for adding to CLAUDE.md)
- Text within <code class="example-code"> (Settings/Code snippets)
- Text within <code class="copyable-prompt"> (prompt to paste into Claude Code)
- data-text attribute value of input element (copyable text for checkbox)'

if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] Execute translation in 'claude -p'"
  echo "[dry-run] Inout: $REPORT → $OUTPUT"
  exit 0
fi

TMPFILE=$(mktemp /tmp/claude/insights-ja-XXXXXX.html)
if claude -p "$PROMPT" <"$REPORT" >"$TMPFILE" 2>/dev/null; then
  # Simple check to see if the output is HTML
  if head -5 "$TMPFILE" | grep -q '<!DOCTYPE\|<html'; then
    mv "$TMPFILE" "$OUTPUT"
    echo "Translation complete: $OUTPUT"
  else
    echo "Error: claude's output is not HTML"
    echo "Check output: $TMPFILE"
    exit 1
  fi
else
  echo "Error: Failed to execute 'claude -p'"
  rm -f "$TMPFILE"
  exit 1
fi
exit 0
