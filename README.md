# dotfiles

Personal dotfiles and development environment setup for macOS.

## Quick Setup (Recommended)

Execute the setup script directly from GitHub:

```sh
# Install everything (dotfiles, homebrew, macos settings, docker)
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh

# Install only specific components
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s dotfiles
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s homebrew
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s macos
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s docker
```

## Manual Setup

If you prefer to clone the repository first:

```sh
git clone https://github.com/gr1m0h/dot.git
cd dot
script/setup all
```

## Available Components

| Component | Description |
|-----------|-------------|
| `dotfiles` | Shell configuration files (.zshrc, .gitconfig, starship, etc.) |
| `homebrew` | Package manager and application installation via Brewfile |
| `macos` | macOS system preferences and defaults |
| `docker` | Docker environment setup with Colima |
| `all` | Install all components (default) |

## What's Included

### Dotfiles
- **Zsh configuration**: Custom aliases, completions, and environment variables
- **Git configuration**: Aliases, signing with 1Password, and sensible defaults  
- **Starship prompt**: Minimal, fast shell prompt with git integration
- **Editor configuration**: EditorConfig for consistent coding style

### Applications (via Homebrew)
- Development tools: `git`, `mise`, `pnpm`, `swiftgen`, `mockolo`
- Terminal: `wezterm` with custom configuration
- Productivity: `1password`, `hammerspoon`, `slack`
- Browsers: `brave-browser`
- Design: `opal-composer`
- And more...

### macOS Configuration
- Finder: Show file extensions, path bar, and status bar
- Dock: Auto-hide, remove recent apps, minimal configuration
- Keyboard: Fast key repeat, function key mode
- Security: Enable firewall and screensaver password
- Development: Install Xcode Command Line Tools and Rosetta 2

### Docker Setup
- **Colima**: Lightweight container runtime for macOS
- **Docker context**: Automatically configured for Colima
- **Socket linking**: Compatible with standard Docker workflows

## Security Notice

This repository is designed to be safe for public sharing:
- ❌ No API keys, tokens, or credentials
- ❌ No personal/sensitive information  
- ✅ Only configuration and preference files
- ✅ Safe system defaults and tool configurations

## Requirements

- macOS (tested on macOS Sequoia 15.x, compatible with Sonoma 14.x+)
- Internet connection for downloading packages
- Administrative privileges for some system configurations

## Customization

Fork this repository and modify the configuration files to match your preferences:
- `Brewfile`: Add/remove applications and packages
- `dots/.zshrc`: Customize shell environment
- `dots/.config/starship.toml`: Modify prompt appearance
- `script/setup`: Adjust installation behavior

## Troubleshooting

If the installation fails:

1. **Check internet connection**: All files are downloaded from GitHub
2. **Verify permissions**: Some operations require admin privileges
3. **Manual fallback**: Clone the repository and run components individually
4. **Check logs**: Most operations provide detailed error messages

```sh
# Run individual components for debugging
script/setup dotfiles
script/setup homebrew
script/setup macos
script/setup docker
```
