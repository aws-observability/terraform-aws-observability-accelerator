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

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards"
  type        = bool
  default     = true
}

variable "flux_name" {
  description = "Flux GitRepository and Kustomization Name"
  type        = string
  default     = "grafana-dashboards"
}

variable "flux_gitrepository_url" {
  description = "Flux GitRepository URL"
  type        = string
  default     = "https://github.com/aws-observability/aws-observability-accelerator"
}

variable "flux_gitrepository_branch" {
  description = "Flux GitRepository Branch"
  type        = string
  default     = "main"
}

variable "flux_kustomization_path" {
  description = "Flux Kustomization Path"
  type        = string
  default     = "./artifacts/grafana-operator-manifests"
}

