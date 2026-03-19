---
title: Implementation readiness — Phase 1
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/api/schemas/
  - docs/api/openapi.yaml
  - docs/guides/testing.md
  - docs/guides/compliance-evidence.md
---

## Purpose

Define the minimum artifacts that must be in place before coding starts in parallel across teams. This is the pre-implementation checklist for Phase 1.

## Required artifacts

### Canonical data contracts

Versioned JSON Schemas under `docs/api/schemas/`:

- `anomaly.schema.json`
- `workflow.schema.json`
- `feedback.schema.json`
- `policy.schema.json`
- `alert.schema.json`

Schema rules:
- Every payload includes `schema_version`.
- Additive changes only within minor versions.
- Breaking changes require a new major schema version.

### API contracts

Starter OpenAPI spec at `docs/api/openapi.yaml` covering:

- `POST /v1/ingestion/events`
- `GET /v1/agent/deployments/{deploymentId}/feedback`
- `POST /v1/notifications/alerts`

Contract expectations:
- OAuth2/JWT bearer auth for user and agent calls.
- Correlation headers: `X-Request-Id`, `X-Correlation-Id`.
- Consistent error envelope: `{ code, message, details, trace_id }`.

### Policy model

Starter policy schema at `docs/api/schemas/policy.schema.json` supporting:

- Action gating: `auto_allowed`, `approval_required`.
- Residency controls.
- Model allowlists.
- Healthcare profile binding.

Initial runtime profiles:
- `default`
- `strict-healthcare-nl`

### State model

Deterministic lifecycle definitions:

- Anomaly: `new → triaged → investigating → resolved → closed`
- Workflow: `queued → running → waiting_approval → completed | failed | cancelled`

State transitions must be idempotent and keyed by stable IDs (`anomaly_id`, `workflow_id`).

## Exit criteria to start coding

- [ ] All schemas reviewed and published as `v1.0.0`
- [ ] OpenAPI spec reviewed and lint-valid
- [ ] Policy profile `strict-healthcare-nl` approved by security and compliance
- [ ] Workflow and anomaly state machine transitions agreed across teams
- [ ] CI checks include schema and API contract validation
- [ ] `make dev-up` starts the full local stack cleanly
