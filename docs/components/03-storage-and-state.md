# Component 03: Storage and State

## Purpose

Provide durable raw retention, high-performance analytics, and reliable operational state for anomalies, workflows, and policy execution.

## Recommended stack

- Object storage (S3-compatible/MinIO/Ceph) for immutable raw data
- ClickHouse primary analytics store; OpenSearch optional secondary (ADR 002)
- PostgreSQL system of record + Redis ephemeral state (ADR 004)

## Responsibilities

- Store raw telemetry for replay and forensic analysis.
- Serve low-latency analytical queries for detectors and dashboards.
- Persist anomaly lifecycle, workflow metadata, policy versions, and approvals.
- Maintain suppression/cooldown/dedup hot state with TTL semantics.

## Data ownership boundaries

- Object storage: source-of-truth raw events and immutable compliance snapshots.
- ClickHouse: aggregated and query-optimized operational datasets.
- OpenSearch (optional): full-text search indexes.
- PostgreSQL: authoritative business/process state.
- Redis: short-lived coordination and rate-limiting state.

## Retention strategy

- Raw archive: long retention with lifecycle tiers.
- Analytics tables: hot/warm retention windows tuned by query needs.
- Workflow and audit metadata: retention aligned to compliance profile.
- Redis keys: explicit TTL only; no durable compliance data.

## Backup and recovery

- Point-in-time recovery for PostgreSQL.
- Scheduled snapshots and replication for ClickHouse metadata/data.
- Object storage versioning + replication where required.
- Restore drills as part of operational readiness.
