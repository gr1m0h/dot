---
name: telemetry-dashboard
description: Analyze telemetry data and display a dashboard
user-invocable: true
allowed-tools: Read, Grep
---

# Telemetry Dashboard

Analyzes and visualizes collected telemetry data.

## Data Sources

- `.claude/telemetry/traces.jsonl`: Trace logs
- `.claude/telemetry/metrics.json`: Aggregated metrics

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
