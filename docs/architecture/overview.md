---
title: Architecture overview — AIOps Agentic System
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/components/
  - docs/architecture/decisions/
---

## Purpose

The AIOps Agentic System is a sovereign control plane that ingests telemetry from infrastructure and services, detects meaningful anomalies, orchestrates deterministic AI-assisted RCA workflows, and delivers actionable alerts with deep-links to pre-filtered evidence views. It runs entirely in customer-owned data centers.

This document covers C4 level 1 (system context) and level 2 (containers). Component-level detail is in `docs/architecture/components/`.

## System context (C4 L1)

External systems that interact with the platform:

| External system | Direction | Protocol |
|---|---|---|
| Workloads and services | Inbound telemetry | OTLP/gRPC, OTLP/HTTP |
| Kubernetes and node infrastructure | Inbound telemetry | Log streams, Prometheus metrics |
| CI/CD pipelines | Inbound events | Deployment and change events |
| Enterprise IdP | Auth | OIDC/SAML |
| ChatOps platforms (Slack, Mattermost) | Outbound alerts | Webhook/API |
| Incident management systems (PagerDuty, ServiceNow) | Outbound alerts | API |
| Grafana | Outbound links | Dashboard deep-links |
| Agentic clients and software agents | Bidirectional | MCP-compatible HTTP |
| Self-hosted model endpoints | Outbound inference | HTTP/gRPC |

## Containers (C4 L2)

```
Workloads + Infrastructure
  → Telemetry Ingestion (OTel Collectors + Kafka)
  → Normalization and Enrichment (stream processors)
  → Storage and State (object store + ClickHouse + PostgreSQL + Redis)
  → Anomaly Detection (statistical + rule-based workers)
  → Workflow Orchestration (Temporal + agent workers)
  → Notifications and Dashboards (alert delivery + Grafana deep-links)
  → Agent Gateway and Curated Feedback (MCP-compatible interface)

Cross-cutting:
  → Compliance and Governance Plane (policy engine + audit trail)
  → Operations and SLO (platform observability + runbooks)
```

| Container | Responsibility | Key tech |
|---|---|---|
| Telemetry Ingestion | Collect and durably buffer all inbound signals | OTel Collector, Kafka |
| Normalization and Enrichment | Canonicalize and enrich raw telemetry | Stream processors |
| Storage and State | Durable raw retention, analytics queries, operational state | S3-compatible, ClickHouse, PostgreSQL, Redis |
| Anomaly Detection | Detect regressions, emit structured anomaly events | Statistical + rule-based workers |
| Workflow Orchestration | Run deterministic RCA pipelines | Temporal, LLM adapters |
| Notifications and Dashboards | Deliver alerts and dashboard deep-links | ChatOps/incident APIs, Grafana |
| Agent Gateway and Curated Feedback | Policy-aware interface for agents, deployment feedback | MCP-compatible HTTP |
| Compliance and Governance Plane | Policy enforcement, audit trail, healthcare controls | Policy-as-code engine |
| Operations and SLO | Platform self-observability, SLO tracking, runbooks | OTel, Grafana |

## Key flows

### End-to-end incident flow

1. **T+0s** — Logs, metrics, and traces stream through OTel collectors into the ingestion bus.
2. **T+5s** — Normalization workers enrich telemetry and write to raw object storage and analytics indexes.
3. **Sub-minute to few-minute cadence** — Detection workers compare against baselines and emit an anomaly event.
4. **T+30s–T+2min** — Temporal workflow validates the signal, correlates with deployment and DB saturation data, compares against historical incidents, and produces an RCA hypothesis with confidence score and recommended actions.
5. **T+2min** — Alert is sent to the collaboration channel with evidence summary and Grafana deep-link.
6. **T+3min** — Responder validates findings and executes approved mitigation.

### Agent-assisted deploy feedback loop

1. Agentic client authenticates to the agent gateway with user + agent identity.
2. Client deploys a service change and calls `get_deployment_feedback`.
3. Gateway queries normalization, detection, and workflow state for the deployment scope.
4. Gateway returns a curated feedback payload: health deltas, anomaly summary, confidence, and next actions tagged `auto_allowed` or `approval_required`.
5. Client presents the feedback to the user and executes permitted follow-up actions or requests approval.

## Architecture decisions

- [ADR 0001: Kafka over NATS JetStream](decisions/0001-message-bus-kafka-over-nats-jetstream.md)
- [ADR 0002: ClickHouse primary, OpenSearch secondary](decisions/0002-analytics-store-clickhouse-primary-opensearch-secondary.md)
- [ADR 0003: Temporal over Argo Workflows](decisions/0003-orchestration-engine-temporal-over-argo.md)
- [ADR 0004: PostgreSQL plus Redis over single key-value store](decisions/0004-state-store-postgresql-plus-redis-over-single-kv.md)

## Component deep dives

- [Telemetry Ingestion](components/telemetry-ingestion.md)
- [Normalization and Enrichment](components/normalization-and-enrichment.md)
- [Storage and State](components/storage-and-state.md)
- [Anomaly Detection](components/anomaly-detection.md)
- [Workflow Orchestration](components/workflow-orchestration.md)
- [Agent Gateway and Curated Feedback](components/agent-gateway-and-curated-feedback.md)
- [Notifications and Dashboards](components/notifications-and-dashboards.md)
- [Compliance and Governance Plane](components/compliance-and-governance-plane.md)
- [Operations and SLO](components/operations-and-slo.md)
