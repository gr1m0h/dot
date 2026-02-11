#!/bin/bash
set -euo pipefail

echo "Installing packages from Brewfile..."

# Ensure brew is available
if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is not installed"
    exit 1
fi

# Check if Brewfile exists
echo "Debug: Looking for Brewfile at $HOME/Brewfile"
echo "Debug: Contents of home directory:"
ls -la "$HOME/" | grep -E "(Brewfile|\.)"
if [ ! -f "$HOME/Brewfile" ]; then
    echo "No Brewfile found at $HOME/Brewfile"
    echo "Diagnosing chezmoi configuration..."
    
    # Debug chezmoi state
    echo "=== chezmoi Debug Information ==="
    echo "chezmoi source directory:"
    ls -la ~/.local/share/chezmoi/ 2>/dev/null || echo "Source directory not found"
    
    echo "chezmoi managed files:"
    timeout 10 chezmoi managed 2>/dev/null || echo "Failed to get managed files"
    
    echo "chezmoi data:"
    timeout 10 chezmoi data 2>/dev/null || echo "Failed to get chezmoi data"
    
    echo "Trying manual apply..."
    timeout 30 chezmoi apply --dry-run 2>/dev/null || echo "Dry run failed"
    
    echo "Checking source files:"
    find ~/.local/share/chezmoi -name "*Brewfile*" 2>/dev/null || echo "No Brewfile in source"
    
    echo "=== End Debug ==="
    
    # Try manual copy as fallback
    if [ -f ~/.local/share/chezmoi/home/Brewfile ]; then
        echo "Found Brewfile in source, copying manually..."
        cp ~/.local/share/chezmoi/home/Brewfile "$HOME/Brewfile"
    elif [ -f ~/.local/share/chezmoi/Brewfile ]; then
        echo "Found Brewfile in root, copying manually..."
        cp ~/.local/share/chezmoi/Brewfile "$HOME/Brewfile"
    else
        echo "No Brewfile found in chezmoi source, skipping package installation"
        exit 0
    fi
fi

# Install from Brewfile
brew bundle --file="$HOME/Brewfile"

echo "Homebrew packages installed successfully!"