# dotfiles

Personal dotfiles and development environment setup for macOS.

## Quick Setup (Recommended)

**One-Command Installation**:

```sh
# Install everything - automatically switches to interactive mode when needed
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh
```

This smart installer will:
- ✅ Automatically detect if Homebrew needs installation
- ✅ Switch to interactive mode for password prompts
- ✅ Install Homebrew and all packages from Brewfile
- ✅ Set up dotfiles, macOS settings, Docker, MCP servers, and Serena
- ✅ Handle all password prompts properly

**Install specific components**:
```sh
# Dotfiles only (no Homebrew required)
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s dotfiles

# macOS settings only
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s macos

# Other components
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s {docker|mcp|serena}
```

## Manual Setup

If you prefer to clone the repository first:

```sh
git clone https://github.com/gr1m0h/dot.git
cd dot
script/setup.sh all
```

### How It Works

The installer is smart:
1. When you run the piped command, it detects if it's in non-interactive mode
2. If Homebrew installation is needed, it automatically re-launches itself interactively
3. This allows proper password prompts while keeping the simple one-liner interface

No need for complex commands - just use:
```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh
```

## Available Components

| Component | Description |
|-----------|-------------|
| `dotfiles` | Shell configuration files (.zshrc, .gitconfig, starship, etc.) |
| `homebrew` | Package manager and application installation via Brewfile |
| `macos` | macOS system preferences and defaults |
| `docker` | Docker environment setup with Colima |
| `mcp` | Claude MCP (Model Context Protocol) servers setup |
| `serena` | Serena AI code assistant configuration |
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

### MCP Servers
- **GitHub Remote MCP server**: Integration with GitHub API for Claude
- **Authentication**: Uses GitHub PAT from `.env` file

### Serena Configuration
- **AI Code Assistant**: Semantic code understanding and navigation
- **Project Management**: Intelligent project-based code analysis
- **Memory System**: Persistent project knowledge storage

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
- `script/setup.sh`: Adjust installation behavior

## Troubleshooting

If the installation fails:

1. **Check internet connection**: All files are downloaded from GitHub
2. **Verify permissions**: Some operations require admin privileges
3. **Manual fallback**: Clone the repository and run components individually
4. **Check logs**: Most operations provide detailed error messages

```sh
# Run individual components for debugging
script/setup.sh dotfiles
script/setup.sh homebrew
script/setup.sh macos
script/setup.sh docker
script/setup.sh mcp
script/setup.sh serena
```
