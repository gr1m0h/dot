#!/bin/sh
#
# Minimal installer for gr1m0h/dot using mise dotfiles
#
set -e

echo ""
echo "====================================="
echo "    gr1m0h/dot mise installer"
echo "====================================="
echo ""

# Install mise if missing
if ! command -v mise >/dev/null 2>&1; then
    echo "Installing mise..."
    if command -v brew >/dev/null 2>&1; then
        brew install mise
    else
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

if ! command -v mise >/dev/null 2>&1; then
    echo "Error: mise installation failed"
    exit 1
fi

echo "mise is installed at: $(command -v mise)"
echo ""

# NOTE: provide per-PC secrets BEFORE adopting (see README "Secrets"):
#   ~/.env  ->  export NOTION_TOKEN="..."   (sourced by ~/.zshenv)

# Adopt dotfiles from the mise-sync branch, then run full machine setup.
echo "Adopting dotfiles from gr1m0h/dot (mise-sync branch)..."
mise bootstrap --adopt ssh://git@github.com/gr1m0h/dot.git

echo "Running machine setup (Homebrew, packages, macOS, Docker, MCP)..."
mise bootstrap

echo ""
echo "====================================="
echo "    Installation completed!"
echo "====================================="
echo ""
echo "Restart your terminal for all changes to take effect."
echo "To sync later:   mise bootstrap dotfiles sync && mise bootstrap dotfiles pull"
