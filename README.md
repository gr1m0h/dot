# dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/) dotfiles
(migrated from chezmoi).

Files are managed **in place** — mise tracks the live files and saves history
automatically. There are no symlinks or a separate generated tree; you just
edit your real dotfiles.

**`main`'s `home/` tree is the single source of truth.** mise is not
connected to any origin: its history stays on each machine (autosave,
rollback, undo), and all sharing between machines goes through this
repository with two tasks — `mise run propose` (live → `home/`, then PR) and
`mise run apply-main` (merged `home/` → live). Nothing moves over the
network except git operations you run yourself
(see [No remote sync](#no-remote-sync-policy)).

- Live tracking + auto-save history: `[dotfiles]` in `~/.config/mise/config.toml`
- Machine setup (Homebrew, packages, macOS defaults, Docker, MCP): `[tasks]` + the `bootstrap` task
- Per-PC secrets stay in `~/.env` (see [Secrets](#secrets))

## Cheat sheet

Two commands cover the whole operation.

**Share a change** (edited live files on this machine):

```sh
mise run propose                   # mirror live tracked files into home/
git diff                           # review (gitignored files never get copied)
git switch -c <branch> && git add -A && git commit && gh pr create
# merge the PR
```

**Take in merged changes** (on every machine, including after Renovate):

```sh
mise run apply-main                # fetch origin/main, apply home/ -> live
mise bootstrap                     # if [tools]/[dotfiles]/templates changed
```

One rule of order: **propose local edits before running apply-main** — an
un-proposed edit differs from `main` and would be overwritten (recoverable
with `mise dot rollback`; the watcher checkpointed it).

Machine setup: `sh install.sh` on a brand-new machine
([details](#install-on-a-new-machine)); an existing machine just needs the
repo cloned and the same two commands.

## Layout

| What                                    | Where                                                                               |
| --------------------------------------- | ----------------------------------------------------------------------------------- |
| Source of truth                         | `~/.config/mise/config.toml` (`[tools]` / `[tasks]` / `[bootstrap]` / `[dotfiles]`) |
| Machine-local secrets (never tracked)   | `~/.env` (sourced from `~/.zshenv`)                                                 |
| Machine-local overrides (never tracked) | `*.local` files sourced by their base file                                          |
| Template sources (value-level diffs)    | `~/.dotfiles/` (`dotfiles.root`)                                                    |
| Local history store                     | `~/.local/state/mise/history/repo.git` — autosave checkpoints, local only           |
| Single source of truth                  | this repo's `main` branch, `home/` tree (see below)                                 |
| Sharing between machines                | `mise run propose` (live → `home/`, PR) / `mise run apply-main` (`home/` → live)    |

### This repository's `home/` tree

`home/` mirrors real `$HOME` paths 1:1 (`home/.config/nvim/init.lua` ==
`~/.config/nvim/init.lua`), with no chezmoi-style `dot_`/`executable_`/
`private_` name encoding — mise needs none of that, since it manages files in
place rather than rendering them from an encoded source tree.

This tree on `main` is the single source of truth: every change to it is a
PR diff someone approved, and every machine materialises it onto the live
files with `mise run apply-main`. The reverse direction is
`mise run propose`, which mirrors the live tracked files into `home/` for a
PR — skipping anything the repo's `.gitignore` excludes, so machine-only
content never reaches the public tree.

### Agent configuration mirror

Preview Claude, Codex and personal skills together (Python 3.11+):

```sh
bash scripts/sync-agent-configs.sh                 # preview only
bash scripts/sync-agent-configs.sh --apply         # additions and updates
bash scripts/sync-agent-configs.sh --apply --delete # also remove reviewed stale files
mise run sync-agent-configs-dry                    # equivalent preview task
mise run sync-agent-configs                        # equivalent apply task
python3 -B -m unittest discover -s scripts -p 'test_sync_agent_configs.py'
```

The agent entries in `home/.config/mise/config.toml` are the shared target list.
The mirror command reads this repository file; it does not update the live mise
configuration, publish, or commit. Activate newly added tracking entries in the
live mise configuration separately before relying on cross-machine restoration.

Runtime files are excluded from the mirror and symlinks are rejected. Missing
source entries preserve the existing mirror. Deletions are always displayed and
require `--delete` to apply. Directory tracking in mise is separate: mirror
exclusions do not automatically configure mise's history watcher.

Raw Claude `settings.json`, Codex `config.toml`, `hooks.json` and accumulated
`rules/default.rules` require manual review and are never copied by this command,
even if tracked. Keep credentials, project trust entries and machine-specific
paths local; prepare portable settings separately. Installed plugin caches are
excluded; record installation sources/instructions instead. `sync-claude.sh`
delegates to the same implementation with `--only claude`. Its no-argument form
still applies additions/updates, but no longer deletes stale files implicitly.

See [agent configuration setup](docs/agent-config-setup.md) for the portable
Codex example, local credentials, hooks and plugin restoration. Example files
are maintained in this repository and are not overwritten by live imports.

## Install on a new machine

One command (plus the secrets you must provide yourself):

```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/install.sh | sh
```

It installs mise (Homebrew, or `curl https://mise.run | sh` when Homebrew is
absent), clones this repository, runs `apply-main` to materialise `home/`
onto `$HOME`, and finishes with `mise bootstrap`. Template rendering (git
config, mmcp) needs `~/.env` — create it before or right after and rerun
`mise bootstrap`:

```sh
cat > ~/.env <<'EOF'
export NOTION_TOKEN="ntn_xxx"
export GIT_NAME="..."
export GIT_EMAIL="..."
export GIT_SIGNINGKEY="..."
EOF
```

The equivalent manual steps:

```sh
brew install mise
git clone ssh://git@github.com/gr1m0h/dot.git ~/Documents/workspace/github.com/gr1m0h/dot
cd ~/Documents/workspace/github.com/gr1m0h/dot
python3 -B scripts/apply-main.py   # home/ -> $HOME (config.toml included)
mise bootstrap                     # packages, defaults, templates, services, tools
```

An existing machine needs no enrollment of any kind: clone the repo and use
the same two tasks (`propose` / `apply-main`).

## Daily usage

One loop, whichever side the change originates on:

```text
live edit ──(mise run propose)──> home/ ──PR──> main
main ──(mise run apply-main, every machine)──> live
```

### Share an edit made on this machine

Edit the live file as usual — the history watcher auto-checkpoints it locally
(that gives you rollback, not publication). To share it:

```sh
nvim ~/.config/zsh/.zshrc              # edit; auto-saved to local history
cd <this repo>
mise run propose                       # mirror live tracked files into home/
git diff                               # review what would be shared
git switch -c <branch> && git add -A && git commit && gh pr create
```

`propose` copies additions and updates only and skips everything the repo's
`.gitignore` excludes, so machine-only content (slide-deck assets,
lazy-lock.json, runtime artifacts) never reaches the public tree. Intentional
deletions are done with `git rm` in the same PR.

### Take in changes merged on main

On every machine, whenever you next use it:

```sh
mise run apply-main            # fetch origin/main, apply tracked home/ paths
mise bootstrap                 # if [tools]/[dotfiles]/templates changed
```

`apply-main` copies additions and updates only (live-only files survive) and
never touches the repo working tree. If it overwrote a local edit you had
not proposed yet, the watcher's checkpoint has it: `mise dot rollback <path>`.

### Start tracking a new file

Add it to `[dotfiles]` in `~/.config/mise/config.toml` (the file is itself
tracked, so the change travels through propose/apply like any other edit).

## Command reference

What each command touches — live files, the network, or neither:

| Command | What it does | Touches live | Network |
| --- | --- | --- | --- |
| `mise run propose` | mirror live tracked files into `home/` for a PR (gitignored files skipped; nothing staged) | no | no |
| `mise run apply-main` | fetch `origin/main`, copy its tracked `home/` paths onto live (additions/updates only, never deletes) | yes | git only |
| `mise bootstrap` | machine assembly: render templates (mmcp, git config), install `[tools]`, apply services/defaults/tasks | yes | yes |
| watcher (`mise-history` service) | auto-checkpoint tracked files on edit — local save only, never leaves the machine | no | no |

Inspection and recovery (all local):

| Command | What it does |
| --- | --- |
| `mise dot status` | tracked set, pending changes, watcher health |
| `mise dot history --path <path>` | browse saved versions of a file |
| `mise dot rollback <path>` | revert one file to a checkpointed version |
| `mise dot undo` | reverse the last apply operation as a whole |
| `mise dot save` | checkpoint now (the watcher normally does this) |
| `mise dot paths` | list tracked paths and capture-omitted files (e.g. credential-store false positives) |

Narrower live→repo mirrors (subsets of `propose`):

| Command | What it does |
| --- | --- |
| `mise run sync-claude` | copy live `~/.claude` into `home/.claude` (no commit) |
| `mise run sync-agent-configs` | same for all agent configs (Claude, Codex, `~/.agents/skills`) |

Mnemonic: **propose = live→repo, apply-main = repo→live, bootstrap =
assemble (renders + installs)**. Anything destructive is reversible via
`undo` / `rollback`.

### No remote sync (policy)

mise's origin-sync feature is deliberately **not connected**: `mise dot
status` should show no repository, and the `mise dot sync` / `pull` /
`origin` commands are unused. The repository's `main` branch is the only
remote, and only git commands you run yourself touch it.

Reasons, grounded in this being a public repository:

- mise can only sync a branch it created itself (its enrollment format),
  which would mean a second, divergent copy of every tracked file on a
  public branch — including files `.gitignore` deliberately keeps out of
  `main`. One source of truth is simpler and safer.
- A transient edit that momentarily contains a credential must never be
  auto-pushed; here nothing leaves the machine until you `propose` and
  review the diff.

Local autosave is unaffected: checkpoints, `rollback` and `undo` work
entirely offline. If a machine still has an origin connected from the old
setup, disconnect with `mise dot origin --remove`.

## Secrets

Secrets are kept out of every tracked file and live only on each machine.

- The real tokens live in `~/.env` (never tracked), sourced by `~/.zshenv`
  (`[ -f "$HOME/.env" ] && source "$HOME/.env"`)
- `~/.mmcp.json` is a **template target**: only its source
  `~/.dotfiles/mmcp.json.tera` is tracked, and it carries the placeholder
  `{{ env.NOTION_TOKEN }}` instead of the token
- `mise bootstrap` renders the real token from the environment into the live
  `~/.mmcp.json`, which itself is never mirrored (`apply-main` only copies
  tracked files; it never renders templates)

This is the same mechanism as the git config template (see
[Per-machine differences](#per-machine-differences) §2). Keeping the rendered
token in the live file — rather than relying on env inheritance — also works
for MCP clients launched from the GUI, which never see shell exports.

## Per-machine differences

When settings differ between machines (personal vs work, different usernames,
etc.), pick one of three approaches by the shape of the difference.

### 1. Separable settings -> machine-local file (default, simplest)

An independent block (a Datadog stanza, machine-specific aliases) is split out
of the tracked file into a non-tracked `*.local` file that the base file sources.

- Common: `~/.config/zsh/.zshrc` (tracked)
- Machine-local: `~/.config/zsh/.zshrc.local` (NOT tracked)
- Wire-up at the end of `.zshrc`:
  `[ -f "${ZDOTDIR}/.zshrc.local" ] && source "${ZDOTDIR}/.zshrc.local"`

This uses only track plus the shell's own `source`; no `~/.dotfiles` needed.
Use it whenever the difference can live in its own file.

### 2. Value-level diffs that can't be split -> template

When only a value inside a file differs (username, email, a path containing
`$USER`), use template mode. The template source is tracked so edits sync, and
each machine renders its own value from `env`/`vars`. The live example in this
repo is the git config:

```toml
[dotfiles]
"~/.config/git/config" = { mode = "template", source = "~/.dotfiles/git-config.tera" }
"~/.dotfiles/git-config.tera" = { mode = "track" }
```

```tera
[user]
    name = {{ env.GIT_NAME }}
    email = {{ env.GIT_EMAIL }}
    signingkey = {{ env.GIT_SIGNINGKEY }}
```

The values (`GIT_NAME`, `GIT_EMAIL`, …) come from the machine's environment or
mise `vars`. This is the closest to chezmoi's templating.

### 3. Whole-file differences -> variants

When a file has no common part and differs entirely by OS or environment, use
variants. Each variant is a separate history stream for the same path.

```toml
[dotfiles]
"~/.config/foo/config" = { mode = "track", variants = [
  { profile = "work" },
  { default = true },
] }
```

The profile is selected with `-E <name>` or `MISE_ENV=<name>`, so personal and
work machines can differ even when both run macOS.

### Which to use

- The difference lives in its own block -> **1. machine-local file** (start here)
- Only a value inside a shared file differs -> **2. template**
- The whole file differs with no common part -> **3. variants**

## Machine provisioning

`mise bootstrap` runs a `bootstrap` task that chains the setup steps:

```sh
mise run setup-homebrew   # install Homebrew
mise run setup-packages   # brew bundle --global (~/.Brewfile)
mise run setup-macos      # macOS defaults
mise run setup-docker     # Colima / Docker context
mise run setup-mcp        # Claude GitHub MCP
mise run setup-ghostty    # build Ghostty-Nvim.app from the tracked AppleScript
```

Tools are installed by mise itself (`mise install` / the bootstrap tools phase)
from `[tools]` in `config.toml`.

## Troubleshooting

### History-watch service not saving edits

The `mise-history` LaunchAgent (`[bootstrap.services.mise-history]`, builtin
`history-watch`) auto-checkpoints tracked files as you edit them. If edits
stop showing up in history, check whether it's actually running:

```sh
launchctl list dev.mise.mise-history   # LastExitStatus should be 0
ps aux | grep -E 'mise (dot|bootstrap dotfiles) watch' | grep -v grep
```

If `LastExitStatus` is non-zero, capture the real error by temporarily
adding log paths to the generated plist, then reloading:

```sh
/usr/libexec/PlistBuddy -c "Add :StandardErrorPath string /tmp/mise-history-watch.err.log" \
  ~/Library/LaunchAgents/dev.mise.mise-history.plist
launchctl bootout gui/$(id -u)/dev.mise.mise-history
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.mise.mise-history.plist
sleep 2
cat /tmp/mise-history-watch.err.log
```

**Symptom: the log mentions `xcodebuild`, `libxcodebuildLoader.dylib`, or
`xcode-select: Failed to locate 'git'`.** This means the machine's Xcode
Command Line Tools are broken, so `/usr/bin/git` can't resolve a real `git`
binary. It normally goes unnoticed because an interactive shell's `PATH` puts
Homebrew's `git` first — but `launchd` starts this service with a minimal
`PATH` that falls through to the broken `/usr/bin/git` stub.

Fix (reinstall Command Line Tools — resolves `/usr/bin/git` for every
process on the machine, not just this one):

```sh
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

Reload the service afterward:

```sh
launchctl bootout gui/$(id -u)/dev.mise.mise-history
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.mise.mise-history.plist
launchctl list dev.mise.mise-history
```

Note: this plist is regenerated by `mise bootstrap services apply`, so any
manual edit to it (including the log paths added above) is wiped out the next
time that command runs — it is only useful for one-off diagnosis, not as a
persistent fix.

## Requirements

- macOS 14.0+
- mise 2026.10+ (`mise dot` CLI and branch-connected setup repositories;
  dotfiles tracking itself was added in 2026.9.2)
- Internet connection; admin privileges for some macOS settings
