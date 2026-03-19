---
title: "0002: Analytics store — ClickHouse primary, OpenSearch secondary"
status: proposed
date: 2026-03-11
---

## Context

The platform must support anomaly baselines, time-window aggregations, incident evidence queries, and cost-efficient retention for high-cardinality telemetry. The architecture initially listed ClickHouse and/or OpenSearch as candidates for dashboard and analytics workloads.

## Decision

Use ClickHouse as the primary analytics store for metrics, log-derived analytical queries, and detector workloads.

Use OpenSearch as optional secondary for full-text search and operator-centric log exploration when needed.

## Consequences

Positive:
- Better performance and cost profile for core detection and RCA analytics.
- Clear workload boundaries improve tuning and reliability.
- Deterministic detector pipelines benefit from fast columnar scans and materialized views.

Trade-offs:
- Dual-store operation adds integration and data-routing complexity.
- Teams need governance on which query type goes to which store.

Revisit if:
- Full-text search becomes the primary workload.
- Team lacks operational capability for dual stores.
- New platform constraints require single-store simplification.
