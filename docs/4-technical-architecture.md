# Technical Architecture

## Architecture summary

The platform implements a sovereign control plane inside customer-owned data centers. It ingests telemetry from clusters and infrastructure systems, stores normalized data, runs hybrid anomaly detection, executes deterministic agentic RCA workflows, and emits actionable alerts linked to Grafana evidence views.

## Design principles

- Sovereign deployment in organization-controlled environments.
- Open-source-first building blocks with pluggable components.
- Deterministic orchestration and auditable decisions.
- AI provider abstraction with strict policy controls.
- Modular services with clear interfaces and failure boundaries.
- Compliance-by-design for Dutch healthcare workloads from Phase 1.

## High-level flow

```
Workloads + Infrastructure
  -> OpenTelemetry Collectors / Exporters
  -> Message bus (Kafka default; ADR 001)
  -> Normalization and enrichment processors
  -> Raw/object storage + analytics store (ClickHouse primary; ADR 002)
  -> Detection layer (statistical + rule-based)
  -> Incident/anomaly state store + event stream (PostgreSQL + Redis; ADR 004)
  -> Orchestration engine (Temporal default; ADR 003)
  -> Alert delivery + Grafana deep-link generation
```

## Runtime components

### Data plane

- **Collection**: OpenTelemetry Collectors and log shippers gather signals from services, Kubernetes, and infra systems.
- **Ingestion bus**: Kafka is the default for durable buffering and replay (ADR 001).
- **Normalization**: stream processors map records to canonical schema and enrich with ownership/deployment context.
- **Storage**:
  - Object storage (S3-compatible/MinIO/Ceph) for immutable raw records.
  - Analytics store: ClickHouse as primary; OpenSearch as optional secondary for full-text exploration (ADR 002).
  - State store: PostgreSQL as system of record plus Redis for ephemeral coordination state (ADR 004).

### Detection plane

- **Statistical detector**: scheduled or streaming workers evaluate baseline deviations and changepoints.
- **Rule-based detector**: deterministic guardrails for thresholds, error budgets, and security patterns.
- **Output contract**: structured anomaly events with severity, confidence, and evidence references.

### Orchestration plane

- **Trigger**: anomaly event stream.
- **Engine**: Temporal is the default deterministic orchestrator for RCA workflows (ADR 003).
- **Agent sequence**:
  - Detection validation
  - Correlation
  - Historical comparison
  - RCA synthesis
  - Recommendation generation
- **Auditability**: stage-by-stage state, inputs, outputs, and model metadata persisted for replay.

### Presentation plane

- **Notifications**: ChatOps/incident integrations (e.g., Slack, Mattermost, PagerDuty, ServiceNow).
- **Visual analytics**: Grafana dashboards over analytics stores.
- **Investigation UX**: deep-links with pre-applied filters (service, environment, timeframe, anomaly/workflow IDs).

### Agent interface plane

- **Agent gateway**: authenticated endpoint for software agents and agentic clients.
- **Protocol direction**: MCP-compatible tool/resource interfaces for investigation and workflow tasks.
- **Policy enforcement**: per-agent authorization, tool allowlists, response filtering, and rate limits.
- **Traceability**: each agent action is correlated to user/session identity and audit trail IDs.
- **Curated feedback service**: deployment-scoped feedback payloads for agents (health regressions, anomaly summaries, confidence, and policy-tagged next actions).

### Telemetry and control plane observability

- **Instrumentation standard**: OpenTelemetry for all platform services.
- **Platform SLOs**: ingestion lag, detector latency, orchestration duration, notification success rate.
- **Control signals**: policy changes, deploy events, and feedback events flow through auditable streams.

### Compliance and governance plane

- **Policy engine**: policy-as-code profiles enforce healthcare controls (access, masking, residency, model routing).
- **Audit trail**: immutable, queryable logs for access, policy changes, workflow execution, and recommendation approvals.
- **Data classification**: telemetry and workflow records tagged for sensitivity class and retention obligations.
- **DPIA support**: processing inventories and decision evidence exported for governance review.
- **Healthcare profiles**: Dutch baseline profile encodes NEN 7510/NEN 7513 expectations and AVG safeguards.

## AI provider architecture

- Unified adapter interface for model invocation by agent type.
- Primary mode is self-hosted model endpoints within sovereign boundary.
- Optional external providers are policy-gated with redaction, allowlists, and egress controls.
- Per-agent model parameters and budget limits are centrally managed and auditable.

## Security and governance architecture

- Identity and access integration with enterprise IdP (OIDC/SAML).
- Secrets and key management via vault systems and hardware-backed controls where available.
- Network segmentation and egress restrictions for sensitive workloads.
- Data classification tags drive retention, masking, and model-routing policy.
- EU/EER residency enforcement controls for patient-related datasets and AI processing paths.
- NEN 7513-aligned logging retention and tamper-evidence mechanisms for relevant data-access events.

## Configuration and deployment

- Kubernetes-first runtime packaging (Helm/Kustomize/Terraform-supported flows).
- GitOps delivery model for policies and service configuration.
- Environment overlays for dev/staging/prod and data-center-specific constraints.
- Safe rollout patterns: canary, feature flags, and rollback automation hooks.
- Compliance profile bundles (default, strict healthcare NL) validated in CI before rollout.

## Dutch healthcare compliance mapping

- **NEN 7510**: covered through security architecture, access controls, incident procedures, and auditable operations.
- **NEN 7513**: covered through immutable access/action logs and retention controls for patient-related scope.
- **AVG/GDPR Art. 9**: covered via minimization, masking/redaction, residency controls, and processor governance.
- **DPIA obligations**: supported through processing inventories and evidence export.
- **EU AI Act (limited-risk context)**: covered through transparency metadata and mandatory human oversight checkpoints.
- **NEN 7512 / MedMij**: modeled as optional extension modules for regulated healthcare data exchange scenarios.

## End-to-end incident flow example

**Scenario**: checkout latency spike caused by a slow query path introduced in a new release.

1. **Collection (T+0s)**: logs, metrics, traces stream through OTel collectors into the message bus.
2. **Normalization (T+5s)**: processors enrich telemetry and write to raw object storage and analytics indexes.
3. **Detection (sub-minute to few-minute cadence)**: baseline comparison flags p95 jump and emits anomaly event.
4. **Orchestration (T+30s to T+2min)**:
   - validates signal quality and deduplicates duplicates
   - correlates with release and database saturation metrics
   - compares similar historical incidents
   - produces RCA hypothesis with confidence
   - maps recommended actions to service runbooks
5. **Notification (T+2min)**: collaboration alert is sent with evidence summary and Grafana deep-link.
6. **Investigation (T+3min)**: responder validates findings and executes approved mitigation.

Typical latency from anomaly formation to actionable alert should remain within operational response targets.

## Component deep dives

- [components/01-telemetry-ingestion.md](components/01-telemetry-ingestion.md)
- [components/02-normalization-and-enrichment.md](components/02-normalization-and-enrichment.md)
- [components/03-storage-and-state.md](components/03-storage-and-state.md)
- [components/04-anomaly-detection.md](components/04-anomaly-detection.md)
- [components/05-workflow-orchestration.md](components/05-workflow-orchestration.md)
- [components/06-agent-gateway-and-curated-feedback.md](components/06-agent-gateway-and-curated-feedback.md)
- [components/07-notifications-and-dashboards.md](components/07-notifications-and-dashboards.md)
- [components/08-compliance-and-governance-plane.md](components/08-compliance-and-governance-plane.md)
- [components/09-operations-and-slo.md](components/09-operations-and-slo.md)

## Decision references

- [decisions/001-message-bus-kafka-over-nats-jetstream.md](decisions/001-message-bus-kafka-over-nats-jetstream.md)
- [decisions/002-analytics-store-clickhouse-primary-opensearch-secondary.md](decisions/002-analytics-store-clickhouse-primary-opensearch-secondary.md)
- [decisions/003-orchestration-engine-temporal-over-argo.md](decisions/003-orchestration-engine-temporal-over-argo.md)
- [decisions/004-state-store-postgresql-plus-redis-over-single-kv.md](decisions/004-state-store-postgresql-plus-redis-over-single-kv.md)

## Implementation artifacts

- [5-implementation-readiness.md](5-implementation-readiness.md)
- [contracts/openapi.yaml](contracts/openapi.yaml)
- [schemas/README.md](schemas/README.md)
- [6-repository-bootstrap.md](6-repository-bootstrap.md)
- [7-testing-strategy.md](7-testing-strategy.md)
- [8-compliance-evidence-plan.md](8-compliance-evidence-plan.md)
