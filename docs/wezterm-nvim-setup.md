# WezTerm-Nvim File Association Setup

This setup allows you to open files with specific extensions in WezTerm with Nvim just by double-clicking them in Finder.

## Setup Method

### Automatic Setup with chezmoi

```bash
# Apply settings with chezmoi
chezmoi apply

# On first run, answer the following questions:
# - Path to wezterm binary: /opt/homebrew/bin/wezterm (M1/M2 Mac)
# - Path to nvim binary: /opt/homebrew/bin/nvim (Homebrew installation)
```

The setup script automatically:
- Creates the AppleScript application "WezTerm-Nvim.app"
- Installs it in `~/Applications/`
- Configures file extension associations

### File Association Settings

1. Right-click any text file (e.g., `.txt`, `.md`) in Finder
2. Select "Get Info"
3. In the "Open with" section, select "WezTerm-Nvim"
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

### Changing Paths

For Intel Macs or custom installation locations, edit `.chezmoi.toml`:

```toml
[data]
    wezterm_path = "/usr/local/bin/wezterm"  # Intel Mac
    nvim_path = "/usr/local/bin/nvim"
```

## Troubleshooting

### If the app doesn't open

1. Check security settings:
   - System Preferences > Security & Privacy > General
   - Allow "WezTerm-Nvim"

2. Reset LaunchServices database:
   ```bash
   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
   ```

### If paths are not found

```bash
# Check wezterm and nvim paths
which wezterm
which nvim
```

Set the confirmed paths in `.chezmoi.toml`.

## Reinstall

If you've changed settings or encounter issues:

```bash
# Rebuild the app
chezmoi apply --force-refresh-externals
```