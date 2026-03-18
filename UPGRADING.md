# Upgrading to v3.0.0

This guide covers migrating from `v2.x` to `v3.0.0` of the `modules/eks-monitoring/` module.

v3.0.0 is a complete rewrite that replaces the EKS Blueprints v4 architecture with a
profile-driven design. This is a **breaking change** — existing configurations will need
to be updated.

## What Changed

### Profile-driven architecture

The module now uses a single `collector_profile` variable instead of boolean toggles:

| v2.x approach | v3.0.0 replacement |
|---|---|
| `enable_managed_prometheus = true` + ADOT operator | `collector_profile = "managed-metrics"` |
| ADOT Collector → AMP remote write | `collector_profile = "self-managed-amp"` |
| *(new)* CloudWatch OTLP | `collector_profile = "cloudwatch-otlp"` |

### EKS Blueprints v4 dependency removed

The module no longer depends on EKS Blueprints v4 constructs. All Helm deployments use
`helm_release` directly. IRSA uses `terraform-aws-modules/iam/aws`.

### FluxCD and Grafana Operator removed

Dashboard delivery now uses the `grafana_dashboard` Terraform resource from the Grafana
provider. FluxCD and the Grafana Operator are no longer deployed or required.

### ADOT Operator removed

The ADOT (AWS Distro for OpenTelemetry) operator add-on is replaced by a direct
`helm_release` of the upstream OpenTelemetry Collector chart for profiles that need it.

### Workload patterns removed

The `patterns/` subdirectory (Java, NGINX, Istio, Memcached) has been removed. Workload-
specific scrape targets can be added via `additional_scrape_jobs` or `helm_values`.

## Removed Variables

The following variables no longer exist. Remove them from your module call:

| Removed variable | Migration path |
|---|---|
| `enable_amazon_eks_adot` | Replaced by `collector_profile` selection |
| `enable_managed_prometheus` | Use `collector_profile = "managed-metrics"` or `"self-managed-amp"` |
| `enable_alertmanager` | Removed; configure alerting externally |
| `enable_cert_manager` | No longer needed |
| `helm_config` | Use `helm_values` for OTel Collector overrides |
| `irsa_iam_role_name` | Managed automatically based on `eks_cluster_id` |
| `irsa_iam_role_path` | Removed |
| `irsa_iam_permissions_boundary` | Removed |
| `irsa_iam_additional_policies` | Removed |
| `adot_loglevel` | Configure via `helm_values` |
| `adot_service_telemetry_loglevel` | Configure via `helm_values` |
| `managed_prometheus_workspace_endpoint` | Computed automatically from workspace ID |
| `managed_prometheus_workspace_region` | Uses current AWS region from provider |
| `managed_prometheus_cross_account_role` | Removed |
| `enable_kube_state_metrics` | Always deployed (required by all profiles) |
| `ksm_config` | Managed internally; override via `helm_values` |
| `enable_node_exporter` | Always deployed (required by all profiles) |
| `ne_config` | Managed internally; override via `helm_values` |
| `enable_custom_metrics` | Use `additional_scrape_jobs` or `helm_values` |
| `custom_metrics_config` | Use `additional_scrape_jobs` or `helm_values` |
| `enable_java` | Removed; add Java scrape targets via `additional_scrape_jobs` |
| `java_config` | Removed |
| `enable_nginx` | Removed; add NGINX scrape targets via `additional_scrape_jobs` |
| `nginx_config` | Removed |
| `enable_istio` | Removed; add Istio scrape targets via `additional_scrape_jobs` |
| `istio_config` | Removed |
| `enable_fluxcd` | FluxCD no longer used |
| `flux_config` | FluxCD no longer used |
| `flux_kustomization_name` | FluxCD no longer used |
| `flux_gitrepository_name` | FluxCD no longer used |
| `flux_gitrepository_url` | FluxCD no longer used |
| `flux_gitrepository_branch` | Use `dashboard_git_tag` instead |
| `flux_kustomization_path` | FluxCD no longer used |
| `enable_grafana_operator` | Grafana Operator no longer used |
| `go_config` | Grafana Operator no longer used |
| `enable_external_secrets` | External Secrets no longer used |
| `grafana_api_key` | Configure the Grafana Terraform provider directly |
| `grafana_url` | Configure the Grafana Terraform provider directly |
| `grafana_*_dashboard_url` | Use `dashboard_sources` map or accept defaults |
| `target_secret_name` | External Secrets no longer used |
| `target_secret_namespace` | External Secrets no longer used |
| `enable_adotcollector_metrics` | Removed |
| `enable_nvidia_monitoring` | Removed; add GPU scrape targets via `additional_scrape_jobs` |
| `nvidia_monitoring_config` | Removed |
| `adothealth_monitoring_config` | Removed |
| `kubeproxy_monitoring_config` | Removed |
| `enable_apiserver_monitoring` | Removed; add API server scrape targets via `additional_scrape_jobs` |
| `apiserver_monitoring_config` | Removed |
| `tracing_config` | Configure via `helm_values` or use profile defaults |
| `logs_config` | Configure via `cloudwatch_log_group` / `cloudwatch_log_stream` |

## New Required Variables

| Variable | Description |
|---|---|
| `collector_profile` | One of `managed-metrics`, `self-managed-amp`, `cloudwatch-otlp` |

## Prerequisites

The EKS cluster must have an [IAM OIDC identity provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) registered in your account for IRSA to work. The module auto-derives the OIDC provider ARN from the cluster data source. If the provider does not exist, `terraform plan` will fail with a clear error. You can override with `eks_oidc_provider_arn` if needed (e.g. cross-account setups).

## New Provider Requirements

v3.0.0 requires the Grafana Terraform provider when `enable_dashboards = true`:

```hcl
provider "grafana" {
  url  = "https://your-grafana-workspace.grafana-workspace.us-west-2.amazonaws.com"
  auth = var.grafana_api_key
}

module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = {
    grafana = grafana
  }

  # ...
}
```

If you don't need dashboards, set `enable_dashboards = false` and no Grafana provider is
required.

## Migration Examples

### v2.x AMP with ADOT → v3.0.0 self-managed-amp

Before (v2.x):
```hcl
module "eks_monitoring" {
  source = "...?ref=v2.5.0"

  eks_cluster_id            = "my-cluster"
  enable_managed_prometheus = true
  enable_amazon_eks_adot    = true
  enable_grafana_operator   = true
  enable_fluxcd             = true
  grafana_api_key           = var.grafana_api_key
  grafana_url               = var.grafana_url
  enable_tracing            = true
  enable_logs               = true
  # ... 20+ more variables
}
```

After (v3.0.0):
```hcl
module "eks_monitoring" {
  source = "...?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile      = "self-managed-amp"
  eks_cluster_id         = "my-cluster"
  enable_tracing         = true
  enable_logs            = true
}
```

### v2.x AMP → v3.0.0 managed-metrics (agentless)

After (v3.0.0):
```hcl
module "eks_monitoring" {
  source = "...?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile          = "managed-metrics"
  eks_cluster_id             = "my-cluster"
  scraper_subnet_ids         = module.vpc.private_subnets
  scraper_security_group_ids = [aws_security_group.scraper.id]
}
```

### New: CloudWatch OTLP (v3.0.0 only)

```hcl
module "eks_monitoring" {
  source = "...?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile            = "cloudwatch-otlp"
  eks_cluster_id               = "my-cluster"
  cloudwatch_metrics_endpoint  = "https://monitoring.us-west-2.amazonaws.com/v1/metrics"
  cloudwatch_log_group         = "/eks/my-cluster/otel"
  cloudwatch_log_stream        = "collector"
}
```

## Removed Submodules

The following subdirectories have been removed:

- `modules/eks-monitoring/add-ons/` — ADOT operator, AWS for FluentBit, External Secrets
- `modules/eks-monitoring/patterns/` — Java, NGINX, Istio, Memcached workload patterns
- `modules/eks-monitoring/otel-config/` — Custom Helm chart for OTel Collector config

These are replaced by the profile-driven OTel Collector configuration generated in
`locals.tf`. Workload-specific scrape targets can be added via `additional_scrape_jobs`.

## State Migration

Because v3.0.0 replaces all resources, a clean `terraform destroy` of the v2.x module
followed by `terraform apply` with v3.0.0 is the recommended migration path. In-place
`terraform apply` will remove v2.x resources and create v3.0.0 resources, but resource
address changes mean Terraform will destroy-then-create rather than update in place.

If you need to preserve the AMP workspace, set `create_amp_workspace = false` and pass
the existing workspace ID via `managed_prometheus_workspace_id`. Then import or let
Terraform manage the workspace separately.


## Helm Provider v3 Requirement

v3.0.0 requires Helm Terraform provider `>= 3.0.0`. The Helm provider v3 changed `set`
from a nested block to a list attribute. If you are currently on Helm provider v2, you
will need to upgrade. Run `terraform init -upgrade` after updating your module reference.

## CloudWatch PutMetricData IAM Policy

The `cloudwatch-otlp` profile grants `cloudwatch:PutMetricData` on `Resource = "*"`
without namespace scoping. This is intentional — the OTel Collector sends metrics across
multiple CloudWatch namespaces (infrastructure metrics from kube-state-metrics,
node-exporter, kubelet, plus application metrics via OTLP), and the Zeus OTLP endpoint
may not support the `aws:cloudwatch:namespace` condition key.

If you need to restrict PutMetricData to specific namespaces, you can:
1. Set `collector_profile = "cloudwatch-otlp"` and override the IRSA role policy
   externally by creating a more restrictive policy and attaching it to the role
2. Use `helm_values` to configure the OTel Collector to prefix all metric namespaces,
   then scope the IAM policy with `StringLike` on `aws:cloudwatch:namespace`

The IRSA role is scoped to the `otel-collector` service account in the collector
namespace, limiting the blast radius to pods running with that service account.

## Dashboard Delivery Method

v3.0.0 introduces `dashboard_delivery_method` (default: `"terraform"`):

- `"terraform"` — Module provisions dashboards via `grafana_dashboard` resources (default)
- `"none"` — Module skips dashboard provisioning; use the `dashboard_sources` and
  `amp_datasource_config` / `cloudwatch_promql_datasource_config` outputs to wire up
  your own FluxCD, ArgoCD, or Grafana Operator pipeline

This replaces the v2.x FluxCD + Grafana Operator approach. FluxCD support may be
re-introduced as a delivery method in a future release.
