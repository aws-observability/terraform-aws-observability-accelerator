# External Secrets Operator Kubernetes addon

This deploys an EKS Cluster with the External Secrets Operator. The cluster is populated with a ClusterSecretStore and ExternalSecret using Grafana API Key secret from AWS SSM Parameter Store. A secret store for each AWS SSM Parameter Store is created. Store use IRSA (IAM Roles For Service Account) to retrieve the secret values from AWS.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 2.0.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 2.0.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_secretstore_role"></a> [cluster\_secretstore\_role](#module\_cluster\_secretstore\_role) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/irsa | v4.32.1 |
| <a name="module_external_secrets"></a> [external\_secrets](#module\_external\_secrets) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/external-secrets | v4.32.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.cluster_secretstore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_key.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_ssm_parameter.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [kubectl_manifest.cluster_secretstore](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.secret](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_enable_external_secrets"></a> [enable\_external\_secrets](#input\_enable\_external\_secrets) | Enable external-secrets | `bool` | `true` | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Grafana API key for the Amazon Managed Grafana workspace | `string` | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for external secrets | `any` | `{}` | no |
| <a name="input_target_secret_name"></a> [target\_secret\_name](#input\_target\_secret\_name) | Name to store the secret for Grafana API Key | `string` | n/a | yes |
| <a name="input_target_secret_namespace"></a> [target\_secret\_namespace](#input\_target\_secret\_namespace) | Namespace to store the secret for Grafana API Key | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
