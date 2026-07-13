---
name: dashboard
description: Analyze telemetry and cost data, and display a session performance dashboard. Use when user says "dashboard", "show stats", "session metrics", "telemetry report", "cost report", or "token usage". Visualizes tool usage, token consumption, cost estimates, and session efficiency. (Absorbed the former cost-report skill.)
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[period: 'session', 'today', 'week', or YYYY-MM-DD]"
---

# Telemetry & Cost Dashboard

Analyzes and visualizes collected telemetry and cost data for $ARGUMENTS (default: `session`).

## Dynamic Context

- Telemetry files: !`ls -la .claude/telemetry/ 2>/dev/null || echo "No telemetry directory - run telemetry-collector hook to initialize"`
- Latest traces: !`tail -5 .claude/telemetry/traces.jsonl 2>/dev/null || echo "No traces yet"`
- Metrics snapshot: !`cat .claude/telemetry/metrics.json 2>/dev/null || echo "No metrics yet"`
- Cost stats: !`cat .claude/memory/local/cost-stats.json 2>/dev/null | head -10 || echo "No cost stats yet"`

## Data Sources

- `.claude/telemetry/traces.jsonl`: OpenTelemetry-compatible trace logs (written by telemetry-collector hook)
- `.claude/telemetry/metrics.json`: Aggregated metrics (tool call counts, error rates, durations)
- `.claude/memory/local/cost-stats.json`: Session cost aggregates (written by cost-monitor hook)
- `.claude/memory/local/cost-detail.jsonl`: Per-operation cost details
- `.claude/memory/local/session-metrics.jsonl`: Session metrics and task data

## Report Periods

| Period | Description |
|--------|-------------|
| `session` | Current session only (default) |
| `today` | All sessions from today |
| `week` | Last 7 days |
| `YYYY-MM-DD` | Specific date |

## Analysis Items

### 1. Tool Usage

| Tool | Calls | Errors | Error Rate | Avg Duration |
| ---- | ----- | ------ | ---------- | ------------ |
| ...  | ...   | ...    | ...        | ...          |

### 2. Error Analysis

Most frequent error patterns and causes

### 3. Performance

- Most time-consuming tools
- Bottleneck identification

### 4. Session Statistics

- Total tool call count
- Success rate
- Session duration

### 5. Cost & Efficiency

- Total estimated cost units / token usage (input/output)
- Cost per task completed, average cost per tool call
- High-cost operations list
- Optimization recommendations (e.g. haiku for simple tasks, line-range reads, cached searches)
- Daily cost trend (multi-day periods only)

## Output Format

```
╔══════════════════════════════════════════════════════════╗
║              Telemetry & Cost Dashboard                   ║
╠══════════════════════════════════════════════════════════╣
║ Total Calls: XXX  |  Success Rate: XX.X%  |  Session: Xm  ║
║ Cost Units: XX.X  |  Est. Tokens: XX,XXX  |  Tasks: XX    ║
╠══════════════════════════════════════════════════════════╣
║ Top Tools:                                                ║
║   1. Edit       - XXX calls (XX.X% errors)               ║
║   2. Read       - XXX calls (XX.X% errors)               ║
║   3. Bash       - XXX calls (XX.X% errors)               ║
╠══════════════════════════════════════════════════════════╣
║ Recent Errors:                                            ║
║   - [TIME] Tool: Error message                           ║
╠══════════════════════════════════════════════════════════╣
║ High-Cost Operations / Recommendations:                   ║
║   - [TIME] Tool: X.XX units — suggestion                 ║
╚══════════════════════════════════════════════════════════╝
```

## Interpreting Cost Results

Cost units are relative measures for comparison: 1 unit ≈ 1 simple Read; 5 units ≈ 1 Task (subagent); 10+ units ≈ large file operations.

- **Healthy**: Read/Edit ratio > 2:1 (planning before editing) · Task tool for exploration (offloads context) · decreasing cost per task over session
- **Warning**: repeated similar Grep patterns · many Reads without Edit · high Task counts without completions

## Related Skills

- `/manage-context` - Context window optimization
- `/harness-audit` - Full configuration audit (incl. token efficiency of CLAUDE.md/rules)
