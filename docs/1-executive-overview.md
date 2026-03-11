# Executive Overview

## Observe - Engage - Govern

The AIOps Platform is a sovereign, open-source-first observability and incident intelligence control plane that runs fully in customer-owned data centers. It detects anomalies, orchestrates AI-assisted root-cause analysis (RCA), and delivers actionable alerts while keeping data, operations, and policy control inside the organization boundary.

Phase 1 focuses on **Observe + Engage**. Autonomous remediation is intentionally out of scope.

## What the product does

- Centralizes logs, metrics, traces, and events from multiple clusters/environments into one sovereign control plane.
- Uses hybrid anomaly detection (statistical + rule-based), with LLMs as explainers and correlators.
- Runs a deterministic agent pipeline to produce RCA, confidence scores, and recommended actions.
- Notifies teams in collaboration channels with deep-links to Grafana dashboards for rapid triage.

## Who it is for

- **Platform/SRE teams** operating shared observability, incident workflows, and reliability policies.
- **Product engineering teams** owning service instrumentation, release quality, and incident response.
- **Security and compliance teams** requiring data residency, auditability, and policy enforcement.
- **Agentic clients and software agents** acting on behalf of users for investigation, summarization, and workflow automation under policy constraints.
- **Open-source contributors** extending detectors, orchestration logic, and integrations.

## Product tenets

- **Sovereignty first**: data and control remain in your environment.
- **Open-source first**: avoid hard lock-in to proprietary managed services.
- **Deterministic first**: LLMs support explanation, not core detection truth.
- **Evidence over intuition**: every conclusion includes traceable signals and confidence.
- **Human-in-the-loop**: no autonomous production changes in Phase 1.
- **OpenTelemetry standard**: platform and services use OTel for consistent telemetry semantics.
- **Healthcare compliance by design**: Phase 1 includes Dutch healthcare baseline controls (NEN 7510, NEN 7513 logging, AVG Art. 9 safeguards, DPIA workflows, and AI transparency/human oversight).

## Core outcomes

- Faster triage with high-context alerts and pre-investigated incidents.
- Reduced alert fatigue through deduplication, suppression, and correlation.
- Lower MTTR through evidence-linked recommendations and runbook mapping.
- Auditable incident reasoning and AI usage with policy controls.
- Compliance support for strict data residency and governance needs.
- Healthcare readiness from day one for Dutch provider procurement and audits.

## Dutch healthcare compliance baseline (Phase 1)

- NEN 7510-aligned security and operational controls for environments handling patient-related data.
- NEN 7513-compliant audit logging patterns for access and action traceability.
- AVG/GDPR Art. 9 handling guardrails, including processor agreement support and DPIA-required workflows.
- EU/EER data residency defaults; no uncontrolled transfer of sensitive healthcare data.
- Human oversight and transparency controls for AI-assisted outputs, aligned with Dutch AP expectations and EU AI Act limited-risk obligations.
- NEN 7512 and MedMij requirements treated as scope-dependent extensions when healthcare data exchange roles require them.

## Example RCA alert message

```
🚨 AIOps Alert: High latency anomaly detected
Service: payments-api | Env: prod | Cluster: dc1-prod-01 | Region: eu-central
Probable root cause (83% confidence): Release 2.8.4 introduced a slower SQL path,
raising p95 latency from 180ms baseline to 740ms over the last 14 minutes.
Evidence: spike started 4 minutes after rollout; DB query duration +210%;
error rate stable, indicating regression rather than service outage.

Recommended steps:
1) Roll back payments-api to 2.8.3 (or disable feature flag `new-routing`).
2) Run EXPLAIN ANALYZE for top 3 slowest `invoice` queries.
3) Temporarily increase DB read pool and monitor connection saturation.
4) Track p95 and queue depth on the linked Grafana dashboard for 15 minutes.
```

## Scope summary

### In scope (Phase 1)

- Multi-cluster/environment ingestion and normalization
- Hybrid anomaly detection
- Agentic RCA and recommendation workflow
- Collaboration channel alerts with Grafana deep-links
- Policy-driven configuration via GitOps/IaC

### Out of scope (Phase 1)

- Autonomous remediation and change execution
- Full APM suite replacement
- Cross-organization multi-tenant SaaS operations

## Document map

- [2-product-requirements.md](2-product-requirements.md)
- [3-product-design.md](3-product-design.md)
- [4-technical-architecture.md](4-technical-architecture.md)
