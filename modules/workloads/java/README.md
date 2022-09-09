# Java based workloads monitoring

This module provides monitoring for Java based workloads with the following resources:

- AWS Distro For OpenTelemetry Operator and Collector
- AWS Managed Grafana Dashboard and data source
- Alerts and recording rules with AWS Managed Service for Prometheus

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 1.25.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | >= 1.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons/helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_rule_group_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [grafana_dashboard.this](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    irsa_iam_permissions_boundary  = string<br>    irsa_iam_role_path             = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_amp_endpoint"></a> [amp\_endpoint](#input\_amp\_endpoint) | Amazon Managed Prometheus endpoint | `string` | n/a | yes |
| <a name="input_amp_id"></a> [amp\_id](#input\_amp\_id) | Managed Prometheus workspace id | `string` | n/a | yes |
| <a name="input_amp_region"></a> [amp\_region](#input\_amp\_region) | Amazon Managed Prometheus Workspace's Region | `string` | `null` | no |
| <a name="input_dashboards_folder_id"></a> [dashboards\_folder\_id](#input\_dashboards\_folder\_id) | Grafana folder ID for automatic dashboards | `string` | n/a | yes |
| <a name="input_enable_recording_rules"></a> [enable\_recording\_rules](#input\_enable\_recording\_rules) | Enable AMP recording rules | `bool` | `true` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Prometheus | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
