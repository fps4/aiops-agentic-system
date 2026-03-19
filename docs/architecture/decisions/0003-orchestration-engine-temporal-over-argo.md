---
title: "0003: Orchestration engine — Temporal over Argo Workflows"
status: proposed
date: 2026-03-11
---

## Context

The platform requires deterministic, replayable RCA workflows with retries, durable state, long-running step coordination, and strict audit trails. The architecture initially listed Temporal, Argo Workflows, or a custom worker pipeline as candidates.

## Decision

Use Temporal as the default orchestration engine for Phase 1 agentic investigation workflows.

Argo Workflows remains a valid option for Kubernetes-native batch pipelines, but is not the primary RCA workflow engine.

## Consequences

Positive:
- Strong workflow durability, retries, versioning, and history out of the box.
- Better fit for long-lived, stateful, event-driven orchestration than DAG-only models.
- Supports deterministic workflow logic and replay — aligned with audit and compliance needs.
- Clear separation between workflow state and task worker execution.

Trade-offs:
- Learning curve for the Temporal workflow programming model.
- Additional operational component in the platform baseline.

Revisit if:
- Organization has a strong Argo-only operating model and no Temporal expertise.
- Workflows remain purely short-lived batch DAGs.
- Temporal operational overhead is disproportionate for the target deployment footprint.
