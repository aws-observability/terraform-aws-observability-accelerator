# Infrastructure monitoring

This module provides EKS cluster monitoring with the following resources:

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
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons/helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_rule_group_namespace.alerting_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.recording_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [grafana_dashboard.cluster](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.clusternw](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.kubelet](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nodes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsnw](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsnwworkload](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nspods](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsworkload](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nwworload](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.podnetwork](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.pods](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.workloads](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [helm_release.kube_state_metrics](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_node_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dashboards_folder_id"></a> [dashboards\_folder\_id](#input\_dashboards\_folder\_id) | Grafana folder ID for automatic dashboards | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_enable_alerting_rules"></a> [enable\_alerting\_rules](#input\_enable\_alerting\_rules) | Enables or disables Managed Prometheus alerting rules | `bool` | `true` | no |
| <a name="input_enable_dashboards"></a> [enable\_dashboards](#input\_enable\_dashboards) | Enables or disables curated dashboards | `bool` | `true` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | Enables or disables Kube State metrics exporter. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_node_exporter"></a> [enable\_node\_exporter](#input\_enable\_node\_exporter) | Enables or disables Node exporter. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_recording_rules"></a> [enable\_recording\_rules](#input\_enable\_recording\_rules) | Enables or disables Managed Prometheus recording rules. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Prometheus | `any` | `{}` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_ksm_config"></a> [ksm\_config](#input\_ksm\_config) | Kube State metrics configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "kube-state-metrics",<br>  "helm_chart_version": "4.16.0",<br>  "helm_release_name": "kube-state-metrics",<br>  "helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "kube-system"<br>}</pre> | no |
| <a name="input_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#input\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint | `string` | `null` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus Workspace ID | `string` | `null` | no |
| <a name="input_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#input\_managed\_prometheus\_workspace\_region) | Amazon Managed Prometheus Workspace's Region | `string` | `null` | no |
| <a name="input_ne_config"></a> [ne\_config](#input\_ne\_config) | Node exporter configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "prometheus-node-exporter",<br>  "helm_chart_version": "2.0.3",<br>  "helm_release_name": "prometheus-node-exporter",<br>  "helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "prometheus-node-exporter"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
