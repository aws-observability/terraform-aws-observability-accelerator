# EKS CloudWatch OTLP Example

Self-contained example that deploys full EKS observability via CloudWatch OTLP.
A single `./install.sh` creates everything — Grafana workspace, service account,
datasource, dashboards, and OTel Collector.

## What gets deployed

- Amazon Managed Grafana workspace with service account + API token
- Grafana Prometheus datasource pointing at CloudWatch PromQL endpoint (SigV4 auth)
- Infrastructure dashboards (cluster, kubelet, nodes, workloads, namespace-workloads, node-exporter)
- OpenTelemetry Collector via Helm (Prometheus receiver → CloudWatch OTLP exporter)
- kube-state-metrics and node-exporter Helm charts
- IRSA role with `cloudwatch:PutMetricData`, `CloudWatchLogsFullAccess`, and `AWSXrayWriteOnlyAccess`

## Prerequisites

- An existing EKS cluster with OIDC provider
- AWS IAM Identity Center (SSO) configured in the account (for Grafana auth)
- Terraform >= 1.5.0

## Quick start

```bash
./install.sh -var="eks_cluster_id=my-cluster" -var="aws_region=us-west-2"
```

The script runs two Terraform applies:
1. Creates Grafana workspace, OTel Collector, and supporting infra
2. Uses the Grafana service account token from step 1 to provision dashboards

The CloudWatch metrics endpoint defaults to `https://monitoring.<region>.amazonaws.com/v1/metrics`.

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
- `collector_irsa_arn` — IAM role used by the OTel Collector
- `cloudwatch_promql_datasource_config` — datasource connection details

## Cleanup

```bash
terraform destroy -var="eks_cluster_id=my-cluster"
```
