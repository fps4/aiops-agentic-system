# Glossary

| Term | Definition |
|------|------------|
| Anomaly | A structured detection event produced by the detection plane. Contains severity, confidence score, baseline value, observed value, and evidence references. Not a raw alert. |
| Anomaly key | A deterministic suppression key computed from anomaly properties (service, environment, detector type, signal). Used for deduplication and cooldown enforcement. |
| Canonical schema | The normalized telemetry envelope used across the platform after the normalization-and-enrichment stage. Defined in `docs/api/schemas/`. |
| Curated feedback | A deployment-scoped operational summary returned by the agent gateway to agentic clients: health deltas, anomaly summaries, confidence scores, and policy-tagged next actions. |
| DPIA | Data Protection Impact Assessment. Required under AVG/GDPR Art. 35 for processing activities involving patient-related or high-risk datasets. |
| Evidence chain | The ordered set of signals, queries, comparisons, and model outputs that support an RCA conclusion. Persisted per workflow stage for auditability. |
| NEN 7510 | Dutch standard for information security management in healthcare. Treated as a procurement gate for healthcare deployments. |
| NEN 7513 | Dutch standard for logging of access to electronic patient records. Drives audit trail design for workflows touching patient-related data. |
| Policy profile | A versioned YAML artifact that controls detection thresholds, suppression rules, model/provider routing, residency constraints, and compliance controls for a given environment or service scope. |
| RCA | Root Cause Analysis. The output of an orchestrated investigation workflow: a probable cause with confidence score, supporting evidence, and recommended actions. |
| Sovereign deployment | A deployment where all platform components, data, and policy execution run inside the customer's own infrastructure with no dependency on external managed services. |
| Workflow | A Temporal-backed, deterministic, replayable investigation pipeline. Stages: detection validation → signal correlation → historical comparison → RCA synthesis → recommendation generation. |
| Workflow ID | A stable identifier scoped to a single RCA workflow execution, used for correlation across audit logs, state store, and notification payloads. |
