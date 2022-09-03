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
  type = string
}

variable "enable_recording_rules" {
  type    = bool
  default = true
}

variable "enable_alerting_rules" {
  type    = bool
  default = true
}

variable "enable_dashboards" {
  type    = bool
  default = true
}

variable "enable_kube_state_metrics" {
  type    = bool
  default = true
}

variable "ksm_config" {
  type = object({
    create_namespace   = bool
    k8s_namespace      = string
    helm_chart_name    = string
    helm_chart_version = string
    helm_release_name  = string
    helm_repo_url      = string
    helm_settings      = map(string)
    helm_values        = map(any)
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
  }
  nullable = false
}

variable "enable_node_exporter" {
  type    = bool
  default = true
}
variable "ne_config" {
  type = object({
    create_namespace   = bool
    k8s_namespace      = string
    helm_chart_name    = string
    helm_chart_version = string
    helm_release_name  = string
    helm_repo_url      = string
    helm_settings      = map(string)
    helm_values        = map(any)
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
  }
  nullable = false
}
variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
