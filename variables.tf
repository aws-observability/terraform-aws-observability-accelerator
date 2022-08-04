variable "java" {
  default = {
    a = ""
    b = ""
  }
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
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

variable "enable_amazon_eks_adot" {
  type    = bool
  default = true
}

variable "enable_cert_manager" {
  description = "Allow reusing an existing installation of cert-manager"
  type        = bool
  default     = true
}

variable "enable_opentelemetry_operator" {
  type    = bool
  default = false
}

variable "enable_managed_prometheus" {
  type    = bool
  default = true
}

variable "managed_prometheus_id" {
  description = "AWS Managed Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_prometheus_region" {
  description = "AWS Managed Prometheus Workspace Region"
  type        = string
  default     = null
}

variable "enable_alertmanager" {
  description = "Create AMP AlertManager for all workloads"
  type        = bool
  default     = false
}

variable "enable_managed_grafana" {
  type    = bool
  default = true
}


variable "managed_grafana_region" {
  description = "AWS Managed Grafana Workspace Region"
  type        = string
  default     = null
}
variable "managed_grafana_workspace_id" {
  type    = string
  default = ""
}
variable "grafana_api_key" {
  type    = string
  default = null
}

variable "enable_java" {
  description = "Deploys a collector for JAVA/JMX based workloads, dashboards and alerting rules"
  type        = bool
  default     = false
}

variable "enable_java_recording_rules" {
  description = "Enable AMP recording rules for Java"
  type        = bool
  default     = true
}

# variable "java_config" {
#   description = "Input configuration Java workloads"
#   type = object({
#     enable_recording_rules = bool
#   })
# }


variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}


variable "enable_infra_metrics" {
  type    = bool
  default = false
}

variable "infra_metrics_config" {
  type = object({
    helm_config = map(any)

    enable_kube_state_metrics = bool
    kms_create_namespace      = bool
    ksm_k8s_namespace         = string
    ksm_helm_chart_name       = string
    ksm_helm_chart_version    = string
    ksm_helm_release_name     = string
    ksm_helm_repo_url         = string
    ksm_helm_settings         = map(string)
    ksm_helm_values           = map(any)

    enable_node_exporter  = bool
    ne_create_namespace   = bool
    ne_k8s_namespace      = string
    ne_helm_chart_name    = string
    ne_helm_chart_version = string
    ne_helm_release_name  = string
    ne_helm_repo_url      = string
    ne_helm_settings      = map(string)
    ne_helm_values        = map(any)
  })

  default = null

  # default = {
  #   enable_kube_state_metrics = true
  #   enable_node_exporter      = true
  #   helm_config               = {}

  #   kms_create_namespace   = true
  #   ksm_helm_chart_name    = "kube-state-metrics"
  #   ksm_helm_chart_version = "4.9.2"
  #   ksm_helm_release_name  = "kube-state-metrics"
  #   ksm_helm_repo_url      = "https://prometheus-community.github.io/helm-charts"
  #   ksm_helm_settings      = {}
  #   ksm_helm_values        = {}
  #   ksm_k8s_namespace      = "kube-system"

  #   ne_create_namespace   = true
  #   ne_k8s_namespace      = "prometheus-node-exporter"
  #   ne_helm_chart_name    = "prometheus-node-exporter"
  #   ne_helm_chart_version = "2.0.3"
  #   ne_helm_release_name  = "prometheus-node-exporter"
  #   ne_helm_repo_url      = "https://prometheus-community.github.io/helm-charts"
  #   ne_helm_settings      = {}
  #   ne_helm_values        = {}
  # }
}
