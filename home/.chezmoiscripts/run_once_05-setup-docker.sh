#!/bin/bash
set -euo pipefail

# Skip in CI environment
if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "Skipping Docker setup in CI environment"
    exit 0
fi

echo "Setting up Docker with Colima..."

# Ensure mise is available
if ! command -v mise &>/dev/null; then
    echo "Error: mise is not installed. mise tools should be installed by previous script."
    exit 1
fi

# Activate mise environment
echo "Activating mise environment..."
eval "$(mise activate bash)"

# Debug mise environment
echo "Debug: mise version: $(mise --version)"
echo "Debug: PATH after mise activate: $PATH"
echo "Debug: mise list:"
mise list || echo "Failed to list mise tools"

# Check if docker and colima are available
echo "Checking for docker command..."
if ! command -v docker &>/dev/null; then
    echo "Docker not found. Debugging mise installation..."
    echo "mise doctor:"
    mise doctor || echo "mise doctor failed"
    echo "Contents of ~/.local/share/mise/installs/:"
    ls -la ~/.local/share/mise/installs/ 2>/dev/null || echo "Directory not found"
    exit 1
fi

if ! command -v colima &>/dev/null; then
    echo "Colima not found. Please ensure mise tools are installed properly."
    echo "Run 'mise install' manually if needed."
    exit 1
fi

# Check for Lima (required by Colima)
if ! command -v limactl &>/dev/null; then
    echo "Lima (limactl) not found. Colima requires Lima to function."
    echo "Checking mise installation..."
    mise list | grep -E "lima|colima" || echo "Lima/Colima not in mise list"
    
    # Try to refresh mise environment
    echo "Refreshing mise environment..."
    eval "$(mise activate bash)"
    
    # Check if lima binary exists in mise directory
    lima_path=$(mise which limactl 2>/dev/null || echo "")
    if [ -n "$lima_path" ] && [ -f "$lima_path" ]; then
        echo "Found lima at: $lima_path"
        export PATH="$(dirname "$lima_path"):$PATH"
    else
        echo "Searching for lima installation in mise directory..."
        lima_bin=$(find ~/.local/share/mise/installs -name "limactl" 2>/dev/null | head -1)
        if [ -n "$lima_bin" ] && [ -f "$lima_bin" ]; then
            echo "Found lima at: $lima_bin"
            export PATH="$(dirname "$lima_bin"):$PATH"
        fi
    fi
    
    if ! command -v limactl &>/dev/null; then
        echo "ERROR: Lima is still not available after trying to fix PATH."
        echo "Debug information:"
        echo "- mise which limactl: $(mise which limactl 2>/dev/null || echo 'not found')"
        echo "- PATH: $PATH"
        echo "- lima installations found:"
        find ~/.local/share/mise/installs -name "limactl" 2>/dev/null || echo "No lima installations found"
        exit 1
    fi
    
    echo "Lima is now available after PATH adjustment."
fi

echo "Docker, Colima, and Lima found via mise. Proceeding with setup..."

# Start Colima if not running
if ! colima status &>/dev/null; then
    echo "Starting Colima with default configuration..."
    
    # Ensure mise environment is properly loaded before starting Colima
    echo "Re-activating mise environment before starting Colima..."
    eval "$(mise activate bash)"
    
    # Double-check that both tools are available
    if ! command -v colima &>/dev/null; then
        echo "ERROR: colima command not found after mise activation"
        exit 1
    fi
    
    if ! command -v limactl &>/dev/null; then
        echo "ERROR: limactl command not found after mise activation"
        echo "Attempting to locate and add lima to PATH..."
        
        # Try to find and add lima to PATH again
        lima_path=$(mise which limactl 2>/dev/null || echo "")
        if [ -n "$lima_path" ] && [ -f "$lima_path" ]; then
            export PATH="$(dirname "$lima_path"):$PATH"
        else
            lima_bin=$(find ~/.local/share/mise/installs -name "limactl" 2>/dev/null | head -1)
            if [ -n "$lima_bin" ] && [ -f "$lima_bin" ]; then
                export PATH="$(dirname "$lima_bin"):$PATH"
            fi
        fi
        
        if ! command -v limactl &>/dev/null; then
            echo "Still cannot find limactl after PATH adjustment"
            find ~/.local/share/mise -name "limactl" 2>/dev/null || echo "limactl not found in mise directory"
            exit 1
        fi
        
        echo "Lima PATH fixed successfully"
    fi
    
    colima start || {
        echo "Failed to start Colima. Please check logs with 'colima logs'"
        echo "Debugging information:"
        echo "- colima version: $(colima --version 2>/dev/null || echo 'unknown')"
        echo "- limactl version: $(limactl --version 2>/dev/null || echo 'unknown')"
        echo "- PATH: $PATH"
        exit 1
    }
fi

# Configure Docker context
echo "Setting up docker context to use colima..."
docker context use colima || {
    echo "Failed to set docker context to colima"
    echo "You can set it manually with 'docker context use colima'"
}

# Create docker socket link (optional, for compatibility)
if [ -S "$HOME/.config/colima/default/docker.sock" ]; then
    echo "Docker socket found. Some tools may require a symlink to /var/run/docker.sock"
    echo "If needed, run: sudo ln -sf $HOME/.config/colima/default/docker.sock /var/run/docker.sock"
fi

echo "Docker setup completed successfully!"