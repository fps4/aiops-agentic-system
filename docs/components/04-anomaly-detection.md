# Component 04: Anomaly Detection

## Purpose

Detect meaningful service and infrastructure regressions with low false positives and produce structured anomaly events for orchestration.

## Detection modes

- Statistical detectors: baseline deviation, changepoint, seasonality-aware behavior.
- Rule-based detectors: SLO breaches, latency/error thresholds, security/event guardrails.

## Responsibilities

- Consume normalized telemetry and pre-aggregations.
- Compute anomaly score, severity, confidence, and suppression keys.
- Attach evidence references (queries, time windows, comparative baselines).
- Emit anomaly events to workflow trigger stream and state store.

## Output contract

Required fields:
- `anomaly_id`, `service`, `environment`, `time_window`
- `severity`, `confidence`, `detector_type`
- `baseline_value`, `observed_value`, `delta`
- `evidence_refs[]`, `suppression_key`

## Tuning and feedback

- Detector thresholds are policy-driven and versioned.
- Operator feedback updates suppression rules and detector parameters.
- Quality metrics: false positive rate, alert usefulness, detection delay.

## Reliability controls

- Idempotent anomaly creation by deterministic suppression keys.
- Cooldown windows to prevent alert storms.
- Circuit breakers when upstream data quality degrades.
