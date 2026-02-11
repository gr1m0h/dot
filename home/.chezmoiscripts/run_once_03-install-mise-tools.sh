#!/bin/bash
set -euo pipefail

# Skip in CI environment
if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "Skipping mise tools installation in CI environment"
    exit 0
fi

echo "Installing mise tools..."

# Ensure mise is available
if ! command -v mise &>/dev/null; then
    echo "Error: mise is not installed. Please run brew bundle first."
    exit 1
fi

if [ ! -f "$HOME/.config/mise/config.toml" ]; then
    echo "mise config not found, diagnosing..."
    
    # Debug mise config location
    echo "=== mise Config Debug ==="
    echo "Checking .config directory:"
    ls -la ~/.config/ 2>/dev/null || echo ".config directory not found"
    
    echo "Looking for mise config in chezmoi source:"
    find ~/.local/share/chezmoi -path "*/mise/*" -name "*.toml" 2>/dev/null || echo "No mise config in source"
    
    echo "Checking chezmoi source structure:"
    find ~/.local/share/chezmoi -type d -name "*config*" 2>/dev/null || echo "No config directories in source"
    
    # Try manual copy as fallback
    if [ -f ~/.local/share/chezmoi/home/dot_config/mise/config.toml ]; then
        echo "Found mise config in source, copying manually..."
        mkdir -p "$HOME/.config/mise"
        cp ~/.local/share/chezmoi/home/dot_config/mise/config.toml "$HOME/.config/mise/config.toml"
    else
        echo "No mise config found in chezmoi source"
        echo "Looking for alternative config files..."
        find ~/.local/share/chezmoi -name "*.toml" | head -10
        echo "Skipping mise tools installation"
        exit 0
    fi
fi

echo "mise config found, proceeding with installation"
echo "Config contents:"
head -10 "$HOME/.config/mise/config.toml"

# Install all mise tools
echo "Running mise install..."
mise install

# Activate mise for current shell
eval "$(mise activate bash)"

echo "mise tools installed successfully!"