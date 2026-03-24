# EKS CloudWatch OTLP Example

Self-contained example that deploys full EKS observability via CloudWatch OTLP.
A single `./install.sh` creates everything — Grafana workspace, service account,
datasource, dashboards, and CloudWatch Agent.

## What gets deployed

- Amazon Managed Grafana workspace with service account + API token
- Grafana Prometheus datasource pointing at CloudWatch PromQL endpoint (SigV4 auth)
- Infrastructure dashboards (cluster, kubelet, nodes, workloads, namespace-workloads, node-exporter)
- Amazon CloudWatch Observability Helm chart (CW Agent DaemonSet, Fluent Bit, kube-state-metrics, node-exporter, cluster scraper)
- `CloudWatchAgentServerPolicy` attached to EKS node IAM role

## Prerequisites

- An existing EKS cluster with at least one managed node group
- AWS IAM Identity Center (SSO) configured in the account (for Grafana auth)
- Terraform >= 1.5.0

## Quick start

```bash
./install.sh -var="eks_cluster_id=my-cluster" -var="aws_region=us-west-2"
```

The script runs two Terraform applies:
1. Creates Grafana workspace, CloudWatch Agent, and supporting infra
2. Uses the Grafana service account token from step 1 to provision dashboards

### Pre-release testing with a local chart

To test with an internal build of the CloudWatch Agent chart:

```bash
./install.sh \
  -var="eks_cluster_id=my-cluster" \
  -var="aws_region=us-west-2" \
  -var="cw_agent_chart_path=/path/to/cloudwatch-agent/helm/amazon-cloudwatch-observability"
```

## Manual two-step apply

If you prefer not to use the script:

```bash
# Step 1: Create infra (dashboards skipped — no Grafana token yet)
terraform init
terraform apply -var="eks_cluster_id=my-cluster"

# Step 2: Grab the token and re-apply with dashboards
terraform apply \
  -var="eks_cluster_id=my-cluster" \
  -var="grafana_endpoint=$(terraform output -raw grafana_workspace_endpoint)" \
  -var="grafana_api_key=$(terraform output -raw grafana_api_key)"
```

## Outputs

- `grafana_workspace_endpoint` — open this URL to view dashboards
- `grafana_workspace_id` — workspace ID for AWS CLI operations
- `cloudwatch_promql_datasource` — datasource connection details
- `cw_agent_namespace` — Kubernetes namespace where the CW Agent runs

## Cleanup

```bash
terraform destroy -var="eks_cluster_id=my-cluster"
```
