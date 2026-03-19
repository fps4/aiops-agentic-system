---
title: API contracts
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/api/schemas/
  - docs/architecture/components/agent-gateway-and-curated-feedback.md
---

## Purpose

Index of API contracts and schemas for the AIOps Agentic System. All contracts are versioned and must remain backward-compatible within a major version.

## OpenAPI spec

- [`openapi.yaml`](openapi.yaml) — starter API contract covering ingestion, agent feedback, and notification endpoints

## Schemas

- [`schemas/`](schemas/) — versioned JSON Schema files for platform event contracts

## Contract conventions

- OAuth2/JWT bearer auth for all user and agent calls.
- Correlation headers `X-Request-Id` and `X-Correlation-Id` are required on all requests.
- Error responses use the standard envelope: `{ code, message, details, trace_id }`.
- All schemas include `schema_version`; additive changes only within minor versions.
- Breaking changes require a new major version and a new ADR if they affect cross-service contracts.
