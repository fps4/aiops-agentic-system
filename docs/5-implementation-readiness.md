# Implementation Readiness

This document defines the minimum artifacts required before coding starts in parallel across teams.

## 1) Canonical data contracts (must-have)

Use versioned JSON Schemas under `docs/schemas/`:

- `anomaly.schema.json`
- `workflow.schema.json`
- `feedback.schema.json`
- `policy.schema.json`
- `alert.schema.json`

Rules:
- Every payload includes `schema_version`.
- Additive changes only within minor versions.
- Breaking changes require a new major schema version.

## 2) API contracts (must-have)

Starter OpenAPI spec is in `docs/contracts/openapi.yaml` and covers:

- `POST /v1/ingestion/events`
- `GET /v1/agent/deployments/{deploymentId}/feedback`
- `POST /v1/notifications/alerts`

Contract expectations:
- OAuth2/JWT bearer auth for user/agent calls.
- Correlation headers (`X-Request-Id`, `X-Correlation-Id`).
- Consistent error envelope (`code`, `message`, `details`, `trace_id`).

## 3) Policy model (must-have)

Starter policy schema in `docs/schemas/policy.schema.json` supports:

- action gating (`auto_allowed`, `approval_required`)
- residency controls
- model allowlists
- healthcare profile binding

Initial runtime profiles:
- `default`
- `strict-healthcare-nl`

## 4) State model (must-have)

Define deterministic lifecycles:

- Anomaly: `new -> triaged -> investigating -> resolved -> closed`
- Workflow: `queued -> running -> waiting_approval -> completed | failed | cancelled`

State transitions must be idempotent and keyed by stable IDs (`anomaly_id`, `workflow_id`).

## 5) Repository bootstrap (must-have)

See `docs/6-repository-bootstrap.md` for baseline structure and day-1 developer setup.

## 6) Test strategy (must-have)

See `docs/7-testing-strategy.md` for contract, replay, workflow determinism, and policy tests.

## 7) Compliance evidence plan (must-have)

See `docs/8-compliance-evidence-plan.md` for audit logs, DPIA traceability, retention, and residency evidence.

## Exit criteria to start coding

- Schemas are reviewed and published as `v1.0.0`.
- OpenAPI is reviewed and lint-valid.
- Policy profile `strict-healthcare-nl` approved by security/compliance.
- Workflow and anomaly state machine transitions agreed.
- CI checks include schema + API contract validation.
