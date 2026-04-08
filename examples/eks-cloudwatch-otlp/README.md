# EKS CloudWatch OTLP Example

Deploys EKS observability via the Amazon CloudWatch Observability EKS add-on,
with optional Grafana dashboards in a "CloudWatch Container Insights" folder.

## What gets deployed

- `amazon-cloudwatch-observability` EKS add-on (CW Agent DaemonSet, Fluent Bit, kube-state-metrics, node-exporter)
- IAM role for Pod Identity with `CloudWatchAgentServerPolicy`
- Grafana dashboards (9 dashboards: cluster, containers, gpu-fleet, kubelet, nodes, workloads, namespace-workloads, node-exporter, unified-service) — when Grafana endpoint is provided

## Prerequisites

### 1. EKS cluster

You need a running EKS cluster with at least one managed node group.

```bash
eksctl create cluster --name my-cluster --region us-east-1 --version 1.32 \
  --nodegroup-name system --node-type t3.medium --nodes 2 --managed
```

### 2. EKS Pod Identity Agent add-on

The CW Agent uses EKS Pod Identity for IAM credentials. Install the agent:

```bash
aws eks create-addon --cluster-name my-cluster --addon-name eks-pod-identity-agent --region us-east-1
```

### 3. Grafana workspace (optional — for dashboards)

To provision dashboards, you need an Amazon Managed Grafana workspace with a
service account token. Use the [`managed-grafana-workspace`](../managed-grafana-workspace/)
example.

### 4. Terraform >= 1.5

## Quick start

CW Agent only (no dashboards):

```bash
terraform init
terraform apply -var="eks_cluster_id=my-cluster" -var="aws_region=us-east-1"
```

With Grafana dashboards:

```bash
terraform apply \
  -var="eks_cluster_id=my-cluster" \
  -var="aws_region=us-east-1" \
  -var="grafana_endpoint=https://g-xxxxx.grafana-workspace.us-east-1.amazonaws.com" \
  -var="grafana_api_key=glsa_xxxxx"
```

## Verify

```bash
# Add-on status
aws eks describe-addon --cluster-name my-cluster \
  --addon-name amazon-cloudwatch-observability --region us-east-1 \
  --query '{status:addon.status,version:addon.addonVersion}'

# Pods running
kubectl get pods -n amazon-cloudwatch

# Agent logs (check for credential errors)
kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=cloudwatch-agent --tail=20
```

Metrics should appear in the CloudWatch console under Container Insights within 3-5 minutes.

## Outputs

| Name | Description |
|------|-------------|
| `cloudwatch_promql_datasource` | Datasource connection details for Grafana |

## Cleanup

```bash
terraform destroy -var="eks_cluster_id=my-cluster" -var="aws_region=us-east-1"
```
