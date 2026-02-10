---
name: dashboard
description: Analyze telemetry data and display a dashboard
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Telemetry Dashboard

Analyzes and visualizes collected telemetry data.

## Dynamic Context

- Telemetry files: !`ls -la .claude/telemetry/ 2>/dev/null || echo "No telemetry directory - run telemetry-collector hook to initialize"`
- Latest traces: !`tail -5 .claude/telemetry/traces.jsonl 2>/dev/null || echo "No traces yet"`
- Metrics snapshot: !`cat .claude/telemetry/metrics.json 2>/dev/null || echo "No metrics yet"`

## Data Sources

- `.claude/telemetry/traces.jsonl`: OpenTelemetry-compatible trace logs (written by telemetry-collector hook)
- `.claude/telemetry/metrics.json`: Aggregated metrics (tool call counts, error rates, durations)

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

## Output Format

```
╔══════════════════════════════════════════════════════════╗
║                 Telemetry Dashboard                       ║
╠══════════════════════════════════════════════════════════╣
║ Total Calls: XXX  |  Success Rate: XX.X%  |  Session: Xm  ║
╠══════════════════════════════════════════════════════════╣
║ Top Tools:                                                ║
║   1. Edit       - XXX calls (XX.X% errors)               ║
║   2. Read       - XXX calls (XX.X% errors)               ║
║   3. Bash       - XXX calls (XX.X% errors)               ║
╠══════════════════════════════════════════════════════════╣
║ Recent Errors:                                            ║
║   - [TIME] Tool: Error message                           ║
╚══════════════════════════════════════════════════════════╝
```
