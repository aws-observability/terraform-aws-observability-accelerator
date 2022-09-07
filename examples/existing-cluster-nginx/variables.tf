variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
}
variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus (AMP) workspace ID"
  type        = string
  default     = ""
}
variable "managed_prometheus_endpoint" {
  description = "AMP workspace ID"
  type        = string
  default     = ""
}
variable "managed_prometheus_region" {
  description = "Region where AMP is deployed"
  type        = string
  default     = ""
}
variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana (AMG) workspace ID"
  type        = string
  default     = ""
}
variable "grafana_endpoint" {
  description = "AMG endpoint"
  type        = string
  default     = null
}
variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}