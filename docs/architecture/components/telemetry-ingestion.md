---
title: "Component design: Telemetry Ingestion"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: telemetry-ingestion
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/decisions/0001-message-bus-kafka-over-nats-jetstream.md
---

## Purpose

Collect logs, metrics, traces, and platform events from shared infrastructure and onboarded services into a durable ingestion backbone. This is the entry boundary for all signals entering the platform — nothing reaches the detection or analytics layers without passing through here.

## Responsibilities

**Owns:**
- Accepting inbound telemetry over OTLP/gRPC, OTLP/HTTP, log streams, and event webhooks.
- Applying first-pass schema validation and metadata stamping (`cluster`, `env`, `service`, `owner`).
- Buffering bursts and absorbing downstream outages without data loss.
- Emitting ingestion health signals: `lag`, `drop_rate`, `backpressure`.
- Routing to Kafka ingestion topics and dead-letter topic for malformed payloads.

**Does not own:**
- Normalization or enrichment of telemetry (owned by normalization-and-enrichment).
- Storage of canonical or analytics records (owned by storage-and-state).
- Detection or anomaly scoring (owned by anomaly-detection).

## Internal structure

| Component | Responsibility |
|---|---|
| `OTel Collector (daemonset)` | Co-located per node; collects pod logs, node metrics, and traces from local workloads |
| `OTel Collector (gateway)` | Cluster-level aggregator; validates schema, stamps metadata, forwards to Kafka |
| `Edge buffer adapter` | Optional lightweight buffer for constrained sites where Kafka is not directly reachable |
| `Kafka ingestion topics` | Partitioned by signal type (`logs`, `metrics`, `traces`, `events`) and tenancy scope |
| `Dead-letter topic` | Receives malformed or unroutable payloads for inspection and replay |

## Key flows

### Happy path: service telemetry ingestion

1. Service emits OTLP/gRPC telemetry to the daemonset OTel Collector.
2. Daemonset collector forwards to the gateway collector.
3. Gateway collector validates the OTLP envelope schema and stamps `cluster`, `namespace`, `service`, and `environment` metadata.
4. Gateway collector publishes the record to the appropriate Kafka topic partitioned by signal type and tenancy scope.
5. Downstream normalization workers consume from Kafka.

### Malformed payload

1. Gateway collector receives a payload that fails schema validation.
2. Payload is routed to the dead-letter Kafka topic with a reason code.
3. Ingestion health signal `drop_rate` is incremented.
4. Original payload is not forwarded to ingestion topics.

### Downstream Kafka unavailable

1. Gateway collector detects Kafka unavailability.
2. Local queue buffer absorbs new records up to configured limits.
3. `backpressure` health signal is emitted.
4. Non-critical signals are sampled; critical signals (errors, security events) are preserved.
5. On Kafka recovery, buffered records are flushed in order.

## Data owned

**Writes:**
- Kafka ingestion topics (partitioned by signal type and tenancy scope) — primary owner
- Kafka dead-letter topic — primary owner

**Reads (does not own):**
- None at this stage — ingestion is the source boundary.

## External interfaces

### Consumes

| Source | Protocol | Signal type |
|---|---|---|
| Services | OTLP/gRPC, OTLP/HTTP | Traces, metrics, logs |
| Kubernetes nodes | Log stream | Node and pod logs |
| CI/CD pipelines | Event webhook | Deployment and change events |
| Prometheus exporters | Prometheus scrape | Infrastructure metrics |

### Publishes

| Destination | Protocol | Signal | Schema |
|---|---|---|---|
| Kafka ingestion topics | Kafka | Validated telemetry by signal type | `docs/api/schemas/` |
| Kafka dead-letter topic | Kafka | Malformed payload with reason code | — |

Required envelope fields on all published records:
- `event_id`, `event_time`, `signal_type`
- `cluster`, `namespace`, `service`, `environment`
- `trace_id` (if present), `deployment_id` (if present)
- `classification` (`public` / `internal` / `sensitive-health`)

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| Payload fails schema validation | Routed to dead-letter topic with reason code; not forwarded |
| Kafka unavailable | Local queue buffer absorbs records; backpressure signal emitted; non-critical signals sampled |
| Auth failure at ingestion endpoint | Request rejected at gateway; not forwarded; logged with actor context |
| Metadata stamping fails (missing ownership data) | Record published with partial metadata and `classification=internal`; flagged for enrichment correction |

## Non-functional constraints

- At-least-once delivery from collectors to Kafka.
- Partition strategy by service/environment for parallel downstream processing.
- mTLS between collectors, gateways, and Kafka brokers.
- Tenant-aware authentication and authorization for all ingestion endpoints.
- Sensitive field detection and early masking hooks applied before records reach Kafka.

## Assumptions and constraints

- Kafka is available as the primary ingestion bus (ADR 0001).
- Services use OTLP-compatible instrumentation (OTel SDK or equivalent).
- `classification` field must be set by the emitting service for healthcare-sensitive data; fallback is `internal`.
