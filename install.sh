#!/bin/sh
#
# Minimal installer for gr1m0h/dot using chezmoi
#
set -e

echo ""
echo "====================================="
echo "    gr1m0h/dot chezmoi installer"
echo "====================================="
echo ""

# Check if chezmoi is installed
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Installing chezmoi..."
    
    # Detect OS and architecture
    OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m)"
    
    case "$ARCH" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    # Install chezmoi
    if [ "$OS" = "darwin" ]; then
        # Try to use Homebrew if available
        if command -v brew >/dev/null 2>&1; then
            brew install chezmoi
        else
            # Install using the official script
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
            export PATH="$HOME/bin:$PATH"
        fi
    else
        # Linux or other Unix-like systems
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
        export PATH="$HOME/bin:$PATH"
    fi
fi

# Verify chezmoi is available
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Error: chezmoi installation failed"
    exit 1
fi

echo "chezmoi is installed at: $(which chezmoi)"
echo ""

# Initialize and apply dotfiles
echo "Initializing dotfiles from gr1m0h/dot..."
# Use the current branch if available, otherwise use main
BRANCH="${CHEZMOI_BRANCH:-main}"
chezmoi init --apply --branch "$BRANCH" gr1m0h/dot

echo ""
echo "====================================="
echo "    Installation completed!"
echo "====================================="
echo ""
echo "Your dotfiles have been installed. You may need to:"
echo "  1. Restart your terminal for all changes to take effect"
echo "  2. Create ~/.env file with your personal tokens (e.g., GITHUB_PAT)"
echo ""
echo "To update your dotfiles later, run:"
echo "  chezmoi update"
echo ""