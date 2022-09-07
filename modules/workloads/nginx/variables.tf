
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

variable "enable_node_exporter" {
  type    = bool
  default = true
}

variable "config" {
  type = object({
    helm_config = map(any)

    kms_create_namespace   = bool
    ksm_k8s_namespace      = string
    ksm_helm_chart_name    = string
    ksm_helm_chart_version = string
    ksm_helm_release_name  = string
    ksm_helm_repo_url      = string
    ksm_helm_settings      = map(string)
    ksm_helm_values        = map(any)

    ne_create_namespace   = bool
    ne_k8s_namespace      = string
    ne_helm_chart_name    = string
    ne_helm_chart_version = string
    ne_helm_release_name  = string
    ne_helm_repo_url      = string
    ne_helm_settings      = map(string)
    ne_helm_values        = map(any)

  })

  default = {
    enable_kube_state_metrics = true
    enable_node_exporter      = true

    helm_config = {}

    kms_create_namespace   = true
    ksm_helm_chart_name    = "kube-state-metrics"
    ksm_helm_chart_version = "4.9.2"
    ksm_helm_release_name  = "kube-state-metrics"
    ksm_helm_repo_url      = "https://prometheus-community.github.io/helm-charts"
    ksm_helm_settings      = {}
    ksm_helm_values        = {}
    ksm_k8s_namespace      = "kube-system"

    ne_create_namespace   = true
    ne_k8s_namespace      = "prometheus-node-exporter"
    ne_helm_chart_name    = "prometheus-node-exporter"
    ne_helm_chart_version = "2.0.3"
    ne_helm_release_name  = "prometheus-node-exporter"
    ne_helm_repo_url      = "https://prometheus-community.github.io/helm-charts"
    ne_helm_settings      = {}
    ne_helm_values        = {}
  }
  nullable = false
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}


