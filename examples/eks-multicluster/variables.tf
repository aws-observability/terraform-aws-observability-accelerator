variable "eks_cluster_1_id" {
  description = "Name or ID of the EKS cluster 1"
  type        = string
  default     = "eks-cluster-1"
  nullable    = false
}

variable "eks_cluster_1_region" {
  description = "AWS region of the EKS cluster 1"
  type        = string
  default     = "us-west-2"
  nullable    = false
}

variable "eks_cluster_2_id" {
  description = "Name or ID of the EKS cluster 2"
  type        = string
  default     = "eks-cluster-2"
  nullable    = true
}

variable "eks_cluster_2_region" {
  description = "AWS region of the EKS cluster 2"
  type        = string
  default     = "us-west-2"
  nullable    = true
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
  default     = ""
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}
