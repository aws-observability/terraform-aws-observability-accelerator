# EKS CloudWatch OTLP Example

Deploys EKS observability via CloudWatch OTLP — CloudWatch Agent, kube-state-metrics,
node-exporter, and optionally Grafana dashboards.

## What gets deployed

- Amazon CloudWatch Observability Helm chart (CW Agent DaemonSet, Fluent Bit, kube-state-metrics, node-exporter)
- `CloudWatchAgentServerPolicy` attached to EKS node IAM role
- Grafana dashboards (cluster, kubelet, nodes, workloads, namespace-workloads, node-exporter) — when Grafana endpoint is provided

## Prerequisites

### 1. EKS cluster

You need a running EKS cluster with at least one managed node group. Node roles
should include `CloudWatchAgentServerPolicy` and `AmazonEC2ContainerRegistryReadOnly`.

Use the [`eks-cluster-with-vpc`](../eks-cluster-with-vpc/) example to create one:

```bash
cd ../eks-cluster-with-vpc
terraform init && terraform apply -var="aws_region=us-east-1"
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_id) --region us-east-1
```

### 2. Grafana workspace (optional — for dashboards)

To provision dashboards, you need an Amazon Managed Grafana workspace with a
service account token. Use the [`managed-grafana-workspace`](../managed-grafana-workspace/)
example:

```bash
cd ../managed-grafana-workspace
terraform init && terraform apply -var="aws_region=us-east-1"
```

This requires AWS IAM Identity Center (SSO) configured in the account.

### 3. Terraform >= 1.5

## Quick start

CW Agent only (no dashboards):

```bash
./install.sh -var="eks_cluster_id=cw-otlp-test"
```

With Grafana dashboards:

```bash
./install.sh \
  -var="eks_cluster_id=cw-otlp-test" \
  -var="grafana_endpoint=$(cd ../managed-grafana-workspace && terraform output -raw grafana_workspace_endpoint)" \
  -var="grafana_api_key=$(cd ../managed-grafana-workspace && terraform output -raw grafana_api_key)"
```

### Pre-release testing with a local chart

```bash
./install.sh \
  -var="eks_cluster_id=cw-otlp-test" \
  -var="cw_agent_chart_path=/path/to/cloudwatch-agent/helm/amazon-cloudwatch-observability"
```

## Outputs

| Name | Description |
|------|-------------|
| `cloudwatch_promql_datasource` | Datasource connection details for Grafana |
| `cw_agent_namespace` | Kubernetes namespace where the CW Agent runs |

## Cleanup

```bash
./destroy.sh -var="eks_cluster_id=cw-otlp-test"
```
