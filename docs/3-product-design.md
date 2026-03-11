# Product Design

## Design philosophy

Investigate first, alert with answers. During incidents, the product should reduce cognitive load by presenting concise conclusions, explicit confidence, and one-click access to supporting evidence.

## User journeys

### 1) Autonomous pre-investigation

Trigger: anomaly detection event.

System behavior before user receives an alert:
1. Deduplicate and suppress repeated anomalies.
2. Correlate service, infrastructure, deployment, and ownership context.
3. Compare with historical incidents and recent release/config changes.
4. Generate probable RCA with confidence and evidence.
5. Attach recommended actions and runbook mappings.

Outcome: a structured incident summary ready for human review.

### 2) Collaboration-first alert review

Actor: on-call platform/SRE or service owner.

Alert content:
- What changed and where.
- Probable cause with confidence level.
- Why the workflow concluded this (short evidence bullets).
- Recommended next action and relevant runbook.
- Deep-link to Grafana dashboard scoped to service + timeframe.
- Compliance markers when applicable (contains patient-related scope, DPIA tag, policy profile).

Success condition: responder understands likely cause and urgency in seconds.

### 3) Evidence drilldown and decision

Actor: incident responder validating or disproving RCA.

Pre-built dashboard intents:
- Unified incident timeline.
- Baseline vs anomaly comparison.
- RCA evidence explorer.

Navigation:
- Alert deep-link opens with zero manual filter setup.
- Responder can pivot by cluster/namespace/service/time and share links.

### 4) Agent-assisted build and deploy loop

Actor: ordinary user running an approved agentic client for AI-assisted coding and deployment.

Interaction model:
- User iterates on prompts; the client translates prompts into code/module changes and deploys to shared infrastructure.
- Client calls platform tools/resources through a policy-enforced agent interface (MCP-compatible direction).
- Platform returns curated operational feedback for that deployment: service health deltas, anomaly findings, confidence, risk signals, and recommended next actions.
- Client uses policy metadata to either execute permitted follow-up steps autonomously (for safe actions) or ask the user for approval (for guarded actions).

Success condition: users and agents converge faster on stable production behavior without bypassing governance.

## Information architecture

### Alert payload structure

- Incident title and severity.
- Scope metadata (cluster, namespace, service, environment, owner team).
- RCA summary and confidence.
- Key evidence bullets.
- Recommendations and runbook links.
- Dashboard deep-link and incident correlation ID.
- Compliance context block (data classification, policy profile, audit ID, residency zone).

### Policy authoring UX (GitOps-native)

Primary method:
- YAML/JSON policies in Git repositories.
- Pull request review and approval gates.
- Deployment via GitOps/IaC workflows.
- Runtime policy reload with validation checks.
- Compliance policy templates for Dutch healthcare profile (NEN 7510/7513 + AVG + AI oversight).

Design intent:
- No custom admin UI needed for MVP.
- Versioned, reviewable, and auditable change management.

## UX constraints and guardrails

- Prevent alert spam with suppression windows and dedupe keys.
- Keep confidence explicit; avoid overconfident wording for weak evidence.
- Preserve human approval boundaries for operational actions.
- Keep alert formatting readable and scannable under stress.
- Ensure incident links are stable and shareable across teams.
- Never expose patient-identifying fields in collaboration messages by default.
- Require explicit operator acknowledgment when acting on recommendations tied to healthcare-sensitive scope.

## Compliance-by-design interaction model

- Policy profiles are selected per service/environment, with a Dutch healthcare profile available from initial rollout.
- Sensitive workflows surface clear legal/operational context (DPIA reference, data handling class, audit trace ID).
- Design assumes auditors need reconstructable evidence of who saw what, when, and why an action was taken.
- AI output cards include transparency fields (model source, confidence, rationale summary, human approver).

## Feedback and learning loop

- Capture responder feedback on RCA usefulness, accuracy, and recommendation quality.
- Route feedback into policy tuning and detector threshold adjustments.
- Track per-service quality trends to prioritize detector and workflow improvements.

## Future interaction design (post-MVP)

- ChatOps actions (acknowledge, snooze, escalate, open incident ticket).
- Conversational Q&A over telemetry and incident history.
- Guided runbook execution with explicit human approval checkpoints.
- Richer MCP-native client experiences with reusable tool catalogs and organization-specific agent profiles.
- Closed-loop coding assistants that continuously consume curated production feedback after each deployment iteration.
