# Repository Bootstrap

## Recommended initial structure

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
- Shared contracts in `libs/contracts`.
- Backward-compatible API and schema evolution only.
- Correlation IDs are mandatory in all service logs.

## Local developer setup targets

- `make dev-up`: local dependencies (Kafka, PostgreSQL, Redis, ClickHouse).
- `make test`: run unit + contract tests.
- `make lint`: lint APIs/schemas/code.
- `make down`: stop local stack.

## CI gates (initial)

- Schema validation (`docs/schemas/*.json`).
- OpenAPI validation (`docs/contracts/openapi.yaml`).
- Contract tests for producer/consumer compatibility.
- Security checks for dependency and container images.
