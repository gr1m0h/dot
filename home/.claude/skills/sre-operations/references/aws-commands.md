# AWS CLI Commands Reference

## CloudWatch Metrics

### CPU Utilization (1-minute granularity)
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[{"Id":"cpu","MetricStat":{"Metric":{"Namespace":"AWS/RDS","MetricName":"CPUUtilization","Dimensions":[{"Name":"DBInstanceIdentifier","Value":"<INSTANCE_ID>"}]},"Period":60,"Stat":"Average"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

### ALB Response Time (Average + p95)
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id":"rtAvg","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"TargetResponseTime","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"Average"}},
    {"Id":"rtP95","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"TargetResponseTime","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"p95"}}
  ]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

### ALB Request Count + 5XX
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {"Id":"req","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"RequestCount","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"Sum"}},
    {"Id":"e5xx","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"HTTPCode_ELB_5XX_Count","Dimensions":[{"Name":"LoadBalancer","Value":"<ALB_ARN_SUFFIX>"}]},"Period":300,"Stat":"Sum"}}
  ]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

### Database Connections
```sh
aws cloudwatch get-metric-data \
  --metric-data-queries '[{"Id":"conn","MetricStat":{"Metric":{"Namespace":"AWS/RDS","MetricName":"DatabaseConnections","Dimensions":[{"Name":"DBInstanceIdentifier","Value":"<INSTANCE_ID>"}]},"Period":300,"Stat":"Average"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

### ECS Task Count + CPU/Memory
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

## RDS

### Instance Info
```sh
aws rds describe-db-instances \
  --db-instance-identifier <INSTANCE_ID> \
  --region <REGION> --profile <PROFILE> \
  --query 'DBInstances[0].{Class:DBInstanceClass,PI:PerformanceInsightsEnabled,Storage:StorageType,Eng:Engine,Ver:EngineVersion}'
```

### RDS Events
```sh
aws rds describe-events --source-type db-cluster \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>

aws rds describe-events --source-type db-instance \
  --start-time <START_UTC> --end-time <END_UTC> \
  --region <REGION> --profile <PROFILE>
```

## Performance Insights

### DB Load (1-minute)
```sh
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <DBI_RESOURCE_ID> \
  --metric-queries '[{"Metric": "db.load.avg"}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --period-in-seconds 60 \
  --region <REGION> --profile <PROFILE>
```

### Wait Events
```sh
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <DBI_RESOURCE_ID> \
  --metric-queries '[{"Metric": "db.load.avg", "GroupBy": {"Group": "db.wait_event"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --period-in-seconds 300 \
  --region <REGION> --profile <PROFILE>
```

### Top SQL
```sh
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <DBI_RESOURCE_ID> \
  --metric-queries '[{"Metric": "db.load.avg", "GroupBy": {"Group": "db.sql.statement"}}]' \
  --start-time <START_UTC> --end-time <END_UTC> \
  --period-in-seconds 300 \
  --region <REGION> --profile <PROFILE>
```

## Data Retention Notes

| Data Source | Retention | Note |
|---|---|---|
| CloudWatch (1-min) | 15 days | Use 60s period within 15 days |
| CloudWatch (5-min) | 63 days | Use 300s period within 63 days |
| CloudWatch (1-hour) | 455 days | Use 3600s period for older data |
| Performance Insights (free) | 7 days | Capture early or data is lost |
| Performance Insights (paid) | 2 years | Check if retention is configured |
| RDS Events | 14 days | Export immediately after incident |
| Datadog Logs | Varies by plan | Check org retention settings |
| Slow Query Log (small instances) | May be auto-deleted | db.t* instances have storage limits |
