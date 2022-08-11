# AWS Observability Accelerator for Terraform

Welcome to AWS Observability Accelerator for Terraform!

## Getting Started


## Documentation


## Examples


## Usage


## Submodules


## Motivation


## Support & Feedback

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 1.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_grafana"></a> [managed\_grafana](#module\_managed\_grafana) | terraform-aws-modules/managed-service-grafana/aws | ~> 1.3 |
| <a name="module_operator"></a> [operator](#module\_operator) | ./modules/add-ons/adot-operator | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_alert_manager_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_alert_manager_definition) | resource |
| [aws_prometheus_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [grafana_data_source.amp](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/data_source) | resource |
| [grafana_folder.this](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/folder) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_grafana_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/grafana_workspace) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_enable_alertmanager"></a> [enable\_alertmanager](#input\_enable\_alertmanager) | Create AMP AlertManager for all workloads | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_adot"></a> [enable\_amazon\_eks\_adot](#input\_enable\_amazon\_eks\_adot) | n/a | `bool` | `true` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Allow reusing an existing installation of cert-manager | `bool` | `true` | no |
| <a name="input_enable_infra_metrics"></a> [enable\_infra\_metrics](#input\_enable\_infra\_metrics) | n/a | `bool` | `false` | no |
| <a name="input_enable_java"></a> [enable\_java](#input\_enable\_java) | Deploys a collector for JAVA/JMX based workloads, dashboards and alerting rules | `bool` | `false` | no |
| <a name="input_enable_java_recording_rules"></a> [enable\_java\_recording\_rules](#input\_enable\_java\_recording\_rules) | Enable AMP recording rules for Java | `bool` | `true` | no |
| <a name="input_enable_managed_grafana"></a> [enable\_managed\_grafana](#input\_enable\_managed\_grafana) | n/a | `bool` | `true` | no |
| <a name="input_enable_managed_prometheus"></a> [enable\_managed\_prometheus](#input\_enable\_managed\_prometheus) | n/a | `bool` | `true` | no |
| <a name="input_enable_opentelemetry_operator"></a> [enable\_opentelemetry\_operator](#input\_enable\_opentelemetry\_operator) | n/a | `bool` | `false` | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | n/a | `string` | `null` | no |
| <a name="input_infra_metrics_config"></a> [infra\_metrics\_config](#input\_infra\_metrics\_config) | n/a | <pre>object({<br>    helm_config = map(any)<br><br>    enable_kube_state_metrics = bool<br>    kms_create_namespace      = bool<br>    ksm_k8s_namespace         = string<br>    ksm_helm_chart_name       = string<br>    ksm_helm_chart_version    = string<br>    ksm_helm_release_name     = string<br>    ksm_helm_repo_url         = string<br>    ksm_helm_settings         = map(string)<br>    ksm_helm_values           = map(any)<br><br>    enable_node_exporter  = bool<br>    ne_create_namespace   = bool<br>    ne_k8s_namespace      = string<br>    ne_helm_chart_name    = string<br>    ne_helm_chart_version = string<br>    ne_helm_release_name  = string<br>    ne_helm_repo_url      = string<br>    ne_helm_settings      = map(string)<br>    ne_helm_values        = map(any)<br><br>    enable_dashboards = bool<br>  })</pre> | `null` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_managed_grafana_region"></a> [managed\_grafana\_region](#input\_managed\_grafana\_region) | AWS Managed Grafana Workspace Region | `string` | `null` | no |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | n/a | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | AWS Managed Prometheus Workspace ID | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#input\_managed\_prometheus\_workspace\_region) | AWS Managed Prometheus Workspace Region | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | EKS Cluster Id |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | n/a |
| <a name="output_grafana_dashboards_folder_id"></a> [grafana\_dashboards\_folder\_id](#output\_grafana\_dashboards\_folder\_id) | n/a |
| <a name="output_managed_grafana_workspace_endpoint"></a> [managed\_grafana\_workspace\_endpoint](#output\_managed\_grafana\_workspace\_endpoint) | n/a |
| <a name="output_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#output\_managed\_prometheus\_workspace\_endpoint) | n/a |
| <a name="output_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#output\_managed\_prometheus\_workspace\_id) | n/a |
| <a name="output_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#output\_managed\_prometheus\_workspace\_region) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/LICENSE).
