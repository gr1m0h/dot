#!/bin/bash
set -euo pipefail

# Skip in CI environment
if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "Skipping MCP setup in CI environment"
    exit 0
fi

echo "Setting up Claude MCP Servers..."

# Ensure mise is activated
if command -v mise &>/dev/null; then
    eval "$(mise activate bash)"
fi

# Check if claude command is available
if ! command -v claude &>/dev/null; then
    echo "Claude CLI not found. Please ensure mise tools are installed."
    exit 1
fi

# Check if GitHub MCP server already exists
if claude mcp list 2>/dev/null | grep -q "github"; then
    echo "GitHub Remote MCP server already configured"
else
    echo "Adding GitHub Remote MCP server..."
    # Use gh auth token to get GitHub token
    if command -v gh &>/dev/null; then
        github_token=$(gh auth token 2>/dev/null)
        if [ -z "$github_token" ]; then
            echo "Warning: GitHub CLI not authenticated, skipping GitHub MCP setup"
            echo "Run 'gh auth login' to authenticate"
        else
            claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $github_token" || {
                echo "Warning: Failed to add GitHub Remote MCP server"
            }
        fi
    else
        echo "Warning: GitHub CLI not found, skipping GitHub MCP setup"
        echo "Install gh CLI and run 'gh auth login' to enable GitHub MCP server"
    fi
fi

echo "Checking MCP server health..."
if claude mcp list 2>/dev/null; then
    echo "MCP servers configured successfully!"
else
    echo "Warning: Unable to list MCP servers, but setup may have completed"
    echo "You can check MCP status later with 'claude mcp list'"
fi