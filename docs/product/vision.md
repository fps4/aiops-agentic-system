---
title: Product vision — AIOps Agentic System
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/product/design.md
  - docs/architecture/overview.md
---

## Problem

Platform and SRE teams running self-managed infrastructure spend too much time on noisy alerts, fragmented tooling, and manual cross-system correlation. When an incident occurs, responders must piece together evidence from separate dashboards, logs, and deployment records before they can form a hypothesis — losing critical minutes to setup rather than investigation. Existing observability tools surface data but do not deliver conclusions.

For organizations in regulated sectors such as Dutch healthcare, the problem compounds: incident intelligence must never leave the organization boundary, data handling must be auditable to NEN 7510/7513 and AVG/GDPR standards, and AI-assisted tooling must maintain transparent human oversight.

## Users

**Primary — Platform/SRE teams**: operate shared infrastructure and reliability policies across multiple clusters and environments. Responsible for incident response, detection tuning, and cross-service coordination.

**Primary — Product engineering teams**: own individual services, instrument them, and respond to service-specific alerts. Need fast validation or rejection of RCA hypotheses against recent code and config changes.

**Secondary — Security and compliance teams**: define data handling, retention, and redaction policy. Require auditable evidence of access controls, AI usage boundaries, and data residency posture.

**Secondary — Agentic clients and software agents**: act on behalf of engineers for investigation, report generation, and approved workflow automation. Require a policy-enforced interface with curated operational feedback after deployments.

## Goals

- On-call responders receive a pre-investigated incident summary — probable cause, confidence score, recommended actions, and affected dependency scope — before they open a dashboard.
- Alert fatigue decreases: deduplication, suppression, and correlation reduce noise for platform teams.
- MTTR falls for incidents where root cause is detectable from telemetry and deployment history.
- All incident reasoning and AI usage is auditable and traceable to source evidence.
- The platform is deployable in Dutch healthcare environments from Phase 1, satisfying NEN 7510/7513 and AVG/GDPR baseline controls without customization.

## Non-goals

- Autonomous remediation: no production changes are executed without human approval in Phase 1.
- Full APM suite replacement: the platform complements existing observability tools rather than replacing them.
- Cross-organization multi-tenant SaaS: the platform is single-tenant and runs in the customer's own data center.
- Clinical AI decisioning: Phase 1 scope is administrative and operational AI support only; no high-risk AI classification under the EU AI Act.

## Success metrics

**Leading indicators (behaviour):**
- Percentage of on-call engineers who engage with the pre-investigated summary before opening raw dashboards.
- Reduction in time-to-first-hypothesis (from alert received to RCA hypothesis formed).
- Operator feedback rating on RCA usefulness and recommendation accuracy.

**Lagging indicators (outcome):**
- MTTR reduction relative to pre-platform baseline.
- False-positive rate reduction in production alerts.
- Audit readiness score for Dutch healthcare baseline controls (NEN 7510/7513 readiness checklist pass rate).
- Policy compliance pass rate for incident and AI governance controls.
