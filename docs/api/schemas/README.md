---
title: Schema index
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/api/README.md
  - docs/guides/implementation-readiness.md
---

## Purpose

Versioned JSON Schema files for all platform event contracts. These schemas are the authoritative definition of record shapes used across ingestion, detection, orchestration, notifications, and the agent interface.

## Schemas

- [`anomaly.schema.json`](anomaly.schema.json) — structured anomaly event produced by the detection plane
- [`workflow.schema.json`](workflow.schema.json) — RCA workflow lifecycle record
- [`feedback.schema.json`](feedback.schema.json) — curated deployment feedback payload for agent clients
- [`policy.schema.json`](policy.schema.json) — policy profile structure for detection, suppression, and compliance controls
- [`alert.schema.json`](alert.schema.json) — notification alert payload

## Conventions

- Use JSON Schema draft 2020-12.
- Include `schema_version` in every contract payload.
- Additive changes only within minor versions; breaking changes require a new major version.
- Schema changes must be accompanied by updated contract tests.
