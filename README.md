# dotfiles

Personal dotfiles and development environment setup for macOS.

## Quick Setup (Recommended)

**Interactive Installation (Supports Homebrew with Password Prompt)**:

```sh
# Download and run interactively (recommended)
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh -o install.sh && sh install.sh && rm install.sh
```

This will:
- Install Homebrew (prompts for password)
- Install all packages from Brewfile
- Set up dotfiles
- Configure macOS settings (prompts for password for system-level changes)
- Set up Docker with Colima (may prompt for password)
- Configure MCP servers and Serena

**Password prompts occur for:**
1. Homebrew installation (initial setup)
2. macOS security settings (firewall, login settings)
3. Docker socket configuration (optional)

**Install specific components only**:
```sh
# Download script and run with component option
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh -o install.sh && sh install.sh dotfiles && rm install.sh
```

**Non-interactive Installation (No Homebrew)**:
```sh
# For CI/automation or when Homebrew is already installed
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s dotfiles
```

## Manual Setup

If you prefer to clone the repository first:

```sh
git clone https://github.com/gr1m0h/dot.git
cd dot
script/setup.sh all
```

### One-liner Installation

For the absolute quickest setup, use this one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh -o install.sh && sh install.sh && rm install.sh
```

This approach:
- ✅ Downloads the script first, then runs it interactively
- ✅ Allows password prompts for Homebrew installation
- ✅ Automatically cleans up the downloaded script
- ✅ Works with all components (Homebrew, dotfiles, etc.)

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
