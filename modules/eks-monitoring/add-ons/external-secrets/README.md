# External Secrets Operator Kubernetes addon

This example deploys an EKS Cluster with the External Secrets Operator. The cluster is populated with a ClusterSecretStore and SecretStore example using AWS Secret Manager and Parameter Store respectively. A secret for each store is also created. Both stores use IRSA (IAM Roles For Service Account) to retrieve the secret values from AWS.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_external_secrets"></a> [external\_secrets](#module\_external\_manager) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/external-secrets | v4.28.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [kubectl_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource || [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | datasource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_enable_external_secrets"></a> [enable\_external\_secrets](#input\_enable\_external\_secrets) | Enable external secrets to read Grafana API Key | `bool` | `true` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for external-secrets | `any` | <pre>{<br>  "version": "v1.8.2"<br>}</pre> | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Grafana API Key | `string` | n/a | yes |
| <a name="input_target_secret_name"></a> [target\_secret\_name](#input\_target\_secret\_name) | Target secret to store Grafana API Key Secret | `string` | grafana-admin-credentials | yes |
| <a name="input_target_secret_namespace"></a> [target\_secret\_namespace](#input\_target\_secret\_namespace) | Target Namespace to store Grafana API Key Secret | `string` | grafana-operator | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

