# dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/)'s track mode
(migrated from chezmoi). Files are managed **in place**: no symlinks, no
generated tree — you edit your real dotfiles, and mise checkpoints every
change locally so any file can be rolled back.

Set up a new machine with one command ([details](#new-machine)):

```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/install.sh | sh
```

## How it works

```text
                 (automatic, local only)
  live files  ────────────────────────────▶  local history
  ~/.zshrc …        watcher checkpoints        rollback / undo

  live files  ──(mise run propose)──▶  home/  ──PR──▶  main      [share]
  main  ──────(mise run apply-main)─────────────────▶  live      [apply]
```

- **`main`'s `home/` tree is the single source of truth.** It mirrors real
  `$HOME` paths 1:1 (`home/.config/nvim/init.lua` == `~/.config/nvim/init.lua`).
  Every change to it is a reviewable PR diff.
- **mise works offline.** It tracks the files listed under `[dotfiles]` in
  `~/.config/mise/config.toml`, auto-saves checkpoints (the `mise-history`
  watcher), renders templates, and provisions the machine (`mise bootstrap`).
  It is deliberately **not** connected to any sync remote
  ([why](#why-no-mise-remote-sync)).
- **Two tasks move changes between machines**, both through this repository:
  `mise run propose` (live → `home/`, then PR) and `mise run apply-main`
  (merged `home/` → live).
- Per-PC secrets never enter the repo: they live in `~/.env`
  ([Secrets](#secrets)).

## Daily usage

### Share a change

Edit live files as usual, then:

```sh
cd <this repo>
mise run propose     # mirror live tracked files into home/
git diff             # review what would be shared
git switch -c <branch> && git add -A && git commit && gh pr create
# merge the PR
```

`propose` copies additions and updates only, and **skips everything the
repo's `.gitignore` excludes** — machine-only content (slide-deck assets,
lazy-lock.json, runtime artifacts) can't reach the public tree. To delete a
file from the truth, `git rm` it in the same PR.

### Apply merged changes

On every machine (also after Renovate merges):

```sh
mise run apply-main  # fetch origin/main, apply its home/ to $HOME
mise bootstrap       # only if [tools]/[dotfiles]/templates changed
```

`apply-main` copies additions and updates only — live-only files survive —
and never touches your git working tree.

**Order rule: propose your local edits before running apply-main.** An
un-proposed edit differs from `main` and would be overwritten. If that
happens, the watcher has it: `mise dot rollback <path>`.

### Track a new file

Add a line to `[dotfiles]` in `~/.config/mise/config.toml`:

```toml
"~/.config/foo/config" = { mode = "track" }
```

The config file is itself tracked, so this travels via propose/apply too.

## New machine

One command (plus the secrets only you can provide):

```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/install.sh | sh
```

It installs mise (Homebrew, or `curl https://mise.run | sh`), clones this
repository, runs `apply-main`, and finishes with `mise bootstrap`. Template
rendering (git config, mmcp) reads `~/.env` — create it before, or right
after and rerun `mise bootstrap`:

```sh
cat > ~/.env <<'EOF'
export NOTION_TOKEN="ntn_xxx"
export GIT_NAME="..."
export GIT_EMAIL="..."
export GIT_SIGNINGKEY="..."
EOF
```

<details>
<summary>Equivalent manual steps</summary>

```sh
brew install mise
git clone ssh://git@github.com/gr1m0h/dot.git ~/Documents/workspace/github.com/gr1m0h/dot
cd ~/Documents/workspace/github.com/gr1m0h/dot
python3 -B scripts/apply-main.py   # home/ -> $HOME (config.toml included)
mise bootstrap                     # packages, defaults, templates, services, tools
```

</details>

An existing machine needs no enrollment: clone the repo and use the same two
tasks.

## Command reference

Daily commands — what each one touches:

| Command | Direction | Touches live files | Network |
| --- | --- | --- | --- |
| `mise run propose` | live → repo `home/` (gitignored files skipped, nothing staged) | no | no |
| `mise run apply-main` | `origin/main` `home/` → live (add/update only, never deletes) | yes | git fetch |
| `mise bootstrap` | assemble the machine: render templates, install `[tools]`, apply packages/defaults/services/tasks | yes | yes |
| watcher (`mise-history` service) | live → local history, automatically on edit | no | no |

Inspection and recovery (all local):

| Command | What it does |
| --- | --- |
| `mise dot status` | tracked set, pending changes, watcher health |
| `mise dot history --path <path>` | browse saved versions of a file |
| `mise dot rollback <path>` | revert one file to a checkpointed version |
| `mise dot undo` | reverse the last apply operation as a whole |
| `mise dot save` | checkpoint now (the watcher normally does this) |
| `mise dot paths` | tracked paths + capture-omitted files (credential-store false positives) |

Narrower live→repo mirrors (subsets of `propose`, used by it historically):

| Command | What it does |
| --- | --- |
| `mise run sync-claude` | copy live `~/.claude` into `home/.claude` (no commit) |
| `mise run sync-agent-configs` | same for all agent configs (Claude, Codex, `~/.agents/skills`); details in [docs/agent-config-setup.md](docs/agent-config-setup.md) |

Mnemonic: **propose = live→repo, apply-main = repo→live, bootstrap =
assemble.** Anything destructive is reversible via `undo` / `rollback`.

## Per-machine differences

When work and personal machines need different settings, pick by the shape of
the difference:

| Shape of the difference | Mechanism |
| --- | --- |
| A separable block (Datadog stanza, extra aliases) | **1. machine-local file** (start here) |
| Same structure, different values (name, email, key) | **2. template** |
| Entirely different file content per machine | **3. variants** |

### 1. Machine-local file

Split the machine-specific block into a non-tracked `*.local` file that the
tracked file sources:

- Tracked: `~/.config/zsh/.zshrc`, ending with
  `[ -f "${ZDOTDIR}/.zshrc.local" ] && source "${ZDOTDIR}/.zshrc.local"`
- Not tracked: `~/.config/zsh/.zshrc.local` (CHROME_PATH, Datadog, …)

### 2. Template

The tracked source renders per machine from environment variables (Tera).
The live example is the git config:

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

Values come from `~/.env`. Rendering happens in `mise bootstrap`
(`apply-main` only copies tracked files; it never renders).

### 3. Variants

Separate content per profile/OS for the same path — unused so far:

```toml
[dotfiles]
"~/.config/foo/config" = { mode = "track", variants = [
  { profile = "work" },
  { default = true },
] }
```

The profile is selected with `-E <name>` or `MISE_ENV=<name>`. Note that
variants keep whole-file histories per machine, which this repo's
single-truth model cannot represent in `home/` — prefer 1 and 2.

## Secrets

Secrets live only on each machine and never enter the repo.

- Real tokens: `~/.env` (never tracked), sourced by `~/.zshenv`
- `~/.mmcp.json` is a **template target**: only
  `~/.dotfiles/mmcp.json.tera` is tracked, carrying
  `{{ env.NOTION_TOKEN }}` instead of the token
- `mise bootstrap` renders the real value into the live file, which is never
  mirrored. A rendered live file (vs relying on env inheritance) also works
  for MCP clients launched from the GUI, which never see shell exports

### Why no mise remote sync

mise can sync its history to a Git branch, but that is deliberately not used
here:

- mise can only sync a branch it created itself, which would mean a second,
  divergent copy of every tracked file on a **public** branch — including
  files `.gitignore` deliberately keeps out of `main`
- nothing should leave a machine before you review a diff; `propose` + PR is
  exactly that gate

If a machine still has an origin connected from the old setup:
`mise dot origin --remove`.

## Machine provisioning

`mise bootstrap` chains the setup steps (each is also runnable alone):

```sh
mise run setup-homebrew   # install Homebrew
mise run setup-packages   # brew bundle --global (~/.Brewfile)
mise run setup-macos      # macOS defaults
mise run setup-docker     # Colima / Docker context
mise run setup-mcp        # Claude GitHub MCP
mise run setup-ghostty    # build Ghostty-Nvim.app from the tracked AppleScript
```

Tools come from `[tools]` in `~/.config/mise/config.toml` (`mise install` /
the bootstrap tools phase).

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
`xcode-select: Failed to locate 'git'`.** The machine's Xcode Command Line
Tools are broken, so `/usr/bin/git` can't resolve a real `git` binary. An
interactive shell hides this (Homebrew's `git` comes first in `PATH`), but
`launchd` starts the service with a minimal `PATH` that falls through to the
broken `/usr/bin/git` stub.

Fix (reinstall Command Line Tools — repairs `/usr/bin/git` system-wide):

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

Note: this plist is regenerated by `mise bootstrap services apply`, so manual
edits to it (including the log paths above) are wiped the next time that
command runs — useful for one-off diagnosis only.

## Requirements

- macOS 14.0+
- mise 2026.10+ (`mise dot` CLI; dotfiles tracking was added in 2026.9.2)
- Internet connection; admin privileges for some macOS settings
