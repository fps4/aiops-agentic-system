# Component 08: Compliance and Governance Plane

## Purpose

Enforce policy, auditability, and Dutch healthcare baseline controls across data flow, AI usage, and operator/agent actions.

## Responsibilities

- Execute policy-as-code profiles (default + strict healthcare NL).
- Enforce masking, residency, model-routing, and approval requirements.
- Maintain immutable audit trails for access, decisions, and actions.
- Produce DPIA and audit evidence exports.

## Policy domains

- Access control and least privilege
- Data classification and residency
- AI model/provider allowlists
- Human approval checkpoints
- Retention and deletion policies

## Healthcare baseline mapping

- NEN 7510: security controls, incident process, access governance.
- NEN 7513: access/action logging and retention integrity.
- AVG/GDPR Art. 9: minimization, legal basis, processing traceability.
- EU AI Act (limited-risk context): transparency and oversight records.

## Evidence artifacts

- Policy version history and approvals
- Access decision logs
- Workflow/agent action logs with identity binding
- Residency and egress control events
