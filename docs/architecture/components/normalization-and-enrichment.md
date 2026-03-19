---
title: "Component design: Normalization and Enrichment"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: normalization-and-enrichment
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/decisions/0001-message-bus-kafka-over-nats-jetstream.md
---

## Purpose

Transform heterogeneous incoming telemetry into the canonical model used by detection, RCA, dashboards, and agent feedback. This is the single point where raw, source-specific records become consistent platform records.

## Responsibilities

**Owns:**
- Parsing and normalizing records from ingestion topics to the canonical schema.
- Enriching records with ownership, service catalog, release metadata, and policy profile.
- Attaching correlation keys: `anomaly_key`, `deployment_key`, `workflow_hint`.
- Routing normalized output to raw archive and analytics and state sinks.
- Applying field-level masking rules before records leave the trusted processing boundary.
- Tagging records with data classification and residency policy markers.
- Preserving transformation lineage for audit reconstruction.

**Does not own:**
- Ingestion and transport from source systems (owned by telemetry-ingestion).
- Anomaly scoring or detection (owned by anomaly-detection).
- Storage of raw or canonical records (owned by storage-and-state).

## Internal structure

| Component | Responsibility |
|---|---|
| `Schema transformer` | Maps source-specific record format to canonical schema; versioned (`v1`, `v2`) with compatibility checks |
| `Enrichment resolver` | Looks up ownership, service catalog, CMDB data, and policy profile for each record |
| `Correlation key generator` | Computes deterministic `anomaly_key` and `deployment_key` from normalized fields |
| `Masking engine` | Applies field-level masking rules from the active policy profile before record is forwarded |
| `Sink router` | Fans out to raw archive, analytics store, and detection pre-aggregation topics |

## Key flows

### Happy path: record normalization

1. Stream worker reads a raw record from a Kafka ingestion topic.
2. `Schema transformer` maps it to the canonical schema using the record's `signal_type` and schema version.
3. `Enrichment resolver` fetches service catalog and policy profile for the record's `service` and `environment`.
4. `Correlation key generator` computes `anomaly_key` and `deployment_key`.
5. `Masking engine` applies field-level masking rules from the policy profile.
6. `Sink router` writes to: raw object storage archive, ClickHouse analytics topic, and detection pre-aggregation topic.

### Schema violation

1. `Schema transformer` detects an unmappable field or missing required field.
2. Record is routed to the dead-letter queue with a reason code.
3. Transformation lineage entry is written noting the failure.
4. No partial record is forwarded to downstream sinks.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| Kafka ingestion topics | Kafka | Raw validated telemetry by signal type |
| Service catalog / CMDB | Internal lookup API | Ownership and metadata |
| Policy profile store | Internal lookup API | Masking rules, classification tags, residency markers |

### Publishes

| Destination | Protocol | Data |
|---|---|---|
| Raw object storage | S3-compatible write | Immutable raw archive |
| ClickHouse analytics topic | Kafka → ClickHouse | Canonical normalized records for detection and dashboards |
| Detection pre-aggregation topic | Kafka | Pre-aggregated signal facts for detector workers |
| Dead-letter queue | Kafka | Failed records with reason codes |

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| Schema violation on incoming record | Routed to DLQ with reason code; not forwarded |
| Enrichment lookup unavailable (transient) | Retry with exponential backoff; record held in processing buffer |
| Sink write fails (transient) | Retry with exponential backoff |
| Persistent sink failure | Platform incident raised; unsafe data mutation halted |
| Masking rule missing for classified field | Record blocked; incident raised; not forwarded downstream |

## Non-functional constraints

- Stateless stream workers; safe to run multiple replicas without coordination.
- Idempotent processing keyed by `event_id` — reprocessing the same record produces the same canonical output.
- Schema transformers are versioned and backward-compatible within minor versions.

## Assumptions and constraints

- All records entering this stage have already been schema-validated and metadata-stamped by telemetry-ingestion.
- Service catalog and CMDB data is available via an internal lookup API; stale or missing data results in partial enrichment, not failure.
- Policy profiles are pre-loaded and cached; live reload is supported but not guaranteed to be instantaneous.
