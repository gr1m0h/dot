#!/usr/bin/env bash
# Python 3.11+ is required for the standard-library TOML parser.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/sync-agent-configs.py" "$@"
