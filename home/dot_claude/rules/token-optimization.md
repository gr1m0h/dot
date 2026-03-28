# Token Optimization

## Model Routing

| Task | Model | Rationale |
|------|-------|-----------|
| File exploration, lookups | haiku | 80% cost savings |
| Typo fixes, simple renames | haiku | Minimal complexity |
| Code explanation, Q&A | haiku/sonnet | Reading-focused |
| Feature implementation | sonnet | Balance of capability/cost |
| Code review, tests | sonnet | Standard complexity |
| Architecture design | opus | Complex reasoning |
| Security audits | opus | Thoroughness required |
| Multi-file refactoring | opus | Cross-file reasoning |

## Context Management

### Strategic Compaction
- `/compact` at task milestones (not mid-task)
- `/clear` between unrelated projects
- Never compact during multi-file refactoring or active debugging
- Auto-compact at 50% (early consolidation > degraded quality)

### Subagent Delegation
- Offload exploration to subagents (keeps main context clean)
- Use Task(Explore) for open-ended codebase searches
- Subagent results are summarized, not dumped into context
- Max subagent depth: 3 (prevent recursion)

### MCP Server Budget
- Fewer than 10 enabled servers per project
- Prefer CLI tools (gh, aws) over MCP equivalents when possible
- Disable unused servers to reduce context overhead

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Reading entire files "just in case" | Grep/Glob for specific patterns |
| Keeping stale context | `/clear` between tasks |
| Verbose explanations for simple ops | Be concise |
| Redundant searches | Cache results, reference once |
| Agent Teams for sequential tasks | Use subagents instead |
