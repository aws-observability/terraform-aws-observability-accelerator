variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "helm_config" {
  description = "Helm Config for Prometheus"
  type        = any
  default     = {}
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  type        = string
  default     = null
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

variable "dashboards_folder_id" {
  description = "Grafana folder ID for automatic dashboards"
  type        = string
}

variable "enable_recording_rules" {
  description = "Enables or disables Managed Prometheus recording rules. Disabling this might affect some data in the dashboards"
  type        = bool
  default     = true
}

variable "enable_alerting_rules" {
  description = "Enables or disables Managed Prometheus alerting rules"
  type        = bool
  default     = true
}

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards"
  type        = bool
  default     = true
}

variable "enable_kube_state_metrics" {
  description = "Enables or disables Kube State metrics exporter. Disabling this might affect some data in the dashboards"
  type        = bool
  default     = true
}

variable "ksm_config" {
  description = "Kube State metrics configuration"
  type = object({
    create_namespace   = bool
    k8s_namespace      = string
    helm_chart_name    = string
    helm_chart_version = string
    helm_release_name  = string
    helm_repo_url      = string
    helm_settings      = map(string)
    helm_values        = map(any)

    scrape_interval = string
    scrape_timeout  = string
  })

  default = {
    create_namespace   = true
    helm_chart_name    = "kube-state-metrics"
    helm_chart_version = "4.16.0"
    helm_release_name  = "kube-state-metrics"
    helm_repo_url      = "https://prometheus-community.github.io/helm-charts"
    helm_settings      = {}
    helm_values        = {}
    k8s_namespace      = "kube-system"

    scrape_interval = "60s"
    scrape_timeout  = "15s"
  }
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
    create_namespace   = bool
    k8s_namespace      = string
    helm_chart_name    = string
    helm_chart_version = string
    helm_release_name  = string
    helm_repo_url      = string
    helm_settings      = map(string)
    helm_values        = map(any)

    scrape_interval = string
    scrape_timeout  = string
  })

  default = {
    create_namespace   = true
    helm_chart_name    = "prometheus-node-exporter"
    helm_chart_version = "2.0.3"
    helm_release_name  = "prometheus-node-exporter"
    helm_repo_url      = "https://prometheus-community.github.io/helm-charts"
    helm_settings      = {}
    helm_values        = {}
    k8s_namespace      = "prometheus-node-exporter"

    scrape_interval = "60s"
    scrape_timeout  = "60s"
  }
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
    global_scrape_interval = string
    global_scrape_timeout  = string
  })

  default = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }
  nullable = false
}

variable "enable_tracing" {
  description = "(Experimental) Enables tracing with AWS X-Ray. This changes the deploy mode of the collector to daemon set. Requirement: adot add-on <= 0.58-build.0"
  type        = bool
  default     = false
}

variable "enable_custom_metrics" {
  description = "Allows additional metrics collection for config elements in the `custom_metrics_config` config object. Automatic dashboards are not included"
  type        = bool
  default     = false
}

variable "custom_metrics_config" {
  description = "Configuration object to enable custom metrics collection"
  type = object({
    ports = list(number)
    # paths = optional(list(string), ["/metrics"])
    # list of samples to be dropped by label prefix, ex: go_ -> discards go_.*
    dropped_series_prefixes = list(string)
  })

  default = {
    ports                   = []
    dropped_series_prefixes = ["unspecified"]
  }
}
