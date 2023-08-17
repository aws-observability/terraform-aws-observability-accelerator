# Infrastructure monitoring

This module provides EKS cluster monitoring with the following resources:

- AWS Distro For OpenTelemetry Operator and Collector for Metrics and Traces
- Logs with [AWS for FluentBit](https://github.com/aws/aws-for-fluent-bit)
- Installs Grafana Operator to add AWS data sources and create Grafana Dashboards to Amazon Managed Grafana.
- Installs FluxCD to perform GitOps sync of a Git Repo to EKS Cluster. We will use this later for creating Grafana Dashboards and AWS datasources to Amazon Managed Grafana.
- Installs External Secrets Operator to retrieve and Sync the Grafana API keys from AWS SSM Parameter Store.
- Amazon Managed Grafana Dashboard and data source
- Alerts and recording rules with AWS Managed Service for Prometheus

This module makes use of the open source [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

See examples using this Terraform modules in the **Amazon EKS** section of [this documentation](https://aws-observability.github.io/terraform-aws-observability-accelerator/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.4.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_external_secrets"></a> [external\_secrets](#module\_external\_secrets) | ./add-ons/external-secrets | n/a |
| <a name="module_fluentbit_logs"></a> [fluentbit\_logs](#module\_fluentbit\_logs) | ./add-ons/aws-for-fluentbit | n/a |
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon | v4.32.0 |
| <a name="module_istio_monitoring"></a> [istio\_monitoring](#module\_istio\_monitoring) | ./patterns/istio | n/a |
| <a name="module_java_monitoring"></a> [java\_monitoring](#module\_java\_monitoring) | ./patterns/java | n/a |
| <a name="module_nginx_monitoring"></a> [nginx\_monitoring](#module\_nginx\_monitoring) | ./patterns/nginx | n/a |
| <a name="module_operator"></a> [operator](#module\_operator) | ./add-ons/adot-operator | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_rule_group_namespace.alerting_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_rule_group_namespace.recording_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [helm_release.fluxcd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.grafana_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kube_state_metrics](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_node_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.adothealth_monitoring_dashboards](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.api_server_dashboards](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.flux_gitrepository](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.flux_kustomization](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adot_loglevel"></a> [adot\_loglevel](#input\_adot\_loglevel) | Verbosity level for ADOT collector logs. This accepts (detailed\|normal\|basic), see https://aws-otel.github.io/docs/components/misc-exporters for mor infos. | `string` | `"normal"` | no |
| <a name="input_adothealth_monitoring_config"></a> [adothealth\_monitoring\_config](#input\_adothealth\_monitoring\_config) | Config object for API server monitoring | <pre>object({<br>    flux_gitrepository_name   = string<br>    flux_gitrepository_url    = string<br>    flux_gitrepository_branch = string<br>    flux_kustomization_name   = string<br>    flux_kustomization_path   = string<br><br>    dashboards = object({<br>      grafana_adothealth_dashboard_url = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_apiserver_monitoring_config"></a> [apiserver\_monitoring\_config](#input\_apiserver\_monitoring\_config) | Config object for API server monitoring | <pre>object({<br>    flux_gitrepository_name   = string<br>    flux_gitrepository_url    = string<br>    flux_gitrepository_branch = string<br>    flux_kustomization_name   = string<br>    flux_kustomization_path   = string<br><br>    dashboards = object({<br>      basic           = string<br>      advanced        = string<br>      troubleshooting = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_custom_metrics_config"></a> [custom\_metrics\_config](#input\_custom\_metrics\_config) | Configuration object to enable custom metrics collection | <pre>map(object({<br>    enableBasicAuth       = bool<br>    path                  = string<br>    basicAuthUsername     = string<br>    basicAuthPassword     = string<br>    ports                 = string<br>    droppedSeriesPrefixes = string<br>  }))</pre> | `null` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_enable_adotcollector_metrics"></a> [enable\_adotcollector\_metrics](#input\_enable\_adotcollector\_metrics) | Enables collection of ADOT collector metrics | `bool` | `true` | no |
| <a name="input_enable_alerting_rules"></a> [enable\_alerting\_rules](#input\_enable\_alerting\_rules) | Enables or disables Managed Prometheus alerting rules | `bool` | `true` | no |
| <a name="input_enable_amazon_eks_adot"></a> [enable\_amazon\_eks\_adot](#input\_enable\_amazon\_eks\_adot) | Enables the ADOT Operator on the EKS Cluster | `bool` | `true` | no |
| <a name="input_enable_apiserver_monitoring"></a> [enable\_apiserver\_monitoring](#input\_enable\_apiserver\_monitoring) | Enable EKS kube-apiserver monitoring, alerting and dashboards | `bool` | `true` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Allow reusing an existing installation of cert-manager | `bool` | `true` | no |
| <a name="input_enable_custom_metrics"></a> [enable\_custom\_metrics](#input\_enable\_custom\_metrics) | Allows additional metrics collection for config elements in the `custom_metrics_config` config object. Automatic dashboards are not included | `bool` | `false` | no |
| <a name="input_enable_dashboards"></a> [enable\_dashboards](#input\_enable\_dashboards) | Enables or disables curated dashboards | `bool` | `true` | no |
| <a name="input_enable_external_secrets"></a> [enable\_external\_secrets](#input\_enable\_external\_secrets) | Installs External Secrets to EKS Cluster | `bool` | `true` | no |
| <a name="input_enable_fluxcd"></a> [enable\_fluxcd](#input\_enable\_fluxcd) | Enables or disables FluxCD. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_grafana_operator"></a> [enable\_grafana\_operator](#input\_enable\_grafana\_operator) | Deploys Grafana Operator to EKS Cluster | `bool` | `true` | no |
| <a name="input_enable_istio"></a> [enable\_istio](#input\_enable\_istio) | Enable ISTIO workloads monitoring, alerting and default dashboards | `bool` | `false` | no |
| <a name="input_enable_java"></a> [enable\_java](#input\_enable\_java) | Enable Java workloads monitoring, alerting and default dashboards | `bool` | `false` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | Enables or disables Kube State metrics exporter. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_logs"></a> [enable\_logs](#input\_enable\_logs) | Using AWS For FluentBit to collect cluster and application logs to Amazon CloudWatch | `bool` | `true` | no |
| <a name="input_enable_nginx"></a> [enable\_nginx](#input\_enable\_nginx) | Enable NGINX workloads monitoring, alerting and default dashboards | `bool` | `false` | no |
| <a name="input_enable_node_exporter"></a> [enable\_node\_exporter](#input\_enable\_node\_exporter) | Enables or disables Node exporter. Disabling this might affect some data in the dashboards | `bool` | `true` | no |
| <a name="input_enable_recording_rules"></a> [enable\_recording\_rules](#input\_enable\_recording\_rules) | Enables or disables Managed Prometheus recording rules | `bool` | `true` | no |
| <a name="input_enable_tracing"></a> [enable\_tracing](#input\_enable\_tracing) | Enables tracing with OTLP traces receiver to X-Ray | `bool` | `true` | no |
| <a name="input_flux_config"></a> [flux\_config](#input\_flux\_config) | FluxCD configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "flux2",<br>  "helm_chart_version": "2.7.0",<br>  "helm_release_name": "observability-fluxcd-addon",<br>  "helm_repo_url": "https://fluxcd-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "flux-system"<br>}</pre> | no |
| <a name="input_flux_gitrepository_branch"></a> [flux\_gitrepository\_branch](#input\_flux\_gitrepository\_branch) | Flux GitRepository Branch | `string` | `"main"` | no |
| <a name="input_flux_gitrepository_name"></a> [flux\_gitrepository\_name](#input\_flux\_gitrepository\_name) | Flux GitRepository name | `string` | `"aws-observability-accelerator"` | no |
| <a name="input_flux_gitrepository_url"></a> [flux\_gitrepository\_url](#input\_flux\_gitrepository\_url) | Flux GitRepository URL | `string` | `"https://github.com/aws-observability/aws-observability-accelerator"` | no |
| <a name="input_flux_kustomization_name"></a> [flux\_kustomization\_name](#input\_flux\_kustomization\_name) | Flux Kustomization name | `string` | `"grafana-dashboards-infrastructure"` | no |
| <a name="input_flux_kustomization_path"></a> [flux\_kustomization\_path](#input\_flux\_kustomization\_path) | Flux Kustomization Path | `string` | `"./artifacts/grafana-operator-manifests/eks/infrastructure"` | no |
| <a name="input_go_config"></a> [go\_config](#input\_go\_config) | Grafana Operator configuration | <pre>object({<br>    create_namespace   = bool<br>    helm_chart         = string<br>    helm_name          = string<br>    k8s_namespace      = string<br>    helm_release_name  = string<br>    helm_chart_version = string<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart": "oci://ghcr.io/grafana-operator/helm-charts/grafana-operator",<br>  "helm_chart_version": "v5.0.0-rc3",<br>  "helm_name": "grafana-operator",<br>  "helm_release_name": "grafana-operator",<br>  "k8s_namespace": "grafana-operator"<br>}</pre> | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Grafana API key for the Amazon Managed Grafana workspace. Required if `enable_external_secrets = true` | `string` | `""` | no |
| <a name="input_grafana_cluster_dashboard_url"></a> [grafana\_cluster\_dashboard\_url](#input\_grafana\_cluster\_dashboard\_url) | Dashboard URL for Cluster Grafana Dashboard JSON | `string` | `"https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/infrastructure/cluster.json"` | no |
| <a name="input_grafana_kubelet_dashboard_url"></a> [grafana\_kubelet\_dashboard\_url](#input\_grafana\_kubelet\_dashboard\_url) | Dashboard URL for Kubelet Grafana Dashboard JSON | `string` | `"https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/infrastructure/kubelet.json"` | no |
| <a name="input_grafana_namespace_workloads_dashboard_url"></a> [grafana\_namespace\_workloads\_dashboard\_url](#input\_grafana\_namespace\_workloads\_dashboard\_url) | Dashboard URL for Namespace Workloads Grafana Dashboard JSON | `string` | `"https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/infrastructure/namespace-workloads.json"` | no |
| <a name="input_grafana_node_exporter_dashboard_url"></a> [grafana\_node\_exporter\_dashboard\_url](#input\_grafana\_node\_exporter\_dashboard\_url) | Dashboard URL for Node Exporter Grafana Dashboard JSON | `string` | `"https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/infrastructure/nodeexporter-nodes.json"` | no |
| <a name="input_grafana_nodes_dashboard_url"></a> [grafana\_nodes\_dashboard\_url](#input\_grafana\_nodes\_dashboard\_url) | Dashboard URL for Nodes Grafana Dashboard JSON | `string` | `"https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/infrastructure/nodes.json"` | no |
| <a name="input_grafana_url"></a> [grafana\_url](#input\_grafana\_url) | Endpoint URL of Amazon Managed Grafana workspace. Required if `enable_grafana_operator = true` | `string` | `""` | no |
| <a name="input_grafana_workloads_dashboard_url"></a> [grafana\_workloads\_dashboard\_url](#input\_grafana\_workloads\_dashboard\_url) | Dashboard URL for Workloads Grafana Dashboard JSON | `string` | `"https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/infrastructure/workloads.json"` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Prometheus | `any` | `{}` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `null` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_istio_config"></a> [istio\_config](#input\_istio\_config) | Configuration object for ISTIO monitoring | <pre>object({<br>    enable_alerting_rules  = bool<br>    enable_recording_rules = bool<br>    enable_dashboards      = bool<br>    scrape_sample_limit    = number<br><br>    flux_gitrepository_name   = string<br>    flux_gitrepository_url    = string<br>    flux_gitrepository_branch = string<br>    flux_kustomization_name   = string<br>    flux_kustomization_path   = string<br><br>    grafana_url                             = string<br>    grafana_istio_cp_dashboard_url          = string<br>    grafana_istio_mesh_dashboard_url        = string<br>    grafana_istio_performance_dashboard_url = string<br>    grafana_istio_service_dashboard_url     = string<br><br>    prometheus_metrics_endpoint = string<br>  })</pre> | `null` | no |
| <a name="input_java_config"></a> [java\_config](#input\_java\_config) | Configuration object for Java/JMX monitoring | <pre>object({<br>    enable_alerting_rules  = bool<br>    enable_recording_rules = bool<br>    enable_dashboards      = bool<br>    scrape_sample_limit    = number<br><br><br>    flux_gitrepository_name   = string<br>    flux_gitrepository_url    = string<br>    flux_gitrepository_branch = string<br>    flux_kustomization_name   = string<br>    flux_kustomization_path   = string<br><br>    grafana_dashboard_url = string<br><br>    prometheus_metrics_endpoint = string<br>  })</pre> | `null` | no |
| <a name="input_ksm_config"></a> [ksm\_config](#input\_ksm\_config) | Kube State metrics configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br><br>    scrape_interval = string<br>    scrape_timeout  = string<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "kube-state-metrics",<br>  "helm_chart_version": "4.24.0",<br>  "helm_release_name": "kube-state-metrics",<br>  "helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "kube-system",<br>  "scrape_interval": "60s",<br>  "scrape_timeout": "15s"<br>}</pre> | no |
| <a name="input_logs_config"></a> [logs\_config](#input\_logs\_config) | Configuration object for logs collection | <pre>object({<br>    cw_log_retention_days = number<br>  })</pre> | <pre>{<br>  "cw_log_retention_days": 90<br>}</pre> | no |
| <a name="input_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#input\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus Workspace ID | `string` | `null` | no |
| <a name="input_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#input\_managed\_prometheus\_workspace\_region) | Amazon Managed Prometheus Workspace's Region | `string` | `null` | no |
| <a name="input_ne_config"></a> [ne\_config](#input\_ne\_config) | Node exporter configuration | <pre>object({<br>    create_namespace   = bool<br>    k8s_namespace      = string<br>    helm_chart_name    = string<br>    helm_chart_version = string<br>    helm_release_name  = string<br>    helm_repo_url      = string<br>    helm_settings      = map(string)<br>    helm_values        = map(any)<br><br>    scrape_interval = string<br>    scrape_timeout  = string<br>  })</pre> | <pre>{<br>  "create_namespace": true,<br>  "helm_chart_name": "prometheus-node-exporter",<br>  "helm_chart_version": "4.14.0",<br>  "helm_release_name": "prometheus-node-exporter",<br>  "helm_repo_url": "https://prometheus-community.github.io/helm-charts",<br>  "helm_settings": {},<br>  "helm_values": {},<br>  "k8s_namespace": "prometheus-node-exporter",<br>  "scrape_interval": "60s",<br>  "scrape_timeout": "60s"<br>}</pre> | no |
| <a name="input_nginx_config"></a> [nginx\_config](#input\_nginx\_config) | Configuration object for NGINX monitoring | <pre>object({<br>    enable_alerting_rules  = bool<br>    enable_recording_rules = bool<br>    enable_dashboards      = bool<br>    scrape_sample_limit    = number<br><br>    flux_gitrepository_name   = string<br>    flux_gitrepository_url    = string<br>    flux_gitrepository_branch = string<br>    flux_kustomization_name   = string<br>    flux_kustomization_path   = string<br><br>    grafana_dashboard_url = string<br><br>    prometheus_metrics_endpoint = string<br>  })</pre> | `null` | no |
| <a name="input_prometheus_config"></a> [prometheus\_config](#input\_prometheus\_config) | Controls default values such as scrape interval, timeouts and ports globally | <pre>object({<br>    global_scrape_interval = string<br>    global_scrape_timeout  = string<br>  })</pre> | <pre>{<br>  "global_scrape_interval": "120s",<br>  "global_scrape_timeout": "15s"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_target_secret_name"></a> [target\_secret\_name](#input\_target\_secret\_name) | Target secret in Kubernetes to store the Grafana API Key Secret | `string` | `"grafana-admin-credentials"` | no |
| <a name="input_target_secret_namespace"></a> [target\_secret\_namespace](#input\_target\_secret\_namespace) | Target namespace of secret in Kubernetes to store the Grafana API Key Secret | `string` | `"grafana-operator"` | no |
| <a name="input_tracing_config"></a> [tracing\_config](#input\_tracing\_config) | Configuration object for traces collection to AWS X-Ray | <pre>object({<br>    otlp_grpc_endpoint = string<br>    otlp_http_endpoint = string<br>    send_batch_size    = number<br>    timeout            = string<br>  })</pre> | <pre>{<br>  "otlp_grpc_endpoint": "0.0.0.0:4317",<br>  "otlp_http_endpoint": "0.0.0.0:4318",<br>  "send_batch_size": 50,<br>  "timeout": "30s"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS Cluster version |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
