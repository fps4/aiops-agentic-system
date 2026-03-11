# Product Requirements

## Problem statement

Platform and SRE teams running self-managed environments spend too much time on noisy alerts, fragmented tooling, and manual cross-system correlation. The product must detect meaningful anomalies and deliver investigation-ready context before human responders engage.

## Primary users

### Platform/SRE teams

Responsibilities:
- Define and tune detection/suppression policies.
- Operate platform infrastructure and reliability guardrails.
- Respond to proactive anomaly alerts and coordinate incident response.
- Improve RCA quality through feedback and policy iteration.

Goals:
- Reduce MTTR.
- Improve signal-to-noise ratio.
- Maintain shared visibility across clusters, environments, and services.

### Product engineering teams

Responsibilities:
- Instrument owned services with OpenTelemetry and propagate trace context.
- Triage service alerts with platform/SRE partners.
- Validate probable root causes against recent app/config changes.
- Execute or coordinate service-level remediation and rollback decisions.

Goals:
- Detect regressions earlier.
- Reduce time to validate or reject RCA hypotheses.
- Improve release confidence with production feedback loops.

### Security and compliance teams

Responsibilities:
- Define data handling, redaction, and retention policy constraints.
- Validate access controls, audit trails, and data residency posture.
- Review AI usage boundaries and approved model endpoints.

Goals:
- Keep incident intelligence compliant with sovereignty requirements.
- Ensure auditable, policy-aligned operations.

### Agentic clients and software agents

Responsibilities:
- Consume scoped platform context to assist operators and service teams with triage and investigation tasks.
- Execute bounded, policy-approved actions such as evidence retrieval, report generation, and ticket enrichment.
- Support AI-assisted coding workflows where user prompts are translated into code changes and deployments to shared infrastructure.
- Consume curated operational feedback from the platform and either take permitted follow-up actions autonomously or request user confirmation.
- Respect identity, authorization, audit, and data-handling policies enforced by the platform.
- Surface transparent reasoning, confidence, and source links for every generated recommendation.

Goals:
- Reduce manual toil for ordinary users without bypassing human approval boundaries.
- Enable reusable agentic workflows across teams and tools.
- Integrate safely with existing user-facing agentic clients over standard protocols.

## Functional requirements

### FR-1 Multi-environment ingestion

- Ingest logs, metrics, traces, and events from multiple clusters/environments.
- Normalize to a canonical schema including cluster, namespace, service, environment, deployment metadata, and ownership tags.
- Preserve raw records for replay, audit, and backfill workflows.

### FR-2 Hybrid anomaly detection

- Support statistical detection (seasonality-aware baseline, changepoint, z-score/EWMA patterns).
- Support rule-based guardrails (error rate, latency, traffic, saturation, security events).
- Produce structured anomaly objects with baseline, deviation, severity, confidence, and evidence pointers.

### FR-3 Agentic investigation workflow

- Trigger a deterministic, replayable pipeline:
  - Detection validation
  - Signal correlation
  - Historical comparison
  - RCA synthesis
  - Recommendation generation
- Persist evidence chain and confidence scoring per workflow stage.

### FR-4 Alerting and investigation handoff

- Deliver proactive alerts to collaboration channels and incident systems.
- Include what changed, likely cause, confidence, and recommended actions.
- Include deep-links to pre-filtered Grafana dashboards and runbooks.

### FR-5 Policy-driven operations

- Configure detection, suppression, routing, escalation, and model/provider selection using version-controlled policy files.
- Support per-service/per-environment scoping, maintenance windows, and cooldown controls.
- Require audited change flow via pull request and approval policies.

### FR-6 AI provider abstraction

- Provide a unified interface for per-agent model/provider selection.
- Support both self-hosted and approved external providers.
- Capture prompt/response metadata, token/cost estimates, and policy compliance attributes.

### FR-7 Telemetry instrumentation standard

- Require OpenTelemetry instrumentation for platform components and onboarded services.
- Propagate trace context and operational identifiers (`anomaly_id`, `workflow_id`, `service`, `environment`).
- Support common open-source telemetry pipelines and collectors.

### FR-8 Dutch healthcare compliance controls

- Implement NEN 7510-aligned controls across identity/access management, encryption, incident handling, and operational security procedures for healthcare workloads.
- Implement NEN 7513-aligned access logging and auditability for patient-related data interactions where such data is in scope.
- Support NEN 7512-aligned trust controls for electronic healthcare data exchange when exchange roles are activated.
- Enforce AVG/GDPR safeguards for special category data (Art. 9), including processor agreement integration and data minimization by default.
- Require DPIA workflow support for new processing activities involving patient-related datasets or AI processing paths.

### FR-9 AI governance and regulatory guardrails

- Keep Phase 1 use cases in administrative/operational AI support scope; no autonomous clinical decisioning.
- Provide transparent AI output provenance (model identity, prompt class, confidence, evidence links).
- Enforce human approval checkpoints for any recommendation that can affect production operations or patient-related data flows.
- Maintain policy-controlled routing so sensitive workloads use self-hosted or approved EU-jurisdiction model endpoints.

### FR-10 Agent integration interface

- Expose a secure, policy-aware interface for external and embedded software agents to access platform capabilities.
- Support MCP-compatible tool/resource contracts for agentic clients used by ordinary users.
- Enforce per-agent identity, scoped permissions, rate limits, and action allowlists.
- Ensure all agent requests and responses are traceable through the same audit model as human actions.
- Provide a curated operational feedback contract for deployed workloads (health deltas, anomaly summaries, release impact signals, recommended next actions).
- Mark each recommended action as either policy-allowed autonomous execution or user-confirmation-required.

## Regulatory baseline (Netherlands healthcare)

- **NEN 7510** is a go-to-market and procurement gate for healthcare environments handling patient-related data.
- **NEN 7513** audit logging expectations are treated as mandatory design constraints for relevant workflows.
- **AVG/GDPR** obligations apply to patient data as special category data; DPIA support is required.
- **EU AI Act** transparency and human oversight obligations are built into Phase 1 AI workflow design.
- **NEN 7512 / MedMij** are included as conditional requirements when platform scope includes regulated healthcare exchange roles.

## Non-functional requirements

### Performance

- Alert latency from detection to notification should be near real time for operational response (target P95 within a few minutes).
- Dashboard deep-links must open with pre-applied filters and usable load times under incident pressure.

### Reliability

- Retry transient failures in ingestion, workflow, and notification stages.
- Use durable buffering and dead-letter handling to avoid silent data loss.
- Support graceful degradation when downstream components are partially unavailable.

### Security and privacy

- Enforce least-privilege access and tenant/namespace boundaries.
- Redact or block sensitive fields before any external model invocation.
- Maintain full audit trails for detection outputs, prompts, recommendations, and operator actions.
- Default to EU/EER data residency controls for healthcare deployments.
- Provide evidence packages for audits (access logs, policy changes, DPIA traces, incident response records).

### Scalability

- Scale to high-cardinality telemetry and concurrent anomaly bursts.
- Avoid alert storms via deduplication and suppression semantics.
- Support horizontal scaling of ingestion, query, and orchestration layers.

### Operability

- Ship health metrics and self-observability for all core components.
- Support safe upgrades, rollbacks, and policy validation gates.
- Provide clear failure visibility and actionable runbooks.
- Make compliance controls operable: auditable policy-as-code, immutable logging paths, and verification checklists for NEN 7510/7513 readiness.

### Cost and capacity governance

- Enforce AI and storage usage budgets by environment and team.
- Support retention tiers and lifecycle controls for telemetry and audit data.
- Surface capacity utilization to prevent performance cliffs.

## Success metrics

- MTTR reduction relative to baseline.
- False-positive reduction and alert quality improvements.
- RCA usefulness/accuracy based on responder feedback.
- Adoption by on-call engineers and service owners.
- Policy compliance pass rate for incident and AI governance controls.
- Audit readiness score for Dutch healthcare baseline controls.

## Explicit non-goals

- Autonomous remediation in Phase 1.
- Building a proprietary hosted SaaS control plane.
- Replacing all existing observability and APM tools in one release.
- Entering high-risk clinical AI classification in Phase 1.
