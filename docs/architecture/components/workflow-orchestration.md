---
title: "Component design: Workflow Orchestration"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: workflow-orchestration
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/decisions/0003-orchestration-engine-temporal-over-argo.md
  - docs/architecture/decisions/0004-state-store-postgresql-plus-redis-over-single-kv.md
---

## Purpose

Run deterministic, replayable RCA workflows from anomaly trigger to recommendation output. This is the intelligence layer of the platform — it turns a structured anomaly event into an evidence-backed RCA summary with confidence score and recommended actions.

## Responsibilities

**Owns:**
- Managing the full lifecycle of RCA workflows: trigger, execution, retries, timeouts, and completion.
- Persisting stage-level inputs, outputs, confidence progression, and model metadata for auditability.
- Enforcing policy gates before sensitive actions or recommendations.
- Publishing final investigation summaries to the notification and agent feedback channels.

**Does not own:**
- Alert delivery to operators (owned by notifications-and-dashboards).
- Agent interface and feedback API (owned by agent-gateway-and-curated-feedback).
- Storage of workflow history and state (owned by storage-and-state, referenced via Temporal).

## Internal structure

| Component | Responsibility |
|---|---|
| `Workflow trigger consumer` | Reads anomaly events from the Kafka trigger stream and starts Temporal workflows |
| `RCA workflow definition` | Deterministic Temporal workflow code; versioned for replay compatibility |
| `Detection validation worker` | Confirms signal quality and deduplicates against open anomalies |
| `Correlation worker` | Correlates service, infrastructure, deployment, and ownership context |
| `Historical comparison worker` | Compares against similar past incidents and recent release/config changes |
| `RCA synthesis worker` | Invokes LLM adapter to generate probable root cause with confidence and evidence |
| `Recommendation worker` | Maps RCA hypothesis to recommended actions and runbook references |
| `Policy gate` | Enforces approval requirements before any sensitive output is published |

## Key flows

### Happy path: RCA workflow execution

1. `Workflow trigger consumer` reads an anomaly event from Kafka and starts a Temporal workflow keyed by `anomaly_id`.
2. `Detection validation worker` confirms signal quality; deduplicates against any already-open anomaly for the same scope.
3. `Correlation worker` pulls service catalog, recent deployment events, and infrastructure context.
4. `Historical comparison worker` queries ClickHouse for similar past incidents and recent baseline shifts.
5. `RCA synthesis worker` invokes the LLM adapter with structured evidence; receives RCA hypothesis with confidence.
6. `Recommendation worker` maps the hypothesis to ranked recommended actions and runbook links.
7. `Policy gate` checks whether the output contains sensitive scope requiring human approval.
8. Final investigation summary is published to the notification topic and the agent feedback channel.
9. Stage-level metadata (inputs, outputs, model ID, confidence) is persisted in PostgreSQL.

### Human approval gate

1. `Policy gate` determines that the recommendation affects healthcare-sensitive scope or a production action.
2. Workflow transitions to `waiting_approval` state.
3. Notification is sent requesting operator approval with full context.
4. On approval: workflow resumes from `waiting_approval`; approval event is logged with actor identity and timestamp.
5. On rejection or timeout: workflow transitions to `cancelled`; reason is logged.

### Worker failure

1. A task worker fails during a workflow stage.
2. Temporal retries the activity with configured backoff and maximum attempts.
3. If the activity exceeds retry budget: workflow moves to `failed`; full trace context is preserved; manual review queue entry is created.
4. Platform SLO alert is emitted if workflow duration exceeds the SLA threshold.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| Kafka workflow trigger stream | Kafka | Anomaly events |
| ClickHouse | Query | Historical incident data, baseline comparisons |
| Service catalog | Internal API | Ownership, runbook references |
| Deployment event store | Query | Recent releases and config changes |
| LLM adapter | HTTP/gRPC | RCA synthesis and recommendation generation |

### Publishes

| Destination | Protocol | Data |
|---|---|---|
| Notification topic | Kafka | Final investigation summary |
| Agent feedback channel | Internal API | Curated feedback payload for agent gateway |
| PostgreSQL | Direct write | Workflow state, stage metadata, approvals |

## State model

| State | Meaning | Valid transitions |
|---|---|---|
| `queued` | Workflow created, not yet started by Temporal | → `running` |
| `running` | Active stage execution | → `waiting_approval`, `completed`, `failed`, `cancelled` |
| `waiting_approval` | Paused pending human or policy approval | → `running`, `cancelled` |
| `completed` | All stages finished; summary published | terminal |
| `failed` | Unrecoverable stage error | terminal |
| `cancelled` | Policy-cancelled or operator-rejected | terminal |

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| Task worker crash (transient) | Temporal retries with exponential backoff up to configured limit |
| Worker retry budget exhausted | Workflow moves to `failed`; manual review entry created with full trace |
| LLM adapter timeout or error | RCA synthesis retried; on persistent failure, workflow completes with partial output and low confidence |
| Policy gate unavailable | Workflow pauses; approval-required actions blocked until policy gate recovers |
| Workflow SLA breach | Platform operational alert emitted |

## Non-functional constraints

- One workflow per `anomaly_id` and scope — no parallel duplicate workflows for the same anomaly.
- Workflow code is deterministic and explicitly versioned for Temporal replay compatibility.
- All model invocations log: model ID, prompt class, token count estimate, and policy compliance attributes.
- Approval events are stored with actor identity (user + agent) and timestamp for NEN 7513 compliance.

## Assumptions and constraints

- Temporal is available as the orchestration engine (ADR 0003).
- LLM adapter endpoints are self-hosted or policy-approved external providers; no ad-hoc model calls.
- Workflow history IDs are correlated with PostgreSQL records via `workflow_id` for cross-system traceability.
