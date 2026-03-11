# Compliance Evidence Plan

## Purpose

Define what evidence must be produced continuously to support Dutch healthcare readiness and internal audits.

## Evidence categories

- Access and authorization logs.
- Policy decision logs and policy version history.
- Workflow execution history (including approvals).
- Data residency and egress control events.
- DPIA-related processing traceability records.

## Required audit fields

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

- Operational logs: short to medium retention.
- Security/audit logs: long retention aligned to policy profile.
- Immutable evidence snapshots for incident postmortems and audits.

## Review cadence

- Monthly evidence quality review.
- Quarterly restore/readiness verification.
- Post-incident audit trail completeness check.
