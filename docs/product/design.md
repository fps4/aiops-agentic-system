---
title: Product design — AIOps Agentic System
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/product/vision.md
  - docs/product/prd/0001-aiops-agentic-system.md
---

## Purpose

Defines the interaction model, user journeys, and UX constraints for the AIOps Agentic System. Translates product requirements into design decisions that govern how the system presents information, gates actions, and supports compliance workflows.

## User journeys

### 1. Autonomous pre-investigation

Trigger: anomaly detection event.

System behaviour before the user receives an alert:

1. Deduplicate and suppress repeated anomalies.
2. Correlate service, infrastructure, deployment, and ownership context.
3. Compare with historical incidents and recent release and config changes.
4. Generate probable RCA with confidence and evidence.
5. Attach recommended actions and runbook mappings.

Outcome: a structured incident summary ready for human review.

### 2. Collaboration-first alert review

Actor: on-call platform/SRE engineer or service owner.

Alert content:
- What changed and where.
- Probable cause with confidence level.
- Why the workflow concluded this (short evidence bullets).
- Recommended next action and relevant runbook.
- Deep-link to Grafana dashboard scoped to service and timeframe.
- Compliance markers when applicable (data classification, DPIA tag, policy profile).

Success condition: responder understands likely cause and urgency within seconds of opening the alert.

### 3. Evidence drilldown and decision

Actor: incident responder validating or disproving an RCA hypothesis.

Pre-built dashboard intents:
- Unified incident timeline.
- Baseline vs anomaly comparison.
- RCA evidence explorer.
- Deployment impact and rollback validation view.

Navigation: alert deep-link opens with zero manual filter setup. Responder can pivot by cluster, namespace, service, and time, and share stable links across teams.

### 4. Agent-assisted build and deploy loop

Actor: ordinary user running an approved agentic client for AI-assisted coding and deployment.

Interaction model:
- User iterates on prompts; the client translates prompts into code or module changes and deploys to shared infrastructure.
- Client calls platform tools and resources through a policy-enforced agent interface (MCP-compatible).
- Platform returns curated operational feedback for that deployment: service health deltas, anomaly findings, confidence, risk signals, and recommended next actions.
- Client uses policy metadata to either execute permitted follow-up steps autonomously (for `auto_allowed` actions) or ask the user for approval (for `approval_required` actions).

Success condition: users and agents converge faster on stable production behaviour without bypassing governance.

## Information architecture

### Alert payload structure

- Incident title and severity.
- Scope metadata: cluster, namespace, service, environment, owner team.
- RCA summary and confidence.
- Key evidence bullets.
- Recommendations and runbook links.
- Dashboard deep-link and incident correlation ID.
- Compliance context block: data classification, policy profile, audit ID, residency zone.

### Policy authoring (GitOps-native)

- YAML/JSON policies in Git repositories.
- Pull request review and approval gates.
- Deployment via GitOps workflows.
- Runtime policy reload with validation checks.
- Compliance policy templates for Dutch healthcare profile (NEN 7510/7513, AVG, AI oversight).

No custom admin UI is required for Phase 1. Change management is versioned, reviewable, and auditable by design.

## UX constraints and guardrails

- Prevent alert spam with suppression windows and deduplication keys.
- Keep confidence explicit; avoid overconfident wording for weak evidence.
- Preserve human approval boundaries for operational actions.
- Keep alert formatting readable and scannable under stress.
- Ensure incident links are stable and shareable across teams.
- Never expose patient-identifying fields in collaboration messages by default.
- Require explicit operator acknowledgment when acting on recommendations tied to healthcare-sensitive scope.

## Compliance-by-design interaction model

- Policy profiles are selected per service and environment; a Dutch healthcare profile is available from initial rollout.
- Sensitive workflows surface clear legal and operational context: DPIA reference, data handling class, audit trace ID.
- Design assumes auditors need reconstructable evidence of who saw what, when, and why an action was taken.
- AI output cards include transparency fields: model source, confidence, rationale summary, human approver.

## Feedback and learning loop

- Capture responder feedback on RCA usefulness, accuracy, and recommendation quality.
- Route feedback into policy tuning and detector threshold adjustments.
- Track per-service quality trends to prioritize detector and workflow improvements.
