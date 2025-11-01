# Dotfiles Testing Guide for macOS

This directory contains testing scripts to verify the dotfiles installation process on macOS.

## Prerequisites

- macOS
- Git repository cloned locally

## Testing

### Local Installation Test

This script tests the installation in a temporary directory without affecting your actual home directory:

```bash
./test/test-local.sh
```

#### What it does:

1. Creates a temporary directory to simulate a fresh home directory
2. Runs the installation script in this isolated environment
3. Verifies that chezmoi is properly installed
4. Checks that dotfiles are correctly deployed
5. Optionally allows interactive exploration of the test environment

#### Features:

- **Safe**: Doesn't modify your actual home directory
- **Complete**: Tests the full installation process
- **Interactive**: Option to explore the test environment manually
- **Cleanup**: Automatically cleans up after testing (with option to preserve)

## CI/CD Integration

The installation is automatically tested via GitHub Actions on:
- Pull requests
- Pushes to main branch
- Scheduled weekly runs

See `.github/workflows/test.yml` for the CI configuration.

## What Gets Tested

The test scripts verify:

1. **Core dotfiles installation**:
   - `.zshenv` - Zsh environment configuration
   - `.config/git/config` - Git configuration
   - `.config/starship/starship.toml` - Starship prompt
   - `.hammerspoon/init.lua` - Hammerspoon automation

2. **Wezterm configuration**:
   - `.config/wezterm/wezterm.lua` - Main configuration
   - `.config/wezterm/colors/dracula.toml` - Color scheme
   - `.config/wezterm/images/wallpaper.png` - Background image

3. **Neovim configuration**:
   - `.config/nvim/init.lua` - Main configuration
   - `.config/nvim/lua/` - Lua configuration modules
   - `.config/nvim/lazy-lock.json` - Plugin lock file
   - `.config/nvim/lazyvim.json` - LazyVim configuration
   - `.config/nvim/stylua.toml` - Lua formatter configuration

4. **Tool scripts**:
   - `.local/share/chezmoi-scripts/WezTerm-Nvim.applescript` - macOS integration script

## Manual Verification Steps

After running the test script, you can verify:

1. **chezmoi installation**:
   ```bash
   chezmoi --version
   ```

2. **Managed files**:
   ```bash
   chezmoi managed
   ```

3. **Applied configuration**:
   ```bash
   ls -la ~
   ```

4. **Tool configurations**:
   ```bash
   # Check Wezterm config
   ls -la ~/.config/wezterm/
   
   # Check Neovim config
   ls -la ~/.config/nvim/
   ```

## Troubleshooting

### Permission Issues
```bash
chmod +x test/test-local.sh
```

### Test Failures
Check the output for specific error messages. Common issues:
- Network connectivity (for downloading chezmoi)
- File permissions
- Missing dependencies