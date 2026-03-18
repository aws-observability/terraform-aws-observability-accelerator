# EKS Monitoring Module (v3)

Profile-driven EKS cluster monitoring with three collector profiles:

| Profile | Backend | Collector | Best for |
|---------|---------|-----------|----------|
| `managed-metrics` | Amazon Managed Prometheus | AMP Managed Collector (agentless) | Simplest setup, no in-cluster pods |
| `self-managed-amp` | Amazon Managed Prometheus | OpenTelemetry Collector (Helm) | Full pipeline control, traces + logs |
| `cloudwatch-otlp` | Amazon CloudWatch | OpenTelemetry Collector (Helm) | CloudWatch-native observability |

All profiles deploy kube-state-metrics and node-exporter for infrastructure
metrics, and provision Grafana dashboards for cluster visibility.

## Prerequisites

- The EKS cluster must have an [IAM OIDC identity provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) registered in your account (required for IRSA). The module auto-derives the OIDC provider ARN from the cluster; if the provider does not exist, `terraform plan` will fail with a clear error. You can override with `eks_oidc_provider_arn` if needed.

## Usage

### Self-managed AMP (most common)

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = "my-cluster"
  enable_tracing        = true
  enable_logs           = true
}
```

### Managed metrics (agentless)

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile          = "managed-metrics"
  eks_cluster_id             = "my-cluster"
  scraper_subnet_ids         = module.vpc.private_subnets
  scraper_security_group_ids = [aws_security_group.scraper.id]
}
```

### CloudWatch OTLP

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile           = "cloudwatch-otlp"
  eks_cluster_id              = "my-cluster"
  cloudwatch_metrics_endpoint = "https://monitoring.us-west-2.amazonaws.com/v1/metrics"
  cloudwatch_log_group        = "/eks/my-cluster/otel"
  cloudwatch_log_stream       = "collector"
}
```

## Dashboard delivery

Control how dashboards are provisioned with `dashboard_delivery_method`:

- `"terraform"` (default) — provisions via `grafana_dashboard` resources
- `"none"` — skips provisioning; use `dashboard_sources` and datasource config
  outputs for BYO GitOps (FluxCD, ArgoCD, etc.)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |
| helm | >= 3.0.0 |
| grafana | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `collector_profile` | Collector profile: `managed-metrics`, `self-managed-amp`, `cloudwatch-otlp` | `string` | n/a | yes |
| `eks_cluster_id` | EKS cluster identifier | `string` | n/a | yes |
| `eks_oidc_provider_arn` | ARN of the EKS OIDC provider for IRSA (auto-derived if empty) | `string` | `""` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |
| `enable_dashboards` | Whether to provision Grafana dashboards | `bool` | `true` | no |
| `dashboard_delivery_method` | `terraform` or `none` | `string` | `"terraform"` | no |
| `dashboard_sources` | Map of dashboard names to JSON source URLs | `map(string)` | `{}` | no |
| `dashboard_git_tag` | Git tag for default dashboard JSON URLs | `string` | `"v0.3.2"` | no |
| `grafana_folder_id` | Grafana folder ID for dashboards | `string` | `null` | no |
| `create_amp_workspace` | Whether to create a new AMP workspace | `bool` | `true` | no |
| `managed_prometheus_workspace_id` | Existing AMP workspace ID | `string` | `null` | no |
| `amp_workspace_alias` | Alias for new AMP workspace | `string` | `"eks-monitoring"` | no |
| `enable_alerting_rules` | Create Prometheus alerting rules | `bool` | `true` | no |
| `enable_recording_rules` | Create Prometheus recording rules | `bool` | `true` | no |
| `custom_alerting_rules` | Additional alerting rule YAML | `string` | `""` | no |
| `custom_recording_rules` | Additional recording rule YAML | `string` | `""` | no |
| `scraper_subnet_ids` | Subnet IDs for managed scraper (>= 2 AZs) | `list(string)` | `[]` | no |
| `scraper_security_group_ids` | Security group IDs for managed scraper | `list(string)` | `[]` | no |
| `scrape_configuration` | Custom Prometheus scrape config YAML (overrides defaults) | `string` | `""` | no |
| `additional_scrape_jobs` | Additional scrape jobs to append to defaults | `list(any)` | `[]` | no |
| `prometheus_config` | Global scrape interval/timeout settings | `object` | `{}` | no |
| `otel_collector_chart_version` | OTel Collector Helm chart version | `string` | `"0.78.0"` | no |
| `kube_state_metrics_chart_version` | kube-state-metrics Helm chart version | `string` | `"5.15.2"` | no |
| `node_exporter_chart_version` | node-exporter Helm chart version | `string` | `"4.24.0"` | no |
| `collector_namespace` | Kubernetes namespace for OTel Collector | `string` | `"otel-collector"` | no |
| `helm_values` | Additional Helm values for OTel Collector chart | `map(string)` | `{}` | no |
| `cloudwatch_metrics_endpoint` | CloudWatch OTLP metrics endpoint URL | `string` | `""` | no |
| `cloudwatch_log_group` | CloudWatch Logs log group name | `string` | `""` | no |
| `cloudwatch_log_stream` | CloudWatch Logs log stream name | `string` | `""` | no |
| `grafana_cw_datasource_name` | Grafana datasource name for CloudWatch PromQL | `string` | `"CloudWatch PromQL"` | no |
| `enable_tracing` | Enable traces pipeline (self-managed-amp only) | `bool` | `true` | no |
| `enable_logs` | Enable logs pipeline (self-managed-amp only) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| `managed_prometheus_workspace_endpoint` | AMP workspace endpoint URL |
| `managed_prometheus_workspace_id` | AMP workspace ID |
| `managed_prometheus_workspace_region` | AMP workspace region |
| `collector_irsa_arn` | IRSA role ARN for OTel Collector (self-managed profiles) |
| `amp_scraper_arn` | AMP Managed Collector scraper ARN (managed-metrics profile) |
| `eks_cluster_id` | EKS cluster identifier |
| `cloudwatch_promql_datasource_config` | Grafana datasource config for CloudWatch PromQL (cloudwatch-otlp) |
| `amp_datasource_config` | Grafana datasource config for AMP (AMP profiles, for BYO GitOps) |
| `dashboard_sources` | Map of dashboard names to JSON URLs (for BYO GitOps) |

## Resources

| Name | Type |
|------|------|
| `aws_prometheus_workspace.this` | resource |
| `aws_prometheus_scraper.this` | resource |
| `aws_prometheus_rule_group_namespace.recording_rules` | resource |
| `aws_prometheus_rule_group_namespace.alerting_rules` | resource |
| `aws_iam_policy.cloudwatch_put_metric` | resource |
| `module.collector_irsa_role` | module |
| `helm_release.otel_collector` | resource |
| `helm_release.kube_state_metrics` | resource |
| `helm_release.prometheus_node_exporter` | resource |
| `grafana_dashboard.this` | resource |
| `grafana_data_source.cloudwatch_promql` | resource |

## Upgrading from v2.x

See [UPGRADING.md](../../UPGRADING.md) for migration guide.

## Documentation

Full documentation: [https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/)
