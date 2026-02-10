# Cost Optimization Rules

Efficient resource usage for Claude Code sessions.

## Model Selection

| Task Type | Recommended Model | Rationale |
|-----------|-------------------|-----------|
| Typo fixes, simple renames | haiku | Minimal complexity |
| Code explanation, Q&A | haiku/sonnet | Reading-focused |
| Feature implementation | sonnet | Balance of capability/cost |
| Architecture design | opus | Complex reasoning needed |
| Security audits | opus | Thoroughness required |

## Token Conservation

### DO
- Use `/clear` after completing major tasks
- Prefer `Glob`/`Grep` over reading entire files
- Request specific line ranges when reading large files
- Use `Task` tool for exploratory searches (offloads context)
- Batch related questions in single prompts

### DON'T
- Read entire codebases "just in case"
- Keep stale context across unrelated tasks
- Request verbose explanations for simple operations
- Run redundant searches for the same information

## Tool Usage Efficiency

### Parallel Execution
- Run independent operations in parallel
- Combine related file reads in single request
- Batch git operations where possible

### Search Strategy
- Start with `Glob` for known file patterns
- Use `Grep` with specific patterns, not broad searches
- Use `Task(Explore)` for open-ended exploration

## Session Management

- **Short sessions** (< 30 min): Direct work, minimal exploration
- **Long sessions** (> 1 hr): Use `/clear` between major phases
- **Complex projects**: Plan first, then execute in focused bursts

## Cost Tracking

- Monitor `.claude/memory/local/cost-stats.json` for session costs
- Set `COST_BUDGET` env var for automatic warnings
- Review `cost-detail.jsonl` for optimization opportunities

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| "Read all files in src/" | "Find files matching X pattern" |
| Repeated similar searches | Cache results mentally, reference once |
| Exploratory reads without purpose | State goal, let agent optimize path |
| Large file writes for small changes | Use Edit tool for targeted changes |
