# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make dev-up        # Start local stack: Kafka, PostgreSQL, Redis, ClickHouse (Docker Compose)
make down          # Stop local stack
make test          # Unit + contract tests (no external services required)
make test-e2e      # End-to-end tests (requires make dev-up first)
make test-replay   # Historical telemetry replay for detectors
make test-workflow # Determinism check: same input → same workflow outcome
make test-policy   # Action gating, model routing, residency rules
make lint          # Lint JSON schemas, OpenAPI spec, and code (zero warnings required)
```

## Before submitting changes

1. `make lint` — zero warnings required
2. `make test` — all tests must pass
3. If behaviour changed, update the relevant doc in `docs/`
4. If a significant technical decision was made, propose an ADR in `docs/architecture/decisions/` (never edit an accepted ADR — supersede it)
5. If schema changed, bump `schema_version` and update `docs/api/schemas/`

## Architecture

This is a sovereign, open-source-first **AIOps observability and incident intelligence** platform built for regulated environments (Dutch healthcare: NEN 7510/7513, AVG/GDPR, EU AI Act). It is currently in documentation and architecture phase — service implementations do not exist yet.

**Nine core components** (defined in `docs/architecture/components/`):

1. **Telemetry Ingestion** — OTLP receivers + Kafka buffering; validates, stamps metadata, routes to dead-letter on failure
2. **Normalization and Enrichment** — Stream processors that canonicalize telemetry and enrich with ownership/deployment context
3. **Storage and State** — Multi-store: S3-compatible (raw), ClickHouse (analytics/baselines), PostgreSQL (compliance system of record), Redis (deduplication/cooldown)
4. **Anomaly Detection** — Statistical (z-score, EWMA, changepoint) + rule-based (SLO, error/latency thresholds); emits structured anomaly events with confidence and evidence
5. **Workflow Orchestration** — Temporal-backed RCA engine; deterministic and replayable; enforces policy gates before sensitive outputs
6. **Agent Gateway** — MCP-compatible; authenticates OIDC/JWT, enforces per-agent capability policies, returns curated deployment feedback tagged `auto_allowed` or `approval_required`
7. **Notifications** — Alert delivery to ChatOps (Slack/Mattermost) and incident management (PagerDuty/ServiceNow) with Grafana deep-links
8. **Compliance and Governance Plane** — Cross-cutting policy engine; field masking, residency controls, model routing, immutable audit trail, DPIA evidence export
9. **Operations and SLO** — Platform self-observability via OpenTelemetry; tracks lag, drop_rate, backpressure

**Key technology decisions** (ADRs in `docs/architecture/decisions/`):
- **Kafka** — primary message bus (durability, replay, healthcare compliance maturity)
- **ClickHouse** — analytics store for detector queries and baselines
- **Temporal** — workflow orchestration (determinism, auditability, replay)
- **PostgreSQL + Redis** — PostgreSQL as system of record; Redis for ephemeral suppression state

**Policy profiles** (`deploy/policies/`) drive detection thresholds, suppression windows, model routing with residency constraints, and approval gates. Profiles: `default` and `strict-healthcare-nl`.

## Code style and conventions

- All new service endpoints require a corresponding contract test
- Correlation IDs (`X-Request-Id`, `X-Correlation-Id`) are mandatory in all service logs
- Error responses must use the standard envelope: `{ code, message, details, trace_id }`
- New processing activities on patient-related data must have a DPIA entry — flag this to the human reviewer

## Constraints

- Do not modify `infra/` without explicit instruction
- Do not modify policy profiles in `deploy/policies/` without explicit instruction
- Do not commit or push directly — output diffs for human review
- Do not invoke external model endpoints or APIs not listed in the active policy profile

## Key orientation files

- `CODEBASE.md` — directory map and naming conventions
- `GLOSSARY.md` — domain term definitions
- `docs/architecture/overview.md` — C4 L1–L2 system context and container map
- `docs/product/vision.md` — product problem and goals
- `docs/product/prd/0001-aiops-agentic-system.md` — Phase 1 requirements
- `docs/api/openapi.yaml` — API contracts
- `docs/api/schemas/` — JSON Schema definitions (IngestionEvent, DeploymentFeedback, AlertMessage)
