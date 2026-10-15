---
name: mysql
description: MySQL best practices for schema design, indexing, query optimization, transactions, and operations. Load when working with MySQL databases.
user-invocable: false
metadata:
  author: planetscale
  version: "1.0.0"
  organization: PlanetScale
  license: MIT
---

# MySQL

MySQL expertise module for safe, measurable database changes across schema design, indexing, query optimization, transactions, and operations.

## Core Workflow

1. Establish workload parameters and constraints
2. Consult only relevant reference materials
3. Propose minimal changes with trade-offs clearly stated
4. Validate findings with diagnostic output (`EXPLAIN`, metrics)
5. For production work, include rollback and verification procedures

## Schema Design

| Topic | Reference | Use for |
|-------|-----------|---------|
| Primary Keys | [references/primary-keys.md](references/primary-keys.md) | Monotonic PKs, UUID anti-patterns, clustered key choice |
| Data Types | [references/data-types.md](references/data-types.md) | Type selection, storage sizes, precision |
| Character Sets | [references/character-sets.md](references/character-sets.md) | utf8mb4, collation, migration |
| JSON Columns | [references/json-column-patterns.md](references/json-column-patterns.md) | JSON storage, generated columns, indexing |

## Indexing

| Topic | Reference | Use for |
|-------|-----------|---------|
| Composite Indexes | [references/composite-indexes.md](references/composite-indexes.md) | Column ordering, equality-before-range, selectivity |
| Covering Indexes | [references/covering-indexes.md](references/covering-indexes.md) | Index-only scans, INCLUDE columns |
| Fulltext Indexes | [references/fulltext-indexes.md](references/fulltext-indexes.md) | Natural language search, boolean mode |
| Index Maintenance | [references/index-maintenance.md](references/index-maintenance.md) | Unused index detection, performance_schema audit |

## Partitioning

| Topic | Reference | Use for |
|-------|-----------|---------|
| Partitioning | [references/partitioning.md](references/partitioning.md) | Time-series, large tables (>50M rows), partition pruning |

## Query Optimization

| Topic | Reference | Use for |
|-------|-----------|---------|
| EXPLAIN Analysis | [references/explain-analysis.md](references/explain-analysis.md) | Plan reading, red flags (filesort, temp tables) |
| Query Pitfalls | [references/query-optimization-pitfalls.md](references/query-optimization-pitfalls.md) | OFFSET pagination, implicit conversions |
| N+1 Queries | [references/n-plus-one.md](references/n-plus-one.md) | Detection, batching, eager loading |

## Transactions & Locking

| Topic | Reference | Use for |
|-------|-----------|---------|
| Isolation Levels | [references/isolation-levels.md](references/isolation-levels.md) | REPEATABLE READ default, phantom reads |
| Deadlocks | [references/deadlocks.md](references/deadlocks.md) | Consistent access order, lock analysis |
| Row Locking | [references/row-locking-gotchas.md](references/row-locking-gotchas.md) | Gap locks, lock escalation, I/O outside transactions |

## Operations

| Topic | Reference | Use for |
|-------|-----------|---------|
| Online DDL | [references/online-ddl.md](references/online-ddl.md) | Schema changes, ALGORITHM options |
| Connection Mgmt | [references/connection-management.md](references/connection-management.md) | Pooling, max_connections tuning |
| Replication Lag | [references/replication-lag.md](references/replication-lag.md) | Lag monitoring, read consistency |

## Guardrails
- Prefer measured evidence over blanket rules of thumb.
- Note MySQL-version-specific behavior when giving advice.
- Ask for explicit human approval before destructive data operations (drops/deletes/truncates).
