---
title: "0001: Message bus — Kafka over NATS JetStream"
status: proposed
date: 2026-03-11
---

## Context

The ingestion plane needs durable buffering, replay, ordered partitions, and high-throughput fan-out for logs, metrics, and events. The architecture initially listed Kafka or NATS JetStream as candidate options.

Healthcare-compliant operations also require strong auditability, mature operations tooling, and predictable behaviour under burst load.

## Decision

Use Kafka as the default message bus for Phase 1 and production reference deployments.

Keep NATS JetStream as an optional edge pattern for lightweight local buffering where Kafka is unavailable.

## Consequences

Positive:
- Lower risk for large-scale ingestion and replay-heavy workflows.
- Stronger ecosystem maturity for high-volume telemetry pipelines.
- Better long-horizon replay and consumer-group semantics for analytics and detection backfills.
- Broader compatibility with stream processors and governance tooling.
- Operational patterns are well-known in regulated environments.

Trade-offs:
- Higher operational complexity than NATS for small installations.
- Requires careful cluster sizing and storage planning.

Revisit if:
- Small-site footprint requirements dominate over throughput.
- Strong organizational standardization on NATS already exists.
- Operational burden of Kafka is unacceptable for target teams.
