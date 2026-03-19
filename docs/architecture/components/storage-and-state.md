---
title: "Component design: Storage and State"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: storage-and-state
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/decisions/0002-analytics-store-clickhouse-primary-opensearch-secondary.md
  - docs/architecture/decisions/0004-state-store-postgresql-plus-redis-over-single-kv.md
---

## Purpose

Provide durable raw retention, high-performance analytics, and reliable operational state for anomalies, workflows, and policy execution. This component is the persistence layer shared by the detection, orchestration, compliance, and dashboard planes.

## Responsibilities

**Owns:**
- Storing raw telemetry in immutable object storage for replay and forensic analysis.
- Serving low-latency analytical queries for detectors and dashboards via ClickHouse.
- Persisting anomaly lifecycle, workflow metadata, policy versions, and operator approvals in PostgreSQL.
- Maintaining suppression, cooldown, and deduplication hot state with TTL semantics in Redis.
- Enforcing retention tiers and lifecycle policies aligned to the active policy profile.

**Does not own:**
- Record normalization or schema transformation (owned by normalization-and-enrichment).
- Query routing logic in calling services — each service is responsible for knowing which store to query.
- Backup tooling execution — storage-and-state defines the strategy; infra/ops execute it.

## Internal structure

| Store | Role | Key characteristics |
|---|---|---|
| Object storage (S3-compatible/MinIO/Ceph) | Immutable raw archive and compliance snapshots | Append-only, versioned, long retention |
| ClickHouse | Primary analytics store for detection and dashboards | Columnar, materialized views, time-window aggregations |
| OpenSearch | Optional secondary for full-text log search | Enabled per deployment; not required for core detection |
| PostgreSQL | System of record for business and process state | ACID, queryable schema, audit-friendly |
| Redis | Ephemeral coordination and rate-limiting state | Short-TTL keys only; no durable compliance data |

## Data owned

**Writes:**
- Object storage: raw telemetry events and immutable compliance evidence snapshots — primary owner
- ClickHouse: aggregated and query-optimized operational datasets — primary owner
- PostgreSQL: anomaly lifecycle, workflow metadata, policy versions, approval records, audit events — primary owner
- Redis: suppression keys, cooldown windows, deduplication keys — primary owner

**Reads (does not own):**
- Normalized canonical records written by normalization-and-enrichment before analytics ingest.

## State model

| State | Meaning | Valid transitions |
|---|---|---|
| Anomaly: `new` | Anomaly event received, not yet triaged | → `triaged` |
| Anomaly: `triaged` | Acknowledged, workflow not yet started | → `investigating` |
| Anomaly: `investigating` | Workflow running | → `resolved`, `closed` |
| Anomaly: `resolved` | Root cause identified and actioned | → `closed` |
| Anomaly: `closed` | Terminal state | — |
| Workflow: `queued` | Workflow created, not yet started | → `running` |
| Workflow: `running` | Active pipeline execution | → `waiting_approval`, `completed`, `failed`, `cancelled` |
| Workflow: `waiting_approval` | Paused pending human or policy approval | → `running`, `cancelled` |
| Workflow: `completed` | All stages finished successfully | terminal |
| Workflow: `failed` | Unrecoverable error | terminal |
| Workflow: `cancelled` | Manually or policy-cancelled | terminal |

State transitions are idempotent and keyed by stable IDs (`anomaly_id`, `workflow_id`).

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| ClickHouse write fails | Retry with backoff; buffered in Kafka until ClickHouse recovers |
| PostgreSQL write fails | Exception propagates; calling service handles retry or compensation |
| Redis unavailable | Hot-path logic (suppression, cooldown) degrades gracefully; warning logged; risk of duplicate anomaly accepted |
| Object storage write fails | Normalization worker retries; record is not marked as archived until confirmed |

## Non-functional constraints

- PostgreSQL point-in-time recovery required.
- ClickHouse metadata and data: scheduled snapshots and replication.
- Object storage: versioning and replication where residency policy requires it.
- Redis keys must have explicit TTL; no durable compliance data stored in Redis.
- Retention aligned to active policy profile: healthcare profile enforces longer audit log retention and immutability requirements.

## Assumptions and constraints

- OpenSearch is optional; the platform operates correctly without it (ClickHouse covers core analytics).
- Redis is a shared cache — this component does not own its own Redis instance.
- Restore drills are an operational responsibility defined in the operations-and-slo runbooks.
