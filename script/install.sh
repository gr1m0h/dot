#!/bin/sh

# Exit on error, undefined variables, and propagate errors in pipes
set -euo pipefail

# Configuration
REPO_URL="https://raw.githubusercontent.com/gr1m0h/dot/main"
TEMP_DIR=$(mktemp -d)
SCRIPT_PATH="$TEMP_DIR/setup.sh"

# Check if output supports colors
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  # Use tput for better compatibility
  COLOR_GRAY=$(tput setaf 243 || true)
  COLOR_PURPLE=$(tput setaf 5 || true)
  COLOR_RED=$(tput setaf 1 || true)
  COLOR_BLUE=$(tput setaf 4 || true)
  COLOR_GREEN=$(tput setaf 2 || true)
  COLOR_YELLOW=$(tput setaf 3 || true)
  COLOR_NONE=$(tput sgr0 || true)
  COLOR_BOLD=$(tput bold || true)
else
  COLOR_GRAY=""
  COLOR_PURPLE=""
  COLOR_RED=""
  COLOR_BLUE=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_NONE=""
  COLOR_BOLD=""
fi

title() {
  echo ""
  echo "${COLOR_BOLD}${COLOR_PURPLE}$1${COLOR_NONE}"
  echo "${COLOR_GRAY}==============================${COLOR_NONE}"
  echo ""
}

err() {
  echo "${COLOR_RED}${COLOR_BOLD}ERROR: ${COLOR_NONE}$1"
  exit 1
}

warn() {
  echo "${COLOR_YELLOW}${COLOR_BOLD}WARNING: ${COLOR_NONE}$1"
}

info() {
  echo "${COLOR_BLUE}${COLOR_BOLD}INFO: ${COLOR_NONE}$1"
}

success() {
  echo "${COLOR_GREEN}${COLOR_BOLD}$1${COLOR_NONE}"
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