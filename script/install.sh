#!/bin/sh

# Exit on error, undefined variables, and propagate errors in pipes
set -euo pipefail

# Configuration
REPO_URL="https://raw.githubusercontent.com/gr1m0h/dot/main"
TEMP_DIR=$(mktemp -d)
SCRIPT_PATH="$TEMP_DIR/setup.sh"

title() {
  echo ""
  echo "===== $1 ====="
  echo ""
}

err() {
  echo "[ERROR] $1"
  exit 1
}

warn() {
  echo "[WARNING] $1"
}

info() {
  echo "[INFO] $1"
}

success() {
  echo "[SUCCESS] $1"
}

cleanup() {
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo ""
echo "========================================="
echo "       gr1m0h/dot installer"
echo "========================================="
echo ""

# Check if running in non-interactive mode (piped)
if [ ! -t 0 ] || [ ! -t 1 ]; then
  # Check for command line arguments
  COMPONENT="${1:-all}"
  
  # If trying to install homebrew in non-interactive mode, re-execute interactively
  if [ "$COMPONENT" = "all" ] || [ "$COMPONENT" = "homebrew" ]; then
    echo ""
    warn "Detected non-interactive mode. Homebrew installation requires interactive mode."
    info "Automatically switching to interactive installation..."
    echo ""
    
    # Download the script to a temporary location and execute it
    TEMP_INSTALL_SCRIPT=$(mktemp)
    info "Downloading installer for interactive execution..."
    
    if curl -fsSL "$REPO_URL/script/install.sh" -o "$TEMP_INSTALL_SCRIPT"; then
      chmod +x "$TEMP_INSTALL_SCRIPT"
      info "Launching interactive installer..."
      echo ""
      # Execute the script interactively
      exec sh "$TEMP_INSTALL_SCRIPT" "$COMPONENT"
    else
      err "Failed to download installer for interactive mode"
    fi
  fi
fi

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
    echo ""
    echo "Usage: $(basename "$0") {dotfiles|homebrew|macos|docker|mcp|serena|all}"
    echo "Default: all"
    echo ""
    echo "Examples:"
    echo "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh"
    echo "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s dotfiles"
    echo "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s mcp"
    exit 1
    ;;
esac