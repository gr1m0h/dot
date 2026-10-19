#!/usr/bin/env bash
# Isolated integration checks. No Python, live writes, or network.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-tests.XXXXXX")"
TEMP="$(cd "$TEMP" && pwd -P)"
trap 'rm -rf -- "$TEMP"' EXIT
export HOME="$TEMP/live home"
export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$HOME"
export MISE_OFFLINE=1 MISE_TASK_RUN_AUTO_INSTALL=false
export MISE_DATA_DIR="$TEMP/data" MISE_STATE_DIR="$TEMP/state" MISE_CACHE_DIR="$TEMP/cache"
export MISE_GLOBAL_CONFIG_FILE="$XDG_CONFIG_HOME/mise/config.toml"
# Any accidental return to Python must fail, even if Python is installed.
mkdir -p "$TEMP/bin"
cat > "$TEMP/bin/python3" <<'STUB'
#!/bin/sh
echo 'Python must not be called by dotfile scripts' >&2
exit 99
STUB
cp "$TEMP/bin/python3" "$TEMP/bin/python"
chmod +x "$TEMP/bin/python" "$TEMP/bin/python3"
export PATH="$TEMP/bin:$PATH"
FIXTURE="$TEMP/repo space"
mkdir -p "$FIXTURE/scripts" "$FIXTURE/home/.config/mise"
cp "$ROOT"/scripts/{dotfiles-lib,apply-main,propose,sync-agent-configs}.sh "$FIXTURE/scripts/"
git -C "$FIXTURE" init -q
printf 'home/.agents/**/.env\n' > "$FIXTURE/.gitignore"
printf '[dotfiles]\n"~/.config/custom" = { mode = "track" }\n' > "$FIXTURE/home/.config/mise/config.toml"
mkdir -p "$FIXTURE/home/.codex" "$FIXTURE/home/.claude" "$FIXTURE/home/.agents/skills/example"
printf 'codex\n' > "$FIXTURE/home/.codex/AGENTS.md"
printf 'claude\n' > "$FIXTURE/home/.claude/CLAUDE.md"
printf 'skill\n' > "$FIXTURE/home/.agents/skills/example/SKILL.md"
printf 'secret fixture\n' > "$FIXTURE/home/.agents/skills/example/.env"
mkdir -p "$XDG_CONFIG_HOME/mise" "$XDG_CONFIG_HOME/custom"
printf 'preserve\n' > "$XDG_CONFIG_HOME/custom/local"
printf '[tools]\n"npm:@openai/codex" = "latest"\nnode="24"\n[dotfiles]\n"~/.config/custom" = {mode="track"}\n"~/.claude/CLAUDE.md" = {mode="track"}\n' > "$MISE_GLOBAL_CONFIG_FILE"
cat >> "$MISE_GLOBAL_CONFIG_FILE" <<'MCP'
[tasks.setup-mcp]
run = '''
set -euo pipefail
echo custom-mcp
'''
MCP
mkdir -p "$HOME/.claude" "$HOME/.codex"
printf 'inactive\n' > "$HOME/.claude/CLAUDE.md"
printf 'credential fixture\n' > "$HOME/.codex/auth.json"
apply() { bash "$FIXTURE/scripts/apply-main.sh" --local --agents-only --agents "$1" > "$TEMP/apply.log" 2>&1; }
apply codex
cmp "$FIXTURE/home/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
[[ "$(cat "$HOME/.claude/CLAUDE.md")" == inactive ]]
[[ "$(cat "$HOME/.codex/auth.json")" == 'credential fixture' ]]
[[ "$(cat "$XDG_CONFIG_HOME/custom/local")" == preserve ]]
[[ ! -e "$HOME/.agents/skills/example/.env" ]]
grep -q 'node="24"' "$MISE_GLOBAL_CONFIG_FILE"
! grep -q 'npm:@openai/codex' "$MISE_GLOBAL_CONFIG_FILE"
mise config get --file "$MISE_GLOBAL_CONFIG_FILE" tasks.setup-mcp.run > "$TEMP/mcp-task"
DOTFILES_CLAUDE=0 bash "$TEMP/mcp-task" > "$TEMP/mcp.log"
! grep -q custom-mcp "$TEMP/mcp.log"
DOTFILES_CLAUDE=1 bash "$TEMP/mcp-task" > "$TEMP/mcp.log"
grep -q custom-mcp "$TEMP/mcp.log"
cp "$XDG_CONFIG_HOME/mise/conf.d/agents.toml" "$TEMP/first"
apply codex
cmp "$TEMP/first" "$XDG_CONFIG_HOME/mise/conf.d/agents.toml"
bash "$FIXTURE/scripts/sync-agent-configs.sh" --only claude --apply > "$TEMP/inactive-sync"
[[ ! -s "$TEMP/inactive-sync" ]]
printf 'inactive codex\n' > "$HOME/.codex/AGENTS.md"
apply claude
[[ "$(cat "$HOME/.codex/AGENTS.md")" == 'inactive codex' ]]
cmp "$FIXTURE/home/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
apply both
cmp "$FIXTURE/home/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
grep -q 'npm:@anthropic-ai/claude-code' "$XDG_CONFIG_HOME/mise/conf.d/agents.toml"
if apply invalid; then echo 'Invalid choice accepted' >&2; exit 1; fi
printf 'changed\n' > "$HOME/.agents/skills/example/SKILL.md"
printf 'secret fixture\n' > "$HOME/.agents/skills/example/.env"
bash "$FIXTURE/scripts/sync-agent-configs.sh" --dry-run > "$TEMP/sync"
grep -q 'UPDATE .agents/skills/example/SKILL.md' "$TEMP/sync"
[[ "$(cat "$FIXTURE/home/.agents/skills/example/SKILL.md")" == skill ]]
bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply > "$TEMP/sync"
cmp "$HOME/.agents/skills/example/SKILL.md" "$FIXTURE/home/.agents/skills/example/SKILL.md"
mv "$HOME/.agents/skills" "$TEMP/missing-source-skills"
bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply --delete > "$TEMP/missing-source"
[[ -f "$FIXTURE/home/.agents/skills/example/SKILL.md" ]]
grep -q 'MISSING .agents/skills (preserved)' "$TEMP/missing-source"
mv "$TEMP/missing-source-skills" "$HOME/.agents/skills"
chmod 755 "$HOME/.agents/skills/example/SKILL.md"
bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply > "$TEMP/sync"
[[ -x "$FIXTURE/home/.agents/skills/example/SKILL.md" ]]
if bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply --dry-run > "$TEMP/conflict" 2>&1; then
    echo 'Conflicting modes accepted' >&2; exit 1
fi
printf 'obsolete\n' > "$FIXTURE/home/.agents/skills/example/old.md"
bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply > "$TEMP/sync"
[[ -f "$FIXTURE/home/.agents/skills/example/old.md" ]]
bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply --delete > "$TEMP/sync"
[[ ! -f "$FIXTURE/home/.agents/skills/example/old.md" ]]
printf 'proposed\n' > "$HOME/.agents/skills/example/SKILL.md"
bash "$FIXTURE/scripts/propose.sh" > "$TEMP/propose"
cmp "$HOME/.agents/skills/example/SKILL.md" "$FIXTURE/home/.agents/skills/example/SKILL.md"
[[ ! -e "$FIXTURE/home/.config/mise/conf.d/agents.toml" ]]
ln -s "$TEMP/missing" "$HOME/.agents/skills/example/link.md"
if bash "$FIXTURE/scripts/sync-agent-configs.sh" --apply > "$TEMP/symlink" 2>&1; then
    echo 'Symlink accepted' >&2; exit 1
fi
[[ -L "$HOME/.agents/skills/example/link.md" ]]
rm "$HOME/.agents/skills/example/link.md"
printf 'PASS: selection, migration, idempotence, preservation, runtime exclusions, dry-run, permissions, sync, deletion, propose, symlink rejection\n'

# Exercise origin/main using a local-only origin, with unmerged checkout edits.
mkdir -p "$FIXTURE/home/.config/custom"
printf 'archived common setting\n' > "$FIXTURE/home/.config/custom/shared"
git -C "$FIXTURE" add .
git -C "$FIXTURE" -c user.name=Test -c user.email=test@example.invalid \
    -c commit.gpgsign=false commit -qm 'test: add isolated archive fixture'
git -C "$FIXTURE" branch -M main
git -C "$FIXTURE" remote add origin "$FIXTURE"
printf 'unmerged checkout edit\n' > "$FIXTURE/home/.codex/AGENTS.md"
git -C "$FIXTURE" status --porcelain > "$TEMP/status-before"
bash "$FIXTURE/scripts/apply-main.sh" --agents codex > "$TEMP/archive.log" 2>&1
[[ "$(cat "$HOME/.codex/AGENTS.md")" == codex ]]
[[ "$(cat "$XDG_CONFIG_HOME/custom/shared")" == 'archived common setting' ]]
[[ "$(cat "$XDG_CONFIG_HOME/custom/local")" == preserve ]]
git -C "$FIXTURE" status --porcelain > "$TEMP/status-after"
cmp "$TEMP/status-before" "$TEMP/status-after"
[[ "$(git -C "$FIXTURE" branch --show-current)" == main ]]
printf 'PASS: origin/main archive application, common settings, live-only preservation, unchanged checkout\n'

# Existing machine-local provisioning checks, migrated from Python fixtures.
(
    export HOME="$TEMP/provision home"
    unset XDG_CONFIG_HOME
    mkdir -p "$HOME"
    sh "$ROOT/scripts/init-machine-local.sh" > "$TEMP/init.log"
    for path in "$HOME/.Brewfile.local" "$HOME/.config/mise/config.local.toml" "$HOME/.config/macos.local.sh"; do
        [[ -f "$path" && ! -s "$path" ]]
        printf '# keep local edits\n' > "$path"
    done
    sh "$ROOT/scripts/init-machine-local.sh" > "$TEMP/init.log"
    for path in "$HOME/.Brewfile.local" "$HOME/.config/mise/config.local.toml" "$HOME/.config/macos.local.sh"; do
        [[ "$(cat "$path")" == '# keep local edits' ]]
    done
    rm "$HOME/.Brewfile.local"
    ln -s "$HOME/missing" "$HOME/.Brewfile.local"
    export XDG_CONFIG_HOME="$HOME/custom config"
    sh "$ROOT/scripts/init-machine-local.sh" > "$TEMP/init.log"
    [[ -L "$HOME/.Brewfile.local" && ! -e "$HOME/missing" ]]
    [[ -f "$XDG_CONFIG_HOME/mise/config.local.toml" && -f "$XDG_CONFIG_HOME/macos.local.sh" ]]
    mise config get --file "$ROOT/home/.config/mise/config.toml" tasks.setup-packages.run > "$TEMP/setup-packages"
    mkdir -p "$HOME/bin"
    cat > "$HOME/bin/brew" <<'BREW'
#!/bin/sh
printf '%s\n' "$*" >> "$HOME/brew-calls"
BREW
    chmod +x "$HOME/bin/brew"
    export PATH="$HOME/bin:$PATH"
    for common in 0 1; do
        for local_manifest in 0 1; do
            rm -f "$HOME/.Brewfile" "$HOME/.Brewfile.local" "$HOME/brew-calls"
            : > "$TEMP/expected"
            if [[ "$common" == 1 ]]; then : > "$HOME/.Brewfile"; printf 'bundle --global\n' >> "$TEMP/expected"; fi
            if [[ "$local_manifest" == 1 ]]; then
                : > "$HOME/.Brewfile.local"
                printf 'bundle --file=%s/.Brewfile.local\n' "$HOME" >> "$TEMP/expected"
            fi
            bash "$TEMP/setup-packages" > "$TEMP/packages.log"
            touch "$HOME/brew-calls"
            cmp "$TEMP/expected" "$HOME/brew-calls"
        done
    done
    mise config get --file "$ROOT/home/.config/mise/config.toml" tasks.setup-macos.run > "$TEMP/setup-macos"
    # Execute only the local hook block; never change macOS preferences.
    awk '/^local_macos=/{copy=1} /^echo "Restarting affected/{copy=0} copy' "$TEMP/setup-macos" > "$TEMP/local-hook"
    rm "$XDG_CONFIG_HOME/macos.local.sh"
    bash -euo pipefail "$TEMP/local-hook"
    printf 'printf applied > "$HOME/local-applied"\n' > "$XDG_CONFIG_HOME/macos.local.sh"
    bash -euo pipefail "$TEMP/local-hook" > "$TEMP/hook.log"
    [[ "$(cat "$HOME/local-applied")" == applied ]]
    printf 'exit 23\n' > "$XDG_CONFIG_HOME/macos.local.sh"
    if bash -euo pipefail "$TEMP/local-hook" > "$TEMP/hook.log"; then
        echo 'Local hook failure was hidden' >&2; exit 1
    else
        [[ "$?" == 23 ]]
    fi
)
printf 'PASS: machine-local initialization, custom XDG path, symlink preservation, optional Brewfiles, local hook failure propagation\n'
