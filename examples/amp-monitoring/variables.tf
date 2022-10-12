variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana (AMG) workspace ID"
  type        = string
  default     = ""
}

variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = ""
}