# Performance Optimization

## 1M Context Window Management

### Context Rot
1M tokens available ≠ use all 1M tokens.
- Performance degrades at ~300k-400k tokens (varies by task)
- Older content actively distracts model from current task
- Autocompaction is safety net, not strategy

### Recovery Toolkit

| Tool | When | Impact |
|------|------|--------|
| `/rewind` | Failed attempt, wrong direction | Jumps back, preserves learnings |
| `/btw` | Quick side question | Overlay response, no history |
| `/compact <hints>` | Mid-task milestone | Distills session, frees context |
| `/clear` | Between unrelated tasks | Full reset |
| Subagent | Exploratory investigation | Fresh context, results only |
| Checkpoints | Complex multi-phase work | Persist across sessions |

### Session Rewind
- `Esc + Esc` or `/rewind` opens rewind menu
- Options: restore conversation only, code only, or both
- Summarize-from: condenses forward, keeps history
- Not simple undo — recovers learning while discarding failure

### Context Discipline
Even with 1M:
- Load only relevant files (Glob/Grep, not cat *)
- Use sparse checkout for monorepos
- Lean CLAUDE.md (<200 lines, <500 tokens ideal)
- Skills-first loading (on-demand, not always)

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
