# Component 01: Telemetry Ingestion

## Purpose

Collect logs, metrics, traces, and platform events from shared infrastructure and onboarded services into a durable ingestion backbone.

## Recommended stack

- OpenTelemetry Collector (daemonset + gateway modes)
- Kafka as primary ingestion bus (ADR 001)
- Optional edge buffering adapters for constrained sites

## Responsibilities

- Accept OTLP, Prometheus scrape-derived metrics, log streams, and infra events.
- Apply first-pass schema validation and metadata stamping (`cluster`, `env`, `service`, `owner`).
- Buffer bursts and absorb downstream outages without data loss.
- Emit ingestion health signals (`lag`, `drop_rate`, `backpressure`).

## Inputs and outputs

Inputs:
- Service telemetry (OTLP/gRPC, OTLP/HTTP)
- Kubernetes and node logs
- Deployment and change events from CI/CD

Outputs:
- Kafka topics partitioned by signal type and tenancy scope
- Dead-letter topic for malformed payloads

## Data contracts

Required envelope fields:
- `event_id`, `event_time`, `signal_type`
- `cluster`, `namespace`, `service`, `environment`
- `trace_id` (if present), `deployment_id` (if present)
- `classification` (public/internal/sensitive-health)

## Reliability and scaling

- At-least-once delivery from collectors to Kafka.
- Partition strategy by service/environment for parallel processing.
- Backpressure policies: queue limits, spillover, and controlled sampling only for non-critical signals.

## Security and compliance

- mTLS between collectors, gateways, and Kafka brokers.
- Tenant-aware authN/authZ for ingestion endpoints.
- Sensitive field detection and early masking hooks for disallowed attributes.
