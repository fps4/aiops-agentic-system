---
title: "Component design: Operations and SLO"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: operations-and-slo
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/guides/
---

## Purpose

Keep the platform observable, operable, and resilient through explicit service level objectives, platform health monitoring, and operational runbooks. This component defines what good looks like for the platform itself and ensures deviations are visible and actionable.

## Responsibilities

**Owns:**
- Defining and tracking SLOs for each component plane.
- Monitoring golden signals per component.
- Running capacity management for Kafka, ClickHouse, PostgreSQL, and Redis.
- Maintaining upgrade, rollback, and disaster recovery runbooks.
- Providing continuous improvement loops through SLO and feedback reviews.

**Does not own:**
- Platform component implementation (owned by their respective components).
- Compliance evidence collection (owned by compliance-and-governance-plane).
- End-user alert delivery (owned by notifications-and-dashboards).

## Internal structure

### Core SLOs

| SLO | Signal | Target |
|---|---|---|
| Ingestion lag | Time from event emission to Kafka availability | P95 within operational target |
| Detection latency | Time from Kafka record to anomaly event emitted | P95 within operational target |
| Workflow completion | Time from anomaly event to final summary published | P95 within operational target |
| Notification delivery | Time from workflow completion to alert delivered | P95 within operational target |
| Agent gateway availability | Successful tool call rate | Target uptime per SLA |

SLO thresholds are defined in the active policy profile and reviewed quarterly.

### Alerting strategy

- Error-budget-based paging for critical SLO breaches (ingestion lag, detection, notification delivery).
- Ticket-based alerts for non-urgent degradation (capacity trending, slow query patterns).
- Suppression rules to prevent operations alert storms during known maintenance windows.

## Key flows

### SLO breach response

1. Grafana evaluates SLO error budget; breach threshold crossed.
2. PagerDuty page sent to on-call platform engineer.
3. Responder opens Grafana SLO dashboard; identifies the degraded component.
4. Runbook for that component is linked in the alert.
5. Responder follows runbook; updates incident record.
6. Post-incident: action item filed for root cause resolution.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| All platform components | OTel / Prometheus | Golden signals: latency, error rate, saturation, traffic |
| Kafka | Kafka metrics | Consumer lag, partition health |
| PostgreSQL, ClickHouse, Redis | DB metrics | Query latency, connection saturation, storage usage |

### Publishes

| Destination | Protocol | Data |
|---|---|---|
| Grafana | Dashboard | SLO dashboards, golden signal views |
| PagerDuty | Alert | SLO breach pages |
| Runbook store (`docs/guides/runbooks/`) | — | Operational playbooks |

## Error handling and failure modes

Key runbook coverage:

| Scenario | Runbook |
|---|---|
| Ingestion backlog recovery | `docs/guides/runbooks/ingestion-backlog-recovery.md` |
| Detector quality degradation | `docs/guides/runbooks/detector-quality-degradation.md` |
| Workflow stuck or retry storms | `docs/guides/runbooks/workflow-stuck-retry.md` |
| Notification delivery failures | `docs/guides/runbooks/notification-delivery-failure.md` |
| Policy engine rejection spikes | `docs/guides/runbooks/policy-engine-rejection-spikes.md` |

## Non-functional constraints

- All platform services must emit OTel traces and metrics; no dark services.
- SLO dashboards must be available during incidents — Grafana availability is a dependency.
- Backup and restore drills must be executed on a schedule defined in the active policy profile.

## Assumptions and constraints

- SLO thresholds are starting targets; they will be refined after Phase 1 baseline data is available.
- Runbooks listed above are to be authored during Phase 1 implementation; placeholders are noted in `docs/guides/runbooks/`.
