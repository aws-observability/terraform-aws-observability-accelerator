
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
  default     = null
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

variable "dashboards_folder_id" {
  type        = string
  description = "Grafana folder ID for automatic dashboards"
}

variable "enable_alerting_rules" {
  type        = bool
  default     = true
  description = "Enables or disables Managed Prometheus alerting rules"
}

variable "enable_dashboards" {
  type        = bool
  description = "Enables or disables curated dashboards"
  default     = true
}

variable "config" {
  description = "Helm Config for Prometheus"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
