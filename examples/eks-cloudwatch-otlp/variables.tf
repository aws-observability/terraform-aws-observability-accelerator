variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_id" {
  description = "EKS cluster name"
  type        = string
}

variable "cloudwatch_metrics_endpoint" {
  description = "CloudWatch OTLP metrics endpoint URL. Leave empty for the default regional endpoint."
  type        = string
  default     = ""
}

variable "grafana_endpoint" {
  description = "Amazon Managed Grafana workspace URL (from managed-grafana-workspace example output)."
  type        = string
  default     = ""
}

variable "grafana_api_key" {
  description = "Grafana service account token (from managed-grafana-workspace example output)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "grafana_cw_datasource_name" {
  description = "Name for the CloudWatch PromQL datasource in Grafana. Override when deploying multiple regions to the same workspace."
  type        = string
  default     = "CloudWatch PromQL"
}

variable "grafana_folder_id" {
  description = "Existing Grafana folder ID to deploy dashboards into. If null, creates a new folder."
  type        = string
  default     = null
}