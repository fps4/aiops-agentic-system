# Component 09: Operations and SLO

## Purpose

Keep the platform observable, operable, and resilient with explicit service level objectives and incident response playbooks.

## Core SLOs

- Ingestion lag SLO
- Detection latency SLO
- Workflow completion SLO
- Notification success and latency SLO
- Agent gateway availability SLO

## Operational responsibilities

- Monitor golden signals per component plane.
- Run capacity management for Kafka, ClickHouse, PostgreSQL, and Redis.
- Execute backup/restore and disaster recovery drills.
- Maintain upgrade and rollback playbooks.

## Alerting strategy

- Error-budget based paging for critical SLO breaches.
- Ticket-based alerts for non-urgent degradation.
- Suppression rules to prevent operations alert storms.

## Runbook coverage

- Ingestion backlog recovery
- Detector quality degradation
- Workflow stuck/retry storms
- Notification delivery failures
- Policy engine rejection spikes

## Continuous improvement

- Weekly SLO and false-positive reviews.
- Post-incident action tracking.
- Policy and detector tuning based on feedback loop metrics.
