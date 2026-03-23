variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_id" {
  description = "EKS cluster name"
  type        = string
}

variable "cloudwatch_metrics_endpoint" {
  description = "CloudWatch OTLP metrics endpoint URL. Defaults to the regional endpoint if empty."
  type        = string
  default     = ""
}

variable "cloudwatch_log_group" {
  description = "CloudWatch Logs log group for OTLP logs exporter"
  type        = string
  default     = "/eks/otel-collector"
}

variable "cloudwatch_log_stream" {
  description = "CloudWatch Logs log stream for OTLP logs exporter"
  type        = string
  default     = "otel-logs"
}

# These are auto-populated by install.sh on the second apply.
# Leave empty for the first apply (creates workspace + collector).
variable "grafana_endpoint" {
  description = "Amazon Managed Grafana workspace URL. Leave empty on first apply — install.sh fills it automatically."
  type        = string
  default     = ""
}

variable "grafana_api_key" {
  description = "Grafana service account token. Leave empty on first apply — install.sh fills it automatically."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
