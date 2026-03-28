# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

## Current Hooks (in ~/.claude/settings.json)

### PreToolUse
- **tmux reminder**: Suggests tmux for long-running commands (npm, pnpm, yarn, cargo, bundle, composer, etc.)
- **git push review**: Opens Zed for review before push
- **doc blocker**: Blocks creation of unnecessary .md/.txt files

### PostToolUse
- **PR creation**: Logs PR URL and GitHub Actions status
- **Auto-format/lint**: Language-aware formatting after edit
  - JS/TS: Biome or ESLint + Prettier
  - Python: Ruff or Black + Mypy
  - Ruby: RuboCop
  - PHP: PHP-CS-Fixer + PHPStan
  - Go: gofmt + goimports
  - Rust: rustfmt
- **Type check**: Runs language-specific type checker (tsc, mypy, PHPStan)
- **console.log warning**: Warns about debug output in edited files

### Stop
- **console.log audit**: Checks all modified files for console.log before session ends

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in `~/.claude.json` instead

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
