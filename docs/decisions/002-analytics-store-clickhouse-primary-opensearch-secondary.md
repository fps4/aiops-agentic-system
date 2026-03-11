# ADR 002: Analytics store - ClickHouse primary, OpenSearch secondary

- Status: **Proposed**
- Date: 2026-03-11
- Deciders: Platform architecture group

## Context

The architecture currently lists `ClickHouse and/or OpenSearch` for dashboard and analytics workloads.

The platform must support anomaly baselines, time-window aggregations, incident evidence queries, and cost-efficient retention for high-cardinality telemetry.

## Decision

Use **ClickHouse as the primary analytics store** for metrics/log-derived analytical queries and detector workloads.

Use **OpenSearch as optional secondary** for full-text search and operator-centric log exploration use cases when needed.

## Rationale

- ClickHouse is generally stronger for large aggregations and time-series analytics at lower cost.
- Deterministic detector pipelines benefit from fast columnar scans and materialized views.
- OpenSearch remains useful for full-text and ad-hoc search experience.
- Split-by-strength avoids forcing one datastore to do everything poorly.

## Consequences

Positive:
- Better performance/cost profile for core detection and RCA analytics.
- Clear workload boundaries improve tuning and reliability.

Trade-offs:
- Dual-store operation adds integration and data-routing complexity.
- Teams need governance on which query type goes to which store.

## Revisit triggers

- Full-text search becomes primary workload.
- Team lacks operational capability for dual stores.
- New platform constraints require single-store simplification.
