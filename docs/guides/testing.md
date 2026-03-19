---
title: Testing strategy
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/guides/setup.md
  - docs/guides/implementation-readiness.md
  - docs/api/schemas/
---

## Purpose

Define the test layers, required fixtures, and release criteria for the AIOps Agentic System. Testing is structured to catch contract breaks early, guarantee deterministic workflow behaviour, and validate policy enforcement and compliance controls.

## Test layers

| Layer | Scope | Command |
|---|---|---|
| Unit tests | Component logic and adapters | `make test` |
| Contract tests | Schema and API producer-consumer compatibility | `make test` |
| Replay tests | Historical telemetry replay for detectors | `make test-replay` |
| Workflow determinism tests | Same input produces the same workflow outcome | `make test-workflow` |
| Policy tests | Action gating, model routing, residency rules | `make test-policy` |
| End-to-end smoke tests | Ingestion → anomaly → workflow → notification | `make test-e2e` (requires `make dev-up`) |

## Required test fixtures

- Canonical anomaly payloads (one per severity level).
- Deployment feedback payloads with `auto_allowed` and `approval_required` actions.
- Healthcare profile policy fixtures for `strict-healthcare-nl`.
- Error fixtures for malformed and unauthorized requests.
- Historical telemetry replay datasets for statistical detector baselines.

## Release criteria

- No breaking schema changes without a major version bump.
- Workflow regression suite green.
- Policy enforcement suite green for `strict-healthcare-nl` profile.
- Alert payload contract compatibility verified between notification producer and consumer.
- End-to-end smoke test passing against a local stack.
