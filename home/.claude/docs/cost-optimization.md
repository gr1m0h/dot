# Cost Optimization Rules

Efficient resource usage for Claude Code sessions.

## Model Selection

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| File exploration, lookups | haiku | Cheapest; strong for short-context retrieval |
| Typo fixes, simple renames | haiku | Minimal complexity |
| Code explanation, Q&A | haiku/sonnet | Reading-focused |
| Feature implementation | sonnet | Balance of capability/cost |
| Code review, tests | sonnet | Standard complexity |
| Architecture design | opus | Complex reasoning needed |
| Security audits | opus | Thoroughness required |
| Multi-file refactoring | opus | Cross-file reasoning |
| Subagent workers | haiku | `CLAUDE_CODE_SUBAGENT_MODEL=haiku` |

Haiku 4.5 is credible for short-context coding tasks — not just fallback.
Re-evaluate the tier table on each model upgrade; capability/price ratios shift.

## Token Conservation

### DO
- Use `/clear` after completing major tasks
- Prefer `Glob`/`Grep` over reading entire files
- Request specific line ranges when reading large files
- Use `Task(Explore)` for exploratory searches (offloads context)
- Batch related questions in single prompts
- `/compact` at task milestones with targeted summary hints
- `/rewind` to recover from failed attempts without context loss
- `/btw` for side questions without polluting conversation history

### DON'T
- Read entire codebases "just in case"
- Keep stale context across unrelated tasks
- Request verbose explanations for simple operations
- Run redundant searches for the same information
- Compact during multi-file refactoring or active debugging
- Micro-manage thinking budget on Fable 5+ — `effortLevel` is the control (MAX_THINKING_TOKENS removed 2026-07 as legacy)

## Context Window Management

Context-rot, recovery tooling (`/rewind`, `/btw`, `/compact`, `/clear`), and
subagent delegation are covered in `~/.claude/docs/performance.md` and the
`/manage-context` skill — not repeated here to keep always-loaded budget lean.

### MCP Server Budget
- Fewer than 10 enabled servers per project
- Prefer CLI tools (gh, aws) over MCP equivalents when possible
- Disable unused servers to reduce context overhead

## Prompt Caching Awareness

- Verify current cache TTL and pricing against official docs before relying on it
  (TTL/pricing have changed; do not hardcode assumptions)
- Place static content first, dynamic last (prefix matching)
- Batch operations stack discounts with cache hits
- Monitor billing for cache-cost anomalies; reconcile against expected usage

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
- **After 2+ failed corrections**: `/clear` + better prompt (not more context)

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
| Fighting the thinking budget manually | Tune `effortLevel` (low/medium/high/xhigh) instead |
| Bloated CLAUDE.md (>200 lines) | Progressive disclosure via skills |
