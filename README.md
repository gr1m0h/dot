# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/update/install.sh | sh
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

## Requirements

- macOS 14.0+
- Internet connection
- Admin privileges (for some configurations)