---
title: "Component design: Notifications and Dashboards"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: notifications-and-dashboards
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
---

## Purpose

Deliver actionable incident intelligence to responders with minimal cognitive overhead and immediate evidence navigation. This component is the human-facing output layer — it translates completed RCA workflow summaries into formatted alerts and pre-configured dashboard links.

## Responsibilities

**Owns:**
- Publishing alert messages to ChatOps platforms and incident management systems.
- Generating deterministic deep-links to Grafana views scoped to the incident's service, environment, and timeframe.
- Including compliance metadata markers in alerts when required by the active policy profile.
- Ensuring idempotent delivery: no duplicate alerts for the same workflow summary.

**Does not own:**
- RCA synthesis or recommendation generation (owned by workflow-orchestration).
- Dashboard query logic or data (owned by Grafana over storage-and-state data).
- Agent feedback payloads (owned by agent-gateway-and-curated-feedback).

## Internal structure

| Component | Responsibility |
|---|---|
| `Notification consumer` | Reads final investigation summaries from the Kafka notification topic |
| `Alert formatter` | Renders structured RCA summaries into platform-specific alert formats |
| `Deep-link generator` | Constructs deterministic Grafana URLs with pre-applied filters from alert context |
| `Delivery adapter` | Sends formatted alerts to target platforms (Slack, Mattermost, PagerDuty, ServiceNow) |
| `Idempotency store` | Tracks delivered `workflow_id` keys to prevent duplicate notifications |
| `Compliance marker injector` | Appends compliance context block to alerts when policy profile requires it |

## Key flows

### Happy path: alert delivery

1. `Notification consumer` reads a final investigation summary from Kafka.
2. `Idempotency store` checks `workflow_id` — not previously delivered.
3. `Deep-link generator` constructs Grafana URL with `service`, `environment`, `anomaly_id`, and timeframe pre-applied.
4. `Compliance marker injector` checks the policy profile; appends compliance context block if required.
5. `Alert formatter` renders the full alert payload.
6. `Delivery adapter` sends to configured target platforms.
7. `Idempotency store` records `workflow_id` as delivered.

### Duplicate delivery attempt

1. `Notification consumer` reads a summary whose `workflow_id` was already delivered.
2. `Idempotency store` returns a match; delivery is skipped.
3. No alert is sent; no duplicate metric is incremented.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| Kafka notification topic | Kafka | Final RCA investigation summaries |
| Policy profile store | Internal lookup | Compliance marker requirements |

### Publishes

| Destination | Protocol | Payload |
|---|---|---|
| ChatOps platforms (Slack, Mattermost) | Webhook/API | Formatted alert message |
| Incident platforms (PagerDuty, ServiceNow) | API | Structured incident payload |
| Grafana | Deep-link URL | Pre-filtered dashboard URL (included in alert payload) |

Alert payload structure:
- Incident title, severity, and impact scope.
- Probable cause and confidence score.
- Top evidence bullets.
- Recommended next actions and runbook links.
- Grafana deep-link.
- Correlation IDs: `anomaly_id`, `workflow_id`, `audit_id`.
- Compliance context block (data classification, policy profile, residency zone) — when policy requires it.

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| Delivery to target platform fails (transient) | Retry with exponential backoff; dead-letter entry created after retry budget exhausted |
| Deep-link generation fails | Alert delivered without dashboard link; link generation error logged |
| Kafka consumer lag | Backpressure; alert latency increases; SLO monitoring triggers operational alert |
| Idempotency store unavailable | Delivery proceeds with risk of duplicate; operational alert raised |

## Non-functional constraints

- Idempotent notification keys prevent duplicate alerts for the same workflow.
- Deep-links are stable and shareable — URLs must remain resolvable for the duration of the telemetry retention window.
- Compliance context block must never contain patient-identifying fields.

## Known limitations

- Deep-link validity depends on Grafana dashboard templates remaining in sync with the data model. Stale templates produce links that open but may show incorrect filters.
