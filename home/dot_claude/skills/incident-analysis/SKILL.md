---
name: incident-analysis
description: Cross-cutting incident investigation using AWS CLI, Datadog (pup), and local repository analysis. Use when user says "incident analysis", "investigate outage", "root cause analysis", "postmortem", or "analyze incident". Systematically collects infrastructure metrics, application logs, and codebase evidence to produce a comprehensive incident report with timeline, root cause, and remediation recommendations.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
context: fork
argument-hint: "[incident-date or description, e.g. '2026-03-26 DB CPU saturation' or GitHub issue URL]"
metadata:
  version: "1.0.0"
  updated: "2026-04"
---

# Incident Analysis

Perform a comprehensive cross-cutting incident investigation for $ARGUMENTS.

## Prerequisites

Verify the following tools are available before proceeding:

!`which aws && aws --version 2>&1 | head -1 || echo "AWS CLI: NOT FOUND"`
!`which pup && pup --version 2>&1 | head -1 || echo "pup (Datadog CLI): NOT FOUND"`
!`which gh && gh --version 2>&1 | head -1 || echo "gh (GitHub CLI): NOT FOUND"`

## Input Gathering

Before starting, collect the following from the user (or extract from the provided issue/description):

1. **Incident datetime range** (start ~ end, timezone)
2. **Affected services** (service names, instance identifiers)
3. **Symptoms** (errors observed, user-reported issues)
4. **AWS profile and region** to use
5. **Known actions taken** (failovers, restarts, rollbacks)

If a GitHub issue URL is provided, fetch it first:
```
gh issue view <number> --repo <owner/repo> --json title,body,labels,state
gh api repos/<owner/repo>/issues/<number>/comments --jq '.[].body'
```

## Investigation Strategy

Follow this layered approach — each layer narrows the root cause:

### Phase 1: Infrastructure Metrics (AWS CloudWatch)

Collect hard metrics to establish the infrastructure-level timeline.

#### 1.1 Compute Resources

**RDS/Aurora Instance Specs:**
```sh
aws rds describe-db-instances \
  --db-instance-identifier <INSTANCE_ID> \
  --region <REGION> --profile <PROFILE> \
  --query 'DBInstances[0].{Class:DBInstanceClass,PI:PerformanceInsightsEnabled,Storage:StorageType,Eng:Engine,Ver:EngineVersion}'
```

**CPU Utilization (1-minute granularity for incident window):**
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[{"Id":"cpu","MetricStat":{"Metric":{"Namespace":"AWS/RDS","MetricName":"CPUUtilization","Dimensions":[{"Name":"DBInstanceIdentifier","Value":"<INSTANCE_ID>"}]},"Period":60,"Stat":"Average"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

**CPU Credit Balance (for burstable instances db.t*):**
```sh
# Only for db.t* instance classes
pup metrics query \
  --query 'avg:aws.rds.cpucredit_balance{dbinstanceidentifier:<INSTANCE_ID>}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

pup metrics query \
  --query 'avg:aws.rds.cpusurplus_credit_balance{dbinstanceidentifier:<INSTANCE_ID>}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

pup metrics query \
  --query 'avg:aws.rds.cpucredit_usage{dbinstanceidentifier:<INSTANCE_ID>}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))
```

**Database Connections:**
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[{"Id":"conn","MetricStat":{"Metric":{"Namespace":"AWS/RDS","MetricName":"DatabaseConnections","Dimensions":[{"Name":"DBInstanceIdentifier","Value":"<INSTANCE_ID>"}]},"Period":300,"Stat":"Average"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

#### 1.2 Load Balancer Metrics

**ALB Response Time (Average + p95):**
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id":"rtAvg","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"TargetResponseTime","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"Average"}},
    {"Id":"rtP95","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"TargetResponseTime","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"p95"}}
  ]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

**ALB Request Count + 5XX Errors:**
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id":"req","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"RequestCount","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"Sum"}},
    {"Id":"e5xx","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"HTTPCode_ELB_5XX_Count","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"Sum"}}
  ]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

#### 1.3 ECS Metrics

**Task Count + Resource Utilization:**
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id":"ecs","MetricStat":{"Metric":{"Namespace":"AWS/ECS","MetricName":"RunningTaskCount","Dimensions":[{"Name":"ClusterName","Value":"<CLUSTER>"},{"Name":"ServiceName","Value":"<SERVICE>"}]},"Period":300,"Stat":"Average"}},
    {"Id":"cpuAvg","MetricStat":{"Metric":{"Namespace":"AWS/ECS","MetricName":"CPUUtilization","Dimensions":[{"Name":"ClusterName","Value":"<CLUSTER>"},{"Name":"ServiceName","Value":"<SERVICE>"}]},"Period":300,"Stat":"Average"}},
    {"Id":"memAvg","MetricStat":{"Metric":{"Namespace":"AWS/ECS","MetricName":"MemoryUtilization","Dimensions":[{"Name":"ClusterName","Value":"<CLUSTER>"},{"Name":"ServiceName","Value":"<SERVICE>"}]},"Period":300,"Stat":"Average"}}
  ]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

#### 1.4 RDS Events

**Cluster and Instance Events (failovers, restarts, modifications):**
```sh
aws rds describe-events --source-type db-cluster \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>

aws rds describe-events --source-type db-instance \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

#### 1.5 Performance Insights

**DB Load (1-minute granularity):**
```sh
# First get DbiResourceId
aws rds describe-db-instances \
  --db-instance-identifier <INSTANCE_ID> \
  --region <REGION> --profile <PROFILE> \
  --query 'DBInstances[0].DbiResourceId' --output text

aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <DBI_RESOURCE_ID> \
  --metric-queries '[{"Metric": "db.load.avg"}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --period-in-seconds 60 \
  --region <REGION> --profile <PROFILE>
```

**Wait Events (5-minute granularity):**
```sh
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <DBI_RESOURCE_ID> \
  --metric-queries '[{"Metric": "db.load.avg", "GroupBy": {"Group": "db.wait_event"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --period-in-seconds 300 \
  --region <REGION> --profile <PROFILE>
```

**Top SQL:**
```sh
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <DBI_RESOURCE_ID> \
  --metric-queries '[{"Metric": "db.load.avg", "GroupBy": {"Group": "db.sql.statement"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --period-in-seconds 300 \
  --region <REGION> --profile <PROFILE>
```

### Phase 2: Application Logs (Datadog / pup)

Collect log-level evidence to correlate with infrastructure metrics.

#### 2.1 Error Aggregation

**By service:**
```sh
pup logs aggregate \
  --query 'status:error' \
  --from <EPOCH_START> --to <EPOCH_END> \
  --compute 'count' --group-by 'service' --limit 20
```

**By error kind:**
```sh
pup logs aggregate \
  --query 'status:error' \
  --from <EPOCH_START> --to <EPOCH_END> \
  --compute 'count' --group-by '@error.kind' --limit 20
```

#### 2.2 Error Timeline

**First errors (to pinpoint onset):**
```sh
pup logs search \
  --query 'status:error -service:realtime -"nginx"' \
  --from <EPOCH_START> --to <EPOCH_END> --limit 10
```

**Specific error patterns:**
```sh
# Transaction timeouts
pup logs search \
  --query '"Transaction already closed" OR "Unable to start a transaction" service:<SERVICE>' \
  --from <EPOCH_START> --to <EPOCH_END> --limit 5

# Prepared statement overflow
pup logs search \
  --query 'service:<SERVICE> "max_prepared_stmt_count"' \
  --from <EPOCH_START_ISO> --to <EPOCH_END_ISO> --limit 3
```

#### 2.3 Day-over-Day Comparison

Compare error counts against a normal day to confirm incident specificity:
```sh
# Incident day
pup logs aggregate \
  --query '<ERROR_PATTERN> service:<SERVICE>' \
  --from <INCIDENT_EPOCH_START> --to <INCIDENT_EPOCH_END> --compute 'count'

# Previous day (same time window)
pup logs aggregate \
  --query '<ERROR_PATTERN> service:<SERVICE>' \
  --from <PREV_DAY_EPOCH_START> --to <PREV_DAY_EPOCH_END> --compute 'count'
```

#### 2.4 Datadog Metrics

**Database-level metrics:**
```sh
pup metrics query --query 'avg:aws.rds.queries{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

pup metrics query --query 'avg:aws.rds.database_connections{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

pup metrics query --query 'avg:aws.rds.active_transactions{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

pup metrics query --query 'avg:aws.rds.write_latency{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))

pup metrics query --query 'avg:aws.rds.freeable_memory{*}' \
  --from $((EPOCH_START * 1000)) --to $((EPOCH_END * 1000))
```

### Phase 3: Codebase Analysis (Local Repository)

Identify contributing code patterns by searching local repositories.

#### 3.1 Endpoint Identification

Search for affected endpoints in the codebase:
```sh
# Find route definitions
grep -rn "router\.\(get\|post\|put\|delete\)" --include="*.ts" --include="*.js" | grep "<ENDPOINT_PATH>"

# Find controller/handler implementations
grep -rn "<HANDLER_NAME>" --include="*.ts" --include="*.js"
```

#### 3.2 Query Analysis

Identify heavy queries and ORM patterns:
```sh
# Find raw queries
grep -rn "queryRawUnsafe\|queryRaw\|\$queryRaw" --include="*.ts" --include="*.js"

# Find complex includes/joins
grep -rn "include:" --include="*.ts" --include="*.js" -A 20 | grep -c "include:"

# Find the specific repository method
grep -rn "<METHOD_NAME>" --include="*.ts" --include="*.js"
```

#### 3.3 Client-Side Amplification

Check for client-side patterns that amplify load:
```sh
# React Query / TanStack Query settings
grep -rn "invalidateQueries\|staleTime\|refetchOnWindowFocus\|QueryClient" --include="*.ts" --include="*.tsx"

# App lifecycle handlers
grep -rn "AppState\|handleAppForeground\|onForeground\|useFocusEffect" --include="*.ts" --include="*.tsx"
```

#### 3.4 Connection Pool Configuration

```sh
# Prisma connection settings
grep -rn "connection_limit\|pool_timeout\|DATABASE_URL" --include="*.ts" --include="*.env*" --include="*.prisma"

# Connection pool library settings
grep -rn "connectionLimit\|min:\|max:\|idleTimeout" --include="*.ts" --include="*.js" --include="*.json"
```

### Phase 4: Multi-Day Comparison

Compare incident day against normal days to isolate the trigger.

**3-Day CPU Comparison:**
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[{"Id":"cpu","MetricStat":{"Metric":{"Namespace":"AWS/RDS","MetricName":"CPUUtilization","Dimensions":[{"Name":"DBInstanceIdentifier","Value":"<INSTANCE_ID>"}]},"Period":300,"Stat":"Average"}}]' \
  --start-time <3_DAYS_BEFORE_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

**Derive queries-per-request ratio:**
Calculate `(Queries/sec * Period) / ALB_RequestCount` per time bucket to detect query mix changes.

### Phase 5: Monitoring Gap Analysis

Identify what was NOT monitored that should have been:

```sh
# Check available Datadog metrics
pup metrics list --filter "<METRIC_PREFIX>.*" --from 7d
pup metrics search --query "metrics:<SEARCH_TERM>"

# Check RDS event logs for storage constraints
aws rds describe-events --source-type db-instance \
  --start-time <WIDE_START_UTC> --end-time <WIDE_END_UTC> \
  --region <REGION> --profile <PROFILE> | grep -i "slow\|log\|storage\|delete"
```

## Analysis Framework

After data collection, structure the analysis as follows:

### 1. Timeline Construction

Build a minute-by-minute timeline correlating:
- Infrastructure metrics (CPU, connections, response time)
- Application events (first error, error escalation)
- Human actions (failover, scaling, restarts)
- Recovery indicators (metric normalization)

### 2. Root Cause Identification

Apply the "5 Whys" method:
- What was the immediate trigger?
- What was the underlying vulnerability?
- Why wasn't it caught earlier?
- What amplified the impact?
- What prevented faster recovery?

### 3. Contributing Factors

Categorize into:
- **Infrastructure**: Instance sizing, credit depletion, scaling limits
- **Application**: Query patterns, connection management, retry behavior
- **Client**: Request amplification, missing backoff/throttle
- **Monitoring**: Gaps in observability, insufficient alerting
- **Process**: Response time, runbook gaps

### 4. Cascade Analysis

For cascade failures, document each stage:
```
[Trigger] → [Primary failure] → [Secondary failure] → [Amplification] → [Recovery blocker]
```

## Output Format

Generate a structured incident report:

```markdown
# Incident Report: [Title]

## Summary
- **Duration**: [start] ~ [end] ([N] minutes)
- **Impact**: [user-facing impact description]
- **Root Cause**: [one-sentence root cause]
- **Severity**: [P1/P2/P3/P4]

## Timeline
| Time (JST) | Event | Evidence |
|---|---|---|
| HH:MM | ... | CloudWatch / Datadog / RDS Events |

## Root Cause Analysis
[Detailed analysis with data evidence]

### Why did it happen on this specific day?
[Comparative analysis against normal days]

### Cascade Failure Chain
[Stage-by-stage breakdown]

## Contributing Factors
### Infrastructure
### Application
### Client
### Monitoring Gaps

## Metrics Summary
| Metric | Normal | Incident Peak | Source |
|---|---|---|---|
| ... | ... | ... | CloudWatch / Datadog |

## Remediation Recommendations
### Immediate (P0)
### Short-term (1-2 weeks)
### Medium-term (1-3 months)

## Monitoring Improvements
[What to add to prevent recurrence]

## Appendix: Raw Data
[Collapsed sections with full command outputs]
```

## Verification Script Generation

After analysis, generate a reusable verification script (`run-verification.sh`) that captures all the commands used during investigation for future reference and reproducibility.

## Related Skills

- [security-scan](/security-scan) - Automated vulnerability scanning + STRIDE threat modeling mode
- [code-review](/code-review) - Code-level review for identified issues

## Resources

- [AWS CloudWatch GetMetricData](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_GetMetricData.html)
- [AWS Performance Insights](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html)
- [AWS RDS Events](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.html)
- [Datadog Metrics Query](https://docs.datadoghq.com/api/latest/metrics/#query-timeseries-data)
- [Incident Analysis - Jeli.io](https://www.jeli.io/howie/welcome)
- [Google SRE - Postmortem Culture](https://sre.google/sre-book/postmortem-culture/)

## Guardrails

- Never execute destructive commands (DELETE, DROP, TRUNCATE, restart) during investigation.
- Read-only access to production systems. All commands are queries/reads only.
- Mask or omit PII, credentials, and sensitive data from the report.
- If AWS credentials or Datadog access is unavailable, document what data is needed and provide the exact commands for the user to run manually.
- Always include evidence (command output or metric values) for every claim in the report.
- Prefer measured evidence over assumptions. If data is unavailable, state it explicitly.
