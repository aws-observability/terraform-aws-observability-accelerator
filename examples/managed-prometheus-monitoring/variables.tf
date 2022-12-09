variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_prometheus_workspace_ids" {
  description = "Amazon Managed Service for Prometheus Workspace IDs to create Alarms for"
  type        = string
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  type        = string
}
