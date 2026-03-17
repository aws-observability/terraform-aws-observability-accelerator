# Requirements Document

## Introduction

The v2 Collector Architecture replaces the current tightly-coupled ADOT-based observability stack in the AWS Observability Accelerator for Terraform with a flexible, modular collector system. The v1 architecture depends on deprecated EKS Blueprints v4, a single ADOT collector path, FluxCD + Grafana Operator for dashboard delivery, and 60+ variables in the eks-monitoring module.

The v2 architecture provides two distinct observability flavors:

1. **AMP flavor** — metrics stored in Amazon Managed Service for Prometheus, queried via PromQL in Amazon Managed Grafana. Two collector profiles: `managed-metrics` (agentless via `aws_prometheus_scraper`) and `self-managed-amp` (upstream OTel Collector with Prometheus remote write to AMP). Traces go to X-Ray, logs to CloudWatch Logs.

2. **CloudWatch flavor** — all telemetry (metrics, traces, logs) sent to CloudWatch via OTLP endpoints. Metrics are ingested through the CloudWatch OTLP metrics endpoint (Zeus) using SigV4 with service `monitoring` and `cloudwatch:PutMetricData` permission, and queried via PromQL in Amazon Managed Grafana configured with a Prometheus datasource pointing at the CloudWatch PromQL endpoint. Traces go to the CloudWatch OTLP traces endpoint, logs to the CloudWatch OTLP logs endpoint. Profile: `cloudwatch-otlp`.

Both flavors use upstream OpenTelemetry Collector (replacing ADOT), simplified variable surfaces using collector profiles, direct Grafana provider dashboard provisioning (no FluxCD/Grafana Operator), and remove all references to the deprecated `terraform-aws-eks-blueprints` v4 modules.

## Glossary

- **Collector_Module**: The v2 Terraform module (`modules/eks-monitoring/`, released as `v3.0.0`) that replaces the current module implementation, providing collector selection and configuration. The module path stays the same; versioning is handled via git tags (`?ref=v3.0.0`)
- **AMP_Managed_Collector**: The AWS-managed Prometheus scraper (`aws_prometheus_scraper` Terraform resource) that discovers and pulls metrics from EKS clusters without in-cluster agents
- **OTel_Collector**: The upstream OpenTelemetry Collector deployed via Helm chart into an EKS cluster for self-managed metrics, traces, and logs collection
- **CloudWatch_OTLP_Exporter**: The component within the OTel Collector pipeline that sends telemetry (metrics, traces, logs) to CloudWatch OTLP endpoints using SigV4 authentication. Metrics use SigV4 service `monitoring` with `cloudwatch:PutMetricData` permission; traces use SigV4 service `xray`; logs use SigV4 service `logs`
- **CloudWatch_PromQL_Endpoint**: The CloudWatch Prometheus-compatible query endpoint (Zeus) that allows PromQL queries against metrics ingested via OTLP. Configured as a Prometheus datasource in Amazon Managed Grafana with SigV4 auth (service `monitoring`)
- **Collector_Profile**: A predefined configuration preset (e.g., "managed-metrics", "self-managed-amp", "cloudwatch-otlp") that sets sensible defaults for a collector deployment mode, reducing the number of individual variables users must configure
- **Scrape_Configuration**: A standard Prometheus scrape configuration YAML document that defines which targets the AMP Managed Collector or OTel Collector scrapes
- **Scrape_Configuration_Renderer**: The component that generates a valid Prometheus scrape configuration YAML from user-provided parameters and encodes it to base64 for the AMP Managed Collector
- **Dashboard_Manager**: The component responsible for provisioning Grafana dashboards, replacing the current FluxCD + Grafana Operator approach with direct Grafana provider resources or configurable dashboard JSON sources
- **IRSA_Module**: An IAM Role for Service Accounts module that creates the necessary IAM roles and policies for in-cluster collectors, replacing the deprecated EKS Blueprints v4 IRSA module
- **SigV4_Auth**: AWS Signature Version 4 authentication used by the OTel Collector's `sigv4authextension` to authenticate requests to CloudWatch OTLP endpoints and AMP remote write endpoints
- **EKS_Blueprints_V4**: The deprecated `terraform-aws-eks-blueprints` v4.32.x module currently used for helm-addon, external-secrets, cert-manager, FluentBit, and IRSA provisioning

## Requirements

### Requirement 1: Collector Profile Selection

**User Story:** As a platform engineer, I want to select a collector profile that matches my operational preferences, so that I get a working observability stack with minimal configuration.

#### Acceptance Criteria

1. THE Collector_Module SHALL accept a `collector_profile` variable with values "managed-metrics", "self-managed-amp", and "cloudwatch-otlp"
2. WHEN the `collector_profile` is set to "managed-metrics", THE Collector_Module SHALL provision an AMP_Managed_Collector and require no in-cluster collector agents for metrics collection (AMP flavor)
3. WHEN the `collector_profile` is set to "self-managed-amp", THE Collector_Module SHALL deploy an OTel_Collector via Helm into the EKS cluster with metrics remote-written to AMP, traces to X-Ray, and logs to CloudWatch Logs (AMP flavor)
4. WHEN the `collector_profile` is set to "cloudwatch-otlp", THE Collector_Module SHALL deploy an OTel_Collector configured to export metrics, traces, and logs to CloudWatch OTLP endpoints (CloudWatch flavor)
5. WHEN the `collector_profile` is set to an unsupported value, THE Collector_Module SHALL fail Terraform validation with a descriptive error message listing valid profiles
6. THE Collector_Module SHALL expose no more than 20 required and optional variables for the "managed-metrics" profile

### Requirement 2: AMP Managed Collector Provisioning

**User Story:** As a platform engineer, I want to use the AMP Managed Collector for metrics, so that I avoid deploying and managing in-cluster collector agents.

#### Acceptance Criteria

1. WHEN the "managed-metrics" profile is selected, THE Collector_Module SHALL create an `aws_prometheus_scraper` resource linked to the specified EKS cluster ARN and AMP workspace ARN
2. WHEN the "managed-metrics" profile is selected, THE Collector_Module SHALL configure the scraper with the provided security group IDs and subnet IDs (minimum 2 subnets in 2 Availability Zones)
3. IF fewer than 2 subnet IDs in 2 distinct Availability Zones are provided, THEN THE Collector_Module SHALL fail Terraform validation with a descriptive error message
4. THE Collector_Module SHALL accept an optional `scrape_configuration` variable containing a custom Prometheus scrape configuration YAML string
5. WHEN no custom `scrape_configuration` is provided, THE Scrape_Configuration_Renderer SHALL generate a default scrape configuration targeting kube-state-metrics, node-exporter, and kubelet endpoints
6. THE Collector_Module SHALL base64-encode the scrape configuration before passing it to the `aws_prometheus_scraper` resource
7. WHEN the "managed-metrics" profile is selected, THE Collector_Module SHALL not deploy any Helm charts for collector agents

### Requirement 3: Upstream OpenTelemetry Collector Deployment

**User Story:** As a platform engineer, I want to deploy the upstream OpenTelemetry Collector instead of ADOT, so that I use the community-supported collector with the latest features.

#### Acceptance Criteria

1. WHEN the "self-managed-amp" or "cloudwatch-otlp" profile is selected, THE Collector_Module SHALL deploy the upstream OpenTelemetry Collector Helm chart (`open-telemetry/opentelemetry-collector`) into the EKS cluster
2. THE Collector_Module SHALL create an IRSA IAM role with the appropriate policies for the selected profile's OTel_Collector service account
3. WHEN the "self-managed-amp" profile is selected, THE Collector_Module SHALL configure the OTel_Collector with a Prometheus receiver for metrics scraping, an OTLP receiver for traces, and a FluentForward or OTLP receiver for logs
4. WHEN the "self-managed-amp" profile is selected, THE Collector_Module SHALL configure the OTel_Collector to remote-write metrics to the specified AMP workspace endpoint using SigV4_Auth
5. THE Collector_Module SHALL accept optional `helm_values` overrides for the OTel_Collector Helm chart to allow custom pipeline configuration
6. THE Collector_Module SHALL not reference any `terraform-aws-eks-blueprints` v4 modules for Helm deployment or IRSA creation

### Requirement 4: CloudWatch OTLP Endpoint Support (CloudWatch Flavor)

**User Story:** As a platform engineer, I want to send all telemetry (metrics, traces, logs) to CloudWatch via OTLP endpoints, so that I can use CloudWatch as my single observability backend with PromQL query support in Grafana.

#### Acceptance Criteria

1. WHEN the "cloudwatch-otlp" profile is selected, THE Collector_Module SHALL configure the OTel_Collector with an OTLP HTTP exporter targeting the CloudWatch metrics OTLP endpoint using SigV4_Auth with service `monitoring`
2. WHEN the "cloudwatch-otlp" profile is selected, THE Collector_Module SHALL configure the OTel_Collector with an OTLP HTTP exporter targeting `https://xray.{region}.amazonaws.com/v1/traces` for traces using SigV4_Auth with service `xray`
3. WHEN the "cloudwatch-otlp" profile is selected, THE Collector_Module SHALL configure the OTel_Collector with an OTLP HTTP exporter targeting `https://logs.{region}.amazonaws.com/v1/logs` for logs using SigV4_Auth with service `logs`
4. THE Collector_Module SHALL configure the logs exporter to include `x-aws-log-group` and `x-aws-log-stream` headers derived from configurable variables
5. THE Collector_Module SHALL create an IRSA IAM role with `cloudwatch:PutMetricData` (no namespace condition key), `CloudWatchLogsFullAccess`, and `AWSXrayWriteOnlyAccess` policies for the CloudWatch OTLP exporter service account
6. THE Collector_Module SHALL configure the OTel_Collector metrics pipeline with a Prometheus receiver for scraping kube-state-metrics, node-exporter, and kubelet, and export scraped metrics to the CloudWatch OTLP metrics endpoint
7. THE Collector_Module SHALL output a `cloudwatch_promql_datasource_config` object containing the endpoint URL, SigV4 region, and SigV4 service (`monitoring`) for configuring an Amazon Managed Grafana Prometheus datasource pointing at the CloudWatch PromQL endpoint

### Requirement 5: Remove EKS Blueprints v4 Dependency

**User Story:** As a maintainer, I want to remove all references to the deprecated EKS Blueprints v4 modules, so that the project does not depend on unmaintained code.

#### Acceptance Criteria

1. THE Collector_Module SHALL not contain any `source` references to `github.com/aws-ia/terraform-aws-eks-blueprints//modules/`
2. THE Collector_Module SHALL use the `helm_release` Terraform resource directly for deploying Helm charts (OTel Collector, kube-state-metrics, node-exporter)
3. THE IRSA_Module SHALL use the `terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks` module or direct `aws_iam_role` and `aws_iam_role_policy_attachment` resources for IRSA creation
4. THE Collector_Module SHALL use direct `aws_cloudwatch_log_group` and `aws_iam_policy` resources for log collection instead of the EKS Blueprints FluentBit add-on
5. THE Collector_Module SHALL not depend on the EKS Blueprints `addon_context` data structure

### Requirement 6: Simplified Dashboard Provisioning

**User Story:** As a platform engineer, I want dashboards provisioned without requiring FluxCD and Grafana Operator in-cluster, so that I reduce operational complexity and in-cluster dependencies.

#### Acceptance Criteria

1. THE Dashboard_Manager SHALL provision Grafana dashboards using the `grafana_dashboard` Terraform resource from the Grafana provider
2. THE Dashboard_Manager SHALL accept a `dashboard_sources` map variable that maps dashboard names to JSON source URLs or local file paths
3. WHEN no custom `dashboard_sources` are provided, THE Dashboard_Manager SHALL use default dashboard JSON URLs from the `aws-observability-accelerator` repository at a configurable Git tag
4. THE Collector_Module SHALL not require FluxCD or Grafana Operator to be deployed in the EKS cluster for dashboard provisioning
5. THE Dashboard_Manager SHALL accept an optional `grafana_folder_id` variable to organize dashboards into a specific Grafana folder
6. IF the Grafana provider is not configured, THEN THE Dashboard_Manager SHALL skip dashboard provisioning without causing a Terraform error

### Requirement 7: Scrape Configuration Generation

**User Story:** As a platform engineer, I want the module to generate a valid default scrape configuration for the AMP Managed Collector, so that I get metrics from standard Kubernetes exporters without writing Prometheus config manually.

#### Acceptance Criteria

1. THE Scrape_Configuration_Renderer SHALL generate a valid Prometheus scrape configuration YAML document containing jobs for kube-state-metrics, node-exporter, and kubelet metrics
2. THE Scrape_Configuration_Renderer SHALL accept a list of additional scrape job objects to append to the default configuration
3. THE Scrape_Configuration_Renderer SHALL output the generated configuration as both a raw YAML string and a base64-encoded string
4. WHEN a user provides a complete custom `scrape_configuration` string, THE Scrape_Configuration_Renderer SHALL use the custom configuration and skip default generation
5. THE Scrape_Configuration_Renderer SHALL set the global `scrape_interval` and `scrape_timeout` from configurable variables with defaults of "60s" and "15s"

### Requirement 8: AMP Workspace Management

**User Story:** As a platform engineer, I want the module to optionally create an AMP workspace or accept an existing one, so that I can integrate with my existing infrastructure.

#### Acceptance Criteria

1. WHEN `create_amp_workspace` is set to true, THE Collector_Module SHALL create a new `aws_prometheus_workspace` resource with a configurable alias and tags
2. WHEN `create_amp_workspace` is set to false, THE Collector_Module SHALL accept a `managed_prometheus_workspace_id` variable referencing an existing workspace
3. IF `create_amp_workspace` is false and `managed_prometheus_workspace_id` is not provided, THEN THE Collector_Module SHALL fail Terraform validation with a descriptive error message
4. THE Collector_Module SHALL output the AMP workspace ID, endpoint URL, and ARN regardless of whether the workspace was created or referenced

### Requirement 9: Alerting and Recording Rules

**User Story:** As a platform engineer, I want the module to provision Prometheus alerting and recording rules into my AMP workspace, so that I get pre-built monitoring coverage for Kubernetes infrastructure.

#### Acceptance Criteria

1. WHEN `enable_alerting_rules` is set to true, THE Collector_Module SHALL create `aws_prometheus_rule_group_namespace` resources containing infrastructure alerting rules for node health, kubelet, pod status, and resource utilization
2. WHEN `enable_recording_rules` is set to true, THE Collector_Module SHALL create `aws_prometheus_rule_group_namespace` resources containing recording rules for CPU, memory, network, and API server metrics aggregation
3. THE Collector_Module SHALL accept optional `custom_alerting_rules` and `custom_recording_rules` variables containing additional rule group YAML to append to the default rules
4. WHEN `enable_alerting_rules` is set to false, THE Collector_Module SHALL not create any alerting rule group namespace resources
5. WHEN `enable_recording_rules` is set to false, THE Collector_Module SHALL not create any recording rule group namespace resources

### Requirement 10: Provider Version Compatibility

**User Story:** As a platform engineer, I want the module to work with current Terraform and provider versions, so that I am not blocked by outdated version constraints.

#### Acceptance Criteria

1. THE Collector_Module SHALL require Terraform version >= 1.5.0
2. THE Collector_Module SHALL require the AWS provider version >= 5.0.0
3. THE Collector_Module SHALL require the Helm provider version >= 2.10.0
4. THE Collector_Module SHALL require the Grafana provider version >= 2.0.0 when dashboard provisioning is enabled
5. THE Collector_Module SHALL not require the `kubectl` provider or the `kubernetes` provider unless the "self-managed-amp" or "cloudwatch-otlp" profile is selected

### Requirement 11: Backward-Compatible Outputs

**User Story:** As a platform engineer migrating from v1, I want the v2 module to expose equivalent outputs, so that I can update my Terraform configurations without breaking downstream references.

#### Acceptance Criteria

1. THE Collector_Module SHALL output `managed_prometheus_workspace_endpoint` containing the full AMP workspace endpoint URL
2. THE Collector_Module SHALL output `managed_prometheus_workspace_id` containing the AMP workspace ID
3. THE Collector_Module SHALL output `managed_prometheus_workspace_region` containing the AMP workspace region
4. THE Collector_Module SHALL output `collector_irsa_arn` containing the IRSA role ARN when a self-managed collector is deployed
5. WHEN the "managed-metrics" profile is selected, THE Collector_Module SHALL output `amp_scraper_arn` containing the ARN of the created `aws_prometheus_scraper`
6. THE Collector_Module SHALL output `eks_cluster_id` containing the EKS cluster identifier
7. WHEN the "cloudwatch-otlp" profile is selected, THE Collector_Module SHALL output `cloudwatch_promql_datasource_config` containing the endpoint URL, SigV4 region, and SigV4 service (`monitoring`) for configuring an Amazon Managed Grafana Prometheus datasource
