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

# Template rendering (git config, mmcp) reads per-PC secrets from ~/.env.
# A zsh session gets it via ~/.zshenv, but this script runs under sh — source
# it explicitly. Without it `mise bootstrap` dies at the dotfiles phase,
# before any package is installed, so check up front.
if [ ! -f "$HOME/.env" ]; then
    cat <<'MSG'
Error: ~/.env not found — create it first, then rerun this script:

  cat > ~/.env <<'EOF'
export NOTION_TOKEN="ntn_xxx"
export GIT_NAME="..."
export GIT_EMAIL="..."
export GIT_SIGNINGKEY="ssh-ed25519 ..."
EOF
MSG
    exit 1
fi
# shellcheck disable=SC1091
. "$HOME/.env"

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

echo "Applying main's home/ tree onto \$HOME..."
python3 -B "$REPO_DIR/scripts/apply-main.py"

echo "Preparing machine-local configuration (preserving existing files)..."
sh "$REPO_DIR/scripts/init-machine-local.sh"

# gcloud's install script requires python >= 3.10, but a fresh mac only has
# the CLT 3.9 until mise's python lands — and the parallel tools phase lets
# gcloud race ahead of it, killing the whole bootstrap. Install python first
# and point gcloud's installer at it (CLOUDSDK_PYTHON is honored by the
# script; PATH makes plain python3 resolve to it as well).
echo "Installing python first (gcloud's installer needs >= 3.10)..."
mise install python
MISE_PY_BIN="$(mise where python)/bin"
PATH="$MISE_PY_BIN:$PATH"
CLOUDSDK_PYTHON="$MISE_PY_BIN/python3"
export PATH CLOUDSDK_PYTHON

# Install Homebrew here, not inside bootstrap: mise runs tasks in parallel
# with stdin detached, so the Homebrew installer's sudo can never prompt
# there (observed: setup-homebrew died on "stdin is not a TTY"). From this
# script we can hand it the real terminal; the setup-homebrew task then sees
# brew installed and skips.
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew (sudo will ask for your password)..."
    if [ -r /dev/tty ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
    else
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Running machine setup (packages, macOS, templates, tools)..."
# --yes: when this script is piped into a shell, stdin is the script itself,
# so an interactive mise prompt would consume script text as its answer.
if [ -r /dev/tty ]; then
    mise bootstrap --yes </dev/tty
else
    mise bootstrap --yes
fi

echo ""
echo "====================================="
echo "    Installation completed!"
echo "====================================="
echo ""
echo "Restart your terminal for all changes to take effect."
echo "Daily loop:  mise run propose  (share via PR)  /  mise run apply-main  (take in)"
