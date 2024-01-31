variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-with-vpc"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  sensitive   = true
}

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards. Dashboards are managed by the Grafana Operator"
  type        = bool
  default     = true
}

variable "enable_grafana_key_rotation" {
  description = "Enables or disables Grafana API key rotation"
  type        = bool
  default     = true
}

variable "grafana_api_key_interval" {
  description = "Number of seconds for secondsToLive value while creating API Key"
  type        = number
  default     = 5400
}

variable "eventbridge_scheduler_schedule_expression" {
  description = "Schedule Expression for EventBridge Scheduler in Grafana API Key Rotation"
  type        = string
  default     = "rate(60 minutes)"
}

variable "grafana_api_key_refresh_interval" {
  description = "Refresh Internal to be used by External Secrets for Grafana API Key rotation"
  type        = string
  default     = "5m"
}

variable "lambda_runtime_grafana_key_rotation" {
  description = "Python Runtime Identifier for the Lambda Function"
  type        = string
  default     = "python3.12"
}
