# CloudWatch OTLP monitoring on Amazon EKS

This guide covers the `cloudwatch-otlp` collector profile, which sends metrics,
traces, and logs to Amazon CloudWatch using the OTLP protocol via an
OpenTelemetry Collector deployed in your cluster.

## Overview

The `cloudwatch-otlp` profile deploys an OpenTelemetry Collector that:

- Scrapes Prometheus metrics from kube-state-metrics, node-exporter, and kubelet
- Accepts application telemetry via OTLP (gRPC :4317, HTTP :4318)
- Exports metrics to the CloudWatch OTLP endpoint using SigV4 authentication
- Exports traces to AWS X-Ray via OTLP
- Exports logs to CloudWatch Logs via OTLP

A Grafana PromQL datasource is automatically configured to query CloudWatch
metrics using the Prometheus-compatible query API.

## Prerequisites

- An existing Amazon EKS cluster
- A CloudWatch OTLP metrics endpoint URL for your region
- An [Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/what-is-Amazon-Managed-Service-Grafana.html) workspace
- The [Grafana Terraform provider](https://registry.terraform.io/providers/grafana/grafana/latest/docs) configured

## Quick start

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

#### 3. Grafana API key

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

## Module configuration

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile            = "cloudwatch-otlp"
  eks_cluster_id               = var.eks_cluster_id
  eks_oidc_provider_arn        = var.eks_oidc_provider_arn
  cloudwatch_metrics_endpoint  = var.cloudwatch_metrics_endpoint
  cloudwatch_log_group         = var.cloudwatch_log_group
  cloudwatch_log_stream        = var.cloudwatch_log_stream

  enable_dashboards = true
  tags              = var.tags
}
```

## IAM permissions

The module creates an IRSA role for the OTel Collector with the following
policies:

- `cloudwatch:PutMetricData` — custom policy for metrics export
- `CloudWatchLogsFullAccess` — managed policy for logs export
- `AWSXrayWriteOnlyAccess` — managed policy for traces export

The `cloudwatch:PutMetricData` permission uses `Resource = "*"` without
namespace scoping. The OTel Collector sends metrics across multiple CloudWatch
namespaces (infrastructure metrics from kube-state-metrics, node-exporter,
kubelet, plus application metrics via OTLP).

If you need to restrict PutMetricData to specific namespaces:

1. Override the IRSA role policy externally by creating a more restrictive
   policy and attaching it to the role
2. Use `helm_values` to configure the OTel Collector to prefix all metric
   namespaces, then scope the IAM policy with `StringLike` on
   `aws:cloudwatch:namespace`

The IRSA role is scoped to the `otel-collector` service account in the
collector namespace, limiting the blast radius.

## Grafana PromQL datasource

The module automatically creates a Grafana Prometheus datasource pointing at
the CloudWatch PromQL endpoint. This allows the standard infrastructure
dashboards to query CloudWatch metrics using PromQL.

The datasource uses SigV4 authentication with service `monitoring`. You can
customize the datasource name with `grafana_cw_datasource_name`.

## Sending application telemetry

Applications in the cluster can send telemetry to the OTel Collector via OTLP:

```yaml
env:
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://otel-collector.otel-collector.svc.cluster.local:4317"
```

Metrics, traces, and logs sent via OTLP are routed to CloudWatch, X-Ray, and
CloudWatch Logs respectively.

## Customization

Override OTel Collector Helm chart values:

```hcl
module "eks_monitoring" {
  # ...
  helm_values = {
    "replicaCount" = "2"
  }
}
```

Add custom scrape targets:

```hcl
module "eks_monitoring" {
  # ...
  additional_scrape_jobs = [
    {
      job_name = "my-app"
      static_configs = [
        { targets = ["my-app.default.svc.cluster.local:9090"] }
      ]
    }
  ]
}
```
