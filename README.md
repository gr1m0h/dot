# dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/) dotfiles
(migrated from chezmoi).

Files are managed **in place** — mise tracks the live files, saves history
automatically, and syncs to this repository's `mise-sync` branch. There are no
symlinks or a separate generated tree; you just edit your real dotfiles.

- Live tracking + auto-save history: `[dotfiles]` in `~/.config/mise/config.toml`
- Machine setup (Homebrew, packages, macOS defaults, Docker, MCP): `[tasks]` + the `bootstrap` task
- Per-PC secrets stay in `~/.env` (see [Secrets](#secrets))

## Layout

| What | Where |
|------|-------|
| Source of truth | `~/.config/mise/config.toml` (`[tools]` / `[tasks]` / `[bootstrap]` / `[dotfiles]`) |
| Machine-local secrets (never tracked) | `~/.env` (sourced from `~/.zshenv`) |
| History store | `~/.local/state/mise/history/repo.git` (bare) |
| Remote | `github.com/gr1m0h/dot` branch `mise-sync` |

## Install on a new machine

```sh
# 1. Install mise (Homebrew)
brew install mise

# 2. Provide per-PC secrets in ~/.env (sourced by ~/.zshenv)
cat > ~/.env <<'EOF'
export NOTION_TOKEN="ntn_xxx"   # your real token
EOF

# 3. Adopt this repository (fetches the mise-sync branch and restores files)
mise bootstrap --adopt ssh://git@github.com/gr1m0h/dot.git

# 4. Run full machine setup (Homebrew packages, macOS defaults, Docker, MCP)
mise bootstrap
```

## Daily usage

### Coming from chezmoi

| chezmoi | mise |
|---------|------|
| `chezmoi apply` (repo → this PC) | `mise bootstrap dotfiles sync && mise bootstrap dotfiles pull` |
| `chezmoi add <file>` (this PC → repo) | just edit (auto-saved), then `mise bootstrap dotfiles sync` |
| `chezmoi update` | `mise bootstrap dotfiles sync && mise bootstrap dotfiles pull` |
| `chezmoi diff` | `mise bootstrap dotfiles diff` |
| `chezmoi edit <file>` | edit directly (auto-saved) or `mise bootstrap dotfiles edit <file>` |
| `chezmoi managed` | `mise bootstrap dotfiles status` |

### Apply repo → this PC (like `chezmoi apply` / `update`)

Bring changes made on other machines into this machine's live files:

```sh
mise bootstrap dotfiles sync   # fetch what other machines published
mise bootstrap dotfiles pull   # write those changes into your live files
```

`pull` runs as one recoverable transaction (undo with
`mise bootstrap dotfiles undo`). On conflicts, decide per path with
`--take-remote` or `--keep-local`, then `pull` again.

### Save this PC → repo (like `chezmoi add`)

Editing a tracked file is enough — the history watcher auto-saves it. Then
publish to the `mise-sync` branch:

```sh
nvim ~/.config/nvim/init.lua           # edit; auto-saved to history
mise bootstrap dotfiles save ~/foo     # (optional) save a path explicitly
mise bootstrap dotfiles sync           # publish to the remote
```

Start tracking a new file/directory:

```sh
mise bootstrap dotfiles track ~/.config/foo/bar
```

### Inspect / recover

```sh
mise bootstrap dotfiles status
mise bootstrap dotfiles history --path ~/.zshrc
mise bootstrap dotfiles rollback ~/.zshrc   # revert a file to a checkpoint
mise bootstrap dotfiles undo                # reverse the last pull/apply
```

### Automatic sync

Sync is `manual` by default (run `sync`/`pull` yourself). To auto push/fetch,
set in `config.local.toml`:

```toml
[settings.history]
sync = "sync"
```

## Secrets

Secrets are kept out of the tracked files entirely and supplied by the shell
environment.

- `~/.mmcp.json` is tracked but carries **no token**; its `env` block is empty
- The real token lives in `~/.env` (never tracked), exported via `~/.zshenv`
  (`[ -f "$HOME/.env" ] && source "$HOME/.env"`)
- MCP servers started by the client inherit `NOTION_TOKEN` from the environment

Because the token is never written into a tracked file, `~/.mmcp.json` is safe
to publish as-is.

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

## Requirements

- macOS 14.0+
- mise 2026.9.2+ (dotfiles tracking was added in 2026.9.2)
- Internet connection; admin privileges for some macOS settings
