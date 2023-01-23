# Deployment Instructions
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_grafana_role_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_role_association) | resource |
| [aws_grafana_workspace.workshop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace) | resource |
| [aws_iam_role.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | OPTIONAL ID for identity store | `string` | `""` | no |
| <a name="input_identitystore_admins_info"></a> [identitystore\_admins\_info](#input\_identitystore\_admins\_info) | The minimum required data to create aws identity store users with admin access to the grafana workspace | <pre>list(object({<br>    first_name = string<br>    last_name  = string<br>    email      = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_workspace_endpoint"></a> [grafana\_workspace\_endpoint](#output\_grafana\_workspace\_endpoint) | The Grafana Workspace endpoint |
| <a name="output_grafana_workspace_id"></a> [grafana\_workspace\_id](#output\_grafana\_workspace\_id) | The Grafana Workspace ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
1. Supply first name, last name, email address in either terraform.tfvars file, as a default in the variables.tf file, or in the command line at runtime
2. Once deployed, you will need to get the identity centre admin to send a verification email to users
3. When you have accepted the verification email, you can then sign in to the grafana workspace
