# AWS Distro for OpenTelemetry (ADOT) Container Logs Collector

[AWS Distro for OpenTelemetry (ADOT)](https://aws-otel.github.io/) is a secure,
production-ready, AWS-supported distribution of the OpenTelemetry project.
Part of the Cloud Native Computing Foundation, OpenTelemetry provides open
source APIs, libraries, and agents to collect distributed traces and metrics
for application monitoring.

This module generates the
[ADOT Container Logs Collector](https://aws-otel.github.io/docs/getting-started/adot-eks-add-on/config-container-logs) configuration for Amazon EKS ADOT add-on.

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adot_logs_iam_role"></a> [adot\_logs\_iam\_role](#module\_adot\_logs\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.adot_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.adot_logs_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.adot_logs_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_config"></a> [addon\_config](#input\_addon\_config) | ADOT Container Logs Collector config | <pre>object({<br>    enable_logs = bool<br>    logs_config = object({<br>      cw_log_retention_days = number<br>    })<br>  })</pre> | <pre>{<br>  "enable_logs": true,<br>  "logs_config": {<br>    "cw_log_retention_days": 90<br>  }<br>}</pre> | no |
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adot_logs_collector_config"></a> [adot\_logs\_collector\_config](#output\_adot\_logs\_collector\_config) | ADOT Container Logs Collector configuration |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
