# Datadog (pup) Commands Reference

## Metrics Queries

### RDS Metrics
```sh
# CPU Credit Balance (burstable instances only)
pup metrics query \
  --query 'avg:aws.rds.cpucredit_balance{dbinstanceidentifier:<INSTANCE>}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# CPU Surplus Credit Balance
pup metrics query \
  --query 'avg:aws.rds.cpusurplus_credit_balance{dbinstanceidentifier:<INSTANCE>}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# CPU Credit Usage
pup metrics query \
  --query 'avg:aws.rds.cpucredit_usage{dbinstanceidentifier:<INSTANCE>}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Queries per second
pup metrics query \
  --query 'avg:aws.rds.queries{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Database Connections
pup metrics query \
  --query 'avg:aws.rds.database_connections{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Active Transactions
pup metrics query \
  --query 'avg:aws.rds.active_transactions{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Write Latency
pup metrics query \
  --query 'avg:aws.rds.write_latency{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Freeable Memory
pup metrics query \
  --query 'avg:aws.rds.freeable_memory{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Engine Uptime (detects restarts/failovers)
pup metrics query \
  --query 'avg:aws.rds.engine_uptime{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))
```

### Aurora-Specific Metrics
```sh
# Memory Health State
pup metrics query \
  --query 'avg:aws.rds.aurora_memory_health_state{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Declined SQL (OOM)
pup metrics query \
  --query 'avg:aws.rds.aurora_memory_num_declined_sql_total{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# Killed Connections (OOM)
pup metrics query \
  --query 'avg:aws.rds.aurora_memory_num_kill_conn_total{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# DML Rejected (Writer Full)
pup metrics query \
  --query 'avg:aws.rds.aurora_dmlrejected_writer_full{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

# OOM Recovery Triggered
pup metrics query \
  --query 'avg:aws.rds.aurora_num_oom_recovery_triggered{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))
```

### Metrics Discovery
```sh
# List available metrics matching a pattern
pup metrics list --filter "<METRIC_PREFIX>.*" --from 7d

# Search for specific metrics
pup metrics search --query "metrics:<SEARCH_TERM>"
```

## Log Queries

### Search
```sh
# Error logs by service
pup logs search \
  --query 'status:error service:<SERVICE>' \
  --from <EPOCH_START> --to <EPOCH_END> --limit <N>

# Specific error pattern
pup logs search \
  --query 'service:<SERVICE> "<ERROR_MESSAGE>"' \
  --from '<ISO_START>' --to '<ISO_END>' --limit <N>

# Exclude noise
pup logs search \
  --query 'status:error -service:realtime -"nginx"' \
  --from <EPOCH_START> --to <EPOCH_END> --limit <N>
```

### Aggregation
```sh
# Count by service
pup logs aggregate \
  --query 'status:error' \
  --from <EPOCH_START> --to <EPOCH_END> \
  --compute 'count' --group-by 'service' --limit 20

# Count by error kind
pup logs aggregate \
  --query 'status:error' \
  --from <EPOCH_START> --to <EPOCH_END> \
  --compute 'count' --group-by '@error.kind' --limit 20

# Simple count for a time window
pup logs aggregate \
  --query '<QUERY>' \
  --from <EPOCH_START> --to <EPOCH_END> \
  --compute 'count'
```

### Common Error Patterns to Search

| Pattern | Query |
|---|---|
| Transaction timeout | `"Transaction already closed" OR "Unable to start a transaction"` |
| Prepared stmt overflow | `"max_prepared_stmt_count"` |
| Connection errors | `"ECONNREFUSED" OR "ECONNRESET" OR "ETIMEDOUT"` |
| Lock/deadlock | `"deadlock" OR "lock wait timeout"` |
| OOM | `"out of memory" OR "OOM"` |
| 504 gateway timeout | `"504" OR "gateway timeout"` |

## Dashboards and Events
```sh
# List dashboards
pup dashboards list

# List events in time range
pup events list \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))
```

## Time Format Notes

- `pup metrics query` uses **millisecond epoch** timestamps
- `pup logs search` accepts both **epoch seconds** and **ISO 8601** strings
- `pup logs aggregate` uses **epoch seconds**
- Always verify timezone alignment (JST = UTC+9)

### Epoch Conversion Helpers
```sh
# JST datetime to epoch seconds
date -j -f "%Y-%m-%d %H:%M:%S" "2026-03-26 17:00:00" "+%s"
# Note: macOS `date` treats input as local time

# Epoch to JST
date -r 1774513200 "+%Y-%m-%d %H:%M:%S %Z"
```
