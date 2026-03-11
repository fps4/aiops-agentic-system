# Testing Strategy

## Goals

- Catch contract breaks early.
- Guarantee deterministic workflow behavior.
- Validate policy enforcement and compliance controls.

## Test layers

- Unit tests: component logic and adapters.
- Contract tests: schema/API producer-consumer compatibility.
- Replay tests: historical telemetry replay for detectors.
- Workflow determinism tests: same input => same workflow outcomes.
- Policy tests: action gating, model routing, residency rules.
- End-to-end smoke tests: ingestion -> anomaly -> workflow -> notification.

## Required fixtures

- Canonical anomaly payloads.
- Deployment feedback payloads (`auto_allowed`, `approval_required`).
- Healthcare profile policy fixtures.
- Error fixtures for malformed and unauthorized requests.

## Release criteria

- No breaking schema changes without version bump.
- Workflow regression suite green.
- Policy enforcement suite green for `strict-healthcare-nl`.
- Alert payload contract compatibility verified.
