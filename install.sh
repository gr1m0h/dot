#!/bin/sh
#
# Minimal installer for gr1m0h/dot — one command on a new machine:
#
#   curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/install.sh | sh
#
# main's home/ tree is the single source of truth: this script installs mise,
# clones the repository, materialises home/ onto $HOME (apply-main), then runs
# the full machine setup (mise bootstrap).
#
set -e

REPO_HTTPS="https://github.com/gr1m0h/dot.git"
REPO_DIR="$HOME/Documents/workspace/github.com/gr1m0h/dot"

echo ""
echo "====================================="
echo "    gr1m0h/dot installer"
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

# Clone (or update) the repository
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Cloning gr1m0h/dot..."
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_HTTPS" "$REPO_DIR"
else
    echo "Repository already present; updating to origin/main..."
    git -C "$REPO_DIR" fetch origin main
    # Fast-forward the working tree too — apply-main.py runs from it, so a
    # fetch alone would keep executing the stale checkout.
    git -C "$REPO_DIR" checkout main
    if ! git -C "$REPO_DIR" merge --ff-only origin/main; then
        echo "Warning: local main has diverged from origin/main; using it as-is"
    fi
fi

# NOTE: template rendering (git config, mmcp) reads per-PC secrets from
# ~/.env (sourced by ~/.zshenv) — see README "Secrets". Create it before or
# after this script and rerun `mise bootstrap`:
#   export NOTION_TOKEN=... GIT_NAME=... GIT_EMAIL=... GIT_SIGNINGKEY=...

echo "Applying main's home/ tree onto \$HOME..."
python3 -B "$REPO_DIR/scripts/apply-main.py"

echo "Running machine setup (Homebrew, packages, macOS, templates, tools)..."
mise bootstrap

echo ""
echo "====================================="
echo "    Installation completed!"
echo "====================================="
echo ""
echo "Restart your terminal for all changes to take effect."
echo "Daily loop:  mise run propose  (share via PR)  /  mise run apply-main  (take in)"
