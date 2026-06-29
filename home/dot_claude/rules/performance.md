# Performance Optimization

## Context Window Management

Context-rot doctrine and the recovery toolkit (`/rewind`, `/btw`, `/compact`,
`/clear`, subagents, checkpoints) are the canonical content of
`@rules/global/context-engineering.md`. Performance-specific notes only:

- 1M tokens available ≠ use all 1M; degradation starts ~300k–400k (autocompaction
  is a safety net, not a strategy)
- Load only relevant files (Glob/Grep, not `cat *`); sparse checkout for monorepos
- `Esc Esc` / `/rewind` recovers learning while discarding the failed attempt
  (restore conversation, code, or both)
- For bulk file operations prefer shell tools (cp/sed/mv) over reading large files into context; use targeted reads (ranges/grep) over full-file reads to avoid autocompaction

## Ultrathink + Plan Mode

For complex tasks requiring deep reasoning:
1. Use `ultrathink` for enhanced thinking
2. Enable **Plan Mode** for structured approach
3. "Rev the engine" with multiple critique rounds
4. Use split role sub-agents for diverse analysis

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix

## Monorepo Optimization

- Use `worktree.sparsePaths` for large monorepos (>20 packages)
- Use `worktree.symlinkDirectories` for node_modules/vendor
- Work in one package at a time
- Use subagents for cross-package exploration
- Nested CLAUDE.md: root = global, package = specific
