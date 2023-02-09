variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-with-vpc"
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1" 
}
variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = "ws-0337f531-5732-4361-acfe-e1800abc785f"
}
variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
  default     = "g-120c5f0253"
}
variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = "eyJrIjoic2tWTm5Nb0JSZnNTalMxOWtENndwMzNTekw3b09vMWUiLCJuIjoiRGVtbyIsImlkIjoxfQ=="
  sensitive   = true
}
