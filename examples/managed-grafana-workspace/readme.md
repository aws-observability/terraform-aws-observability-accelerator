# Amazon Managed Grafana Workspace

Creates an Amazon Managed Grafana workspace with a service account token
for Terraform-driven dashboard provisioning.

## What it provisions

- Amazon Managed Grafana workspace (v10.4) with CloudWatch, Prometheus, and X-Ray datasources
- IAM Identity Center (SSO) authentication
- Service account with ADMIN role and a 30-day API token

## Prerequisites

- AWS IAM Identity Center (SSO) configured in the account
- Terraform >= 1.3

## Usage

```bash
terraform init
terraform apply -var="aws_region=us-east-1"
```

Pass the outputs to any monitoring example:

```bash
cd ../eks-cloudwatch-otlp
./install.sh \
  -var="eks_cluster_id=my-cluster" \
  -var="grafana_endpoint=$(cd ../managed-grafana-workspace && terraform output -raw grafana_workspace_endpoint)" \
  -var="grafana_api_key=$(cd ../managed-grafana-workspace && terraform output -raw grafana_api_key)"
```

## Outputs

| Name | Description |
|------|-------------|
| `grafana_workspace_endpoint` | Workspace URL |
| `grafana_workspace_id` | Workspace ID |
| `grafana_workspace_iam_role_arn` | Workspace IAM role ARN |
| `grafana_api_key` | Service account token (sensitive, 30-day TTL) |
