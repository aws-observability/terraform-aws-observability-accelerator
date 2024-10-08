variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_prometheus_workspace_ids" {
  description = "Amazon Managed Service for Prometheus Workspace ID to create Alarms for"
  type        = string
}

variable "active_series_threshold" {
  description = "Threshold for active series metric alarm"
  type        = number
  default     = 8000000
}

variable "ingestion_rate_threshold" {
  description = "Threshold for active series metric alarm"
  type        = number
  default     = 136000
}

variable "dashboards_folder_id" {
  description = "Grafana folder ID for automatic dashboards"
  default     = "0"
  type        = string
}
