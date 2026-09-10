---
name: clickhouse-io
description: ClickHouse database patterns, query optimization, and data engineering best practices. Use when working with ClickHouse databases, writing analytical queries, designing MergeTree tables, or optimizing materialized views for high-performance workloads.
---

# ClickHouse Analytics Patterns

ClickHouse-specific patterns for high-performance analytics and data engineering.

## Table Design Patterns

### MergeTree Engine (Most Common)

```sql
CREATE TABLE markets_analytics (
    date Date,
    market_id String,
    market_name String,
    volume UInt64,
    trades UInt32,
    unique_traders UInt32,
    avg_trade_size Float64,
    created_at DateTime
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(date)
ORDER BY (date, market_id)
SETTINGS index_granularity = 8192;
```

### ReplacingMergeTree (Deduplication)

```sql
CREATE TABLE user_events (
    event_id String,
    user_id String,
    event_type String,
    timestamp DateTime,
    properties String
) ENGINE = ReplacingMergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, event_id, timestamp)
PRIMARY KEY (user_id, event_id);
```

### AggregatingMergeTree (Pre-aggregation)

```sql
CREATE TABLE market_stats_hourly (
    hour DateTime,
    market_id String,
    total_volume AggregateFunction(sum, UInt64),
    total_trades AggregateFunction(count, UInt32),
    unique_users AggregateFunction(uniq, String)
) ENGINE = AggregatingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, market_id);
```

## Query Optimization

### Efficient Filtering

```sql
-- Use indexed columns first
SELECT * FROM markets_analytics
WHERE date >= '2025-01-01'
  AND market_id = 'market-123'
  AND volume > 1000
ORDER BY date DESC LIMIT 100;
```

### Aggregations

```sql
SELECT
    toStartOfDay(created_at) AS day,
    market_id,
    sum(volume) AS total_volume,
    count() AS total_trades,
    uniq(trader_id) AS unique_traders
FROM trades
WHERE created_at >= today() - INTERVAL 7 DAY
GROUP BY day, market_id
ORDER BY day DESC, total_volume DESC;
```

## Materialized Views

```sql
CREATE MATERIALIZED VIEW market_stats_hourly_mv
TO market_stats_hourly
AS SELECT
    toStartOfHour(timestamp) AS hour,
    market_id,
    sumState(amount) AS total_volume,
    countState() AS total_trades,
    uniqState(user_id) AS unique_users
FROM trades
GROUP BY hour, market_id;
```

## Data Insertion

### Bulk Insert (Recommended)

```typescript
async function bulkInsertTrades(trades: Trade[]) {
  const values = trades.map(trade => `(
    '${trade.id}', '${trade.market_id}', '${trade.user_id}',
    ${trade.amount}, '${trade.timestamp.toISOString()}'
  )`).join(',')

  await clickhouse.query(`
    INSERT INTO trades (id, market_id, user_id, amount, timestamp) VALUES ${values}
  `).toPromise()
}
```

## Common Analytics Queries

### Time Series, Funnel, Cohort Analysis

- Daily active users with `uniq(user_id)`
- Retention analysis with `dateDiff`
- Conversion funnels with `countIf`
- Cohort analysis by signup month

## Best Practices

1. **Partitioning**: By time (month or day), avoid too many partitions
2. **Ordering Key**: Most frequently filtered columns first
3. **Data Types**: Smallest appropriate type, LowCardinality for repeated strings
4. **Avoid**: SELECT *, FINAL, too many JOINs, small frequent inserts
5. **Monitor**: Query performance, disk usage, merge operations
