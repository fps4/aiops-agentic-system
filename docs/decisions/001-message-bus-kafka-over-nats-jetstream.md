# ADR 001: Message bus - Kafka over NATS JetStream

- Status: **Proposed**
- Date: 2026-03-11
- Deciders: Platform architecture group

## Context

The ingestion plane needs durable buffering, replay, ordered partitions, and high-throughput fan-out for logs/metrics/events. The architecture currently lists `Kafka or NATS JetStream`.

Healthcare-compliant operations also require strong auditability, mature operations tooling, and predictable behavior under burst load.

## Decision

Use **Kafka** as the default message bus for Phase 1 and production reference deployments.

Keep NATS JetStream as an optional edge pattern for lightweight local buffering where Kafka is unavailable.

## Rationale

- Kafka has stronger ecosystem maturity for high-volume telemetry pipelines.
- Better long-horizon replay and consumer-group semantics for analytics/detection backfills.
- Broader compatibility with stream processors and governance tooling.
- Operational patterns are well-known in regulated environments.

## Consequences

Positive:
- Lower risk for large-scale ingestion and replay-heavy workflows.
- Easier future integration with stream processing ecosystems.

Trade-offs:
- Higher operational complexity than NATS for small installations.
- Requires careful cluster sizing and storage planning.

## Revisit triggers

- Small-site footprint requirements dominate over throughput.
- Strong organizational standardization on NATS already exists.
- Operational burden of Kafka is unacceptable for target teams.
