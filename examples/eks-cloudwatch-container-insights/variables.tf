variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "eks_cluster_id" {
  type = string
}

variable "cw_agent_chart_path" {
  description = "Local path to the amazon-cloudwatch-observability Helm chart"
  type        = string
  default     = ""
}

variable "cw_agent_image" {
  description = "Override CW Agent image (e.g. '123456789.dkr.ecr.us-east-1.amazonaws.com/cw-agent-dev:latest')"
  type        = string
  default     = ""
}

variable "cloudwatch_metrics_endpoint" {
  description = "CloudWatch OTLP metrics endpoint URL override"
  type        = string
  default     = ""
}

variable "grafana_endpoint" {
  type    = string
  default = ""
}

variable "grafana_api_key" {
  type      = string
  default   = ""
  sensitive = true
}
