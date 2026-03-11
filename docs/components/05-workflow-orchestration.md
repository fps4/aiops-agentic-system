# Component 05: Workflow Orchestration

## Purpose

Run deterministic, replayable RCA workflows from anomaly trigger to recommendation output.

## Recommended stack

- Temporal as default workflow engine (ADR 003)
- Dedicated task workers for each agent stage

## Workflow stages

1. Detection validation
2. Signal correlation
3. Historical comparison
4. RCA synthesis
5. Recommendation generation

## Responsibilities

- Manage retries, backoff, timeouts, and compensation logic.
- Persist stage-level inputs/outputs and confidence progression.
- Enforce policy gates before sensitive actions or recommendations.
- Publish final investigation summary to notification and agent feedback channels.

## Execution model

- One workflow per `anomaly_id` + scope.
- Deterministic workflow code with explicit versioning.
- Long-running support for delayed evidence availability.

## Failure handling

- Retry transient worker failures with bounded attempts.
- Move irrecoverable cases to manual review queue with full trace context.
- Emit operational alerts for workflow SLA breaches.

## Auditability

- Store workflow history IDs and correlation IDs in PostgreSQL.
- Capture model metadata and evidence links per stage.
- Associate approvals with user/agent identity and timestamp.
