# Ghostty-Nvim File Association Setup

This setup allows you to open files with specific extensions in Ghostty with Nvim just by double-clicking them in Finder.

## Prerequisites

- macOS (the setup uses AppleScript and LaunchServices)
- [Ghostty](https://ghostty.org/) installed at `/Applications/Ghostty.app`
- Neovim installed via [mise](https://mise.jdx.dev/) (`mise install neovim`)

The AppleScript invokes nvim through the mise shim at
`~/.local/share/mise/shims/nvim`, which resolves the active version without
relying on `PATH` (Ghostty wraps `-e` commands in `/usr/bin/login -flp`, which
does not carry shell-level activations such as `mise activate zsh`).

## Setup Method

### Automatic Setup with chezmoi

```bash
chezmoi apply
```

The setup script automatically:
- Creates the AppleScript application "Ghostty-Nvim.app"
- Installs it in `~/Applications/`
- Configures file extension associations

### File Association Settings

1. Right-click any text file (e.g., `.txt`, `.md`) in Finder
2. Select "Get Info"
3. In the "Open with" section, select "Ghostty-Nvim"
4. Click "Change All..." to apply to all files with the same extension

### Supported Extensions

The following extensions are supported by default:

- **Text**: txt, md, markdown, rst
- **Programming Languages**: lua, js, ts, py, rb, go, rs, c, cpp, java, sh
- **Configuration Files**: yml, yaml, json, toml, ini, env, gitignore
- **Web**: html, css, scss, php
- And many more

## Customization

### Adding Extensions

Add extensions to the `extra_extensions` array in `.chezmoi.toml`:

```toml
[data]
    extra_extensions = ["log", "conf", "cfg"]
```

## Troubleshooting

### If the app doesn't open

1. Check security settings:
   - System Preferences > Security & Privacy > General
   - Allow "Ghostty-Nvim"

2. Reset LaunchServices database:
   ```bash
   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
   ```

### If nvim cannot be found

The AppleScript expects nvim at `~/.local/share/mise/shims/nvim`. Verify the
shim exists and resolves to a working binary:

```bash
ls -l ~/.local/share/mise/shims/nvim
~/.local/share/mise/shims/nvim --version

# If the shim is missing, install nvim under mise:
mise install neovim
```

## Reinstall

If you've changed settings or encounter issues:

```bash
# Rebuild the app
chezmoi apply --force-refresh-externals
```
