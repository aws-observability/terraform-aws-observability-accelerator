# Infrastructure monitoring

This module provides EKS cluster monitoring with the following resources:

- AWS Distro For OpenTelemetry Operator and Collector
- AWS Managed Grafana Dashboard and data source
- Alerts and recording rules with AWS Managed Service for Prometheus

This module is inspired from the open source [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
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
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon | v4.13.1 |
| <a name="module_java_monitoring"></a> [java\_monitoring](#module\_java\_monitoring) | ./patterns/java | n/a |
| <a name="module_nginx_monitoring"></a> [nginx\_monitoring](#module\_nginx\_monitoring) | ./patterns/nginx | n/a |
| <a name="module_operator"></a> [operator](#module\_operator) | ./add-ons/adot-operator | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_rule_group_namespace.alerting_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.recording_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [grafana_dashboard.cluster](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.kubelet](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nodeexp_nodes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nodes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.nsworkload](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
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
| <a name="input_custom_metrics_config"></a> [custom\_metrics\_config](#input\_custom\_metrics\_config) | Configuration object to enable custom metrics collection | <pre>object({<br>    ports = list(number)<br>    # paths = optional(list(string), ["/metrics"])<br>    # list of samples to be dropped by label prefix, ex: go_ -> discards go_.*<br>    dropped_series_prefixes = list(string)<br>  })</pre> | <pre>{<br>  "dropped_series_prefixes": [<br>    "unspecified"<br>  ],<br>  "ports": []<br>}</pre> | no |
| <a name="input_dashboards_folder_id"></a> [dashboards\_folder\_id](#input\_dashboards\_folder\_id) | Grafana folder ID for automatic dashboards | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_enable_alerting_rules"></a> [enable\_alerting\_rules](#input\_enable\_alerting\_rules) | Enables or disables Managed Prometheus alerting rules | `bool` | `true` | no |
| <a name="input_enable_amazon_eks_adot"></a> [enable\_amazon\_eks\_adot](#input\_enable\_amazon\_eks\_adot) | Enables the ADOT Operator on the EKS Cluster | `bool` | `true` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Allow reusing an existing installation of cert-manager | `bool` | `true` | no |
| <a name="input_enable_custom_metrics"></a> [enable\_custom\_metrics](#input\_enable\_custom\_metrics) | Allows additional metrics collection for config elements in the `custom_metrics_config` config object. Automatic dashboards are not included | `bool` | `false` | no |
| <a name="input_enable_dashboards"></a> [enable\_dashboards](#input\_enable\_dashboards) | Enables or disables curated dashboards | `bool` | `true` | no |
| <a name="input_enable_java"></a> [enable\_java](#input\_enable\_java) | Enable Java workloads monitoring, alerting and default dashboards | `bool` | `false` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | Enables or disables Kube State metrics exporter. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_nginx"></a> [enable\_nginx](#input\_enable\_nginx) | Enable NGINX workloads monitoring, alerting and default dashboards | `bool` | `false` | no |
| <a name="input_enable_node_exporter"></a> [enable\_node\_exporter](#input\_enable\_node\_exporter) | Enables or disables Node exporter. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_tracing"></a> [enable\_tracing](#input\_enable\_tracing) | (Experimental) Enables tracing with AWS X-Ray. This changes the deploy mode of the collector to daemon set. Requirement: adot add-on <= 0.58-build.0 | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Prometheus | `any` | `{}` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `null` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_java_config"></a> [java\_config](#input\_java\_config) | Configuration object for Java/JMX monitoring | <pre>object({<br>    enable_alerting_rules = bool<br>    scrape_sample_limit   = number<br>  })</pre> | <pre>{<br>  "enable_alerting_rules": true,<br>  "scrape_sample_limit": 1000<br>}</pre> | no |
| <a name="input_ksm_config"></a> [ksm\_config](#input\_ksm\_config) | Kube State metrics configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br><br>    scrape_interval = string<br>    scrape_timeout  = string<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "kube-state-metrics",<br>  "helm_chart_version": "4.24.0",<br>  "helm_release_name": "kube-state-metrics",<br>  "helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "kube-system",<br>  "scrape_interval": "60s",<br>  "scrape_timeout": "15s"<br>}</pre> | no |
| <a name="input_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#input\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus Workspace ID | `string` | `null` | no |
| <a name="input_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#input\_managed\_prometheus\_workspace\_region) | Amazon Managed Prometheus Workspace's Region | `string` | `null` | no |
| <a name="input_ne_config"></a> [ne\_config](#input\_ne\_config) | Node exporter configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br><br>    scrape_interval = string<br>    scrape_timeout  = string<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "prometheus-node-exporter",<br>  "helm_chart_version": "2.0.3",<br>  "helm_release_name": "prometheus-node-exporter",<br>  "helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "prometheus-node-exporter",<br>  "scrape_interval": "60s",<br>  "scrape_timeout": "60s"<br>}</pre> | no |
| <a name="input_nginx_config"></a> [nginx\_config](#input\_nginx\_config) | Configuration object for NGINX monitoring | <pre>object({<br>    enable_alerting_rules       = bool<br>    scrape_sample_limit         = number<br>    prometheus_metrics_endpoint = string<br>  })</pre> | <pre>{<br>  "enable_alerting_rules": true,<br>  "prometheus_metrics_endpoint": "metrics",<br>  "scrape_sample_limit": 1000<br>}</pre> | no |
| <a name="input_prometheus_config"></a> [prometheus\_config](#input\_prometheus\_config) | Controls default values such as scrape interval, timeouts and ports globally | <pre>object({<br>    global_scrape_interval = string<br>    global_scrape_timeout  = string<br>  })</pre> | <pre>{<br>  "global_scrape_interval": "60s",<br>  "global_scrape_timeout": "15s"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tracing_config"></a> [tracing\_config](#input\_tracing\_config) | Configuration object for traces collection to AWS X-Ray | <pre>object({<br>    otlp_grpc_endpoint = string<br>    otlp_http_endpoint = string<br>    send_batch_size    = number<br>    timeout            = string<br>  })</pre> | <pre>{<br>  "otlp_grpc_endpoint": "0.0.0.0:4317",<br>  "otlp_http_endpoint": "0.0.0.0:4318",<br>  "send_batch_size": 50,<br>  "timeout": "30s"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS Cluster version |
| <a name="output_grafana_dashboard_urls"></a> [grafana\_dashboard\_urls](#output\_grafana\_dashboard\_urls) | URLs for dashboards created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
