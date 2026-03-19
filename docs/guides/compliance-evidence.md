---
title: Compliance evidence plan
status: current
last_updated: 2026-03-19
owners: [platform-team, security-team]
related:
  - docs/architecture/components/compliance-and-governance-plane.md
  - docs/product/prd/0001-aiops-agentic-system.md
---

## Purpose

Define what evidence must be produced continuously to support Dutch healthcare readiness (NEN 7510, NEN 7513, AVG/GDPR) and internal audits. This plan establishes what the platform must generate, how long it must retain it, and how it will be reviewed.

## Evidence categories

| Category | Description |
|---|---|
| Access and authorization logs | Records of who accessed what, when, and with what result |
| Policy decision logs | Each policy evaluation with decision, policy version, and correlation ID |
| Policy version history | All changes to policy profiles with approver identity and timestamp |
| Workflow execution history | Stage-by-stage records including approvals and model invocations |
| Data residency and egress control events | Records of any data touching or crossing residency boundaries |
| DPIA-related processing traceability | Processing activity records for patient-related or high-risk datasets |

## Required audit event fields

Every audit event must include:

- `audit_id`
- `event_time`
- `actor_type` (`user`, `agent`, `service`)
- `actor_id`
- `action`
- `resource`
- `decision` (`allow`, `deny`, `approval_required`)
- `policy_version`
- `correlation_id`

## Retention baseline

| Log type | Retention |
|---|---|
| Operational logs | Short to medium retention (tuned by capacity) |
| Security and audit logs | Long retention aligned to NEN 7513 and active policy profile |
| Immutable compliance snapshots | Retained for the full compliance period; versioned in object storage |
| Redis ephemeral keys | Explicit TTL only; no compliance data stored in Redis |

Exact retention durations are set in the `strict-healthcare-nl` policy profile and reviewed at each profile update.

## Review cadence

- **Monthly**: evidence quality review — audit log completeness, field coverage, and anomaly counts.
- **Quarterly**: restore and readiness verification — confirm audit logs are recoverable and readable.
- **Post-incident**: audit trail completeness check — verify the full evidence chain for the incident is present and correct.
