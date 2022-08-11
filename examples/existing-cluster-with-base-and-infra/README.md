# Existing Cluster

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_observability_accelerator"></a> [eks\_observability\_accelerator](#module\_eks\_observability\_accelerator) | ../../ | n/a |
| <a name="module_workloads_infra"></a> [workloads\_infra](#module\_workloads\_infra) | ../../workloads/infra | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana | `string` | `""` | no |
| <a name="input_grafana_endpoint"></a> [grafana\_endpoint](#input\_grafana\_endpoint) | Grafana endpoint | `string` | `null` | no |
| <a name="input_java"></a> [java](#input\_java) | n/a | `map` | <pre>{<br>  "a": "",<br>  "b": ""<br>}</pre> | no |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | n/a | `string` | `""` | no |
| <a name="input_managed_prometheus_endpoint"></a> [managed\_prometheus\_endpoint](#input\_managed\_prometheus\_endpoint) | n/a | `string` | `""` | no |
| <a name="input_managed_prometheus_region"></a> [managed\_prometheus\_region](#input\_managed\_prometheus\_region) | n/a | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS Region |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | n/a |
| <a name="output_prometheus_endpoint"></a> [prometheus\_endpoint](#output\_prometheus\_endpoint) | n/a |
| <a name="output_prometheus_id"></a> [prometheus\_id](#output\_prometheus\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
