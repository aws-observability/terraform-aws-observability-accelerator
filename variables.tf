variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "enable_managed_prometheus" {
  description = "Creates a new Amazon Managed Service for Prometheus Workspace"
  type        = bool
  default     = true
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_prometheus_workspace_region" {
  description = "Region where Amazon Managed Service for Prometheus is deployed"
  type        = string
  default     = null
}

variable "enable_alertmanager" {
  description = "Creates Amazon Managed Service for Prometheus AlertManager for all workloads"
  type        = bool
  default     = false
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
  default     = ""
}

variable "grafana_api_key" {
  description = "Grafana API key for the Amazon Managed Grafana workspace"
  type        = string
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
