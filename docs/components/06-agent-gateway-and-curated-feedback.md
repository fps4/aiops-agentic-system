# Component 06: Agent Gateway and Curated Feedback

## Purpose

Provide a secure, policy-aware interface for agentic clients and software agents, including curated operational feedback for build/deploy loops.

## Interface direction

- MCP-compatible tool/resource contracts for agent clients.
- Authentication bound to user identity plus agent identity.
- Per-agent capability and action policies.

## Responsibilities

- Expose investigation, summary, and deployment-feedback tools.
- Return curated feedback payloads after deployments:
  - health deltas
  - anomaly summaries
  - confidence and risk markers
  - recommended next actions with execution policy tags
- Mark actions as:
  - `auto_allowed` (policy-permitted autonomous follow-up)
  - `approval_required` (explicit user confirmation needed)

## Core tools (initial direction)

- `get_deployment_feedback`
- `get_anomaly_summary`
- `get_service_risk_snapshot`
- `propose_next_actions`
- `submit_user_approval`

## Security and governance

- Request/response logging tied to audit IDs.
- Output filtering by data classification and tenancy scope.
- Rate limiting and abuse controls per agent client.
- Deny-by-default for destructive or high-impact operations.

## UX integration

- Optimized for ordinary users with AI-assisted coding clients.
- Supports closed-loop iteration: prompt -> code -> deploy -> feedback -> next action.
