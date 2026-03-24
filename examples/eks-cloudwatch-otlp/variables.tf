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
  description = "Path to the amazon-cloudwatch-observability Helm chart. Use a local path for pre-release testing."
  type        = string
  default     = "amazon-cloudwatch-observability"
}

variable "cloudwatch_metrics_endpoint" {
  description = "CloudWatch OTLP metrics endpoint URL. Leave empty to use the CW Agent's default regional endpoint."
  type        = string
  default     = ""
}

variable "eks_node_role_name" {
  description = "Name of the EKS node group IAM role to attach CloudWatchAgentServerPolicy to. Leave empty to skip (e.g. during destroy when node groups are already gone)."
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
