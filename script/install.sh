#!/bin/sh

# Exit on error, undefined variables, and propagate errors in pipes
set -euo pipefail

# Configuration
REPO_URL="https://raw.githubusercontent.com/gr1m0h/dot/main"
TEMP_DIR=$(mktemp -d)
SCRIPT_PATH="$TEMP_DIR/setup.sh"

# Color definitions
COLOR_GRAY="\033[1;38;5;243m"
COLOR_PURPLE="\033[1;35m"
COLOR_RED="\033[1;31m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
  printf "\n%s\n" "${COLOR_PURPLE}$1${COLOR_NONE}"
  printf "%s\n\n" "${COLOR_GRAY}==============================${COLOR_NONE}"
}

err() {
  printf "%s\n" "${COLOR_RED}ERROR: ${COLOR_NONE}$1"
  exit 1
}

info() {
  printf "%s\n" "${COLOR_BLUE}INFO: ${COLOR_NONE}$1"
}

success() {
  printf "%s\n" "${COLOR_GREEN}$1${COLOR_NONE}"
}

cleanup() {
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

title "gr1m0h/dot installer"

info "Downloading setup script..."
if ! curl -fsSL "$REPO_URL/script/setup.sh" -o "$SCRIPT_PATH"; then
  err "Failed to download setup script"
fi

chmod +x "$SCRIPT_PATH"

# Check for command line arguments
COMPONENT="${1:-all}"
case "$COMPONENT" in
  dotfiles|homebrew|macos|docker|mcp|serena|all)
    info "Running setup with option: $COMPONENT"
    if "$SCRIPT_PATH" "$COMPONENT"; then
      success "Installation completed successfully!"
    else
      warn "Installation completed with some errors"
      info "You can check ~/.setup-state.d for progress and re-run to retry failed steps"
      info "To reset and start fresh: rm -rf ~/.setup-state.d"
      # Exit with non-zero but don't use err() to avoid abrupt termination
      exit 1
    fi
    ;;
  *)
    printf "\nUsage: %s {dotfiles|homebrew|macos|docker|mcp|serena|all}\n" "$(basename "$0")"
    printf "Default: all\n\n"
    printf "Examples:\n"
    printf "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh\n"
    printf "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s dotfiles\n"
    printf "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s mcp\n"
    exit 1
    ;;
esac