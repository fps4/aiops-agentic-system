---
title: "0001: AIOps Agentic System — Phase 1"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/product/vision.md
  - docs/product/design.md
  - docs/architecture/overview.md
---

## Summary

Phase 1 delivers a sovereign AIOps control plane for platform and SRE teams running self-managed environments. It addresses the core problem from the [product vision](../vision.md): responders receive noisy, context-free alerts and must manually assemble evidence before forming any hypothesis. Phase 1 closes this gap by pre-investigating anomalies and delivering actionable, evidence-linked summaries before the responder engages.

Dutch healthcare compliance controls are built into Phase 1 from the start — not added as a later overlay.

## Problem statement

Platform teams operating multi-cluster, multi-environment infrastructure lack a system that automatically correlates signals, detects meaningful regressions, and delivers pre-investigated incident context. Alert volume is high, signal quality is low, and manual correlation across tools is slow. For healthcare environments, this problem is compounded by strict data sovereignty, audit, and AI oversight requirements.

## Users and context

**Platform/SRE teams**: when an anomaly fires during an on-call shift, I want a pre-investigated summary with probable cause and recommended actions, so I can triage and respond without first spending time assembling evidence from multiple tools.

**Product engineering teams**: when a regression is detected in my service after a release, I want it correlated with recent deployment and config changes, so I can quickly validate or reject a root cause hypothesis.

**Security and compliance teams**: when the platform processes data under a healthcare policy profile, I want all access, AI usage, and recommendations to be auditable and residency-compliant, so I can satisfy NEN 7510/7513 and AVG obligations.

## Scope

### In scope

- Multi-cluster and multi-environment telemetry ingestion and normalization
- Hybrid anomaly detection (statistical and rule-based)
- Deterministic, replayable agentic RCA workflows
- Collaboration channel alerts with Grafana deep-links
- Policy-driven configuration via GitOps
- MCP-compatible agent gateway with curated deployment feedback
- Dutch healthcare compliance baseline controls (NEN 7510, NEN 7513, AVG/GDPR Art. 9, DPIA workflow support, EU AI Act transparency)

### Out of scope

- Autonomous remediation and production change execution
- Full APM suite replacement
- Cross-organization multi-tenant SaaS operations
- High-risk clinical AI classification (EU AI Act)
- Custom admin UI for policy management

## Requirements

### Functional requirements

**FR-1 Multi-environment ingestion**

1. The platform ingests logs, metrics, traces, and events from multiple clusters and environments.
2. All records are normalized to a canonical schema including cluster, namespace, service, environment, deployment metadata, and ownership tags.
3. Raw records are preserved for replay, audit, and backfill workflows.

**FR-2 Hybrid anomaly detection**

1. The platform supports statistical detection: seasonality-aware baseline, changepoint, z-score, and EWMA patterns.
2. The platform supports rule-based guardrails: error rate, latency, traffic, saturation, and security event thresholds.
3. Every anomaly event includes: baseline value, observed value, delta, severity, confidence score, and evidence references.

**FR-3 Agentic investigation workflow**

1. Anomaly detection triggers a deterministic, replayable investigation pipeline with stages: detection validation, signal correlation, historical comparison, RCA synthesis, recommendation generation.
2. Stage-level inputs, outputs, confidence scores, and model metadata are persisted for audit and replay.
3. The workflow enforces policy gates before any sensitive action or recommendation.

**FR-4 Alerting and investigation handoff**

1. The platform delivers proactive alerts to collaboration channels and incident systems.
2. Each alert includes: what changed, probable cause with confidence, key evidence bullets, recommended actions, and a deep-link to a pre-filtered Grafana dashboard.
3. Alerts include compliance markers when the policy profile requires them.

**FR-5 Policy-driven operations**

1. Detection thresholds, suppression rules, routing, escalation, and model/provider selection are configurable via version-controlled policy files.
2. Policy supports per-service and per-environment scoping, maintenance windows, and cooldown controls.
3. All policy changes require an audited change flow via pull request and approval.

**FR-6 AI provider abstraction**

1. A unified adapter interface supports per-agent model and provider selection.
2. Both self-hosted and approved external providers are supported.
3. Each model invocation captures prompt/response metadata, token and cost estimates, and policy compliance attributes.

**FR-7 Telemetry instrumentation standard**

1. All platform components use OpenTelemetry instrumentation.
2. Trace context and operational identifiers (`anomaly_id`, `workflow_id`, `service`, `environment`) are propagated across all services.

**FR-8 Dutch healthcare compliance controls**

1. The platform implements NEN 7510-aligned controls: identity/access management, encryption, incident handling, and operational security procedures for healthcare workloads.
2. The platform implements NEN 7513-aligned access logging and auditability for patient-related data interactions where in scope.
3. AVG/GDPR safeguards for special category data (Art. 9) are enforced: processor agreement integration, data minimization by default, and EU/EER residency defaults.
4. DPIA workflow support is provided for new processing activities involving patient-related datasets or AI processing paths.

**FR-9 AI governance and regulatory guardrails**

1. Phase 1 use cases remain in administrative and operational AI support scope; no autonomous clinical decisioning.
2. Every AI output includes provenance: model identity, prompt class, confidence score, and evidence links.
3. Human approval checkpoints are enforced for any recommendation that can affect production operations or patient-related data flows.
4. Sensitive workloads route exclusively to self-hosted or approved EU-jurisdiction model endpoints.

**FR-10 Agent integration interface**

1. The platform exposes a secure, policy-aware interface for external and embedded software agents.
2. The interface supports MCP-compatible tool and resource contracts.
3. Per-agent identity, scoped permissions, rate limits, and action allowlists are enforced.
4. All agent requests and responses are traceable through the same audit model as human actions.
5. The platform provides a curated operational feedback contract for deployed workloads: health deltas, anomaly summaries, release impact signals, and recommended next actions tagged as `auto_allowed` or `approval_required`.

### Non-functional requirements

**Performance**: alert latency from detection to notification must target P95 within a few minutes under normal load. Dashboard deep-links must open with pre-applied filters and usable load times.

**Reliability**: transient failures in ingestion, workflow, and notification stages must be retried. Durable buffering and dead-letter handling must prevent silent data loss. The platform must degrade gracefully when downstream components are partially unavailable.

**Security and privacy**: least-privilege access and tenant/namespace boundaries must be enforced. Sensitive fields must be redacted before any external model invocation. Full audit trails must be maintained for detection outputs, prompts, recommendations, and operator actions. EU/EER data residency controls must be default for healthcare deployments.

**Scalability**: the platform must scale to high-cardinality telemetry and concurrent anomaly bursts. Alert storms must be prevented via deduplication and suppression. Ingestion, query, and orchestration layers must support horizontal scaling.

**Operability**: all core components must ship self-observability metrics. Safe upgrade, rollback, and policy validation gates must be supported. Compliance controls must be operable: policy-as-code, immutable logging paths, and NEN 7510/7513 verification checklists.

**Cost governance**: AI and storage usage budgets must be enforceable by environment and team. Retention tiers and lifecycle controls must be supported for telemetry and audit data.

## Open questions

| Question | Owner | Due |
|----------|-------|-----|
| Which ChatOps platforms are in scope for Phase 1 alert delivery? | @platform-team | TBD |
| What is the target retention period for NEN 7513 audit logs? | @security-team | TBD |
| Are NATS JetStream edge deployments in scope for Phase 1 or deferred? | @platform-team | TBD |

## Out of scope — decisions deferred to engineering

- Choice of stream processing framework for normalization workers
- ClickHouse vs OpenSearch query routing implementation details
- Specific Temporal workflow versioning strategy
- Redis cluster topology and sizing
- OpenAPI transport versioning scheme
