# Cost Optimization Rules

Efficient resource usage for Claude Code sessions.

## Model Selection

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| File exploration, lookups | haiku | 80% cost savings |
| Typo fixes, simple renames | haiku | Minimal complexity |
| Code explanation, Q&A | haiku/sonnet | Reading-focused |
| Feature implementation | sonnet | Balance of capability/cost |
| Code review, tests | sonnet | Standard complexity |
| Architecture design | opus | Complex reasoning needed |
| Security audits | opus | Thoroughness required |
| Multi-file refactoring | opus | Cross-file reasoning |
| Subagent workers | haiku | `CLAUDE_CODE_SUBAGENT_MODEL=haiku` |

## Token Conservation

### DO
- Use `/clear` after completing major tasks
- Prefer `Glob`/`Grep` over reading entire files
- Request specific line ranges when reading large files
- Use `Task(Explore)` for exploratory searches (offloads context)
- Batch related questions in single prompts
- `/compact` at task milestones (not mid-task)

### DON'T
- Read entire codebases "just in case"
- Keep stale context across unrelated tasks
- Request verbose explanations for simple operations
- Run redundant searches for the same information
- Compact during multi-file refactoring or active debugging

## Context Management

### Strategic Compaction
- Auto-compact at 50% (early consolidation > degraded quality)
- Manual `/compact` with targeted summary prompt is preferred
- `/clear` between unrelated projects

### Subagent Delegation
- Offload exploration to subagents (keeps main context clean)
- Subagent results are summarized, not dumped into context
- Max subagent depth: 3 (prevent recursion)

### MCP Server Budget
- Fewer than 10 enabled servers per project
- Prefer CLI tools (gh, aws) over MCP equivalents when possible
- Disable unused servers to reduce context overhead

## Tool Usage Efficiency

### Search Strategy
- Start with `Glob` for known file patterns
- Use `Grep` with specific patterns, not broad searches
- Use `Task(Explore)` for open-ended exploration

### Parallel Execution
- Run independent operations in parallel
- Combine related file reads in single request
- Batch git operations where possible

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
| Agent Teams for sequential tasks | Use subagents instead |
| Reading entire files "just in case" | Grep/Glob for specific patterns |
