# Agent instructions

## Allowed

- Read any file in the repo
- Create and edit files in `services/`, `libs/`, `tests/`, `docs/`, `deploy/`
- Run: `make test`, `make lint`, `make dev-up`, `make down`
- Propose new ADRs in `docs/architecture/decisions/` — do not edit accepted ones

## Not allowed

- Modify `infra/` without explicit instruction
- Commit or push directly — output diffs for human review
- Edit `docs/architecture/decisions/` entries that have `status: accepted` — propose a superseding ADR instead
- Invoke external model endpoints or APIs not listed in the active policy profile
- Modify policy profiles in `deploy/policies/` without explicit instruction

## How to run tests

```
make test          # unit + contract tests, no external services required
make test-e2e      # requires local stack running: make dev-up
make lint          # schema, OpenAPI, and code linting
```

## Local dev stack

```
make dev-up        # starts Kafka, PostgreSQL, Redis, ClickHouse via Docker Compose
make down          # stops local stack
```

## Code style

- Follow existing patterns in the module you are editing
- All new service endpoints must have a corresponding contract test
- Correlation IDs (`X-Request-Id`, `X-Correlation-Id`) are mandatory in all service logs
- Error responses must use the standard envelope: `{ code, message, details, trace_id }`
- New processing activities on patient-related data must have a DPIA entry — flag this to the human reviewer

## Before submitting changes

1. Run `make lint` — zero warnings required
2. Run `make test` — all tests must pass
3. If behaviour changed, update the relevant doc in `docs/`
4. If a significant technical decision was made, propose an ADR in `docs/architecture/decisions/`
5. If schema changed, bump `schema_version` and update `docs/api/schemas/`

## Key files for orientation

- `CODEBASE.md` — directory map and naming notes
- `GLOSSARY.md` — domain term definitions
- `docs/architecture/overview.md` — system context and container map
- `docs/product/vision.md` — product problem and goals
- `docs/product/prd/0001-aiops-agentic-system.md` — Phase 1 requirements
