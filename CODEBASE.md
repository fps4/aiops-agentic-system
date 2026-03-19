# Codebase overview

The AIOps Agentic System is a sovereign, open-source-first observability and incident intelligence control plane that runs in customer-owned data centers. It detects anomalies, orchestrates AI-assisted root-cause analysis, and delivers actionable alerts while keeping all data, operations, and policy control inside the organization boundary.

## Directory map

| Path | Purpose |
|------|---------|
| `services/ingestion/` | OpenTelemetry-based telemetry collection and Kafka publishing |
| `services/normalization/` | Stream processors that canonicalize and enrich raw telemetry |
| `services/detection/` | Statistical and rule-based anomaly detectors |
| `services/orchestration/` | Temporal-backed RCA workflow engine |
| `services/agent-gateway/` | MCP-compatible interface for agentic clients |
| `services/notifications/` | Alert delivery to ChatOps and incident platforms |
| `libs/contracts/` | Shared JSON schemas and OpenAPI spec |
| `libs/policy-engine/` | Policy-as-code evaluation and enforcement |
| `libs/observability/` | Shared OTel instrumentation helpers |
| `deploy/helm/` | Helm charts for Kubernetes deployment |
| `deploy/kustomize/` | Kustomize overlays for environment-specific config |
| `infra/terraform/` | Terraform modules for infrastructure provisioning |
| `docs/` | Human and agent documentation |

## Entry points

- Telemetry ingestion: `services/ingestion/`
- Anomaly detection: `services/detection/`
- RCA workflow trigger: `services/orchestration/`
- Agent interface: `services/agent-gateway/`

## Naming notes

- "anomaly" in the domain maps to a structured detection event with confidence, severity, and evidence references — not a raw alert
- "workflow" refers to a Temporal-backed RCA investigation pipeline, not a generic automation
- "policy profile" is a versioned YAML artifact that controls detection, suppression, model routing, and compliance behaviour per environment
- "curated feedback" is the deployment-scoped operational summary returned to agentic clients after a deploy event
- "sovereign" means the full platform runs in the customer's own data center with no dependency on external managed services

## Key configuration

- Policy profiles live in `deploy/` and are loaded at runtime via GitOps
- Environment overlays: `deploy/kustomize/overlays/{dev,staging,prod}`
- Healthcare compliance profile: `deploy/policies/strict-healthcare-nl.yaml`
