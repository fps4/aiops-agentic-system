# Component 02: Normalization and Enrichment

## Purpose

Transform heterogeneous incoming telemetry into a canonical model used by detection, RCA, dashboards, and agent feedback.

## Responsibilities

- Parse and normalize records from ingestion topics.
- Enrich with ownership, service catalog, release metadata, and policy profile.
- Attach correlation keys (`anomaly_key`, `deployment_key`, `workflow_hint`).
- Route normalized output to raw archive and analytics/state sinks.

## Processing model

- Stateless stream workers consuming Kafka topics.
- Versioned schema transformers (`v1`, `v2`) with compatibility checks.
- Idempotent processing keyed by `event_id`.

## Inputs and outputs

Inputs:
- Raw ingestion topics
- Service catalog and CMDB metadata
- Policy profile lookup tables

Outputs:
- Canonical telemetry streams
- Raw immutable archive writes
- Derived facts for detection pre-aggregation

## Error handling

- Schema violations go to DLQ with reason codes.
- Transient sink failures trigger retries with exponential backoff.
- Persistent sink failures raise platform incidents and halt unsafe data mutation.

## Compliance hooks

- Apply field-level masking rules before leaving trusted boundaries.
- Tag records with data classification and residency policy markers.
- Preserve transformation lineage for audit reconstruction.
