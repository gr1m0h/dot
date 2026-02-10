---
name: cost-report
description: Generate a report on token usage, tool calls, and session cost estimates. Use for monitoring and optimization.
user-invocable: true
allowed-tools: Read, Bash, Glob
context: fork
model: haiku
argument-hint: "[period: 'session', 'today', 'week', or specific date]"
metadata:
  version: "1.0.0"
  updated: "2026-02"
---

# Cost Report

Generate a cost and usage report for $ARGUMENTS.

## Data Sources

Reports are generated from:
- `.claude/memory/local/cost-stats.json` - Session aggregates
- `.claude/memory/local/cost-detail.jsonl` - Per-operation details
- `.claude/memory/local/edit-audit.jsonl` - Edit history
- `.claude/memory/local/session-metrics.jsonl` - Session metrics and task data

## Report Periods

| Period | Description |
|--------|-------------|
| `session` | Current session only |
| `today` | All sessions from today |
| `week` | Last 7 days |
| `YYYY-MM-DD` | Specific date |

## Metrics

### Session Metrics
- Total estimated cost units
- Estimated token usage (input/output)
- Session duration
- Tool call counts by type

### Efficiency Metrics
- Cost per task completed
- Average cost per tool call
- High-cost operations list
- Optimization opportunities

### Trend Analysis (multi-day)
- Daily cost trends
- Tool usage patterns
- Peak usage hours

## Output Format

```markdown
## Claude Code Cost Report

**Period:** [session/today/week/date]
**Generated:** [timestamp]

### Summary
| Metric | Value |
|--------|-------|
| Total Cost Units | X.XX |
| Estimated Tokens | X,XXX |
| Tool Calls | XXX |
| Tasks Completed | XX |

### Tool Usage Breakdown
| Tool | Calls | Est. Tokens | Cost % |
|------|-------|-------------|--------|
| Read | XX | X,XXX | XX% |
| Edit | XX | X,XXX | XX% |
| Bash | XX | X,XXX | XX% |
| Task | XX | X,XXX | XX% |
| ... | ... | ... | ... |

### High-Cost Operations
1. [timestamp] Tool: X, Cost: X.XX
2. ...

### Optimization Recommendations
- [ ] Consider using haiku for [task type]
- [ ] Large file read detected - use line ranges
- [ ] Redundant searches detected - cache results

### Cost Trend (if multi-day)
[ASCII chart or summary]
```

## Interpreting Results

### Cost Units Explained
Cost units are relative measures for comparison:
- 1 unit ~ 1 simple Read operation
- 5 units ~ 1 Task (subagent) operation
- 10+ units ~ Large file operations

### Healthy Patterns
- Read/Edit ratio > 2:1 (planning before editing)
- Task tool for exploration (offloads context)
- Decreasing cost per task over session

### Warning Signs
- Repeated similar Grep patterns
- Many Read operations without Edit
- High Task counts without completions

## Related Skills

- `/manage-context` - Context window optimization
- `/dashboard` - Full telemetry dashboard

---

*Version 1.0.0 - 2026-02*
