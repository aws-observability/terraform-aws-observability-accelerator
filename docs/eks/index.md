# Amazon EKS cluster monitoring

This guide demonstrates how to monitor your Amazon Elastic Kubernetes Service
(Amazon EKS) cluster with the Observability Accelerator's
[EKS monitoring module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring).

## Overview

The EKS monitoring module uses a profile-driven architecture with three
collector profiles:

| Profile | Backend | Collector | Best for |
|---------|---------|-----------|----------|
| `cloudwatch-otlp` | Amazon CloudWatch | OpenTelemetry Collector (Helm) | CloudWatch-native observability with OTLP |
| `managed-metrics` | Amazon Managed Prometheus | AMP Managed Collector (agentless) | Agentless setup, no in-cluster collector to manage |
| `self-managed-amp` | Amazon Managed Prometheus | OpenTelemetry Collector (Helm) | Full control over collection pipeline, traces + logs support |

All profiles deploy [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
and [node-exporter](https://github.com/prometheus/node_exporter) for infrastructure
metrics, and provision Grafana dashboards for cluster visibility.

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.

- An existing Amazon EKS cluster
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- An [Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/what-is-Amazon-Managed-Service-Grafana.html) workspace (for dashboards)

## Quick start — CloudWatch OTLP profile

This walkthrough uses the `cloudwatch-otlp` profile, which deploys an
OpenTelemetry Collector to send metrics, traces, and logs to Amazon CloudWatch
using the OTLP protocol.

#### 1. Clone and initialize

```bash
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/eks-cloudwatch-otlp
terraform init
```

#### 2. Configure variables

```bash
export TF_VAR_eks_cluster_id=my-cluster
export TF_VAR_aws_region=us-west-2
export TF_VAR_cloudwatch_metrics_endpoint="https://monitoring.us-west-2.amazonaws.com/v1/metrics"
export TF_VAR_cloudwatch_log_group="/eks/my-cluster/otel"
export TF_VAR_cloudwatch_log_stream="collector"
```

#### 3. Amazon Managed Grafana workspace

If you don't have an Amazon Managed Grafana workspace, follow
[our helper guide](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/managed-grafana/)
to create one.

v3.0.0 uses the [Grafana Terraform provider](https://registry.terraform.io/providers/grafana/grafana/latest/docs)
to provision dashboards. Configure it in your root module:

```hcl
provider "grafana" {
  url  = "https://${var.managed_grafana_workspace_id}.grafana-workspace.${var.aws_region}.amazonaws.com"
  auth = var.grafana_api_key
}
```

Generate a short-lived API key:

```bash
export TF_VAR_managed_grafana_workspace_id=g-xxx
export TF_VAR_grafana_api_key=$(aws grafana create-workspace-api-key \
  --key-name "observability-accelerator-$(date +%s)" \
  --key-role ADMIN \
  --seconds-to-live 7200 \
  --workspace-id $TF_VAR_managed_grafana_workspace_id \
  --query key --output text)
```

#### 4. Deploy

```bash
terraform apply
```

#### 5. Visualization

Open your Amazon Managed Grafana workspace. The module provisions infrastructure
dashboards (cluster, kubelet, namespace workloads, node-exporter, nodes,
workloads) via the `grafana_dashboard` Terraform resource. The CloudWatch OTLP
profile uses a Prometheus-compatible PromQL datasource backed by CloudWatch.

For more details, see the [CloudWatch OTLP guide](cloudwatch-otlp.md).

## Managed-metrics profile (agentless AMP scraper)

The `managed-metrics` profile uses the
[AMP Managed Collector](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-collector.html)
— a fully managed, agentless scraper that runs outside your cluster. No
OpenTelemetry Collector pods are deployed. Metrics-only (no traces or logs).

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile          = "managed-metrics"
  eks_cluster_id             = var.eks_cluster_id
  scraper_subnet_ids         = var.scraper_subnet_ids         # >= 2 subnets in 2 AZs
  scraper_security_group_ids = var.scraper_security_group_ids
}
```

!!! note
    The managed scraper requires at least 2 subnets in 2 distinct Availability
    Zones. See the [managed-metrics example](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/examples/eks-amp-managed).

## Self-managed AMP profile

The `self-managed-amp` profile deploys an OpenTelemetry Collector via Helm to
scrape Prometheus metrics and remote-write to Amazon Managed Prometheus. It
supports metrics, traces (X-Ray), and logs (CloudWatch Logs).

```bash
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/eks-amp-otel
terraform init
```

```bash
export TF_VAR_eks_cluster_id=my-cluster
export TF_VAR_aws_region=us-west-2
```

By default the module creates a new AMP workspace. To use an existing one:

```bash
export TF_VAR_managed_prometheus_workspace_id=ws-xxx
```

And set `create_amp_workspace = false` in your module call.

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile = "self-managed-amp"
  eks_cluster_id    = var.eks_cluster_id
  enable_tracing    = true
  enable_logs       = true
}
```

See the [self-managed AMP example](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/examples/eks-amp-otel)
for a complete working configuration.

## Dashboards

The module provisions Grafana dashboards via the `grafana_dashboard` Terraform
resource. Default dashboards cover cluster, kubelet, namespace workloads,
node-exporter, nodes, and workloads views.

You can control dashboard delivery with `dashboard_delivery_method`:

- `"terraform"` (default) — the module provisions dashboards directly
- `"none"` — skip provisioning; use the `dashboard_sources` and
  `amp_datasource_config` / `cloudwatch_promql_datasource_config` outputs to
  wire up your own GitOps pipeline (FluxCD, ArgoCD, etc.)

To override the default dashboard set, pass a custom `dashboard_sources` map:

```hcl
module "eks_monitoring" {
  # ...
  dashboard_sources = {
    my-custom = "https://example.com/my-dashboard.json"
  }
}
```

## Custom metrics and scrape jobs

To scrape additional workload metrics (Java/JMX, NGINX, Istio, your own apps),
use the `additional_scrape_jobs` variable:

```hcl
module "eks_monitoring" {
  # ...
  additional_scrape_jobs = [
    {
      job_name        = "my-app"
      scrape_interval = "30s"
      static_configs = [
        { targets = ["my-app.default.svc.cluster.local:8080"] }
      ]
    }
  ]
}
```

For the `self-managed-amp` and `cloudwatch-otlp` profiles, you can also pass
arbitrary OTel Collector Helm values via `helm_values` for full pipeline
customization.

For the `managed-metrics` profile, you can provide a complete custom Prometheus
scrape configuration via `scrape_configuration` to override the defaults entirely.

## AMP recording and alerting rules

When using an AMP-backed profile (`managed-metrics` or `self-managed-amp`), the
module creates default infrastructure recording and alerting rules. You can
extend them with custom rules:

```hcl
module "eks_monitoring" {
  # ...
  enable_recording_rules = true
  enable_alerting_rules  = true

  custom_recording_rules = <<-YAML
    - record: my_custom:metric
      expr: sum(rate(http_requests_total[5m]))
  YAML

  custom_alerting_rules = <<-YAML
    - alert: HighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
      for: 5m
      labels:
        severity: critical
  YAML
}
```

!!! note
    To setup your alert receiver with Amazon SNS, follow
    [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html).

## Tracing and logs

The `self-managed-amp` profile supports traces and logs pipelines via the
OpenTelemetry Collector:

- **Traces** — enabled by default (`enable_tracing = true`), exported to
  AWS X-Ray via OTLP
- **Logs** — enabled by default (`enable_logs = true`), exported to
  CloudWatch Logs via OTLP

The `cloudwatch-otlp` profile includes traces and logs pipelines by default
with no additional configuration needed.

The `managed-metrics` profile is metrics-only (no traces or logs).

For details on instrumenting your applications, see the
[tracing guide](tracing.md) and [logs guide](logs.md).

## Upgrading from v2.x

If you are migrating from v2.x, see the [Upgrading to v3.0.0](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/UPGRADING.md)
guide for a complete list of removed variables, new requirements, and migration
examples.
