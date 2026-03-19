# AIOps Agentic System

A sovereign, open-source-first observability and incident intelligence control plane. Detects anomalies, orchestrates AI-assisted root-cause analysis, and delivers actionable alerts — fully within your own data center.

## Quick orientation

- `CODEBASE.md` — directory map, entry points, and naming notes
- `GLOSSARY.md` — domain term definitions
- `AGENTS.md` — instructions for AI coding agents
- `docs/` — full documentation

## Documentation

- [Product vision](docs/product/vision.md)
- [Phase 1 PRD](docs/product/prd/0001-aiops-agentic-system.md)
- [Architecture overview](docs/architecture/overview.md)
- [Component designs](docs/architecture/components/)
- [Architecture decisions](docs/architecture/decisions/)
- [API contracts](docs/api/)
- [Guides](docs/guides/)

## Local setup

```
make dev-up    # start local dependencies (Kafka, PostgreSQL, Redis, ClickHouse)
make test      # run unit + contract tests
make lint      # lint schemas, APIs, and code
make down      # stop local stack
```
