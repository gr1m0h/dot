#!/usr/bin/env bash
# Compatibility entry point: same shared target list and exclusions.
# No arguments still applies additions/updates; deletions now require --delete.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ $# -eq 0 ]]; then
  set -- --apply
fi
exec bash "$SCRIPT_DIR/sync-agent-configs.sh" --only claude "$@"
