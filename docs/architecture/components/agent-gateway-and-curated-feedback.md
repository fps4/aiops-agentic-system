---
title: "Component design: Agent Gateway and Curated Feedback"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: agent-gateway-and-curated-feedback
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/decisions/0004-state-store-postgresql-plus-redis-over-single-kv.md
---

## Purpose

Provide a secure, policy-aware interface for agentic clients and software agents to access platform capabilities, including curated operational feedback for build and deploy loops. This component is the boundary between the platform's internal state and external agents acting on behalf of users.

## Responsibilities

**Owns:**
- Authenticating and authorizing agent requests using user identity plus agent identity.
- Enforcing per-agent capability policies, action allowlists, and rate limits.
- Exposing investigation, summary, and deployment-feedback tools to agent clients.
- Assembling and returning curated feedback payloads scoped to a specific deployment.
- Logging all agent requests and responses tied to audit IDs.
- Filtering output by data classification and tenancy scope.

**Does not own:**
- Anomaly detection or RCA synthesis (owned by their respective components).
- Workflow execution (owned by workflow-orchestration).
- User-facing dashboards or ChatOps alerts (owned by notifications-and-dashboards).

## Internal structure

| Component | Responsibility |
|---|---|
| `Auth middleware` | Validates user + agent identity (OIDC/JWT); enforces per-agent capability policy |
| `Tool router` | Dispatches incoming tool calls to the appropriate internal platform service |
| `Feedback assembler` | Queries normalization, detection, and workflow state to build deployment-scoped feedback payloads |
| `Action policy gate` | Tags each recommended action as `auto_allowed` or `approval_required` based on the active policy profile |
| `Audit logger` | Writes every request and response to the audit trail with actor identity, tool name, and correlation IDs |
| `Output filter` | Strips fields that exceed the requesting agent's data classification clearance |

## Key flows

### Happy path: get deployment feedback

1. Agentic client authenticates with user + agent JWT.
2. `Auth middleware` validates identity and checks that `get_deployment_feedback` is in the agent's allowlist.
3. `Tool router` dispatches to `Feedback assembler`.
4. `Feedback assembler` queries detection state, workflow summaries, and normalization output for the requested `deploymentId`.
5. `Action policy gate` tags each recommended next action as `auto_allowed` or `approval_required`.
6. `Output filter` removes any fields exceeding the agent's classification clearance.
7. Curated feedback payload is returned to the client.
8. `Audit logger` records the request, response summary, actor identity, and correlation IDs.

### Denied tool call

1. Agent calls a tool not in its allowlist (e.g., a destructive operation).
2. `Auth middleware` rejects the request with a deny response.
3. `Audit logger` records the denial with reason.
4. No internal state is accessed.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| PostgreSQL | Query | Anomaly state, workflow summaries, approval records |
| Detection service | Internal API | Latest anomaly summaries for deployment scope |
| Policy profile store | Internal lookup | Agent capability policies, action allowlists, classification rules |
| Enterprise IdP | OIDC/JWT | User and agent identity tokens |

### Synchronous APIs exposed

Initial tool set (MCP-compatible):

| Tool | Description |
|---|---|
| `get_deployment_feedback` | Returns health deltas, anomaly summaries, confidence, and policy-tagged next actions for a deployment |
| `get_anomaly_summary` | Returns the latest RCA summary for a given anomaly ID |
| `get_service_risk_snapshot` | Returns current risk signals for a service |
| `propose_next_actions` | Returns ranked recommended actions for the current platform state |
| `submit_user_approval` | Records an operator approval or rejection for a pending workflow gate |

Full API schema: `docs/api/openapi.yaml`.

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| Invalid or expired JWT | Request rejected with 401; audit log entry written |
| Tool not in agent allowlist | Request rejected with 403; audit log entry written |
| Upstream service unavailable | Returns degraded response with partial data and explicit `degraded: true` flag |
| Rate limit exceeded | Request rejected with 429; rate limit event logged |
| Output filter cannot classify a field | Field omitted from response; incident raised for policy review |

## Non-functional constraints

- Deny-by-default for all destructive or high-impact operations.
- All requests and responses are logged and tied to audit IDs for NEN 7513 compliance.
- Rate limiting enforced per agent client ID.
- Output scoped strictly to the requesting agent's tenancy and classification clearance.

## Assumptions and constraints

- Agent clients use MCP-compatible tool-calling protocol; the gateway does not support arbitrary HTTP patterns.
- Per-agent capability policies are defined in the active policy profile and loaded at gateway startup; live reload is supported.
- The `approval_required` vs `auto_allowed` split is authoritative from the policy profile — the gateway does not make this determination independently.
