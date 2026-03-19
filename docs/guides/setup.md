---
title: Local development setup
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/guides/implementation-readiness.md
  - docs/architecture/overview.md
---

## Purpose

Get a local development environment running from scratch. Covers prerequisites, initial setup, and day-to-day developer commands.

## Prerequisites

- Docker and Docker Compose
- `make`
- Access to the internal container registry (for base images)

## Recommended repository structure

```
aiops-platform/
  services/
    ingestion/
    normalization/
    detection/
    orchestration/
    agent-gateway/
    notifications/
  libs/
    contracts/
    policy-engine/
    observability/
  deploy/
    helm/
    kustomize/
  infra/
    terraform/
  docs/
```

## Day-1 conventions

- One service = one deployable unit.
- Shared contracts and schemas in `libs/contracts/`.
- Backward-compatible API and schema evolution only within a major version.
- Correlation IDs (`X-Request-Id`, `X-Correlation-Id`) are mandatory in all service logs.

## Setup commands

```bash
make dev-up    # Start local dependencies: Kafka, PostgreSQL, Redis, ClickHouse
make test      # Run unit and contract tests (no external services required)
make lint      # Lint APIs, schemas, and code
make down      # Stop local stack
```

## CI gates

The following checks run on every pull request:

- Schema validation (`docs/api/schemas/*.json`)
- OpenAPI validation (`docs/api/openapi.yaml`)
- Contract tests for producer/consumer schema compatibility
- Security checks for dependency and container images
- Policy profile validation (`deploy/policies/*.yaml`)
