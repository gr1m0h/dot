#!/bin/bash
set -euo pipefail

# Skip if Homebrew is already installed
if command -v brew &>/dev/null; then
    echo "Homebrew already installed at: $(which brew)"
    exit 0
fi

echo "Installing Homebrew..."

# Install Homebrew (macOS only)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH based on architecture
case "$(uname -m)" in
    arm64)
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        ;;
    x86_64)
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
        ;;
esac

echo "Homebrew installed successfully!"