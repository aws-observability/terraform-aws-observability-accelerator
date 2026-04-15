# CloudWatch OTLP monitoring on Amazon EKS

This guide covers the `cloudwatch-otlp` collector profile, which uses the
Amazon CloudWatch Observability EKS add-on for Container Insights with an
optional OTLP gateway for application metrics.

## Overview

The `cloudwatch-otlp` profile deploys:

- **CW Agent DaemonSet** — scrapes cAdvisor, node-exporter, and kubelet metrics
- **Cluster scraper** — scrapes kube-state-metrics and API server metrics
- **OTLP gateway** (optional) — accepts application OTLP telemetry and forwards
  to CloudWatch via SigV4
- **kube-state-metrics** and **node-exporter** — infrastructure metric sources

All metrics are exported to the CloudWatch OTLP endpoint and queryable via
PromQL in Amazon Managed Grafana.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ EKS Cluster                                                 │
│                                                             │
│  kube-state-metrics ──┐  scrape   ┌───────────────────────┐ │
│  API server ──────────┤──────────►│  Cluster Scraper      │ │
│                       │           └───────────┬───────────┘ │
│                       │                       │             │
│  cAdvisor ────────────┤  scrape   ┌───────────┴───────────┐ │
│  node-exporter ───────┤──────────►│  CW Agent DaemonSet   │ │
│  kubelet ─────────────┘           └───────────┬───────────┘ │
│                                               │             │
│  Your apps ──── OTLP ────────────►┌───────────┴───────────┐ │
│                                   │  OTLP Gateway         │ │
│                                   └───────────┬───────────┘ │
└───────────────────────────────────────────────┼─────────────┘
                                                │ SigV4
                                                ▼
                                   CloudWatch OTLP Endpoint
                                   (PromQL queryable)
                                                │
                                                ▼
                                   Amazon Managed Grafana
```

## Prerequisites

1. An existing Amazon EKS cluster
2. [EKS Pod Identity Agent](https://docs.aws.amazon.com/eks/latest/userguide/pod-id-agent-setup.html) add-on installed
3. An [Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/what-is-Amazon-Managed-Service-Grafana.html)
   workspace (v12+) with a service account token (for dashboards)

## Quick start

```bash
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/eks-cloudwatch-otlp
terraform init
```

Create `terraform.tfvars`:

```hcl
eks_cluster_id   = "my-cluster"
aws_region       = "us-east-1"
grafana_endpoint = "https://g-xxx.grafana-workspace.us-east-1.amazonaws.com"
grafana_api_key  = "glsa_xxx"
```

```bash
terraform apply
```

### Verify

```bash
# Add-on and pods
kubectl get pods -n amazon-cloudwatch

# Cluster scraper logs (kube-state-metrics pipeline)
kubectl logs -n amazon-cloudwatch deploy/cloudwatch-agent-cluster-scraper --tail=10

# OTLP gateway (if enabled)
kubectl get amazoncloudwatchagent cwa-otlp-gateway -n amazon-cloudwatch
```

Container Insights metrics appear in CloudWatch within 3–5 minutes.

## Module configuration

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile      = "cloudwatch-otlp"
  eks_cluster_id         = var.eks_cluster_id
  cw_agent_addon_version = "v6.0.1-eksbuild.1"

  # OTLP gateway for application metrics
  enable_otlp_gateway = true

  # Dashboards
  enable_dashboards = true

  tags = var.tags
}
```

## Dashboards

The module provisions 4 dashboards into a "CloudWatch Container Insights"
Grafana folder, plus CloudWatch Logs and X-Ray datasources:

| Dashboard | Key metrics |
|-----------|-------------|
| Container Insights / Containers | Pod status, CPU/memory per container, network, filesystem I/O |
| Container Insights / Nodes | Node CPU, memory, disk, load, network per node and nodegroup |
| GPU Fleet Utilization | DCGM GPU utilization, memory, power, clock, EFA, Neuron metrics |
| Unified Service Dashboard | Cross-signal view: metrics (PromQL), logs (CloudWatch), traces (X-Ray) |

Dashboards use CloudWatch OTLP `@resource.*` label conventions. Variables
auto-discover datasources by type.

!!! note
    Dashboards require Amazon Managed Grafana v12+ for `@`-prefixed label support.

## Sending application telemetry

Applications send OTLP to the gateway at `cwa-otlp-gateway.amazon-cloudwatch`:

```yaml
env:
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://cwa-otlp-gateway.amazon-cloudwatch:4315"
  - name: OTEL_RESOURCE_ATTRIBUTES
    value: "service.namespace=my-team,service.name=my-app"
```

Query in Grafana Explore:

```promql
{`@resource.service.name`="my-app"}
```

## IAM permissions

The module creates a Pod Identity role with `CloudWatchAgentServerPolicy`,
which covers metrics, logs, and traces export.

## Cleanup

```bash
terraform destroy
```
