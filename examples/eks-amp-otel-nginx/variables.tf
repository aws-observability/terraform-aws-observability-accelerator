variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider for IRSA role creation"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID. Leave empty to create a new workspace."
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
  description = "Whether to provision Grafana dashboards via the Grafana Terraform provider"
  type        = bool
  default     = true
}
