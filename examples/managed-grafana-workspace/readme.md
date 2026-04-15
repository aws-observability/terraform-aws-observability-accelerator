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

### Assign a user to the workspace

A new workspace has no users — you must assign at least one SSO user or group
before you can log in. Use the AWS console (Grafana → Workspace → Authentication tab)
or the CLI:

```bash
aws grafana update-permissions \
  --workspace-id $(terraform output -raw grafana_workspace_id) \
  --update-instruction-batch \
    'action=ADD,role=ADMIN,users=[{id=<SSO_USER_ID>,type=SSO_USER}]' \
  --region us-east-1
```

See [Manage user and group access](https://docs.aws.amazon.com/grafana/latest/userguide/AMG-manage-users-and-groups-AMG.html)
for details on finding your SSO user ID and assigning users via console or API.

Then pass the outputs to any monitoring example:

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
