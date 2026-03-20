workspace "AIOps Agentic System" "Sovereign observability and incident intelligence control plane for regulated environments." {

    model {
        # External actors
        workloads       = softwareSystem "Workloads and Services"           "Application workloads emitting telemetry." "External"
        k8sInfra        = softwareSystem "Kubernetes / Node Infrastructure" "Cluster and node-level metrics and log streams." "External"
        cicd            = softwareSystem "CI/CD Pipelines"                  "Deployment and change events." "External"
        idp             = softwareSystem "Enterprise IdP"                   "Identity provider — OIDC/SAML." "External"
        chatops         = softwareSystem "ChatOps Platforms"                "Slack, Mattermost." "External"
        incidentMgmt    = softwareSystem "Incident Management"              "PagerDuty, ServiceNow." "External"
        grafana         = softwareSystem "Grafana"                          "Dashboard deep-links and pre-filtered evidence views." "External"
        agenticClients  = softwareSystem "Agentic Clients"                  "Software agents and AI-assisted developer tooling." "External"
        modelEndpoints  = softwareSystem "Self-hosted Model Endpoints"      "LLM inference — HTTP/gRPC, customer-owned infrastructure." "External"

        # AIOps Agentic System
        aiops = softwareSystem "AIOps Agentic System" "Sovereign control plane: ingest telemetry, detect anomalies, orchestrate RCA, deliver actionable alerts." {

            ingestion = container "Telemetry Ingestion" "Collects and durably buffers all inbound signals. Validates schema, stamps metadata, routes malformed payloads to dead-letter topic." "OTel Collector, Kafka" "MessageBus"

            normalization = container "Normalization and Enrichment" "Canonicalizes telemetry to shared schema. Enriches with ownership and deployment context. Writes to object storage and analytics indexes." "Stream Processors"

            storage = container "Storage and State" "Durable raw retention, analytics queries, baseline storage, operational and compliance metadata, ephemeral deduplication state." "S3-compatible, ClickHouse, PostgreSQL, Redis" "DataStore"

            detection = container "Anomaly Detection" "Compares signals against baselines using statistical (z-score, EWMA, changepoint) and rule-based (SLO, error/latency) patterns. Emits structured anomaly events with confidence and evidence references. Enforces suppression and cooldown." "Workers"

            orchestration = container "Workflow Orchestration" "Runs deterministic, replayable RCA pipelines: signal validation → correlation → historical comparison → hypothesis synthesis → recommendations. Enforces policy gates before sensitive outputs." "Temporal, LLM Adapters"

            agentGateway = container "Agent Gateway and Curated Feedback" "MCP-compatible interface. Authenticates user and agent identity. Enforces per-agent capability policies and rate limits. Returns deployment-scoped feedback with actions tagged auto_allowed or approval_required." "HTTP"

            notifications = container "Notifications and Dashboards" "Delivers alerts to ChatOps and incident management systems. Includes Grafana deep-links with pre-filtered evidence views. Applies compliance markers where required." "Webhook, API"

            compliance = container "Compliance and Governance Plane" "Cross-cutting policy engine: field masking, residency controls, model routing, approval gates. Immutable audit trail. DPIA evidence export." "Policy-as-Code Engine" "CrossCutting"

            ops = container "Operations and SLO" "Platform self-observability via OpenTelemetry. SLO tracking. Health signals: lag, drop_rate, backpressure." "OTel, Grafana" "CrossCutting"
        }

        # --- External → Ingestion ---
        workloads      -> ingestion     "Sends logs, metrics, traces"       "OTLP/gRPC, OTLP/HTTP"
        k8sInfra       -> ingestion     "Sends log streams and metrics"     "Log streams, Prometheus remote-write"
        cicd           -> ingestion     "Sends deployment events"           "HTTP/JSON"
        idp            -> agentGateway  "Issues and validates tokens"       "OIDC/SAML, JWT"
        agenticClients -> agentGateway  "Requests deployment feedback and executes permitted actions" "MCP-compatible HTTP"

        # --- Internal pipeline ---
        ingestion      -> normalization  "Raw telemetry (Kafka topic)"
        normalization  -> storage        "Normalised events and enriched metadata"
        normalization  -> detection      "Normalised event stream"
        detection      -> storage        "Anomaly events and baseline updates"
        detection      -> orchestration  "Anomaly events (Kafka topic)"
        orchestration  -> storage        "RCA artefacts, stage metadata, audit records"
        orchestration  -> modelEndpoints "Inference requests"               "HTTP/gRPC"
        orchestration  -> notifications  "Alert payloads"
        agentGateway   -> normalization  "Queries enrichment state for deployment scope"
        agentGateway   -> detection      "Queries anomaly events for deployment scope"
        agentGateway   -> orchestration  "Queries workflow state and recommendations"

        # --- Outbound delivery ---
        notifications  -> chatops        "Sends alert messages"             "Webhook"
        notifications  -> incidentMgmt   "Opens and updates incidents"      "API"
        notifications  -> grafana        "Generates deep-link URLs"         "URL params"

        # --- Cross-cutting ---
        compliance     -> ingestion      "Enforces schema and residency policy"
        compliance     -> normalization  "Applies field masking rules"
        compliance     -> orchestration  "Enforces approval gates and model routing"
        compliance     -> agentGateway   "Enforces capability policy and audit logging"
        ops            -> ingestion      "Collects platform metrics"
        ops            -> normalization  "Collects platform metrics"
        ops            -> detection      "Collects platform metrics"
        ops            -> orchestration  "Collects platform metrics"
    }

    views {
        systemContext aiops "SystemContext" "C4 Level 1 — System context" {
            include *
            autoLayout lr
        }

        container aiops "Containers" "C4 Level 2 — Container view" {
            include *
            autoLayout lr
        }

        dynamic aiops "IncidentFlow" "End-to-end incident detection and alert delivery" {
            workloads      -> ingestion      "1. Stream logs, metrics, traces"
            ingestion      -> normalization  "2. Raw telemetry via Kafka"
            normalization  -> storage        "3. Write normalised events and enriched metadata"
            normalization  -> detection      "3. Forward normalised event stream"
            detection      -> orchestration  "4. Emit anomaly event"
            orchestration  -> modelEndpoints "5. Request RCA inference"
            orchestration  -> storage        "5. Persist RCA artefacts"
            orchestration  -> notifications  "6. Publish alert payload"
            notifications  -> chatops        "6. Deliver alert with Grafana deep-link"
            autoLayout lr
        }

        dynamic aiops "AgentFeedbackFlow" "Agent-assisted deployment feedback loop" {
            agenticClients -> agentGateway   "1. Authenticate and call get_deployment_feedback"
            agentGateway   -> normalization  "2. Query enrichment state"
            agentGateway   -> detection      "2. Query anomaly events"
            agentGateway   -> orchestration  "2. Query workflow state and recommendations"
            agentGateway   -> agenticClients "3. Return curated feedback (health deltas, actions)"
            autoLayout lr
        }

        styles {
            element "Software System" {
                background #1168bd
                color      #ffffff
                shape      RoundedBox
            }
            element "External" {
                background #999999
                color      #ffffff
            }
            element "Container" {
                background #438dd5
                color      #ffffff
            }
            element "MessageBus" {
                shape Pipe
            }
            element "DataStore" {
                shape Cylinder
            }
            element "CrossCutting" {
                border Dashed
            }
        }
    }
}
