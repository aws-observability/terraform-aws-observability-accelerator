# Managed Grafana Setup
This example creates a Managed Grafana Workspace and Identity Centre Users for it.

# Deployment Instructions

1. Supply variables first name, last name, email address in either terraform.tfvars file, as a default in the variables.tf file, or in the command line at runtime
2. Once deployed, you will need to get the identity centre admin to send a verification email to users
3. When you have accepted the verification email, you can then sign in to the grafana workspace



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_grafana"></a> [managed\_grafana](#module\_managed\_grafana) | terraform-aws-modules/managed-service-grafana/aws | 1.8.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_workspace_endpoint"></a> [grafana\_workspace\_endpoint](#output\_grafana\_workspace\_endpoint) | Amazon Managed Grafana Workspace endpoint |
| <a name="output_grafana_workspace_iam_role_arn"></a> [grafana\_workspace\_iam\_role\_arn](#output\_grafana\_workspace\_iam\_role\_arn) | Amazon Managed Grafana Workspace's IAM Role ARN |
| <a name="output_grafana_workspace_id"></a> [grafana\_workspace\_id](#output\_grafana\_workspace\_id) | Amazon Managed Grafana Workspace ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
