# ADR 004: State store - PostgreSQL plus Redis over single key-value store

- Status: **Proposed**
- Date: 2026-03-11
- Deciders: Platform architecture group

## Context

The architecture lists `PostgreSQL and/or key-value store` for anomaly state, policy state, and workflow metadata.

The platform needs transactional consistency for policy/audit metadata and low-latency ephemeral access for dedupe, cooldown windows, and short-lived coordination.

## Decision

Use **PostgreSQL as the system of record** plus **Redis for ephemeral/high-speed state**.

Do not use a single key-value store as the only state backend for Phase 1.

## Rationale

- PostgreSQL provides strong consistency, queryability, schema governance, and audit friendliness.
- Redis fits short-TTL caches, dedupe keys, and burst-control semantics.
- Split model keeps durable compliance artifacts in a relational system of record.

## Consequences

Positive:
- Better reliability and auditability for governance-critical metadata.
- Lower latency for hot-path suppression and coordination logic.

Trade-offs:
- Two operational components instead of one.
- Requires clear data ownership boundaries to avoid duplication drift.

## Revisit triggers

- Deployment footprint must be minimized to single datastore.
- Workload profile changes to mostly ephemeral coordination.
- Managed platform constraints dictate a different standard stack.
