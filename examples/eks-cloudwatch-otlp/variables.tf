variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_id" {
  description = "EKS cluster name"
  type        = string
}

variable "cw_agent_chart_path" {
  description = "Absolute local path to the amazon-cloudwatch-observability Helm chart for pre-release testing. Leave empty to pull from the public Helm repo."
  type        = string
  default     = ""
}

variable "cw_agent_image" {
  description = "Override the CloudWatch Agent container image (e.g. '123456789.dkr.ecr.us-east-1.amazonaws.com/cw-agent-dev:latest'). Leave empty for chart default."
  type        = string
  default     = ""
}

variable "cloudwatch_metrics_endpoint" {
  description = "CloudWatch OTLP metrics endpoint URL. Leave empty to use the CW Agent's default regional endpoint."
  type        = string
  default     = ""
}

# These are auto-populated by install.sh on the second apply.
# Leave empty for the first apply (creates workspace + CW Agent).
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
