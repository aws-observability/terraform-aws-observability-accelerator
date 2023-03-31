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

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus Workspace ID"
  type        = string
  default     = null
}

variable "dashboards_folder_id" {
  description = "Grafana folder ID for automatic dashboards"
  type        = string
}

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards"
  type        = bool
  default     = true
}
