# ADR 003: Orchestration engine - Temporal over Argo Workflows

- Status: **Proposed**
- Date: 2026-03-11
- Deciders: Platform architecture group

## Context

The architecture lists `Temporal/Argo/custom worker pipeline` for deterministic agentic RCA orchestration.

Workflows need retries, durable state, replayability, long-running step coordination, and strict audit trails.

## Decision

Use **Temporal** as the default orchestration engine for Phase 1 agentic investigation workflows.

Argo remains a valid option for Kubernetes-native batch pipelines, but not the primary RCA workflow engine.

## Rationale

- Temporal provides strong workflow durability, retries, versioning, and history out of the box.
- Better fit for long-lived, stateful, event-driven orchestration than DAG-only models.
- Supports deterministic workflow logic and replay, aligned with audit/compliance needs.

## Consequences

Positive:
- Strong reliability model for multi-step RCA and recommendation pipelines.
- Clear separation between workflow state and task worker execution.

Trade-offs:
- Learning curve for workflow programming model.
- Additional operational component in platform baseline.

## Revisit triggers

- Organization has strong Argo-only operating model and no Temporal expertise.
- Workflows remain purely short-lived batch DAGs.
- Temporal operational overhead proves disproportionate for target footprint.
