variable "primary_eks_cluster" {
  description = "Name of the primary EKS cluster"
  type = object({
    aws_region = string
    id         = string
  })
  default = {
    aws_region = "us-west-2"
    id         = "eks-cluster-1"
  }
  nullable = false
}

variable "secondary_eks_cluster" {
  description = "Name of the secondary EKS cluster"
  type = object({
    aws_region = string
    id         = string
  })
  default = {
    aws_region = "us-west-2"
    id         = "eks-cluster-2"
  }
  nullable = true
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
