---
name: postgres
description: PostgreSQL best practices, query optimization, connection troubleshooting, and performance improvement. Load when working with Postgres databases.
user-invocable: false
metadata:
  author: planetscale
  version: "1.0.0"
  organization: PlanetScale
  license: MIT
---

# PlanetScale Postgres

## Generic Postgres

| Topic                  | Reference                                                        | Use for                                                   |
| ---------------------- | ---------------------------------------------------------------- | --------------------------------------------------------- |
| Schema Design          | [references/schema-design.md](references/schema-design.md)           | Tables, primary keys, data types, foreign keys            |
| Indexing               | [references/indexing.md](references/indexing.md)                      | Index types, composite indexes, performance               |
| Index Optimization     | [references/index-optimization.md](references/index-optimization.md) | Unused/duplicate index queries, index audit               |
| Partitioning           | [references/partitioning.md](references/partitioning.md)             | Large tables, time-series, data retention                 |
| Query Patterns         | [references/query-patterns.md](references/query-patterns.md)         | SQL anti-patterns, JOINs, pagination, batch queries       |
| Optimization Checklist | [references/optimization-checklist.md](references/optimization-checklist.md) | Pre-optimization audit, cleanup, readiness checks  |
| MVCC and VACUUM        | [references/mvcc-vacuum.md](references/mvcc-vacuum.md)               | Dead tuples, long transactions, xid wraparound prevention |

## Operations and Architecture

| Topic                  | Reference                                                                    | Use for                                                         |
| ---------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Process Architecture   | [references/process-architecture.md](references/process-architecture.md)     | Multi-process model, connection pooling, auxiliary processes     |
| Memory Architecture    | [references/memory-management-ops.md](references/memory-management-ops.md)   | Shared/private memory layout, OS page cache, OOM prevention     |
| MVCC Transactions      | [references/mvcc-transactions.md](references/mvcc-transactions.md)           | Isolation levels, XID wraparound, serialization errors          |
| WAL and Checkpoints    | [references/wal-operations.md](references/wal-operations.md)                 | WAL internals, checkpoint tuning, durability, crash recovery    |
| Replication            | [references/replication.md](references/replication.md)                       | Streaming replication, slots, sync commit, failover             |
| Storage Layout         | [references/storage-layout.md](references/storage-layout.md)                | PGDATA structure, TOAST, fillfactor, tablespaces, disk mgmt     |
| Monitoring             | [references/monitoring.md](references/monitoring.md)                         | pg_stat views, logging, pg_stat_statements, host metrics        |
| Backup and Recovery    | [references/backup-recovery.md](references/backup-recovery.md)              | pg_dump, pg_basebackup, PITR, WAL archiving, backup tools      |

## PlanetScale-Specific

| Topic              | Reference                                                                    | Use for                                               |
| ------------------ | ---------------------------------------------------------------------------- | ----------------------------------------------------- |
| Connection Pooling | [references/ps-connection-pooling.md](references/ps-connection-pooling.md)   | PgBouncer, pool sizing, pooled vs direct              |
| Extensions         | [references/ps-extensions.md](references/ps-extensions.md)                   | Supported extensions, compatibility                   |
| Connections        | [references/ps-connections.md](references/ps-connections.md)                 | Connection troubleshooting, drivers, SSL              |
| Insights           | [references/ps-insights.md](references/ps-insights.md)                       | Slow queries, MCP server, pscale CLI                  |
| CLI Commands       | [references/ps-cli-commands.md](references/ps-cli-commands.md)               | pscale CLI reference, branches, deploy requests, auth |
| CLI API Insights   | [references/ps-cli-api-insights.md](references/ps-cli-api-insights.md)       | Query insights via `pscale api`, schema analysis      |

## Guardrails
- Prefer measured evidence over blanket rules of thumb.
- Note Postgres-version-specific behavior when giving advice.
- Ask for explicit human approval before destructive data operations (drops/deletes/truncates).
