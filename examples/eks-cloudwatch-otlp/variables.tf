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
  description = "CloudWatch OTLP metrics endpoint URL (Zeus)"
  type        = string
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

variable "grafana_endpoint" {
  description = "Amazon Managed Grafana workspace endpoint URL"
  type        = string
}

variable "grafana_api_key" {
  description = "Grafana API key for dashboard provisioning"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
