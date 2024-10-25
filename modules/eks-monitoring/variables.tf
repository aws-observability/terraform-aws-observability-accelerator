variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "enable_amazon_eks_adot" {
  description = "Enables the ADOT Operator on the EKS Cluster"
  type        = bool
  default     = true
}

variable "enable_managed_prometheus" {
  description = "Creates a new Amazon Managed Service for Prometheus Workspace"
  type        = bool
  default     = true
}

variable "enable_alertmanager" {
  description = "Creates Amazon Managed Service for Prometheus AlertManager for all workloads"
  type        = bool
  default     = false
}

variable "enable_cert_manager" {
  description = "Allow reusing an existing installation of cert-manager"
  type        = bool
  default     = true
}

variable "helm_config" {
  description = "Helm Config for Prometheus"
  type        = any
  default     = {}
}

variable "irsa_iam_role_name" {
  description = "IAM role name for IRSA roles"
  type        = string
  default     = ""
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = null
}

variable "irsa_iam_additional_policies" {
  description = "IAM additional policies for IRSA roles"
  type        = list(string)
  default     = []
}

variable "adot_loglevel" {
  description = "Verbosity level for ADOT collector logs. This accepts (detailed|normal|basic), see https://aws-otel.github.io/docs/components/misc-exporters for more info."
  type        = string
  default     = "normal"
}

variable "adot_service_telemetry_loglevel" {
  description = "Verbosity level for ADOT service telemetry logs. See https://opentelemetry.io/docs/collector/configuration/#telemetry for more info."
  type        = string
  default     = "INFO"
}

variable "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  type        = string
  default     = ""
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus Workspace ID"
  type        = string
  default     = null
}

variable "managed_prometheus_workspace_region" {
  description = "Amazon Managed Prometheus Workspace's Region"
  type        = string
  default     = null
}

variable "managed_prometheus_cross_account_role" {
  description = "Amazon Managed Prometheus Workspace's Account Role Arn"
  type        = string
  default     = ""
}

variable "enable_alerting_rules" {
  description = "Enables or disables Managed Prometheus alerting rules"
  type        = bool
  default     = true
}

variable "enable_recording_rules" {
  description = "Enables or disables Managed Prometheus recording rules"
  type        = bool
  default     = true
}

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards"
  type        = bool
  default     = true
}

variable "flux_kustomization_name" {
  description = "Flux Kustomization name"
  type        = string
  default     = "grafana-dashboards-infrastructure"
}

variable "flux_gitrepository_name" {
  description = "Flux GitRepository name"
  type        = string
  default     = "aws-observability-accelerator"
}

variable "flux_gitrepository_url" {
  description = "Flux GitRepository URL"
  type        = string
  default     = "https://github.com/aws-observability/aws-observability-accelerator"
}

variable "flux_gitrepository_branch" {
  description = "Flux GitRepository Branch"
  type        = string
  default     = "v0.3.2"
}

variable "flux_kustomization_path" {
  description = "Flux Kustomization Path"
  type        = string
  default     = "./artifacts/grafana-operator-manifests/eks/infrastructure"
}

variable "enable_kube_state_metrics" {
  description = "Enables or disables Kube State metrics exporter. Disabling this might affect some data in the dashboards"
  type        = bool
  default     = true
}

variable "ksm_config" {
  description = "Kube State metrics configuration"
  type = object({
    create_namespace   = optional(bool, true)
    k8s_namespace      = optional(string, "kube-system")
    helm_chart_name    = optional(string, "kube-state-metrics")
    helm_chart_version = optional(string, "5.15.2")
    helm_release_name  = optional(string, "kube-state-metrics")
    helm_repo_url      = optional(string, "https://prometheus-community.github.io/helm-charts")
    helm_settings      = optional(map(string), {})
    helm_values        = optional(map(any), {})

    scrape_interval = optional(string, "60s")
    scrape_timeout  = optional(string, "15s")
  })

  default  = {}
  nullable = false
}

variable "enable_node_exporter" {
  description = "Enables or disables Node exporter. Disabling this might affect some data in the dashboards"
  type        = bool
  default     = true
}

variable "ne_config" {
  description = "Node exporter configuration"
  type = object({
    create_namespace   = optional(bool, true)
    k8s_namespace      = optional(string, "prometheus-node-exporter")
    helm_chart_name    = optional(string, "prometheus-node-exporter")
    helm_chart_version = optional(string, "4.24.0")
    helm_release_name  = optional(string, "prometheus-node-exporter")
    helm_repo_url      = optional(string, "https://prometheus-community.github.io/helm-charts")
    helm_settings      = optional(map(string), {})
    helm_values        = optional(map(any), {})

    scrape_interval = optional(string, "60s")
    scrape_timeout  = optional(string, "60s")
  })

  default  = {}
  nullable = false
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}

variable "prometheus_config" {
  description = "Controls default values such as scrape interval, timeouts and ports globally"
  type = object({
    global_scrape_interval = optional(string, "120s")
    global_scrape_timeout  = optional(string, "15s")
  })

  default  = {}
  nullable = false
}

variable "enable_apiserver_monitoring" {
  description = "Enable EKS kube-apiserver monitoring, alerting and dashboards"
  type        = bool
  default     = true
}

variable "apiserver_monitoring_config" {
  description = "Config object for API server monitoring"
  type = object({
    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    dashboards = object({
      basic           = string
      advanced        = string
      troubleshooting = string
    })
  })

  # defaults are pre-computed in locals.tf, provide a full definition to override
  default = null
}

variable "enable_tracing" {
  description = "Enables tracing with OTLP traces receiver to X-Ray"
  type        = bool
  default     = true
}

variable "tracing_config" {
  description = "Configuration object for traces collection to AWS X-Ray"
  type = object({
    otlp_grpc_endpoint = optional(string, "0.0.0.0:4317")
    otlp_http_endpoint = optional(string, "0.0.0.0:4318")
    send_batch_size    = optional(number, 50)
    timeout            = optional(string, "30s")
  })

  default  = {}
  nullable = false
}

variable "enable_custom_metrics" {
  description = "Allows additional metrics collection for config elements in the `custom_metrics_config` config object. Automatic dashboards are not included"
  type        = bool
  default     = false
}

variable "custom_metrics_config" {
  description = "Configuration object to enable custom metrics collection"
  type = map(object({
    enableBasicAuth       = bool
    path                  = string
    basicAuthUsername     = string
    basicAuthPassword     = string
    ports                 = string
    droppedSeriesPrefixes = string
  }))

  default = null
}

variable "enable_java" {
  description = "Enable Java workloads monitoring, alerting and default dashboards"
  type        = bool
  default     = false
}

variable "java_config" {
  description = "Configuration object for Java/JMX monitoring"
  type = object({
    enable_alerting_rules  = bool
    enable_recording_rules = bool
    enable_dashboards      = bool
    scrape_sample_limit    = number


    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    grafana_dashboard_url = string

    prometheus_metrics_endpoint = string
  })

  # defaults are pre-computed in locals.tf, provide a full definition to override
  default = null
}

variable "enable_nginx" {
  description = "Enable NGINX workloads monitoring, alerting and default dashboards"
  type        = bool
  default     = false
}

variable "nginx_config" {
  description = "Configuration object for NGINX monitoring"
  type = object({
    enable_alerting_rules  = optional(bool)
    enable_recording_rules = optional(bool)
    enable_dashboards      = optional(bool)
    scrape_sample_limit    = optional(number)

    flux_gitrepository_name   = optional(string)
    flux_gitrepository_url    = optional(string)
    flux_gitrepository_branch = optional(string)
    flux_kustomization_name   = optional(string)
    flux_kustomization_path   = optional(string)

    grafana_dashboard_url = optional(string)

    prometheus_metrics_endpoint = optional(string)
  })

  # defaults are pre-computed in locals.tf
  default = {}
}

variable "enable_istio" {
  description = "Enable ISTIO workloads monitoring, alerting and default dashboards"
  type        = bool
  default     = false
}


variable "istio_config" {
  description = "Configuration object for ISTIO monitoring"
  type = object({
    enable_alerting_rules  = bool
    enable_recording_rules = bool
    enable_dashboards      = bool
    scrape_sample_limit    = number

    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    managed_prometheus_workspace_id = string
    prometheus_metrics_endpoint     = string

    dashboards = object({
      cp          = string
      mesh        = string
      performance = string
      service     = string
    })
  })

  # defaults are pre-computed in locals.tf, provide a full definition to override
  default = null
}

variable "enable_logs" {
  description = "Using AWS For FluentBit to collect cluster and application logs to Amazon CloudWatch"
  type        = bool
  default     = true
}

variable "logs_config" {
  description = "Configuration object for logs collection"
  type = object({
    cw_log_retention_days = number
  })

  default = {
    # Valid values are  [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653]
    cw_log_retention_days = 90
  }
}

variable "enable_fluxcd" {
  description = "Enables or disables FluxCD. Disabling this might affect some data in the dashboards"
  type        = bool
  default     = true
}

variable "flux_config" {
  description = "FluxCD configuration"
  type = object({
    create_namespace   = optional(bool, true)
    k8s_namespace      = optional(string, "flux-system")
    helm_chart_name    = optional(string, "flux2")
    helm_chart_version = optional(string, "2.12.2")
    helm_release_name  = optional(string, "observability-fluxcd-addon")
    helm_repo_url      = optional(string, "https://fluxcd-community.github.io/helm-charts")
    helm_settings      = optional(map(string), {})
    helm_values        = optional(map(any), {})
  })

  default  = {}
  nullable = false
}

variable "enable_grafana_operator" {
  description = "Deploys Grafana Operator to EKS Cluster"
  type        = bool
  default     = true
}

variable "go_config" {
  description = "Grafana Operator configuration"
  type = object({
    create_namespace   = optional(bool, true)
    helm_chart         = optional(string, "oci://ghcr.io/grafana-operator/helm-charts/grafana-operator")
    helm_name          = optional(string, "grafana-operator")
    k8s_namespace      = optional(string, "grafana-operator")
    helm_release_name  = optional(string, "grafana-operator")
    helm_chart_version = optional(string, "v5.5.2")
  })

  default  = {}
  nullable = false
}

variable "enable_external_secrets" {
  description = "Installs External Secrets to EKS Cluster"
  type        = bool
  default     = true
}

variable "grafana_api_key" {
  description = "Grafana API key for the Amazon Managed Grafana workspace. Required if `enable_external_secrets = true`"
  type        = string
  default     = ""
}

variable "grafana_url" {
  description = "Endpoint URL of Amazon Managed Grafana workspace. Required if `enable_grafana_operator = true`"
  type        = string
  default     = ""
}

variable "grafana_cluster_dashboard_url" {
  description = "Dashboard URL for Cluster Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/infrastructure/cluster.json"
}

variable "grafana_kubelet_dashboard_url" {
  description = "Dashboard URL for Kubelet Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/infrastructure/kubelet.json"
}

variable "grafana_kubeproxy_dashboard_url" {
  description = "Dashboard URL for kube-proxy Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/kube-proxy/kube-proxy.json"
}

variable "grafana_namespace_workloads_dashboard_url" {
  description = "Dashboard URL for Namespace Workloads Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/infrastructure/namespace-workloads.json"
}

variable "grafana_node_exporter_dashboard_url" {
  description = "Dashboard URL for Node Exporter Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/infrastructure/nodeexporter-nodes.json"
}

variable "grafana_nodes_dashboard_url" {
  description = "Dashboard URL for Nodes Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/infrastructure/nodes.json"
}

variable "grafana_workloads_dashboard_url" {
  description = "Dashboard URL for Workloads Grafana Dashboard JSON"
  type        = string
  default     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/infrastructure/workloads.json"
}

variable "target_secret_name" {
  description = "Target secret in Kubernetes to store the Grafana API Key Secret"
  type        = string
  default     = "grafana-admin-credentials"
}

variable "target_secret_namespace" {
  description = "Target namespace of secret in Kubernetes to store the Grafana API Key Secret"
  type        = string
  default     = "grafana-operator"
}

variable "enable_adotcollector_metrics" {
  description = "Enables collection of ADOT collector metrics"
  type        = bool
  default     = true
}

variable "enable_nvidia_monitoring" {
  description = "Enables monitoring of nvidia metrics"
  type        = bool
  default     = true
}

variable "nvidia_monitoring_config" {
  description = "Config object for nvidia monitoring"
  type = object({
    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string
  })

  # defaults are pre-computed in locals.tf, provide a full definition to override
  default = null
}

variable "adothealth_monitoring_config" {
  description = "Config object for ADOT health monitoring"
  type = object({
    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    dashboards = object({
      health = string
    })
  })

  # defaults are pre-computed in locals.tf, provide a full definition to override
  default = null
}

variable "kubeproxy_monitoring_config" {
  description = "Config object for kube-proxy monitoring"
  type = object({
    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    dashboards = object({
      default = string
    })
  })

  # defaults are pre-computed in locals.tf, provide a full definition to override
  default = null
}

variable "enable_polyglot" {
  description = "Enable monitoring for .net,Rust and other languages"
  type        = bool
  default     = false
}
