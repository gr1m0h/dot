# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/install.sh | sh
```

This installs:

- chezmoi (if needed)
- All dotfiles and configurations
- Homebrew packages
- Development tools via mise

## Update

```sh
chezmoi update
```

## Manual Installation

```sh
# Install chezmoi
brew install chezmoi

# Initialize and apply
chezmoi init --apply gr1m0h/dot
```

## Options

### Preview changes

```sh
chezmoi diff
```

### Edit configuration

```sh
chezmoi edit <file>
```

### Update from repo

```sh
chezmoi update
```

### Apply without downloading

```sh
chezmoi apply
```

## Editing Files Managed by chezmoi

When you want to modify dotfiles managed by chezmoi, you have two approaches:

### Method 1: Edit source files directly (Recommended)

```sh
# Edit the source file in chezmoi's directory
chezmoi edit ~/.zshrc

# Preview what changes will be applied
chezmoi diff

# Apply changes to your home directory
chezmoi apply
```

### Method 2: Edit local files then add changes

```sh
# Edit the file in your home directory
vim ~/.zshrc

# Add the changes back to chezmoi
chezmoi add ~/.zshrc

# Verify the changes were captured
chezmoi diff
```

### Common operations

#### See which files are managed by chezmoi

```sh
chezmoi managed
```

#### Navigate to chezmoi source directory

```sh
chezmoi cd
```

#### Update from remote repository

```sh
# Pull latest changes and apply them
chezmoi update
```

### Working with template files

Some files use chezmoi's templating feature (`.tmpl` extension):

```sh
# Edit a template file
chezmoi edit ~/.config/git/config

# The source might be a template like:
# ~/.local/share/chezmoi/home/dot_config/git/config.tmpl
```

### Examples

```sh
# Edit zsh configuration
chezmoi edit ~/.zshrc

# Edit git configuration
chezmoi edit ~/.config/git/config

# Edit Ghostty configuration
chezmoi edit ~/.config/ghostty/config
```

### Important notes

- Always use `chezmoi edit` for files managed by chezmoi to ensure changes are properly tracked
- Use `chezmoi diff` before applying to preview changes
- Local edits without `chezmoi add` will be overwritten on next `chezmoi apply`
- Template files (`.tmpl`) are processed during `chezmoi apply`

## Brewfile Management

The `Brewfile` in this repository is designed for **initial setup only**. It installs all required Homebrew packages during the first run.

### How it works

1. During initial setup, the script `home/.chezmoiscripts/run_once_02-install-packages.sh.tmpl` runs
2. It copies `Brewfile` to your home directory and runs `brew bundle`
3. After successful installation, you can remove the Brewfile:
   ```sh
   rm ~/Brewfile
   ```

## Documentation

- [Ghostty-Nvim File Association Setup](docs/ghostty-nvim-setup.md) - Configure file associations to open files in Ghostty with Nvim

## Requirements

- macOS 14.0+
- Internet connection
- Admin privileges (for some configurations)
