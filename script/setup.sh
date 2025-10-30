#!/bin/sh

# Exit on error, undefined variables, and propagate errors in pipes
set -euo pipefail

# Configuration
REPO_URL="https://raw.githubusercontent.com/gr1m0h/dot/main"
# Set DOTPATH - for local development use the script's parent directory
if [ -d "$(dirname "$0")/../.git" ]; then
  DOTPATH="$(cd "$(dirname "$0")/.." && pwd)"
else
  # For remote execution, we don't need a local DOTPATH anymore
  DOTPATH=""
fi

# State tracking
STATE_FILE="$HOME/.setup-state"
STATE_DIR="$HOME/.setup-state.d"
mkdir -p "$STATE_DIR"

# Temporary directory
TEMP_DIR=$(mktemp -d)

title() {
  echo ""
  echo "===== $1 ====="
  echo ""
}

err() {
  echo "[ERROR] $1"
  exit 1
}

warn() {
  echo "[WARNING] $1"
}

info() {
  echo "[INFO] $1"
}

success() {
  echo "[SUCCESS] $1"
}

download_file() {
  local src="$1"
  local dest="$2"

  if ! curl -fsSL "$REPO_URL/$src" -o "$dest"; then
    return 1
  fi
  return 0
}

# Check if a step has been completed
check_step() {
  local step="$1"
  [ -f "$STATE_DIR/$step" ]
}

# Mark a step as completed
mark_step() {
  local step="$1"
  touch "$STATE_DIR/$step"
}

# Detect current shell for mise activate
get_shell_type() {
  # Check if we're running in zsh
  if [ -n "${ZSH_VERSION:-}" ]; then
    echo "zsh"
  # Check if we're running in bash
  elif [ -n "${BASH_VERSION:-}" ]; then
    echo "bash"
  # Default to bash if we can't detect
  else
    echo "bash"
  fi
}

# Run a function with error handling
run_step() {
  local step_name="$1"
  local func_name="$2"
  
  if check_step "$step_name"; then
    info "$step_name already completed... Skipping."
    return 0
  fi
  
  info "Running $step_name"
  if "$func_name"; then
    mark_step "$step_name"
    success "$step_name completed successfully"
    return 0
  else
    warn "$step_name failed"
    return 1
  fi
}

setup_dotfiles() {
  title "Downloading dotfiles"
  
  # Track overall success
  local overall_success=0

  local dotfiles="
.editorconfig
.zshenv
.mmcp.json
"

  for dotfile in $dotfiles; do
    if [ -e "$HOME/$dotfile" ]; then
      info "$dotfile already exists... Skipping."
    else
      info "Downloading $dotfile to $HOME/$dotfile"
      download_file "dots/$dotfile" "$HOME/$dotfile"
    fi
  done

  # Setup .config directory structure
  info "Setting up .config directory"
  mkdir -p "$HOME/.config/zsh"
  mkdir -p "$HOME/.config/starship"

  # Zsh configuration files
  local zsh_configs="
.zshrc
.zsh_aliases
.zsh_completions
"

  for config in $zsh_configs; do
    if [ -e "$HOME/.config/zsh/$config" ]; then
      info "zsh/$config already exists... Skipping."
    else
      info "Downloading zsh/$config to $HOME/.config/zsh/$config"
      download_file "dots/.config/zsh/$config" "$HOME/.config/zsh/$config"
    fi
  done

  # Starship configuration
  if [ -e "$HOME/.config/starship/starship.toml" ]; then
    info "starship/starship.toml already exists... Skipping."
  else
    info "Downloading starship/starship.toml to $HOME/.config/starship/starship.toml"
    download_file "dots/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
  fi

  # Additional config directories
  local config_dirs="
hammerspoon
sheldon
wezterm
git
mise
nvim
"

  for dir in $config_dirs; do
    mkdir -p "$HOME/.config/$dir"
    info "Setting up $dir configuration"

    case "$dir" in
    hammerspoon)
      if [ -e "$HOME/.config/hammerspoon/init.lua" ]; then
        info "hammerspoon/init.lua already exists... Skipping."
      else
        download_file "dots/.config/hammerspoon/init.lua" "$HOME/.config/hammerspoon/init.lua"
      fi
      ;;
    sheldon)
      if [ -e "$HOME/.config/sheldon/plugins.toml" ]; then
        info "sheldon/plugins.toml already exists... Skipping."
      else
        download_file "dots/.config/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
      fi
      ;;
    wezterm)
      if [ -e "$HOME/.config/wezterm/wezterm.lua" ]; then
        info "wezterm/wezterm.lua already exists... Skipping."
      else
        download_file "dots/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
      fi
      ;;
    git)
      if [ -e "$HOME/.config/git/config" ]; then
        info "git/config already exists... Skipping."
      else
        download_file "dots/.config/git/config" "$HOME/.config/git/config"
      fi
      if [ -e "$HOME/.config/git/ignore" ]; then
        info "git/ignore already exists... Skipping."
      else
        download_file "dots/.config/git/ignore" "$HOME/.config/git/ignore"
      fi
      ;;
    mise)
      if [ -e "$HOME/.config/mise/config.toml" ]; then
        info "mise/config.toml already exists... Skipping."
      else
        download_file "dots/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
      fi
      ;;
    nvim)
      # nvim has many files, so download the entire structure
      if [ -e "$HOME/.config/nvim/init.lua" ]; then
        info "nvim config already exists... Skipping."
      else
        info "Setting up nvim configuration"
        # Download all nvim config files
        download_file "dots/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
        download_file "dots/.config/nvim/.neoconf.json" "$HOME/.config/nvim/.neoconf.json"
        download_file "dots/.config/nvim/.markdownlint.json" "$HOME/.config/nvim/.markdownlint.json"
        download_file "dots/.config/nvim/markdownlint.jsonc" "$HOME/.config/nvim/markdownlint.jsonc"
        download_file "dots/.config/nvim/stylua.toml" "$HOME/.config/nvim/stylua.toml"
        download_file "dots/.config/nvim/lazyvim.json" "$HOME/.config/nvim/lazyvim.json"
        download_file "dots/.config/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"
        
        # Create lua directories and download files
        mkdir -p "$HOME/.config/nvim/lua/config"
        mkdir -p "$HOME/.config/nvim/lua/plugins"
        
        download_file "dots/.config/nvim/lua/config/autocmds.lua" "$HOME/.config/nvim/lua/config/autocmds.lua"
        download_file "dots/.config/nvim/lua/config/keymaps.lua" "$HOME/.config/nvim/lua/config/keymaps.lua"
        download_file "dots/.config/nvim/lua/config/options.lua" "$HOME/.config/nvim/lua/config/options.lua"
        download_file "dots/.config/nvim/lua/config/lazy.lua" "$HOME/.config/nvim/lua/config/lazy.lua"
        
        download_file "dots/.config/nvim/lua/plugins/lint.lua" "$HOME/.config/nvim/lua/plugins/lint.lua"
        download_file "dots/.config/nvim/lua/plugins/example.lua" "$HOME/.config/nvim/lua/plugins/example.lua"
      fi
      ;;
    esac
  done
  
  return $overall_success
}

setup_mise() {
  title "Setting up mise tools"
  
  # Check if mise is available
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not installed. Please ensure Homebrew setup completed successfully."
    return 1
  fi
  
  # Ensure mise config exists
  if [ ! -f "$HOME/.config/mise/config.toml" ]; then
    warn "mise config not found. Please ensure dotfiles setup completed successfully."
    return 1
  fi
  
  info "Installing all mise tools..."
  if mise install; then
    success "All mise tools installed successfully"
    info "Tools installed include: Node.js, Python, Go, Docker, Claude CLI, and more"
  else
    warn "Some mise tools failed to install"
    return 1
  fi
  
  return 0
}

setup_homebrew() {
  title "Setting up Homebrew"

  # install if Homebrew is not installed
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    
    # Check if we have sudo access
    if ! sudo -n true 2>/dev/null; then
      if [ ! -t 0 ]; then
        # Non-interactive mode without sudo
        warn "Homebrew installation requires administrator privileges."
        warn "Please run one of these commands first:"
        warn ""
        warn "Option 1: Cache sudo password, then run installer:"
        warn "  sudo -v"
        warn "  curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh"
        warn ""
        warn "Option 2: Install Homebrew manually:"
        warn "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        warn "  Then run: curl -fsSL https://raw.githubusercontent.com/gr1m0h/dot/main/script/install.sh | sh"
        return 1
      else
        # Interactive mode - prompt for password
        info "Please enter your password when prompted."
      fi
    fi
    
    # Install Homebrew
    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      success "Homebrew installed successfully"
    else
      warn "Failed to install Homebrew"
      return 1
    fi

    # Make sure brew is in PATH
    case "$(uname -m)" in
    arm64)
      if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # Also add to current shell session
        export PATH="/opt/homebrew/bin:$PATH"
      else
        warn "Homebrew installation failed - brew executable not found"
        return 1
      fi
      ;;
    x86_64)
      if [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
        # Also add to current shell session
        export PATH="/usr/local/bin:$PATH"
      else
        warn "Homebrew installation failed - brew executable not found"
        return 1
      fi
      ;;
    *)
      warn "Unsupported architecture: $(uname -m)"
      return 1
      ;;
    esac

    # Verify brew is now in path
    if ! command -v brew >/dev/null 2>&1; then
      warn "Homebrew installation succeeded but brew is not in PATH"
      return 1
    fi
    
    info "Homebrew installed successfully at: $(which brew)"
    info "Note: To ensure Homebrew is available in future sessions, add the following to your shell profile:"
    case "$(uname -m)" in
    arm64)
      info "  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
      ;;
    x86_64)
      info "  eval \"\$(/usr/local/bin/brew shellenv)\""
      ;;
    esac
  else
    info "Homebrew already installed at: $(which brew)"
    # Ensure brew is in PATH even if already installed
    case "$(uname -m)" in
    arm64)
      if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      ;;
    x86_64)
      if [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
      ;;
    esac
  fi

  # Install brew dependencies directly from GitHub repository
  info "Installing brew dependencies from GitHub repository Brewfile"
  local brewfile_url="$REPO_URL/Brewfile"
  
  # First, download the Brewfile to a temporary location
  local temp_brewfile="$TEMP_DIR/Brewfile"
  if curl -fsSL "$brewfile_url" -o "$temp_brewfile"; then
    info "Successfully downloaded Brewfile from repository"
    
    # Run brew bundle with the downloaded Brewfile
    if ! brew bundle --file="$temp_brewfile"; then
      warn "Failed to install some Homebrew packages. Check logs for details."
      info "You can try running 'brew bundle' manually later with the Brewfile from the repository."
    else
      success "Homebrew packages installed successfully"
    fi
  else
    warn "Failed to download Brewfile from repository"
    return 1
  fi
  
  return 0
}

setup_macos() {
  title "Configuring macOS"
  if [ "$(uname)" != "Darwin" ]; then
    warn "macOS not detected. Skipping."
    return 0
  fi

  info "Creating workspace directory"
  if ! mkdir -p "$HOME/Documents/workspace"; then
    warn "Failed to create workspace directory"
  else
    success "Created workspace directory at $HOME/Documents/workspace"
  fi

  # Install command line tools for xcode if not installed
  if [ ! -d /Library/Developer/CommandLineTools ]; then
    info "Installing Xcode Command Line Tools"
    # xcode-select --install is interactive and can't be scripted effectively
    # Using a more reliable approach
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    if [ -n "$PROD" ]; then
      info "Found Command Line Tools update: $PROD"
      if ! softwareupdate -i "$PROD" --verbose; then
        warn "Failed to install Xcode Command Line Tools"
        info "You may need to install manually with 'xcode-select --install'"
      else
        success "Installed Xcode Command Line Tools successfully"
      fi
    else
      warn "No Command Line Tools found in software update"
      info "Falling back to interactive installation"
      xcode-select --install || warn "Failed to install Xcode Command Line Tools"
      info "This may require user interaction - check for dialogs"
    fi
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    info "Xcode Command Line Tools already installed"
  fi

  # Install Rosetta 2 on Apple Silicon
  if [ "$(uname -m)" = "arm64" ]; then
    if ! pgrep -q oahd; then
      info "Installing Rosetta for Apple Silicon"
      softwareupdate --install-rosetta --agree-to-license || warn "Failed to install Rosetta"
    else
      info "Rosetta already installed"
    fi
  fi

  info "Configuring Terminal"
  defaults write com.apple.terminal StringEncodings -array 4

  info "Configuring Safari"
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true 2>/dev/null || info "Safari settings may need manual configuration due to privacy restrictions"

  info "Configuring Finder"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.Finder AppleShowAllFiles -bool false
  chflags nohidden ~/Library
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder NewWindowTarget -string "PfDe"

  info "Configuring Dock"
  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dock orientation bottom
  defaults write com.apple.dock "mineffect" -string "suck"
  defaults write com.apple.dock largesize -float 94
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock show-recents -bool false
  defaults write com.apple.dock show-process-indicators -bool false

  info "Configuring Menu Bar"
  # Menu bar configuration may not work on newer macOS versions
  if [ -f "/System/Library/CoreServices/Menu Extras/Volume.menu" ]; then
    for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
      defaults write "${domain}" dontAutoLoad -array \
        "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
        "/System/Library/CoreServices/Menu Extras/Volume.menu" 2>/dev/null || warn "Menu bar configuration may require manual setup"
    done
  else
    info "Menu bar configuration updated for newer macOS versions"
  fi

  info "Configuring Keyboard"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  defaults write NSGlobalDomain AppleFontSmoothing -int 2
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  info "Configuring Trackpad"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

  info "Configuring Security and Privacy"
  defaults write com.apple.screensaver askForPassword -bool true
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  
  # Enable firewall and disable automatic login (requires sudo)
  info "Configuring system security settings..."
  info "Please enter your password when prompted."
  
  # Try to enable firewall
  if sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1; then
    success "Firewall enabled"
  else
    warn "Failed to enable firewall - you may need to enable it manually in System Settings > Security & Privacy"
  fi
  
  # Try to disable automatic login
  if sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null; then
    success "Automatic login disabled"
  else
    info "Automatic login already disabled or not configured"
  fi

  info "Configuring Clock"
  defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE d MMM HH:mm' 2>/dev/null || warn "Clock format may need manual configuration in System Settings"

  info "Restarting affected applications"
  for app in Safari Finder Dock SystemUIServer; do
    killall "$app" >/dev/null 2>&1 || true
  done

  success "macOS configured successfully"
  return 0
}

setup_docker() {
  title "Setting up docker"

  # Check if Homebrew is available
  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew not available. Cannot install Docker automatically."
    info "Please install Homebrew first, then run this script again."
    return 1
  fi

  # Check if mise is available
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not installed. Installing docker and colima via Homebrew as fallback..."
    
    # Install docker if not available
    if ! command -v docker >/dev/null 2>&1; then
      info "Docker not installed. Installing via Homebrew..."
      if brew install docker; then
        success "Docker installed successfully"
      else
        warn "Failed to install Docker"
        return 1
      fi
    fi

    # Install colima if not available
    if ! command -v colima >/dev/null 2>&1; then
      info "Colima not installed. Installing via Homebrew..."
      if brew install colima; then
        success "Colima installed successfully"
      else
        warn "Failed to install Colima"
        return 1
      fi
    fi
  else
    # Use mise to install docker and colima
    info "Ensuring docker and colima are installed via mise..."
    if mise install; then
      success "mise tools installed successfully"
    else
      warn "Failed to install mise tools"
    fi
    
    # Ensure mise is activated in current shell
    eval "$(mise activate $(get_shell_type))"
  fi

  # Start Colima if not running
  info "Checking Colima status"
  if ! colima status >/dev/null 2>&1; then
    info "Starting Colima with default configuration"
    if ! colima start; then
      warn "Failed to start Colima. Please check logs with 'colima logs' and try again manually."
      return 1
    fi
    success "Colima started successfully"
  else
    info "Colima is already running"
  fi

  # Configure Docker context
  info "Setting up docker context to use colima"
  if ! docker context use colima; then
    warn "Failed to set docker context to colima"
    info "You can set it manually with 'docker context use colima'"
  else
    success "Docker context set to colima"
  fi

  # Create docker socket link (with better error handling)
  info "Linking docker socket for compatibility"
  if [ -S "$HOME/.config/colima/default/docker.sock" ]; then
    info "Creating docker socket link..."
    info "Please enter your password when prompted."
    
    if sudo ln -sf "$HOME/.config/colima/default/docker.sock" /var/run/docker.sock; then
      success "Created docker socket link successfully"
    else
      warn "Failed to create docker socket link"
      warn "This is not critical - Docker will still work through colima context"
    fi
  else
    warn "Colima docker socket not found at $HOME/.config/colima/default/docker.sock"
    info "Make sure Colima is running properly"
  fi
  
  return 0
}

setup_mcp_servers() {
  title "Setting up Claude MCP Servers"

  # Check if mise is available
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not installed. Please ensure Homebrew setup completed successfully."
    return 1
  fi

  # Install mise tools including claude-code
  info "Installing mise tools (including claude-code)..."
  if mise install; then
    success "mise tools installed successfully"
  else
    warn "Failed to install mise tools"
    return 1
  fi

  # Ensure mise is activated in current shell
  eval "$(mise activate $(get_shell_type))"

  # Check if claude command is available
  if ! command -v claude >/dev/null 2>&1; then
    warn "Claude CLI not found after mise install."
    info "You may need to restart your shell or run: eval \"\$(mise activate \$(get_shell_type))\""
    return 1
  fi

  if [ ! -e "$HOME/.env" ]; then
    warn ".env not found."
    return 1
  fi

  # Download Claude settings.json only if different
  info "Checking Claude settings.json"
  mkdir -p "$HOME/.claude"
  local temp_settings="$TEMP_DIR/settings.json"
  if download_file "dots/.claude/settings.json" "$temp_settings"; then
    if [ -f "$HOME/.claude/settings.json" ]; then
      if ! diff -q "$HOME/.claude/settings.json" "$temp_settings" >/dev/null 2>&1; then
        info "settings.json has changed, updating..."
        # Backup existing settings
        cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.backup"
        cp "$temp_settings" "$HOME/.claude/settings.json"
        success "Updated Claude settings.json (backup saved as settings.json.backup)"
      else
        info "Claude settings.json is up to date"
      fi
    else
      info "Creating new Claude settings.json"
      cp "$temp_settings" "$HOME/.claude/settings.json"
      success "Created Claude settings.json"
    fi
  else
    warn "Failed to download Claude settings.json"
    return 1
  fi

  # Check if GitHub MCP server already exists
  info "Checking GitHub Remote MCP server"
  if claude mcp list 2>/dev/null | grep -q "github"; then
    info "GitHub Remote MCP server already configured"
  else
    info "Adding GitHub Remote MCP server"
    local github_token=$(grep GITHUB_PAT "$HOME/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    if [ -z "$github_token" ]; then
      warn "GITHUB_PAT not found in .env file"
      return 1
    fi
    if ! claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $github_token"; then
      warn "Failed to add GitHub Remote MCP server"
    else
      success "Added GitHub Remote MCP server"
    fi
  fi

  info "Checking MCP server health"
  if ! claude mcp list; then
    warn "Failed to list MCP servers"
  else
    success "MCP servers configured successfully"
  fi
  
  return 0
}

setup_serena() {
  title "Setting up Serena Configuration"

  info "Setting up Serena directory"
  mkdir -p "$HOME/.serena"

  # Download serena_config.yml
  if [ -e "$HOME/.serena/serena_config.yml" ]; then
    info "serena_config.yml already exists... Skipping."
  else
    info "Downloading serena_config.yml to $HOME/.serena/serena_config.yml"
    if ! download_file "dots/.serena/serena_config.yml" "$HOME/.serena/serena_config.yml"; then
      warn "Failed to download serena_config.yml"
      return 1
    fi
  fi

  success "Serena configuration setup completed"
  return 0
}

# Cleanup function
cleanup() {
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Main execution
case "$1" in
dotfiles)
  run_step "dotfiles" setup_dotfiles || true
  ;;
homebrew)
  run_step "homebrew" setup_homebrew || true
  ;;
macos)
  run_step "macos" setup_macos || true
  ;;
mise)
  run_step "mise" setup_mise || true
  ;;
docker)
  run_step "docker" setup_docker || true
  ;;
mcp)
  run_step "mcp_servers" setup_mcp_servers || true
  ;;
serena)
  run_step "serena" setup_serena || true
  ;;
all)
  # Run all steps, continuing even if some fail
  run_step "dotfiles" setup_dotfiles || warn "Dotfiles setup failed, continuing..."
  run_step "homebrew" setup_homebrew || warn "Homebrew setup failed, continuing..."
  run_step "mise" setup_mise || warn "mise setup failed, continuing..."
  run_step "macos" setup_macos || warn "macOS setup failed, continuing..."
  run_step "docker" setup_docker || warn "Docker setup failed, continuing..."
  run_step "mcp_servers" setup_mcp_servers || warn "MCP servers setup failed, continuing..."
  run_step "serena" setup_serena || warn "Serena setup failed, continuing..."
  ;;
*)
  printf "\nUsage: %s {dotfiles|homebrew|macos|docker|mcp|serena|all}\n" "$(basename "$0")"
  printf "\nTo reset progress and run again: rm -rf ~/.setup-state.d\n"
  exit 1
  ;;
esac

success "Done."
