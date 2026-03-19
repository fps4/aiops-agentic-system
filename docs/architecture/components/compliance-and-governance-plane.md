---
title: "Component design: Compliance and Governance Plane"
status: draft
last_updated: 2026-03-19
owners: [platform-team, security-team]
c4_level: component
container: compliance-and-governance-plane
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/guides/compliance-evidence.md
---

## Purpose

Enforce policy, auditability, and Dutch healthcare baseline controls across all data flows, AI usage, and operator and agent actions. This component is the cross-cutting governance layer — every other component delegates policy evaluation, masking decisions, and audit writing to it.

## Responsibilities

**Owns:**
- Executing policy-as-code profiles: `default` and `strict-healthcare-nl`.
- Enforcing masking, residency controls, model-routing rules, and human approval requirements.
- Maintaining immutable audit trails for access, decisions, and actions.
- Producing DPIA evidence exports and audit packages.
- Managing policy version history and change approvals.

**Does not own:**
- Audit log storage infrastructure (owned by storage-and-state).
- Application of masking in transit (each component applies masking using rules provided by this plane).
- Incident response execution (owned by the responding teams).

## Internal structure

| Component | Responsibility |
|---|---|
| `Policy engine` | Evaluates policy rules against request context; returns allow/deny/approval-required decisions |
| `Profile loader` | Loads and caches policy profiles from Git-backed config; supports live reload |
| `Masking rule registry` | Provides field-level masking rules to normalization and gateway components |
| `Audit writer` | Writes immutable structured audit events to the audit log store |
| `DPIA evidence exporter` | Assembles processing inventory and decision evidence for governance review |
| `Residency controller` | Enforces EU/EER data residency constraints for model routing and egress |

## Key flows

### Policy evaluation: action gating

1. A component (workflow-orchestration, agent-gateway) requests a policy decision for an action.
2. `Policy engine` evaluates the active profile rules against: actor identity, action type, resource scope, and data classification.
3. Returns one of: `allow`, `deny`, or `approval_required`.
4. `Audit writer` records the decision with: `actor_id`, `action`, `resource`, `decision`, `policy_version`, `correlation_id`, `event_time`.

### Audit event write

1. Any platform component emits an audit event (access, recommendation, approval, policy change).
2. `Audit writer` receives the event and writes to the immutable audit log in PostgreSQL.
3. Write is append-only; existing records are never modified or deleted within the retention window.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| Git policy repository | GitOps pull | Policy profile YAML files |
| All platform components | Internal API | Policy evaluation requests, audit event submissions |

### Publishes

| Destination | Protocol | Data |
|---|---|---|
| PostgreSQL audit log | Direct write | Immutable structured audit events |
| DPIA evidence export | File export | Processing inventories and decision evidence packages |

Required audit event fields:
- `audit_id`, `event_time`, `actor_type` (`user`, `agent`, `service`)
- `actor_id`, `action`, `resource`
- `decision` (`allow`, `deny`, `approval_required`)
- `policy_version`, `correlation_id`

## Non-functional constraints

- Audit log is append-only; no update or delete operations within the retention window.
- NEN 7513 retention period applies to all audit events for healthcare-scoped workloads.
- Policy profile changes require pull request approval and are version-tagged on load.
- `residency_zone` is enforced at model-routing time — no sensitive data leaves EU/EER without explicit policy override.

## Known limitations

- Policy evaluation is synchronous on the hot path; high-frequency requests may add latency. Components should cache allow decisions with short TTLs where safe to do so.
- DPIA evidence export is a manual-trigger operation in Phase 1; automated scheduled exports are a post-Phase-1 capability.
