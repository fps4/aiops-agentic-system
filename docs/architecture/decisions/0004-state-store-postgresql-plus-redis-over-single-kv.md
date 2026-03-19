---
title: "0004: State store — PostgreSQL plus Redis over single key-value store"
status: proposed
date: 2026-03-11
---

## Context

The platform needs transactional consistency for policy and audit metadata and low-latency ephemeral access for deduplication, cooldown windows, and short-lived coordination state. The architecture initially listed PostgreSQL and/or a key-value store as candidates.

## Decision

Use PostgreSQL as the system of record plus Redis for ephemeral and high-speed state.

Do not use a single key-value store as the only state backend for Phase 1.

## Consequences

Positive:
- PostgreSQL provides strong consistency, queryability, schema governance, and audit friendliness for compliance-critical metadata.
- Redis fits short-TTL caches, deduplication keys, and burst-control semantics.
- Split model keeps durable compliance artifacts in a relational system of record.
- Better reliability and auditability for governance-critical metadata.
- Lower latency for hot-path suppression and coordination logic.

Trade-offs:
- Two operational components instead of one.
- Requires clear data ownership boundaries to avoid duplication drift.

Revisit if:
- Deployment footprint must be minimized to a single datastore.
- Workload profile changes to mostly ephemeral coordination.
- Managed platform constraints dictate a different standard stack.
