# dotfiles

Personal dotfiles and development environment setup for macOS using [chezmoi](https://www.chezmoi.io/).

## Quick Setup (New Method with chezmoi)

```sh
# One-line install (installs chezmoi if needed, then applies dotfiles)
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/update/install.sh | sh
```

This will:
1. Install chezmoi (if not already installed)
2. Initialize and apply all dotfiles
3. Run all setup scripts automatically (Homebrew, mise, macOS settings, etc.)

### Update dotfiles later
```sh
chezmoi update
```

## Legacy Setup (Original Method)

### New Mac Setup
```sh
# Step 1: Ensure you have administrator access
sudo -v

# Step 2: Install everything including Homebrew
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh
```

The installer will automatically:
- Install Homebrew (if not installed)
- Install all packages from Brewfile
- Configure dotfiles and system settings

### If Homebrew is already installed
```sh
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh
```

**Install specific components:**
```sh
# Components that don't require Homebrew
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s dotfiles
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s macos
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s serena

# Components that require Homebrew (install Homebrew first)
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s docker
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh -s mcp
```

## What Gets Installed

- **chezmoi**: Dotfiles manager (new method)
- **Homebrew**: Package manager for macOS
- **mise**: Runtime version manager (manages Node.js, Python, Go, etc.)
- **Development Tools**: Via mise - Claude CLI, Docker, Neovim, and more
- **Packages**: From Brewfile - Git, GnuPG, GUI apps
- **Dotfiles**: Zsh configuration, Git config, editor settings
- **macOS Settings**: Dock, Finder, security preferences
- **MCP Servers**: Claude integration tools
- **Serena**: Development environment configuration

## Manual Setup

### Using chezmoi (Recommended)
```sh
# Install chezmoi
brew install chezmoi  # or: sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize from this repo
chezmoi init gr1m0h/dot

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply
```

### Legacy method
```sh
git clone https://github.com/gr1m0h/dot.git
cd dot
script/setup.sh all
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

## Troubleshooting

### Homebrew installation fails with "Need sudo access"
This happens when running the installer via pipe (`curl | sh`). Solution:
```sh
# First, cache your sudo password
sudo -v

# Then run the installer
curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh
```

### Claude CLI not found
The Claude desktop app (`cask "claude"`) is different from Claude CLI (`claude-code`). The CLI is installed via mise along with other development tools. Make sure mise installation completes successfully.

### Docker setup fails
Docker and Colima are installed via mise. Make sure mise installation completes successfully. If mise is not available, the installer will fall back to installing via Homebrew.

### Tools not found after installation
Many development tools (Node.js, Python, Go, Docker, etc.) are installed via mise. After installation, you may need to:
1. Restart your terminal
2. Or run: `eval "$(mise activate zsh)"` (or `sh` for sh/bash)

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

### With chezmoi (Recommended)
- Edit files in `home/` directory
- Use `chezmoi edit <file>` to edit managed files
- Use templates for machine-specific values (`.tmpl` files)
- Test changes with `chezmoi diff` before applying

### Legacy structure
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
