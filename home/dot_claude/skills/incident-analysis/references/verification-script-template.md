# Verification Script Template

After completing an incident analysis, generate a `run-verification.sh` script that captures all commands used for reproducibility.

## Template

```sh
#!/bin/bash
# Incident Verification Script
# Incident: [TITLE]
# Date: [INCIDENT_DATE]
# Generated: [TODAY]

OUT="incident-timeline-verification.md"

cat > "$OUT" << 'HEADER'
# Incident Timeline Verification

Execution date: [TODAY]
Target: [INCIDENT_DESCRIPTION]

---

HEADER

run_cmd() {
  local title="$1"
  shift
  local cmd="$*"
  echo "=== Running: $title ===" >&2
  {
    echo "## $title"
    echo ""
    echo '```'
    echo "\$ $cmd"
    echo '```'
    echo ""
    echo '```json'
    eval "$cmd" 2>&1
    echo '```'
    echo ""
    echo "---"
    echo ""
  } >> "$OUT"
}

# ===== 1. Infrastructure State =====

run_cmd "1.1 RDS Instance Info" \
  "aws rds describe-db-instances --db-instance-identifier <INSTANCE_ID> --region <REGION> --profile <PROFILE> --query 'DBInstances[0].{Class:DBInstanceClass,PI:PerformanceInsightsEnabled,Storage:StorageType,Eng:Engine,Ver:EngineVersion}'"

# ===== 2. CloudWatch Metrics =====

run_cmd "2.1 CPU Utilization (incident window)" \
  "aws cloudwatch get-metric-data --metric-data-queries '[{\"Id\":\"cpu\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/RDS\",\"MetricName\":\"CPUUtilization\",\"Dimensions\":[{\"Name\":\"DBInstanceIdentifier\",\"Value\":\"<INSTANCE_ID>\"}]},\"Period\":60,\"Stat\":\"Average\"}}]' --start-time <START_UTC> --end-time <END_UTC> --region <REGION> --profile <PROFILE>"

# ===== 3. Performance Insights =====

run_cmd "3.1 DB Load" \
  "aws pi get-resource-metrics --service-type RDS --identifier <DBI_RESOURCE_ID> --metric-queries '[{\"Metric\": \"db.load.avg\"}]' --start-time <START_UTC> --end-time <END_UTC> --period-in-seconds 60 --region <REGION> --profile <PROFILE>"

# ===== 4. RDS Events =====

run_cmd "4.1 Cluster Events" \
  "aws rds describe-events --source-type db-cluster --start-time <START_UTC> --end-time <END_UTC> --region <REGION> --profile <PROFILE>"

# ===== 5. ALB Metrics =====

run_cmd "5.1 Response Time" \
  "aws cloudwatch get-metric-data --metric-data-queries '[{\"Id\":\"rtAvg\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/ApplicationELB\",\"MetricName\":\"TargetResponseTime\",\"Dimensions\":[{\"Name\":\"LoadBalancer\",\"Value\":\"<ALB_ARN_SUFFIX>\"}]},\"Period\":300,\"Stat\":\"Average\"}},{\"Id\":\"rtP95\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/ApplicationELB\",\"MetricName\":\"TargetResponseTime\",\"Dimensions\":[{\"Name\":\"LoadBalancer\",\"Value\":\"<ALB_ARN_SUFFIX>\"}]},\"Period\":300,\"Stat\":\"p95\"}}]' --start-time <START_UTC> --end-time <END_UTC> --region <REGION> --profile <PROFILE>"

# ===== 6. Datadog Metrics =====

run_cmd "6.1 CPU Credits" \
  "pup metrics query --query 'avg:aws.rds.cpucredit_balance{dbinstanceidentifier:<INSTANCE_ID>}' --from \$((EPOCH_START * 1000)) --to \$((EPOCH_END * 1000))"

# ===== 7. Multi-Day Comparison =====

run_cmd "7.1 CPU 3-day" \
  "aws cloudwatch get-metric-data --metric-data-queries '[{\"Id\":\"cpu\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/RDS\",\"MetricName\":\"CPUUtilization\",\"Dimensions\":[{\"Name\":\"DBInstanceIdentifier\",\"Value\":\"<INSTANCE_ID>\"}]},\"Period\":300,\"Stat\":\"Average\"}}]' --start-time <3_DAYS_BEFORE> --end-time <END_UTC> --region <REGION> --profile <PROFILE>"

# ===== 8. Datadog Logs =====

run_cmd "8.1 Error by service" \
  "pup logs aggregate --query 'status:error' --from <EPOCH_START> --to <EPOCH_END> --compute 'count' --group-by 'service' --limit 20"

echo "=== Done! Output saved to $OUT ===" >&2
```

## Usage Notes

- Replace all `<PLACEHOLDER>` values with actual identifiers
- Time ranges should include buffer before/after incident (e.g., 2 hours before, 1 hour after)
- Some data has limited retention — run the script ASAP after an incident
- Performance Insights free tier: 7 days retention
- RDS Events: 14 days retention
- CloudWatch 1-minute data: 15 days retention
