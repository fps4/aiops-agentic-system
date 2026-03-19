---
title: "Component design: Anomaly Detection"
status: draft
last_updated: 2026-03-19
owners: [platform-team]
c4_level: component
container: anomaly-detection
related:
  - docs/architecture/overview.md
  - docs/product/prd/0001-aiops-agentic-system.md
  - docs/architecture/decisions/0002-analytics-store-clickhouse-primary-opensearch-secondary.md
---

## Purpose

Detect meaningful service and infrastructure regressions with low false positives and produce structured anomaly events for the orchestration plane. The detection layer is the signal-to-meaning boundary — it converts raw telemetry patterns into structured, evidence-backed anomaly events.

## Responsibilities

**Owns:**
- Consuming normalized telemetry and pre-aggregations from storage.
- Computing anomaly score, severity, confidence, and suppression key.
- Attaching evidence references: queries, time windows, and comparative baselines.
- Emitting anomaly events to the workflow trigger stream and state store.
- Enforcing cooldown windows and deduplication to prevent alert storms.

**Does not own:**
- RCA synthesis or recommendation generation (owned by workflow-orchestration).
- Alert delivery to operators (owned by notifications-and-dashboards).
- Detector threshold configuration — thresholds are defined in policy profiles.

## Internal structure

| Component | Responsibility |
|---|---|
| `Statistical detector` | Evaluates baseline deviations, changepoints, and seasonality-aware patterns (z-score, EWMA) |
| `Rule-based detector` | Applies deterministic guardrails: SLO breaches, latency/error thresholds, security event patterns |
| `Suppression engine` | Enforces cooldown windows and deduplication by `anomaly_key` |
| `Evidence collector` | Assembles queries, time windows, and baseline comparisons as structured evidence references |
| `Anomaly publisher` | Writes anomaly events to the workflow trigger Kafka stream and PostgreSQL state |

## Key flows

### Happy path: statistical anomaly detected

1. `Statistical detector` evaluates a time-window aggregation from ClickHouse.
2. Baseline deviation exceeds configured threshold; changepoint or EWMA pattern confirmed.
3. `Suppression engine` checks `anomaly_key` — not in cooldown, not a duplicate.
4. `Evidence collector` assembles time window, baseline value, observed value, delta, and ClickHouse query reference.
5. Anomaly event is constructed with `anomaly_id`, `severity`, `confidence`, `detector_type`, and `evidence_refs[]`.
6. `Anomaly publisher` writes the event to the Kafka trigger stream and creates the anomaly record in PostgreSQL with state `new`.

### Suppressed duplicate

1. Detector produces a candidate anomaly.
2. `Suppression engine` finds an existing active anomaly with the same `anomaly_key` within the cooldown window.
3. Candidate is discarded; no event emitted; suppression counter incremented.

### Rule-based guardrail breach

1. `Rule-based detector` evaluates an error rate or latency threshold policy.
2. Threshold exceeded for configured duration.
3. Same evidence collection and publish flow as statistical detection.

## External interfaces

### Consumes

| Source | Protocol | Data |
|---|---|---|
| ClickHouse | Query | Pre-aggregated metrics, baselines, time-window aggregations |
| Detection pre-aggregation topic | Kafka | Streaming signal facts from normalization |
| Policy profile store | Internal lookup | Detector thresholds, suppression rules, cooldown durations |

### Publishes

| Destination | Protocol | Event |
|---|---|---|
| Kafka workflow trigger stream | Kafka | Structured anomaly events |
| PostgreSQL anomaly state | Direct write | Anomaly lifecycle records |

Required anomaly event fields:
- `anomaly_id`, `service`, `environment`, `time_window`
- `severity`, `confidence`, `detector_type`
- `baseline_value`, `observed_value`, `delta`
- `evidence_refs[]`, `suppression_key`

## Error handling and failure modes

| Failure | Behaviour |
|---|---|
| ClickHouse query fails | Detection skipped for that evaluation window; next window retried |
| Kafka publish fails | Retry with backoff; anomaly state written to PostgreSQL regardless |
| Upstream data quality degrades (missing or delayed records) | Circuit breaker activates; detection suspended; platform alert raised |
| Policy profile unavailable | Detector falls back to last-loaded profile; warning logged |

## Non-functional constraints

- Idempotent anomaly creation: same input signal and detector produces the same `anomaly_id` via deterministic `suppression_key`.
- Detector thresholds are policy-driven and versioned — no hardcoded thresholds in detection code.
- Operator feedback updates suppression rules and detector parameters via policy profile updates.

## Known limitations

- Statistical detectors require sufficient historical baseline data per service/environment. New services or environments with fewer than 7 days of data will have degraded detection quality.
- Seasonality-aware detection depends on consistent telemetry cadence; gaps cause false positives on resumption.
