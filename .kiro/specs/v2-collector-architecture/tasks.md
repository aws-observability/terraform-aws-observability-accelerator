# Implementation Plan: v2 Collector Architecture

## Overview

Replace the current `modules/eks-monitoring/` module with a profile-driven v2 architecture (released as git tag `v3.0.0`). Implementation follows two parallel streams: shared foundation first, then CloudWatch flavor (priority for internal demo), then AMP flavor. All code lives in `modules/eks-monitoring/` — no new `-v2` directory.

## Tasks

- [x] 1. Shared foundation — module skeleton and profile routing
  - [x] 1.1 Create `modules/eks-monitoring/versions.tf` with provider constraints
    - Require Terraform >= 1.5.0, AWS provider >= 5.0.0, Helm >= 2.10.0, Grafana >= 2.0.0
    - Remove `kubernetes` and `kubectl` provider requirements
    - Add `configuration_aliases = [grafana]` for the Grafana provider
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [x] 1.2 Create `modules/eks-monitoring/variables.tf` with core variables
    - Define `collector_profile` variable with validation block accepting `managed-metrics`, `self-managed-amp`, `cloudwatch-otlp`
    - Define shared variables: `eks_cluster_id`, `eks_oidc_provider_arn`, `tags`, `enable_dashboards`, `dashboard_sources`, `dashboard_git_tag`, `grafana_folder_id`
    - Define AMP variables: `create_amp_workspace`, `managed_prometheus_workspace_id`, `amp_workspace_alias`, `enable_alerting_rules`, `enable_recording_rules`, `custom_alerting_rules`, `custom_recording_rules`
    - Define managed-metrics variables: `scraper_subnet_ids` (with >= 2 validation), `scraper_security_group_ids`, `scrape_configuration`, `additional_scrape_jobs`, `prometheus_config`
    - Define OTel variables: `otel_collector_chart_version`, `collector_namespace`, `helm_values`
    - Define CloudWatch variables: `cloudwatch_metrics_endpoint`, `cloudwatch_log_group`, `cloudwatch_log_stream`, `grafana_cw_datasource_name`
    - Define self-managed-amp toggles: `enable_tracing`, `enable_logs`
    - Keep managed-metrics profile to ≤ 20 variables
    - Remove all EKS Blueprints v4 variables (`helm_config`, `addon_context`, `flux_*`, `go_config`, `enable_fluxcd`, `enable_grafana_operator`, `enable_external_secrets`, etc.)
    - _Requirements: 1.1, 1.5, 1.6, 2.2, 2.3, 2.4, 5.5_

  - [x] 1.3 Create `modules/eks-monitoring/locals.tf` with profile routing booleans and data sources
    - Define `is_managed_metrics`, `is_self_managed_amp`, `is_cloudwatch_otlp`, `needs_otel_helm`, `needs_irsa`, `is_amp_flavor`, `is_cw_flavor`
    - Add `data.aws_partition`, `data.aws_caller_identity`, `data.aws_region`, `data.aws_eks_cluster`
    - Add AMP workspace endpoint computation (`amp_workspace_id`, `amp_workspace_arn`, `amp_workspace_endpoint`)
    - Add precondition: fail when `create_amp_workspace = false` and `managed_prometheus_workspace_id` is null
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 8.1, 8.2, 8.3_

  - [x] 1.4 Create `modules/eks-monitoring/main.tf` with AMP workspace resource
    - `aws_prometheus_workspace.this` gated by `var.create_amp_workspace`
    - `data.aws_prometheus_workspace.existing` for referencing existing workspaces
    - Remove all EKS Blueprints v4 module references (`module.operator`, `module.helm_addon`, `module.fluentbit_logs`, `module.external_secrets`, FluxCD, Grafana Operator)
    - _Requirements: 5.1, 5.5, 8.1, 8.2, 8.4_

  - [x] 1.5 Create `modules/eks-monitoring/outputs.tf` with backward-compatible outputs
    - `managed_prometheus_workspace_endpoint`, `managed_prometheus_workspace_id`, `managed_prometheus_workspace_region`
    - `collector_irsa_arn` (conditional on `needs_irsa`)
    - `amp_scraper_arn` (conditional on `is_managed_metrics`)
    - `eks_cluster_id`
    - `cloudwatch_promql_datasource_config` (conditional on `is_cloudwatch_otlp`)
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 4.7_

  - [x] 1.6 Create `modules/eks-monitoring/helm-support.tf` with kube-state-metrics and node-exporter
    - `helm_release.kube_state_metrics` gated by all three profiles (always deployed)
    - `helm_release.prometheus_node_exporter` gated by all three profiles (always deployed)
    - Use direct `helm_release` resource, no EKS Blueprints helm-addon
    - _Requirements: 5.2, 3.1_

- [x] 2. Checkpoint — Validate shared foundation
  - Run `terraform validate` on the module skeleton with each profile value
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. CloudWatch flavor — OTel Collector for cloudwatch-otlp profile (Priority Stream)
  - [x] 3.1 Create `modules/eks-monitoring/iam.tf` with IRSA for cloudwatch-otlp
    - `module.collector_irsa_role` using `terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks` gated by `local.needs_irsa`
    - `aws_iam_policy.cloudwatch_put_metric` custom policy for `cloudwatch:PutMetricData` (no namespace condition key) gated by `local.is_cloudwatch_otlp`
    - Attach `CloudWatchLogsFullAccess` and `AWSXrayWriteOnlyAccess` managed policies for cloudwatch-otlp
    - Wire OIDC provider and service account namespace
    - _Requirements: 3.2, 4.5, 5.3, 5.6_

  - [x] 3.2 Add CloudWatch OTel Collector config generation to `modules/eks-monitoring/locals.tf`
    - Build `local.otel_collector_values` YAML for `cloudwatch-otlp` profile
    - Configure `sigv4auth/monitoring` extension (service `monitoring`), `sigv4auth/xray` (service `xray`), `sigv4auth/logs` (service `logs`)
    - Configure `otlphttp/metrics` exporter → `var.cloudwatch_metrics_endpoint` with `sigv4auth/monitoring`
    - Configure `otlphttp/traces` exporter → `https://xray.{region}.amazonaws.com/v1/traces` with `sigv4auth/xray`
    - Configure `otlphttp/logs` exporter → `https://logs.{region}.amazonaws.com/v1/logs` with `sigv4auth/logs`, including `x-aws-log-group` and `x-aws-log-stream` headers
    - Configure `prometheus` receiver with scrape configs for kube-state-metrics, node-exporter, kubelet
    - Configure `otlp` receiver (gRPC 4317, HTTP 4318) for application telemetry
    - Wire metrics pipeline: `[prometheus, otlp] → [batch] → [otlphttp/metrics]`
    - Wire traces pipeline: `[otlp] → [batch] → [otlphttp/traces]`
    - Wire logs pipeline: `[otlp] → [batch] → [otlphttp/logs]`
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.6_

  - [x] 3.3 Create `modules/eks-monitoring/collector-otel.tf` with Helm release for OTel Collector
    - `helm_release.otel_collector` using upstream `open-telemetry/opentelemetry-collector` chart, gated by `local.needs_otel_helm`
    - Pass `local.otel_collector_values` as values
    - Support `var.helm_values` overrides via dynamic `set` blocks
    - Set `create_namespace = true` with `var.collector_namespace`
    - _Requirements: 3.1, 3.5, 5.2_

  - [x] 3.4 Create `modules/eks-monitoring/dashboards.tf` with Grafana dashboard provisioning and CloudWatch PromQL datasource
    - `data.http.dashboard_json` fetching dashboard JSON from URLs in `local.dashboard_sources`
    - `grafana_dashboard.this` for each dashboard, gated by `var.enable_dashboards`
    - Default dashboard sources in `locals.tf` using `var.dashboard_git_tag`
    - `grafana_data_source.cloudwatch_promql` for cloudwatch-otlp profile: Prometheus type, SigV4 service `monitoring`, gated by `local.is_cloudwatch_otlp && var.enable_dashboards`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 4.7_

  - [ ]* 3.5 Write property tests for CloudWatch OTel config generation
    - **Property 3: OTLP endpoint URL construction** — For any valid AWS region, verify traces endpoint = `https://xray.{region}.amazonaws.com/v1/traces`, logs endpoint = `https://logs.{region}.amazonaws.com/v1/logs`, metrics uses configured endpoint with SigV4 service `monitoring`
    - **Property 3a: CloudWatch metrics SigV4 service is `monitoring`** — Verify metrics exporter uses `monitoring`, traces uses `xray`, logs uses `logs`
    - **Property 4: CloudWatch log headers contain configured values** — For any log group/stream, verify `x-aws-log-group` and `x-aws-log-stream` headers in generated config
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

  - [x] 3.6 Create `examples/eks-cloudwatch-otlp/` example configuration
    - `main.tf` calling `modules/eks-monitoring/` with `collector_profile = "cloudwatch-otlp"`
    - `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`
    - Demonstrate CloudWatch metrics endpoint, log group/stream, and Grafana datasource config
    - _Requirements: 1.4, 4.1, 4.7_

- [x] 4. Checkpoint — Validate CloudWatch flavor end-to-end
  - Run `terraform validate` on the module and `examples/eks-cloudwatch-otlp/`
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. AMP flavor — managed-metrics and self-managed-amp profiles (Stream 2)
  - [x] 5.1 Add scrape configuration renderer to `modules/eks-monitoring/locals.tf`
    - Define `local.default_scrape_jobs` for kube-state-metrics, node-exporter, kubelet
    - Merge with `var.additional_scrape_jobs`
    - Render `scrape_configuration_yaml` with global scrape_interval/scrape_timeout
    - Compute `scrape_configuration_base64` via `base64encode`
    - Honor `var.scrape_configuration` override (skip defaults when non-empty)
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [x] 5.2 Create `modules/eks-monitoring/collector-managed.tf` for AMP Managed Collector
    - `aws_prometheus_scraper.this` gated by `local.is_managed_metrics`
    - Link to EKS cluster ARN, AMP workspace ARN, security groups, subnets
    - Pass `local.scrape_configuration_base64`
    - No Helm charts deployed for this profile (`local.needs_otel_helm` is false)
    - _Requirements: 2.1, 2.2, 2.4, 2.5, 2.6, 2.7_

  - [x] 5.3 Add self-managed-amp OTel Collector config to `modules/eks-monitoring/locals.tf`
    - Build `local.otel_collector_values` YAML branch for `self-managed-amp` profile
    - Configure `prometheusremotewrite` exporter with SigV4 service `aps` → AMP endpoint
    - Configure `otlphttp/xray` exporter for traces (X-Ray)
    - Configure `otlphttp/cwlogs` exporter for logs (CloudWatch Logs)
    - Wire pipelines: metrics `[prometheus, otlp] → [batch] → [prometheusremotewrite]`, traces `[otlp] → [batch] → [otlphttp/xray]`, logs `[otlp] → [batch] → [otlphttp/cwlogs]`
    - _Requirements: 3.3, 3.4_

  - [x] 5.4 Extend `modules/eks-monitoring/iam.tf` for self-managed-amp IRSA policies
    - Attach `AmazonPrometheusRemoteWriteAccess` for self-managed-amp
    - Attach `AWSXrayWriteOnlyAccess` for self-managed-amp traces
    - Conditionally attach policies based on `local.is_self_managed_amp`
    - _Requirements: 3.2, 5.3_

  - [x] 5.5 Create `modules/eks-monitoring/rules.tf` and `modules/eks-monitoring/alerts.tf`
    - `aws_prometheus_rule_group_namespace.recording_rules` gated by `var.enable_recording_rules`
    - `aws_prometheus_rule_group_namespace.alerting_rules` gated by `var.enable_alerting_rules`
    - Merge default infrastructure rules with `var.custom_recording_rules` and `var.custom_alerting_rules`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

  - [ ]* 5.6 Write property tests for scrape config renderer
    - **Property 6: Scrape config renderer merges jobs and applies global settings** — For any additional jobs list and interval/timeout, verify all default + additional jobs present and global settings applied
    - **Property 7: Scrape configuration base64 round trip** — For any YAML string, verify `base64decode(base64encode(x)) == x`
    - **Property 8: Custom scrape configuration overrides defaults** — For any non-empty custom config, verify passthrough without default jobs
    - **Validates: Requirements 7.2, 7.3, 7.4, 7.5**

  - [ ]* 5.7 Write property tests for AMP and rules
    - **Property 9: AMP workspace endpoint URL format** — For any workspace ID and region, verify endpoint = `https://aps-workspaces.{region}.amazonaws.com/workspaces/{id}/`
    - **Property 10: Custom rules are appended to default rules** — For any custom rule YAML, verify both default and custom rules present in output
    - **Validates: Requirements 8.4, 9.3, 11.1**

  - [x] 5.8 Create `examples/eks-amp-managed/` and `examples/eks-amp-otel/` example configurations
    - `eks-amp-managed/`: `collector_profile = "managed-metrics"` with subnet IDs, security groups
    - `eks-amp-otel/`: `collector_profile = "self-managed-amp"` with AMP workspace
    - Each with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`
    - _Requirements: 1.2, 1.3, 2.1, 3.1_

- [x] 6. Checkpoint — Validate AMP flavor end-to-end
  - Run `terraform validate` on the module and both AMP examples
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Shared validation and property tests
  - [ ]* 7.1 Write property test for profile validation
    - **Property 1: Profile validation is exhaustive** — For any random string, validation passes iff value is in `["managed-metrics", "self-managed-amp", "cloudwatch-otlp"]`
    - **Validates: Requirements 1.1, 1.5**

  - [ ]* 7.2 Write property test for subnet validation
    - **Property 2: Subnet count validation** — For any list with length 1 (non-zero < 2), validation fails; for length >= 2 or length == 0, validation passes
    - **Validates: Requirements 2.2, 2.3**

  - [ ]* 7.3 Write property test for dashboard git tag in URLs
    - **Property 5: Default dashboard URLs contain the configured git tag** — For any non-empty git tag string, every default dashboard URL contains that tag
    - **Validates: Requirements 6.3**

- [x] 8. Migration guide and cleanup
  - [x] 8.1 Create `UPGRADING.md` documenting migration from v2.x → v3.0.0
    - Document removed variables and their replacements
    - Document profile selection replacing boolean toggles
    - Document FluxCD/Grafana Operator removal and `grafana_dashboard` replacement
    - Document EKS Blueprints v4 dependency removal
    - Document new provider requirements (Grafana provider)
    - _Requirements: 5.1, 5.5, 6.4_

  - [x] 8.2 Remove deprecated submodules and patterns
    - Remove `modules/eks-monitoring/add-ons/` directory (adot-operator, aws-for-fluentbit, external-secrets)
    - Remove `modules/eks-monitoring/patterns/` directory (java, nginx, istio)
    - Remove `modules/eks-monitoring/otel-config/` Helm chart directory
    - _Requirements: 5.1, 5.2_

- [x] 9. Final checkpoint — Full module validation
  - Run `terraform validate` on the complete module and all examples
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Documentation refresh (Hugo site in `docs/`)
  - [x] 10.1 Rewrite `docs/eks/index.md` for v3 profile-driven architecture
    - Replace ADOT/FluxCD/Grafana Operator references with OTel Collector profiles
    - Update getting-started walkthrough to use `examples/eks-amp-otel/` (self-managed-amp) as the primary AMP path
    - Add section for `managed-metrics` profile (agentless) as an alternative
    - Update dashboard section: remove `kubectl get grafanadashboards`, document `grafana_dashboard` Terraform resource and `dashboard_delivery_method`
    - Update custom metrics section: replace `enable_custom_metrics`/`custom_metrics_config` with `additional_scrape_jobs`
    - Update prerequisites to include Grafana Terraform provider setup

  - [x] 10.2 Add `docs/eks/cloudwatch-otlp.md` for CloudWatch flavor
    - Document `cloudwatch-otlp` profile setup using `examples/eks-cloudwatch-otlp/`
    - Cover CloudWatch OTLP metrics endpoint (Zeus), traces, logs configuration
    - Document Grafana PromQL datasource for CloudWatch metrics
    - Document PMD IAM policy scope and guidance for namespace restriction

  - [x] 10.3 Update or deprecate workload-specific doc pages
    - `docs/eks/java.md` — update to show `additional_scrape_jobs` for JMX metrics, or mark deprecated
    - `docs/eks/nginx.md` — update to show `additional_scrape_jobs` for NGINX metrics, or mark deprecated
    - `docs/eks/istio.md` — update to show `additional_scrape_jobs` for Istio metrics, or mark deprecated
    - `docs/eks/tracing.md` — update for OTel Collector traces pipeline (self-managed-amp `enable_tracing`, cloudwatch-otlp built-in)
    - `docs/eks/logs.md` — update for OTel Collector logs pipeline (self-managed-amp `enable_logs`, cloudwatch-otlp built-in)

  - [x] 10.4 Update `docs/eks/troubleshooting.md`
    - Remove ADOT operator troubleshooting steps
    - Add OTel Collector pod troubleshooting (logs, config validation)
    - Add AMP Managed Collector scraper troubleshooting
    - Update Helm-related troubleshooting for Helm provider v3

- [x] 11. Legacy examples refresh
  - [x] 11.1 Rewrite `examples/eks-amp-otel-getting-started/` for v3
    - This is the primary getting-started example referenced in Hugo docs and the AMP docs page
    - Update to use `collector_profile = "self-managed-amp"` (closest to the old default behavior)
    - Replace old variable names with v3 variables
    - Update README.md with v3 setup instructions
    - Ensure backward compatibility with the AMP docs page walkthrough flow (same env var names where possible)

  - [x] 11.2 Update or remove workload-specific examples
    - `examples/eks-amp-otel-java/` — rewrite to use `additional_scrape_jobs` or remove
    - `examples/eks-amp-otel-nginx/` — rewrite to use `additional_scrape_jobs` or remove
    - `examples/eks-amp-otel-istio/` — rewrite to use `additional_scrape_jobs` or remove

  - [x] 11.3 Update multi-cluster and cross-account examples
    - `examples/eks-amp-cross-account/` — update module interface to v3 variables
    - `examples/eks-multicluster/` — update module interface to v3 variables

  - [x] 11.4 Update `modules/eks-monitoring/README.md`
    - Regenerate resource/variable/output tables for v3 module
    - Remove references to ADOT, FluxCD, Grafana Operator, EKS Blueprints v4
    - Document the three collector profiles with usage examples
    - Document `dashboard_delivery_method` and BYO GitOps approach

- [x] 12. External documentation coordination (prepare in advance, merge with doc team publish)
  - [x] 12.1 Prepare replacement AMP docs page example using managed scraper
    - Create a polished `examples/eks-amp-otel-getting-started/` rewrite that uses `collector_profile = "managed-metrics"` (agentless managed scraper)
    - Write a step-by-step walkthrough matching the structure of the current AMP docs page (https://docs.aws.amazon.com/prometheus/latest/userguide/obs_accelerator.html)
    - Preserve same env var names where possible (`TF_VAR_eks_cluster_id`, `TF_VAR_managed_prometheus_workspace_id`, `TF_VAR_managed_grafana_workspace_id`, `TF_VAR_grafana_api_key`)
    - Document the new resources created (AMP workspace, managed scraper, Grafana dashboards via Terraform)
    - Prepare a draft doc page update for the doc team to review
    - Hold merge until doc team publishes the updated page

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Stream 1 (CloudWatch flavor, tasks 3.x) is prioritized for internal demo ahead of Zeus launch
- Stream 2 (AMP flavor, tasks 5.x) can be deferred until after the CloudWatch demo
- The module path stays at `modules/eks-monitoring/` — versioning is via git tag `v3.0.0`
- Property tests use `fast-check` (TypeScript) with minimum 100 iterations per property
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation between streams
