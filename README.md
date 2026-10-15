# dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/) dotfiles
(migrated from chezmoi).

Files are managed **in place** — mise tracks the live files and saves history
automatically. There are no symlinks or a separate generated tree; you just
edit your real dotfiles.

Two branches play different roles:

- **`main`** — the human source of truth. Its `home/` tree is reviewed: every
  change lands through a PR. mise never reads or writes `main`.
- **`mise-sync`** — the machine transport branch, created and owned by mise
  (it carries mise's enrollment metadata, which mise only generates when it
  creates the branch itself — an existing content branch like `main` cannot
  be connected directly).

The loop: merge a PR on `main` → one machine copies the merged files onto its
live paths and runs `mise dot sync` (publishing them to `mise-sync`) → every
other machine runs `mise dot sync && mise dot pull`. Nothing is published
automatically — see [Sync is manual](#sync-is-manual-policy).

- Live tracking + auto-save history: `[dotfiles]` in `~/.config/mise/config.toml`
- Machine setup (Homebrew, packages, macOS defaults, Docker, MCP): `[tasks]` + the `bootstrap` task
- Per-PC secrets stay in `~/.env` (see [Secrets](#secrets))

## Cheat sheet

A change made **on this machine** (live file edited; the watcher checkpoints
it automatically):

```sh
cp ~/<path> <repo>/home/<path>     # or `mise run sync-claude` for ~/.claude
# open a PR from that diff and merge it
mise dot sync                      # publish (live already matches main)
```

A change merged **repo-side** (Renovate, another machine's PR, direct edits
to `home/`):

```sh
cd <repo> && git pull
cp home/<path> ~/<path>            # on ONE machine
mise dot sync                      # publish to mise-sync
```

Every **other** machine, afterwards:

```sh
mise dot sync && mise dot pull     # fetch + apply
mise bootstrap                     # only if [tools]/[dotfiles]/templates changed
```

Machine setup, by situation:

| Situation | What to run |
| --- | --- |
| Brand-new machine | `sh install.sh` ([details](#install-on-a-new-machine)) |
| Existing machine whose local history is unrelated to `mise-sync` | `mise bootstrap --adopt 'ssh://git@github.com/gr1m0h/dot.git?ref=mise-sync' --replace-history --take-remote-all --yes`, then `mise bootstrap` |
| First machine ever (no `mise-sync` yet) | [Connect an existing machine](#connect-an-existing-machine) |

## Layout

| What                                    | Where                                                                               |
| --------------------------------------- | ----------------------------------------------------------------------------------- |
| Source of truth                         | `~/.config/mise/config.toml` (`[tools]` / `[tasks]` / `[bootstrap]` / `[dotfiles]`) |
| Machine-local secrets (never tracked)   | `~/.env` (sourced from `~/.zshenv`)                                                 |
| Machine-local overrides (never tracked) | `*.local` files sourced by their base file                                          |
| Template sources (value-level diffs)    | `~/.dotfiles/` (`dotfiles.root`)                                                    |
| Local history store                     | `~/.local/state/mise/history/repo.git` — autosave checkpoints, never auto-pushed    |
| Reviewed source of truth                | this repo's `main` branch, `home/` tree (see below)                                 |
| Machine transport (what mise syncs)     | this repo's `mise-sync` branch (mise-created; enrollment metadata)                  |

### This repository's `home/` tree

`home/` mirrors real `$HOME` paths 1:1 (`home/.config/nvim/init.lua` ==
`~/.config/nvim/init.lua`), with no chezmoi-style `dot_`/`executable_`/
`private_` name encoding — mise needs none of that, since it manages files in
place rather than rendering them from an encoded source tree.

This tree on `main` is the reviewed canonical state: every change to it is a
PR diff someone approved. mise itself does not read it — merged changes reach
machines by being applied to one machine's live files and published to
`mise-sync` (see "Propagate changes merged on main" below). To propose a
change from a machine's live files, mirror them into `home/`
(`scripts/sync-agent-configs.sh`, or the `sync-agent-configs` / `sync-claude`
tasks in the repo-root `mise.toml`, or a plain `cp`) and open a PR.

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

# 3. Adopt this repository (restores files from the mise-sync transport branch;
#    ?ref= is required — plain --adopt would target the default branch `main`,
#    which is not a setup repository)
mise bootstrap --adopt 'ssh://git@github.com/gr1m0h/dot.git?ref=mise-sync'

# 4. Run full machine setup (Homebrew packages, macOS defaults, Docker, MCP)
mise bootstrap
```

## Connect an existing machine

A machine whose live dotfiles are already in place (so a plain `--adopt`
restore is not wanted) connects to the `mise-sync` transport branch once.
Without a connection, sync fails with `no setup repository is connected`.

Make the live files current **first** (copy merged state from `main`'s
`home/` onto the live paths), because `mise dot origin set` immediately
captures an initial checkpoint of the live tracked files:

```sh
mise dot save                    # checkpoint the current live state
mise dot origin set ssh://git@github.com/gr1m0h/dot.git --branch mise-sync
#  -> answer **No** to "Automatically publish ... AND apply ...?"
#     (manual sharing; local autosave continues — see "Sync is manual")
mise dot status                  # confirm the tracked set and sync state
```

Branch rules (observed on mise 2026.10):

- `--branch` only connects to a branch that **already exists** on the remote.
  Bootstrapping `mise-sync` from scratch is done with plain git: push the
  local history store's `main` as the new branch, then connect —

  ```sh
  mise dot save
  git -C ~/.local/state/mise/history/repo.git \
    push ssh://git@github.com/gr1m0h/dot.git refs/heads/main:refs/heads/mise-sync
  mise dot origin set ssh://git@github.com/gr1m0h/dot.git --branch mise-sync
  ```
- An existing **content** branch (like `main`) can never be connected: it has
  no enrollment metadata and mise cannot add it, so the connect dies with
  `local and origin histories are unrelated`.
- A later machine joining an existing `mise-sync` whose local checkpoints are
  unrelated runs
  `mise bootstrap --adopt 'ssh://git@github.com/gr1m0h/dot.git?ref=mise-sync' --replace-history --take-remote-all --yes`
  — this discards its local checkpoints and takes the branch's version of
  every differing live file (the replaced versions are saved first;
  `mise dot undo` restores them). Untracked machine-local files like `~/.env`
  and `*.local` are unaffected.

Note: applying never runs `mise bootstrap` and never renders templates — when
a pull brings in `[dotfiles]`/`[tools]` changes or template sources, run
`mise bootstrap` (or `mise install`) afterwards.

## Daily usage

The change loop is PR-shaped, with `mise-sync` as the transport:

```text
edit (any machine or the repo directly)
  -> mirror into home/ -> PR -> review -> merge to main
  -> editing machine: mise dot sync        (publish; its live files already match)
  -> every other machine: mise dot sync && mise dot pull
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

### Propagate changes merged on main

After the merge, the machine whose live files already carry the change (the
one that opened the PR) publishes it to the transport branch; a change made
directly in the repo is first copied onto one machine's live paths:

```sh
cd <this repo> && git pull
cp home/<path> ~/<path>        # only when the edit was made repo-side
mise dot sync                  # publish checkpoints to mise-sync
```

Every other machine then applies it:

```sh
mise dot sync                  # fetch
mise dot pull                  # write into live files
```

`pull` runs as one recoverable transaction (reverse with `mise dot undo`).
On conflicts — a local edit that never went through a PR collides with an
incoming change — inspect with `mise dot conflicts`, then decide per path
with `--take-remote <path>` or `--keep-local <path>` and `pull` again.
Remember that applying never renders templates or runs tasks: follow up with
`mise bootstrap` when the pull changed `[dotfiles]`/`[tools]` or template
sources.

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
  manual mode, publication happens only when you run `mise dot sync` —
  normally right after the same change was reviewed and merged as a PR.
- Review happens *before* anything reaches `main` and the transport branch,
  so a bad change never propagates to other machines; with auto-sync the
  watcher would apply it everywhere first and you would review afterwards.

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
