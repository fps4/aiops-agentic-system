---
title: Architecture Decision Records
status: current
last_updated: 2026-03-19
owners: [platform-team]
related:
  - docs/architecture/overview.md
---

## Purpose

ADRs record why significant technical decisions were made. They are immutable once accepted — do not edit an accepted ADR; write a new one that supersedes it.

## Status meanings

- **proposed**: recommended, awaiting team confirmation
- **accepted**: approved for implementation
- **deprecated**: no longer applicable
- **superseded by NNNN**: replaced by a newer ADR

## ADR index

- [0001: Message bus — Kafka over NATS JetStream](0001-message-bus-kafka-over-nats-jetstream.md) *(proposed)*
- [0002: Analytics store — ClickHouse primary, OpenSearch secondary](0002-analytics-store-clickhouse-primary-opensearch-secondary.md) *(proposed)*
- [0003: Orchestration engine — Temporal over Argo Workflows](0003-orchestration-engine-temporal-over-argo.md) *(proposed)*
- [0004: State store — PostgreSQL plus Redis over single key-value store](0004-state-store-postgresql-plus-redis-over-single-kv.md) *(proposed)*
