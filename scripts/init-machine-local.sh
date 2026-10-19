#!/bin/sh
# Create editable per-machine files without replacing existing content.
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates/machine-local"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

create_local_file() {
    template="$TEMPLATE_DIR/$1"
    target="$2"
    if [ -e "$target" ] || [ -L "$target" ]; then
        return 0
    fi
    mkdir -p "$(dirname -- "$target")"
    # noclobber also protects a file created after the existence check.
    if (set -C; cat "$template" > "$target"); then
        echo "Created $target"
    else
        return 1
    fi
}

create_local_file config.local.toml "$CONFIG_DIR/mise/config.local.toml"
create_local_file Brewfile.local "$HOME/.Brewfile.local"
create_local_file macos.local.sh "$CONFIG_DIR/macos.local.sh"
