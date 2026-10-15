# Incident Analysis Patterns

## Cascade Failure Analysis

Cascade failures involve a chain reaction where one failure triggers subsequent failures. Document each stage:

```
[Trigger Event]
  → [Primary Failure] (e.g., resource saturation)
  → [Secondary Failure] (e.g., timeout cascade)
  → [Amplification] (e.g., client retry storm)
  → [Recovery Blocker] (e.g., connection storm after failover)
  → [Resolution]
```

### Common Cascade Patterns

| Pattern | Trigger | Amplification | Recovery Risk |
|---|---|---|---|
| CPU Saturation | Traffic spike on undersized instance | Client retries, queue buildup | Cold start on failover |
| Connection Pool Exhaustion | Slow queries hold connections | New requests blocked, timeout cascade | Pool refill storm |
| Prepared Statement Overflow | Failover + reconnection storm | Every connection recreates all stmts | max_prepared_stmt_count breach |
| Memory Pressure | Large result sets / sorting | OOM killer triggers, restarts | Thundering herd on restart |
| Lock Contention | Long-running transaction | Cascading lock waits | Deadlock detection overhead |

## Multi-Day Comparison Technique

To identify why a specific day had an incident when similar conditions existed on other days, compare:

1. **Absolute metrics**: CPU, connections, request count (often similar)
2. **Derived metrics**: queries-per-request ratio (often different)
3. **State metrics**: connection pool warmth, credit balance
4. **Directional metrics**: ascending vs descending traffic at peak

### queries-per-request Calculation

```
q/req = (Queries/sec from Datadog × Period_seconds) / ALB_RequestCount
```

A sudden change in q/req indicates endpoint mix shift — heavier queries being called more frequently.

## 5 Whys Template

```
1. What happened? → [Symptom: users saw 504 errors]
2. Why? → [CPU saturated at 97%]
3. Why? → [Burstable instance with 0 CPU credits]
4. Why? → [Instance was undersized for production workload]
5. Why? → [No capacity planning review for production DB sizing]
```

## Contributing Factor Categories

### Infrastructure
- Instance sizing (burstable vs provisioned)
- Resource limits (CPU credits, IOPS, connections)
- Auto-scaling configuration
- Network capacity

### Application
- Query efficiency (N+1, missing indexes, excessive JOINs)
- Connection pool management (min/max, idle timeout)
- Prepared statement lifecycle
- Transaction management (timeout, isolation level)
- ORM-generated query patterns

### Client
- Retry behavior (exponential backoff? circuit breaker?)
- Cache invalidation patterns (staleTime, refetch triggers)
- Request amplification (app lifecycle events)
- Batch vs individual requests

### Monitoring
- Missing metrics (things that can't be monitored via CloudWatch/Datadog)
- Alert thresholds (too high, too late)
- Log retention (auto-deleted before investigation)
- Dashboard coverage

### Process
- Incident detection time
- Runbook availability
- Escalation path
- Recovery procedures

## Monitoring Gap Identification

Common gaps discovered during incidents:

| Gap | What's Missing | Why It Matters | Workaround |
|---|---|---|---|
| Prepared_stmt_count | Not in CloudWatch/Datadog | Error 1461 is undetectable | Custom metric via SHOW GLOBAL STATUS |
| Connection pool state | App-internal metric | Cold pool → connection storm | APM instrumentation |
| Query mix ratio | Derived metric | Detects endpoint shift | Calculate from Queries/sec ÷ RequestCount |
| Slow query log (small instances) | Auto-deleted on db.t* | No forensic data | Upgrade instance or external log shipping |
| Client retry rate | App-side metric | Invisible amplification | Client-side instrumentation |

## Report Quality Checklist

- [ ] Every claim has a metric or log evidence reference
- [ ] Timeline has minute-level granularity during incident window
- [ ] Day-over-day comparison explains why THIS day was different
- [ ] Cascade chain is documented stage by stage
- [ ] Remediation items are prioritized (immediate / short / medium term)
- [ ] Monitoring gaps are documented with proposed solutions
- [ ] Verification script is generated for reproducibility
- [ ] Raw command outputs are preserved in appendix
