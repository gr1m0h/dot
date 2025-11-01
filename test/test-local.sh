#!/bin/bash
#
# Local testing script for dotfiles installation on macOS
# This script creates a temporary environment to test the installation
# without affecting your actual home directory
#
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Local Dotfiles Installation Test ===${NC}"
echo -e "${YELLOW}This will test the installation in a temporary directory${NC}"
echo ""

# Create temporary test directory
TEST_DIR="$(mktemp -d /tmp/dotfiles-test.XXXXXX)"
echo -e "${BLUE}Test directory: ${TEST_DIR}${NC}"

# Create a backup of current HOME (just the variable)
ORIGINAL_HOME="$HOME"
ORIGINAL_PATH="$PATH"

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}Cleaning up...${NC}"
    
    # Restore original environment
    export HOME="$ORIGINAL_HOME"
    export PATH="$ORIGINAL_PATH"
    
    
    # Ask before removing test directory
    read -p "Remove test directory ${TEST_DIR}? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TEST_DIR"
        echo -e "${GREEN}Test directory removed${NC}"
    else
        echo -e "${YELLOW}Test directory preserved at: ${TEST_DIR}${NC}"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Function to test installation
test_installation() {
    echo -e "${YELLOW}Setting up test environment...${NC}"
    
    # Set HOME to test directory
    export HOME="$TEST_DIR"
    export PATH="$TEST_DIR/bin:$PATH"
    
    # Set chezmoi-specific environment variables
    export CHEZMOI_CONFIG_DIR="$TEST_DIR/.config/chezmoi"
    export CHEZMOI_CACHE_DIR="$TEST_DIR/.cache/chezmoi"
    export CHEZMOI_DATA_DIR="$TEST_DIR/.local/share/chezmoi"
    
    # Copy current git config to test environment (for chezmoi init)
    if [ -f "$ORIGINAL_HOME/.gitconfig" ]; then
        mkdir -p "$TEST_DIR"
        cp "$ORIGINAL_HOME/.gitconfig" "$TEST_DIR/.gitconfig"
    fi
    
    echo -e "${YELLOW}Running installation script...${NC}"
    echo ""
    
    # Get the absolute path to the repository
    REPO_PATH="$(cd "$(dirname "$0")/.." && pwd)"
    
    # Run chezmoi init from local repository instead of remote
    if command -v chezmoi >/dev/null 2>&1; then
        echo "Using existing chezmoi installation"
    else
        echo "Installing chezmoi..."
        # Install chezmoi first
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$TEST_DIR/bin"
        export PATH="$TEST_DIR/bin:$PATH"
    fi
    
    # Initialize from local repository
    echo "Initializing from local repository: $REPO_PATH"
    # Set environment variable to skip package installation during testing
    export CHEZMOI_TEST_MODE=1
    export SKIP_BREW_INSTALL=1
    
    # Create chezmoi config directory
    mkdir -p "$TEST_DIR/.config/chezmoi"
    
    # Create a test source directory with only the files we want to test
    TEST_SOURCE="$TEST_DIR/.test-source"
    mkdir -p "$TEST_SOURCE"
    
    # Copy repository structure
    cp -r "$REPO_PATH/.chezmoiroot" "$TEST_SOURCE/" 2>/dev/null || true
    cp -r "$REPO_PATH/.chezmoiignore" "$TEST_SOURCE/" 2>/dev/null || true
    cp -r "$REPO_PATH/home" "$TEST_SOURCE/"
    
    # Remove problematic template file
    rm -f "$TEST_SOURCE/home/dot_local/share/chezmoi-scripts/WezTerm-Nvim.applescript.tmpl"
    
    # Create a minimal chezmoi config with test data
    cat > "$TEST_DIR/.config/chezmoi/chezmoi.toml" << EOF
[data]
    name = "Test User"
    email = "test@example.com"
    test_mode = true
    wezterm_path = "/opt/homebrew/bin/wezterm"
    nvim_path = "/opt/homebrew/bin/nvim"
    codespaces = false
    container = false
    extra_extensions = []
    
[merge]
    command = "nvim"
    args = ["-d"]
    
[diff]
    exclude = ["scripts"]
EOF
    
    # Initialize chezmoi from the test source directory
    echo "Initializing chezmoi from test source directory..."
    # Skip scripts during testing
    chezmoi init --apply --exclude=scripts --source "$TEST_SOURCE"
    
    # Debug: Check chezmoi configuration
    echo ""
    echo "Checking chezmoi configuration..."
    echo "Config dir: $CHEZMOI_CONFIG_DIR"
    echo "Data dir: $CHEZMOI_DATA_DIR"
    
    # Debug: Check what chezmoi sees
    echo ""
    echo "Checking chezmoi source directory..."
    SOURCE_PATH=$(chezmoi source-path)
    echo "Chezmoi source path: $SOURCE_PATH"
    
    # List source directory contents
    if [ -d "$SOURCE_PATH" ]; then
        echo "Source directory contents:"
        ls -la "$SOURCE_PATH" | head -10
        
        # Check for .chezmoiroot
        if [ -f "$SOURCE_PATH/.chezmoiroot" ]; then
            echo "Found .chezmoiroot: $(cat "$SOURCE_PATH/.chezmoiroot")"
        fi
        
        # Check for home directory
        if [ -d "$SOURCE_PATH/home" ]; then
            echo "Found home directory with $(ls "$SOURCE_PATH/home" | wc -l) items"
        fi
    fi
    
    
    echo ""
    echo -e "${YELLOW}Verifying installation...${NC}"
    
    # Check chezmoi
    if command -v chezmoi >/dev/null 2>&1; then
        echo -e "${GREEN}✓ chezmoi installed${NC}"
        echo "  Version: $(chezmoi --version)"
        echo "  Location: $(which chezmoi)"
    else
        echo -e "${RED}✗ chezmoi not found${NC}"
        return 1
    fi
    
    # List managed files
    echo ""
    echo -e "${BLUE}Managed files:${NC}"
    chezmoi managed | head -20 || echo "No managed files found"
    
    # Show what was installed
    echo ""
    echo -e "${BLUE}Installed files in test home:${NC}"
    ls -la "$TEST_DIR" | grep -v "^total" | head -20
    
    # Test specific files
    echo ""
    echo -e "${BLUE}Testing specific configurations:${NC}"
    
    # Check for key files
    local files_to_check=(
        ".zshenv"
        ".config/git/config"
        ".config/starship/starship.toml"
        ".hammerspoon/init.lua"
        ".config/wezterm/wezterm.lua"
        ".config/nvim/init.lua"
    )
    
    for file in "${files_to_check[@]}"; do
        if [ -f "$TEST_DIR/$file" ]; then
            echo -e "${GREEN}✓ $file exists${NC}"
        else
            echo -e "${YELLOW}○ $file not found${NC}"
        fi
    done
    
    # Test Wezterm configuration
    echo ""
    echo -e "${BLUE}Testing Wezterm configuration:${NC}"
    if [ -f "$TEST_DIR/.config/wezterm/wezterm.lua" ]; then
        echo -e "${GREEN}✓ Wezterm config exists${NC}"
        
        # Check for required Wezterm config files
        if [ -f "$TEST_DIR/.config/wezterm/colors/dracula.toml" ]; then
            echo -e "${GREEN}✓ Wezterm color scheme exists${NC}"
        else
            echo -e "${YELLOW}○ Wezterm color scheme not found${NC}"
        fi
        
        if [ -f "$TEST_DIR/.config/wezterm/images/wallpaper.png" ]; then
            echo -e "${GREEN}✓ Wezterm wallpaper exists${NC}"
        else
            echo -e "${YELLOW}○ Wezterm wallpaper not found${NC}"
        fi
    else
        echo -e "${RED}✗ Wezterm config not found${NC}"
    fi
    
    # Test Neovim configuration
    echo ""
    echo -e "${BLUE}Testing Neovim configuration:${NC}"
    if [ -f "$TEST_DIR/.config/nvim/init.lua" ]; then
        echo -e "${GREEN}✓ Neovim init.lua exists${NC}"
        
        # Check for Neovim config structure
        local nvim_dirs=("lua" "lua/config" "lua/plugins")
        for dir in "${nvim_dirs[@]}"; do
            if [ -d "$TEST_DIR/.config/nvim/$dir" ]; then
                echo -e "${GREEN}✓ $dir directory exists${NC}"
            else
                echo -e "${YELLOW}○ $dir directory not found${NC}"
            fi
        done
        
        # Check for key Neovim config files
        local nvim_files=("lazyvim.json" "stylua.toml")
        for file in "${nvim_files[@]}"; do
            if [ -f "$TEST_DIR/.config/nvim/$file" ]; then
                echo -e "${GREEN}✓ $file exists${NC}"
            else
                echo -e "${YELLOW}○ $file not found${NC}"
            fi
        done
    else
        echo -e "${RED}✗ Neovim config not found${NC}"
    fi
    
    # Test chezmoi scripts
    echo ""
    echo -e "${BLUE}Testing chezmoi scripts:${NC}"
    if [ -d "$TEST_DIR/.local/share/chezmoi-scripts" ]; then
        echo -e "${GREEN}✓ chezmoi-scripts directory exists${NC}"
        
        # Check for WezTerm-Nvim script
        if [ -f "$TEST_DIR/.local/share/chezmoi-scripts/WezTerm-Nvim.applescript" ]; then
            echo -e "${GREEN}✓ WezTerm-Nvim.applescript exists${NC}"
        else
            echo -e "${YELLOW}○ WezTerm-Nvim.applescript not found${NC}"
        fi
        
        # Check if build script was deployed
        if [ -f "$TEST_DIR/tools/build-wezterm-nvim-app.sh" ]; then
            echo -e "${GREEN}✓ build-wezterm-nvim-app.sh deployed${NC}"
        else
            echo -e "${YELLOW}○ build-wezterm-nvim-app.sh not deployed (check if it's managed by chezmoi)${NC}"
        fi
    else
        echo -e "${YELLOW}○ chezmoi-scripts directory not found${NC}"
    fi
    
    # Interactive mode option
    echo ""
    read -p "Would you like to explore the test installation interactively? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Entering test environment shell...${NC}"
        echo "Type 'exit' to continue with cleanup"
        echo ""
        
        # Start a new shell in the test environment
        cd "$TEST_DIR"
        $SHELL || true
    fi
}

# Main execution
test_installation

echo ""
echo -e "${GREEN}=== Test completed ===${NC}"