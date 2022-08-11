# Observability Pattern for Java/JMX

This module provides an automated experience around Observability for Nginx workloads.
It provides the following resources:

- AWS Distro For OpenTelemetry Operator and Collector
- AWS Managed Grafana Dashboard and data source
- Alerts and recording rules with AWS Managed Service for Prometheus

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 1.25.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons/helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_rule_group_namespace.api-availability](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.apibr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.apihg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.apislos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.etcd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.generic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubeapps](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubelet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubeprom-recording](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubepromnr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kuberesources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubescheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubestm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubestorage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubesys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubesysapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubesyschdlr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubesyscm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubesyskblt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubesyskbpxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.kubprom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.ne](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.nodeexporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.nodenw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.noderules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [grafana_dashboard.alertmanager](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.apis](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.cluster](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.clusternw](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.controller](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.coredns](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.etcd](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.grafana](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.kubelet](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.macos](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.necluster](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nenode](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nenodeuse](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nodes](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsnw](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsnwworkload](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nspods](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsworkload](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.nwworload](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.podnetwork](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.pods](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.prometheus](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.proxy](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.pv](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.scheduler](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [grafana_dashboard.workloads](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/dashboard) | resource |
| [helm_release.kube_state_metrics](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_node_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | n/a | <pre>object({<br>    helm_config = map(any)<br><br>    kms_create_namespace   = bool<br>    ksm_k8s_namespace      = string<br>    ksm_helm_chart_name    = string<br>    ksm_helm_chart_version = string<br>    ksm_helm_release_name  = string<br>    ksm_helm_repo_url      = string<br>    ksm_helm_settings      = map(string)<br>    ksm_helm_values        = map(any)<br><br>    ne_create_namespace   = bool<br>    ne_k8s_namespace      = string<br>    ne_helm_chart_name    = string<br>    ne_helm_chart_version = string<br>    ne_helm_release_name  = string<br>    ne_helm_repo_url      = string<br>    ne_helm_settings      = map(string)<br>    ne_helm_values        = map(any)<br><br>  })</pre> | <pre>{<br>  "enable_kube_state_metrics": true,<br>  "enable_node_exporter": true,<br>  "helm_config": {},<br>  "kms_create_namespace": true,<br>  "ksm_helm_chart_name": "kube-state-metrics",<br>  "ksm_helm_chart_version": "4.9.2",<br>  "ksm_helm_release_name": "kube-state-metrics",<br>  "ksm_helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "ksm_helm_settings": {},<br>  "ksm_helm_values": {},<br>  "ksm_k8s_namespace": "kube-system",<br>  "ne_create_namespace": true,<br>  "ne_helm_chart_name": "prometheus-node-exporter",<br>  "ne_helm_chart_version": "2.0.3",<br>  "ne_helm_release_name": "prometheus-node-exporter",<br>  "ne_helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "ne_helm_settings": {},<br>  "ne_helm_values": {},<br>  "ne_k8s_namespace": "prometheus-node-exporter"<br>}</pre> | no |
| <a name="input_dashboards_folder_id"></a> [dashboards\_folder\_id](#input\_dashboards\_folder\_id) | n/a | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_enable_alerting_rules"></a> [enable\_alerting\_rules](#input\_enable\_alerting\_rules) | n/a | `bool` | `true` | no |
| <a name="input_enable_dashboards"></a> [enable\_dashboards](#input\_enable\_dashboards) | n/a | `bool` | `true` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | n/a | `bool` | `true` | no |
| <a name="input_enable_node_exporter"></a> [enable\_node\_exporter](#input\_enable\_node\_exporter) | n/a | `bool` | `true` | no |
| <a name="input_enable_recording_rules"></a> [enable\_recording\_rules](#input\_enable\_recording\_rules) | n/a | `bool` | `true` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Prometheus | `any` | `{}` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#input\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint | `string` | `null` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus Workspace ID | `string` | `null` | no |
| <a name="input_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#input\_managed\_prometheus\_workspace\_region) | Amazon Managed Prometheus Workspace's Region | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
