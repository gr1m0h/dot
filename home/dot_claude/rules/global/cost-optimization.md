# Cost Optimization Rules

Efficient resource usage for Claude Code sessions.

## Model Selection

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| File exploration, lookups | haiku | 80% cost savings, 73.3% capability |
| Typo fixes, simple renames | haiku | Minimal complexity |
| Code explanation, Q&A | haiku/sonnet | Reading-focused |
| Feature implementation | sonnet | Balance of capability/cost |
| Code review, tests | sonnet | Standard complexity |
| Architecture design | opus | Complex reasoning needed |
| Security audits | opus | Thoroughness required |
| Multi-file refactoring | opus | Cross-file reasoning |
| Subagent workers | haiku | `CLAUDE_CODE_SUBAGENT_MODEL=haiku` |

Haiku 4.5 is now credible for short-context coding tasks — not just fallback.

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
- Let extended thinking run uncapped (use MAX_THINKING_TOKENS=31999)

## 1M Context Window Management

### Context Rot
Performance degrades at ~300k-400k tokens despite 1M available.
Older irrelevant content actively distracts from current task.

### Strategies (ordered by impact)
1. **Subagent delegation** — Fresh context per child, only results return
2. **`/rewind`** — Jump to previous state, preserve learnings, drop failures
3. **`/compact <hints>`** — Model distills session into dense brief
4. **`/btw`** — Side questions in dismissible overlay, never enters history
5. **`/clear`** — Full reset between unrelated tasks
6. **Checkpoints** — Persist across sessions, support summarize-from

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

## Prompt Caching Awareness

- TTL is 5 minutes (changed Jan 2026, from 60 min)
- Place static content first, dynamic last (prefix matching)
- Batch operations stack discounts (batch 50% + cache hit)
- Monitor for cache anomalies (March 2026 incident: 10-20x inflation)

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
| Uncapped extended thinking | Set MAX_THINKING_TOKENS=31999 |
| Bloated CLAUDE.md (>200 lines) | Progressive disclosure via skills |
