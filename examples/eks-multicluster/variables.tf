variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = ""
}

variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "enable_alertmanager" {
  description = "Boolean flag to enable the AlertManager"
  type        = bool
  default     = false
}

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards"
  type        = bool
  default     = true
}

variable "create_prometheus_data_source" {
  description = "Boolean flag to determine creation of Amazon Managed service for Prometheus as a datasource"
  type        = bool
  default     = false
}

variable "create_dashboard_folder" {
  description = "Boolean flag to enable Amazon Managed Grafana folder and dashboards"
  type        = bool
  default     = false
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
  default     = ""
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
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

variable "enable_java_recording_rules" {
  description = "Enables or disables Managed Prometheus recording rules for Java applications. Disabling this might affect some data in the dashboards"
  type        = bool
  default     = true
}

variable "enable_java_alerting_rules" {
  description = "Enables or disables Managed Prometheus alerting rule for Java applications"
  type        = bool
  default     = true
}
