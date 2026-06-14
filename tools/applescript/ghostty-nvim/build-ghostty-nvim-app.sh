#!/usr/bin/env bash
# Build Ghostty-Nvim.app from a rendered AppleScript and install it to ~/Applications.
#
# Usage:
#   build-ghostty-nvim-app.sh [APPLESCRIPT]
#
# APPLESCRIPT defaults to the chezmoi-managed copy at
# ~/.local/share/chezmoi-scripts/Ghostty-Nvim.applescript (deployed by
# `chezmoi apply`). The script is also invoked by
# home/.chezmoiscripts/run_onchange_07-setup-ghostty-nvim-app.sh.tmpl.

set -euo pipefail

APPLESCRIPT="${1:-${HOME}/.local/share/chezmoi-scripts/Ghostty-Nvim.applescript}"

if [ ! -f "$APPLESCRIPT" ]; then
    echo "❌ AppleScript not found: $APPLESCRIPT" >&2
    echo "   Run 'chezmoi apply' first, or pass an explicit path." >&2
    exit 1
fi

if [ "$(uname)" != "Darwin" ]; then
    echo "Skipping Ghostty-Nvim.app build (non-macOS)"
    exit 0
fi

APP_NAME="Ghostty-Nvim.app"
INSTALL_DIR="${HOME}/Applications"
APP_PATH="${INSTALL_DIR}/${APP_NAME}"
PLIST_PATH="${APP_PATH}/Contents/Info.plist"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "🚀 Building ${APP_NAME} from ${APPLESCRIPT}"
osacompile -o "${TEMP_DIR}/${APP_NAME}" "$APPLESCRIPT"

mkdir -p "$INSTALL_DIR"

# Replace any previous build (and stale WezTerm-Nvim.app left from the old setup).
rm -rf "$APP_PATH" "${INSTALL_DIR}/WezTerm-Nvim.app"

mv "${TEMP_DIR}/${APP_NAME}" "$APP_PATH"

echo "⚙️  Configuring file associations..."
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$PLIST_PATH" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array" "$PLIST_PATH"

EXTENSIONS=(
    # Text
    "txt" "md" "markdown" "rst"
    # Languages
    "lua" "vim" "vimrc"
    "js" "jsx" "ts" "tsx" "mjs" "cjs"
    "py" "pyw" "pyi"
    "rb" "rake" "ru" "gemspec"
    "go" "mod" "sum"
    "rs" "toml"
    "c" "h" "cpp" "hpp" "cc" "cxx"
    "java"
    "sh" "bash" "zsh" "fish"
    # Config
    "yml" "yaml" "json" "jsonc" "json5"
    "xml" "plist" "ini" "cfg" "conf"
    "env" "gitignore" "gitconfig"
    "dockerfile" "dockerignore"
    # Web
    "html" "htm" "css" "scss" "sass" "less"
    "php"
    # Misc
    "sql" "graphql" "proto"
)

for i in "${!EXTENSIONS[@]}"; do
    /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:$i string '${EXTENSIONS[$i]}'" "$PLIST_PATH"
done

/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string 'Text Files'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string 'Editor'" "$PLIST_PATH"

/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string 'com.local.ghostty-nvim'" "$PLIST_PATH" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier 'com.local.ghostty-nvim'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleName string 'Ghostty-Nvim'" "$PLIST_PATH" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleName 'Ghostty-Nvim'" "$PLIST_PATH"

echo "🔄 Updating LaunchServices..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_PATH"

# Strip Gatekeeper quarantine so it can be launched without manual approval.
xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

echo "✅ ${APP_NAME} installed to ${APP_PATH}"
