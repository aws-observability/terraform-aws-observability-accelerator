variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus Workspace ID"
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

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
