# dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/) dotfiles
(migrated from chezmoi).

Files are managed **in place** — mise tracks the live files and saves history
automatically. There are no symlinks or a separate generated tree; you just
edit your real dotfiles.

Machines connect to this repository's **`main` branch** (the `home/` tree is
the canonical state) and **never publish to it automatically**: every change
reaches `main` through a reviewed PR, and each machine applies merged changes
with `mise dot pull`. See [Sync is manual](#sync-is-manual-policy) for why.

- Live tracking + auto-save history: `[dotfiles]` in `~/.config/mise/config.toml`
- Machine setup (Homebrew, packages, macOS defaults, Docker, MCP): `[tasks]` + the `bootstrap` task
- Per-PC secrets stay in `~/.env` (see [Secrets](#secrets))

## Layout

| What                                    | Where                                                                               |
| --------------------------------------- | ----------------------------------------------------------------------------------- |
| Source of truth                         | `~/.config/mise/config.toml` (`[tools]` / `[tasks]` / `[bootstrap]` / `[dotfiles]`) |
| Machine-local secrets (never tracked)   | `~/.env` (sourced from `~/.zshenv`)                                                 |
| Machine-local overrides (never tracked) | `*.local` files sourced by their base file                                          |
| Template sources (value-level diffs)    | `~/.dotfiles/` (`dotfiles.root`)                                                    |
| Local history store                     | per machine (`mise dot paths` shows it) — autosave checkpoints, never auto-pushed   |
| Sync source (what machines apply)       | this repo's `main` branch, `home/` tree (see below)                                 |

### This repository's `home/` tree

`home/` mirrors real `$HOME` paths 1:1 (`home/.config/nvim/init.lua` ==
`~/.config/nvim/init.lua`), with no chezmoi-style `dot_`/`executable_`/
`private_` name encoding — mise needs none of that, since it manages files in
place rather than rendering them from an encoded source tree.

This tree on `main` is what connected machines compare against and apply with
`mise dot pull` — it is the canonical state, and at the same time a normal git
tree, so every change to it is reviewable as a PR diff before any machine
applies it. To propose a change from a machine's live files, mirror them into
`home/` (`scripts/sync-agent-configs.sh`, or the `sync-agent-configs` /
`sync-claude` tasks in the repo-root `mise.toml`, or a plain `cp`) and open a
PR.

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

`sh install.sh` runs steps 1, 3 and 4 below in one go (falling back to
`curl https://mise.run | sh` when Homebrew is absent) — provide the secrets of
step 2 yourself first. Manually:

```sh
# 1. Install mise (Homebrew)
brew install mise

# 2. Provide per-PC secrets in ~/.env (sourced by ~/.zshenv)
cat > ~/.env <<'EOF'
export NOTION_TOKEN="ntn_xxx"   # your real token
EOF

# 3. Adopt this repository (restores files from the main branch's home/ tree)
mise bootstrap --adopt ssh://git@github.com/gr1m0h/dot.git

# 4. Run full machine setup (Homebrew packages, macOS defaults, Docker, MCP)
mise bootstrap
```

## Connect an existing machine

A machine whose live dotfiles are already in place (so `--adopt` would be
wrong — nothing should be restored over them) connects to `main` once.
Without a connection, sync fails with `no setup repository is connected`:

```sh
mise dot origin set ssh://git@github.com/gr1m0h/dot.git
#  -> answer **No** to "Automatically publish ... AND apply ...?"
#     (manual sharing; local autosave continues — see "Sync is manual")
mise dot status                  # confirm the tracked set and sync state
mise dot pull                    # apply main's current state to this machine
```

Connecting requires the local checkpoint history to share git ancestry with
`main`. A machine whose history started standalone fails with
`local and origin histories are unrelated` — reset the local history store
first (`mise dot paths` shows its location; deleting it never touches live
files), then reconnect: a machine with no checkpoints adopts the branch
history.

The tracked set comes from `[dotfiles]` in the live
`~/.config/mise/config.toml` — make sure that file is current (run
`mise dot pull` right after connecting) before relying on the watcher.

Note: applying never runs `mise bootstrap` and never renders templates — when
a pull brings in `[dotfiles]`/`[tools]` changes or template sources, run
`mise bootstrap` (or `mise install`) afterwards.

One-time enrollment: `mise bootstrap --adopt` (new-machine restore) only
works against a branch that carries mise's enrollment metadata
(`.mise-history/`, `config/config.toml`). The first machine to connect runs
`mise dot sync` once, **immediately after `mise dot pull`** so the live state
equals `main` and the push adds nothing but that metadata. This is the single
sanctioned direct push to `main`; everything else goes through PRs.

The legacy `mise-sync` branch predates this main-centric setup; once every
machine is connected to `main`, delete it.

## Daily usage

The change loop is PR-shaped in both directions:

```text
edit (any machine or the repo directly)
  -> mirror into home/ -> PR -> review -> merge to main
  -> every machine: mise dot pull
```

### Change something (this PC → main)

Edit the live file as usual — the history watcher auto-checkpoints it locally
(that gives you rollback, not publication). To share the change, put it on
`main` through a PR:

```sh
nvim ~/.config/zsh/.zshrc              # edit; auto-saved to local history
cd <this repo>
mise run sync-claude                   # ~/.claude changes, or:
cp ~/<path> home/<path>                # any other tracked file
git switch -c <branch> && git add -A && git commit && gh pr create
```

After the PR merges, the editing machine's live file already matches `main`
(its `pull` is a no-op); every other machine runs `mise dot pull`.

### Apply main → this PC

```sh
mise dot pull
```

`pull` runs as one recoverable transaction (reverse with `mise dot undo`).
On conflicts — a local edit that never went through a PR collides with an
incoming change — decide per path with `--take-remote` or `--keep-local`,
then `pull` again. Remember that applying never renders templates or runs
tasks: follow up with `mise bootstrap` when the pull changed
`[dotfiles]`/`[tools]` or template sources.

### Start tracking a new file

Add it to `[dotfiles]` in `~/.config/mise/config.toml` — via a PR like any
other change, since that file is itself tracked.

### Inspect / recover

```sh
mise dot status                 # tracked set, pending diffs, sync state
mise dot paths                  # store locations and capture-omitted files
mise dot history --path ~/.zshrc
mise dot rollback ~/.zshrc      # revert a file to a local checkpoint
mise dot undo                   # reverse the last pull/apply
```

### Sync is manual (policy)

Machines never publish automatically and never auto-apply. At
`mise dot origin set`, answer **No** to the
"Automatically publish saved edits AND apply incoming changes?" prompt.

Two reasons, both grounded in this being a public repository:

- A transient edit that momentarily contains a credential would be
  auto-pushed and remain in public git history even after deletion. With
  manual mode the only publication path is a PR you review.
- Review happens *before* anything reaches `main`, so a bad change never
  propagates to other machines; with auto-sync the watcher would apply it
  everywhere first and you would review afterwards.

Local autosave is unaffected: checkpoints, `rollback` and `undo` keep
working entirely offline.

## Secrets

Secrets are kept out of every tracked file and live only on each machine.

- The real tokens live in `~/.env` (never tracked), sourced by `~/.zshenv`
  (`[ -f "$HOME/.env" ] && source "$HOME/.env"`)
- `~/.mmcp.json` is a **template target**: only its source
  `~/.dotfiles/mmcp.json.tera` is tracked, and it carries the placeholder
  `{{ env.NOTION_TOKEN }}` instead of the token
- `mise bootstrap` renders the real token from the environment into the live
  `~/.mmcp.json`, which itself is never synced (`mise dot pull` only applies
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
