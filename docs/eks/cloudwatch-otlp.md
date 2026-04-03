# CloudWatch OTLP monitoring on Amazon EKS

This guide covers the `cloudwatch-otlp` collector profile, which sends metrics,
traces, and logs to Amazon CloudWatch using the OTLP protocol via an
OpenTelemetry Collector deployed in your cluster.

## Overview

The `cloudwatch-otlp` profile deploys an OpenTelemetry Collector that:

- Scrapes Prometheus metrics from kube-state-metrics, node-exporter, and kubelet
- Accepts application telemetry via OTLP (gRPC :4317, HTTP :4318)
- Exports metrics to `https://monitoring.<region>.amazonaws.com/v1/metrics`
- Exports traces to `https://xray.<region>.amazonaws.com/v1/traces`
- Exports logs to `https://logs.<region>.amazonaws.com/v1/logs` (requires `cloudwatch_log_group`)

All exports use SigV4 authentication. A Grafana PromQL datasource is
automatically configured to query CloudWatch metrics at
`https://monitoring.<region>.amazonaws.com`.

See the [CloudWatch OTLP Endpoints documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-OTLPEndpoint.html)
for endpoint limits and restrictions.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ EKS Cluster                                                 │
│                                                             │
│  kube-state-metrics ──┐                                     │
│  node-exporter ───────┤ scrape    ┌──────────────────────┐  │
│  kubelet/cadvisor ────┘           │  OTel Collector      │  │
│                          ────────►│  (otel-collector ns)  │  │
│  Your apps ──── OTLP ───────────►│                        │  │
│                                   └──────┬───┬───┬───────┘  │
└──────────────────────────────────────────┼───┼───┼──────────┘
                                           │   │   │
                          metrics (SigV4)  │   │   │  logs (SigV4)
                     ┌─────────────────────┘   │   └──────────────┐
                     ▼                         │                  ▼
              CloudWatch Metrics          traces (SigV4)   CloudWatch Logs
              (PromQL queryable)               │
                     │                         ▼
                     │                    AWS X-Ray
                     ▼
              Amazon Managed Grafana
              (PromQL datasource)
```

## Prerequisites

1. An existing Amazon EKS cluster ([create one](../helpers/new-eks-cluster.md))
2. An [Amazon Managed Grafana](../helpers/managed-grafana.md) workspace with at
   least one SSO user assigned — see
   [Manage user and group access](https://docs.aws.amazon.com/grafana/latest/userguide/AMG-manage-users-and-groups-AMG.html)
3. A Grafana API key (service account token with Admin role)

## Quick start

### 1. Create prerequisites (if needed)

```bash
# EKS cluster
cd examples/eks-cluster-with-vpc
terraform init && terraform apply -var="aws_region=us-east-1"

# Grafana workspace
cd ../managed-grafana-workspace
terraform init && terraform apply -var="aws_region=us-east-1"
```

After creating the Grafana workspace, assign an SSO user:

```bash
aws grafana update-permissions \
  --workspace-id <WORKSPACE_ID> \
  --update-instruction-batch \
    'action=ADD,role=ADMIN,users=[{id=<SSO_USER_ID>,type=SSO_USER}]' \
  --region us-east-1
```

### 2. Configure and deploy

```bash
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
./install.sh
```

### 3. Verify

```bash
# OTel Collector running
kubectl get pods -n otel-collector

# Inspect collector config
kubectl get configmap -n otel-collector \
  otel-collector-opentelemetry-collector \
  -o jsonpath='{.data.relay}' | head -60

# Check collector logs
kubectl logs -n otel-collector \
  -l app.kubernetes.io/name=opentelemetry-collector --tail=20
```

### 4. Enable vended metrics enrichment (optional)

CloudWatch OTel enrichment adds AWS resource attributes (`@aws.account`,
`@aws.region`, `@resource.k8s.cluster.name`) to your metrics automatically.

```bash
aws observabilityadmin start-telemetry-enrichment
aws cloudwatch start-o-tel-enrichment
```

Both commands are idempotent. Run once per account.

## Module configuration

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile = "cloudwatch-otlp"
  eks_cluster_id    = var.eks_cluster_id

  # Logs (optional — requires a log group)
  cloudwatch_log_group  = "/eks/my-cluster/otel"
  cloudwatch_log_stream = "collector"

  # Dashboards (requires grafana_endpoint + grafana_api_key)
  enable_dashboards = true

  tags = var.tags
}
```

## Dashboards

The module provisions 6 dashboards into Grafana, optimized for the CloudWatch
PromQL datasource with enriched attribute support:

| Dashboard | Key metrics |
|-----------|-------------|
| Cluster | CPU/memory usage, pod counts, network I/O |
| Kubelet | Kubelet operations, PLEG relist, pod start latency |
| Nodes | Node resource allocation, capacity vs requests |
| Node Exporter | CPU, memory, disk, network per node |
| Namespace Workloads | Resource usage by namespace and workload type |
| Workloads | Per-workload CPU, memory, network, storage |

Dashboards include `k8s_cluster_name` and `aws_account` variables for
multi-cluster and cross-account filtering.

## Sending application telemetry

Applications in the cluster can send OTLP telemetry to the collector:

```yaml
env:
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://otel-collector-opentelemetry-collector.otel-collector.svc.cluster.local:4317"
  - name: OTEL_RESOURCE_ATTRIBUTES
    value: "service.namespace=my-team,service.name=my-app"
```

Metrics, traces, and logs are routed to CloudWatch, X-Ray, and CloudWatch Logs
respectively.

### Demo application

Deploy the [OpenTelemetry Python sample app](https://github.com/aws-observability/aws-otel-community/tree/main/sample-apps/python-auto-instrumentation-sample-app)
to generate application metrics:

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-demo-app
  namespace: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: python-demo-app
  template:
    metadata:
      labels:
        app: python-demo-app
    spec:
      containers:
        - name: app
          image: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/python-demo-app:latest
          env:
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: http://otel-collector-opentelemetry-collector.otel-collector.svc.cluster.local:4317
            - name: OTEL_RESOURCE_ATTRIBUTES
              value: service.namespace=demo,service.name=python-demo-app
EOF
```

Query in Grafana Explore:

```promql
{@resource.service.name="python-demo-app"}
```

## IAM permissions

The module creates an IRSA role with:

| Policy | Signal |
|--------|--------|
| `CloudWatchAgentServerPolicy` | Metrics |
| `AWSXrayWriteOnlyAccess` | Traces (when `enable_tracing = true`) |
| `CloudWatchLogsFullAccess` | Logs (when `enable_logs = true`) |

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

Override endpoints (e.g. for VPC endpoints or testing):

```hcl
module "eks_monitoring" {
  # ...
  cloudwatch_metrics_endpoint = "https://monitoring.us-east-1.amazonaws.com/v1/metrics"
  cloudwatch_traces_endpoint  = "https://xray.us-east-1.amazonaws.com/v1/traces"
  cloudwatch_logs_endpoint    = "https://logs.us-east-1.amazonaws.com/v1/logs"
}
```

## Cleanup

```bash
cd examples/eks-cloudwatch-otlp
./destroy.sh
```

The `destroy.sh` script uninstalls Helm releases before running
`terraform destroy` to avoid timeout issues.
